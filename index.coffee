Protocol    = require './protocol'
VirtDBConnector = require 'virtdb-connector'
VirtDBTable = require './virtdbTable'
VirtDBReply = require './virtdbReply'

class VirtDBDataProvider

    constructor: (@name, connectionString) ->
        VirtDBConnector.connect(@name, connectionString)

    createTable: (name) =>
        return new VirtdbTable(name)

    createReply: (table, query) =>
        return new VirtDBReply(table, query)

    onMetaDataRequest: (callback) =>
        VirtDBConnector.setupEndpoint @name, Protocol.metaDataServer, callback
        return

    onQuery: (callback) =>
        VirtDBConnector.setupEndpoint @name, Protocol.queryServer, callback
        VirtDBConnector.setupEndpoint @name, Protocol.columnServer

    sendMetaData: (data) ->
        message =
            Tables: []
        message.Tables.concat data
        Protocol.sendMetaData message

    sendColumn: (data) ->
        Protocol.sendColumn data

    send: (reply) ->
        for column in reply.data
            Protocol.sendColumn column

    close: =>
        VirtDBConnector.close()
        Protocol.close()

    @log = VirtDBConnector.log

module.exports = VirtDBDataProvider
