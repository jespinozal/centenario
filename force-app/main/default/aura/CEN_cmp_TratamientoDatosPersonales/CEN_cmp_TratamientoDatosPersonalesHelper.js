({
    getAccountHelper: function (component, id) {
        var action = component.get("c.getAccount");
        action.setParams({
            'Id': id
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var respuesta = response.getReturnValue();
                //console.log(respuesta);
                component.set("v.Cuenta", respuesta);
                component.set("v.Valor1", respuesta.check1__c);
                component.find("CheckBox1").set("v.checked", respuesta.check1__c);
                component.set("v.Valor2", respuesta.check2__c);
                component.find("CheckBox2").set("v.checked", respuesta.check2__c);
                component.set("v.Valor3", respuesta.check3__c);
                component.find("CheckBox3").set("v.checked", respuesta.check3__c);
            }
        });
        $A.enqueueAction(action);
    },
    
	setPrivacidadHelper: function (component, accountId, check1, check2, check3, document) {
        var action = component.get("c.setPrivacidad");
        console.log('Prueba Helper: '+'AccountId: '+accountId+'|check1: '+check1+'|check2: '+check2+'|check3: '+check3+'|document: '+document);
        action.setParams({
            'id': accountId,
            'check1': check1,
            'check2': check2,
            'check3': check3,
            'document': document
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: response.getReturnValue(),
                    type : 'success'
                });
        		//toastEvent.fire("Se actualizo la privacidad de la cuenta.");
                window.location.reload(true)
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    attachHelper: function (component, id) {
        var action = component.get("c.attach");
        action.setParams({
            'cuentaId': id
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var respuesta = response.getReturnValue();
                //console.log(respuesta);
                component.set("v.Cuenta", respuesta);
            }
        });
        $A.enqueueAction(action);
    }
})