({
    updateDataConsult: function(component, event, helper) {
        var recordId=component.get("v.recordId");
        var action = component.get("c.getCaseById");
  		action.setParams({
            "caseId": recordId  
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var caseRecord = response.getReturnValue();
                console.log('Case data: '+JSON.stringify(caseRecord));
                if(caseRecord&&caseRecord.CEN_Actualizar_Datos__c&&(caseRecord.Status=='En proceso'||caseRecord.Status=='Atendido')){                    
                    console.log('Account data: '+JSON.stringify(caseRecord.Account));
                    component.set("v.caseRecord", caseRecord);
                    if(caseRecord.CEN_flag_postergar_gestion__c==true){
                        component.set("v.isModal", false);
                    }else{
                        component.set("v.isModal", true);
                    }
                    helper.searchDistrito(component, event, caseRecord);
                }
            }});
      	$A.enqueueAction(action);
    },
	searchDistrito: function(component, event, caseRecord){
        console.log('caseRecord: '+caseRecord);
        if(caseRecord!=null&&caseRecord.CEN_distrito_actualizado__c){
            var action = component.get("c.buscarDistritobyId");
            action.setParams({
                "distritoId": caseRecord.CEN_distrito_actualizado__c
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('oRes: '+JSON.stringify(oRes));
                    if(oRes){
                        component.set("v.selectedLookUpRecord", oRes);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    postergarHelper:function(component, event, status) {
        var recordId=component.get("v.recordId");
        var action = component.get("c.postergarCase");
  		action.setParams({
            "caseId": recordId,
            "status": status
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log(oRes);
                if(oRes==="ok"){
                    component.set("v.isModal",false);
                }
            }
        });
      	$A.enqueueAction(action);
    }
})