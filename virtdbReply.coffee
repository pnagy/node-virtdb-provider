FieldData = require("virtdb-connector").FieldData
lz4 = require "lz4"

class VirtDBReply
    data: null
    maxChunkSize: null
    queryId: null
    compType: 'LZ4_COMPRESSION'
    seqNo: 0
    constructor: (query) ->
        @data = []
        @maxChunkSize = query.MaxChunkSize or 25000
        @queryId = query.QueryId
        @seqNo = 0
        for field in query.Fields
            column =
                QueryId: query.QueryId
                Name: field.Name
                Data: FieldData.createInstance(field.Name, field.Desc.Type)
            @data.push column

    pushObject: (row) =>
        for item in @data
            item.Data.push row[item.Name]

    compress = (data) ->
        input = new Buffer(data)
        output = new Buffer(lz4.encodeBound(input.length))
        compSize = lz4.encodeBlock(input, output)
        output = output.slice(0, compSize)
        return [output, compSize]

    send: (sendFn, endOfData = true) =>
        for column in @data
            index = 0
            while column.Data.getArray().length > 0
                uncompressedData = column.Data.getArray().splice(0, @maxChunkSize)
                sendColumn =
                    QueryId: @queryId
                    Name: column.Name
                    SeqNo: @seqNo + index
                    Data: []
                    EndOfData: false
                    CompType: 'LZ4_COMPRESSION'
                [sendColumn.CompressedData, sendColumn.UncompressedSize] =
                    compress uncompressedData
                sendFn sendColumn
                index += 1
            if endOfData
                uncompressedData = []
                sendColumn =
                    QueryId: @queryId
                    Name: column.Name
                    SeqNo: @seqNo + index
                    Data: []
                    EndOfData: true
                    CompType: 'LZ4_COMPRESSION'
                [sendColumn.CompressedData, sendColumn.UncompressedSize] =
                    compress uncompressedData
                sendFn sendColumn
                index += 1
        @seqNo = @seqNo + index + 1
        data = []

module.exports = VirtDBReply