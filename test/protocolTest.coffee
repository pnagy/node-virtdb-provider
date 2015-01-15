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
    on: (message, @callback) =>
    bind: (address, callback) =>
        @bound = true
        callback()

describe "Protocol metaDataServer", ->
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

    it "should return error if called without onBound handler", ->
        Protocol.metaDataServer.should.throw(Error)

    it "should start listening if handler is given", ->
        dataCallback = (data) ->
        connectionCallback = sandbox.spy()
        Protocol.metaDataServer "name", "connectionString", dataCallback, connectionCallback
        socket.bound.should.be.true;
        connectionCallback.should.have.been.calledWith("name", socket, 'META_DATA', 'REQ_REP')
