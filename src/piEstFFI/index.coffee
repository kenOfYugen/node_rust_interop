{Library} = require 'ffi'

exports.piEstFFI = Library "#{__dirname}/../../native/Rust/pi_est_c_wrapper/target/release/libpi_est_c_wrapper",
  pi_est: ['double', ['double']]

