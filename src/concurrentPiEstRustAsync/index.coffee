{piEstRust, piEstRustAsync} = require('bindings')('addon')

exports.concurrentPiEstRustAsync = (points, cb) ->
  batches = 16
  ended = 0
  total = 0

  for i in [1..batches]
    piEstRustAsync (points / batches), (err, pi) ->
      ended += 1
      total += pi
      if ended is batches then cb null, total / ended

  return
