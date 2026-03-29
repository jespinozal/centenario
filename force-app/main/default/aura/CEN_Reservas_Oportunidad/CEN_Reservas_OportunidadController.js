({
	doInit : function(component, event, helper) {
		helper.getData(component);
	},
    forceRefreshViewHandler : function(component, event, helper) {
		helper.getData(component);
	},
    handleClick:function(component, event, helper) {
		helper.reservar(component);
	}
})