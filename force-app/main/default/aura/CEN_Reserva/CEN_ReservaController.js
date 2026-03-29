({
	Prueba: function(component, event, helper) {
        component.set("v.btnDisabled",true);
		var ID = component.get('v.recordId');
        if(ID){
            component.set("v.btnDisabled",true);
        }else{
            ID = component.get('v.recordidentificador');
        }
        console.log('ID:' +ID);
		var action = component.get("c.getReserva");
  		action.setParams({ 
					 "ID": ID  
		});
			action.setCallback(this, function(response) 
			{
					var state = response.getState();
					if (state === "SUCCESS"){
                        var storeResponse = response.getReturnValue();
                        console.log('Finalizo');
                        console.log('mensaje: '+storeResponse.mensaje);
                        if(storeResponse.status.includes("error")){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: storeResponse.mensaje,
                                type : 'error'
                            });
                            toastEvent.fire();
                        }else{
                            component.set("v.isModaldoc", true);
                        	component.set("v.mensaje", storeResponse.mensaje);	
                        }                        	
                    }
                component.set("v.btnDisabled",false);
      });
      	$A.enqueueAction(action);
			 
		},
    
    closeModelDoc: function(component, event, helper) {
        //for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        //component.find("numero").set("v.value", "");
        var id = component.get("v.recordId");
        component.set("v.isModaldoc", false);
        $A.get('e.force:refreshView').fire();
        //window.location="/lightning/r/"+id+"/view"; 
        //window.location.reload()
  	},
    doInit:function(component, event, helper) {
        helper.getData(component);
    },
    forceRefreshViewHandler:function(component, event, helper) {
        helper.getData(component);
    },
    
    
    
    
    
    
    
    
    
})