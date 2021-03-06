// Generated by CoffeeScript 1.4.0
var bcodec;

document.ondrop = function() {
  return false;
};

document.ondragover = function() {
  return false;
};

bcodec = new Bcodec;

Zepto(function($) {
  var cycleMessages, idList, live, messages, pushMessage, shiftMessage, suspendedAnimation;
  live = new Date;
  messages = $('#messages');
  idList = [];
  suspendedAnimation = {};
  pushMessage = function(id, text) {
    idList.push(id);
    suspendedAnimation[id] = true;
    messages.append("<span id='" + id + "' class='message incoming'>" + text + "</span>");
    return $('#' + id).bind('webkitAnimationEnd', function(ev) {
      ev.stopPropagation();
      return shiftMessage(id);
    });
  };
  shiftMessage = function(id) {
    var message;
    if (suspendedAnimation[id]) {
      return delete suspendedAnimation[id];
    } else {
      message = $('#' + id);
      message.removeClass('incoming');
      message.addClass('outgoing');
      return setTimeout(function() {
        return message.remove();
      }, 1000);
    }
  };
  cycleMessages = function(newMessage) {
    shiftMessage(idList.shift());
    return pushMessage((Math.floor(Math.random() * 1000000)).toString(16), newMessage);
  };
  pushMessage('message1', 'DROP A TORRENT ON ME');
  document.getElementById('shield').ondrop = function(ev) {
    var fr, start;
    fr = new FileReader();
    start = 0;
    cycleMessages('THE BOMB HAS BEEN DROPPED');
    fr.onload = function(ev) {
      $('.start').remove();
      $('.filecell').remove();
      start = new Date();
      return document.title = 'Loading...';
    };
    fr.onloadend = function(ev) {
      var dummy, file, fileArray, filecell, filename, size, target, torrent, _i, _len;
      torrent = bcodec.bdecode(ev.target.result)[0];
      console.log("Torrent parsed in " + (new Date() - start) + "ms.");
      fileArray = !Backend.singular(torrent) ? Backend.directoryStructure(torrent.info.name, torrent.info.files) : [
        {
          name: torrent.info.name,
          size: Backend.humanize(torrent.info.length),
          id: Backend.classnameify(torrent.info.name),
          "class": '',
          depth: 0
        }
      ];
      console.log("Files organized in " + (new Date() - start) + "ms.");
      target = $("#container");
      dummy = document.createDocumentFragment();
      for (_i = 0, _len = fileArray.length; _i < _len; _i++) {
        file = fileArray[_i];
        filecell = document.createElement('div');
        filecell.className = 'filecell ' + file["class"];
        filecell.id = file.id;
        filecell.style.marginLeft = file.depth * 10 + 'px';
        size = document.createElement('div');
        size.className = 'size';
        size.innerHTML = file.size;
        filename = document.createElement('div');
        filename.className = 'filename';
        filename.innerHTML = file.name;
        filecell.appendChild(size);
        filecell.appendChild(filename);
        dummy.appendChild(filecell);
      }
      console.log("DocumentFragment accomplished in " + (new Date() - start) + "ms.");
      target.append(dummy);
      console.log("Rows jammed in in " + (new Date() - start) + "ms.");
      $('.filecell').on('click', function(ev) {
        var dir, subFiles;
        if (ev.srcElement.parentNode.id !== '') {
          dir = $('#' + ev.srcElement.parentNode.id);
          subFiles = $('.' + ev.srcElement.parentNode.id);
          if (dir.hasClass('file-tree-collapsed')) {
            dir.removeClass('file-tree-collapsed');
            subFiles.removeClass('file-tree-collapsed');
            subFiles.show();
          } else {
            dir.addClass('file-tree-collapsed');
            subFiles.hide();
          }
        }
        return false;
      });
      document.title = torrent.info.name;
      messages.addClass('gone');
      messages.bind('webkitAnimationEnd', function() {
        return messages.hide();
      });
      return $('#shield').hide();
    };
    fr.readAsBinaryString(ev.dataTransfer.files[0]);
    return false;
  };
  $('#body').on('dragenter', function(ev) {
    return $('#shield').show();
  });
  $('#shield').on('dragenter', function(ev) {
    return cycleMessages("DROP IT");
  });
  return $('#shield').on('dragleave', function(ev) {
    $('#shield').hide();
    return cycleMessages('DROP A TORRENT ON ME');
  });
});
