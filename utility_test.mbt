///|
/// Utility functions tests
test "kv function" {
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.kv(
    "username",
    @logr_moonbit.Value::from_string("alice"),
  )
  inspect(result.length(), content="2")
  inspect(result[0], content="VString(\"username\")")
  inspect(result[1], content="VString(\"alice\")")
}

///|
test "kv function with different value types" {
  let string_kv : Array[@logr_moonbit.Value] = @logr_moonbit.kv(
    "name",
    @logr_moonbit.Value::from_string("bob"),
  )
  let int_kv : Array[@logr_moonbit.Value] = @logr_moonbit.kv(
    "age",
    @logr_moonbit.Value::from_int(25),
  )
  let bool_kv : Array[@logr_moonbit.Value] = @logr_moonbit.kv(
    "active",
    @logr_moonbit.Value::from_bool(true),
  )
  let double_kv : Array[@logr_moonbit.Value] = @logr_moonbit.kv(
    "score",
    @logr_moonbit.Value::from_double(95.5),
  )
  inspect(string_kv, content="[VString(\"name\"), VString(\"bob\")]")
  inspect(int_kv, content="[VString(\"age\"), VInt(25)]")
  inspect(bool_kv, content="[VString(\"active\"), VBool(true)]")
  inspect(double_kv, content="[VString(\"score\"), VDouble(95.5)]")
}

///|
test "kvs function empty array" {
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.kvs([])
  inspect(result.length(), content="0")
  inspect(result, content="[]")
}

///|
test "kvs function single pair" {
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.kvs([
    ("key", @logr_moonbit.Value::from_string("value")),
  ])
  inspect(result.length(), content="2")
  inspect(result[0], content="VString(\"key\")")
  inspect(result[1], content="VString(\"value\")")
}

///|
test "kvs function multiple pairs" {
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.kvs([
    ("name", @logr_moonbit.Value::from_string("charlie")),
    ("age", @logr_moonbit.Value::from_int(30)),
    ("verified", @logr_moonbit.Value::from_bool(false)),
  ])
  inspect(result.length(), content="6")
  inspect(result[0], content="VString(\"name\")")
  inspect(result[1], content="VString(\"charlie\")")
  inspect(result[2], content="VString(\"age\")")
  inspect(result[3], content="VInt(30)")
  inspect(result[4], content="VString(\"verified\")")
  inspect(result[5], content="VBool(false)")
}

///|
test "sanitize_kv even number of elements" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("key1"),
    @logr_moonbit.Value::from_string("value1"),
    @logr_moonbit.Value::from_string("key2"),
    @logr_moonbit.Value::from_int(42),
  ]
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.sanitize_kv(input)
  inspect(result.length(), content="4")
  inspect(
    result,
    content="[VString(\"key1\"), VString(\"value1\"), VString(\"key2\"), VInt(42)]",
  )
}

///|
test "sanitize_kv odd number of elements" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("key1"),
    @logr_moonbit.Value::from_string("value1"),
    @logr_moonbit.Value::from_string("key2"),
  ]
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.sanitize_kv(input)
  inspect(result.length(), content="4")
  inspect(result[2], content="VString(\"key2\")")
  inspect(result[3], content="VString(\"<no-value>\")")
}

///|
test "sanitize_kv empty array" {
  let input : Array[@logr_moonbit.Value] = []
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.sanitize_kv(input)
  inspect(result.length(), content="0")
  inspect(result, content="[]")
}

///|
test "sanitize_kv single element" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("lonely-key"),
  ]
  let result : Array[@logr_moonbit.Value] = @logr_moonbit.sanitize_kv(input)
  inspect(result.length(), content="2")
  inspect(result[0], content="VString(\"lonely-key\")")
  inspect(result[1], content="VString(\"<no-value>\")")
}

///|
test "format_kv_pairs empty array" {
  let result : String = @logr_moonbit.format_kv_pairs([])
  inspect(result, content="")
}

///|
test "format_kv_pairs single pair" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("service"),
    @logr_moonbit.Value::from_string("api"),
  ]
  let result : String = @logr_moonbit.format_kv_pairs(input)
  inspect(result, content="service=VString(\"api\")")
}

///|
test "format_kv_pairs multiple pairs" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("name"),
    @logr_moonbit.Value::from_string("test"),
    @logr_moonbit.Value::from_string("count"),
    @logr_moonbit.Value::from_int(5),
    @logr_moonbit.Value::from_string("enabled"),
    @logr_moonbit.Value::from_bool(true),
  ]
  let result : String = @logr_moonbit.format_kv_pairs(input)
  inspect(
    result,
    content="name=VString(\"test\") count=VInt(5) enabled=VBool(true)",
  )
}

///|
test "format_kv_pairs with non-string keys" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_int(123),
    @logr_moonbit.Value::from_string("numeric-key"),
    @logr_moonbit.Value::from_bool(true),
    @logr_moonbit.Value::from_string("boolean-key"),
  ]
  let result : String = @logr_moonbit.format_kv_pairs(input)
  inspect(
    result,
    content="VInt(123)=VString(\"numeric-key\") VBool(true)=VString(\"boolean-key\")",
  )
}

///|
test "format_kv_pairs handles odd elements via sanitize" {
  let input : Array[@logr_moonbit.Value] = [
    @logr_moonbit.Value::from_string("key1"),
    @logr_moonbit.Value::from_string("value1"),
    @logr_moonbit.Value::from_string("orphan-key"),
  ]
  let result : String = @logr_moonbit.format_kv_pairs(input)
  inspect(
    result,
    content="key1=VString(\"value1\") orphan-key=VString(\"<no-value>\")",
  )
}
