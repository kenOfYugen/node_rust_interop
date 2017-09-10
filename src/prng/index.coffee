###
 * Creates a pseudo-random value generator. The seed must be an integer.
 *
 * Uses an optimized version of the Park-Miller PRNG.
 * http://www.firstpr.com.au/dsp/rand31/
###

exports.PRNG = (seed) ->
  @seed = seed % 2147483647
  if @seed <= 0 then @seed += 2147483646

  ###
   * Returns a pseudo-random value between 1 and 2^32 - 2.
  ###

  @next = -> @seed = @seed * 16807 % 2147483647

  ###
   * Returns a pseudo-random floating point number in range [0, 1).
  ###

  @nextFloat = ->
    # We know that result of next() will be 1 to 2147483646 (inclusive).
    (@next() - 1) / 2147483646 #* (max - min) + min

  return

if process.env.NODE_ENV is 'test'
  assert = require 'assert'
  {PRNG} = exports

  do integerGenerationTest = ->
    gen1 = new PRNG 1
    gen2 = new PRNG 1

    firstSet = (gen1.next() for i in [1..10])
    secondSet = (gen2.next() for i in [1..10])

    for int, index in firstSet
      assert.equal int, secondSet[index], "integer generation is not reproducible"

  do floatGenerationTest = ->
    gen1 = new PRNG 1
    gen2 = new PRNG 1

    firstSet = (gen1.nextFloat() for i in [1..10])
    secondSet = (gen2.nextFloat() for i in [1..10])

    for float, index in firstSet
      assert.equal float, secondSet[index], "float generation is not reproducible"

  do checkFloatsUniformity = ->
    gen = new PRNG 1
    simulations = 1e6
    ranges = (0 for i in [1..10])

    for simulation in [1..simulations]
      sample = gen.nextFloat()
      range = switch
        when 0.0 <= sample < 0.1 then ranges[0] += 1
        when 0.1 <= sample < 0.2 then ranges[1] += 1
        when 0.2 <= sample < 0.3 then ranges[2] += 1
        when 0.3 <= sample < 0.4 then ranges[3] += 1
        when 0.4 <= sample < 0.5 then ranges[4] += 1
        when 0.5 <= sample < 0.6 then ranges[5] += 1
        when 0.6 <= sample < 0.7 then ranges[6] += 1
        when 0.7 <= sample < 0.8 then ranges[7] += 1
        when 0.8 <= sample < 0.9 then ranges[8] += 1
        when 0.9 <= sample < 1.0 then ranges[9] += 1

    divergences = (~~(simulations / range*10) / 100 for range in ranges)

    assert divergence <= 1 for divergence in divergences

if process.env.NODE_ENV is 'bench'
  Benchmark = require 'benchmark'

  suite = new Benchmark.Suite
  {PRNG} = exports

  generator = undefined

  suite
    .add 'integer generation',
      defer: false
      fn: -> generator.next()

    .add 'float generation',
      defer: false
      fn: -> generator.nextFloat()

    .add 'Math.random()',
      defer: false
      fn: -> Math.random()

    .on 'start', -> generator = new PRNG 1
    .on 'cycle', (e) ->
      generator = new PRNG 1
      console.log String e.target
    .on 'complete', -> console.log 'Fastest is ' + @filter('fastest').map('name')
    .on 'error', (e) -> throw e
    .run({async: false})
