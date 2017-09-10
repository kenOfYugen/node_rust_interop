{wSpiEstRustAsync} = require('bindings')('addon')

ws_pi_est_rust_async = (samples, cb) -> wSpiEstRustAsync samples, cb

module.exports = ws_pi_est_rust_async
