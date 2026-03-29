({
	showAlert : function(message, type, duration) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration: duration,
            message: message,
            type : type
        });
        toastEvent.fire();
	},
    getData: function(component){
        var ID = component.get('v.recordId');
		var action = component.get("c.GetDataCase");
  		action.setParams({ 
            "caseId": ID  
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('oRes: ' + JSON.stringify(oRes));
                if(oRes.estado=="OK"){
                    component.set("v.lotesDelCaso",oRes.lotesstr);
                    var options = [];
                    var value = "CN";                                        
                    if(oRes.caso&&oRes.caso.AccountId){
                        options.push({'label': oRes.caso.Account.Name+' - Cuenta', 'value': 'CN'});
                        value = "CN";
                    }
                    if(oRes.caso&&oRes.caso.ContactId){
                        if(oRes.caso&&oRes.caso.AccountId&&oRes.caso.Account.PersonContactId!=oRes.caso.ContactId){
                            options.push({'label': oRes.caso.Contact.Name+' - Contacto', 'value': 'CT'});                            
                        }
                        if(oRes.caso&&!oRes.caso.AccountId){
                            value = "CT";
                        }
                    }
                    options.push();                    
                    component.set("v.options",options);
                    component.set("v.value",value);
                    this.getLotes(component);
                }
            }
        });
      	$A.enqueueAction(action);
    },
    getLotes:function(component){
        var ID = component.get('v.recordId');
        var tipo = component.get("v.value");
        console.log("tipo: "+tipo);
		var action = component.get("c.BuscarLotesPorCasoTipoCliente");
  		action.setParams({ 
            "caseId": ID,
            "tipo": tipo
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('oRes: ' + JSON.stringify(oRes));
                if(oRes.estado=="OK"){
                    if(oRes.lotes || oRes.lotesstr){
                        var lotes = [];
                        if(oRes.lotes){
                            for(var i=0;i<oRes.lotes.length;i++){
                                lotes.push({"Name":oRes.lotes[i].Name,
                                            "Id":oRes.lotes[i].Id,
                                            "Url":oRes.lotes[i].Url,
                                            "Origen":"SAP"});
                            }
                        }
                        if(oRes.lotesstr){
                            for(var i=0;i<oRes.lotesstr.length;i++){
                                lotes.push({"Name":oRes.lotesstr[i].Name,
                                            "Id":oRes.lotesstr[i].Id,
                                            "Url":oRes.lotesstr[i].Url,
                                            "Origen":"Oracle"});
                            }
                        }
                        if(lotes.length>0){
                            component.set("v.lotesBuscados",lotes);
                            component.set("v.lotesBuscadosSize",lotes.length);
                        }
                    }                    
                }
            }
        });
      	$A.enqueueAction(action);
    },
})