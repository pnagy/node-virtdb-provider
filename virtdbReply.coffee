class VirtDBReply
    data: null
    constructor: (query) ->
        @data = []
        for field in query.Fields
            column =
                QueryId: query.QueryId
                Name: field.Name
                SeqNo: 0
                Data:
                    Type: field.Desc.Type
                EndOfData: true
                CompType: 'NO_COMPRESSION'
            switch field.Desc.Type
                when 'STRING'
                    column.Data.StringValue = []
                when 'UINT32'
                    column.Data.UInt32Value = []
                when 'UINT64'
                    column.Data.UInt64Value = []
            @data.push column

    pushObject: (row) =>
        for item in @data
            if row[item.Name]?
                switch item.Data.Type
                    when 'STRING'
                        item.Data.StringValue.push row[item.Name]
                    when 'UINT32'
                        item.Data.UInt32Value.push row[item.Name]
                    when 'UINT64'
                        item.Data.UInt64Value.push row[item.Name]

    get: (field) =>


module.exports = VirtDBReply
