# MoonBit logr

A minimal structured logging API for MoonBit, inspired by the Go [logr](https://github.com/go-logr/logr) library.

## Overview

logr offers a structured logging API that allows MoonBit programs and libraries to do logging without becoming coupled to a particular logging implementation. This package provides the API interface, while the actual logging implementation is handled by "sinks".

The `Logger` type is intended for application and library authors. It provides a relatively small API which can be used everywhere you want to emit logs.

The `LogSink` enum is intended for logging library implementers. It provides different implementations of the actual logging functionality.

## Key Features

- **Structured Logging**: Uses key-value pairs instead of printf-style format strings
- **Verbosity Levels**: Support for different verbosity levels (V-levels)
- **Logger Names**: Hierarchical logger naming for better organization
- **Context Support**: Store and enrich loggers with contextual information
- **Discard Logger**: Zero-cost logger that discards all messages
- **Funcr Implementation**: Built-in formatted text output implementation

## Basic Usage

### Creating a Logger

```moonbit
test "basic logger creation" {
  // Create a discard logger (for testing or when logging is disabled)
  let discard_logger = discard()
  
  // Create a funcr logger with default options
  let logger = new_funcr(default_funcr_options())
  
  // Create a funcr logger with custom options
  let custom_opts = FuncrOptions::{
    log_caller: message_class_none,
    log_timestamp: true,
    timestamp_format: "2006-01-02 15:04:05",
    verbosity: 2
  }
  let custom_logger = new_funcr(custom_opts)
}
```

### Structured Logging

```moonbit
test "structured logging example" {
  let logger = new_funcr(default_funcr_options())
  
  // Info logging with key-value pairs
  logger.info("user login successful", [
    Value::from_string("user_id"), Value::from_int(12345),
    Value::from_string("ip_address"), Value::from_string("192.168.1.100"),
    Value::from_string("login_method"), Value::from_string("oauth")
  ])
  
  // Error logging
  logger.error(
    Some("database connection timeout"), 
    "failed to authenticate user", 
    [
      Value::from_string("user_id"), Value::from_int(12345),
      Value::from_string("timeout_ms"), Value::from_int(5000)
    ]
  )
}
```

### Verbosity Levels

Verbosity levels allow you to control how much detail your logs contain. Higher V-levels mean more verbose (and less important) logs.

```moonbit
test "verbosity levels example" {
  let opts = FuncrOptions::{
    log_caller: message_class_none,
    log_timestamp: false,
    timestamp_format: "",
    verbosity: 2  // Enable V-levels 0, 1, and 2
  }
  let logger = new_funcr(opts)
  
  // These will be logged (V-level <= 2)
  logger.info("Important message", [])  // V-level 0 (default)
  logger.v(1).info("Less important message", [])  // V-level 1
  logger.v(2).info("Debug information", [])  // V-level 2
  
  // This will be filtered out (V-level > 2)
  logger.v(3).info("Very verbose debug info", [])  // V-level 3
}
```

### Logger Names

Logger names help organize logs hierarchically, making it easier to filter and understand log sources.

```moonbit
test "logger names example" {
  let base_logger = new_funcr(default_funcr_options())
  
  // Create service-specific loggers
  let user_service_logger = base_logger.with_name("user-service")
  let auth_logger = user_service_logger.with_name("auth")
  let db_logger = user_service_logger.with_name("database")
  
  user_service_logger.info("service starting", [])
  auth_logger.info("user authenticated", [Value::from_string("user_id"), Value::from_int(123)])
  db_logger.info("connection established", [Value::from_string("host"), Value::from_string("localhost")])
}
```

### Persistent Values

You can attach key-value pairs to a logger that will be included in all subsequent log messages.

```moonbit
test "persistent values example" {
  let base_logger = new_funcr(default_funcr_options())
  
  // Create a logger with persistent values
  let request_logger = base_logger.with_values([
    Value::from_string("request_id"), Value::from_string("req-12345"),
    Value::from_string("user_id"), Value::from_int(67890),
    Value::from_string("trace_id"), Value::from_string("trace-abcdef")
  ])
  
  // All logs from this logger will include the persistent values
  request_logger.info("processing request", [Value::from_string("action"), Value::from_string("create_user")])
  request_logger.info("request completed", [Value::from_string("duration_ms"), Value::from_int(150)])
}
```

### Chaining Operations

Logger operations can be chained together for convenience:

```moonbit
test "chaining operations example" {
  let logger = new_funcr(default_funcr_options())
    .with_name("api-gateway")
    .with_values([
      Value::from_string("version"), Value::from_string("1.2.3"),
      Value::from_string("instance"), Value::from_string("web-01")
    ])
    .v(1)  // Set verbosity level
  
  logger.info("gateway started", [Value::from_string("port"), Value::from_int(8080)])
}
```

## Context Support

The library provides context support for storing loggers and enriching them with contextual information.

### Basic Context Usage

```moonbit
test "context basic usage" {
  let logger = new_funcr(default_funcr_options())
  
  // Create a context with a logger
  let ctx = new_context_with_logger(logger)
    .with_value("service", Value::from_string("user-api"))
    .with_value("version", Value::from_string("2.1.0"))
    .with_value("request_id", Value::from_string("req-789"))
  
  // Log using the context (includes context values automatically)
  ctx.info("processing user request", [
    Value::from_string("action"), Value::from_string("get_profile")
  ])
  
  ctx.error(Some("user not found"), "failed to retrieve profile", [
    Value::from_string("user_id"), Value::from_int(404)
  ])
}
```

### Context Logger Modifications

```moonbit
test "context logger modifications" {
  let base_logger = new_funcr(default_funcr_options())
  let ctx = new_context_with_logger(base_logger)
  
  // Create child contexts with modified loggers
  let service_ctx = ctx.with_logger_name("payment-service")
  let component_ctx = service_ctx.with_logger_values([
    Value::from_string("component"), Value::from_string("stripe-integration")
  ])
  let debug_ctx = component_ctx.with_logger_v(2)
  
  debug_ctx.info("processing payment", [
    Value::from_string("amount"), Value::from_int(2999),
    Value::from_string("currency"), Value::from_string("USD")
  ])
}
```

## Value Types

The library uses the `Value` enum to represent all loggable values in a type-safe manner:

```moonbit
test "value types example" {
  // Create different types of values
  let string_val = Value::from_string("hello world")
  let int_val = Value::from_int(42)
  let bool_val = Value::from_bool(true)
  let double_val = Value::from_double(3.14159)
  
  let logger = new_funcr(default_funcr_options())
  logger.info("demonstrating value types", [
    Value::from_string("string_example"), string_val,
    Value::from_string("int_example"), int_val,
    Value::from_string("bool_example"), bool_val,
    Value::from_string("double_example"), double_val
  ])
}
```

## Helper Functions

### Key-Value Helpers

```moonbit
test "helper functions example" {
  // Create a single key-value pair
  let single_kv = kv("user_name", Value::from_string("alice"))
  
  // Create multiple key-value pairs
  let multiple_kvs = kvs([
    ("user_id", Value::from_int(123)),
    ("is_active", Value::from_bool(true)),
    ("last_login", Value::from_string("2024-01-15T10:30:00Z"))
  ])
  
  let logger = new_funcr(default_funcr_options())
  logger.info("user information", single_kv)
  logger.info("user details", multiple_kvs)
}
```

### Custom Value Formatting

For custom types, you can create helper functions to format them for logging:

```moonbit
struct User {
  id: Int
  name: String
  email: String
}

fn User::to_log_value(self : User) -> Value {
  // Only log id and name, not email for privacy
  Value::from_string("User{id=\{self.id}, name=\{self.name}}")
}

test "custom formatting example" {
  let user = User::{ id: 123, name: "Alice", email: "alice@example.com" }
  let logger = new_funcr(default_funcr_options())
  
  // Use the custom formatting function
  logger.info("user action", [
    Value::from_string("user"), user.to_log_value(),
    Value::from_string("action"), Value::from_string("login")
  ])
}
```

## Best Practices

### 1. Use Structured Logging

Prefer key-value pairs over concatenated strings:

```moonbit
test "structured logging best practice" {
  let logger = new_funcr(default_funcr_options())
  
  // Good
  logger.info("user login failed", [
    Value::from_string("user_id"), Value::from_int(123),
    Value::from_string("reason"), Value::from_string("invalid_password"),
    Value::from_string("attempt_count"), Value::from_int(3)
  ])

  // Avoid - harder to parse and query
  logger.info("User 123 login failed: invalid_password (attempt 3)", [])
}
```

### 2. Use Consistent Key Names

Establish conventions for key names across your application:

```moonbit
test "consistent key names" {
  let logger = new_funcr(default_funcr_options())
  
  // Use consistent keys like "user_id", "request_id", "duration_ms"
  logger.info("operation completed", [
    Value::from_string("user_id"), Value::from_int(123),
    Value::from_string("request_id"), Value::from_string("req-456"),
    Value::from_string("duration_ms"), Value::from_int(250)
  ])
}
```

### 3. Use Appropriate Verbosity Levels

- V(0): Important operational information
- V(1): General debugging information
- V(2): Detailed debugging information
- V(3): Very verbose trace information

### 4. Use Logger Names for Organization

Create hierarchical logger names that reflect your application structure:

```moonbit
test "logger name organization" {
  let base_logger = new_funcr(default_funcr_options())
  let app_logger = base_logger.with_name("myapp")
  let service_logger = app_logger.with_name("user-service")
  let component_logger = service_logger.with_name("authentication")
  
  component_logger.info("component initialized", [])
}
```

### 5. Use Context for Request-Scoped Information

Store request-scoped information in contexts rather than passing it through every function:

```moonbit
test "context for request scope" {
  let base_ctx = new_context()
  let request_ctx = base_ctx
    .with_value("request_id", Value::from_string("req-789"))
    .with_value("user_id", Value::from_int(123))
    .with_value("trace_id", Value::from_string("trace-abc"))
  
  // Context can be passed through your call chain
  // process_user_request(request_ctx, user_data)
}
```

## Performance Considerations

- The discard logger has zero cost - it's safe to leave debug loggers in production code
- Verbosity level checks are performed before any log formatting
- String concatenation and formatting only occurs when logs will actually be emitted
- Context enrichment is lazy - values are only processed when logging occurs

## Extending the Library

To implement a custom LogSink, you would add a new variant to the `LogSink` enum and implement the required methods. For example:

```moonbit
// Example of how you could extend LogSink
// (Note: This would require modifying the library source)

// struct CustomSink {
//   // Your custom sink fields
// }

// Add variant to LogSink enum:
// CustomSink(CustomSink)

// Then implement the required methods in the LogSink module functions
```

This pattern allows for type-safe extension while maintaining the performance benefits of enum dispatch.