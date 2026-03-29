/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 22-10-2024
 * @last modified by   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   21-10-2024   Luis Maldonado   Initial Version
**/
({
    noAceptarOAC:function(component, event, helper) {      
        component.set("v.confirmarOAC", false);
    },
    aceptarOAC:function(component, event, helper) {      
        component.set("v.confirmarOAC", false);
        var eventkeyCode = component.get("v.eventKeyCode");
        if(eventkeyCode == 13){
            var action = component.get("c.formPress");
            $A.enqueueAction(action);
        }else if(!eventkeyCode){
            var action = component.get("c.Search");
            $A.enqueueAction(action);
        }
    },
    ejecutarBusqueda:function(component, event, helper) {
        var requeridoOAC = component.get("v.requeridoOAC");
        var requeridoMedio = component.get("v.requeridoMedio");
        helper.validarOAC(component, event, helper);
        component.set("v.eventKeyCode", event.keyCode);
        if(!requeridoOAC){
            if(event.keyCode == 13){
                var action = component.get("c.formPress");
                $A.enqueueAction(action);
            }else if(!event.keyCode){
                var action = component.get("c.Search");
                $A.enqueueAction(action);
            }
        }
        if(!requeridoMedio){
            if(event.keyCode == 13){
                var action = component.get("c.formPress");
                $A.enqueueAction(action);
            }else if(!event.keyCode){
                var action = component.get("c.Search");
                $A.enqueueAction(action);
            }
        }

        // /*NUEVO -INICIO*/
        // console.log('ENTRA');
        // var navService = component.find("navService");
        // // Sets the route to /lightning/r/recordId
        // var pageReference = {
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: '0014T00000NuqROQAZ',
        //         objectApiName: 'Account',
        //         actionName: 'view'
        //     }
        // };
        // component.set("v.pageReference", pageReference);
        // // Set the URL on the link or use the default if there's an error
        // var defaultUrl = "#";
        // navService.generateUrl(pageReference)
        //     .then($A.getCallback(function(url) {
        //         component.set("v.url", url ? url : defaultUrl);
        //     }), $A.getCallback(function(error) {
        //         component.set("v.url", defaultUrl);
        //     }));
        // /*NUEVO -FIN*/
    },
	Search : function(component, event, helper) { 
        
        //Declaración de variables
		var tipo = component.find("documento").get("v.value"); 
        var tipo_ = false;        
        var numero = component.find("numero").get("v.value");
        var numero_ = false;                
        var visita = component.find("visita").get("v.value");
        //var NameInput = component.find("NombreCompletoRegistrado").get("v.value");
        //var CorreoInput = component.find("CorreoRegistrado").get("v.value");
        //var CelularInput = component.find("CelularRegistrado").get("v.value");
       
        
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
            //helper.Search(component, tipo, numero, visita, NameInput, CorreoInput, CelularInput);
            helper.Search(component, tipo, numero, visita);
        }
                       
	},
        
    closeModelDoc: function(component, event, helper) {
        //for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        helper.closemodalpopup(component, event);
        //window.location.reload()
  	},

    continuarModalAsesor: function(component, event, helper){
        component.set("v.showNoHayEventos", false);
        component.set("v.showModalAsesor", true);
    },
        
    redModelDoc : function (component, event, helper) {
        component.set("v.disableIrAlregistro", true);
        var id = component.get("v.searchResult");
        var tipo = component.get("v.tipo");
        var visita = component.find("visita").get("v.value");
        var documento = component.find("numero").get("v.value");                       
        var atencion = component.find("atencion").get("v.value");
        
       	var NameInput = component.find("NombreRegistrado").get("v.value");
        var ApellidoInput = component.find("ApellidoRegistrado").get("v.value");   
        var CorreoInput = component.find("CorreoRegistrado").get("v.value");
        var CelularInput = component.find("CelularRegistrado").get("v.value");
        var DireccionInput = component.find("DireccionRegistrado").get("v.value");
        var DistritoInput = component.get("v.selectedLookUpRecord");
        var visitante = component.get("v.visitante");
        var oac = component.get("v.selectedOAC");
        var Medio = component.get("v.selectedMedio");
        var idct=null;
        if(visitante){
            idct=visitante.Id;
        }
    
        var IDuni = id[0].Id;          
        
        if(visita.toUpperCase()=="POSTVENTA"){
            if(NameInput&&ApellidoInput&&CelularInput&&DireccionInput&&DistritoInput.Id){
                helper.Search2(component, IDuni, tipo, visita, documento, NameInput, ApellidoInput, CorreoInput, CelularInput, DireccionInput, DistritoInput, atencion, idct, oac,Medio);                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: 'Nombres, Apellidos, Dirección, Distrito y Celular no pueden estar vacío.',
                    type : 'error'
                });
                toastEvent.fire();
                component.set("v.disableIrAlregistro", false);
            }
        }else{
            helper.Search2(component, IDuni, tipo, visita, documento, NameInput, ApellidoInput, CorreoInput, CelularInput, DireccionInput, DistritoInput, atencion, null, oac,Medio);
        }
    },

    createNewAutomaticEvent : function (component, event, helper){
        var leadSearchResult = component.get("v.searchResult");
        var leadId = leadSearchResult[0].Id;
        var tipo = component.get("v.tipo");
        var visita = component.find("visita").get("v.value");
        var oac = component.get("v.selectedOAC");
        var Medio = component.get("v.selectedMedio");
        

        var action = component.get("c.createNewEventAutomaticPresencial");
        action.setParams({
            "id": leadId ,
            "tipo": tipo ,
            "visita": visita,
            "oac": oac,
            "Medio":Medio
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                /*NUEVO -INICIO*/
                var navService = component.find("navService");
                // Sets the route to /lightning/r/recordId
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: allValues,
                        objectApiName: 'Event',
                        actionName: 'view'
                    }
                };
                component.set("v.pageReference", pageReference);
                navService.navigate(pageReference);
            }
        });
        $A.enqueueAction(action);
        helper.closemodalpopup(component, event);
    },

    createLead : function (component, event, helper){
        var leadSearchResult = component.get("v.searchResult");
        var leadFirstName = leadSearchResult[0].FirstName;
        var leadLastName = leadSearchResult[0].LastName;
        var leadNumDocumento = leadSearchResult[0].CEN_N_mero_de_documento__c;
        var leadEmail = leadSearchResult[0].Email;
        var leadMobilePhone = leadSearchResult[0].MobilePhone;
        var requeridoOAC = component.get("v.requeridoOAC");
        var selectedOAC = component.get("v.selectedOAC");
        

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
        "entityApiName": "Lead",
        "defaultFieldValues": {
            'LeadSource': 'Presencial',
            'FirstName': leadFirstName,
            'LastName': leadLastName,
            'CEN_N_mero_de_documento__c': leadNumDocumento,
            'Email': leadEmail,
            'MobilePhone': leadMobilePhone,
            'CEN_Oficina_de_Venta2__c': selectedOAC
        }
        });
        createRecordEvent.fire();
        helper.closemodalpopup(component, event);
    },

    redEventLead : function (component, event, helper) {
        var button = event.getSource();
        var eventId = button.get("v.value");

        //Redirección al Evento en base a su Id
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: eventId,
                objectApiName: 'Event',
                actionName: 'view'
            }
        };

        //Empieza la Redirección
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);

        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
        /*NUEVO -FIN*/
        helper.closemodalpopup(component, event);
    },

    confirmarAsistencia : function (component, event, helper) {
        var button = event.getSource();
        var eventIdConfirm = button.get("v.value");

        var action = component.get("c.confirmarAsistenciaDeEvento");
        action.setParams({
            "id": eventIdConfirm
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var idEventReturned = response.getReturnValue();
                //Redireccionamos luego de confirmar la asistencia
                var navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: idEventReturned,
                        objectApiName: 'Event',
                        actionName: 'view'
                    }
                };
                component.set("v.pageReference", pageReference);
                navService.navigate(pageReference);
            }
        });
        $A.enqueueAction(action);
        helper.closemodalpopup(component, event);
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
        component.set("v.tipoDoc",tipo);
    },
    
 	doInit : function(component, event, helper) {

        //validar si perfil debe usar selector OACs
        var action = component.get("c.getObligacionElegirOAC");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //	insetar OACs
                var datos = response.getReturnValue();
                component.set("v.requeridoOAC", datos);
                component.set("v.requeridoMedio", datos);
            }else if (state === "INCOMPLETE"){
            }else if (state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        //obtener OACs
   	    var action = component.get("c.getOACs");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //	insetar OACs
                var datos = response.getReturnValue();
                if(datos){
                    datos = datos.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
                }
                component.set("v.optionsOAC", datos);
            }else if (state === "INCOMPLETE"){
                console.log("No se terminó de obtener los datos OAC. Revisar conexión a internet.");
            }else if (state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error obteniendo OACs. " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        //obtener Medios
        var action = component.get("c.getMedio");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //	insetar Medio
                var datos = response.getReturnValue();
                if(datos){
                    datos = datos.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
                }
                component.set("v.optionsMedio", datos);
            }else if (state === "INCOMPLETE"){
                console.log("No se terminó de obtener los datos Medios. Revisar conexión a internet.");
            }else if (state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error obteniendo Medios. " + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
  	},
    
    formPress: function(component, event, helper){
        if(event.keyCode == 13)
        {           
            
            //Declaración de variables
		var tipo = component.find("documento").get("v.value"); 
        var tipo_ = false;        
        var numero = component.find("numero").get("v.value");
        var numero_ = false;
        var visita = component.find("visita").get("v.value");
        
        //var NameInput = component.get("NombreCompletoRegistrado");                       
        //var CorreoInput = component.get("CorreoRegistrado"); 
        //var CelularInput = component.get("CelularRegistrado"); 
            
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
         if(numero == undefined || numero == "" || numero.length == 0 || numero == null)
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
        
        if((tipo == "Carnet de extranjeria") && (numero.length > 16 && numero.length < 1))
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
            //helper.Search(component, tipo, numero, visita, NameInput, CorreoInput, CelularInput);
            helper.Search(component, tipo, numero, visita);
        }
        }      
    },
    
    onCheck: function(component, event, helper){        
        
        var estadoCheck = component.find("checkbox").get("v.value");
        var estado = "true";
        
        
        if(estadoCheck == true)
        {
            
            
            estado = "false";
            var itemNombre = component.find("NombreCompletoRegistrado");                   
			itemNombre.set("v.disabled", estado);
            
            var itemCorreo = component.find("CorreoRegistrado");                   
			itemCorreo.set("v.disabled", estado);
            
            var itemCelular = component.find("CelularRegistrado");                   
			itemCelular.set("v.disabled", estado);
            
            var itemDireccion = component.find("DireccionRegistrado");                   
			itemDireccion.set("v.disabled", estado);
            
            var itemDistrito = component.find("DistritoRegistrado");                   
			itemDistrito.set("v.disabled", estado);
            
        }else
        {
            console.log("false");
            var itemNombre = component.find("NombreCompletoRegistrado");                   
			itemNombre.set("v.disabled", estado);
            
            var itemCorreo = component.find("CorreoRegistrado");                   
			itemCorreo.set("v.disabled", estado);
            
            var itemCelular = component.find("CelularRegistrado");                   
			itemCelular.set("v.disabled", estado);
            
            var itemDireccion = component.find("DireccionRegistrado");                   
			itemDireccion.set("v.disabled", estado);
            
            var itemDistrito = component.find("DistritoRegistrado");                   
			itemDistrito.set("v.disabled", estado);
        }
        		                        
    },
    
    ClickSpan: function(component, event, helper){
        
        var estadoCheck = component.find("checkbox").get("v.value");
        var estado = "true";
        
        
        if(estadoCheck == true)
        {
            var itemCheck = component.find("checkbox");
        	itemCheck.set("v.value", false);
            
            console.log("false");
            var itemNombre = component.find("NombreCompletoRegistrado");                   
			itemNombre.set("v.disabled", estado);
            
            var itemCorreo = component.find("CorreoRegistrado");                   
			itemCorreo.set("v.disabled", estado);
            
            var itemCelular = component.find("CelularRegistrado");                   
			itemCelular.set("v.disabled", estado);
            
            var itemDireccion = component.find("DireccionRegistrado");                   
			itemDireccion.set("v.disabled", estado);
            
            var itemDistrito = component.find("DistritoRegistrado");                   
			itemDistrito.set("v.disabled", estado);
            
        }else
        {                                               
            estado = "false";
            
            var itemCheck = component.find("checkbox");
        	itemCheck.set("v.value", true);
            
            var itemNombre = component.find("NombreCompletoRegistrado");                   
			itemNombre.set("v.disabled", estado);
            
            var itemCorreo = component.find("CorreoRegistrado");                   
			itemCorreo.set("v.disabled", estado);
            
            var itemCelular = component.find("CelularRegistrado");                   
			itemCelular.set("v.disabled", estado);
            
            var itemDireccion = component.find("DireccionRegistrado");                   
			itemDireccion.set("v.disabled", estado);
            
            var itemDistrito = component.find("DistritoRegistrado");                   
			itemDistrito.set("v.disabled", estado);
        }
        
    },
    
    ActualizarInformacionBoton: function(component, event, helper){
        var estado = "false";        
        var itemNombre = component.find("NombreRegistrado");    
        itemNombre.set("v.disabled", estado);
        
        var itemApellido = component.find("ApellidoRegistrado");                   
        itemApellido.set("v.disabled", estado);
        
        var itemCorreo = component.find("CorreoRegistrado");                   
        itemCorreo.set("v.disabled", estado);
        
        var itemCelular = component.find("CelularRegistrado");                   
        itemCelular.set("v.disabled", estado);
        
        var itemDireccion = component.find("DireccionRegistrado");                   
        itemDireccion.set("v.disabled", estado);
        
        var itemDistrito1 = component.find("distrito_lookup_1");                   
        $A.util.addClass(itemDistrito1, 'slds-show');
        $A.util.removeClass(itemDistrito1, 'slds-hide');
        var itemDistrito2 = component.find("distrito_lookup_2");                   
        $A.util.addClass(itemDistrito2, 'slds-hide');
        $A.util.removeClass(itemDistrito2, 'slds-show');
        
    },
    checkboxSelect: function(component, event, helper){      
        // on each checkbox selection update the selected record cou
        var selectedRec = event.getSource().get("v.value");
        
        var getSelectedNumber = component.get("v.selectedCount");
        
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        
        if(getSelectedNumber>1){
            event.getSource().set("v.value",false);
            getSelectedNumber--;
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                mode: 'pester',
                message: 'Solo puede seleccionar a un representante.',
                type : 'error'
                });
                toastEvent.fire();        
        }else if(getSelectedNumber<=0){            
            getSelectedNumber=0;
            component.set('v.visitante',null);
        }else{
            var allRecords = component.get("v.Cuentaorgs");
            var selectedRecords = [];
            for (var i = 0; i < allRecords.length; i++) {
                for (var j = 0; j < allRecords[i].contactos.length; j++) {
                    if (allRecords[i].contactos[j].isChecked) {
                        selectedRecords.push(allRecords[i].contactos[j]);
                    }
                }  
            }
            if(selectedRecords.length>0){
                
                component.set("v.visitante",selectedRecords[0]);
                helper.searchDistrito(component, event, selectedRecords[0].CEN_Distrito__c);
            }           
        }
        
        component.set("v.selectedCount", getSelectedNumber);       
    },
    registrarVisitaTercero:function(component, event, helper){              
        var atencion = component.find("atencion").get("v.value");
        var TipoDocInput = component.find("TipoDocRegistrado").get("v.value");
        var NdocInput = component.find("NdocRegistrado").get("v.value");
       	var NameInput = component.find("NombreRegistrado").get("v.value");
        var ApellidoInput = component.find("ApellidoRegistrado").get("v.value");   
        var CorreoInput = component.find("CorreoRegistrado").get("v.value");
        var CelularInput = component.find("CelularRegistrado").get("v.value");
        var DireccionInput = component.find("DireccionRegistrado").get("v.value");
        var DistritoInput = component.get("v.selectedLookUpRecord");
        var oac = component.get("v.selectedOAC");
        
        if(atencion&&TipoDocInput&&NdocInput&&NameInput&&ApellidoInput&&CelularInput&&DireccionInput&&DistritoInput&&DistritoInput.Id){
            
        
        var action = component.get("c.registrarVisitaDeTercero");
        action.setParams({
            "TipoDoc": TipoDocInput,
            "Ndoc": NdocInput,
            "Nombres": NameInput,
            "Apellidos": ApellidoInput,
            "Direccion": DireccionInput,
            "Distrito": DistritoInput.Id,
            "Correo": CorreoInput,
            "Celular": CelularInput,
            "TipoDeAtencion": atencion,
            "oac":oac
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var mensaje = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: mensaje,
                    type : 'success'
                });
                toastEvent.fire(); 
                helper.closemodalpopup(component, event);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: 'Hubo un problema.',
                    type : 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: 'Tipo de documento, Número de documento, Nombres, Apellidos, Dirección, Distrito y Celular son requeridos para registrar la visita.',
                    type : 'error'
                });
                toastEvent.fire();
        }
    }
})