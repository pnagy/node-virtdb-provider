FieldTypeDetector = require "../fieldTypeDetector"

chai = require "chai"
should = chai.should()

sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "FieldTypeDetector", ->
    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    it "with 1 string field it should report field type as STRING", ->
        sample = ['asd']
        FieldTypeDetector.get(sample).should.equal('STRING')

    it "with 1 unsigned int field it should report field type as UINT32", ->
        sample =  ['42']
        FieldTypeDetector.get(sample).should.equal('UINT32')

    it "with 1 field of 0 it should report field type as UINT32", ->
        sample = ['0']
        FieldTypeDetector.get(sample).should.equal('UINT32')

    it "null fields should not change field type", ->
        sample = ['-42', '42', '']
        FieldTypeDetector.get(sample).should.equal('INT32')

    it "with an int and a string field it should report field type as STRING", ->
        sample = ['42', 'asd']
        FieldTypeDetector.get(sample).should.equal('STRING')

    it "with an uint and an int field it should report field type as INT32", ->
        sample = ['42', '-42']
        FieldTypeDetector.get(sample).should.equal('INT32')

    it "with an uint64 and an uint32 field it should report field type as UINT64", ->
        sample = ['4294967294', '4294967295']
        FieldTypeDetector.get(sample).should.equal('UINT64')

    it "with an uint32 and an int32 field of which uint32 does not fit into int32 it should report field type as INT64", ->
        sample = ['4294967294', '-2']
        FieldTypeDetector.get(sample).should.equal('INT64')

    it "with an uint64 and an int64 field of which uint64 does not fit into int64 it should report field type as STRING", ->
        sample = ['9223372036854775807', '-2']
        FieldTypeDetector.get(sample).should.equal('STRING')
