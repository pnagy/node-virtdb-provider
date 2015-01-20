Protocol    = require './protocol'
VirtDBConnector = require 'virtdb-connector'

class VirtDBDataProvider

    constructor: (@name, connectionString) ->
        VirtDBConnector.connect(@name, connectionString)

    onMetaDataRequest: (callback) =>
        VirtDBConnector.setupEndpoint @name, Protocol.metaDataServer, callback
        return

    onQuery: (callback) =>
        VirtDBConnector.setupEndpoint @name, Protocol.queryServer, callback
        VirtDBConnector.setupEndpoint @name, Protocol.columnServer

    sendMetaData: (data) ->
        Protocol.sendMetaData data

    sendColumn: (data) ->
        Protocol.sendColumn data

    close: =>
        VirtDBConnector.close()
        Protocol.close()

    @log = VirtDBConnector.log

module.exports = VirtDBDataProvider
