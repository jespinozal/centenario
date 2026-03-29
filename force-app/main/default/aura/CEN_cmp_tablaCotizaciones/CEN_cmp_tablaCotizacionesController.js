({
  doInit: function (component, event, helper) {
    var columnsdtRLCotizaciones = [
      /*{
        initialWidth: 200,
        label: "NroCotización",
        fieldName: "nroCotizacion",
        type: "text"
      },*/
      {
        label: "NroCotización",
        fieldName: "url",
        type: "url",
        sortable: true,
        initialWidth: 200,
        typeAttributes: { label: { fieldName: "nroCotizacion" } },
        wrapText: true
      },
      {
        initialWidth: 200,
        label: "Fecha",
        fieldName: "fecha",
        type: "date-local",
        sortable: true,
        typeAttributes: { month: "2-digit", day: "2-digit" }
      },
      {
        initialWidth: 200,
        label: "Proyecto",
        fieldName: "proyecto",
        type: "text",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Nombre de Cliente",
        fieldName: "nombreCompletoPersona",
        type: "text",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Tipo Documento",
        fieldName: "tipoDocumentoPersona",
        type: "text",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Nro Documento",
        fieldName: "nroDocumentoPersona",
        type: "text",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Área total",
        fieldName: "areaTotal",
        type: "number",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Precio Total",
        fieldName: "precioTotal",
        type: "number",
        sortable: true
      },
      {
        initialWidth: 200,
        label: "Precio con Descuento",
        fieldName: "precioConDescuento",
        type: "number",
        sortable: true
      }
    ];
    component.set("v.columnsdtRLCotizaciones", columnsdtRLCotizaciones);
  },
  onrowselectiondtRLCotizaciones: function (component, event, helper) {
    var selectedRowsdtRLCotizaciones = event.getParam("selectedRows");
    if (
      selectedRowsdtRLCotizaciones != null &&
      selectedRowsdtRLCotizaciones != undefined &&
      selectedRowsdtRLCotizaciones.length > 0
    ) {
      component.set(
        "v.idCotizacionSeleccionado",
        selectedRowsdtRLCotizaciones[0].idCotizacion
      );
      component.set("v.idPDF", selectedRowsdtRLCotizaciones[0].idPDF);
    } else {
      component.set("v.idCotizacionSeleccionado", null);
    }
  },
  sortdtRLCotizaciones:function(component, event, helper) {
    var sortedBydtRLCotizaciones = event.getParam('fieldName');        
    var sortDirectiondtRLCotizaciones = event.getParam('sortDirection');
    component.set("v.sortedBydtRLCotizaciones",sortedBydtRLCotizaciones);
    component.set("v.sortDirectiondtRLCotizaciones",sortDirectiondtRLCotizaciones);
    helper.sortdtRLCotizaciones(component, sortedBydtRLCotizaciones, sortDirectiondtRLCotizaciones);
  }
});