({
	chargeDoc : function(component) {
		var idoportunidad=component.get("v.OportunidadId");
        console.log("Record id Oportunidad: " + idoportunidad);
//        idoportunidad="0060v000006RmjmAAC";
		var action = component.get("c.getLastAttachDoc");
        action.setParams({
            "IdOportunidad": idoportunidad
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
                console.log('response from controller:' + res);
                if(res!=""){                    
                    component.set("v.BodyDocEmbed",res);
                    component.set("v.DocCargado",true);
                    window.open(res);
                }
            }
        });
        $A.enqueueAction(action);
	}
})