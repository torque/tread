# some flimflammery to stop chrome from loading the dropped document in the window
document.ondrop = () -> false
document.ondragover = () -> false
bcodec = new Bcodec

Zepto ($) -> # equivalent to $(document).ready
	live = new Date
	messages = $('#messages')
	idList = []
	suspendedAnimation = {}

	pushMessage = (id, text) ->
		idList.push id
		suspendedAnimation[id] = true
		messages.append "<span id='#{id}' class='message incoming'>#{text}</span>"
		$('#' + id).bind 'webkitAnimationEnd', (ev) ->
			ev.stopPropagation()
			shiftMessage(id)

	shiftMessage = (id) ->
		if suspendedAnimation[id]
			delete suspendedAnimation[id]
		else
			message = $('#' + id)
			message.removeClass 'incoming'
			message.addClass 'outgoing'
			setTimeout () ->
				message.remove()
			, 1000

	cycleMessages = (newMessage) ->
		shiftMessage idList.shift()
		pushMessage (Math.floor Math.random()*1000000).toString(16), newMessage

	pushMessage 'message1', 'DROP A TORRENT ON ME'

	document.getElementById('shield').ondrop = (ev) ->
		fr = new FileReader()
		start = 0
		cycleMessages 'THE BOMB HAS BEEN DROPPED'
		fr.onload = (ev) ->
			$('.start').remove() # clear out drop message.
			$('.filecell').remove() # clear out the old file list.
			start = new Date()
			document.title = 'Loading...'
		fr.onloadend = (ev) ->
			torrent = bcodec.bdecode(ev.target.result)[0]
			console.log "Torrent parsed in #{new Date()-start}ms." # I am guessing this is not a reliable benchmark method.
			# console.log torrent
			fileArray = unless Backend.singular(torrent) then Backend.directoryStructure torrent.info.name, torrent.info.files else [{
				name: torrent.info.name
				size: Backend.humanize torrent.info.length
				id: Backend.classnameify torrent.info.name
				class: ''
				depth: 0
			}]
			console.log "Files organized in #{new Date()-start}ms."
			# console.log fileArray
			target = $("#container")
			number = Backend.onScreen()

			for file in fileArray
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
			messages.addClass 'gone'
			messages.bind 'webkitAnimationEnd', () ->
				messages.hide()
			$('#shield').hide()
				# console.log ev.target.id + ' has been clicked.'

		fr.readAsBinaryString ev.dataTransfer.files[0]
		false

	$('#body').on 'dragenter', (ev) ->
		$('#shield').show()

	$('#shield').on 'dragenter', (ev) ->
		cycleMessages "DROP IT"

	$('#shield').on 'dragleave', (ev) ->
		$('#shield').hide()
		cycleMessages 'DROP A TORRENT ON ME'