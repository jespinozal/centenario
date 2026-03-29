({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    console.log('estoy en el modal JS');
    var action = component.get("c.validateStageNameOpp");
    action.setParams({IdOportunidad: recordId });
      console.log("recordId: " + recordId);
    action.setCallback(this, function (response) {
          var state = response.getState();
          console.log(state + 'Estado de llamada');
          console.log('some problem'+response.getError());
        if (state === "SUCCESS") {
            console.log(response.getReturnValue() + 'respuesta del apex');
            if(response.getReturnValue()){
                component.set("v.isVisible", true);
                component.set("v.idOportunidad", recordId);
                helper.obtenerTiposDocumentoCotizacion(component);
                helper.obtenerDatosPersonaOportunidad(component);
                var planillaPDFcotizadorEndpoint = $A.get("$Label.c.CEN_lbl_planillaPDFcotizador");
                component.set("v.planillaPDFcotizadorEndpoint",planillaPDFcotizadorEndpoint);
                console.log("idOportunidadGenerica: " + idOportunidadGenerica);
    			console.log("recordId: " + recordId);
            }else{
                try {
                        helper.showToast(
                        component,
                        "Etapa no válida",
                        "Solo es posible cotizar en la etapa de COTIZACIÓN.",
                        "error"
                      );
                     // $A.get("e.force:refreshView").fire();
                      $A.get("e.force:closeQuickAction").fire();
                    } catch (error) {
                      console.error(error);
                    }
                    //component.set("v.modalActivado", !component.get("v.modalActivado"));
            }
        }
      })
    $A.enqueueAction(action);
    
  },
  onclickClose: function (component, event, helper) {
    try {
      $A.get("e.force:refreshView").fire();
      $A.get("e.force:closeQuickAction").fire();
    } catch (error) {
      console.error(error);
    }
  },
  onclickAnterior: function (component, event, helper) {
    component.set("v.page1", !component.get("v.page1"));
    component.set("v.page2", !component.get("v.page2"));
  },
  onclickSiguiente: function (component, event, helper) {
    component.set("v.page1", !component.get("v.page1"));
    component.set("v.page2", !component.get("v.page2"));
  },
  handleAccionRecibida: function (component, event, helper) {
    var action = event.getParam("action");
    if (action == "onclickBuscar") {
      var objInputBuscador = component.get("v.objInputBuscador");
      helper.buscarCotizacionesLibres(component, objInputBuscador);
    } else if (action == "onclickLimpiarFiltros") {
      helper.onclickLimpiarFiltros(component);
    }
  },
  onclickAsociarCotizacion: function (component, event, helper) {
    component.set("v.asociandoCotizacion", true);
    var idCotizacionSeleccionado = component.get("v.idCotizacionSeleccionado");
    var idOportunidad = component.get("v.idOportunidad");
    if (!idOportunidad) {
      helper.showToast(
        component,
        "Error",
        "Id de oportunidad no identificada",
        "error"
      );
      component.set("v.asociandoCotizacion", false);
      return;
    }
    if (!idCotizacionSeleccionado) {
      helper.showToast(
        component,
        "Error",
        "Id de cotización no identificada",
        "error"
      );
      component.set("v.asociandoCotizacion", false);
      return;
    }
    helper.procesarAsociacion(
      component,
      idCotizacionSeleccionado,
      idOportunidad
    );
  }
});