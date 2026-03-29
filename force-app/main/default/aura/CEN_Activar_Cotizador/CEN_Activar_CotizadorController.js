({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.validarOportunidad");
    action.setParams({
      opportunityId: recordId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();        
        if (data.ok) {
          for(var i in data.lotes){
            data.lotes[i].PrecioVentaDscto = data.lotes[i].Precioventafun;
          }
          component.set("v.lotesList", data.lotes);
          component.set("v.objProyectoSF",data.objProyectoSF);
          component.set("v.idProyectoSF",data.idProyectoSF);
          //  activar modal
          component.set("v.isModal", true);          
          component.set("v.modalActivado", true);
          component.set("v.page2",true);
        } else {
          component.set("v.lotesList", []);
          component.set("v.page2",false);
          component.set("v.modalActivado", false);
          component.set("v.isModal", false);
        }
      }
      else if (state === "ERROR") {
        var errors = response.getError();
        console.log(errors);
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            this.showAlert(errors[0].message, "error");
          }
        } else {
          console.log("Unknown error");
        }
        component.set("v.page2",false);
        component.set("v.modalActivado", false);
        component.set("v.isModal", false);
      }
    });
    //@ts-ignore
    $A.enqueueAction(action);
  },
  onchangeIsmodal: function (component, event, helper) {
    var modalActivado = component.get("v.modalActivado");
    var isModal = component.get("v.isModal");
    if (isModal && !modalActivado) {
      component.set("v.isModal", !isModal);
    }
  }
})