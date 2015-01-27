VirtDBReply = require "../virtdbReply"

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
        reply.data[0].SeqNo.should.equal 0
        reply.data[0].Data.Type.should.equal 'UINT64'
        reply.data[0].Data.UInt64Value.should.deep.equal []
        reply.data[0].EndOfData.should.equal true
        reply.data[0].CompType.should.equal 'NO_COMPRESSION'
        reply.data[1].QueryId.should.equal id
        reply.data[1].Name.should.equal 'name'
        reply.data[1].SeqNo.should.equal 0
        reply.data[1].Data.Type.should.equal 'STRING'
        reply.data[1].Data.StringValue.should.deep.equal []
        reply.data[1].EndOfData.should.equal true
        reply.data[1].CompType.should.equal 'NO_COMPRESSION'

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
        reply.data[0].SeqNo.should.equal 0
        reply.data[0].Data.Type.should.equal 'UINT64'
        reply.data[0].Data.UInt64Value.should.deep.equal [5, 4]
        reply.data[0].EndOfData.should.equal true
        reply.data[0].CompType.should.equal 'NO_COMPRESSION'
        reply.data[1].QueryId.should.equal id
        reply.data[1].Name.should.equal 'name'
        reply.data[1].SeqNo.should.equal 0
        reply.data[1].Data.Type.should.equal 'STRING'
        reply.data[1].Data.StringValue.should.deep.equal ['cica', 'kutya']
        reply.data[1].EndOfData.should.equal true
        reply.data[1].CompType.should.equal 'NO_COMPRESSION'
