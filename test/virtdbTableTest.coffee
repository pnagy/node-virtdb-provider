VirtDBTable = require "../virtdbTable"

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "VirtDBTable", ->
    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    it "should be a well-formed table metadata when a STRING field is added", ->
        table = new VirtDBTable('tableName')
        table.addField('tableField', 'STRING')
        table.Name.should.equal 'tableName'
        table.Fields.length.should.equal 1
        table.Fields[0].Name.should.equal 'tableField'
        table.Fields[0].Desc.Type.should.equal 'STRING'

    it "should be a well-formed table metadata when a STRING and an INT32 field are added", ->
        table = new VirtDBTable('tableName')
        table.addField('tableField', 'STRING')
        table.addField('intField', 'INT32')
        table.Name.should.equal 'tableName'
        table.Fields.length.should.equal 2
        table.Fields[0].Name.should.equal 'tableField'
        table.Fields[0].Desc.Type.should.equal 'STRING'
        table.Fields[1].Name.should.equal 'intField'
        table.Fields[1].Desc.Type.should.equal 'INT32'
