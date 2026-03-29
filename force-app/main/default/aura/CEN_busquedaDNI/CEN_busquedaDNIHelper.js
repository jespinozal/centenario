/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 04-11-2024
 * @last modified by   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   21-10-2024   Luis Maldonado   Initial Version
**/
({
    validarOAC: function(component, event, helper){
        var oacInputField = component.find("slcOAC");
        var medioInputField = component.find("Medio");
        var requeridoOAC = component.get("v.requeridoOAC");
        var requeridoMedio = component.get("v.requeridoMedio");
        var message = null;
        if(oacInputField && requeridoOAC){
            var valueOAC = oacInputField.get("v.value");
            var selectedOAC = component.get("v.selectedOAC");
            var valueMedio = medioInputField.get("v.value");
            var selectedMedio = component.get("v.selectedMedio");
            if(!valueOAC || valueOAC==="nulo" || selectedOAC == undefined || selectedOAC == null){
                message= "No ha seleccionado una OAC";
                component.find("slcOAC").set('v.validity', {valid:false, badInput :true});
                component.find("slcOAC").showHelpMessageIfInvalid();
            }else if(!valueMedio || valueMedio==="nulo" || selectedMedio == undefined || selectedMedio == null){
                message= "No ha seleccionado un Medio";
                component.find("Medio").set('v.validity', {valid:false, badInput :true});
                component.find("Medio").showHelpMessageIfInvalid();
            }
        }else if(requeridoOAC){
            message = "Debe seleccionar una OAC";
        }else if(requeridoMedio){
            message = "Debe seleccionar un Medio";
        }
        if(message){
            var toastEvent = $A.get("e.force:showToast");
            if(toastEvent){
                    toastEvent.setParams({
                    mode: 'pester',
                    message: message,
                    type : 'error'
                });
                toastEvent.fire();
            }
        }else if(requeridoOAC){
            var selectedOAC = component.get("v.selectedOAC");
            var data = component.get("v.optionsOAC");
            var filter = data.filter(x=>(x.value == selectedOAC));
            var selectedOAClabel = selectedOAC;
            if(filter){
                selectedOAClabel = filter[0].label;
            }
            component.set("v.selectedOAClabel", selectedOAClabel);
            component.set("v.confirmarOAC",true);
        }else if(requeridoMedio){
            var selectedMedio = component.get("v.selectedMedio");
            var data = component.get("v.optionsMedio");
            var filter = data.filter(x=>(x.value == selectedMedio));
            var selectedMediolabel = selectedMedio;
            if(filter){
                selectedMediolabel = filter[0].label;
            }
            component.set("v.selectedMediolabel", selectedMediolabel);
            component.set("v.confirmarMedio",true);
        }
    },
    Search: function(component, tipo, numero, visita) {
        var tipo= tipo;
        var selectedOAC = component.get("v.selectedOAC");
        var action = component.get("c.getselectDoc");
        action.setParams({
            "tipo": tipo ,
            "numero": numero ,
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
                if(allValues.Cuenta.length>0&&visita=="Postventa"){
                    component.set("v.searchResult", allValues.Cuenta);
                    component.set("v.Cuentaorgs", allValues.Cuentaorgs);
                    console.log("Es cliente");
                    component.set("v.isModaldoc", true);
                    component.set("v.tipo", 'Cliente '); 
                    component.set("v.enlace", "/view");

                    //component.set("v.showIrAlEvento", true);
                    component.set("v.events", allValues.eventosFormateados);


                    if(allValues.Cuenta[0].CEN_Distrito__pc){
                                var oRes={CEN_Codigo_distrito__c:allValues.Cuenta[0].CEN_Distrito__pr.CEN_Codigo_distrito__c,
                                          CEN_Codigo_provincia__c:allValues.Cuenta[0].CEN_Distrito__pr.CEN_Codigo_provincia__c,
                                          CEN_Codigo_departamento__c:allValues.Cuenta[0].CEN_Distrito__pr.CEN_Codigo_departamento__c,
                                          Provincia__c:allValues.Cuenta[0].CEN_Distrito__pr.Provincia__c,
                                          Departamento__c:allValues.Cuenta[0].CEN_Distrito__pr.Departamento__c,
                                          Id:allValues.Cuenta[0].CEN_Distrito__pr.Id,
                                          Name:allValues.Cuenta[0].CEN_Distrito__pr.Name};
                                component.set("v.selectedLookUpRecord", oRes);
                            }
                    if(visita =='Postventa')
                    {
                        component.set("v.display","display:inline");
                        component.set("v.showInfoRegistrada", true);
                    }
                    else
                    {
                        component.set("v.display","display:none");
                        component.set("v.showInfoRegistrada", false);
                    }
                    
                    /*NUEVO -INICIO*/
                    var navService = component.find("navService");
                    // Sets the route to /lightning/r/recordId
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: allValues.Cuenta[0].Id,
                            objectApiName: 'Account',
                            actionName: 'view'
                        }
                    };
                    component.set("v.pageReference", pageReference);
                    // Set the URL on the link or use the default if there's an error
                    var defaultUrl = "#";
                    navService.generateUrl(pageReference)
                        .then($A.getCallback(function(url) {
                            component.set("v.url", url ? url : defaultUrl);
                        }), $A.getCallback(function(error) {
                            component.set("v.url", defaultUrl);
                        }));
                    /*NUEVO -FIN*/

                }else if(allValues.Cuenta.length>0&&allValues.Prospecto.length<=0&&visita!="Postventa"){
                    component.set("v.searchResult", allValues.Cuenta);
                    component.set("v.isModaldoc", true);
                    component.set("v.events", allValues.eventosFormateados);
                    component.set("v.tipo", 'Cliente ');  

                    if(response.getReturnValue().eventosFormateados.length > 0){
                        component.set("v.showIrAlEvento", true);
                        component.set("v.showNoHayEventos", false);
                    }else{
                        component.set("v.showIrAlEvento", false);
                        component.set("v.showNoHayEventos", true);
                    }
                    
                }else if(allValues.Prospecto.length>0&&visita!="Postventa"){
                    if(response.getReturnValue().eventosFormateados.length > 0){
                        component.set("v.showIrAlEvento", true);
                        component.set("v.showNoHayEventos", false);
                    }else{
                        component.set("v.showIrAlEvento", false);
                        component.set("v.showNoHayEventos", true);
                    }
                    console.log("Es prospecto");
                    console.table(allValues.Prospecto);
                    component.set("v.searchResult", allValues.Prospecto);
                    component.set("v.isModaldoc", true);
                    component.set("v.tipo", 'Prospecto ');     
                    component.set("v.enlace", "/view"); 
                    component.set("v.display","display:none");
                    //component.set("v.showIrAlEvento", true);
                    component.set("v.events", allValues.eventosFormateados);

                    component.set("v.ownerName", allValues.Prospecto[0].Owner.Name);
                    var fechaCreacion = allValues.Prospecto[0].CreatedDate;
                    var dateObj = new Date(fechaCreacion);
            
                    // Obtener la parte de la fecha en formato "YYYY-MM-DD"
                    var formattedDate = dateObj.toLocaleDateString();
                    // Obtener la parte de la hora en formato "HH:MM:SS"
                    var formattedTime = dateObj.toLocaleTimeString();
                    // Asignar los valores formateados a atributos en el componente
                    component.set("v.formattedDate", formattedDate);
                    component.set("v.formattedTime", formattedTime);

                     /*NUEVO -INICIO*/
                     var navService = component.find("navService");
                     // Sets the route to /lightning/r/recordId
                     var pageReference = {
                         type: 'standard__recordPage',
                         attributes: {
                             recordId: allValues.Prospecto[0].Id,
                             objectApiName: 'Lead',
                             actionName: 'view'
                         }
                     };
                     component.set("v.pageReference", pageReference);
                     // Set the URL on the link or use the default if there's an error
                     var defaultUrl = "#";
                     navService.generateUrl(pageReference)
                         .then($A.getCallback(function(url) {
                             component.set("v.url", url ? url : defaultUrl);
                         }), $A.getCallback(function(error) {
                             component.set("v.url", defaultUrl);
                         }));
                     /*NUEVO -FIN*/
                }else{
                    var numero = component.find("numero").get("v.value");
                    var tipo = component.find("documento").get("v.value");                    
                    if(visita=="Postventa"){
                        console.log("Es tercero");                        
                        component.set("v.isModaldoc",true);
                        component.set("v.tipoVisitante",'tercero');
                        component.set("v.display","display:none");
                        component.set("v.selectedLookUpRecord",null);
                        component.find("TipoDocRegistrado").set("v.value",tipo);
                        component.find("NdocRegistrado").set("v.value",numero);
                        if(allValues.datos&&allValues.datos.Nombres&&allValues.datos.Apellidos){
                            component.find("NombreRegistrado").set("v.value",allValues.datos.Nombres);
                            component.find("ApellidoRegistrado").set("v.value",allValues.datos.Apellidos);
                        }else if(allValues.Prospecto.length>0){
                            component.find("NombreRegistrado").set("v.value",allValues.Prospecto[0].FirstName);
                            component.find("ApellidoRegistrado").set("v.value",allValues.Prospecto[0].LastName);
                            component.find("DireccionRegistrado").set("v.value",allValues.Prospecto[0].CEN_Direcci_n_Prospecto__c);
                            if(allValues.Prospecto[0].CEN_Distrito__c){
                                var oRes={CEN_Codigo_distrito__c:allValues.Prospecto[0].CEN_Distrito__r.CEN_Codigo_distrito__c,
                                          CEN_Codigo_provincia__c:allValues.Prospecto[0].CEN_Distrito__r.CEN_Codigo_provincia__c,
                                          CEN_Codigo_departamento__c:allValues.Prospecto[0].CEN_Distrito__r.CEN_Codigo_departamento__c,
                                          Provincia__c:allValues.Prospecto[0].CEN_Distrito__r.Provincia__c,
                                          Departamento__c:allValues.Prospecto[0].CEN_Distrito__r.Departamento__c,
                                          Id:allValues.Prospecto[0].CEN_Distrito__r.Id,
                                          Name:allValues.Prospecto[0].CEN_Distrito__r.Name};
                                component.set("v.selectedLookUpRecord", oRes);
                            }                            
                            component.find("CorreoRegistrado").set("v.value",allValues.Prospecto[0].Email);
                            component.find("CelularRegistrado").set("v.value",allValues.Prospecto[0].MobilePhone);
                        }
                    }else{
                        
                    if(tipo != "Sin especificar" && tipo != "RUC"){
                    var lead={ CEN_N_mero_de_documento__c: numero, CEN_Tipo_de_documento__c:tipo, Salutation: "Sr.", CEN_Oficina_de_Venta2__c:selectedOAC, LeadSource:"Presencial"};
                        /*<------USANDO RENIEC--------*/
                        if(allValues.datos&&allValues.datos.Nombres&&allValues.datos.Apellidos){
                            lead={ CEN_N_mero_de_documento__c: numero, CEN_Tipo_de_documento__c:tipo, Salutation: "Sr.", FirstName:allValues.datos.Nombres, LastName:allValues.datos.Apellidos, CEN_Oficina_de_Venta2__c:selectedOAC};
                        } 
                        /*-------USANDO RENIEC------->*/
                    var createRecordEvent = $A.get("e.force:createRecord");
        			createRecordEvent.setParams({
            		"entityApiName": "Lead",
                    "defaultFieldValues": lead
                    });
                    createRecordEvent.fire();    
                    }else if(tipo == "RUC"){
                        
                    var lead={ CEN_RUC__c: numero, Salutation: "Sr.", CEN_Oficina_de_Venta2__c:selectedOAC, LeadSource:"Presencial"};
                    var createRecordEvent = $A.get("e.force:createRecord");
        			createRecordEvent.setParams({
            		"entityApiName": "Lead",
                    "defaultFieldValues": lead
                    });
                    createRecordEvent.fire();
                                                                     
                    }else{
                        var lead={ CEN_N_mero_de_documento__c: numero, CEN_Tipo_de_documento__c:tipo, Salutation: "Sr.",CEN_No_brindo_datos__c: true, CEN_Oficina_de_Venta2__c:selectedOAC, LeadSource:"Presencial"};
                    var createRecordEvent = $A.get("e.force:createRecord");
        			createRecordEvent.setParams({
            		"entityApiName": "Lead",
                    "defaultFieldValues": lead
                    });
                    createRecordEvent.fire();
                    }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Search2: function(component, IDuni, tipo, visita, documento, NameInput, ApellidoInput, CorreoInput, CelularInput, DireccionInput, DistritoInput, atencion, idct, oac,Medio) {
        
        var action = component.get("c.getselectEve");
        action.setParams({
            "id": IDuni ,
            "tipo": tipo ,
            "visita": visita,
            "documento": documento,
            "Name": NameInput,
            "Apellido":ApellidoInput,
            "Correo": CorreoInput,
            "Celular":CelularInput,
            "Direccion":DireccionInput,
            "Distrito":DistritoInput.Id,
            "Atencion":atencion,
            "idct":idct,
            "oac": oac,
            "Medio":Medio
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    duration: 5000,
                    message: 'Se registró correctamente la interacción!',
                    type : 'success'
                });
                toastEvent.fire(); 
                //     window.location="/lightning/r/"+allValues+"/view";
                var navService = component.find("navService");
                // Uses the pageReference definition in the init handler
                var pageReference = component.get("v.pageReference");
                //event.preventDefault();
                navService.navigate(pageReference);

            }
            component.set("v.disableIrAlregistro", false);
        });
        $A.enqueueAction(action);
    },
    
    searchDistrito: function(component, event, id){
        if(id){
            var action = component.get("c.buscarDistritobyId");
                action.setParams({
                    "distritoId": id
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes){
                        component.set("v.selectedLookUpRecord", oRes);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    closemodalpopup: function(component, event){
         component.find("numero").set("v.value", "");
        component.set("v.isModaldoc", false);
        component.set("v.showIrAlEvento", false);
        component.set("v.showNoHayEventos", false);
        component.set("v.showInfoRegistrada", false);
        component.set("v.showModalAsesor", false);
        
        component.set("v.selectedCount",0);
                        component.set("v.tipoVisitante",null);
                        component.set("v.display",null);
        component.set("v.selectedLookUpRecord",{});
                        //component.find("TipoDocRegistrado").set("v.value",null);
                        //component.find("NdocRegistrado").set("v.value",null);
    }
    
})