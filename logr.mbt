/// MoonBit implementation of go-logr
/// 
/// logr offers an opinion on how MoonBit programs and libraries can do logging
/// without becoming coupled to a particular logging implementation. This is not 
/// an implementation of logging - it is an API.
///
/// The `Logger` type is intended for application and library authors. It provides
/// a relatively small API which can be used everywhere you want to emit logs.

///| Value type for structured logging

///|
/// Value represents any value that can be logged
pub enum Value {
  VString(String)
  VInt(Int)
  VBool(Bool)
  VDouble(Double)
  VArray(Array[Value])
  VMap(Map[String, Value])
  VNone
} derive(Eq, Show)

///|
/// Convert common types to Value
pub fn Value::from_string(s : String) -> Value {
  VString(s)
}

///|
pub fn Value::from_int(i : Int) -> Value {
  VInt(i)
}

///|
pub fn Value::from_bool(b : Bool) -> Value {
  VBool(b)
}

///|
pub fn Value::from_double(d : Double) -> Value {
  VDouble(d)
}

///| RuntimeInfo and basic types

///|
/// RuntimeInfo holds information that the logr library knows
pub struct RuntimeInfo {
  /// CallDepth is the number of call frames the logr library adds
  call_depth : Int
} derive(Eq, Show, Default)

///|
/// Message classes for caller logging
pub enum MessageClass {
  None
  All
  Info
  Error
} derive(Eq, Show)

///|
impl Default for MessageClass with default() {
  None
}

///| LogSink implementations

///|
/// Abstract LogSink type that can hold different implementations
pub enum LogSink {
  Discard
  Funcr(FuncrSink)
  // We can add more implementations here
} derive(Eq)

///|
/// FuncrSink is a concrete implementation that formats logs and calls a function
/// Note: We can't derive Eq for this because function types don't implement Eq
pub struct FuncrSink {
  prefix : String
  values : Array[Value]
  enabled_level : Int
  options : FuncrOptions
}

///|
impl Eq for FuncrSink with op_equal(self, other) {
  self.prefix == other.prefix &&
  self.values == other.values &&
  self.enabled_level == other.enabled_level &&
  self.options == other.options
}

///|
/// Options for funcr formatting
pub struct FuncrOptions {
  log_caller : MessageClass
  log_timestamp : Bool
  timestamp_format : String
  verbosity : Int
} derive(Eq, Show, Default)

///|
impl Show for LogSink with output(self, logger) {
  match self {
    Discard => logger.write_string("DiscardSink")
    Funcr(sink) => {
      logger.write_string("FuncrSink{prefix=")
      logger.write_string(sink.prefix)
      logger.write_string("}")
    }
  }
}

///|
impl Show for FuncrSink with output(self, logger) {
  logger.write_string("FuncrSink{prefix=")
  logger.write_string(self.prefix)
  logger.write_string(", level=")
  logger.write_string(self.enabled_level.to_string())
  logger.write_string("}")
}

///| LogSink methods

///|
/// Initialize the LogSink with runtime info
pub fn LogSink::init(self : LogSink, info : RuntimeInfo) -> Unit {
  match self {
    Discard => ()
    Funcr(_) => () // FuncrSink doesn't need special initialization
  }
}

///|
/// Check if this LogSink is enabled at the specified V-level
pub fn LogSink::enabled(self : LogSink, level : Int) -> Bool {
  match self {
    Discard => false
    Funcr(sink) => level <= sink.options.verbosity
  }
}

///|
/// Log an info message
pub fn LogSink::info(
  self : LogSink,
  level : Int,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self {
    Discard => ()
    Funcr(sink) =>
      if level <= sink.options.verbosity {
        let formatted = format_info_message(sink, level, msg, keys_and_values)
        // For now, just print to stdout - in real implementation this would call write_fn
        println(sink.prefix + " " + formatted)
      }
  }
}

///|
/// Log an error message
pub fn LogSink::error(
  self : LogSink,
  err : String?,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self {
    Discard => ()
    Funcr(sink) => {
      let formatted = format_error_message(sink, err, msg, keys_and_values)
      // For now, just print to stdout - in real implementation this would call write_fn
      println(sink.prefix + " " + formatted)
    }
  }
}

///|
/// Return a new LogSink with additional key/value pairs
pub fn LogSink::with_values(
  self : LogSink,
  keys_and_values : Array[Value],
) -> LogSink {
  match self {
    Discard => Discard
    Funcr(sink) => {
      let new_values = []
      for v in sink.values {
        new_values.push(v)
      }
      for v in keys_and_values {
        new_values.push(v)
      }
      Funcr(FuncrSink::{
        prefix: sink.prefix,
        values: new_values,
        enabled_level: sink.enabled_level,
        options: sink.options,
      })
    }
  }
}

