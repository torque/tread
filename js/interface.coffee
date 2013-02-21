# some flimflammery to stop chrome from loading the dropped document in the window
document.ondrop = () -> false
document.ondragover = () -> false

(TorrentDisplay = (viewer) ->
	viewer.torrent = {}

	document.getElementById('body').ondrop = (ev) ->
		console.log 'dropped'
		fr = new FileReader()
		start = 0
		fr.onload = (ev) ->
			start = new Date()
		fr.onloadend = (ev) ->
			torrent = bdecode(ev.target.result)[0]
			viewer.$apply () ->
				viewer.baseName = torrent.info.name
				viewer.torrent = torrent
			console.log viewer.torrent
			console.log "Parsed in #{new Date()-start}ms"
		fr.readAsBinaryString ev.dataTransfer.files[0]
		false

	$('#body').on 'dragenter', (ev) ->
		console.log 'Drag entered.'

	$('#body').on 'dragleave', (ev) ->
		console.log 'Drag left.'

	viewer.fileView = (file) ->
		filePath = viewer.baseName
		for path in file.path
			filePath += '/'+path
		"#{filePath}"

).$inject = ['$scope']