({
    showModal : function(component) {
        component.set("v.modalActivado", "true");
    },
    hideModal : function(component){
        component.set("v.modalActivado", "false");
    },
    showMesagge : function(component, msg){
        component.set("v.txtMesagge", msg);
        component.set("v.mesaggeActivado", "true");
    },
    callMessage : function(data){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: data.title,
            type: data.messagetype,
            message: data.message,
            messageTemplate: data.messageTemplate,
            messageTemplateData: [data.messageTempData]
        });
        toastEvent.fire();
    },
    errorMessageText : function(errorMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Error',
            type: 'error',
            message: errorMessage
        });
        toastEvent.fire();
    },
    infoMessageText : function(infoMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: 'info',
            message: infoMessage
        });
        toastEvent.fire();
    },
    openConfirm: function(component, event, helper, message) {

        this.LightningConfirm.open({
            message: message,
            theme: 'warning',
            label: 'Confirmación',
        }).then(function(result) {
            // result is true if clicked "OK"
            // result is false if clicked "Cancel"
            console.log('confirm result is', result);
            if(result){
                //guardar
                console.log('guardar');
                return helper.btnSaveConfirmation(component, helper);
            }
        });

    },
    btnSaveConfirmation: function(component, helper){
        component.set("v.isLoading", "true");
        var selectedCount = component.get('v.selectedRowsCount');
        var selectedRows = component.get('v.selectedRowsDetails');
        if(selectedCount > 0){
            var action = component.get("c.generatePaymentOrder");
            action.setParams({oppId : component.get("v.recordId"),
                                jsonString : component.get("v.selectedRowsDetails")});
            $A.enqueueAction(action);
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var vData = response.getReturnValue();
                    if(vData.msgResponse.messagetype != 'warning'){
                        component.set('v.columnsSuccess', [
                            {label: 'Anticipo', fieldName: 'BELNR', type: 'text', initialWidth: 100},
                            {label: 'Importe anticipo', fieldName: 'WRBTR', type: 'text', initialWidth: 100},
                            {label: 'Estado', fieldName: 'status', type: 'text', initialWidth: 100, "cellAttributes": {
                                "class": {
                                    "fieldName": "showClass"
                                }
                            }},
                            {label: 'Detalle', fieldName: 'detail', type: 'text'},
                            { type: 'action', typeAttributes: { rowActions: { fieldName: "rowActions" } } }
                        ]);
                        helper.showMesagge(component, vData.msgResponse.message);
                        var records = vData.lstPaymentOrder;
                        records.forEach(function(record){
                            record.showClass = record.status;
                            record.rowActions = [{label:'Ir a Orden de Pago',name:'show_details'}];    
                            if(record.status == 'Error'){
                                record.rowActions = [{label:'Reportar al Administrador',name:'report_error'}];    
                            }
                        });
                        component.set('v.dataSuccess', records);
                        helper.callMessage(vData.msgResponse);
                        helper.hideModal(component);
                        component.set("v.dataSuccessActivado", "true");
                    }else{
                        helper.callMessage(vData.msgResponse);
                    }
                }else{
                    helper.showMesagge(component,"Error al generar ordenes de pago, por favor contactar al administrador.");
                    helper.errorMessageText('Error al generar ordenes de pago, por favor contactar al administrador.');
                    helper.hideModal(component);
                }
            });
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", "false");
        }else{
            helper.infoMessageText("Por favor seleccionar al menos un anticipo de la lista.");
            component.set("v.isLoading", "false");
        }
    }
})