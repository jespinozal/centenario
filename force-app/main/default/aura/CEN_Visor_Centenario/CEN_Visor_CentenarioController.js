({
	doInit : function(component, event, helper) {
        var ID = component.get('v.recordId');
        console.log('ID:' +ID);
        var msg1 = component.find("msg1");
        var msg2 = component.find("msg2");
        var msg3 = component.find("msg3");
        var msg0 = component.find("msg0");
        var msg = component.find("msg");
		var action = component.get("c.getData");
        action.setParams({
            "idOportunidad": ID  
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var sro = response.getReturnValue();
                console.log('sro: '+JSON.stringify(sro));
                if(sro.status=='OK'){
                    if(sro.oportunidad){
                        console.log(JSON.stringify(sro.oportunidad));
                        if(sro.endpoint!=""&&sro.endpoint&&sro.proyecto){
                                console.log(JSON.stringify(sro.proyecto));
                                component.set("v.nombreProyecto",sro.proyecto.Name);
                                component.set("v.existeProyecto",true);
                                console.log(sro.endpoint);
                                window.open(sro.endpoint);
                        }                    
                    }
                }
                 component.set("v.mensaje",sro.status + ': ' +sro.mensaje);
                    $A.util.addClass(msg, 'slds-show');
                    $A.util.removeClass(msg, 'slds-hide');
                    $A.util.addClass(msg0, 'slds-hide');
            }
        });
        $A.enqueueAction(action);
	}
})