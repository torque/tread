# some flimflammery to stop chrome from loading the dropped document in the window
document.ondrop = () -> false
document.ondragover = () -> false

Zepto ($) -> # equivalent to $(document).ready
	document.getElementById('body').ondrop = (ev) ->
		fr = new FileReader()
		start = 0
		fr.onload = (ev) ->
			$('.start').remove() # clear out drop message.
			$('.filecell').remove() # clear out the old file list.
			start = new Date()
			document.title = 'Loading...'
		fr.onloadend = (ev) ->
			torrent = bdecode(ev.target.result)[0]
			files = Backend.organizeFiles torrent
			document.title = torrent.info.name
			console.log "Torrent parsed in #{new Date()-start}ms." # I am guessing this is not a reliable benchmark method.
			# console.log torrent
			for file in files # this is _significantly_ faster than dumping a huge chunk of html into the DOM.
				rendered = ich.filelist {files: file} 
				$("#drop").append rendered
		fr.readAsBinaryString ev.dataTransfer.files[0]
		false

	# $('#body').on 'dragenter', (ev) ->
	# 	console.log 'Drag entered.'

	# $('#body').on 'dragleave', (ev) ->
	# 	console.log 'Drag left.'