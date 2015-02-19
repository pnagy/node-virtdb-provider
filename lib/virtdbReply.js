var CommonProto, FieldData, VirtDBReply, lz4,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FieldData = require("virtdb-connector").FieldData;

lz4 = require("lz4");

CommonProto = (require("virtdb-proto")).common;

VirtDBReply = (function() {
  var compress;

  VirtDBReply.prototype.data = null;

  VirtDBReply.prototype.maxChunkSize = null;

  VirtDBReply.prototype.queryId = null;

  VirtDBReply.prototype.compType = 'LZ4_COMPRESSION';

  VirtDBReply.prototype.seqNo = 0;

  function VirtDBReply(query) {
    this.send = bind(this.send, this);
    this.pushObject = bind(this.pushObject, this);
    var column, field, i, len, ref;
    this.data = [];
    this.maxChunkSize = query.MaxChunkSize || 25000;
    this.queryId = query.QueryId;
    this.seqNo = 0;
    ref = query.Fields;
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      column = {
        QueryId: query.QueryId,
        Name: field.Name,
        Data: FieldData.createInstance(field.Name, field.Desc.Type)
      };
      this.data.push(column);
    }
  }

  VirtDBReply.prototype.pushObject = function(row) {
    var i, item, len, ref, results;
    ref = this.data;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      results.push(item.Data.push(row[item.Name]));
    }
    return results;
  };

  compress = function(data) {
    var compSize, input, output, testData;
    input = CommonProto.serialize(data, "virtdb.interface.pb.ValueType");
    testData = CommonProto.parse(input, "virtdb.interface.pb.ValueType");
    output = new Buffer(lz4.encodeBound(input.length));
    compSize = lz4.encodeBlock(input, output);
    output = output.slice(0, compSize);
    return [output, input.length];
  };

  VirtDBReply.prototype.send = function(sendFn, endOfData) {
    var column, data, i, index, len, ref, ref1, sendColumn, uncompressedData;
    if (endOfData == null) {
      endOfData = true;
    }
    ref = this.data;
    for (i = 0, len = ref.length; i < len; i++) {
      column = ref[i];
      index = 0;
      while (column.Data.getArray().length > 0) {
        uncompressedData = FieldData.createInstance(column.Name, column.Data.Type);
        uncompressedData.pushArray(column.Data.getArray().splice(0, this.maxChunkSize));
        sendColumn = {
          QueryId: this.queryId,
          Name: column.Name,
          SeqNo: this.seqNo + index,
          Data: {
            Name: column.Name,
            Type: column.Data.Type
          },
          EndOfData: column.Data.getArray().length === 0,
          CompType: 'LZ4_COMPRESSION'
        };
        ref1 = compress(uncompressedData), sendColumn.CompressedData = ref1[0], sendColumn.UncompressedSize = ref1[1];
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