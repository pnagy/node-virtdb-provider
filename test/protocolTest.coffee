Protocol = require "../protocol"
zmq     = require 'zmq'

chai = require "chai"
chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    on: (message, @callback) =>
    bind: (address, callback) =>

describe "Protocol", ->

    sandbox = null
    socket = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub

    afterEach =>
        sandbox.restore()

    it "should", ->
        connectStub = sandbox.stub zmq, "socket", (type) ->
            type.should.equal 'rep'
            return socket
        Protocol.metaDataServer()
