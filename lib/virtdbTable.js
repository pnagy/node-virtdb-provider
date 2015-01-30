var VirtDBTable,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

VirtDBTable = (function() {
  VirtDBTable.prototype.Fields = null;

  function VirtDBTable(_at_Name) {
    this.Name = _at_Name;
    this.addField = __bind(this.addField, this);
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