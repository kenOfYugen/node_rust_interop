{exec} = require 'child_process'

getCPU = (file, times, cb) ->
	exec "UV_THREADPOOL_SIZE=8 perf stat -r #{times} -d node #{file}", (err, stdout, stderr) ->
		lines = stderr.split '\n'
		cpu = for line, index in lines when index is 3
			line.split('#')[1].split(' ')[4]

		cb cpu[0]

#getCPU 'rustAddonSync.js', 1, console.log

module.exports = getCPU
