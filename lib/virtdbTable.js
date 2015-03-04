var FieldTypeDetector, VirtDBTable,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FieldTypeDetector = require("./fieldTypeDetector");

VirtDBTable = (function() {
  VirtDBTable.detectFieldType = function(sample) {
    return FieldTypeDetector.get(sample);
  };

  VirtDBTable.prototype.Fields = null;

  function VirtDBTable(Name, Schema) {
    this.Name = Name;
    this.Schema = Schema;
    this.addField = bind(this.addField, this);
    this.Fields = [];
  }

  VirtDBTable.prototype.addField = function(fieldName, type) {
    return this.Fields.push({
      Name: fieldName,
      Desc: {
        Type: type
      }
    });
  };

  return VirtDBTable;

})();

module.exports = VirtDBTable;

//# sourceMappingURL=virtdbTable.js.map