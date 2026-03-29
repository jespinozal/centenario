({
	doInit: function(component, event, helper) {
		var ID = component.get('v.recordId');  		
	},
    
    Search : function(component, event, helper) {
    	var rsocial = component.find("rsocial").get("v.value"); 
        var ruc = component.find("ruc").get("v.value");
        var id = component.get("v.recordId");
        console.log('ID: '+id);
    	helper.Search(component, rsocial, ruc, id);  
	},   
        
})