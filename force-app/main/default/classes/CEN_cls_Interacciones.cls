public class CEN_cls_Interacciones {
     @AuraEnabled
    public static Tabla_maestra__c buscarDistritobyId(String distritoId){
        Tabla_maestra__c distrito = null;
        try{
            distrito = [SELECT CEN_Codigo_distrito__c, CEN_Codigo_provincia__c, CEN_Codigo_departamento__c, Provincia__c,
                        Departamento__c, Id, Name FROM Tabla_maestra__c WHERE Id=:distritoId LIMIT 1];
        }catch(Exception ex){
            System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        return distrito;
    }
    @AuraEnabled 
    public static String postergarCase(String caseId, Boolean status){
        Case record = null;
        try{
            record = [SELECT Description, Id, CaseNumber, Subject, ContactId, AccountId, ProductId, ParentId, CEN_flag_postergar_gestion__c,
                      OwnerId, CreatedById, CEN_Activar_Prorroga__c, CEN_Actualizar_Datos__c, IsClosed, Status, 
                      CreatedDate, ClosedDate, Contact.Id, Contact.FirstName, Contact.Name, Contact.LastName, Contact.Email, Contact.Phone, 
                      Contact.CEN_Direccion__c, Contact.CEN_Distrito__c, CEN_nombre_actualizado__c, CEN_distrito_actualizado__c,
                      CEN_distrito_actualizado__r.Name, CEN_distrito_actualizado__r.Provincia__c, CEN_distrito_actualizado__r.Departamento__c,
                      Contact.CEN_Distrito__r.Name, Contact.CEN_Distrito__r.Provincia__c, Contact.CEN_Distrito__r.Departamento__c, 
                      CEN_direccion_actualizado__c, CEN_celular_actualizado__c, CEN_apellido_actualizado__c, correo_actualizado__c 
                      FROM Case WHERE ID = :caseId LIMIT 1];
        }catch(Exception ex){
            if(record == null){
                System.debug('No se encontró un Case (Interacción) con Id '+caseId+'. Line: '+ex.getLineNumber());
            }
            System.debug('Exc: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            return 'error';
        }
        record.CEN_flag_postergar_gestion__c=status;
        update record;
        return 'ok';
    }
    @AuraEnabled
    public static List<Tabla_maestra__c> buscarDistrito(String textSearch){
        List<List<sObject>> searchList = null;
        List<Tabla_maestra__c> distritos = new List<Tabla_maestra__c>();
        if(String.isNotBlank(textSearch)){
            //textSearch = '%'+textSearch+'_%';
            try{
                searchList = [FIND :textSearch IN NAME FIELDS RETURNING Tabla_maestra__c(Id, Name, Provincia__c, Departamento__c)];
            }catch(Exception ex){
                System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            }
            if(searchList!=null||searchList.size()>0){
                distritos = (List<Tabla_maestra__c>)searchList[0];
            }
            System.debug('distritos: '+distritos);
        }
        return distritos;
    }
    @AuraEnabled
    public static Case getCaseById(String caseId){
        Case record = null;
        try{
            record = [SELECT Description, Id, CaseNumber, Subject, ContactId, AccountId, ProductId, ParentId, CEN_flag_postergar_gestion__c,
                      OwnerId, CreatedById, CEN_Activar_Prorroga__c, CEN_Actualizar_Datos__c, IsClosed, Status, 
                      CreatedDate, ClosedDate, Contact.Id, Contact.FirstName, Contact.Name, Contact.LastName, Contact.Email, Contact.Phone, 
                      Contact.CEN_Direccion__c, Contact.CEN_Distrito__c, CEN_nombre_actualizado__c, CEN_distrito_actualizado__c,
                      CEN_distrito_actualizado__r.Name, CEN_distrito_actualizado__r.Provincia__c, CEN_distrito_actualizado__r.Departamento__c,
                      Contact.CEN_Distrito__r.Name, Contact.CEN_Distrito__r.Provincia__c, Contact.CEN_Distrito__r.Departamento__c, 
                      CEN_direccion_actualizado__c, CEN_celular_actualizado__c, CEN_apellido_actualizado__c, correo_actualizado__c 
                      FROM Case WHERE ID = :caseId LIMIT 1];
        }catch(Exception ex){
            if(record == null){
                System.debug('No se encontró un Case (Interacción) con Id '+caseId+'. Line: '+ex.getLineNumber());
            }
            System.debug('Exc: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        return record;
    }
    @AuraEnabled
    public static String noGestionar(String caseId, String observacion){
        String status = 'NO';
        System.debug('noGestionar');
        System.debug('caseId: '+caseId);
        if(String.isNotBlank(caseId)){
            Case record = null;
            try{
                  record = [SELECT Description, Id, CaseNumber, Subject, ContactId, AccountId, ProductId, ParentId, CEN_flag_postergar_gestion__c,
                      OwnerId, CreatedById, CEN_Activar_Prorroga__c, CEN_Actualizar_Datos__c, IsClosed, Status, Account.Name, CEN_Canal_de_Solucion__c,
                      CreatedDate, ClosedDate, Contact.Id, Contact.FirstName, Contact.Name, Contact.LastName, Contact.Email, Contact.Phone, 
                      Contact.CEN_Direccion__c, Contact.CEN_Distrito__c, CEN_nombre_actualizado__c, CEN_distrito_actualizado__c,
                      CEN_direccion_actualizado__c, CEN_celular_actualizado__c, CEN_apellido_actualizado__c, correo_actualizado__c 
                      FROM Case WHERE ID = :caseId LIMIT 1];
            }catch(Exception ex){
                if(record == null){
                    System.debug('No se encontró un Case (Interacción) con Id '+caseId+'. Line: '+ex.getLineNumber());
                }
                System.debug('Exc: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            }
            if(record!=null){
                String name = '';
                String nameacc = '';
                if(String.isNotBlank(record.Contact.Name)){name = record.Contact.Name;}
                if(String.isNotBlank(record.Account.Name)){nameacc = record.Account.Name;}
                Group grupo=null;
                String ownerid= '';
                try{
                    grupo = [SELECT Id FROM Group WHERE ID=:record.OwnerId LIMIT 1];
                }catch(Exception ex){
                    system.debug('buscar grupo: '+ ex.getMessage()+'. Line: '+ex.getLineNumber());
                }
                if(grupo!=null){
                    if(String.isNotBlank(System.UserInfo.getUserId())){
                        ownerid=System.UserInfo.getUserId();
                    }else{
                        User usuario = null;
                        try{
                            usuario = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'Administrador del sistema' LIMIT 1];
                            ownerid = usuario.Id;
                        }catch(Exception ex){
                            system.debug('buscar admin: '+ ex.getMessage()+'. Line: '+ex.getLineNumber());
                        } 
                    }
                }else{
                    ownerid = record.OwnerId;
                }                
                Task tarea = new Task (Subject = 'Interacción no se gestionó.', Status='En curso', Priority='Normal',
                                       Description = 'No se gestionó la actualización de datos solicitado por el contacto '+name+
                                       ' del cliente '+nameacc+'. Observación: '+observacion, CEN_Canal__c = record.CEN_Canal_de_Solucion__c, 
                                       OwnerId = ownerid, ActivityDate = date.today(), WhatId = record.Id);
                insert tarea;
                System.debug('tarea insertada: '+tarea);
                if(String.isNotBlank(tarea.Id)){
                    status = 'OK';
                }
                record.CEN_Actualizar_Datos__c = false;
                //record.Status = 'Atendido';
                update record;
            }
        }
        return status;
    }
    @AuraEnabled
    public static Response actualizarDatosCliente(String caseId, String distritoId, String nombre, String apellido, String correo, String celular, String direccion){
        System.debug('actualizarDatosCliente');
        System.debug('data entrante: '+caseId+', '+ distritoId+', '+nombre+', '+apellido+', '+ correo+', '+ celular+', '+ direccion);
        
        Response response = new Response();
        response.estado = 'NO';
        response.mensaje = 'No se pudo actualizar los datos del contacto del cliente.';
        response.newcase = null;
        
        Case record = null;
        try{
            record = [SELECT IsDeleted, IsClosed, IsEscalated, CEN_Actualizar_Datos__c, CEN_Activar_Prorroga__c, Fecha_de_Plazo__c, 
                      ClosedDate, CreatedDate, LastModifiedDate, SystemModstamp, LastViewedDate, LastReferencedDate, CEN_Fecha_de_Respuesta__c,
                      CEN_Fecha_de_Atencion__c, CEN_Fecha_de_Prorroga__c, CEN_Fecha_de_Solucion__c, CEN_Hora_Hoy__c, CEN_Dias_transcurridos__c, 
                      CEN_Plazo__c, SuppliedEmail, ContactEmail, Id, ContactPhone, ContactMobile, ContactFax, Type, Status, Reason, Origin, 
                      Contact.Name, Account.Name, Priority, 
                      CEN_Area_de_Solucion_del__c, CEN_Cola__c, CEN_Canal_de_Solucion__c, CEN_Tipo_de_Contacto__c, MasterRecordId, ContactId,
                      AccountId, ProductId, ParentId, OwnerId, CreatedById, LastModifiedById, CaseNumber, SuppliedName, SuppliedPhone,
                      SuppliedCompany, Subject, CEN_OfiAC__c, CEN_Plazo_Dia__c, Id_external__c, Description, Comments FROM Case WHERE ID = :caseId LIMIT 1];
        }catch(Exception ex){
            if(record == null){
                System.debug('No se encontró un Case (Interacción) con Id '+caseId+'. Line: '+ex.getLineNumber());
            }
            System.debug('Exc: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(record!=null){
            String ctname = '';
            String acname = '';            
                if(String.isNotBlank(record.Contact.Name)){ctname = record.Contact.Name;}
                if(String.isNotBlank(record.Account.Name)){acname = record.Account.Name;}
            Tabla_maestra__c distrito = null;
            try{
                distrito = [SELECT CEN_Codigo_distrito__c, CEN_Codigo_provincia__c, CEN_Codigo_departamento__c, Provincia__c,
                            Departamento__c, Id, Name FROM Tabla_maestra__c WHERE Id=:distritoId LIMIT 1];
            }catch(Exception ex){
                System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            }
            if(distrito!=null){
                Contact cuenta = null;            
                if(String.isNotBlank(record.ContactId)){
                    Boolean actualizo = false;
                    try{
                        cuenta = [SELECT Id, FirstName, LastName, Email, Phone, CEN_Direccion__c,
                                  CEN_Distrito__c FROM Contact WHERE Id=:record.ContactId LIMIT 1];
                    }catch(Exception ex){
                        System.debug('Ex insert newcase: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    }
                    try{
                        cuenta.FirstName = nombre;
                        cuenta.LastName = apellido;
                        cuenta.Email = correo;
                        cuenta.Phone = celular;
                        cuenta.CEN_Direccion__c = direccion;
                        cuenta.CEN_Distrito__c = distrito.Id;
                        update cuenta;
                        actualizo = true;
                    }catch(Exception ex){
                        System.debug('Ex update cuenta: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    }
                    if(actualizo){
                        Group grupo=null;
                        String ownerid= '';
                        try{
                            grupo = [SELECT Id FROM Group WHERE ID=:record.OwnerId LIMIT 1];
                        }catch(Exception ex){
                            system.debug('buscar grupo: '+ ex.getMessage()+'. Line: '+ex.getLineNumber());
                        }
                        if(grupo!=null){
                            if(String.isNotBlank(System.UserInfo.getUserId())){
                                ownerid=System.UserInfo.getUserId();
                            }else{
                                User usuario = null;
                                try{
                                    usuario = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'Administrador del sistema' LIMIT 1];
                                    ownerid = usuario.Id;
                                }catch(Exception ex){
                                    system.debug('buscar admin: '+ ex.getMessage()+'. Line: '+ex.getLineNumber());
                                } 
                            }
                        }else{
                            ownerid = record.OwnerId;
                        }
                        Case newcase = new Case(Type='Solicitud', ContactId=record.ContactId, AccountId=record.AccountId, Status='Cerrado', 
                                                Reason='Otros', Origin='Presencial', Subject='Interacción - Otros - Actualizacion de otros datos',
                                                Priority=record.Priority, Description='Se actualizó la información básica del contacto '+ctname+
                                                ' del cliente '+acname, OwnerId=ownerid,CEN_Sub_Categoria__c='Actualización de otros datos',ParentId=caseId,
                                                CEN_Area_Responsable__c='Post venta',CEN_Area_de_Solucion_del__c='Post venta',
                                                CEN_Actualizar_Datos__c=false, CEN_Fecha_de_Respuesta__c=Datetime.now(), CEN_Fecha_de_Atencion__c=record.LastModifiedDate,
                                                CEN_Fecha_de_Solucion__c=Datetime.now(), CEN_Canal_de_Solucion__c='Presencial',
                                                CEN_Tipo_de_Contacto__c='Reactivo', CEN_Tipifica_Solucion__c='Procedente');
                        try{
                            insert newcase;
                        }catch(Exception ex){
                            System.debug('Ex insert newcase: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                            response.mensaje = response.mensaje + '. ' +ex.getMessage();
                        }
                        
                        if(String.isNotBlank(newcase.Id)){
                            System.debug('newcase id: '+newcase.Id);
                            try{
                                record.CEN_Actualizar_Datos__c=false;
                                //record.Status='Cerrado';
                                update record;
                            }catch(Exception ex){
                                System.debug('Ex update case record: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                                response.mensaje = response.mensaje + '. ' +ex.getMessage();
                            }
                            if(record.CEN_Actualizar_Datos__c==false){
                                response.estado = 'OK';
                                response.mensaje = 'Se actualizó los datos de la Interacción.';
                                response.newcase = newcase;
                            }
                        }
                    }
                }       
            }
        }
        System.debug('Response: '+response);
        return response;
    }
    
    public class Response{
        @AuraEnabled public String estado{get;set;}
        @AuraEnabled public String mensaje{get;set;}
        @AuraEnabled public Case newcase{get;set;}
    }
}