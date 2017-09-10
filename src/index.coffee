{piEstRust, piEstRustAsync, wSpiEstRust, wSpiEstRustAsync} = require('bindings')('addon')
{piEstFFI} = require './piEstFFI'
{concurrentPiEstRustAsync} = require './concurrentPiEstRustAsync'
{piEstPureJS} = require './est_pi'

module.exports = {
  piEstFFI
  piEstRust
  piEstRustAsync
  concurrentPiEstRustAsync
}

if process.env.NODE_ENV is 'test'
  assert = require 'assert'

  do piEstimationFFI = ->
    pi = piEstFFI.pi_est 1e6
    assert 2.64 < pi < 3.64, "estimated pi value is more than 0.5 off"

if process.env.NODE_ENV is 'bench'
  Benchmark = require 'benchmark'

  suite = new Benchmark.Suite

  suite
    .add 'pi estimation ffi',
      defer: false
      fn: -> piEstFFI.pi_est 1e6

    .add 'pi estimation addon',
      defer: false
      fn: -> piEstRust 1e6

    .add 'pi estimation work stealing addon',
      defer: false
      fn: -> wSpiEstRust 1e6

    .add 'pi estimation async addon',
      defer: true
      fn: (deferred) ->
        piEstRustAsync 1e6, -> deferred.resolve()

    .add 'pi estimation concurrent async addon',
      defer: true
      fn: (deferred) ->
        concurrentPiEstRustAsync 1e6, -> deferred.resolve()

    .add 'pi estimation work stealing async addon',
      defer: true
      fn: (deferred) ->
        wSpiEstRustAsync 1e6, -> deferred.resolve()

    .add 'pi estimation pure JS',
      defer: false
      fn: -> piEstPureJS 1e6

    .on 'cycle', (e) -> console.log String e.target
    .on 'complete', -> console.log 'Fastest is ' + @filter('fastest').map('name')
    .on 'error', (e) -> throw e
    .run({async: false})
