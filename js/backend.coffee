Backend = { # I hear namespacing is popular nowadays (tl note: idk what the fuck im doing)

	singular: (torrent) ->
		!torrent.info.files
	,
	humanize: (num) ->
		post = [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB']
		dum = num
		count = 0
		while Math.floor dum # 0 == false
			dum /= 1024
			count++
		Math.round(num/(Math.pow(1024,(count-1)))*100)/100 + post[count-1] # allows things like 1023 KiB but I don't care.
	,
	organizeFiles: (torrent) ->
		# torrent.info.paths
		files = []
		unless Backend.singular torrent
			for file in torrent.info.files
				pathto = ""
				pathto += dir+'/' for dir in file.path
				files.push {
					name: file.path[file.path.length-1],
					path: pathto,
					size: Backend.humanize(file.length),
					rawsize: file.length
				}
		else
			files.push {
				name: torrent.info.name,
				path: "",
				size: Backend.humanize(torrent.info.length),
				rawsize: torrent.info.length
			}
		files
}