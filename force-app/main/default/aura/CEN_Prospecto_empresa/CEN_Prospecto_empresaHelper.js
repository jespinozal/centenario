({
    Search: function(component, rsocial, ruc, id) {
        
        var action = component.get("c.getProspectoEmpresa");
        action.setParams({
            "rsocial": rsocial,
            "ruc": ruc ,
            "id": id ,
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('Todo ok');
                window.location.reload()
            }
        });
        $A.enqueueAction(action);
    },
})