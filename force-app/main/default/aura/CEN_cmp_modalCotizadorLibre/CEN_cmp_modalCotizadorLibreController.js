({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    console.log('estoy en el modal JS');
    helper.getMonedaActualHelper(component, recordId);
    helper.getOppDataHelper(component, recordId);
    if(recordId != null && recordId != undefined){
          var action = component.get("c.validateStageOpp");
          action.setParams({
            IdOportunidad: recordId
          });
          action.setCallback(this, function (response) {
            var state = response.getState();
              console.log(state + 'Estado de llamada');
              console.log('some problem'+response.getError());
            if (state === "SUCCESS") {
                console.log(response.getReturnValue() + 'respuesta del apex');
                if(response.getReturnValue()){
                    component.set("v.isVisible", true);
                    var idOportunidadGenerica = $A.get("$Label.c.CEN_lbl_idOportunidadGenerica");
              console.log("idOportunidadGenerica: " + idOportunidadGenerica);
              console.log("recordId: " + recordId);
              if (recordId != null && recordId != undefined) {
                  component.set("v.esCotizacionLibre", false);
                  component.set("v.IdOportunidad", recordId);
                    } else {
                      component.set("v.esCotizacionLibre", true);
                      component.set("v.IdOportunidad", idOportunidadGenerica);
                    }
                }else{
                    try {
                            helper.showToast(
                            component,
                            "Etapa no válida",
                            "Solo es posible cotizar en la etapa de COTIZACIÓN.",
                            "error"
                          );
                          $A.get("e.force:refreshView").fire();
                          $A.get("e.force:closeQuickAction").fire();
                        } catch (error) {
                          console.error(error);
                        }
                        component.set("v.modalActivado", !component.get("v.modalActivado"));
                }
        }
        });
          $A.enqueueAction(action);
    }else{
      component.set("v.isVisible", true);
                var idOportunidadGenerica = $A.get("$Label.c.CEN_lbl_idOportunidadGenerica");
          console.log("idOportunidadGenerica: " + idOportunidadGenerica);
          console.log("recordId: " + recordId);
          component.set("v.esCotizacionLibre", true);
                  component.set("v.IdOportunidad", idOportunidadGenerica);

    }
  },
  closeModal: function (component, event, helper) {
    // si es modal de un quickaction
    try {
      $A.get("e.force:refreshView").fire();
      $A.get("e.force:closeQuickAction").fire();
    } catch (error) {
      console.error(error);
    }
    component.set("v.modalActivado", !component.get("v.modalActivado"));
  },
  onClickContinuar: function (component, event, helper) {
    var lotesList = component.get("v.lotesList");
    // si esta en el ultimo page, terminar con generar el pdf y el registro de la cotizacion
    var pag1 = component.get("v.pag1");
    var pag2 = component.get("v.pag2");
    if (pag1 && lotesList && Array.isArray(lotesList) && lotesList.length > 0) {
      component.set("v.pag1", !component.get("v.pag1"));
      component.set("v.pag2", !component.get("v.pag2"));
    } else if (pag1) {
      helper.showToast(
        component,
        "Falta lotes",
        "Debe seleccionar por lo menos un lote.",
        "error"
      );
    } else if (pag2) {
      console.log("Terminar");
    }
  },
  onClickAnterior: function (component, event, helper) {
    var pag1 = component.get("v.pag1");
    var pag2 = component.get("v.pag2");
    var pag3 = component.get("v.pag3");
    if (pag1) {
      pag1 = true;
      pag2 = false;
      pag3 = false;
    }
    if (pag2) {
      pag1 = true;
      pag2 = false;
      pag3 = false;
    }
    if (pag3) {
      pag1 = false;
      pag2 = true;
      pag3 = false;
      component.set("v.idRegistroCotizacion", null);
      component.set("v.pdfCotizacionId", null);
      component.set("v.pdfCotizacionBlob", null);
    }
    component.set("v.pag1", pag1);
    component.set("v.pag2", pag2);
    component.set("v.pag3", pag3);
  },
  onClickGenerarCotizacion: function (component, event, helper) {
    var flagGenerarCotizacion = component.get("v.flagGenerarCotizacion");
    if (flagGenerarCotizacion == false) {
      component.set("v.pdfCotizacionId", null);
      component.set("v.flagGenerarCotizacion", true);
    }
  },
  onClickCalcular: function (component, event, helper) {
    var flagCalcularCotizacion = component.get("v.flagCalcularCotizacion");
    if (!flagCalcularCotizacion) {
      component.set("v.flagCalcularCotizacion", true);
    }

  },
  onClickGestionDescuento: function (component, event, helper) {
    var flagCalcularDescuento = component.get("v.flagCalcularDescuento");
    var flagCalcularCotizacion = component.get("v.flagCalcularCotizacion");

    //if (!flagCalcularCotizacion && !flagCalcularDescuento) {
    if (!flagCalcularCotizacion) {
      component.set("v.flagCalcularCotizacion", true);
      component.set("v.flagCalcularDescuento", true);
    }

  }
});