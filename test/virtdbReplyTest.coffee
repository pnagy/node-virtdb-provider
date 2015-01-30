VirtDBReply = require "../virtdbReply"
FieldData = require("virtdb-connector").FieldData
lz4 = require "lz4"
CommonProto = (require "virtdb-proto").common

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "VirtDBReply", ->
    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    compress = (data) ->
        input = CommonProto.serialize data, "virtdb.interface.pb.ValueType"
        testData = CommonProto.parse input, "virtdb.interface.pb.ValueType"
        output = new Buffer(lz4.encodeBound(input.length))
        compSize = lz4.encodeBlock(input, output)
        output = output.slice(0, compSize)
        return [output, input.length]


    it "should be a well-formed column meta when a STRING field is added", ->
        id = "e142fbd0-9d77-11e4-bd06-0800200c9a66"
        query =
            QueryId: id
            Table: "customers"
            Fields: [
                Name: "id"
                Desc:
                    Type: 'UINT64'
            ,
                Name: "name"
                Desc:
                    Type:
                        'STRING'
            ]
        reply = new VirtDBReply(query)
        reply.data.length.should.equal 2
        reply.data[0].QueryId.should.equal id
        reply.data[0].Name.should.equal 'id'
        reply.data[0].Data.Type.should.equal 'UINT64'
        reply.data[0].Data.UInt64Value.should.deep.equal []
        reply.data[1].QueryId.should.equal id
        reply.data[1].Name.should.equal 'name'
        reply.data[1].Data.Type.should.equal 'STRING'
        reply.data[1].Data.StringValue.should.deep.equal []

    it "should contain items if an object is pushed to it", ->
        id = "e142fbd0-9d77-11e4-bd06-0800200c9a66"
        query =
            QueryId: id
            Table: "customers"
            Fields: [
                Name: "id"
                Desc:
                    Type: 'UINT64'
            ,
                Name: "name"
                Desc:
                    Type:
                        'STRING'
            ]
        reply = new VirtDBReply(query)
        data1 =
            id: 5
            name: 'cica'
        data2 =
            id: 4
            name: 'kutya'
        reply.pushObject data1
        reply.pushObject data2
        reply.data.length.should.equal 2
        reply.data[0].QueryId.should.equal id
        reply.data[0].Name.should.equal 'id'
        reply.data[0].Data.Type.should.equal 'UINT64'
        reply.data[0].Data.UInt64Value.should.deep.equal [5, 4]
        reply.data[1].QueryId.should.equal id
        reply.data[1].Name.should.equal 'name'
        reply.data[1].Data.Type.should.equal 'STRING'
        reply.data[1].Data.StringValue.should.deep.equal ['cica', 'kutya']

    it "should send 5 rows in 5 chunks if chunkSize is 1", ->
        query_id = "id"
        sendFn = sinon.spy()
        query =
            QueryId: query_id
            MaxChunkSize: 1
            Table: "ids"
            Fields: [
                Name: "id"
                Desc:
                    Type: 'UINT64'
            ]
        reply = new VirtDBReply query
        for id in [1, 2, 3, 4, 5]
            reply.pushObject { id: id }
        reply.send sendFn
        column =
            QueryId: query_id
            Name: "id"
            SeqNo: 0
            EndOfData: false
            CompType: 'LZ4_COMPRESSION'
        data = FieldData.createInstance column.Name, 'UINT64'
        data.pushArray [1]
        [compressedData, column.UncompressedSize] =
            compress data
        sendFn.should.have.been.calledWith(sinon.match(column))
        column.SeqNo = 1
        data = FieldData.createInstance column.Name, 'UINT64'
        data.pushArray [2]
        [compressedData, column.UncompressedSize] =
            compress data
        sendFn.should.have.been.calledWith(sinon.match(column))
        column.SeqNo = 2
        data = FieldData.createInstance column.Name, 'UINT64'
        data.pushArray [3]
        [compressedData, column.UncompressedSize] =
            compress data
        sendFn.should.have.been.calledWith(sinon.match(column))
        column.SeqNo = 3
        data = FieldData.createInstance column.Name, 'UINT64'
        data.pushArray [4]
        [compressedData, column.UncompressedSize] =
            compress data
        sendFn.should.have.been.calledWith(sinon.match(column))
        column.SeqNo = 4
        column.EndOfData = true
        data = FieldData.createInstance column.Name, 'UINT64'
        data.pushArray [5]
        [compressedData, column.UncompressedSize] =
            compress data
        sendFn.should.have.been.calledWith(sinon.match(column))

    it "should send 5 rows in 3 chuks if chunkSize is 2", ->
        id = "id"
        sendFn = sinon.spy()
        query =
            QueryId: id
            MaxChunkSize: 2
            Table: "ids"
            Fields: [
                Name: "id"
                Desc:
                    Type: 'UINT64'
            ]
        reply = new VirtDBReply query
        for id in [1, 2, 3, 4, 5]
            reply.pushObject { id: id }
        reply.send sendFn
        sendFn.should.have.callCount 3

    it "should send 5 rows with 2 fields in 6 chuks if chunkSize is 2", ->
        id = "id"
        sendFn = sinon.spy()
        query =
            QueryId: id
            MaxChunkSize: 2
            Table: "ids"
            Fields: [
                Name: "id"
                Desc:
                    Type: 'UINT64'
            ,
                Name: "name"
                Desc:
                    Type: 'STRING'
            ]
        reply = new VirtDBReply query
        for id in [1, 2, 3, 4, 5]
            reply.pushObject { id: id, name: "name #{id}" }
        reply.send sendFn
        sendFn.should.have.callCount 6
