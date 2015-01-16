var Protocol, fs, proto_data, proto_meta, protobuf, zmq;

fs = require('fs');

zmq = require('zmq');

protobuf = require('virtdb-proto');

proto_meta = protobuf.meta_data;

proto_data = protobuf.data;

Protocol = (function() {
  function Protocol() {}

  Protocol.metadata_socket = null;

  Protocol.column_socket = null;

  Protocol.metaDataServer = function(name, connectionString, onRequest, onBound) {
    if (onBound == null) {
      throw new Error("Missing required parameter: onBound");
    }
    Protocol.metadata_socket = zmq.socket("rep");
    Protocol.metadata_socket.on("message", function(request) {
      var ex, newData;
      try {
        newData = proto_meta.parse(request, "virtdb.interface.pb.MetaDataRequest");
        onRequest(newData);
      } catch (_error) {
        ex = _error;
        Protocol.metadata_socket.send('err');
      }
    });
    return Protocol.metadata_socket.bind(connectionString, function(err) {
      if (err != null) {
        throw err;
      }
      return onBound(name, Protocol.metadata_socket, 'META_DATA', 'REQ_REP');
    });
  };

  Protocol.queryServer = function(name, connectionString, onQuery, onBound) {
    if (onBound == null) {
      throw new Error("Missing required parameter: onBound");
    }
    Protocol.query_socket = zmq.socket("pull");
    Protocol.query_socket.on("message", function(request) {
      var ex, query;
      try {
        query = proto_data.parse(request, "virtdb.interface.pb.Query");
        onQuery(query);
      } catch (_error) {
        ex = _error;
        Protocol.query_socket.send('err');
      }
    });
    return Protocol.query_socket.bind(connectionString, function(err) {
      if (err != null) {
        throw err;
      }
      return onBound(name, Protocol.query_socket, 'QUERY', 'PUSH_PULL');
    });
  };

  Protocol.columnServer = function(name, connectionString, onBound) {
    if (onBound == null) {
      throw new Error("Missing required parameter: onBound");
    }
    Protocol.column_socket = zmq.socket("pub");
    return Protocol.column_socket.bind(connectionString, function(err) {
      if (err != null) {
        throw err;
      }
      return onBound(name, Protocol.column_socket, 'COLUMN', 'PUB_SUB');
    });
  };

  Protocol.sendMetaData = function(data) {
    var serializedData;
    if (Protocol.metadata_socket == null) {
      throw new Error("metadata_socket is not yet initialized");
    }
    if (data == null) {
      throw new Error("sendMetaData called with invalid argument: ", data);
    }
    serializedData = proto_meta.serialize(data, "virtdb.interface.pb.MetaData");
    proto_meta.parse(serializedData, "virtdb.interface.pb.MetaData");
    return Protocol.metadata_socket.send(serializedData);
  };

  Protocol.sendColumn = function(columnChunk) {
    var serializedData;
    if (Protocol.column_socket == null) {
      throw new Error("column_socket is not yet initialized");
    }
    if (columnChunk == null) {
      throw new Error("sendColumn called with invalid argument: ", columnChunk);
    }
    serializedData = proto_data.serialize(columnChunk, "virtdb.interface.pb.Column");
    proto_data.parse(serializedData, "virtdb.interface.pb.Column");
    Protocol.column_socket.send(columnChunk.QueryId, zmq.ZMQ_SNDMORE);
    return Protocol.column_socket.send(serializedData);
  };

  Protocol.close = function() {
    var _ref, _ref1, _ref2;
    if ((_ref = Protocol.metadata_socket) != null) {
      _ref.close();
    }
    Protocol.metadata_socket = null;
    if ((_ref1 = Protocol.column_socket) != null) {
      _ref1.close();
    }
    Protocol.column_socket = null;
    if ((_ref2 = Protocol.query_socket) != null) {
      _ref2.close();
    }
    return Protocol.query_socket = null;
  };

  return Protocol;

})();

module.exports = Protocol;

//# sourceMappingURL=protocol.js.map