///|
/// Return a new LogSink with the specified name appended
pub fn LogSink::with_name(self : LogSink, name : String) -> LogSink {
  match self {
    Discard => Discard
    Funcr(sink) => {
      let new_prefix = if sink.prefix.length() > 0 {
        sink.prefix + "/" + name
      } else {
        name
      }
      Funcr(FuncrSink::{
        prefix: new_prefix,
        values: sink.values,
        enabled_level: sink.enabled_level,
        options: sink.options,
      })
    }
  }
}

///| Logger type

///|
/// Logger is a concrete type for performance reasons, but all the real work 
/// is passed on to a LogSink implementation.
pub struct Logger {
  sink : LogSink?
  level : Int
} derive(Eq)

///|
impl Show for Logger with output(self, logger) {
  logger.write_string("Logger{level=")
  logger.write_string(self.level.to_string())
  match self.sink {
    Some(sink) => {
      logger.write_string(", sink=")
      sink.output(logger)
    }
    None => logger.write_string(", sink=None")
  }
  logger.write_string("}")
}

///| Logger construction and basic operations

///|
/// new returns a new Logger instance. This is primarily used by libraries
/// implementing LogSink, rather than end users. Passing None will create
/// a Logger which discards all log lines.
pub fn new(sink : LogSink?) -> Logger {
  let logger = Logger::{ sink, level: 0 }
  match sink {
    Some(s) => s.init(RuntimeInfo::{ call_depth: 1 })
    None => ()
  }
  logger
}

///|
/// discard returns a Logger that discards all messages logged to it
pub fn discard() -> Logger {
  new(None)
}

///|
/// get_sink returns the stored sink
pub fn Logger::get_sink(self : Logger) -> LogSink? {
  self.sink
}

///|
/// with_sink returns a copy of the logger with the new sink
pub fn Logger::with_sink(self : Logger, sink : LogSink?) -> Logger {
  Logger::{ sink, level: self.level }
}

///| Logger methods

///|
/// enabled tests whether this Logger is enabled
pub fn Logger::enabled(self : Logger) -> Bool {
  match self.sink {
    Some(s) => s.enabled(self.level)
    None => false
  }
}

///|
/// info logs a non-error message with the given key/value pairs as context.
/// The msg argument should be used to add some constant description to the log line.
/// The key/value pairs can then be used to add additional variable information.
pub fn Logger::info(
  self : Logger,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self.sink {
    Some(s) =>
      if s.enabled(self.level) {
        s.info(self.level, msg, keys_and_values)
      }
    None => ()
  }
}

///|
/// error logs an error, with the given message and key/value pairs as context.
/// The log message will always be emitted, regardless of verbosity level.
/// The err parameter is optional and None may be passed instead of an error.
pub fn Logger::error(
  self : Logger,
  err : String?,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self.sink {
    Some(s) => s.error(err, msg, keys_and_values)
    None => ()
  }
}

///|
/// v returns a new Logger instance for a specific verbosity level, relative to
/// this Logger. In other words, V-levels are additive. A higher verbosity
/// level means a log message is less important. Negative V-levels are treated as 0.
pub fn Logger::v(self : Logger, level : Int) -> Logger {
  match self.sink {
    Some(_) => {
      let adjusted_level = if level < 0 { 0 } else { level }
      Logger::{ sink: self.sink, level: self.level + adjusted_level }
    }
    None => self
  }
}

///|
/// get_v returns the verbosity level of the logger
pub fn Logger::get_v(self : Logger) -> Int {
  self.level
}

///|
/// with_values returns a new Logger instance with additional key/value pairs
pub fn Logger::with_values(
  self : Logger,
  keys_and_values : Array[Value],
) -> Logger {
  match self.sink {
    Some(s) =>
      Logger::{ sink: Some(s.with_values(keys_and_values)), level: self.level }
    None => self
  }
}

///|
/// with_name returns a new Logger instance with the specified name element added
/// to the Logger's name. Successive calls with with_name append additional
/// suffixes to the Logger's name.
pub fn Logger::with_name(self : Logger, name : String) -> Logger {
  match self.sink {
    Some(s) => Logger::{ sink: Some(s.with_name(name)), level: self.level }
    None => self
  }
}

