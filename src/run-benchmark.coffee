{piEstRust, piEstRustAsync, wSpiEstRust, wSpiEstRustAsync} = require('bindings')('addon')
{piEstFFI} = require './piEstFFI'
{concurrentPiEstRustAsync} = require './concurrentPiEstRustAsync'
{piEstPureJS} = require './est_pi'

{writeFileSync} = require 'fs'
filename = "#{(new Date()).getTime()}.log"

bench = (samples, cb) ->

  results = {}

  Benchmark = require 'benchmark'

  suite = new Benchmark.Suite

  suite
  .add 'pi estimation ffi',
      defer: false
      fn: -> piEstFFI.pi_est samples

  .add 'pi estimation addon',
      defer: false
      fn: -> piEstRust samples

  .add 'pi estimation work stealing addon',
      defer: false
      fn: -> wSpiEstRust samples

  .add 'pi estimation async addon',
      defer: true
      fn: (deferred) ->
        piEstRustAsync samples, -> deferred.resolve()

  .add 'pi estimation concurrent async addon',
      defer: true
      fn: (deferred) ->
        concurrentPiEstRustAsync samples, -> deferred.resolve()

  .add 'pi estimation work stealing async addon',
      defer: true
      fn: (deferred) ->
        wSpiEstRustAsync samples, -> deferred.resolve()

  .add 'pi estimation pure JS',
      defer: false
      fn: -> piEstPureJS samples

  .on 'start', -> console.log "#{samples} samples:"
  .on 'cycle', (e) ->
      result = String e.target
      console.log """
        #{result}
      """
      name = result.split('x')[0]
      ops = result.split('x')[1].split(' ')[1]
      if !results.name?
        results[name] = ops
      else
        results.name += ops
        results.name /= 2

  .on 'complete', ->
    console.log '\n'
    cb {samples, results}
  .on 'error', (e) -> throw e
  .run({async: false})


acc = []

lazyBench = (samples) -> (cb) -> bench samples, cb

runs = for i in [3..9] by 0.5
  if i % 1 is 0
    lazyBench Math.pow 10, i
  else
    middle = (Math.pow 10, i + 0.5) / 2
    lazyBench Math.ceil Math.pow 10, Math.log10 middle 


run = runs.pop()
do recur = -> run (data) ->
  acc.push data
  run = runs.pop()
  if run? then do recur
  else
    str = JSON.stringify {data: acc}
    writeFileSync "./#{filename}", str, 'utf8'
    console.log 'Done'

