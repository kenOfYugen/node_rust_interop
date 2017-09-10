{piEstRustAsync} = require('bindings')('addon')

pi_est_rust_async_addon = (samples, cb) -> piEstRustAsync samples, cb

module.exports = pi_est_rust_async_addon