///|
/// is_zero returns true if this logger is an uninitialized zero value
pub fn Logger::is_zero(self : Logger) -> Bool {
  match self.sink {
    None => true
    Some(_) => false
  }
}

///| Funcr implementation

///|
/// new_funcr creates a new logger with funcr-style formatting
pub fn new_funcr(options : FuncrOptions) -> Logger {
  let sink = Funcr(FuncrSink::{
    prefix: "",
    values: [],
    enabled_level: 0,
    options,
  })
  new(Some(sink))
}

///|
/// Default funcr options
pub fn default_funcr_options() -> FuncrOptions {
  FuncrOptions::{
    log_caller: message_class_none,
    log_timestamp: false,
    timestamp_format: "2006-01-02 15:04:05.000000",
    verbosity: 0,
  }
}

///| Formatting helpers

///|
/// Format an info message for funcr
fn format_info_message(
  sink : FuncrSink,
  level : Int,
  msg : String,
  keys_and_values : Array[Value],
) -> String {
  let mut result = ""

  // Add level if > 0
  if level > 0 {
    result = result + "level=" + level.to_string() + " "
  }

  // Add message
  result = result + "msg=\"" + msg + "\""

  // Add pre-stored values
  if sink.values.length() > 0 {
    result = result + " " + format_kv_pairs(sink.values)
  }

  // Add current key-value pairs
  if keys_and_values.length() > 0 {
    result = result + " " + format_kv_pairs(keys_and_values)
  }
  result
}

///|
/// Format an error message for funcr  
fn format_error_message(
  sink : FuncrSink,
  err : String?,
  msg : String,
  keys_and_values : Array[Value],
) -> String {
  let mut result = ""

  // Add message
  result = result + "msg=\"" + msg + "\""

  // Add error if present
  match err {
    Some(e) => result = result + " error=\"" + e + "\""
    None => ()
  }

  // Add pre-stored values
  if sink.values.length() > 0 {
    result = result + " " + format_kv_pairs(sink.values)
  }

  // Add current key-value pairs
  if keys_and_values.length() > 0 {
    result = result + " " + format_kv_pairs(keys_and_values)
  }
  result
}

///| Key-Value pair utilities

///|
/// sanitize_kv ensures that a list of key-value pairs has a value for every key.
/// It expects alternating string keys and Value values.
pub fn sanitize_kv(kv_list : Array[Value]) -> Array[Value] {
  let result = []
  let mut i = 0
  while i < kv_list.length() {
    // Add the key (should be a string, but we'll accept any Value)
    result.push(kv_list[i])

    // Add the value, or a placeholder if missing
    if i + 1 < kv_list.length() {
      result.push(kv_list[i + 1])
    } else {
      result.push(VString("<no-value>"))
    }
    i += 2
  }
  result
}

///|
/// format_kv_pairs converts key-value pairs to a formatted string representation
pub fn format_kv_pairs(kv_pairs : Array[Value]) -> String {
  let mut result = ""
  let sanitized = sanitize_kv(kv_pairs)
  let mut i = 0
  while i + 1 < sanitized.length() {
    if i > 0 {
      result = result + " "
    }

    // Format as key=value
    let key_str = match sanitized[i] {
      VString(s) => s
      other => other.to_string()
    }
    result = result + key_str + "=" + sanitized[i + 1].to_string()
    i += 2
  }
  result
}

///| Convenience functions for creating Value from common types

///|
/// Helper function to create key-value pairs easily
pub fn kv(key : String, value : Value) -> Array[Value] {
  [VString(key), value]
}

///|
/// Helper to create multiple key-value pairs
pub fn kvs(pairs : Array[(String, Value)]) -> Array[Value] {
  let result = []
  for pair in pairs {
    let (key, value) = pair
    result.push(VString(key))
    result.push(value)
  }
  result
}

///| Marshaler trait for custom log formatting

///|
/// Marshaler is an optional trait that logged values may choose to implement.
/// Loggers with structured output should log the object returned by marshal_log
/// instead of the original value.
pub trait Marshaler {
  /// marshal_log can be used to ensure structs are logged appropriately
  marshal_log(Self) -> Value
}

///| Global constants for convenience

///|
/// Default message class constants
pub let message_class_none : MessageClass = MessageClass::None

///|
pub let message_class_all : MessageClass = MessageClass::All

///|
pub let message_class_info : MessageClass = MessageClass::Info

///|
pub let message_class_error : MessageClass = MessageClass::Error

///| Context support for storing and retrieving loggers

