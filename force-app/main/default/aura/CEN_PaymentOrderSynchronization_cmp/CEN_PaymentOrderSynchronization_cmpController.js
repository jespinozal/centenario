({
    doInit: function (component, event, helper) {
        console.log('***doInit****');
        //callOperactionSafe
        var actOperSafe = component.get("c.callOperactionSafe");
        actOperSafe.setParams({ oppId : component.get("v.recordId")});
        $A.enqueueAction(actOperSafe);
        actOperSafe.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var respOperSafe = response.getReturnValue();
                if(respOperSafe.message != null){
                    helper.callMessage(respOperSafe); 
                }
            }else{
                helper.errorMessageText('Error tecnico en el proceso de operación segura.');
            }
            //getAdvanceList
            console.log('***getAdvanceList****');
            var action = component.get("c.getAdvanceList");
            action.setParams({ oppId : component.get("v.recordId")});
            $A.enqueueAction(action);
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.columns', [
                        {label: 'Anticipo', fieldName: 'BELNR', type: 'text'},
                        {label: 'Ejercicio', fieldName: 'GJAHR', type: 'text'},
                        {label: 'Importe anticipo', fieldName: 'WRBTR', type: 'text'},
                        {label: 'Moneda', fieldName: 'WAERS', type: 'text'},
                        {label: 'Sociedad', fieldName: 'BUKRS', type: 'text'},
                        {label: 'Fecha de contabilización', fieldName: 'BUDAT', type: 'text'},
                        {label: 'Estado', fieldName: 'status', type: 'text', "cellAttributes": {
                            "class": {
                                "fieldName": "showClass"
                            }
                        }}
                    ]);
                    var vData = response.getReturnValue();
                    if(vData.strAdvanceList != null){
                        var records = vData.strAdvanceList;
                        records.forEach(function(record){
                            record.showClass = record.status;
                        });
                        component.set('v.respWrapAccount',vData.wAccountData);
                        component.set('v.society',vData.wAccountData.societyNumber)
                        component.set('v.data',records);
                        helper.showModal(component);
                    }else{
                        helper.callUpdateChange(component, helper);
                        helper.hideModal(component);
                    }
                }else{
                    helper.errorMessageText('Error al intentar obtener la lista de Anticipos en SAP');
                    helper.callUpdateChange(component, helper);
                    helper.hideModal(component);
                }
                component.set("v.isLoading", "false");
            });
        });  
    },
    btnSave : function(component, event, helper) {
        console.log('***btnSave****');
        var selectedRows = component.get('v.selectedRowsDetails');
        var sociedad = component.get('v.society');
        var json = JSON.parse(selectedRows);
       
        let obj =[] ;
        for (var i = 0; i < json.length; i++) {
            if(json[i].BUKRS != sociedad){
                obj.push({BELNR:json[i].BELNR,BUKRS:json[i].BUKRS});
            }
        }

        if(obj.length>0){
            var message = 'Se han seleccionado anticipos con una sociedad diferente, esta seguro de de continuar con el registro de anticipos';
            //obj.forEach(element => message1 += element.BELNR + ' ' + element.BUKRS);
            helper.openConfirm(component, event, helper, message);            
        }else{

            helper.btnSaveConfirmation(component, helper);
            // component.set("v.isLoadingModal", "true");
            // var selectedCount = component.get('v.selectedRowsCount');
            // var selectedRows = component.get('v.selectedRowsDetails');
            // if(selectedCount > 0){
            //     var action = component.get("c.generatePaymentOrder");
            //     action.setParams({oppId : component.get("v.recordId"),
            //                       jsonString : component.get("v.selectedRowsDetails")});
            //     $A.enqueueAction(action);
            //     action.setCallback(this, function(response){
            //         var state = response.getState();
            //         if (state === "SUCCESS") {
            //             var vData = response.getReturnValue();
            //             if(vData.msgResponse.messagetype == 'info'){
            //                 component.set('v.columnsSuccess', [
            //                     {label: 'Anticipo', fieldName: 'BELNR', type: 'text', initialWidth: 100},
            //                     {label: 'Importe anticipo', fieldName: 'WRBTR', type: 'text', initialWidth: 100},
            //                     {label: 'Estado', fieldName: 'status', type: 'text', initialWidth: 100, "cellAttributes": {
            //                         "class": {
            //                             "fieldName": "showClass"
            //                         }
            //                     }},
            //                     {label: 'Detalle', fieldName: 'detail', type: 'text'},
            //                     { type: 'action', typeAttributes: { rowActions: { fieldName: "rowActions" } } }
            //                 ]);
            //                 component.set("v.txtMesagge", vData.msgResponse.message);
            //                 var records = vData.lstPaymentOrder;
            //                 records.forEach(function(record){
            //                     record.showClass = record.status;
            //                     record.rowActions = [{label:'Ir a Orden de Pago',name:'show_details'}];    
            //                     if(record.status == 'Error'){
            //                         record.rowActions = [{label:'Reportar al Administrador',name:'report_error'}];    
            //                     }
            //                 });
            //                 component.set('v.dataSuccess', records);
            //                 helper.callMessage(vData.msgResponse);
            //                 helper.hideTable(component);
            //             }else{
            //                 helper.callMessage(vData.msgResponse);
            //             }
            //             component.set("v.isLoadingModal", "false");
            //         }else{
            //             component.set("v.txtMesagge", "Error al generar ordenes de pago, por favor contactar al administrador.");
            //             helper.errorMessageText('Error al generar ordenes de pago, por favor contactar al administrador.');
            //             helper.hideTable(component);
            //             component.set("v.isLoadingModal", "false");
            //         }
            //     });
            // }else{
            //     helper.infoMessageText("Por favor seleccionar al menos un anticipo de la lista.");
            //     component.set("v.isLoadingModal", "false");
            // }
        }
    },
    btnCancel : function(component,event, helper){
        helper.callUpdateChange(component, helper);
        helper.hideModal(component);
    },
    btnDone: function(component, event, helper){
        helper.callUpdateChange(component, helper);
        helper.hideModal(component);
        $A.get('e.force:refreshView').fire();
    },
    handleSelectedRow: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');  
        component.set("v.selectedRowsCount", selectedRows.length);
        component.set("v.selectedRowsDetails", JSON.stringify(selectedRows));
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'show_details':
                window.open('/'+row.idPaymentOrder);
                break;
            case 'report_error':
                var action = component.get("c.sendEmailReportAdmin");
                action.setParams({ 	sbody : JSON.stringify(row)});
                $A.enqueueAction(action);
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var vData = response.getReturnValue();
                        helper.callMessage(vData);
                    }else{
                        helper.errorMessageText('Error al intentar enviar email.');
                    }
                });
                break;
        }
    }
})