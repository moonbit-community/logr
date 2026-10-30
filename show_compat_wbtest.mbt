///|
test "public display formats remain compatible" {
  inspect(
    make_runtime_info(2),
    content=(
      #|{call_depth: 2}
    ),
  )
  inspect(
    message_class_none,
    content=(
      #|None
    ),
  )
  inspect(
    message_class_all,
    content=(
      #|All
    ),
  )
  inspect(
    message_class_info,
    content=(
      #|Info
    ),
  )
  inspect(
    message_class_error,
    content=(
      #|Error
    ),
  )
  inspect(
    make_funcr_options(message_class_all, true, "q\n\"", 3),
    content=(
      #|{log_caller: All, log_timestamp: true, timestamp_format: q
      #|", verbosity: 3}
    ),
  )
  inspect(
    new_context(),
    content=(
      #|{values: {}, logger: None}
    ),
  )
  inspect(
    new_context_with_logger(discard()).with_value(
      "key",
      Value::from_string("text"),
    ),
    content=(
      #|{values: {key: VString("text")}, logger: Some(Logger{level=0, sink=None})}
    ),
  )
}
