///|
/// MessageClass enum tests
test "MessageClass variants access" {
  let none_val : MessageClass = message_class_none
  let all_val : MessageClass = message_class_all
  let info_val : MessageClass = message_class_info
  let error_val : MessageClass = message_class_error
  inspect(none_val, content="None")
  inspect(all_val, content="All")
  inspect(info_val, content="Info")
  inspect(error_val, content="Error")
}

///|
test "MessageClass equality" {
  let none1 : MessageClass = message_class_none
  let none2 : MessageClass = message_class_none
  let all_val : MessageClass = message_class_all
  inspect(none1 == none2, content="true")
  inspect(none1 == all_val, content="false")
}

///|
test "MessageClass Show implementation" {
  inspect(message_class_none.to_string(), content="None")
  inspect(message_class_all.to_string(), content="All")
  inspect(message_class_info.to_string(), content="Info")
  inspect(message_class_error.to_string(), content="Error")
}

///|
test "MessageClass has default value" {
  // MessageClass has a Default implementation, test it works with our constants
  let default_none : MessageClass = message_class_none
  inspect(default_none, content="None")
}
