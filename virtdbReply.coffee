FieldData = require("virtdb-connector").FieldData

class VirtDBReply
    data: null
    constructor: (query) ->
        @data = []
        for field in query.Fields
            column =
                QueryId: query.QueryId
                Name: field.Name
                SeqNo: 0
                Data: FieldData.createInstance(field.Name, field.Desc.Type)
                EndOfData: true
                CompType: 'NO_COMPRESSION'
            @data.push column

    pushObject: (row) =>
        for item in @data
            if row[item.Name]?
                item.Data.push row[item.Name]

module.exports = VirtDBReply
