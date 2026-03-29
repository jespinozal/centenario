({
	onDragOver: function(component, event) {
        event.preventDefault();
    },
    onDrop: function(component, event, helper) {
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        component.set("v.estaCargando",true);
        var files = event.dataTransfer.files;
        if (files.length>1) {
            helper.showToast(component, event, helper, 'error','Limite de carga ','Puedes añadir solamente una imagen.');
            component.set("v.estaCargando",false);
            return;
        }
        helper.readFile(component, event, helper, files[0]);
	}
})