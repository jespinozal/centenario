({
	doInit : function(component, event, helper) {       
		helper.getData(component);
	},
    onrowselection:function (component, event, helper) {
         var selectedRows = event.getParam('selectedRows');
        console.log('lotes: '+JSON.stringify(selectedRows));
        component.set('v.lotesSeleccionado',selectedRows);
    },
    setLotesSelected: function (component, event, helper) {
        var ID = component.get('v.recordId');
        var lotes = component.get('v.lotesSeleccionado');
        var lotesIdselected = [];
        var i = 0;
        console.log('lotes: '+JSON.stringify(lotesIdselected));
        if(lotes!=null){
            for(i=0;i<lotes.length;i++){
                if(lotes[i].Id){
                    lotesIdselected.push({"Id":lotes[i].Id,"Name":lotes[i].Name,"Origen":lotes[i].Origen});
                }else{
                    lotesIdselected.push({"Id":'undefined'+i,"Name":lotes[i].Name,"Origen":lotes[i].Origen});
                }
            }
            console.log('lotesIdselected: '+JSON.stringify(lotesIdselected));
            var action = component.get("c.ActualizarLotes");
            action.setParams({ 
                "caseId": ID,
                "lotes": JSON.stringify(lotesIdselected)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('oRes: ' + JSON.stringify(oRes));
                    if(oRes.estado=="OK"){
                        component.set("v.isModal",false);
                        helper.showAlert(oRes.mensaje,'success', 5000);                    
                        $A.get('e.force:refreshView').fire();
                        helper.getData(component);
                        component.set('v.lotesSeleccionado',null);
                    }else{
                        helper.showAlert(oRes.mensaje,'error', 5000);
                    }
                }else{
                    helper.showAlert('Hubo un problema. Por favor, intententelo otra vez.','error', 3000);
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.showAlert("No ha seleccionado ningun lote",'error', 5000);
        }
    },
    openModal:function (component, event, helper) {
        var columns = [
            {label: 'Lote', fieldName: 'Name', type: 'text', initialWidth:350},
            {label: 'Origen', fieldName: 'Origen', type: 'text', initialWidth:100},
            {label: "Ver",type: "button",initialWidth: 90,initialWidth:80,
             typeAttributes: {label: "Ver",
                              name: "view_details",
                              title: "Click para ver más detalles.",
                              disabled:{fieldName :'EnabledView'}}}
        ];
        component.set("v.columns",columns);
        component.set("v.isModal",true);        
    },
    closeModal:function (component, event, helper) {
        component.set("v.isModal",false);
    },
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                if(!row.Id||row.Id==undefined||row.Id.indexOf('undefined')>-1){
                    helper.showAlert('Lote no se encuentra en Salesforce.','info', 5000);
                    return;
                }
                window.open("/lightning/r/"+row.Id+"/view",'_blank');
                break;
            default:
                console.log("handleRowAction not view_details");
                break;
        }
    },
    forceRefreshViewHandler:function(component, event, helper) {
        helper.getData(component);
    },
    changeRb:function(component, event, helper){
        helper.getLotes(component);
    }
})