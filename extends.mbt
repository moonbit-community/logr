///|
pub extend Context with Eq::{not_equal, equal}

///|
pub extend Context with Show::{to_string, output}

///|
pub extend FuncrOptions with Default::{default}

///|
pub extend FuncrOptions with Eq::{not_equal, equal}

///|
pub extend FuncrOptions with Show::{to_string, output}

///|
pub extend LogSink with Eq::{not_equal, equal}

///|
pub extend Logger with Eq::{not_equal, equal}

///|
pub extend MessageClass with Eq::{not_equal, equal}

///|
pub extend MessageClass with Show::{to_string, output}

///|
pub extend RuntimeInfo with Default::{default}

///|
pub extend RuntimeInfo with Eq::{not_equal, equal}

///|
pub extend RuntimeInfo with Show::{to_string, output}

///|
pub extend Value with Eq::{not_equal, equal}

///|
pub extend Value with Show::{to_string, output}

///|
pub extend Value with @debug.Debug::{to_repr}
