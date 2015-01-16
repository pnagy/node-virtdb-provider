fs          = require 'fs'
zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'

proto_meta = protobuf.meta_data
proto_data = protobuf.data

class Protocol
    @metadata_socket = null
    @column_socket = null

    @metaDataServer = (name, connectionString, onRequest, onBound) =>
        if not onBound?
            throw new Error("Missing required parameter: onBound")
        @metadata_socket = zmq.socket "rep"
        @metadata_socket.on "message", (request) =>
            try
                newData = proto_meta.parse(request, "virtdb.interface.pb.MetaDataRequest")
                onRequest newData
            catch ex
                @metadata_socket.send 'err'
            return
        @metadata_socket.bind connectionString, (err) =>
            if err?
                throw err
            onBound name, @metadata_socket, 'META_DATA', 'REQ_REP'

    @queryServer = (name, connectionString, onQuery, onBound) =>
        if not onBound?
            throw new Error("Missing required parameter: onBound")
        @query_socket = zmq.socket "pull"
        @query_socket.on "message", (request) =>
            try
                query = proto_data.parse(request, "virtdb.interface.pb.Query")
                onQuery query
            catch ex
                @query_socket.send 'err'
            return
        @query_socket.bind connectionString, (err) =>
            if err?
                throw err
            onBound name, @query_socket, 'QUERY', 'PUSH_PULL'

    @columnServer = (name, connectionString, onBound) =>
        if not onBound?
            throw new Error("Missing required parameter: onBound")
        @column_socket = zmq.socket "pub"
        @column_socket.bind connectionString, (err) =>
            if err?
                throw err
            onBound name, @column_socket, 'COLUMN', 'PUB_SUB'

    @sendMetaData = (data) =>
        if not @metadata_socket?
            throw new Error("metadata_socket is not yet initialized")
        if not data?
            throw new Error("sendMetaData called with invalid argument: ", data)
        serializedData = proto_meta.serialize data, "virtdb.interface.pb.MetaData"
        proto_meta.parse serializedData, "virtdb.interface.pb.MetaData" # call it only for sanity check as serialize seems to be too permissive
        @metadata_socket.send serializedData

    @sendColumn = (columnChunk) =>
        if not @column_socket?
            throw new Error("column_socket is not yet initialized")
        if not columnChunk?
            throw new Error("sendColumn called with invalid argument: ", columnChunk)
        serializedData = proto_data.serialize columnChunk, "virtdb.interface.pb.Column"
        proto_data.parse serializedData, "virtdb.interface.pb.Column" # call it only for sanity check as serialize seems to be too permissive
        @column_socket.send columnChunk.QueryId, zmq.ZMQ_SNDMORE
        @column_socket.send serializedData

    @close = () =>
        @metadata_socket?.close()
        @metadata_socket = null
        @column_socket?.close()
        @column_socket = null
        @query_socket?.close()
        @query_socket = null



module.exports = Protocol
