// Generated by CoffeeScript 1.4.0
var TorrentDisplay;

document.ondrop = function() {
  return false;
};

document.ondragover = function() {
  return false;
};

(TorrentDisplay = function(viewer) {
  viewer.torrent = null;
  document.getElementById('body').ondrop = function(ev) {
    var fr, start;
    console.log('dropped');
    fr = new FileReader();
    start = 0;
    fr.onload = function(ev) {
      start = new Date();
      return document.title = 'Loading...';
    };
    fr.onloadend = function(ev) {
      var parsed, torrent;
      torrent = bdecode(ev.target.result)[0];
      parsed = new Date();
      console.log("Torrent parsed in " + (parsed - start) + "ms.");
      viewer.$apply(function() {
        viewer.baseName = torrent.info.name;
        return viewer.torrent = torrent;
      });
      document.title = viewer.baseName;
      return console.log(viewer.torrent);
    };
    fr.readAsBinaryString(ev.dataTransfer.files[0]);
    return false;
  };
  $('#body').on('dragenter', function(ev) {
    return console.log('Drag entered.');
  });
  $('#body').on('dragleave', function(ev) {
    return console.log('Drag left.');
  });
  viewer.singular = function() {
    if (viewer.torrent) {
      return !viewer.torrent.info.files;
    }
    return null;
  };
  viewer.fileView = function(file) {
    var filePath;
    filePath = "";
    return file.path[file.path.length - 1];
  };
  return viewer.humanize = function(num) {
    var count, dum, post;
    post = [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB'];
    dum = num;
    count = 0;
    while (Math.floor(dum)) {
      dum /= 1024;
      count++;
    }
    return Math.round(num / (Math.pow(1024, count - 1)) * 100) / 100 + post[count - 1];
  };
}).$inject = ['$scope'];
