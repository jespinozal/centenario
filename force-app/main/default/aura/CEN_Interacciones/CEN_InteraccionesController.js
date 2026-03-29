({
	doInit : function(component, event, helper) {
        helper.updateDataConsult(component, event, helper);
  	},
    AbrirModal: function(component, event, helper) {
        component.set("v.isModal", true);
        
        var gestionar_div = component.find("gestion-div");
        $A.util.addClass(gestionar_div, 'slds-hide');
        $A.util.removeClass(gestionar_div, 'slds-show');
    },
    Gestionar: function(component, event, helper) {
        console.log('Decidio gestionar');
        
        var modal = component.find("modal-container-msg");
        $A.util.addClass(modal, 'slds-hide');
        $A.util.removeClass(modal, 'slds-show');
        
        var dc_no_gestionar = component.find("dc-no-gestionar");
        $A.util.addClass(dc_no_gestionar, 'slds-hide');
        $A.util.removeClass(dc_no_gestionar, 'slds-show');
        
        var dc_gestionar = component.find("dc-gestionar");
        $A.util.addClass(dc_gestionar, 'slds-show');
        $A.util.removeClass(dc_gestionar, 'slds-hide');
        
        var NombreRegistrado = component.find("NombreRegistradoL");
        var ApellidoRegistrado = component.find("ApellidoRegistradoL");
        var DireccionRegistrado = component.find("DireccionRegistradoL");
        var CelularRegistrado = component.find("CelularRegistradoL");
        var CorreoRegistrado = component.find("CorreoRegistradoL");
        var DistritoRegistrado = component.find("DistritoRegistradoL");
        var caseRecord=component.get("v.caseRecord");
        if(caseRecord.Contact.FirstName!=caseRecord.CEN_nombre_actualizado__c){
            $A.util.addClass(NombreRegistrado, "changedColor");
        }
        if(caseRecord.Contact.LastName!=caseRecord.CEN_apellido_actualizado__c){
            $A.util.addClass(ApellidoRegistrado, "changedColor");
        }
        if(caseRecord.Contact.CEN_Distrito__c!=caseRecord.CEN_distrito_actualizado__c){
            $A.util.addClass(DistritoRegistrado, "changedColor");
        }
        if(caseRecord.Contact.CEN_Direccion__c!=caseRecord.CEN_direccion_actualizado__c){
            $A.util.addClass(DireccionRegistrado, "changedColor");
        }
        if(caseRecord.Contact.Phone!=caseRecord.CEN_celular_actualizado__c){
            $A.util.addClass(CelularRegistrado, "changedColor");
        }
        if(caseRecord.Contact.Email!=caseRecord.correo_actualizado__c){
            $A.util.addClass(CorreoRegistrado, "changedColor");
        }
  	},
    NoGestionar: function(component, event, helper) {
        console.log('Decidio no gestionar');
        
        var modal = component.find("modal-container-msg");
        $A.util.addClass(modal, 'slds-hide');
        $A.util.removeClass(modal, 'slds-show');
        
        var dc_gestionar = component.find("dc-gestionar");
        $A.util.addClass(dc_gestionar, 'slds-hide');
        $A.util.removeClass(dc_gestionar, 'slds-show');
        
        var dc_no_gestionar = component.find("dc-no-gestionar");
        $A.util.addClass(dc_no_gestionar, 'slds-show');
        $A.util.removeClass(dc_no_gestionar, 'slds-hide');
        
    },
    guardarObservacion: function(component, event, helper) {
        var recordId=component.get("v.recordId");
        
        var observacion = component.get("v.observacion");
        console.log('observacion: '+observacion);
        if(observacion){
            var action = component.get("c.noGestionar");
            action.setParams({
                "caseId": recordId,
                "observacion":observacion
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var status = response.getReturnValue();
                    if(status=='OK'){
                        component.set("v.isModal", false);
                        $A.get('e.force:refreshView').fire();
                    }else{
                        console.log('status: '+status);
                    }
                }else{
                    console.log('state: '+state);
                }});
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'La observación es requerido',
                                type : 'error'
                            });
                            toastEvent.fire();
        }
  	},
    closeModelDoc: function(component, event, helper) {
        //for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        
        component.set("v.isModal", false);
        
        //window.location.reload()
  	},
    actualizarDatos:function(component, event, helper) {
        var recordId=component.get("v.recordId");
        var distrito = component.get("v.selectedLookUpRecord");
        var NombreRegistrado = component.find("NombreRegistrado").get("v.value");
        var ApellidoRegistrado = component.find("ApellidoRegistrado").get("v.value");
        var CorreoRegistrado = component.find("CorreoRegistrado").get("v.value");
        var CelularRegistrado = component.find("CelularRegistrado").get("v.value");
        var DireccionRegistrado = component.find("DireccionRegistrado").get("v.value");
        console.log("---Actualizar datos--- \nrecordId: "+recordId+"\nNombreRegistrado: "+NombreRegistrado+
                    "\nApellidoRegistrado: "+ApellidoRegistrado+"\nCorreoRegistrado: "+CorreoRegistrado+"\nCelularRegistrado: "+CelularRegistrado+
                    "\nDireccionRegistrado: "+DireccionRegistrado+"\nDistrito: "+JSON.stringify(distrito));
        if(NombreRegistrado&&ApellidoRegistrado&&CelularRegistrado&&DireccionRegistrado&&distrito.Id){
            var action = component.get("c.actualizarDatosCliente");
            action.setParams({
                "caseId": recordId,
                "distritoId": distrito.Id,
                "nombre": NombreRegistrado,
                "apellido": ApellidoRegistrado,
                "correo": CorreoRegistrado,
                "celular": CelularRegistrado,
                "direccion": DireccionRegistrado
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var response = response.getReturnValue();
                    console.log(JSON.stringify(response));
                    if(response.estado=='OK'){
                        component.set("v.isModal", false);
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'dismissible',
                                duration: 5000,
                                message: response.mensaje,
                                type : 'success',
                                messageTemplate: 'Se creó la sub interacción. {1}!',
                                messageTemplateData: [response.newcase.CaseNumber, {
                                    url: '/lightning/r/Case/'+response.newcase.Id+'/view',
                                    label: 'Ver'
                                }]
                            });
                            toastEvent.fire();
                        //window.open('/lightning/r/Case/'+response.newcase.Id+'/view');
                        $A.get('e.force:refreshView').fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: response.mensaje,
                                type : 'error'
                            });
                            toastEvent.fire();
                    }
                }});
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Nombres, Apellidos, Dirección, Distrito y Celular no pueden estar vacíos.',
                type : 'error'
            });
            toastEvent.fire();
        }
  	},
    forceRefreshViewHandler:function(component, event, helper) {
        console.log("El registro fue actualizado");
        helper.updateDataConsult(component, event, helper);
    },
    postergar:function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'dismissible',
                message: 'Esta postergando la gestión de Actualización de datos, no podrá cambiar el estado de la Interacción a "Atendido" o "Cerrado" a menos que se gestione.',
                type : 'error',
                duration: 10000
            });
            toastEvent.fire();
        
        var caseRecord = component.get("v.caseRecord");
        if(caseRecord.CEN_flag_postergar_gestion__c==false){
            helper.postergarHelper(component, event, true);
        }
        var gestionar_div = component.find("gestion-div");
        $A.util.addClass(gestionar_div, 'slds-show');
        $A.util.removeClass(gestionar_div, 'slds-hide');
        helper.updateDataConsult(component, event, helper);
    }
})