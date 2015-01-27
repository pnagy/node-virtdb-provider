var Protocol, VirtDBConnector, VirtDBDataProvider, VirtDBReply, VirtDBTable,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Protocol = require('./protocol');

VirtDBConnector = require('virtdb-connector');

VirtDBTable = require('./virtdbTable');

VirtDBReply = require('./virtdbReply');

VirtDBDataProvider = (function() {
  function VirtDBDataProvider(name, connectionString) {
    this.name = name;
    this.close = __bind(this.close, this);
    this.sendTableMeta = __bind(this.sendTableMeta, this);
    this.onQuery = __bind(this.onQuery, this);
    this.onMetaDataRequest = __bind(this.onMetaDataRequest, this);
    this.createReply = __bind(this.createReply, this);
    this.createTable = __bind(this.createTable, this);
    VirtDBConnector.connect(this.name, connectionString);
  }

  VirtDBDataProvider.prototype.createTable = function(name) {
    return new VirtdbTable(name);
  };

  VirtDBDataProvider.prototype.createReply = function(table, query) {
    return new VirtDBReply(table, query);
  };

  VirtDBDataProvider.prototype.onMetaDataRequest = function(callback) {
    VirtDBConnector.setupEndpoint(this.name, Protocol.metaDataServer, callback);
  };

  VirtDBDataProvider.prototype.onQuery = function(callback) {
    VirtDBConnector.setupEndpoint(this.name, Protocol.queryServer, callback);
    return VirtDBConnector.setupEndpoint(this.name, Protocol.columnServer);
  };

  VirtDBDataProvider.prototype.sendTableMeta = function(table) {
    var message;
    message = {
      Tables: [table]
    };
    return this.sendMetaData(message);
  };

  VirtDBDataProvider.prototype.sendMetaData = function(table) {
    return Protocol.sendMetaData(message);
  };

  VirtDBDataProvider.prototype.sendColumn = function(data) {
    return Protocol.sendColumn(data);
  };

  VirtDBDataProvider.prototype.send = function(reply) {
    var column, _i, _len, _ref, _results;
    _ref = reply.data;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      _results.push(Protocol.sendColumn(column));
    }
    return _results;
  };

  VirtDBDataProvider.prototype.close = function() {
    VirtDBConnector.close();
    return Protocol.close();
  };

  VirtDBDataProvider.log = VirtDBConnector.log;

  return VirtDBDataProvider;

})();

module.exports = VirtDBDataProvider;

//# sourceMappingURL=index.js.map