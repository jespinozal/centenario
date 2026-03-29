({
    Search: function(component, tipo, numero) {
        var tipo= tipo;
        console.log(tipo);
        var action = component.get("c.getselectDoc");
        action.setParams({
            "tipo": tipo ,
            "numero": numero ,
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log(allValues.Cuenta.length);
                console.log(allValues.Prospecto.length);
                
                if(allValues.Cuenta.length>0){
                    component.set("v.searchResult", allValues.Cuenta);
                    console.log("Es cliente");
                    component.set("v.isModaldoc", true);
                }else if(allValues.Prospecto.length>0){
                    console.log("Es prospecto");
                    component.set("v.searchResult", allValues.Prospecto);
                    component.set("v.isModaldoc", true);
                }else{
                    console.log("Entro");
                    /*<------USANDO RENIEC--------*/
                    var lead={ CEN_N_mero_de_documento__c: numero, CEN_Tipo_de_documento__c:tipo, Salutation: "Sr."};                        
                    if(tipo == "DNI" && numero && allValues.datos&&allValues.datos.Nombres&&allValues.datos.Apellidos){
                        lead={ CEN_N_mero_de_documento__c: numero, CEN_Tipo_de_documento__c:tipo, Salutation: "Sr.", FirstName:allValues.datos.Nombres, LastName:allValues.datos.Apellidos};
                    }
                    /*-------USANDO RENIEC------->*/
                    var createRecordEvent = $A.get("e.force:createRecord");
        			createRecordEvent.setParams({
                        "entityApiName": "Lead",
                        "defaultFieldValues": lead
                    });
                    createRecordEvent.fire();
                }
                
            }
        });
        $A.enqueueAction(action);
    },
})