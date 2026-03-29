({
    readFile: function(component, event, helper, file) {        
        var allowedFileTypes = ["image/png", "image/jpeg", "image/jpg"];
        if (!file) return;
        if (!allowedFileTypes.includes(file.type)) {
            helper.showToast(component, event, helper, 'error','Tipo de archivo no soportado','Solo se permite imágen de tipo: .png, .jpeg o .jpg.');
            component.set("v.estaCargando",false);
            return;
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },
    upload: function(component, file, base64Data) {
        var action = component.get("c.saveAttachment"); 
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultado = response.getReturnValue();
                
                if(resultado && resultado.ok){
                    this.showToast(component, event, null, 'success','¡Registro exitoso!','');
                    
                    let compEvent = component.getEvent("eventoCargaImagen");
                    compEvent.setParams({"cargoImagen":true});
                    compEvent.fire();
                                         
                    console.log("Termino la carga del logo");
                    component.set("v.estaCargando",false);
                }else if(resultado && !resultado.ok){
                    this.showToast(component, event, helper, 'error','Error en la carga',resultado.mensaje);
                    console.log("Error message: " + resultado.detalle);
                }else{
                    console.log("Unknown error");
                }
                
            }else if (state === "INCOMPLETE") {
                console.log("Unknown error");
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
            component.set("v.estaCargando",false);
        });       
        $A.enqueueAction(action); 
    },
    showToast : function(component, event, helper, type, titulo, mensaje) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            type: type,
            duration: 7000,
            title: titulo,
            message: mensaje
        });
        toastEvent.fire();
    }
})