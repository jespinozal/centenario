({
	Search : function(component, event, helper) {                                       
        //Declaración de variables
		var tipo = component.find("documento").get("v.value"); 
        var tipo_ = false;        
        var numero = component.find("numero").get("v.value");
        var numero_ = false;
        var mensaje = "";              
        
                                
        //Condicionales de valores Tipo
        if(tipo == undefined || tipo == "" || tipo.length == 0 || tipo == null)
        {
            tipo_ = false;
            mensaje = "Por favor seleccione tipo de documento"
        }
        else{
            tipo_ = true;
            mensaje = "";
        }
        
        //Condicionales de valores número
         if((numero == undefined || numero == "" || numero.length == 0 || numero == null) && tipo !="Sin especificar" )
        {
            numero_ = false;
            
            if(mensaje != "")
            {
                mensaje += " e ingrese el número de documento para poder realizar la búsqueda";
            }
            else
            {
                mensaje += "Por favor ingrese el número de documento para poder realizar la búsqueda"; 
            }
        }
        else{
            numero_ = true;  
            
            if(tipo == "DNI" && numero.length < 8)
            {
                mensaje = "El número de DNI debe tener 8 digitos";
            }
            
            if(tipo == "RUC" && numero.length < 11)
            {
                mensaje = "El número de RUC debe tener 11 digitos";
            }
        }
        
        if((tipo == "DNI") && (numero.length < 8 && numero.length > 0))
        {
            mensaje = "El número de DNI debe tener 8 digitos";
        }
        
        if((tipo == "RUC") && (numero.length < 11 && numero.length > 0))
        {
            mensaje = "El número de RUC debe tener 11 digitos";
        }
        
        if((tipo == "Pasaporte") && (numero.length > 16 && numero.length < 1))
        {
            mensaje = "El número de Pasaporte debe tener máximo 16 digitos";
        }
        
        if((tipo == "Carné de extranjeria") && (numero.length > 16 && numero.length < 1))
        {
            mensaje = "El número de Carné de extranjeria debe tener 16 digitos";
        }
                
        if(mensaje != "")
        {                      
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                mode: 'pester',
                message: mensaje,
                type : 'error'
                });
                toastEvent.fire();            
        }
        else
        {
            helper.Search(component, tipo, numero);
        }
	},
    
    closeModelDoc: function(component, event, helper) {
        //for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isModaldoc", false);
        window.location.reload()
  	},
    
    redModelDoc : function (component, event, helper) {
        var id = component.get("v.searchResult");
        console.log(id[0].Id);
        window.location="/lightning/r/Account/"+id[0].Id+"/view"; 
    },
              
    changevalor : function (component, event, helper) {    
        
          var numero = component.find("numero").get("v.value");
       	 var tipo = component.find("documento").get("v.value");
         var mensaje = "";
        
        if(tipo == "Sin especificar")
        {   
          if(!/^[0-9]+$/.test(numero))
          {            
       		mensaje= "No se permite agregar datos";                              
              
        	var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            mode: 'pester',
            message: mensaje,
            type : 'error'
            });
            toastEvent.fire();
              
            var comp = component.find("numero");
            comp.set('v.value',numero.replace(/[^\d,]/g,''));
          }  
            
            if(numero.length > 0){          
            var comp = component.find("numero");
            comp.set('v.value',numero.substring(0,0));}          
        }
        else
        {
        
        
        if(tipo == "DNI")
        {   
          if(!/^[0-9]+$/.test(numero))
          {            
       		 mensaje= "El número de documento solo puede contener números";                              
              
        	var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            mode: 'pester',
            message: mensaje,
            type : 'error'
            });
            toastEvent.fire();
              
            var comp = component.find("numero");
            comp.set('v.value',numero.replace(/[^\d,]/g,''));
          }  
            
            if(numero.length > 8){          
            var comp = component.find("numero");
            comp.set('v.value',numero.substring(0,8));}          
        }
        else
        {
            if(tipo == "RUC")
            {
              if(!/^[0-9]+$/.test(numero)){            
       		  mensaje= "El número de documento solo puede contener números";                              
              
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                mode: 'pester',
                message: mensaje,
                type : 'error'
                });
                toastEvent.fire();
              
            var comp = component.find("numero");
            comp.set('v.value',numero.replace(/[^\d,]/g,''));
          }  
                
                if(numero.length > 11){
                console.log("mayor a 11");
                var comp = component.find("numero");
                comp.set('v.value',numero.substring(0,11));}
            }
            else
            {
                if((tipo == "Pasaporte")||(tipo == "Carnet de extranjeria"))
                {
                    if(numero.length > 16){            	
            		var comp = component.find("numero");
            		comp.set('v.value',numero.substring(0,16));}
                }
                else
                {
                    if(numero.length > 11){            	
            		var comp = component.find("numero");
            		comp.set('v.value',numero.substring(0,11));}
                }
            }
        } 
            
        }
    },
    
    changeitem : function(component, event, helper){
        
        component.find("numero").set("v.value", "");
        
        var tipo = component.find("documento").get("v.value");
        
        if(tipo == "Sin especificar")
        {
            component.find("numero").set("v.value", "-");
        }
        else
        {            
             component.find("numero").set("v.value", "");
        }
        
    },
})