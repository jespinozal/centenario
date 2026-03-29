({
	doInit : function(component, event, helper) {
		var ID = component.get('v.recordId');
		var action = component.get("c.getDataCliente");
  		action.setParams({ 
            "recordId": ID
		});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('oRes: ' + JSON.stringify(oRes));
                if(oRes){
                    component.set("v.LotesCuenta",oRes);
                    var i = 0,
                        list = [];
                    for (i = 0; i < oRes.length; i++) {
                        if (i + 1 > 3) {
                            break;
                        } else {
                            list.push(oRes[i]);
                        }
                    }
                    component.set("v.lotesShowed",list);
                    component.set("v.totalLotes",oRes.length);
                }
            }
        });
      	$A.enqueueAction(action);
	},
    verTodos: function(component, event, helper) {
        if(component.get("v.verTodosBool")){
            component.set("v.verTodosBool",false);
        }else{
            component.set("v.verTodosBool",true);
        }        
    }
})