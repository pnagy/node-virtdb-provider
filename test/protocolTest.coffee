Protocol = require "../protocol"
zmq     = require 'zmq'

protobuf    = require 'virtdb-proto'
proto_meta = protobuf.meta_data
proto_data = protobuf.data

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    bound: false
    sent: false
    on: (message, @callback) =>
    bind: (address, callback) =>
        @bound = true
        callback()
    close: () =>
    send: (data) =>
        @sent = true


describe "Protocol for meta_data", ->
    sandbox = null
    socket = null
    connectStub = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) ->
            type.should.equal 'rep'
            return socket

    afterEach =>
        sandbox.restore()
        Protocol.close()

    it "should return error if listen called without onBound handler", ->
        ( ->
            Protocol.metaDataServer()
        ).should.throw "Missing required parameter: onBound"

    it "should start listening if handler is given", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        socket.bound.should.be.true;
        connectionCallback.should.have.been.calledWith("name", socket, 'META_DATA', 'REQ_REP')

    it "should report error is sending meta_data without listening", ->
        ( ->
            Protocol.sendMetaData()
        ).should.throw "metadata_socket is not yet initialized"

    it "should report error when trying to send empty data", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        ( ->
            Protocol.sendMetaData()
        ).should.throw "sendMetaData called with invalid argument:"

    it "should report error when trying to send malformed data", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        ( ->
            Protocol.sendMetaData(
                Tables: [
                    Schema: 'error'
                ]
            )
        ).should.throw "Malformed protocol buffer"

    it "should be able to send meta_data", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        Protocol.sendMetaData([]) # empty array is valid message here
        socket.sent.should.be.true

    it "should be able to receive meta_data requests", ->
        dataCallback = sandbox.spy()
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        request =
            Name: "name"
            WithFields: false
        socket.callback(proto_meta.serialize(request, "virtdb.interface.pb.MetaDataRequest"))
        dataCallback.should.have.been.calledWith(request)

    it "should send reply even if request is malformed as REQ_REP sockets are picky for this", ->
        dataCallback = sandbox.spy()
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        request = {}
        socket.callback(proto_meta.serialize(request, "virtdb.interface.pb.MetaData"))
        socket.sent.should.be.true

describe "Protocol for column", ->
    sandbox = null
    socket = null
    connectStub = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) ->
            type.should.equal 'pub'
            return socket

    afterEach =>
        sandbox.restore()
        Protocol.close()

    it "should return error if listen called without onBound handler", ->
        ( ->
            Protocol.columnServer()
        ).should.throw "Missing required parameter: onBound"

    it "should start listening if handler is given", ->
        connectionCallback = sandbox.spy()
        Protocol.columnServer "name", "connectionString", null, connectionCallback
        socket.bound.should.be.true;
        connectionCallback.should.have.been.calledWith("name", socket, 'COLUMN', 'PUB_SUB')

    it "should report error is sending meta_data without listening", ->
        ( ->
            Protocol.sendColumn()
        ).should.throw "column_socket is not yet initialized"

    it "should report error when trying to send empty data", ->
        connectionCallback = sandbox.spy()
        Protocol.columnServer "name", "connectionString", null, connectionCallback
        ( ->
            Protocol.sendColumn()
        ).should.throw "sendColumn called with invalid argument:"

    it "should report error when trying to send malformed data", ->
        connectionCallback = sandbox.spy()
        Protocol.columnServer "name", "connectionString", null, connectionCallback
        ( ->
            Protocol.sendColumn(
                QueryId: 'error'
            )
        ).should.throw "Missing required fields while serializing virtdb.interface.pb.Column"

    it "should be able to send meta_data", ->
        connectionCallback = sandbox.spy()
        Protocol.columnServer "name", "connectionString", null, connectionCallback
        Protocol.sendColumn(
            QueryId: "id"
            Name: "name"
            Data:
                Type: 'STRING'
            SeqNo: 0
        ) # em1pty array is valid message here
        socket.sent.should.be.true

    it "should throw error if callback is provided and not null", ->
        connectionCallback = sandbox.spy()
        callbackNotNull = sandbox.spy()
        ( ->
            Protocol.columnServer "name", "connectionString", callbackNotNull, connectionCallback
        ).should.throw "ColumnServer is a write only protocol and must not be called with message callback."

describe "Protocol for query", ->
    sandbox = null
    socket = null
    connectStub = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) ->
            type.should.equal 'pull'
            return socket

    afterEach =>
        sandbox.restore()
        Protocol.close()

    it "should return error if listen called without onBound handler", ->
        ( ->
            Protocol.queryServer()
        ).should.throw "Missing required parameter: onBound"

    it "should start listening if handler is given", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.queryServer "name", "connectionString", dataCallback, connectionCallback
        socket.bound.should.be.true;
        connectionCallback.should.have.been.calledWith("name", socket, 'QUERY', 'PUSH_PULL')

    it "should be able to receive queries", ->
        dataCallback = sandbox.spy()
        connectionCallback = sandbox.spy()
        Protocol.queryServer "name", "connectionString", dataCallback, connectionCallback
        query =
            QueryId: "queryid"
            Table: "table"
            Fields: []
            Filter: []
            SeqNos: []
        socket.callback(proto_data.serialize(query, "virtdb.interface.pb.Query"))
        dataCallback.should.have.been.calledWith(query)
