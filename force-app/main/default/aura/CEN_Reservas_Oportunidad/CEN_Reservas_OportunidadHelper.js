({
	getData : function(component) {
       
            var ID = component.get('v.recordId');
            var action1 = component.get("c.getOportunidad");
            action1.setParams({ 
                "idOportunidad": ID  
            });
            action1.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('response: ' + JSON.stringify(oRes));
                    if(oRes.estado=='OK'){
                        component.set("v.oportunidad",oRes.oportunidad);
                        if(oRes.loteDeOportunidad){
                            component.set("v.loteDeOportunidad",oRes.loteDeOportunidad);
                        }else{
                            component.set("v.loteDeOportunidad",null);
                        }
                        if(oRes.reserva){
                            component.set("v.reserva",oRes.reserva);
                        }else{
                            component.set("v.reserva",null);
                        }
                    }
                }
            });
            $A.enqueueAction(action1);
        
	},
    reservar:function(component) {
        component.set("v.btnDisabled",true);
        var oliid = component.get("v.loteDeOportunidad");
        console.log('loteDeOportunidad: ' + JSON.stringify(oliid));
            var action1 = component.get("c.reservarLotesDeOportunidad");
            action1.setParams({ 
                "oliid": oliid.Id
            });
            action1.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('response: ' + JSON.stringify(oRes));
                    if(oRes.estado=='OK'){
                        this.showAlert(oRes.mensaje,'success',5000);
                        if(oRes.reserva){
                            component.set("v.reserva",oRes.reserva);
                        }else{
                            component.set("v.reserva",null);
                        }
                        $A.get('e.force:refreshView').fire();
                    }else{
                        this.showAlert(oRes.mensaje,'error',5000);
                    }
                }else{
                    this.showAlert('Hubo un problema. Intentelo mas tarde.','error',5000);
                }
                component.set("v.btnDisabled",false);
            });
            $A.enqueueAction(action1);
    },
    showAlert : function(message, type, duration) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration: duration,
            message: message,
            type : type
        });
        toastEvent.fire();
	}
})