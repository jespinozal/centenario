({
  doInit: function (component, event, helper) {
    helper.getData(component);
  },
  forceRefreshViewHandler: function (component, event, helper) {
    console.log("El registro fue actualizado");
    helper.getData(component);
  },
  abrirOnbase: function (component, event, helper) {
    var ID = component.get("v.recordId");
    helper.showAlert(
      "Se está obteniendo los datos para abrir OnBase",
      "info",
      10000
    );
    var action1 = component.get("c.abrirSolicitud_en_OnBase");
    action1.setParams({
      OportunidadId: ID
    });
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();
        console.log(JSON.stringify(oRes));
        if (oRes.estado == "OK") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            mode: "dismissible",
            type: "success",
            duration: 10000,
            message: "Ver la solicitud",
            messageTemplate: "Ver en OnBase la {0} Nro {1} {2}!",
            messageTemplateData: [
              oRes.oportunidad.CEN_Tipo_de_solicitud__c,
              oRes.oportunidad.CEN_Nro_solicitud_presolicitud__c,
              { url: oRes.url, label: "aquí" }
            ]
          });
          toastEvent.fire();
          window.open(oRes.url);
        } else {
          helper.showAlert(oRes.mensaje, "error", 15000);
        }
      } else if (state === "INCOMPLETE") {
        helper.showAlert(
          "Hubo un problema. Intentelo otra vez.",
          "error",
          5000
        );
      } else if (state === "ERROR") {
        helper.showAlert(
          "Hubo un problema. Intentelo otra vez.",
          "error",
          5000
        );
        var errors = response.getError();
        if (errors) {
          console.error(error);
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action1);
  },
  enviarAonBase: function (component, event, helper) {
    helper.showAlert("Se está enviando los datos a OnBase", "info", 10000);
    var ID = component.get("v.recordId");
    var btn_crear = component.find("btn_crear_solicitud");
    component.set("v.btnDisabled", true);
    var action1 = component.get("c.enviarOportunidad_a_OnBase");
    action1.setParams({
      OportunidadId: ID
    });
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();
        console.log(JSON.stringify(oRes));
        if (oRes.estado == "OK") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            mode: "dismissible",
            type: "success",
            duration: 10000,
            message: "Ver la solicitud",
            messageTemplate: oRes.mensaje + ". Ver la {0} Nro {1} {2}!",
            messageTemplateData: [
              oRes.oportunidad.CEN_Tipo_de_solicitud__c,
              oRes.oportunidad.CEN_Nro_solicitud_presolicitud__c,
              { url: oRes.url, label: "aquí" }
            ]
          });
          toastEvent.fire();
          component.set("v.oportunidad", oRes.oportunidad);
          component.set("v.existeSolicitudEnOnbase", true);
          //helper.showAlert(oRes.mensaje,'success', 5000);
          window.open(oRes.url);
          component.set("v.btnDisabled", false);
          $A.get("e.force:refreshView").fire();
        } else {
          if(oRes.faltanCampos){
            component.set("v.faltanCampos",oRes.faltanCampos);
            component.set("v.errorListaFaltanCampos",oRes.listaFaltantes);
          }
          helper.showAlert(oRes.mensaje, "error", 15000);
          component.set("v.btnDisabled", false);
          console.log(oRes.detalle);
        }
      } else if (state === "INCOMPLETE") {
        helper.showAlert(
          "Hubo un problema. Intentelo otra vez.",
          "error",
          5000
        );
      } else if (state === "ERROR") {
        helper.showAlert(
          "Hubo un problema. Intentelo otra vez.",
          "error",
          5000
        );
        var errors = response.getError();
        if (errors) {
          console.error(error);
        } else {
          console.log("Unknown error");
        }
      }
      component.set("v.btnDisabled", false);
    });
    $A.enqueueAction(action1);
  },
  handleMenuSelect: function (component, event, helper) {
    var selectedMenuItemValue = event.getParam("value");
    console.log("selectedMenuItemValue: " + selectedMenuItemValue);
    if (selectedMenuItemValue == "1") {
      helper.abrirDocumentosOnbase(component, event, helper);
    } else if (selectedMenuItemValue == "2") {
      helper.abrirOnbaseWeb(component, event, helper);
    }
  },
  onclickActualizarSolicitudOnbase: function (component, event, helper) {
    helper.enviarActualizacion(component, event, helper);
  },
  closeModal: function(component, event, helper){
    component.set("v.faltanCampos",false);
    component.set("v.errorListaFaltanCampos",null);
  }
});