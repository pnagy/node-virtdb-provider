Protocol    = require '../protocol'
Provider = require "../index.coffee"
VirtDBConnector = require 'virtdb-connector'
zmq         = require 'zmq'

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    bound: false
    sent: false
    connect: null
    constructor: ->
        @connect = sinon.spy()
    on: (message, @callback) =>
    bind: (address, callback) =>
        @bound = true
        callback()
    close: () =>
    send: (data) =>
        @sent = true

describe "DataProvider", ->
    sandbox = null
    socket = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) ->
            socket
    afterEach =>
        sandbox.restore()

    it "should be created", ->
        connector = sinon.spy VirtDBConnector, "connect"
        provider = new Provider "test-provider", "localhost"
        connector.should.have.been.called
        socket.connect.should.have.been.calledWith "localhost"

    it "should be able to register metadata request callback", ->
        provider = new Provider "test-provider", "localhost"
        cb = () ->
            provider.onMetaDataRequest () ->
        cb.should.not.throw

    it "should be able to register query request callback", ->
        provider = new Provider "test-provider", "localhost"
        cb = () ->
            provider.onQuery () ->
        cb.should.not.throw

    # it "should be able to send metadata", ->
    #     sendMethod = sinon.spy Protocol, "sendMetaData"
    #     provider = new Provider "test-provider", "localhost"
    #     data = {}
    #     provider.sendMetaData data
    #     sendMethod.should.have.been.calledWith data
