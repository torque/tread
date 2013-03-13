// Generated by CoffeeScript 1.4.0
var Backend;

Backend = {
  singular: function(torrent) {
    return !torrent.info.files;
  },
  humanize: function(num) {
    var count, dum, post;
    post = [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB'];
    dum = num;
    count = 0;
    while (Math.floor(dum)) {
      dum /= 1024;
      count++;
    }
    return Math.round(num / (Math.pow(1024, count - 1)) * 100) / 100 + post[count - 1];
  },
  organizeFiles: function(torrent) {
    var dir, file, files, pathto, _i, _j, _len, _len1, _ref, _ref1;
    files = [];
    if (!Backend.singular(torrent)) {
      _ref = torrent.info.files;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        pathto = "";
        _ref1 = file.path;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          dir = _ref1[_j];
          pathto += dir + '/';
        }
        files.push({
          name: file.path[file.path.length - 1],
          path: pathto,
          size: Backend.humanize(file.length),
          rawsize: file.length
        });
      }
    } else {
      files.push({
        name: torrent.info.name,
        path: "",
        size: Backend.humanize(torrent.info.length),
        rawsize: torrent.info.length
      });
    }
    return files;
  },
  onScreen: function() {
    var cellHeight, height;
    height = window.innerHeight - 20;
    cellHeight = 70;
    return Math.ceil(height / cellHeight);
  },
  classnameify: function(str) {
    return escape(str).replace(/[ ]/g, '-').replace(/[^-_0-9a-z]/ig, '').replace(/^([^a-z])/i, 's-s$1');
  },
  directoryStructure: function(baseDir, files) {
    var blargh, classyBase, classyDir, currentLevel, depth, dir, file, i, mess, orderedFiles, under, _i, _j, _len, _ref;
    mess = {};
    mess[baseDir] = {};
    mess[baseDir].files = [];
    classyBase = Backend.classnameify(baseDir);
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      currentLevel = mess[baseDir];
      under = classyBase;
      for (i = _j = 0, _ref = file.path.length - 2; _j <= _ref; i = _j += 1) {
        dir = file.path[i];
        classyDir = Backend.classnameify(dir);
        if (currentLevel.subdirs == null) {
          currentLevel.subdirs = {};
        }
        if (currentLevel.subdirs[dir] == null) {
          currentLevel.subdirs[dir] = {};
          currentLevel.subdirs[dir].files = [];
          currentLevel.subdirs[dir]["class"] = under;
          currentLevel.subdirs[dir].id = classyDir;
        }
        under += ' ' + classyDir;
        currentLevel = currentLevel.subdirs[dir];
      }
      currentLevel.files.push({
        name: file.path[file.path.length - 1],
        size: Backend.humanize(file.length),
        "class": under
      });
    }
    orderedFiles = [
      {
        name: baseDir,
        size: "FOLDER",
        depth: 0,
        "class": '',
        id: classyBase
      }
    ];
    depth = 1;
    blargh = function(folder) {
      var k, _k, _l, _len1, _len2, _ref1, _ref2, _results;
      if (folder.subdirs != null) {
        _ref1 = Object.keys(folder.subdirs).sort();
        for (_k = 0, _len1 = _ref1.length; _k < _len1; _k++) {
          k = _ref1[_k];
          dir = folder.subdirs[k];
          orderedFiles.push({
            name: k,
            size: "FOLDER",
            "class": dir["class"],
            depth: depth++,
            id: dir.id
          });
          blargh(dir);
          depth--;
        }
      }
      _ref2 = folder.files.sort(function(a, b) {
        return a.name.toLowerCase() > b.name.toLowerCase();
      });
      _results = [];
      for (_l = 0, _len2 = _ref2.length; _l < _len2; _l++) {
        file = _ref2[_l];
        _results.push(orderedFiles.push({
          name: file.name,
          size: file.size,
          "class": file["class"],
          depth: depth
        }));
      }
      return _results;
    };
    blargh(mess[baseDir]);
    return orderedFiles;
  }
};
