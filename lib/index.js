var Protocol, VirtDBConnector, VirtDBDataProvider,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Protocol = require('./protocol');

VirtDBConnector = require('virtdb-connector');

VirtDBDataProvider = (function() {
  function VirtDBDataProvider(name, connectionString) {
    this.name = name;
    this.close = bind(this.close, this);
    this.sendTableMeta = bind(this.sendTableMeta, this);
    this.onQuery = bind(this.onQuery, this);
    this.onMetaDataRequest = bind(this.onMetaDataRequest, this);
    VirtDBConnector.connect(this.name, connectionString);
  }

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

  VirtDBDataProvider.prototype.sendMetaData = function(message) {
    return Protocol.sendMetaData(message);
  };

  VirtDBDataProvider.prototype.sendColumn = function(data) {
    return Protocol.sendColumn(data);
  };

  VirtDBDataProvider.prototype.close = function() {
    VirtDBConnector.close();
    return Protocol.close();
  };

  VirtDBDataProvider.log = VirtDBConnector.log;

  VirtDBDataProvider.FieldData = VirtDBConnector.FieldData;

  VirtDBDataProvider.VirtDBTable = require('./virtdbTable');

  VirtDBDataProvider.VirtDBReply = require('./virtdbReply');

  return VirtDBDataProvider;

})();

module.exports = VirtDBDataProvider;

//# sourceMappingURL=index.js.map