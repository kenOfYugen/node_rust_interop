{wSpiEstRust} = require('bindings')('addon')

pi_est_rust_ws_addon = (samples) -> wSpiEstRust samples

module.exports = pi_est_rust_ws_addon
