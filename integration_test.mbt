///|
/// Integration tests - testing all components working together
test "complete logging workflow with all features" {
  // Create custom options
  let opts : FuncrOptions = make_funcr_options(
    message_class_none, false, "2006-01-02 15:04:05", 2,
  )

  // Create base logger
  let base_logger : Logger = new_funcr(opts)

  // Create service logger with name and persistent values
  let service_logger : Logger = base_logger
    .with_name("payment-service")
    .with_values([
      Value::from_string("version"),
      Value::from_string("3.2.1"),
      Value::from_string("instance"),
      Value::from_string("web-prod-01"),
    ])

  // Test different verbosity levels
  service_logger.info("service initialized", [])
  service_logger
  .v(1)
  .info("configuration loaded", [
    Value::from_string("config_file"),
    Value::from_string("prod.yaml"),
  ])
  service_logger
  .v(2)
  .info("debug initialization", [
    Value::from_string("memory_mb"),
    Value::from_int(512),
  ])

  // Create request-specific logger
  let request_logger : Logger = service_logger.with_values([
    Value::from_string("request_id"),
    Value::from_string("pay-req-789"),
    Value::from_string("customer_id"),
    Value::from_int(12345),
  ])

  // Test info and error logging
  request_logger.info("processing payment", [
    Value::from_string("amount"),
    Value::from_double(99.95),
    Value::from_string("currency"),
    Value::from_string("USD"),
  ])
  request_logger.error(Some("insufficient funds"), "payment failed", [
    Value::from_string("balance"),
    Value::from_double(50.00),
    Value::from_string("retry_count"),
    Value::from_int(3),
  ])
}

///|
test "context and logger integration" {
  let logger : Logger = new_funcr(default_funcr_options())

  // Create context with logger and values
  let ctx : Context = new_context_with_logger(logger)
    .with_value("trace_id", Value::from_string("trace-integration-123"))
    .with_value("span_id", Value::from_string("span-456"))
    .with_value("operation", Value::from_string("user_management"))

  // Create child contexts with modified loggers
  let service_ctx : Context = ctx.with_logger_name("user-service")
  let component_ctx : Context = service_ctx.with_logger_values([
    Value::from_string("component"),
    Value::from_string("profile-handler"),
  ])
  let debug_ctx : Context = component_ctx.with_logger_v(1)

  // Test logging at each level
  ctx.info("root context logging", [])
  service_ctx.info("service context logging", [])
  component_ctx.info("component context logging", [])
  debug_ctx.info("debug context logging", [])

  // Test error logging through context
  debug_ctx.error(Some("validation error"), "profile update failed", [
    Value::from_string("field"),
    Value::from_string("email"),
    Value::from_string("user_id"),
    Value::from_int(67890),
  ])
}

///|
test "sink replacement and logger reuse" {
  // Create initial logger
  let logger1 : Logger = new_funcr(default_funcr_options())

  // Replace sink with None (discard)
  let logger2 : Logger = logger1.with_sink(None)

  // Create new sink
  let new_opts : FuncrOptions = make_funcr_options(
    message_class_all, true, "custom-time", 5,
  )
  let new_sink : LogSink = make_funcr_sink_logsink(
    make_funcr_sink(
      "replaced-sink",
      [Value::from_string("replaced"), Value::from_bool(true)],
      0,
      new_opts,
    ),
  )
  let logger3 : Logger = logger2.with_sink(Some(new_sink))

  // Test behavior with different sinks
  logger1.info("original logger", [])
  logger2.info("discard logger", []) // Should not appear
  logger3.info("replaced logger", [])
}

///|
test "high verbosity stress test" {
  let opts : FuncrOptions = make_funcr_options(
    message_class_none, false, "", 10,
  )
  let logger : Logger = new_funcr(opts)

  // Test multiple verbosity levels
  for level = 0; level <= 10; level = level + 1 {
    let v_logger : Logger = logger.v(level)
    let should_be_enabled : Bool = level <= 10
    let enabled_result : Bool = v_logger.enabled()
    if should_be_enabled {
      inspect(enabled_result, content="true")
      v_logger.info("level \{level} message", [
        Value::from_string("level"),
        Value::from_int(level),
      ])
    } else {
      inspect(enabled_result, content="false")
    }
  }
}

///|
test "context value isolation" {
  let logger : Logger = new_funcr(default_funcr_options())

  // Create parent context
  let parent_ctx : Context = new_context_with_logger(logger)
    .with_value("parent", Value::from_string("parent_value"))
    .with_value("shared", Value::from_string("parent_shared"))

  // Create child context
  let child_ctx : Context = parent_ctx
    .with_value("child", Value::from_string("child_value"))
    .with_value("shared", Value::from_string("child_shared"))

  // Test value isolation
  inspect(
    parent_ctx.get_value("parent"),
    content="Some(VString(\"parent_value\"))",
  )
  inspect(parent_ctx.get_value("child"), content="None")
  inspect(
    parent_ctx.get_value("shared"),
    content="Some(VString(\"parent_shared\"))",
  )
  inspect(
    child_ctx.get_value("parent"),
    content="Some(VString(\"parent_value\"))",
  )
  inspect(
    child_ctx.get_value("child"),
    content="Some(VString(\"child_value\"))",
  )
  inspect(
    child_ctx.get_value("shared"),
    content="Some(VString(\"child_shared\"))",
  )
}

///|
test "logger and context error handling edge cases" {
  // Test with empty strings
  let logger : Logger = new_funcr(default_funcr_options())
  logger.info("", [])
  logger.error(Some(""), "", [])
  logger.error(None, "", [])

  // Test with empty context
  let ctx : Context = new_context()
  ctx.info("", [])
  ctx.error(None, "", [])

  // Test with context but no logger
  let ctx_no_logger : Context = new_context().with_value(
    "key",
    Value::from_string("value"),
  )
  ctx_no_logger.info("ignored", [])
  ctx_no_logger.error(Some("ignored"), "ignored", [])
}
