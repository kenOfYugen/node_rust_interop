{concurrentPiEstRustAsync} = require '../build/concurrentPiEstRustAsync'

concurrent_pi_est_async_rust_addon = (samples, cb) -> concurrentPiEstRustAsync samples, cb

module.exports = concurrent_pi_est_async_rust_addon
