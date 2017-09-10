{PRNG} = require '../prng'

exports.piEstPureJS = (points) ->
  inside = 0
  randseed = 1

  generator = new PRNG randseed

  for i in [0...points]
    x = generator.nextFloat()
    y = generator.nextFloat()

    inside += 1 if (x * x) + (y * y) <= 1

  inside / points * 4

if process.env.NODE_ENV is 'test'
  assert = require 'assert'
  {piEstPureJS} = exports

  do piEstimation = ->
    pi = piEstPureJS 1e6
    assert 2.64 < pi < 3.64, "estimated pi value is more than 0.5 off"

if process.env.NODE_ENV is 'bench'
  Benchmark = require 'benchmark'

  suite = new Benchmark.Suite
  {piEstPureJS} = exports

  suite
    .add 'pi estimation',
      defer: false
      fn: -> piEstPureJS 1e6

    .on 'cycle', (e) ->
      console.log String e.target
    .on 'complete', -> console.log 'Fastest is ' + @filter('fastest').map('name')
    .on 'error', (e) -> throw e
    .run({async: false})
