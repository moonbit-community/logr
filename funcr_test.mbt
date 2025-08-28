///|
/// FuncrOptions and FuncrSink tests
test "FuncrOptions default creation" {
  let opts : FuncrOptions = default_funcr_options()
  inspect(opts.log_timestamp, content="false")
  inspect(opts.verbosity, content="0")
  inspect(opts.timestamp_format, content="2006-01-02 15:04:05.000000")
}

///|
test "FuncrOptions custom creation" {
  let opts : FuncrOptions = make_funcr_options(
    message_class_all, true, "2006-01-02T15:04:05Z", 5,
  )
  inspect(opts.log_timestamp, content="true")
  inspect(opts.verbosity, content="5")
  inspect(opts.timestamp_format, content="2006-01-02T15:04:05Z")
}

///|
test "FuncrOptions equality" {
  let opts1 : FuncrOptions = default_funcr_options()
  let opts2 : FuncrOptions = default_funcr_options()
  let opts3 : FuncrOptions = make_funcr_options(
    message_class_none, true, "different", 1,
  )
  inspect(opts1 == opts2, content="true")
  inspect(opts1 == opts3, content="false")
}

///|
test "FuncrOptions Show implementation" {
  let opts : FuncrOptions = make_funcr_options(
    message_class_none, true, "custom", 3,
  )
  let output : String = opts.to_string()
  // Just verify it produces some output
  inspect(output.length() > 0, content="true")
}

///|
test "FuncrOptions Default implementation" {
  let opts : FuncrOptions = FuncrOptions::default()
  inspect(opts.log_timestamp, content="false")
  inspect(opts.verbosity, content="0")
}

///|
test "FuncrSink creation and access" {
  let sink : FuncrSink = make_funcr_sink(
    "test-service",
    [Value::from_string("env"), Value::from_string("prod")],
    1,
    default_funcr_options(),
  )
  inspect(sink.prefix, content="test-service")
  inspect(sink.enabled_level, content="1")
  inspect(sink.values.length(), content="2")
}

///|
test "new_funcr with default options" {
  let logger : Logger = new_funcr(default_funcr_options())
  inspect(logger.is_zero(), content="false")
  inspect(logger.enabled(), content="true")
  inspect(logger.get_v(), content="0")
}

///|
test "new_funcr with custom options" {
  let opts : FuncrOptions = make_funcr_options(
    message_class_info, true, "custom-format", 3,
  )
  let logger : Logger = new_funcr(opts)
  inspect(logger.enabled(), content="true")
  inspect(logger.v(3).enabled(), content="true")
  inspect(logger.v(4).enabled(), content="false")
}