///|
/// Context holds key-value pairs and can carry a Logger
pub struct Context {
  values : Map[String, Value]
  logger : Logger?
} derive(Eq, Show)

///|
/// Create a new empty context
pub fn new_context() -> Context {
  Context::{ values: Map::new(), logger: None }
}

///|
/// Create a context with a logger
pub fn new_context_with_logger(logger : Logger) -> Context {
  Context::{ values: Map::new(), logger: Some(logger) }
}

///|
/// Add a value to the context
pub fn Context::with_value(
  self : Context,
  key : String,
  value : Value,
) -> Context {
  let new_values = Map::new()
  for k, v in self.values {
    new_values[k] = v
  }
  new_values[key] = value
  Context::{ values: new_values, logger: self.logger }
}

///|
/// Get a value from the context
pub fn Context::get_value(self : Context, key : String) -> Value? {
  self.values.get(key)
}

///|
/// Set a logger in the context
pub fn Context::with_logger(self : Context, logger : Logger) -> Context {
  Context::{ values: self.values, logger: Some(logger) }
}

///|
/// Get the logger from the context
pub fn Context::get_logger(self : Context) -> Logger? {
  self.logger
}

///|
/// Get the logger from context, or return a discard logger if none exists
pub fn Context::logger_or_discard(self : Context) -> Logger {
  match self.logger {
    Some(logger) => logger
    None => discard()
  }
}

///|
/// Add all context values as key-value pairs to a logger
pub fn Context::enrich_logger(self : Context, logger : Logger) -> Logger {
  let kv_pairs = []
  for key, value in self.values {
    kv_pairs.push(Value::from_string(key))
    kv_pairs.push(value)
  }
  logger.with_values(kv_pairs)
}

///| Context-aware logging functions

///|
/// Log an info message using the context's logger
pub fn Context::info(
  self : Context,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self.logger {
    Some(logger) => {
      let enriched_logger = self.enrich_logger(logger)
      enriched_logger.info(msg, keys_and_values)
    }
    None => () // No logger in context, do nothing
  }
}

///|
/// Log an error message using the context's logger
pub fn Context::error(
  self : Context,
  err : String?,
  msg : String,
  keys_and_values : Array[Value],
) -> Unit {
  match self.logger {
    Some(logger) => {
      let enriched_logger = self.enrich_logger(logger)
      enriched_logger.error(err, msg, keys_and_values)
    }
    None => () // No logger in context, do nothing
  }
}

///|
/// Create a child context with a modified logger (e.g., with additional values or name)
pub fn Context::with_logger_name(self : Context, name : String) -> Context {
  match self.logger {
    Some(logger) =>
      Context::{ values: self.values, logger: Some(logger.with_name(name)) }
    None => self
  }
}

///|
/// Create a child context with additional logger values
pub fn Context::with_logger_values(
  self : Context,
  keys_and_values : Array[Value],
) -> Context {
  match self.logger {
    Some(logger) =>
      Context::{
        values: self.values,
        logger: Some(logger.with_values(keys_and_values)),
      }
    None => self
  }
}

///|
/// Create a child context with a specific verbosity level
pub fn Context::with_logger_v(self : Context, level : Int) -> Context {
  match self.logger {
    Some(logger) =>
      Context::{ values: self.values, logger: Some(logger.v(level)) }
    None => self
  }
}

///| Public constructors for structs

///|
/// Create a new RuntimeInfo
pub fn make_runtime_info(call_depth : Int) -> RuntimeInfo {
  RuntimeInfo::{ call_depth, }
}

///|
/// Create a new FuncrOptions
pub fn make_funcr_options(
  log_caller : MessageClass,
  log_timestamp : Bool,
  timestamp_format : String,
  verbosity : Int,
) -> FuncrOptions {
  FuncrOptions::{ log_caller, log_timestamp, timestamp_format, verbosity }
}

///|
/// Create a new FuncrSink
pub fn make_funcr_sink(
  prefix : String,
  values : Array[Value],
  enabled_level : Int,
  options : FuncrOptions,
) -> FuncrSink {
  FuncrSink::{ prefix, values, enabled_level, options }
}

///|
/// Create a new Context
pub fn make_context(values : Map[String, Value], logger : Logger?) -> Context {
  Context::{ values, logger }
}

///|
/// Create a new LogSink::Discard
pub fn make_discard_sink() -> LogSink {
  LogSink::Discard
}

///|
/// Create a new LogSink::Funcr
pub fn make_funcr_sink_logsink(funcr_sink : FuncrSink) -> LogSink {
  LogSink::Funcr(funcr_sink)
}
