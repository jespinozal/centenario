({
  sendAction: function (component, actionName) {
    var compEvent = component.getEvent("eventoEnviarAccion");
    compEvent.setParams({ action: actionName });
    compEvent.fire();
  }
});