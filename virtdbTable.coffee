class VirtDBTable
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
