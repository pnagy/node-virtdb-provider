class VirtDBTable
    Fields: null
    constructor: (@Name) ->
        @Fields = []

    addField: (fieldName, type) =>
        @Fields.push  {
            Name: fieldName
            Desc:
                Type: type
        }

module.exports = VirtDBTable
