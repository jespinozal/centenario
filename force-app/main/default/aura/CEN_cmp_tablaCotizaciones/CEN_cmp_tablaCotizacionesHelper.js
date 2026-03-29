({
  sortdtRLCotizaciones: function (component, fieldName, sortDirection) {
    var data = component.get("v.listaCotizacionLibreWrapper");
    //function to return the value stored in the field
    var key = function (a) {
      return a[fieldName];
    };
    var reverse = sortDirection == "asc" ? 1 : -1;

    // to handel number/currency type fields
    if (
      fieldName == "areaTotal" ||
      fieldName == "precioTotal" ||
      fieldName == "precioConDescuento"
    ) {
      data.sort(function (a, b) {
        var a = key(a) ? key(a) : "";
        var b = key(b) ? key(b) : "";
        return reverse * ((a > b) - (b > a));
      });
    } else {
      // to handel text type fields
      data.sort(function (a, b) {
        var a = key(a) ? key(a).toLowerCase() : ""; //To handle null values , uppercase records during sorting
        var b = key(b) ? key(b).toLowerCase() : "";
        return reverse * ((a > b) - (b > a));
      });
    }
    //set sorted data to accountData attribute
    component.set("v.listaCotizacionLibreWrapper", data);
  }
});