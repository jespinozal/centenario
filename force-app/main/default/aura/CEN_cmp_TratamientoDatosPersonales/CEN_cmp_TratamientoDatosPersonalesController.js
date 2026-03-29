({
    doInit:function (component, event, helper) {
        var accountId = component.get("v.recordId");
        //console.log('Prueba doInit: '+'Account: '+accountId);
        helper.getAccountHelper(component, accountId);
    },
    
	handleCheck1: function(component, event, helper) {
        var isChecked = component.find("CheckBox1").get("v.checked");
        component.set("v.Valor1", isChecked);
        console.log("CheckBox 1: " + isChecked);
    },
    
	handleCheck2: function(component, event, helper) {
        var isChecked = component.find("CheckBox2").get("v.checked");
        component.set("v.Valor2", isChecked);
        console.log("CheckBox 2: " + isChecked);
    },
    
	handleCheck3: function(component, event, helper) {
        var isChecked = component.find("CheckBox3").get("v.checked");
        component.set("v.Valor3", isChecked);
        console.log("CheckBox 3: " + isChecked);
    },
    
    setPrivacidadController: function(component, event, helper){
        var accountId 	= component.get("v.recordId");
        var check1		= component.get("v.Valor1");
        var check2		= component.get("v.Valor2");
        var check3		= component.get("v.Valor3");
        var document    = event.getSource().get("v.value")
        
        //console.log('Prueba Controller: '+'AccountId: '+accountId+'|check1: '+check1+'|check2: '+check2+'|check3: '+check3);
        helper.setPrivacidadHelper(component, accountId, check1, check2, check3, document);
        //helper.attachHelper(component, accountId);
    }
})