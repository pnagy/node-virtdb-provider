FieldTypeDetector = require "./fieldTypeDetector"

class VirtDBTable

    @detectFieldType: (sample) =>
        return FieldTypeDetector.get sample

    Fields: null
    constructor: (@Name, @Schema) ->
        @Fields = []

    addField: (fieldName, type) =>
        @Fields.push  {
            Name: fieldName
            Desc:
                Type: type
        }

module.exports = VirtDBTable
