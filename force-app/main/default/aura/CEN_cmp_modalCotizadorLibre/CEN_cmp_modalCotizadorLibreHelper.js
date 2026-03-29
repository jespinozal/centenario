({
  showToast: function (component, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      mode: "dismissible",
      type: type,
      duration: 4000
    });
    toastEvent.fire();
  },

  getMonedaActualHelper: function(component, recordId){
    var action = component.get("c.getMonedaActual");
    action.setParams( { IdOportunidad: recordId } );
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") { 
        var dataResponse = response.getReturnValue();
        console.log('MONEDA OPP: ' + dataResponse);
        component.set("v.moneda", dataResponse);
      }
    });
    $A.enqueueAction(action);
  },

  getOppDataHelper: function(component, recordId){
    var action = component.get("c.getOppData");
    action.setParams( { IdOportunidad: recordId } );
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") { 
        var dataResponse = response.getReturnValue();
        console.log('PROFORMA' + dataResponse.CEN_Proforma__c);
        component.set("v.proforma", dataResponse.CEN_Proforma__c);
        component.set("v.tipoVenta", dataResponse.CEN_Tipo_de_venta__c);
      }
    });
    $A.enqueueAction(action);
  }

});