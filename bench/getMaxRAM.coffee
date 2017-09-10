{exec} = require 'child_process'

getMaxRAM = (file, times, handler) ->
	getRAM = (file,  cb) ->
		exec "UV_THREADPOOL_SIZE=8 /usr/bin/time -v node #{file}", (err, stdout, stderr) ->
			#throw err if err
			lines = stderr.split '\n'
			maxMemMsg = lines[9]
			if maxMemMsg?	
				splitBySpace = maxMemMsg.split ' '
				maxMem = splitBySpace[splitBySpace.length - 1]				
				if isNaN Number maxMem then return getRAM file, cb
				cb Number maxMem
			else getRAM file, cb

	getRuns = (file, times) ->
		lazyRAM = (file) -> (cb) -> getRAM file, cb
		for time in [0...times]
			do (time) -> lazyRAM file

	runs = getRuns file, times

	do ->
		avg = 0
		min = 0
		max = 0

		run = runs.pop()
		recur = -> run (mem) ->
			if avg is 0
				avg = mem
				min = mem
				max = mem
			else
				avg += mem
				avg /= 2
		
				(min = mem) if mem < min
				(max = mem) if mem > max

			return handler {avg, min, max} if runs.length is 0 
			run = runs.pop()
			do recur
		do recur
		
module.exports = getMaxRAM
