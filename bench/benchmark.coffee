getCPU = require './getCPU'
getMaxRAM = require './getMaxRAM'

{readFileSync, writeFileSync} = require 'fs'

filename = "#{(new Date()).getTime()}.log"

modules = [
	'pureJSSync.js'
	'rustAddonSync.js'
	'ffiSync.js'
	'piEstRustAsync.js'
	'wsPiEstRustSync.js'
	'baselineSync.js'
	'wSpiEstRustAsync.js'
	'concurrentPiEstRustAsync.js'
]

generateTempFile = (module, samples) -> 
	base = readFileSync module, 'utf8'
	[lines..., exports] = base.split('module.exports = ')
	[fnName, _...] = exports.split '\;'
			
	tempCode = base + '\n' + "#{fnName}(#{samples})\;"
	writeFileSync 'temp.js', tempCode, 'utf8'

generateTempFileAsync = (module, samples) ->
	base = readFileSync module, 'utf8'
	[lines..., exports] = base.split('module.exports = ')
	[fnName, _...] = exports.split '\;'

	tempCode = base + '\n' + "#{fnName}(#{samples}, function() {})\;"
	writeFileSync 'temp.js', tempCode, 'utf8'

times = 10
samples = 1e9

currentSample = 1

results = []

do work = ->
	(writeFileSync filename, (JSON.stringify {result: results}), 'utf8') if modules.length is 0
	module = modules.pop()
	if module?
		if module.split('Sync').length is 2
			currentSample = 1
			console.log "measuring #{module}"
			do recur = ->
				currentSample *= 10
				console.log "at #{currentSample}"
				
				generateTempFile module, currentSample
				
				getMaxRAM 'temp.js', times, (kbytes) ->
					getCPU 'temp.js', times, (cpu) ->
						results.push {module, kbytes, cpu, currentSample, times}
						if currentSample is samples then return do work
						else do recur
			
		if module.split('Async').length is 2
			currentSample = 1
			console.log "measuring #{module}"
			do recur = ->
				currentSample *= 10
				console.log "at #{currentSample}"

				generateTempFileAsync module, currentSample
				
				getMaxRAM 'temp.js', times, (kbytes) ->
					getCPU 'temp.js', times, (cpu) ->
						results.push {module, kbytes, cpu, currentSample, times}
						if currentSample is samples then return do work
						else do recur
