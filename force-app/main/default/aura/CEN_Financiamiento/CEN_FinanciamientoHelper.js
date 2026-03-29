({
  getDetalleDelFinanciamiento: function(component, event, proforma, version) {
        var action = component.get("c.getDetalleFinanciamiento");
        action.setParams({
            "proforma": proforma,
            "version": version
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var detalle = response.getReturnValue();
            console.log("detalle: " + JSON.stringify(detalle));
            if (detalle) {                               
                component.set("v.proformaDetalles", detalle);
            }
          }
        });
        $A.enqueueAction(action);
  },
  setUpdateOfFinancing: function(component, event, req) {
    var action = component.get("c.setUpdateFinancing");
    var tipo = '';
    action.setParams(req);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        //console.log("resp: " + JSON.stringify(resp));
        if (resp) {                               
            component.set("v.resp", resp);
            if(resp['estado'] === 'E'){
              tipo = 'error';
            }
            else if(resp['estado'] === 'S'){
              tipo = 'success';
            }

            this.showToast(
              component,
              "Financiamiento",
              resp['mensaje'],
              tipo
            );

            component.set("v.loaded", true);
        }
      }
      else if (state === "INCOMPLETE") {
          // do something
          console.log("Error message: " + 
                          "INCOMPLETE");
          component.set("v.loaded", false);                
      }
      else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
              if (errors[0] && errors[0].message) {
                  console.log("Error message: " + 
                          errors[0].message);
                  this.showToast(
                    component,
                    "Error",
                    errors[0].message,
                    "error"
                  );        
              }
          } else {
              console.log("Unknown error");
          }

          component.set("v.loaded", false);                
      }

    });
    $A.enqueueAction(action);
  },
  showToast: function (component, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      mode: "dismissible",
      type: type,
      duration: 6000
    });
    toastEvent.fire();
  },
})