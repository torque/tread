bencode = (obj) ->
	encstr = (str) -> str.length + ':' + str
	encint = (num) -> "i#{num}e"
	enclist = (list) ->
		buf = 'l'
		buf += bencode i for i in list
		buf + 'e'
	encdict = (dict) ->
		buf = 'd'
		buf += encstr(k) + bencode(dict[k]) for k in Object.keys(dict).sort()
		buf + 'e'

	switch typeof obj
		when 'string' then out = encstr obj
		when 'number' then out = encint obj
		when 'object'
			if obj instanceof Array
				out = enclist obj
			else if obj?
				out = encdict obj
			else
				throw new Error('This is an evil object.')
		else
			throw new Error('This is an evil ???.')
	return out

charWidth = (str) ->
    /%u/.test escape str 

bdecode = (str, start) ->
	caret = start || 0 # state?
	match = str[caret..-1].match(/([ilde]|\d+?:)/) # regular expression solve all problem
	return [null, caret] unless match? # because otherwise it asploads
	if match.index != 0
		console.log str[1..caret]
		console.log 'Caret is at '+caret
		throw new Error('Non-kosher Match.') 
	caret += match[1].length
	if match[1].length > 1 # trim colon
		match[0] = 's' # cheating and confusion
		match[1] = parseInt match[1], 10 # cutting corners

	decstr = (len) ->
		# console.log 'strlen: '+len
		caret += len
		cutstr = str[caret-len...caret]
		cutstr = decodeURIComponent escape cutstr if cutstr.length < 256
		[cutstr, caret] # gotta love implicit coffee-script returns (or hate. or any other emotion).
	decint = () ->
		# we leave pure regular expression decoding as an exercise for the reader.
		match = str[caret..-1].match(/^(\d+?)e/)
		throw new Error('Error: integer underflow.') unless match?
		caret += match[0].length
		[parseInt(match[1], 10), caret]
	declist = () ->
		list = []
		loop # for(;;)
			[val, caret] = bdecode str, caret
			break unless val?
			list.push val
		[list, caret]
	decdict = () ->
		dict = {}
		loop # round and round the loop goes, when it will end nobody knows.
			[key, caret] = bdecode str, caret
			break unless key?
			[dict[key], caret] = bdecode str, caret
		[dict, caret]
	end = () ->
		return [null, caret]

	switch match[0] # I keep hearing that switch is just glorified if chains in js
		when 's' then return decstr match[1]
		when 'i' then return decint()
		when 'l' then return declist()
		when 'd' then return decdict()
		when 'e' then return end()