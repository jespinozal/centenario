({
	getData : function(component) {
       
            var ID = component.get('v.recordId');
        if(!ID){
            ID = component.get('v.recordidentificador');
        }
        console.log('recordId:' +component.get('v.recordId'));
        console.log('recordidentificador:' +component.get('v.recordidentificador'));
            var action1 = component.get("c.validarDatos");
            action1.setParams({ 
                "Id": ID  
            });
            action1.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('reserva: ' + JSON.stringify(oRes));
                    if(oRes){
                        component.set("v.reserva",oRes);
                    }
                }
            });
            $A.enqueueAction(action1);
        
	}
})