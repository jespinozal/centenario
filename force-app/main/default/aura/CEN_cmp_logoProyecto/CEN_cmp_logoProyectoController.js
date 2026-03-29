({
	onInit: function(component, event, helper) {
         helper.cargarImagenLogo(component, event, helper)
    },
    handleCargoImagen:function(component, event, helper) {        
        let cargoImagen = event.getParam("cargoImagen");
        console.log("cargoImagen: "+cargoImagen);
        if(cargoImagen){
            helper.cargarImagenLogo(component, event, helper)
        }
    }
})