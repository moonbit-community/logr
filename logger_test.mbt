///|
/// Logger type tests
test "Logger construction with discard" {
  let result : Logger = discard()
  inspect(result.is_zero(), content="true")
  inspect(result.enabled(), content="false")
  inspect(result.get_v(), content="0")
}

///|
test "Logger construction with new" {
  let result : Logger = new(None)
  inspect(result.is_zero(), content="true")
  inspect(result.enabled(), content="false")
}

///|
test "Logger construction with funcr" {
  let result : Logger = new_funcr(default_funcr_options())
  inspect(result.is_zero(), content="false")
  inspect(result.enabled(), content="true")
  inspect(result.get_v(), content="0")
}

///|
test "Logger::v method" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let v1_logger : Logger = base_logger.v(1)
  let v2_logger : Logger = base_logger.v(2)
  let v_neg_logger : Logger = base_logger.v(-5)
  inspect(base_logger.get_v(), content="0")
  inspect(v1_logger.get_v(), content="1")
  inspect(v2_logger.get_v(), content="2")
  inspect(v_neg_logger.get_v(), content="0")
}

///|
test "Logger::v additive behavior" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let v1_logger : Logger = base_logger.v(1)
  let v1_v2_logger : Logger = v1_logger.v(2)
  inspect(v1_v2_logger.get_v(), content="3")
}

///|
test "Logger::with_name single name" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let named_logger : Logger = base_logger.with_name("service")

  // Test that logging works with named logger
  named_logger.info("test message", [])
}

///|
test "Logger::with_name multiple names" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let named_logger : Logger = base_logger
    .with_name("api")
    .with_name("user")
    .with_name("auth")

  // Should show hierarchical naming in logs
  named_logger.info("hierarchical logging", [])
}

///|
test "Logger::with_values empty values" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let logger_with_empty : Logger = base_logger.with_values([])
  logger_with_empty.info("no extra values", [])
}

///|
test "Logger::with_values single pair" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let logger_with_values : Logger = base_logger.with_values([
    Value::from_string("service"),
    Value::from_string("user-api"),
  ])
  logger_with_values.info("with single value", [])
}

///|
test "Logger::with_values multiple pairs" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let logger_with_values : Logger = base_logger.with_values([
    Value::from_string("service"),
    Value::from_string("user-api"),
    Value::from_string("version"),
    Value::from_string("1.0"),
    Value::from_string("instance"),
    Value::from_int(42),
  ])
  logger_with_values.info("with multiple values", [])
}

///|
test "Logger::with_values accumulative" {
  let base_logger : Logger = new_funcr(default_funcr_options())
  let logger1 : Logger = base_logger.with_values([
    Value::from_string("key1"),
    Value::from_string("value1"),
  ])
  let logger2 : Logger = logger1.with_values([
    Value::from_string("key2"),
    Value::from_string("value2"),
  ])
  logger2.info("accumulated values", [])
}

///|
test "Logger::info with empty key-values" {
  let logger : Logger = new_funcr(default_funcr_options())
  logger.info("simple message", [])
}

///|
test "Logger::info with key-values" {
  let logger : Logger = new_funcr(default_funcr_options())
  logger.info("message with context", [
    Value::from_string("user_id"),
    Value::from_int(12345),
    Value::from_string("action"),
    Value::from_string("login"),
  ])
}

///|
test "Logger::error without error value" {
  let logger : Logger = new_funcr(default_funcr_options())
  logger.error(None, "something happened", [])
}

///|
test "Logger::error with error value" {
  let logger : Logger = new_funcr(default_funcr_options())
  logger.error(Some("connection refused"), "network error", [
    Value::from_string("host"),
    Value::from_string("localhost"),
    Value::from_string("port"),
    Value::from_int(8080),
  ])
}

///|
test "Logger::enabled with different verbosity levels" {
  let opts : FuncrOptions = make_funcr_options(message_class_none, false, "", 1)
  let logger : Logger = new_funcr(opts)
  inspect(logger.enabled(), content="true")
  inspect(logger.v(1).enabled(), content="true")
  inspect(logger.v(2).enabled(), content="false")
}

///|
test "Logger::get_sink for discard" {
  let logger : Logger = discard()
  let sink_result : LogSink? = logger.get_sink()
  match sink_result {
    None => () // Expected
    Some(_) => abort("Expected None")
  }
}

///|
test "Logger::get_sink for funcr" {
  let logger : Logger = new_funcr(default_funcr_options())
  let sink_result : LogSink? = logger.get_sink()
  match sink_result {
    Some(_) => () // Expected
    None => abort("Expected Some(LogSink)")
  }
}

///|
test "Logger::with_sink replacement" {
  let logger1 : Logger = new_funcr(default_funcr_options())
  let logger2 : Logger = logger1.with_sink(None)
  inspect(logger1.is_zero(), content="false")
  inspect(logger2.is_zero(), content="true")
}

///|
test "Logger chaining operations" {
  let result : Logger = new_funcr(default_funcr_options())
    .with_name("service")
    .with_values([Value::from_string("version"), Value::from_string("2.0")])
    .v(1)
  inspect(result.get_v(), content="1")
  inspect(result.is_zero(), content="false")
  inspect(result.enabled(), content="false")
}

///|
test "Logger equality" {
  let logger1 : Logger = discard()
  let logger2 : Logger = discard()
  let logger3 : Logger = new_funcr(default_funcr_options())
  inspect(logger1 == logger2, content="true")
  inspect(logger1 == logger3, content="false")
}
