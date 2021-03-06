var FieldTypeDetector;

FieldTypeDetector = (function() {
  var _fieldTypes;

  function FieldTypeDetector() {}

  _fieldTypes = function(value) {
    var numberValue, possibleTypes;
    possibleTypes = {
      UINT32: false,
      UINT64: false,
      INT32: false,
      INT64: false,
      FLOAT: false,
      DOUBLE: false
    };
    if (value !== '') {
      numberValue = Number(value);
    }
    switch (typeof numberValue) {
      case 'number':
        if (isFinite(numberValue)) {
          if (numberValue % 1 === 0) {
            if (numberValue >= 0) {
              if (numberValue < 4294967295) {
                possibleTypes['UINT32'] = true;
              }
              possibleTypes['UINT64'] = true;
              if (numberValue < 2147483647) {
                possibleTypes['INT32'] = true;
              }
              if (numberValue < 9223372036854775807) {
                possibleTypes['INT64'] = true;
              }
            } else {
              if (numberValue > -2147483648) {
                possibleTypes['INT32'] = true;
              }
              if (numberValue > -9223372036854775808) {
                possibleTypes['INT64'] = true;
              }
            }
          }
        } else {
          if (numberValue.length < 7) {
            possibleTypes['FLOAT'] = true;
          }
          if (numberValue.lenght < 16) {
            possibleTypes['DOUBLE'] = true;
          }
        }
    }
    return possibleTypes;
  };

  FieldTypeDetector.get = function(values) {
    var hasValues, i, j, len, len1, possibleFieldTypes, possibleTypes, type, typesInOrder, value;
    typesInOrder = ['UINT32', 'UINT64', 'INT32', 'INT64', 'FLOAT', 'DOUBLE'];
    if ((values != null) && values.length > 0) {
      hasValues = false;
      possibleTypes = {
        UINT32: true,
        UINT64: true,
        INT32: true,
        INT64: true,
        FLOAT: true,
        DOUBLE: true
      };
      for (i = 0, len = values.length; i < len; i++) {
        value = values[i];
        if (value !== '') {
          hasValues = true;
          possibleFieldTypes = _fieldTypes(value);
          for (type in possibleTypes) {
            if (!possibleFieldTypes[type]) {
              possibleTypes[type] = false;
            }
          }
        }
      }
      if (hasValues) {
        for (j = 0, len1 = typesInOrder.length; j < len1; j++) {
          type = typesInOrder[j];
          if (possibleTypes[type]) {
            return type;
          }
        }
      }
    }
    return 'STRING';
  };

  return FieldTypeDetector;

})();

module.exports = FieldTypeDetector;

//# sourceMappingURL=fieldTypeDetector.js.map