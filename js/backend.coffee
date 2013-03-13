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
	,
	onScreen: ->
		height = window.innerHeight - 20
		cellHeight = 70 #pixels
		Math.ceil(height/cellHeight)
	,
	classnameify: (str) ->
		escape(str).replace(/[ ]/g,'-').replace(/[^-_0-9a-z]/ig,'').replace(/^([^a-z])/i,'s-s$1')
	,
	directoryStructure: (baseDir, files) ->
		mess = {}
		mess[baseDir] = {}
		# mess[baseDir].subdirs = {}
		mess[baseDir].files = []
		classyBase = Backend.classnameify(baseDir)
		for file in files
			currentLevel = mess[baseDir]
			under = classyBase
			for i in [0..file.path.length-2] by 1
				dir = file.path[i]
				classyDir = Backend.classnameify dir
				unless currentLevel.subdirs?
					currentLevel.subdirs = {}
				unless currentLevel.subdirs[dir]?
					currentLevel.subdirs[dir] = {}
					currentLevel.subdirs[dir].files = []
					currentLevel.subdirs[dir].class = under
					currentLevel.subdirs[dir].id = classyDir
				under += ' ' + classyDir
				currentLevel = currentLevel.subdirs[dir]
			currentLevel.files.push {
				name: file.path[file.path.length-1],
				size: Backend.humanize(file.length),
				class: under
			}

		orderedFiles = [{name: baseDir, size: "FOLDER", depth: 0, class: '', id: classyBase}]
		depth = 1
		blargh = (folder) ->
			if folder.subdirs?
				for k in Object.keys(folder.subdirs).sort()
					dir = folder.subdirs[k]
					orderedFiles.push {
						name: k,
						size: "FOLDER",
						class: dir.class,
						depth: depth++,
						id: dir.id
					}
					blargh dir
					depth--
			for file in folder.files.sort((a,b) -> a.name.toLowerCase() > b.name.toLowerCase() )
				orderedFiles.push {
					name: file.name,
					size: file.size,
					class: file.class,
					depth: depth
				}
		blargh mess[baseDir]
		orderedFiles
}