///|
// Preserve the display formats formerly emitted by derive(Show).
pub impl Show for RuntimeInfo with fn output(self, logger) {
  logger <+ "{call_depth: \{self.call_depth}}"
}

///|
pub impl Show for MessageClass with fn output(self, logger) {
  logger.write_string(
    match self {
      None => "None"
      All => "All"
      Info => "Info"
      Error => "Error"
    },
  )
}

///|
pub impl Show for FuncrOptions with fn output(self, logger) {
  logger <+
    "{log_caller: \{self.log_caller}, log_timestamp: \{self.log_timestamp}, timestamp_format: \{self.timestamp_format}, verbosity: \{self.verbosity}}"
}

///|
pub impl Show for Context with fn output(self, logger) {
  logger.write_string("{values: {")
  let mut first = true
  for key, value in self.values {
    if !first {
      logger.write_string(", ")
    }
    first = false
    logger.write_object(key)
    logger.write_string(": ")
    logger.write_object(value)
  }
  logger.write_string("}, logger: ")
  match self.logger {
    None => logger.write_string("None")
    Some(value) => {
      logger.write_string("Some(")
      Show::output(value, logger)
      logger.write_string(")")
    }
  }
  logger.write_string("}")
}
