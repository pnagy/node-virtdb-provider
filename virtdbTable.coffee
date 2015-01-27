class VirtDBTable
    Fields: null
    constructor: (@Name) ->
        @Fields = []

    addField: (fieldName, type) =>
        if type in ['STRING', 'UINT32', 'INT32', 'UINT64', 'INT64']
            @Fields.push {
                Name: fieldName
                Desc:
                    Type: type
            }
            return true
        else
            return false

module.exports = VirtDBTable
