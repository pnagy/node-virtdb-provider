var FieldData, VirtDBReply,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FieldData = require("virtdb-connector").FieldData;

VirtDBReply = (function() {
  VirtDBReply.prototype.data = null;

  function VirtDBReply(query) {
    this.pushObject = __bind(this.pushObject, this);
    var column, field, _i, _len, _ref;
    this.data = [];
    _ref = query.Fields;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      field = _ref[_i];
      column = {
        QueryId: query.QueryId,
        Name: field.Name,
        SeqNo: 0,
        Data: FieldData.createInstance(field.Name, field.Desc.Type),
        EndOfData: true,
        CompType: 'NO_COMPRESSION'
      };
      this.data.push(column);
    }
  }

  VirtDBReply.prototype.pushObject = function(row) {
    var item, _i, _len, _ref, _results;
    _ref = this.data;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (row[item.Name] != null) {
        _results.push(item.Data.push(row[item.Name]));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return VirtDBReply;

})();

module.exports = VirtDBReply;

//# sourceMappingURL=virtdbReply.js.map