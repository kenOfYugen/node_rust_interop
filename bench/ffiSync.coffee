{piEstFFI} = require "#{__dirname}/../build/piEstFFI"

pi_est_rust_ffi = (samples) -> piEstFFI.pi_est samples

module.exports = pi_est_rust_ffi
