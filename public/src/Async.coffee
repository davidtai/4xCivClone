@Async = 
	series: ()->
		funcs = Array.prototype.slice.call(arguments)
		funcs.reverse()
		lastFunc
		idx = 0
		for func in funcs
			if lastFunc?
				originalFunc = func
				do (originalFunc, lastFunc) ->
					func = ()->
						originalFunc()
						setTimeout(lastFunc, 1)
			lastFunc = func
			idx++
		func()
