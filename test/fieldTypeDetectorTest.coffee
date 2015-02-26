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
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['asd'] }
        detector.getFieldType('Field1').should.equal('STRING')

    it "with 1 unsigned int field it should report field type as UINT32", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['42'] }
        detector.getFieldType('Field1').should.equal('UINT32')

    it "with 1 field of 0 it should report field type as UINT32", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['0']}
        detector.getFieldType('Field1').should.equal('UINT32')

    it "null fields should not change field type", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['-42']}
        detector.addSample {'Field1' : ['']}
        detector.addSample {'Field1' : ['42']}
        detector.getFieldType('Field1').should.equal('INT32')

    it "with an int and a string field it should report field type as STRING", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['42'] }
        detector.addSample {'Field1' : ['asd'] }
        detector.getFieldType('Field1').should.equal('STRING')

    it "with an int and a string field it should report field type as STRING even if only 1 sample is needed", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['42'] }
        detector.addSample {'Field1' : ['asd'] }
        detector.getFieldType('Field1').should.equal('STRING')

    it "with an uint and an int field it should report field type as INT32", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['42'] }
        detector.addSample {'Field1' : ['-42'] }
        detector.getFieldType('Field1').should.equal('INT32')

    it "with an uint64 and an uint32 field it should report field type as UINT64", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['4294967294'] }
        detector.addSample {'Field1' : ['4294967295'] }
        detector.getFieldType('Field1').should.equal('UINT64')

    it "with an uint32 and an int32 field of which uint32 does not fit into int32 it should report field type as INT64", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['4294967294'] }
        detector.addSample {'Field1' : ['-2'] }
        detector.getFieldType('Field1').should.equal('INT64')

    it "with an uint64 and an int64 field of which uint64 does not fit into int64 it should report field type as STRING", ->
        detector = new FieldTypeDetector
        detector.addSample {'Field1' : ['9223372036854775807'] }
        detector.addSample {'Field1' : ['-2'] }
        detector.getFieldType('Field1').should.equal('STRING')

    it "should add more data at the same time in one sample", ->
        samples = 
            "h1": ["11", "12", "13", "14", "15"]
            "h2": ["f21", "f22", "f23", "f24", "f25"]
            "h3": ["-31", "-32", "-33", "-34", "-35"]
        detector = new FieldTypeDetector
        detector.addSample samples
        detector.getFieldType('h1').should.equal('UINT32')
        detector.getFieldType('h2').should.equal('STRING')
        detector.getFieldType('h3').should.equal('INT32')

