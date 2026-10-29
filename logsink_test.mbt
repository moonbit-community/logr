///|
/// LogSink enum tests
test "LogSink::Discard variant" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  inspect(sink.enabled(0), content="false")
  inspect(sink.enabled(1), content="false")
  inspect(sink.enabled(-1), content="false")
}

///|
test "LogSink::Funcr variant creation" {
  let funcr_sink : @logr_moonbit.FuncrSink = @logr_moonbit.make_funcr_sink(
    "test-prefix",
    [
      @logr_moonbit.Value::from_string("key"),
      @logr_moonbit.Value::from_string("value"),
    ],
    0,
    @logr_moonbit.default_funcr_options(),
  )
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    funcr_sink,
  )
  inspect(sink.enabled(0), content="true")
  inspect(sink.enabled(1), content="false")
}

///|
test "LogSink::init method" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  let runtime_info : @logr_moonbit.RuntimeInfo = @logr_moonbit.make_runtime_info(
    2,
  )

  // init should not crash
  sink.init(runtime_info)
}

///|
test "LogSink::enabled with different levels" {
  let opts : @logr_moonbit.FuncrOptions = @logr_moonbit.make_funcr_options(
    @logr_moonbit.message_class_none, false, "", 2,
  )
  let funcr_sink : @logr_moonbit.FuncrSink = @logr_moonbit.make_funcr_sink(
    "",
    [],
    0,
    opts,
  )
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    funcr_sink,
  )
  inspect(sink.enabled(0), content="true")
  inspect(sink.enabled(1), content="true")
  inspect(sink.enabled(2), content="true")
  inspect(sink.enabled(3), content="false")
  inspect(sink.enabled(-1), content="true")
}

///|
test "LogSink::info method" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()

  // Should not crash for discard sink
  sink.info(0, "test message", [])
  sink.info(1, "verbose message", [
    @logr_moonbit.Value::from_string("key"),
    @logr_moonbit.Value::from_string("value"),
  ])
}

///|
test "LogSink::error method" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()

  // Should not crash for discard sink
  sink.error(None, "test error", [])
  sink.error(Some("network error"), "connection failed", [
    @logr_moonbit.Value::from_string("host"),
    @logr_moonbit.Value::from_string("localhost"),
  ])
}

///|
test "LogSink::with_values for Discard" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  let new_sink : @logr_moonbit.LogSink = sink.with_values([
    @logr_moonbit.Value::from_string("key"),
    @logr_moonbit.Value::from_string("value"),
  ])

  // Discard should remain Discard
  match new_sink {
    @logr_moonbit.LogSink::Discard => () // Expected
    _ => abort("Expected Discard")
  }
}

///|
test "LogSink::with_values for Funcr" {
  let original_sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink(
      "test",
      [
        @logr_moonbit.Value::from_string("original"),
        @logr_moonbit.Value::from_string("value"),
      ],
      0,
      @logr_moonbit.default_funcr_options(),
    ),
  )
  let new_sink : @logr_moonbit.LogSink = original_sink.with_values([
    @logr_moonbit.Value::from_string("new"),
    @logr_moonbit.Value::from_string("value"),
  ])

  // Test that values are accumulated
  new_sink.info(0, "test with accumulated values", [])
}

///|
test "LogSink::with_name for Discard" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  let new_sink : @logr_moonbit.LogSink = sink.with_name("test-name")

  // Discard should remain Discard
  match new_sink {
    @logr_moonbit.LogSink::Discard => () // Expected
    _ => abort("Expected Discard")
  }
}

///|
test "LogSink::with_name for Funcr empty prefix" {
  let original_sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink(
      "",
      [],
      0,
      @logr_moonbit.default_funcr_options(),
    ),
  )
  let new_sink : @logr_moonbit.LogSink = original_sink.with_name("service")

  // Test logging with new name
  new_sink.info(0, "named logging", [])
}

///|
test "LogSink::with_name for Funcr existing prefix" {
  let original_sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink(
      "existing",
      [],
      0,
      @logr_moonbit.default_funcr_options(),
    ),
  )
  let new_sink : @logr_moonbit.LogSink = original_sink.with_name("service")

  // Should append with separator
  new_sink.info(0, "hierarchical naming", [])
}

///|
test "LogSink::with_name multiple names" {
  let sink : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink(
      "",
      [],
      0,
      @logr_moonbit.default_funcr_options(),
    ),
  )
  let final_sink : @logr_moonbit.LogSink = sink
    .with_name("api")
    .with_name("user")
    .with_name("auth")

  // Should show full hierarchy
  final_sink.info(0, "deeply nested logging", [])
}

///|
test "LogSink equality" {
  let sink1 : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  let sink2 : @logr_moonbit.LogSink = @logr_moonbit.make_discard_sink()
  inspect(sink1 == sink2, content="true")
}

///|
test "LogSink equality for Funcr" {
  let opts : @logr_moonbit.FuncrOptions = @logr_moonbit.default_funcr_options()
  let sink1 : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink("test", [], 0, opts),
  )
  let sink2 : @logr_moonbit.LogSink = @logr_moonbit.make_funcr_sink_logsink(
    @logr_moonbit.make_funcr_sink("test", [], 0, opts),
  )
  inspect(sink1 == sink2, content="true")
}
