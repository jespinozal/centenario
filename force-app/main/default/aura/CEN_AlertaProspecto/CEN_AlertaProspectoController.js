({
    doInit: function(component, event, helper) {

        
        
		var action = component.get('c.getAlertasProspecto');
		var ID = component.get('v.recordId');
        var object = component.get('v.sobjecttype');
        
        console.log('Nombre'+object);

  		action.setParams({ 
					 "idCliente": ID,
            		"objname": object,
		});
			action.setCallback(this, function(response) 
			{
					var state = response.getState();
					if (state === "SUCCESS") 
					{
							var storeResponse = response.getReturnValue();
              component.set('v.sMensajeAlerta',storeResponse);
              
							var a = component.get('c.showToast');
							$A.enqueueAction(a);
					}
      });
      	$A.enqueueAction(action);
			 
		},

	 showToast : function(component,event, helper) {

			var sMsg = component.get('v.sMensajeAlerta'); 

			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
					mode: 'pester',
					message: sMsg,
					type : 'error'
			});
			toastEvent.fire();
	}
})