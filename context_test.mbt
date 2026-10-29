///|
/// Context type tests
test "Context creation with new_context" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
  match ctx.get_logger() {
    None => () // Expected
    Some(_) => abort("Expected None")
  }
  inspect(ctx.get_value("nonexistent"), content="None")
}

///|
test "Context creation with new_context_with_logger" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  )
  match ctx.get_logger() {
    Some(_) => () // Expected
    None => abort("Expected logger to be present")
  }
}

///|
test "Context::with_value single value" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
  let new_ctx : @logr_moonbit.Context = ctx.with_value(
    "service",
    @logr_moonbit.Value::from_string("user-api"),
  )
  inspect(new_ctx.get_value("service"), content="Some(VString(\"user-api\"))")
  inspect(new_ctx.get_value("missing"), content="None")
}

///|
test "Context::with_value multiple values" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
    .with_value("service", @logr_moonbit.Value::from_string("user-api"))
    .with_value("version", @logr_moonbit.Value::from_string("1.0"))
    .with_value("instance", @logr_moonbit.Value::from_int(42))
  inspect(ctx.get_value("service"), content="Some(VString(\"user-api\"))")
  inspect(ctx.get_value("version"), content="Some(VString(\"1.0\"))")
  inspect(ctx.get_value("instance"), content="Some(VInt(42))")
}

///|
test "Context::with_value overwrite" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
    .with_value("key", @logr_moonbit.Value::from_string("original"))
    .with_value("key", @logr_moonbit.Value::from_string("updated"))
  inspect(ctx.get_value("key"), content="Some(VString(\"updated\"))")
}

///|
test "Context::with_logger" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let new_ctx : @logr_moonbit.Context = ctx.with_logger(logger)
  match new_ctx.get_logger() {
    Some(_) => () // Expected
    None => abort("Expected logger to be present")
  }
}

///|
test "Context::logger_or_discard with logger" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  )
  let result : @logr_moonbit.Logger = ctx.logger_or_discard()
  inspect(result.is_zero(), content="false")
}

///|
test "Context::logger_or_discard without logger" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
  let result : @logr_moonbit.Logger = ctx.logger_or_discard()
  inspect(result.is_zero(), content="true")
}

///|
test "Context::enrich_logger empty context" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let enriched : @logr_moonbit.Logger = ctx.enrich_logger(logger)

  // Should work without additional values
  enriched.info("enriched with empty context", [])
}

///|
test "Context::enrich_logger with values" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()
    .with_value("request_id", @logr_moonbit.Value::from_string("req-123"))
    .with_value("user_id", @logr_moonbit.Value::from_int(456))
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let enriched : @logr_moonbit.Logger = ctx.enrich_logger(logger)

  // Should include context values in logs
  enriched.info("enriched logging", [
    @logr_moonbit.Value::from_string("action"),
    @logr_moonbit.Value::from_string("test"),
  ])
}

///|
test "Context::info with logger" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  ).with_value("trace_id", @logr_moonbit.Value::from_string("trace-abc"))
  ctx.info("context logging", [
    @logr_moonbit.Value::from_string("operation"),
    @logr_moonbit.Value::from_string("create"),
  ])
}

///|
test "Context::info without logger" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context().with_value(
    "some_key",
    @logr_moonbit.Value::from_string("some_value"),
  )

  // Should not crash
  ctx.info("should be ignored", [])
}

///|
test "Context::error with logger" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  ).with_value("request_id", @logr_moonbit.Value::from_string("req-456"))
  ctx.error(Some("validation error"), "invalid input", [
    @logr_moonbit.Value::from_string("field"),
    @logr_moonbit.Value::from_string("email"),
  ])
}

///|
test "Context::error without logger" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context()

  // Should not crash
  ctx.error(None, "should be ignored", [])
}

///|
test "Context::with_logger_name" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  )
  let new_ctx : @logr_moonbit.Context = ctx.with_logger_name("service-name")
  let result_logger : @logr_moonbit.Logger = new_ctx.logger_or_discard()
  result_logger.info("named context logging", [])
}

///|
test "Context::with_logger_values" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  )
  let new_ctx : @logr_moonbit.Context = ctx.with_logger_values([
    @logr_moonbit.Value::from_string("component"),
    @logr_moonbit.Value::from_string("auth"),
  ])
  let result_logger : @logr_moonbit.Logger = new_ctx.logger_or_discard()
  result_logger.info("logger with additional values", [])
}

///|
test "Context::with_logger_v" {
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  )
  let new_ctx : @logr_moonbit.Context = ctx.with_logger_v(2)
  let result_logger : @logr_moonbit.Logger = new_ctx.logger_or_discard()
  inspect(result_logger.get_v(), content="2")
}

///|
test "Context equality" {
  let ctx1 : @logr_moonbit.Context = @logr_moonbit.new_context()
  let ctx2 : @logr_moonbit.Context = @logr_moonbit.new_context()
  let ctx3 : @logr_moonbit.Context = @logr_moonbit.new_context().with_value(
    "key",
    @logr_moonbit.Value::from_string("value"),
  )
  inspect(ctx1 == ctx2, content="true")
  inspect(ctx1 == ctx3, content="false")
}

///|
test "Context Show implementation" {
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context().with_value(
    "service",
    @logr_moonbit.Value::from_string("api"),
  )
  let output : String = ctx.to_string()
  inspect(output.length() > 0, content="true")
}
