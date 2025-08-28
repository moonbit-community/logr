///|
/// Value type tests
test "Value::from_string" {
  let result : Value = Value::from_string("hello world")
  inspect(result, content="VString(\"hello world\")")
}

///|
test "Value::from_int" {
  let result : Value = Value::from_int(42)
  inspect(result, content="VInt(42)")
}

///|
test "Value::from_bool true" {
  let result : Value = Value::from_bool(true)
  inspect(result, content="VBool(true)")
}

///|
test "Value::from_bool false" {
  let result : Value = Value::from_bool(false)
  inspect(result, content="VBool(false)")
}

///|
test "Value::from_double" {
  let result : Value = Value::from_double(3.14159)
  inspect(result, content="VDouble(3.14159)")
}

///|
test "Value::from_double zero" {
  let result : Value = Value::from_double(0.0)
  inspect(result, content="VDouble(0)")
}

///|
test "Value::from_double negative" {
  let result : Value = Value::from_double(-2.5)
  inspect(result, content="VDouble(-2.5)")
}

///|
test "Value equality for strings" {
  let val1 : Value = Value::from_string("test")
  let val2 : Value = Value::from_string("test")
  let val3 : Value = Value::from_string("different")
  inspect(val1 == val2, content="true")
  inspect(val1 == val3, content="false")
}

///|
test "Value equality for integers" {
  let val1 : Value = Value::from_int(100)
  let val2 : Value = Value::from_int(100)
  let val3 : Value = Value::from_int(200)
  inspect(val1 == val2, content="true")
  inspect(val1 == val3, content="false")
}

///|
test "Value equality for booleans" {
  let val1 : Value = Value::from_bool(true)
  let val2 : Value = Value::from_bool(true)
  let val3 : Value = Value::from_bool(false)
  inspect(val1 == val2, content="true")
  inspect(val1 == val3, content="false")
}

///|
test "Value equality for doubles" {
  let val1 : Value = Value::from_double(1.5)
  let val2 : Value = Value::from_double(1.5)
  let val3 : Value = Value::from_double(2.5)
  inspect(val1 == val2, content="true")
  inspect(val1 == val3, content="false")
}

///|
test "Value equality mixed types" {
  let string_val : Value = Value::from_string("42")
  let int_val : Value = Value::from_int(42)
  let bool_val : Value = Value::from_bool(true)
  inspect(string_val == int_val, content="false")
  inspect(string_val == bool_val, content="false")
  inspect(int_val == bool_val, content="false")
}

///|
test "Value Show implementation for strings" {
  let val : Value = Value::from_string("hello")
  inspect(val.to_string(), content="VString(\"hello\")")
}

///|
test "Value Show implementation for integers" {
  let val : Value = Value::from_int(-123)
  inspect(val.to_string(), content="VInt(-123)")
}

///|
test "Value Show implementation for booleans" {
  let val_true : Value = Value::from_bool(true)
  let val_false : Value = Value::from_bool(false)
  inspect(val_true.to_string(), content="VBool(true)")
  inspect(val_false.to_string(), content="VBool(false)")
}

///|
test "Value Show implementation for doubles" {
  let val : Value = Value::from_double(42.0)
  inspect(val.to_string(), content="VDouble(42)")
}

///|
test "Value with empty string" {
  let result : Value = Value::from_string("")
  inspect(result, content="VString(\"\")")
}

///|
test "Value with special characters in string" {
  let result : Value = Value::from_string("hello\nworld\ttab")
  inspect(result, content="VString(\"hello\\nworld\\ttab\")")
}

///|
test "Value with unicode string" {
  let result : Value = Value::from_string("你好世界")
  inspect(result, content="VString(\"你好世界\")")
}

///|
test "Value with zero integer" {
  let result : Value = Value::from_int(0)
  inspect(result, content="VInt(0)")
}

///|
test "Value with negative integer" {
  let result : Value = Value::from_int(-999)
  inspect(result, content="VInt(-999)")
}

///|
test "Value with large integer" {
  let result : Value = Value::from_int(2147483647)
  inspect(result, content="VInt(2147483647)")
}
