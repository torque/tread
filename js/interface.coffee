# some flimflammery to stop chrome from loading the dropped document in the window
document.ondrop = () -> false
document.ondragover = () -> false

(TorrentDisplay = (viewer) ->
	viewer.torrent = null

	document.getElementById('body').ondrop = (ev) ->
		console.log 'dropped'
		fr = new FileReader()
		start = 0
		fr.onload = (ev) ->
			start = new Date()
			document.title = 'Loading...'
		fr.onloadend = (ev) ->
			torrent = bdecode(ev.target.result)[0]
			parsed = new Date()
			console.log "Torrent parsed in #{parsed-start}ms."
			viewer.$apply () ->
				viewer.baseName = torrent.info.name
				viewer.torrent = torrent
			document.title = viewer.baseName
			console.log viewer.torrent
		fr.readAsBinaryString ev.dataTransfer.files[0]
		false

	$('#body').on 'dragenter', (ev) ->
		console.log 'Drag entered.'

	$('#body').on 'dragleave', (ev) ->
		console.log 'Drag left.'

	viewer.singular = () ->
		return !viewer.torrent.info.files if viewer.torrent # seems to be ok without an else
		null
		
	viewer.fileView = (file) ->
		filePath = ""
		# for path in file.path
		# 	filePath += path + '/'
		# filePath[0..-2] # maybe a better way to do this.
		file.path[file.path.length-1]

	viewer.humanize = (num) ->
		post = [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB']
		dum = num
		count = 0
		while Math.floor dum
			dum /= 1024
			count++
		Math.round(num/(Math.pow(1024,(count-1)))*100)/100 + post[count-1] # allow things like 1023 KiB but I don't care.

).$inject = ['$scope']