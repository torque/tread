// Generated by CoffeeScript 1.4.0
var Bcodec;

Bcodec = (function() {

  function Bcodec() {}

  Bcodec.prototype.bencode = function(obj) {
    var encdict, encint, enclist, encstr, out,
      _this = this;
    encstr = function(str) {
      return str.length + ':' + str;
    };
    encint = function(num) {
      return "i" + num + "e";
    };
    enclist = function(list) {
      var buf, i, _i, _len;
      buf = 'l';
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        i = list[_i];
        buf += _this.bencode(i);
      }
      return buf + 'e';
    };
    encdict = function(dict) {
      var buf, k, _i, _len, _ref;
      buf = 'd';
      _ref = Object.keys(dict).sort();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        buf += encstr(k) + _this.bencode(dict[k]);
      }
      return buf + 'e';
    };
    switch (typeof obj) {
      case 'string':
        out = encstr(obj);
        break;
      case 'number':
        out = encint(obj);
        break;
      case 'object':
        if (obj instanceof Array) {
          out = enclist(obj);
        } else if (obj != null) {
          out = encdict(obj);
        } else {
          throw new Error('This is an evil object.');
        }
        break;
      default:
        throw new Error('This is an evil ???.');
    }
    return out;
  };

  Bcodec.prototype.bdecode = function(str, start) {
    var caret, decdict, decint, declist, decstr, end, match,
      _this = this;
    caret = start || 0;
    match = str.slice(caret).match(/([ilde]|\d+?:)/);
    if (match == null) {
      return [null, caret];
    }
    if (match.index !== 0) {
      throw new Error('Non-kosher Match.');
    }
    caret += match[1].length;
    if (match[1].length > 1) {
      match[0] = 's';
      match[1] = parseInt(match[1], 10);
    }
    decstr = function(len) {
      var cutstr;
      caret += len;
      cutstr = str.slice(caret - len, caret);
      try {
        if (len < 512) {
          cutstr = decodeURIComponent(escape(cutstr));
        }
      } catch (_error) {}
      return [cutstr, caret];
    };
    decint = function() {
      match = str.slice(caret).match(/^(\d+?)e/);
      if (match == null) {
        throw new Error('Error: integer underflow.');
      }
      caret += match[0].length;
      return [parseInt(match[1], 10), caret];
    };
    declist = function() {
      var list, val, _ref;
      list = [];
      while (true) {
        _ref = _this.bdecode(str, caret), val = _ref[0], caret = _ref[1];
        if (val == null) {
          break;
        }
        list.push(val);
      }
      return [list, caret];
    };
    decdict = function() {
      var dict, key, _ref, _ref1;
      dict = {};
      while (true) {
        _ref = _this.bdecode(str, caret), key = _ref[0], caret = _ref[1];
        if (key == null) {
          break;
        }
        _ref1 = _this.bdecode(str, caret), dict[key] = _ref1[0], caret = _ref1[1];
      }
      return [dict, caret];
    };
    end = function() {
      return [null, caret];
    };
    switch (match[0]) {
      case 's':
        return decstr(match[1]);
      case 'i':
        return decint();
      case 'l':
        return declist();
      case 'd':
        return decdict();
      case 'e':
        return end();
    }
  };

  return Bcodec;

})();
