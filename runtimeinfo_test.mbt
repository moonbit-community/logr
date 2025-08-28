///|
/// RuntimeInfo struct tests
test "RuntimeInfo creation" {
  let info : RuntimeInfo = make_runtime_info(5)
  inspect(info.call_depth, content="5")
}

///|
test "RuntimeInfo default creation" {
  let info : RuntimeInfo = RuntimeInfo::default()
  inspect(info.call_depth, content="0")
}

///|
test "RuntimeInfo equality" {
  let info1 : RuntimeInfo = make_runtime_info(3)
  let info2 : RuntimeInfo = make_runtime_info(3)
  let info3 : RuntimeInfo = make_runtime_info(4)
  inspect(info1 == info2, content="true")
  inspect(info1 == info3, content="false")
}

///|
test "RuntimeInfo Show implementation" {
  let info : RuntimeInfo = make_runtime_info(10)
  let output : String = info.to_string()
  inspect(output, content="{call_depth: 10}")
}

///|
test "RuntimeInfo zero call_depth" {
  let info : RuntimeInfo = make_runtime_info(0)
  inspect(info.call_depth, content="0")
}

///|
test "RuntimeInfo negative call_depth" {
  let info : RuntimeInfo = make_runtime_info(-2)
  inspect(info.call_depth, content="-2")
}
