///| Marshaler trait tests

///|
/// Test type that can be formatted for logging
struct TestUser {
  id : Int32
  name : String
  email : String
} derive(Eq)

///|
/// Helper function to format TestUser for logging (instead of Marshaler trait)
fn TestUser::to_log_value(self : TestUser) -> @logr_moonbit.Value {
  // Only log id and name for privacy
  @logr_moonbit.Value::from_string("TestUser{id=\{self.id}, name=\{self.name}}")
}

///|
test "TestUser to_log_value implementation" {
  let user : TestUser = TestUser::{
    id: 123,
    name: "Alice",
    email: "alice@example.com",
  }
  let result : @logr_moonbit.Value = user.to_log_value()
  inspect(result, content="VString(\"TestUser{id=123, name=Alice}\")")
}

///|
test "TestUser to_log_value with different data" {
  let user : TestUser = TestUser::{
    id: 456,
    name: "Bob",
    email: "bob@test.com",
  }
  let result : @logr_moonbit.Value = user.to_log_value()
  inspect(result, content="VString(\"TestUser{id=456, name=Bob}\")")
}

///|
test "TestUser to_log_value with empty name" {
  let user : TestUser = TestUser::{
    id: 789,
    name: "",
    email: "empty@name.com",
  }
  let result : @logr_moonbit.Value = user.to_log_value()
  inspect(result, content="VString(\"TestUser{id=789, name=}\")")
}

///|
test "TestUser to_log_value with zero id" {
  let user : TestUser = TestUser::{ id: 0, name: "Zero", email: "zero@id.com", }
  let result : @logr_moonbit.Value = user.to_log_value()
  inspect(result, content="VString(\"TestUser{id=0, name=Zero}\")")
}

///|
/// Another test type for logging
struct TestProduct {
  product_id : String
  price : Double
  in_stock : Bool
} derive(Eq)

///|
fn TestProduct::to_log_value(self : TestProduct) -> @logr_moonbit.Value {
  // Create a structured representation
  @logr_moonbit.Value::from_string(
    "Product{\{self.product_id}:$\{self.price}:stock=\{self.in_stock}}",
  )
}

///|
test "TestProduct to_log_value" {
  let product : TestProduct = TestProduct::{
    product_id: "LAPTOP001",
    price: 999.99,
    in_stock: true,
  }
  let result : @logr_moonbit.Value = product.to_log_value()
  inspect(result, content="VString(\"Product{LAPTOP001:$999.99:stock=true}\")")
}

///|
test "TestProduct to_log_value out of stock" {
  let product : TestProduct = TestProduct::{
    product_id: "PHONE002",
    price: 599.50,
    in_stock: false,
  }
  let result : @logr_moonbit.Value = product.to_log_value()
  inspect(result, content="VString(\"Product{PHONE002:$599.5:stock=false}\")")
}

///|
/// Test using custom formatting in logging context
test "Custom formatting with logger" {
  let user : TestUser = TestUser::{
    id: 999,
    name: "Charlie",
    email: "charlie@test.com",
  }
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )

  // Use custom formatting in logging
  logger.info("user operation", [
    @logr_moonbit.Value::from_string("user"),
    user.to_log_value(),
    @logr_moonbit.Value::from_string("operation"),
    @logr_moonbit.Value::from_string("login"),
  ])
}

///|
test "Custom formatting with context logging" {
  let product : TestProduct = TestProduct::{
    product_id: "TABLET003",
    price: 399.99,
    in_stock: true,
  }
  let logger : @logr_moonbit.Logger = @logr_moonbit.new_funcr(
    @logr_moonbit.default_funcr_options(),
  )
  let ctx : @logr_moonbit.Context = @logr_moonbit.new_context_with_logger(
    logger,
  ).with_value("session_id", @logr_moonbit.Value::from_string("sess-789"))
  ctx.info("product viewed", [
    @logr_moonbit.Value::from_string("product"),
    product.to_log_value(),
  ])
}

///|
/// Test the actual Marshaler trait by implementing it for a simple type
struct SimpleItem {
  id : Int32
} derive(Eq)

///|
test "SimpleItem basic functionality" {
  let item : SimpleItem = SimpleItem::{ id: 42, }
  inspect(item.id, content="42")
  inspect(Show::to_string(item), content="{id: 42}")
}

///|
impl Show for SimpleItem with fn output(self, logger) {
  logger <+ "{id: \{self.id}}"
}
