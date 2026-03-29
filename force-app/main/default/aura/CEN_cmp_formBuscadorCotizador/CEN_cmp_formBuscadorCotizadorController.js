({
  onChangeObjInputBuscador: function (component, event, helper) {
    var objInputBuscador = component.get("v.objInputBuscador");
    var nroCotizacion = component.get("v.in_nroCotizacion");
    var fechaCotizacion = component.get("v.in_fechaCotizacion");
    var nombres = component.get("v.in_nombreCliente");
    var apellidos = component.get("v.in_apellidoCliente");
    var tipoDocumento = component.get("v.in_tipoDocumento");
    var nroDocumento = component.get("v.in_nroDocumento");

    objInputBuscador.nroCotizacion = nroCotizacion;
    objInputBuscador.fechaCotizacion = fechaCotizacion;
    objInputBuscador.nombres = nombres;
    objInputBuscador.apellidos = apellidos;
    objInputBuscador.tipoDocumento = tipoDocumento;
    objInputBuscador.nroDocumento = nroDocumento;

    component.set("v.objInputBuscador", objInputBuscador);
  },
  onclickBuscar: function (component, event, helper) {
    helper.sendAction(component, "onclickBuscar");
  },
  onclickLimpiarFiltros: function (component, event, helper) {
    helper.sendAction(component, "onclickLimpiarFiltros");
    component.set("v.in_nroCotizacion",null);
    component.set("v.in_fechaCotizacion",null);
    component.set("v.in_nombreCliente",null);
    component.set("v.in_apellidoCliente",null);
    component.set("v.in_tipoDocumento",null);
    component.set("v.in_nroDocumento",null);
  },
  onchangeTipoDocumento: function (component, event, helper) {
    var optionsTipoDocumento = component.get("v.optionsTipoDocumento");
    var cmptipoDocumento = component.find("tipoDocumento");
    if(cmptipoDocumento){
      cmptipoDocumento = cmptipoDocumento.get("v.value");
    }
    for(var r in optionsTipoDocumento){
      if(optionsTipoDocumento[r]!=null && optionsTipoDocumento[r].value == cmptipoDocumento){
        optionsTipoDocumento[r].selected = true;
      }else if(optionsTipoDocumento[r]){
        optionsTipoDocumento[r].selected = false;
      }
    }
    component.set("v.in_tipoDocumento", cmptipoDocumento);
  }
});