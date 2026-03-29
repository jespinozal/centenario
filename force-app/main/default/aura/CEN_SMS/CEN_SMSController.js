({
	doInit: function(component, event, helper) {

		var action = component.get('c.getSMS');
		var ID = component.get('v.recordId2');
        
        console.log('ID:' +ID),

  		action.setParams({
            "idCliente": ID
		});
			action.setCallback(this, function(response) 
			{
					var state = response.getState();
					if (state === "SUCCESS") 
					{
							var storeResponse = response.getReturnValue();
                        	console.log('Result '+storeResponse);
                        
                        if(storeResponse.result=='sendmessage')
                        {
                            var mensaje = 'El SMS fue enviado de manera correcta.';
                            component.set("v.resultado", mensaje);
                            component.set("v.mensaje", storeResponse.mensaje);
                            
                        }else{
                            var mensaje = 'El SMS no fue enviado de manera correcta.';
                            component.set("v.resultado", mensaje);
                            component.set("v.mensaje", storeResponse.mensaje);
                            
                        }   
                        
                        
					}
      });
      	$A.enqueueAction(action);
			 
		},
})