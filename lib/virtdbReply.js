var FieldData, VirtDBReply, lz4,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FieldData = require("virtdb-connector").FieldData;

lz4 = require("lz4");

VirtDBReply = (function() {
  var compress;

  VirtDBReply.prototype.data = null;

  VirtDBReply.prototype.maxChunkSize = null;

  VirtDBReply.prototype.queryId = null;

  VirtDBReply.prototype.compType = 'LZ4_COMPRESSION';

  VirtDBReply.prototype.seqNo = 0;

  function VirtDBReply(query) {
    this.send = __bind(this.send, this);
    this.pushObject = __bind(this.pushObject, this);
    var column, field, _i, _len, _ref;
    this.data = [];
    this.maxChunkSize = query.MaxChunkSize || 25000;
    this.queryId = query.QueryId;
    this.seqNo = 0;
    _ref = query.Fields;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      field = _ref[_i];
      column = {
        QueryId: query.QueryId,
        Name: field.Name,
        Data: FieldData.createInstance(field.Name, field.Desc.Type)
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
      _results.push(item.Data.push(row[item.Name]));
    }
    return _results;
  };

  compress = function(data) {
    var compSize, input, output;
    input = new Buffer(data);
    output = new Buffer(lz4.encodeBound(input.length));
    compSize = lz4.encodeBlock(input, output);
    output = output.slice(0, compSize);
    return [output, compSize];
  };

  VirtDBReply.prototype.send = function(sendFn, endOfData) {
    var column, data, index, sendColumn, uncompressedData, _i, _len, _ref, _ref1, _ref2;
    if (endOfData == null) {
      endOfData = true;
    }
    _ref = this.data;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      index = 0;
      while (column.Data.getArray().length > 0) {
        uncompressedData = column.Data.getArray().splice(0, this.maxChunkSize);
        sendColumn = {
          QueryId: this.queryId,
          Name: column.Name,
          SeqNo: this.seqNo + index,
          Data: [],
          EndOfData: false,
          CompType: 'LZ4_COMPRESSION'
        };
        _ref1 = compress(uncompressedData), sendColumn.CompressedData = _ref1[0], sendColumn.UncompressedSize = _ref1[1];
        sendFn(sendColumn);
        index += 1;
      }
      if (endOfData) {
        uncompressedData = [];
        sendColumn = {
          QueryId: this.queryId,
          Name: column.Name,
          SeqNo: this.seqNo + index,
          Data: [],
          EndOfData: true,
          CompType: 'LZ4_COMPRESSION'
        };
        _ref2 = compress(uncompressedData), sendColumn.CompressedData = _ref2[0], sendColumn.UncompressedSize = _ref2[1];
        sendFn(sendColumn);
        index += 1;
      }
    }
    this.seqNo = this.seqNo + index + 1;
    return data = [];
  };

  return VirtDBReply;

})();

module.exports = VirtDBReply;

//# sourceMappingURL=virtdbReply.js.map