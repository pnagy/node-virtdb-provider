class FieldTypeDetector
    samples: null

    constructor: ()->
        @samples = {}

    addSample: (samples) =>
        for header, fields of samples
            @samples[header] ?= []
            for field in fields
                @samples[header].push field

    _fieldTypes = (value) ->
        possibleTypes =
            UINT32: false
            UINT64: false
            INT32: false
            INT64: false
            FLOAT: false
            DOUBLE: false
        if value != ''
            numberValue = Number value
        switch  typeof numberValue
            when 'number'
                if isFinite(numberValue)
                    if numberValue % 1 == 0
                        if numberValue >= 0
                            if numberValue < 4294967295
                                possibleTypes['UINT32'] = true
                            possibleTypes['UINT64'] = true
                            if numberValue < 2147483647
                                possibleTypes['INT32'] = true
                            if numberValue < 9223372036854775807
                                possibleTypes['INT64'] = true
                        else
                            if numberValue > -2147483648
                                possibleTypes['INT32'] = true
                            if numberValue > -9223372036854775808
                                possibleTypes['INT64'] = true
                else
                    if numberValue.length < 7
                        possibleTypes['FLOAT'] = true
                    if numberValue.lenght <16
                        possibleTypes['DOUBLE'] = true
        return possibleTypes

    getFieldType: (name) =>
        typesInOrder = ['UINT32', 'UINT64', 'INT32', 'INT64', 'FLOAT', 'DOUBLE']
        values = @samples?[name]
        if values? and values.length > 0
            hasValues = false
            possibleTypes =
                UINT32: true
                UINT64: true
                INT32: true
                INT64: true
                FLOAT: true
                DOUBLE: true
            for value in values
                if value != ''
                    hasValues = true
                    possibleFieldTypes = _fieldTypes(value)
                    for type of possibleTypes
                        possibleTypes[type] = false if not possibleFieldTypes[type]
            if hasValues
                for type in typesInOrder
                    return type if possibleTypes[type]
        return 'STRING'

module.exports = FieldTypeDetector
