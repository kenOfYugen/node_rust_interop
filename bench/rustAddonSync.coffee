{piEstRust} = require('bindings')('addon')

rust_addon_sync = (samples) -> piEstRust samples

module.exports = rust_addon_sync
