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

    sendTableMeta: (table) =>
        message =
            Tables: [ table ]
        @sendMetaData message

    sendMetaData: (message) ->
        Protocol.sendMetaData message

    sendColumn: (data) ->
        Protocol.sendColumn data

    close: =>
        VirtDBConnector.close()
        Protocol.close()

    @log = VirtDBConnector.log

module.exports = VirtDBDataProvider
