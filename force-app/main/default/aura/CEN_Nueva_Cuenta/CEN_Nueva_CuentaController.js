({
	doInit : function(component, event, helper) {
        //var globalId = component.getGlobalId();
        //var comp = component.find(globalId);
        //$A.util.addClass(comp, 'slds-hide');
        //$A.util.addClass(component, 'slds-hide');       
        var action = component.get("c.getRecordTypeCuentaNatural");
        //action.setParams({});
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var resp = response.getReturnValue();
            console.log("resp: " + JSON.stringify(resp));
            if (resp!=null) {
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Account",
                    "recordTypeId":resp.Id,
                    "defaultFieldValues": null
                });
                createRecordEvent.fire();   
            }
          }
        });
        $A.enqueueAction(action);
	}
})