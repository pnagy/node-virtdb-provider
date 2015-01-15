Protocol = require "../protocol"
zmq     = require 'zmq'

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
        Protocol.metaDataServer.should.throw(Error)

    it "should start listening if handler is given", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        socket.bound.should.be.true;
        connectionCallback.should.have.been.calledWith("name", socket, 'META_DATA', 'REQ_REP')

    it "should report error is sending meta_data without listening", ->
        Protocol.sendMetaData.should.throw(Error)

    it "should report error when trying to send empty data", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        Protocol.sendMetaData.should.throw(Error)

    it "should report error when trying to send malformed data", ->
        cb = () ->
            Protocol.sendMetaData(
                Tables: [
                    Schema: 'error'
                ]
            )
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        cb.should.throw(Error)

    it "should be able to send meta_data", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        Protocol.sendMetaData([]) # empty array is valid message here
        socket.sent.should.be.true
