# some flimflammery to stop chrome from loading the dropped document in the window
document.ondrop = () -> false
document.ondragover = () -> false

Zepto ($) -> # equivalent to $(document).ready
	# console.log Backend.htmlTemplates()
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
			console.log "Torrent parsed in #{new Date()-start}ms." # I am guessing this is not a reliable benchmark method.
			# console.log torrent
			derp = Backend.directoryStructure torrent.info.name, torrent.info.files
			console.log "Files organized in #{new Date()-start}ms."
			# console.log derp
			target = $("#drop")
			number = Backend.onScreen()
			toAnimate = if number > files.length then files.length else number
			# (sleepLoop = (j) ->
			# 	i = toAnimate-j
			# 	file = files[i]
			# 	id = 'cell'+i
			# 	target.append "<div class='filecell onscreen' id='#{id}' style='opacity: 0'><div class='size'><span class='text'>#{file.size}</span></div><div class='filename'><span class='text'>#{file.name}</span></div></div>"
			# 	setTimeout(() ->
			# 		$('#'+id).css('opacity', '1.0')
			# 		if --j
			# 			sleepLoop(j) 
			# 		else
			# 			for i in [toAnimate...files.length]
			# 				file = files[i]
			# 				target.append "<div class='filecell offscreen'><div class='size'><span class='text'>#{file.size}</span></div><div class='filename'><span class='text'>#{file.name}</span></div></div>"
			# 	, 50)
			# )(toAnimate)
			for file in derp
				target.append "<div class='filecell #{file.class}' id='#{file.id}' style='margin-left:#{file.depth*10}px'><div class='size'>#{file.size}</div><div class='filename'>#{file.name}</div></div>"
			
			$('.filecell').on 'click', (ev) ->
				if ev.srcElement.parentNode.id isnt ''
					dir = $('#' + ev.srcElement.parentNode.id)
					subFiles = $('.' + ev.srcElement.parentNode.id)
					if dir.hasClass 'file-tree-collapsed'
						dir.removeClass 'file-tree-collapsed'
						subFiles.removeClass 'file-tree-collapsed'
						subFiles.show()
					else
						dir.addClass 'file-tree-collapsed'
						subFiles.hide()
				false
			document.title = torrent.info.name
				# console.log ev.target.id + ' has been clicked.'

		fr.readAsBinaryString ev.dataTransfer.files[0]
		false