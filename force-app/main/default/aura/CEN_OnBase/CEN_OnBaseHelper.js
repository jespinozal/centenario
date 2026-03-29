({
  getData: function (component) {
    var ID = component.get("v.recordId");
    var action1 = component.get("c.validarDatosDeOnbase");
    action1.setParams({
      OportunidadId: ID
    });
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();
        console.log("solicitud tiene dato de onbase...: " + oRes);
        if (oRes) {
          component.set("v.existeSolicitudEnOnbase", oRes.esSolicitudOnbase);
          component.set("v.estadoPreliminar", oRes.etapaEsPreliminar);
          component.set("v.oportunidad", oRes.oportunidad);
          component.set("v.estadoFinalizado", oRes.estadoFinalizado);
          component.set("v.isVisible", oRes.isVisible);
          console.log("Visible: " + oRes.isVisible);
          
        }
      } else {
        this.showAlert(
          "Hubo un problema. Intententelo otra vez.",
          "error",
          5000
        );
      }
    });
    $A.enqueueAction(action1);
  },
  showAlert: function (message, type, duration) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "dismissible",
      duration: duration,
      message: message,
      type: type
    });
    toastEvent.fire();
  },
  abrirDocumentosOnbase: function (component, event, helper) {
    helper.showAlert("Se está conectando a OnBase", "info", 10000);
    var ID = component.get("v.recordId");
    var action1 = component.get("c.abrirDocumentos_en_Onbase");
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
            message: "Ver documentos en Onbase",
            messageTemplate: "Ver los documentos de la {0} Nro {1} {2}!",
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
      } else {
        helper.showAlert(
          "Hubo un problema. Intententelo otra vez.",
          "error",
          5000
        );
        component.set("v.btnDisabled", false);
      }
    });
    $A.enqueueAction(action1);
  },
  abrirOnbaseWeb: function (component, event, helper) {
    var res = $A.get("$Label.c.CEN_url_bandeja_onbase");
    var appOnBase = $A.get("$Label.c.CEN_lbl_rutaAppOnbase");
    window.open(res + appOnBase, "_blank");
  },
  enviarActualizacion: function (component, event, helper) {
    helper.showAlert("Se está enviando los datos a OnBase", "info", 10000);
    var ID = component.get("v.recordId");
    var action1 = component.get("c.enviarActualizacionSolicitudOnbase");
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
          window.open(oRes.url);
          $A.get("e.force:refreshView").fire();
        } else {
          if(oRes.faltanCampos){
            component.set("v.faltanCampos",oRes.faltanCampos);
            component.set("v.errorListaFaltanCampos",oRes.listaFaltantes);
          }
          helper.showAlert(oRes.mensaje, "error", 15000);
          component.set("v.btnDisabled", false);
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
  }
});