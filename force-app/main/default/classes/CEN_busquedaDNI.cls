/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 05-11-2024
 * @last modified by   : Luis Maldonado
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   21-10-2024   Luis Maldonado   Initial Version
 * 1.1   24-10-2025   Jesus Poco       Se agrego SOQL para que traiga solo una cuenta[linea 38]
**/
public without sharing class CEN_busquedaDNI {

    //Search values to first picklist
 	@AuraEnabled
 	public static NivelPagerWrapper getselectDoc(string tipo, string numero) {
 		NivelPagerWrapper obj =  new NivelPagerWrapper();
        
        system.debug('Tipo doc: ' + tipo);
        system.debug('N doc: ' + numero);
        if(String.isNotBlank(tipo)&&tipo=='Sin especificar'){
            obj.Cuenta=new List<Account>();
            obj.Cuentaorgs=new List<Cuentaorg>();
            obj.Prospecto=new List<Lead>();
            obj.Oportunidades=new List<Opportunity>();
            obj.datos=null;
            return obj;
        }
        List<account> Cuenta = [select id, name, FirstName, LastName, PersonEmail, PersonMobilePhone, CEN_Direcci_n__c, CEN_Direccion__pc,
                                CEN_Distrito__pc,CEN_Distrito__c, CEN_Distrito__r.Name, CEN_Distrito__pr.Name, RecordType.Name,
                                CEN_Distrito__pr.CEN_Codigo_distrito__c, CEN_Distrito__pr.CEN_Codigo_provincia__c,
                                CEN_Distrito__pr.CEN_Codigo_departamento__c,CEN_Distrito__pr.Provincia__c,CEN_Distrito__pr.Departamento__c,
                                CEN_Distrito__pr.Id
                                from account 
                                where (CEN_Tipo_de_documento__pc=:tipo AND CEN_N_mero_de_documento__pc=:numero) OR 
                                (CEN_Tipo_de_documento__c=:tipo AND CEN_Numero_de_documento_del__c=:numero) ORDER BY CreatedDate DESC LIMIT 1];
        
        List<Opportunity> Oportunidades = [ SELECT Id, Name, StageName, CloseDate, Amount, AccountId
                                            FROM Opportunity
                                            WHERE AccountId IN :Cuenta
                                            ];

        if(String.isNotBlank(tipo)&&tipo=='RUC'){
            List<Cuentaorg> Cuentaorgs = new List<Cuentaorg>();
            Set<Id> ids_cuentas = new Set<Id>();
            if(Cuenta.size()<30){
                for(Account acc:Cuenta){
                    ids_cuentas.add(acc.Id);
                    Cuentaorgs.add(new Cuentaorg(acc,new List<Contact>()));
                }
                List<Contact> contactos = null;
                try{
                    contactos = [SELECT Id, FirstName, LastName, Name, Phone, Email, CEN_Direccion__c, CEN_Distrito__c, CEN_Distrito__r.Name, CEN_Tipo_de_documento__c ,
                                 CEN_N_mero_de_documento__c, AccountId FROM Contact WHERE AccountId IN :ids_cuentas ORDER BY AccountId ASC LIMIT 50];
                }catch(Exception ex){
                    contactos = new List<Contact>();
                    System.debug('Exception trying get contact: '+ex.getMessage());
                }
                for(Integer i=0;i<Cuentaorgs.size();i++){
                    for(Contact ct:contactos){
                        if(Cuentaorgs[i].cuentap.Id==ct.AccountId){
                            Cuentaorgs[i].contactos.add(ct);
                        }
                    }
                }
            }
            obj.Cuentaorgs=Cuentaorgs;
            System.debug('Cuentaorgs size: '+Cuentaorgs.size());
        }
        
        
        List<lead> Prospecto = [select Id, Name, LastName, FirstName, OwnerId, Owner.Name, CreatedDate, CEN_N_mero_de_documento__c, CEN_Direcci_n_Prospecto__c, CEN_Distrito__c, MobilePhone, Email,
                                CEN_Distrito__r.CEN_Codigo_distrito__c, CEN_Distrito__r.CEN_Codigo_provincia__c, CEN_Distrito__r.CEN_Codigo_departamento__c, 
                                CEN_Distrito__r.Provincia__c, CEN_Distrito__r.Departamento__c, CEN_Distrito__r.Id, CEN_Distrito__r.Name 
                                from lead where (CEN_Tipo_de_documento__c=:tipo AND CEN_N_mero_de_documento__c=:numero) OR (CEN_RUC__c=:numero) 
                                ORDER BY CreatedDate DESC LIMIT 1];
            obj.Cuenta=Cuenta;
            obj.Prospecto=Prospecto;
            obj.Oportunidades=Oportunidades;
        /*<------USANDO RENIEC--------*/
        if(Cuenta.size()==0&&Prospecto.size()==0&&tipo.equals('DNI')){
            try{
                obj.datos = CEN_WS_Consultar_Datos.ReniecDNI(numero);
            }catch(Exception ex){
                System.debug('DNI busqueda error: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                obj.datos = null;
            }
        }
        /*------USANDO RENIEC------->*/

        /*<------BUSQUEDA DE TODOS LOS EVENTOS RELACIONADOS--------*/
        List<RecordType> recordTypes = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Event' 
            AND DeveloperName IN ('CEN_Reunion_presencial_Visita_presencial')
        ];

        Set<Id> recordTypeIds = new Set<Id>();
        for (RecordType rt : recordTypes) {
            recordTypeIds.add(rt.Id);
        }

        List<Event> eventos = [
            SELECT Id, Subject, StartDateTime, EndDateTime, CEN_Asistio_a_Cita__c, CreatedDate, CreatedBy.Name, WhatId, WhoId
            FROM Event
            WHERE (WhatId IN :Cuenta OR WhoId IN :Prospecto OR WhatId IN :Oportunidades)
            AND (
                RecordTypeId IN :recordTypeIds
                OR Subject LIKE '%visita presencial%'
            )
            AND CEN_Estado__c = 'Programado'
            AND ActivityDate >= :System.today().addDays(-7)
            AND ActivityDate <= :System.today().addDays(7)
        ];

        List<Map<String, String>> eventosFormateados = new List<Map<String, String>>();

        for(Event evt : eventos) {
            Map<String, String> eventoMap = new Map<String, String>();
            eventoMap.put('Id', evt.Id);
            eventoMap.put('Subject', evt.Subject);
            
            // Formatear y separar StartDateTime en fecha y hora
            if(evt.StartDateTime != null) {
                eventoMap.put('StartDate', evt.StartDateTime.format('dd/MM/yyyy'));  // Fecha de inicio
                eventoMap.put('StartTime', evt.StartDateTime.format('HH:mm:ss'));    // Hora de inicio
            }

            // Formatear y separar EndDateTime en fecha y hora
            if(evt.EndDateTime != null) {
                eventoMap.put('EndDate', evt.EndDateTime.format('dd/MM/yyyy'));      // Fecha de fin
                eventoMap.put('EndTime', evt.EndDateTime.format('HH:mm:ss'));        // Hora de fin
            }

            // Formatear y separar CreatedDate en fecha y hora
            if(evt.CreatedDate != null) {
                eventoMap.put('CreatedDate', evt.CreatedDate.format('dd/MM/yyyy'));  // Fecha de creación
                eventoMap.put('CreatedTime', evt.CreatedDate.format('HH:mm:ss'));    // Hora de creación
            }

            // Añadir nombre del creador del evento
            if(evt.CreatedBy != null && evt.CreatedBy.Name != null) {
                eventoMap.put('CreatedBy', evt.CreatedBy.Name);  // Nombre del creador
            }

            // Determinar el origen del evento
            if(evt.WhatId != null) {
                if(String.valueOf(evt.WhatId).startsWith('001')) {
                    eventoMap.put('Origen', 'Cuenta');
                } else if(String.valueOf(evt.WhatId).startsWith('006')) {
                    eventoMap.put('Origen', 'Oportunidad');
                }
            } else if(evt.WhoId != null) {
                eventoMap.put('Origen', 'Prospecto');
            }

            eventoMap.put('CEN_Asistio_a_Cita__c', String.valueOf(evt.CEN_Asistio_a_Cita__c));

            eventosFormateados.add(eventoMap);
        }

        obj.eventosFormateados = eventosFormateados;

  		return obj;
  		
 	}
    public class Cuentaorg{        
        @AuraEnabled public Account cuentap {get;set;}
        @AuraEnabled public List<Contact> contactos {get;set;}
        public Cuentaorg(Account acc,List<Contact> cts){
            cuentap=acc;
            contactos=cts;
        }
    }
    
    public class NivelPagerWrapper {        
        @AuraEnabled public List<Account> Cuenta {get;set;}
        @AuraEnabled public List<Cuentaorg> Cuentaorgs {get;set;}
        @AuraEnabled public List<Lead> Prospecto {get;set;}
        @AuraEnabled public List<Opportunity> Oportunidades {get;set;}
        @AuraEnabled public CEN_WS_Consultar_Datos.DatosPersona datos{get;set;}
        @AuraEnabled public List<Map<String, String>> eventosFormateados {get;set;}
   }

   
    
    //Search values to first picklist
 	@AuraEnabled
 	public static String getselectEve(string id, string tipo, string visita, string documento, string Name, string Apellido, string Correo, string Celular, string Direccion, string Distrito, string Atencion, string idct, String oac, String Medio) {
 		
        String idcont =  id;
        String Prioridad = 'Medio';
        
        User u = [select id,Name,ProfileId, Profile.Name,Caseta_de_Venta__c from User where id =: userInfo.getUserId()];
        String perfil = [select Name from profile where id = :u.ProfileId].Name;
        system.debug('Perfil'+perfil);

        if(perfil=='CEN_Anfitriona'){
            
            Event eve = new Event();
            eve.Subject = 'Se generó una nueva Visita Presencial ' + visita;  
            eve.StartDateTime = System.Now();
            eve.EndDateTime = System.Now();
            //eve.Location = u.Caseta_de_Venta__c;
            eve.CEN_Tipo__c = visita;
            eve.CEN_Canal__c = 'Presencial';
            eve.CEN_Medio__c = Medio;
            eve.CEN_Oficina_de_Venta_Aux__c = oac!=null?oac:null;
            eve.Location = oac!=null?oac:null;
            
            if(tipo=='Prospecto'){
                
            eve.WhoId = id;
                
            }else{
                
            eve.WhatId = id;
            
                //Solo si es posteventa
                //Comentando solo por clase test
                if(visita == 'Postventa')
                {
                    //Obteniendo el id por el DNI cuando es cuenta
                    //string idAccount = [select id, Name, PersonEmail, PersonMobilePhone from account where CEN_N_mero_de_documento__pc =: documento].id;	
                    
                    Account CuentaGet = [select id, Name, FirstName, LastName, PersonEmail, PersonMobilePhone, CEN_Direcci_n__c, CEN_Direccion__pc, 
                                         CEN_Distrito__c, CEN_Distrito__r.Name, CEN_Distrito__pc, CEN_Distrito__pr.Name, RecordType.Name, 
                                         CEN_Distrito__r.Provincia__c, CEN_Distrito__r.Departamento__c from account 
                                         where Id=:idcont];
                    System.debug('Id account: '+CuentaGet.Id);
                    System.debug('Idcont: '+idcont);
                    System.debug('idct: '+idct);
                    
                    //Obteniendo el idgrupo
                    string cg ;
                    cg = [select id,Name from Group where Name=: 'Interacciones'].Id;                                                           
                    system.debug(cg); 
                    
                    if(Atencion == 'Preferencial')
                    {
                       Prioridad = 'Alta' ;
                        cg =[select id,Name from Group where Name=: 'Interacciones Prioridad'].Id;
                    }
                    
                    if(idct==null){
                        
                    Contact ContactGet = [select id from contact where CEN_N_mero_de_documento__c =: documento];
                    
                    //Asdfasdfasdf
                    if(Validar_actualizacion_datos_Cuenta(CuentaGet, Name, Apellido, Correo, Celular, Direccion, Distrito))
                    {                                                               
                        //Creando caso
                        Case caseObj = new Case(            
                        AccountId = CuentaGet.Id,
                        ContactId = ContactGet.Id,
                        Priority  = Prioridad,
                        Status = 'Pendiente',
                        Origin = 'Presencial',
                        Subject = 'Interacción automática - Actualización de Datos',
                        CEN_Actualizar_Datos__c=true,
                        OwnerId = cg, 
                        //Type='Solicitud',
                        CEN_apellido_actualizado__c=Apellido!=null?Apellido:null,
                        CEN_celular_actualizado__c=Celular!=null?Celular:null,
                        correo_actualizado__c=Correo!=null?Correo:null,
                        CEN_direccion_actualizado__c=Direccion!=null?Direccion:null,
                        CEN_nombre_actualizado__c=Name!=null?Name:null,
                        CEN_distrito_actualizado__c=Distrito!=null?Distrito:null,
                        CEN_Oficina_de_Venta__c = oac!=null?oac:null);
                         
                        //Guardando Caso
                        System.debug('caseObj: '+caseObj);
                        insert caseObj;
                        caseObj = [select id, casenumber from case where id = : caseObj.id];
                        eve.Description = eve.Description!=null?eve.Description+'. ':'' + 'N° Interacción '+caseObj.casenumber;
                        System.debug('case number' + caseObj.casenumber); 
                    }
                   	else
                   	{
                        
                        //Creando caso
                        Case caseObj = new Case(            
                        AccountId = CuentaGet.Id,
                        ContactId = ContactGet.Id,
                        Status = 'Pendiente',
                        Origin = 'Presencial',
                        Subject = 'Interación automatica',
                        OwnerId = cg,
                        CEN_Oficina_de_Venta__c = oac!=null?oac:null);
                       
                        //Guardando Caso
                        insert caseObj;
                        caseObj = [select id, casenumber from case where id = : caseObj.id];
                        eve.Description = eve.Description!=null?eve.Description+'. ':'' + 'N° Interacción '+caseObj.casenumber;
                        System.debug('case number' + caseObj.casenumber); 
                   	}
                    }else{
                        
                        Contact contacto = [SELECT Id, FirstName, LastName, Name, Phone, Email, CEN_Direccion__c, CEN_Distrito__c, 
                                            CEN_Distrito__r.Name, CEN_Tipo_de_documento__c, CEN_N_mero_de_documento__c
                                            from contact where Id =: idct];
                        if(Validar_actualizacion_datos_Contacto(contacto, Name, Apellido, Correo, Celular, Direccion, Distrito)){
                            //Creando caso
                            Case caseObj = new Case(            
                            AccountId = CuentaGet.Id,
                            ContactId = contacto.Id,
                            Priority  = Prioridad,
                            Status = 'Pendiente',
                            Origin = 'Presencial',
                            Subject = 'Interacción automática - Actualización de Datos',
                            CEN_Actualizar_Datos__c=true,
                            OwnerId = cg, 
                            //Type='Solicitud',
                            CEN_apellido_actualizado__c=Apellido!=null?Apellido:null,
                            CEN_celular_actualizado__c=Celular!=null?Celular:null,
                            correo_actualizado__c=Correo!=null?Correo:null,
                            CEN_direccion_actualizado__c=Direccion!=null?Direccion:null,
                            CEN_nombre_actualizado__c=Name!=null?Name:null,
                            CEN_distrito_actualizado__c=Distrito!=null?Distrito:null,
                                CEN_Oficina_de_Venta__c = oac!=null?oac:null);
                             
                            //Guardando Caso
                            insert caseObj;
                            caseObj = [select id, casenumber from case where id = : caseObj.id];
                            eve.Description = eve.Description!=null?eve.Description+'. ':'' + 'N° Interacción '+caseObj.casenumber;
                            System.debug('case number "actualizar": ' + caseObj.casenumber); 
                        }
                        else
                        {
                            
                            //Creando caso
                            Case caseObj = new Case(            
                            AccountId = CuentaGet.Id,
                            ContactId = contacto.Id,
                            Status = 'Pendiente',
                            Origin = 'Presencial',
                            Subject = 'Interación automatica',
                            OwnerId = cg,
                            CEN_Oficina_de_Venta__c = oac!=null?oac:null);
                           
                            //Guardando Caso
                            insert caseObj;
                            caseObj = [select id, casenumber from case where id = : caseObj.id];
                            eve.Description = eve.Description!=null?eve.Description+'. ':'' + 'N° Interacción '+caseObj.casenumber;
                            System.debug('case number' + caseObj.casenumber); 
                        }
                    }
                }                                      
            }
            eve.OwnerId = u.Id;
            system.debug('Evento'+eve);
            insert eve;
            
        }else if(perfil=='CEN_Callcenter'){
            /*
            Task tar = new Task();
            tar.Subject = 'Se generó un Registro de llamada '  + visita; 
            tar.ActivityDate = system.today();
            tar.Status = 'Completed';
            if(tipo=='Prospecto'){
            tar.WhoId = id;
            }else{
            tar.WhatId = id;
            }
            tar.OwnerId = u.Id;
            system.debug('Evento'+tar);
            insert tar;
            */
           if(tipo!='Prospecto'){
               
                 if(visita == 'Postventa'){
                System.debug('La visita es Postventa');
               //Obteniendo el idgrupo
                    string cg ;
                    cg = [select id,Name from Group where Name=: 'Interacciones'].Id;                                                           
                    system.debug(cg); 
                    
                    if(Atencion == 'Preferencial')
                    {
                       Prioridad = 'Alta' ;
                        cg =[select id,Name from Group where Name=: 'Interacciones Prioridad'].Id;
                    }
               
                Case caseObj = new Case(
                    Priority  = Prioridad,
                    Status = 'Pendiente',
                    Origin = 'Call Center',
                    Subject = 'Interacción automática',
                    OwnerId = cg,
                    CEN_Oficina_de_Venta__c = oac!=null?oac:null);
               
               Account acc = null;
               Contact cnt = null;
               try{
                   acc = [SELECT Id, Name, FirstName, LastName, PersonEmail, PersonMobilePhone, CEN_Direcci_n__c, CEN_Direccion__pc,
                          CEN_Distrito__c, CEN_Distrito__r.Name, CEN_Distrito__pc, CEN_Distrito__pr.Name, RecordType.Name, 
                          CEN_Distrito__r.Provincia__c, CEN_Distrito__r.Departamento__c, PersonContactId FROM Account WHERE Id=:id LIMIT 1];
               }catch(Exception ex){
                   System.debug('Trying get account: '+ex.getMessage()+ 'Line: '+ex.getLineNumber());
               }
               if(acc!=null && acc.RecordType.Name=='Cuenta Natural'){
                   caseObj.AccountId=acc.Id;
                   caseObj.ContactId = acc.PersonContactId ;
                   if(Validar_actualizacion_datos_Cuenta(acc, Name, Apellido, Correo, Celular, Direccion, Distrito)){
                       caseObj.Subject+=' - Actualización de Datos';
                       caseObj.CEN_Actualizar_Datos__c=true;
                       caseObj.CEN_apellido_actualizado__c=String.isNotBlank(Apellido)?Apellido:null;
                       caseObj.CEN_celular_actualizado__c=String.isNotBlank(Celular)?Celular:null;
                       caseObj.correo_actualizado__c=String.isNotBlank(Correo)?Correo:null;
                       caseObj.CEN_direccion_actualizado__c=String.isNotBlank(Direccion)?Direccion:null;
                       caseObj.CEN_nombre_actualizado__c=String.isNotBlank(Name)?Name:null;
                       caseObj.CEN_distrito_actualizado__c=String.isNotBlank(Distrito)?Distrito:null;
                   }
               }else if(acc!=null&&acc.RecordType.Name!='Cuenta Natural'){
                    caseObj.AccountId=acc.Id;
                   if(String.isNotBlank(idct)){
                        try{
                           cnt = [SELECT Id, FirstName, LastName, Name, Phone, Email, CEN_Direccion__c, CEN_Distrito__c,
                                  CEN_Distrito__r.Name, CEN_Tipo_de_documento__c, CEN_N_mero_de_documento__c FROM Contact WHERE Id=:idct LIMIT 1];
                       }catch(Exception ex){
                           System.debug('Trying get contact: '+ex.getMessage()+ 'Line: '+ex.getLineNumber());
                       }
                       if(cnt!=null){
                           caseObj.ContactId=cnt.Id;
                           if(Validar_actualizacion_datos_Contacto(cnt, Name, Apellido, Correo, Celular, Direccion, Distrito)){
                               caseObj.Subject+=' - Actualización de Datos';
                               caseObj.CEN_Actualizar_Datos__c=true;
                               caseObj.CEN_apellido_actualizado__c=String.isNotBlank(Apellido)?Apellido:null;
                               caseObj.CEN_celular_actualizado__c=String.isNotBlank(Celular)?Celular:null;
                               caseObj.correo_actualizado__c=String.isNotBlank(Correo)?Correo:null;
                               caseObj.CEN_direccion_actualizado__c=String.isNotBlank(Direccion)?Direccion:null;
                               caseObj.CEN_nombre_actualizado__c=String.isNotBlank(Name)?Name:null;
                               caseObj.CEN_distrito_actualizado__c=String.isNotBlank(Distrito)?Distrito:null;
                           }
                       }
                   }
               }
               //Guardando Caso
               insert caseObj;
                     System.debug('case number' + caseObj.casenumber); 
                 }
           }            
        }
  		return idcont;
 	}    
    
    public static Boolean Validar_actualizacion_datos_Contacto(Contact contacto, String Name, String Apellido, String Correo, String Celular, String Direccion, String Distrito){
        Integer cambios=0;
        if(contacto.FirstName != Name)
        {
            cambios++;
        }                        
        if(contacto.LastName != Apellido)
        {
            cambios++;
        }                        
        if(contacto.Email != Correo)
        {
            cambios++;
        }                        
        if(contacto.Phone != Celular)
        {
            cambios++;
        }                       
        if(contacto.CEN_Direccion__c != Direccion)
        {
            cambios++;
        }
        if(contacto.CEN_Distrito__c != Distrito)
        {
            cambios++;
        }
        if(cambios>0){return true;}
        return false;
    }
    public static Boolean Validar_actualizacion_datos_Cuenta(Account CuentaGet, String Name, String Apellido, String Correo, String Celular, String Direccion, String Distrito){
        Integer cambios=0;
                    if(CuentaGet.FirstName != Name)
                    {
                        cambios++;
                    }
                    
                    if(CuentaGet.LastName != Apellido)
                    {
                         cambios++;
                    }
                    
                    if(CuentaGet.PersonEmail != Correo)
                    {
                        cambios++;
                    }
                    
                    if(CuentaGet.PersonMobilePhone != Celular)
                    {
                         cambios++;
                    }
                   
                    if(CuentaGet.CEN_Direccion__pc != Direccion)
                    {
                         cambios++;
                    }
                    if(CuentaGet.RecordType.Name=='Cuenta Natural'){
                        if(CuentaGet.CEN_Distrito__pc != Distrito)
                        {
                             cambios++;                           
                        }
                    }else{
                        if(CuentaGet.CEN_Distrito__c != Distrito)
                        {
                             cambios++;
                        }
                    }
        if( cambios>0){return true;}
        return false;
    }
    
	@AuraEnabled
    public static Tabla_maestra__c buscarDistritobyId(String distritoId){
        System.debug('buscarDistritobyId: '+distritoId);
        Tabla_maestra__c distrito = null;
        try{
            distrito = [SELECT CEN_Codigo_distrito__c, CEN_Codigo_provincia__c, CEN_Codigo_departamento__c, Provincia__c,
                        Departamento__c, Id, Name FROM Tabla_maestra__c WHERE Id=:distritoId LIMIT 1];
        }catch(Exception ex){
            System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        System.debug('distrito: '+distrito);
        return distrito;
    }
    
    @AuraEnabled 
    public static String registrarVisitaDeTercero(String TipoDoc, String Ndoc, String Nombres, String Apellidos, String Direccion, String Distrito, String Correo, String Celular, String TipoDeAtencion, String oac){
        System.debug('<!--registrarVisitaDeTercero');
        String response = '';
        String Prioridad = 'Medio';
        
        User u = [select id,Name,ProfileId, Profile.Name,Caseta_de_Venta__c from User where id =: userInfo.getUserId()];
        String perfil = [select Name from profile where id = :u.ProfileId].Name;
        system.debug('Perfil: '+perfil);
                      
        string cg;
        cg = [select id,Name from Group where Name=: 'Interacciones'].Id;                                                           
        system.debug(cg);         
        if(TipoDeAtencion == 'Preferencial')
        {
            Prioridad = 'Alta' ;
            cg =[select id,Name from Group where Name=: 'Interacciones Prioridad'].Id;
        }
        RecordType record_type = null;
        try{
            record_type = [SELECT Id, Name FROM RecordType WHERE Name='Tercero' LIMIT 1];
        }catch(Exception ex){
            system.debug('record_type exception: '+ex.getMessage());
        }
        Event eve = new Event();
        eve.Subject = 'Se generó una nueva Visita Presencial Postventa';  
        eve.StartDateTime = System.Now();
        eve.EndDateTime = System.Now();
        eve.Location = u.Caseta_de_Venta__c;
        eve.CEN_Tipo__c = 'Postventa';
        eve.CEN_Canal__c = 'Presencial';
        eve.OwnerId=u.Id;       
        
        
        if(perfil=='CEN_Anfitriona'&&record_type!=null){
            
            eve.CEN_Oficina_de_Venta_Aux__c = oac!=null?oac:null;
            eve.Location = oac!=null?oac:null;
            
            System.debug('Es anfitriona');
                        Case caseObj = new Case(
                        Priority  = Prioridad,
                        Status = 'Pendiente',
                        Origin = 'Presencial',
                        Subject = 'Interacción - Visita de Tercero',
                        OwnerId = cg, 
                            RecordTypeId=record_type.Id,
                        CEN_Tipo_de_documento__c=String.isNotBlank(TipoDoc)?TipoDoc:null,
                            N_mero_de_documento__c=String.isNotBlank(Ndoc)?Ndoc:null,
                        CEN_apellido_actualizado__c=String.isNotBlank(Apellidos)?Apellidos:null,
                        CEN_celular_actualizado__c=String.isNotBlank(Celular)?Celular:null,
                        correo_actualizado__c=String.isNotBlank(Correo)?Correo:null,
                        CEN_direccion_actualizado__c=String.isNotBlank(Direccion)?Direccion:null,
                        CEN_nombre_actualizado__c=String.isNotBlank(Nombres)?Nombres:null,
                        CEN_distrito_actualizado__c=String.isNotBlank(Distrito)?Distrito:null,
                            CEN_Oficina_de_Venta__c = oac!=null?oac:null);
                         
                        //Guardando Caso
                        insert caseObj;
                        caseObj = [select id, casenumber from case where id = : caseObj.id];
            eve.WhatId=caseObj.Id;
            eve.Description = eve.Description!=null?eve.Description+'. ':'' + 'N° Interacción '+caseObj.casenumber;
            response= 'Se registró exitosamente la interacción ' + caseObj.casenumber + '.';
                        System.debug('case number' + caseObj.casenumber); 
            try{
                insert eve;
            }catch(Exception ex){
                System.debug('exception: ' + ex.getMessage() +'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName()); 
            }
        }
        else if(perfil=='CEN_Callcenter'){
            System.debug('Es Callcenter');
          
            Case caseObj = new Case(
                        Priority  = Prioridad,
                        Status = 'Pendiente',
                       Origin = 'Call Center',
                            Subject = 'Interacción automática - Visita de tercero - Call Center',
                        OwnerId = cg, 
                            RecordTypeId=record_type.Id,
                        CEN_Tipo_de_documento__c=String.isNotBlank(TipoDoc)?TipoDoc:null,
                            N_mero_de_documento__c=String.isNotBlank(Ndoc)?Ndoc:null,
                        CEN_apellido_actualizado__c=String.isNotBlank(Apellidos)?Apellidos:null,
                        CEN_celular_actualizado__c=String.isNotBlank(Celular)?Celular:null,
                        correo_actualizado__c=String.isNotBlank(Correo)?Correo:null,
                        CEN_direccion_actualizado__c=String.isNotBlank(Direccion)?Direccion:null,
                        CEN_nombre_actualizado__c=String.isNotBlank(Nombres)?Nombres:null,
                        CEN_distrito_actualizado__c=String.isNotBlank(Distrito)?Distrito:null,
                CEN_Oficina_de_Venta__c = oac!=null?oac:null);
              insert caseObj;
            response= 'Se registró exitosamente la interacción ' + caseObj.casenumber + '.';
                System.debug('case number' + caseObj.casenumber); 
            
        }
        
        System.debug('--!>registrarVisitaDeTercero');
        return response;                               
    }
    
    //	Valida si el perfil del usuario debe usar Seleccionador OAC
    @AuraEnabled
    public static Boolean getObligacionElegirOAC(){
        System.debug('<!--getObligacionElegirOAC');
        Boolean response = false;
        String perfiles_str = label.CEN_lbl_busqueda_oac_perfiles;
        List<String> perfiles_list = perfiles_str.split(',');
        for(String pstr:perfiles_list){
            pstr = pstr.trim();
        }
        Profile perfil = [SELECT Id, Name FROM Profile WHERE Id=:System.UserInfo.getProfileId() LIMIT 1];
        response =perfiles_list.contains(perfil.Name);
        System.debug('-->getObligacionElegirOAC: '+response);
        return response;
    }
    
    //	Obtiene el picklist global de OACs
    @AuraEnabled
    public static List<PickListWrapper> getOACs(){
        System.debug('<!--getOACs');
        //	Get values de picklist
        List<PickListWrapper> picklist = new List<PickListWrapper>();
        Schema.sObjectField picklistUsingGlobal = null;
        List<Schema.PicklistEntry> entries = null;
        //	Insertar picklist default
        
        //picklistUsingGlobal = Lead.CEN_Oficina_de_Venta2__c;
        //picklistUsingGlobal = Case.CEN_Oficina_de_Venta__c;
        picklistUsingGlobal = Event.CEN_Oficina_de_Venta_Aux__c;
        
        entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        //	Iterar picklist
        for(Schema.PicklistEntry spe:entries){
            if(spe.isActive()){
                PickListWrapper plw = new PickListWrapper();
                plw.label = spe.getLabel().toUpperCase();
                plw.value = spe.getValue();
                plw.selected = false;
                picklist.add(plw);
            }
        }
        System.debug('-->getOACs: '+picklist.size());
        return picklist;
    }

    @AuraEnabled
    public static List<PickListWrapper> getMedio(){
        System.debug('<!--getMedio');
        //	Get values de picklist
        List<PickListWrapper> picklist = new List<PickListWrapper>();
        Schema.sObjectField picklistUsingGlobal = null;
        List<Schema.PicklistEntry> entries = null;
        //	Insertar picklist default
        
        //picklistUsingGlobal = Lead.CEN_Oficina_de_Venta2__c;
        //picklistUsingGlobal = Case.CEN_Oficina_de_Venta__c;
        picklistUsingGlobal = Event.CEN_Medio__c;
        
        entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        //	Iterar picklist
        for(Schema.PicklistEntry spe:entries){
            if(spe.isActive()){
                PickListWrapper plw = new PickListWrapper();
                plw.label = spe.getLabel().toUpperCase();
                plw.value = spe.getValue();
                plw.selected = false;
                picklist.add(plw);
            }
        }
        System.debug('-->getMedio: '+picklist.size());
        return picklist;
    }
    public class PickListWrapper{
        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public Boolean selected{get;set;}
    }

    @AuraEnabled
    public static string createNewEventAutomaticPresencial(string id, string tipo, string visita, String oac, String Medio){
        System.debug('entro createNewEvent');
        String idcont =  id;
        String Prioridad = 'Medio';

        User u = [select id,Name,ProfileId, Profile.Name,Caseta_de_Venta__c from User where id =: userInfo.getUserId()];
        String perfil = [select Name from profile where id = :u.ProfileId].Name;
        system.debug('Perfil createNewEvent'+perfil);

        List<RecordType> recordTypes = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Event' 
            AND DeveloperName IN ('CEN_Reunion_presencial_Visita_presencial')
        ];

        Set<Id> recordTypeIds = new Set<Id>();
        for (RecordType rt : recordTypes) {
            recordTypeIds.add(rt.Id);
        }
    
        List<Event> events = [
            SELECT Id
            FROM Event
            WHERE WhoId = :idcont
            AND (
                RecordTypeId IN :recordTypeIds
                OR Subject LIKE '%visita presencial%'
            )
            AND CEN_Estado__c = 'Programado'
            AND ActivityDate >= :System.today().addDays(-7)
            AND ActivityDate <= :System.today().addDays(7)
        ];

        
        system.debug('pasó la lista createNewEvent');
        //String idevent = events[0].Id;

        //system.debug('idconttest ehhhh: '+events);

        system.debug('Perfil es createNewEvent: '+perfil);
        system.debug('Tipo de venta es createNewEvent: '+visita);
        system.debug('Tipo de solicitud es createNewEvent: '+tipo);

        String idEventoCreado = null;

        if((perfil == 'CEN_Anfitriona' || perfil == 'System Administrator') && events.isEmpty()){
            system.debug('entró a la logica anfitriona createNewEvent');
            Event eve = new Event();
            eve.Subject = 'Se generó una nueva Visita Presencial - Automático';
            eve.StartDateTime = System.Now();
            eve.EndDateTime = System.Now();
            //eve.Location = u.Caseta_de_Venta__c;
            eve.CEN_Tipo__c = visita;
            eve.CEN_Asistio_a_Cita__c = true;
            eve.CEN_Canal__c = 'Presencial';
            eve.CEN_Estado__c = 'Programado';
            eve.Evento_Programado__c = 'Reunión presencial (visita presencial)';
            eve.RecordTypeId = recordTypeIds.iterator().next();
            eve.CEN_Medio__c = Medio;
            eve.CEN_Oficina_de_Venta_Aux__c = oac!=null?oac:null;
            eve.Location = oac!=null?oac:null;

            if(tipo=='Prospecto '){
                system.debug('entró a prospecto');
                eve.WhoId = id;  
            }else{
                system.debug('entró a cuenta');    
                eve.WhatId = id;
            }
            // Inserción del evento
            try {
                insert eve;
                System.debug('Evento creado con éxito: ' + eve.Id);
                idEventoCreado =  eve.Id;
                System.debug('id evento para aura: ' + idEventoCreado);
                System.debug('evento programado para aura: ' + eve.Evento_Programado__c);
            } catch (Exception e) {
                System.debug('Error al crear el evento: ' + e.getMessage());
            }
        } else {
            System.debug('El perfil no coincide con CEN_Anfitriona o la lista no está vacía o es postventa o venta');
            System.debug(events);
            System.debug(perfil);
            System.debug(visita);
        }
        
        return idEventoCreado;
    }

    @AuraEnabled
    public static string confirmarAsistenciaDeEvento(string id){
        String eventId =  id;

        List<Event> events = [
            SELECT Id, CEN_Asistio_a_Cita__c, OwnerId
            FROM Event
            WHERE Id = :eventId
        ];

        //String previousOwner = events[0].OwnerId;
        // Verificar si se encontró algún evento
        if (!events.isEmpty()) {
            Event evt = events[0];  // Obtener el primer evento de la lista
            //evt.OwnerId = UserInfo.getUserId();
            evt.CEN_Asistio_a_Cita__c = true;  // Actualizar el campo de asistencia
            try {
                update evt;
                return evt.Id;
            } catch (DmlException e) {
                return 'Error al confirmar la asistencia: ' + e.getMessage();
            }
        } else {
            return 'No se encontró ningún evento para confirmar la asistencia';
        }
    }

}