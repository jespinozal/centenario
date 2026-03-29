({
    cargarImagenLogo:function(component, event, helper){
        var action = component.get("c.getLogoPicture"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultado = response.getReturnValue();
                if(resultado && resultado.ok){
                    var attachment = resultado.logo;
                    if (attachment && attachment.Id) {
                        component.set('v.imagenSrc', '/servlet/servlet.FileDownload?file='+ attachment.Id);
                    }
                }else if(resultado && !resultado.ok){
                    helper.showToast(component, event, helper, 'warning','Logo no encontrado',resultado.mensaje);
                    console.log("Error message: " + resultado.detalle);
                }
            }else if (state === "INCOMPLETE") {
                
            }else if (state === "ERROR") {
                component.set("v.message", null);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast(component, event, helper, 'error','Error interno',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
	showToast : function(component, event, helper, type, titulo, mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            type: type,
            duration: 5000,
            title: titulo,
            message: mensaje
        });
        toastEvent.fire();
    }
})