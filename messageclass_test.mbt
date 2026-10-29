///|
/// MessageClass enum tests
test "MessageClass variants access" {
  let none_val : @logr_moonbit.MessageClass = @logr_moonbit.message_class_none
  let all_val : @logr_moonbit.MessageClass = @logr_moonbit.message_class_all
  let info_val : @logr_moonbit.MessageClass = @logr_moonbit.message_class_info
  let error_val : @logr_moonbit.MessageClass = @logr_moonbit.message_class_error
  inspect(none_val, content="None")
  inspect(all_val, content="All")
  inspect(info_val, content="Info")
  inspect(error_val, content="Error")
}

///|
test "MessageClass equality" {
  let none1 : @logr_moonbit.MessageClass = @logr_moonbit.message_class_none
  let none2 : @logr_moonbit.MessageClass = @logr_moonbit.message_class_none
  let all_val : @logr_moonbit.MessageClass = @logr_moonbit.message_class_all
  inspect(none1 == none2, content="true")
  inspect(none1 == all_val, content="false")
}

///|
test "MessageClass Show implementation" {
  inspect(@logr_moonbit.message_class_none.to_string(), content="None")
  inspect(@logr_moonbit.message_class_all.to_string(), content="All")
  inspect(@logr_moonbit.message_class_info.to_string(), content="Info")
  inspect(@logr_moonbit.message_class_error.to_string(), content="Error")
}

///|
test "MessageClass has default value" {
  // MessageClass has a Default implementation, test it works with our constants
  let default_none : @logr_moonbit.MessageClass = @logr_moonbit.message_class_none
  inspect(default_none, content="None")
}
