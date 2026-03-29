({
    doInit : function(component, event, helper) {
        var action = component.get("c.getInfoFromObject");
        var str = component.getGlobalId();
        
        
        
        component.set("v.CleanGID", "GID"+str.replace(":", "").replace(";", ""));
        action.setParams({ objectId : component.get("v.recordId"),
                          SObjectName : component.get("v.sObjectName")});
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.chc", a.getReturnValue());
                helper.renderGauge(component, event);
            }
        });
        
 
        
        
        
        $A.enqueueAction(action);
        
    },
    
    openContact : function (component, event, helper) {
        var ContactId = event.target.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ContactId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    gotoRelatedList : function (component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        var ContactId = component.get("v.chc.Contact.Id");
        
        relatedListEvent.setParams({
            "relatedListId": "Cases",
            "parentRecordId": ContactId
        });
        relatedListEvent.fire();
    },
    onInit: function(component) {
        var action = component.get("c.getProfilePicture"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            console.log(attachment);
            if (attachment && attachment.Id) {
	            component.set('v.imagenSrc', '/servlet/servlet.FileDownload?file=' 
                                                  + attachment.Id);
            }
        });
        $A.enqueueAction(action); 
    },
    
    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("Puedes añadir solamente una imagen.");
        }
        helper.readFile(component, helper, files[0]);
	}
})