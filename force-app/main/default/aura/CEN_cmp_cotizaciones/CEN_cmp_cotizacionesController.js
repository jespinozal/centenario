({
    onClickNuevaCotizacion : function(component, event, helper) {
        component.set("v.cotizadorLibreActivado",true);
    },
    closeModal : function(component, event, helper) {
        component.set("v.cotizadorLibreActivado",false);
    }
})