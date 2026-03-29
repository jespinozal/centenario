@isTest
public class CEN_cls_TestClass_DF {
    
    public static List<Lead> getLeads(){
        List<Lead> prospectos = new List<Lead>();
        
        Lead olead= new Lead();
        olead.FirstName='A00001 b';
        olead.LastName='Guerrero';
        olead.CEN_Tipo_de_documento__c = 'DNI';
        olead.CEN_N_mero_de_documento__c = '86954785';
        olead.Email = 'rm.gh@hotmail.com';
        olead.MobilePhone = '+51999966251';
        olead.Company = 'protiviti';
        olead.CEN_Direcci_n_Prospecto__c = 'prueba';
        olead.CEN_Comentario__c = 'prueba';
        olead.LeadSource = 'Presencial';
        olead.CEN_Medio__c = '0110';
        prospectos.add(olead);
        
        Lead olead2= new Lead();
        olead2.FirstName='A00002 marcell';
        olead2.LastName='Guerrero';
        olead2.CEN_Tipo_de_documento__c = 'Sin especificar';
        olead2.CEN_N_mero_de_documento__c = '00000000';
        olead2.Email = 'rmmm.gh@hotmail.com';
        olead2.MobilePhone = '+51972715765';
        olead2.Company = 'protiviti';
        olead2.CEN_Direcci_n_Prospecto__c = 'prueba';
        olead2.CEN_Comentario__c = 'prueba';
        olead2.CEN_No_brindo_datos__c=true;
        olead2.LeadSource = 'Presencial';
        olead2.CEN_Medio__c = '0110';
        prospectos.add(olead2);
        
        Lead olead3= new Lead();
        olead3.FirstName='A00003 martin marcell';
        olead3.LastName='Guerrero';
        olead3.CEN_Tipo_de_documento__c = 'DNI';
        olead3.CEN_N_mero_de_documento__c = '00000001';
        olead3.Email = 'rmmm.gh2@hotmail.com';
        olead3.MobilePhone = '+51999845632';
        olead3.Company = 'protiviti';
        olead3.CEN_Direcci_n_Prospecto__c = 'prueba';
        olead3.CEN_Comentario__c = 'prueba';
        olead3.CEN_No_brindo_datos__c=true;
        olead3.LeadSource = 'Presencial';
        olead3.CEN_Medio__c = '0110';
        prospectos.add(olead3);
        
        Lead olead4= new Lead();
        olead4.FirstName='A00004 martin marcell';
        olead4.LastName='Guerrero';
        olead4.CEN_Tipo_de_documento__c = 'DNI';
        olead4.CEN_N_mero_de_documento__c = '56900000';
        olead4.Email = 'rmmm.gh3@hotmail.com';
        olead4.MobilePhone = '+51972715765';
        olead4.Company = 'protiviti';
        olead4.CEN_Direcci_n_Prospecto__c = 'prueba';
        olead4.CEN_Comentario__c = 'prueba';
        olead4.CEN_No_brindo_datos__c=true;
        olead4.CEN_RUC__c='12547896584';
        olead4.Company='Prot';
        olead4.LeadSource = 'Presencial';
        olead4.CEN_Medio__c = '0110';
        prospectos.add(olead4);
        
        return prospectos;
    }    
    public static List<Event> getEvents(){
        List<Event> eventos = new List<Event>();
        Event oEvent1 = new Event();
         oEvent1.Subject = 'A00001 Se generó una nueva Visita Presencial ';  
         oEvent1.StartDateTime = System.Now();
         oEvent1.EndDateTime = System.Now();
         oEvent1.CEN_Tipo__c = 'Venta';
         oEvent1.CEN_Canal__c = 'Presencial';
         oEvent1.CEN_Medio__c = '0110';
         //oEvent1.WhoId = olead2.Id;
         oEvent1.CEN_Oficina__c = 'ZV022';
         oEvent1.Description = 'ranked';
         oEvent1.OwnerId = '0054T000001EuBPQA0';
        eventos.add(oEvent1);
        
        Event oEvent2 = new Event();
        oEvent2.Subject = 'A00002 Se generó una nueva Visita Presencial ';  
        oEvent2.StartDateTime = System.Now();
        oEvent2.EndDateTime = System.Now();
        oEvent2.CEN_Tipo__c = 'Venta';
        oEvent2.CEN_Canal__c = 'Presencial';
        oEvent2.CEN_Medio__c = '0110';
        //oEvent2.WhoId = oAccount8.PersonContactId;
        oEvent2.CEN_Oficina__c = 'ZV022';
        oEvent2.Description = 'ranked';
        oEvent2.OwnerId = '0054T000001EuBPQA0';
        eventos.add(oEvent2);
        
        return eventos;
    }    
    public static List<Account> getAccounts(){
        String RecTypeId = [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        List<Account> cuentas = new List<Account>();
        Account oAccount= new Account();
        oAccount.FirstName='A00001 Martin';
        oAccount.LastName='Guerrero';
        oAccount.CEN_Tipo_de_documento__pc = 'DNI';
        oAccount.CEN_N_mero_de_documento__pc = '86954786';
        oAccount.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti';
        oAccount.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount.CEN_Direcci_n__c = 'Protiviti';
        oAccount.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount.RecordTypeId= RecTypeId;
        cuentas.add(oAccount);
        
        Account oAccount2= new Account();
        oAccount2.FirstName='A00002 Martin';
        oAccount2.LastName='Guerrero';
        oAccount2.CEN_Tipo_de_documento__pc = 'DNI';
        oAccount2.CEN_N_mero_de_documento__pc = '86954785';
        oAccount2.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti';
        oAccount2.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount2.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount2.CEN_Direcci_n__c = 'Protiviti';
        oAccount2.Prospecto_acept_t_rminos_y_condiciones__c=false;
        //oAccount2.OwnerId=u.Id;
        oAccount2.RecordTypeId= RecTypeId;
        cuentas.add(oAccount2);
        
        Account oAccount8= new Account();
        oAccount8.FirstName='A00003 protiviti';
        oAccount8.LastName='salesforce';
        oAccount8.CEN_Tipo_de_documento__pc = 'DNI';
        oAccount8.CEN_N_mero_de_documento__pc = '70119903';
        oAccount8.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti';
        oAccount8.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount8.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount8.CEN_Direcci_n__c = 'Protiviti';
        oAccount8.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount8.RecordTypeId= RecTypeId;
        cuentas.add(oAccount8);
        
        return cuentas;
    }    
    public static List<User> getUsers(){
        List<User> usuarios = new List<User>();
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Anfitriona'].Id,
             LastName = 'A00001 last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV022',
             LocaleSidKey = 'en_US'
            
        );
        usuarios.add(u);
        
        User u2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Callcenter'].Id,
             LastName = 'A00002 last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV022',
             LocaleSidKey = 'en_US'
            
        );
        usuarios.add(u2);
        
        return usuarios;
    }    
    public static List<Tabla_maestra__c> getDistritos(){
        List<Tabla_maestra__c> distritos = new List<Tabla_maestra__c>();
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='A0001 Lima', 
                                                         Departamento__c='Lima', 
                                                         Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', 
                                                         CEN_Codigo_provincia__c='1501', 
                                                         CEN_Codigo_distrito__c='150105');
        distritos.add(distrito);
        
        Tabla_maestra__c t1 = new Tabla_maestra__c();
        t1.Name='A0002 prueba';
        t1.Departamento__c='prueba';
        t1.Provincia__c='prueba';
        t1.CEN_Codigo_departamento__c='01';
        t1.CEN_Codigo_distrito__c='01';
        t1.CEN_Codigo_provincia__c='01';
        distritos.add(t1);
        
        return distritos;
    }    
    public static List<Attachment> getAttachments(){
        List<Attachment> attachments = new List<Attachment>();
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        //attach.parentId=oAccount2.id;
        attachments.add(attach);
        return attachments;
    }    
    public static List<Opportunity> getOpportunities(){
        List<Opportunity> oportunidades = new List<Opportunity>();
        Opportunity opp1= new Opportunity();
        opp1.name='prueba';
        //opp1.AccountId=oAccount2.id;
        opp1.StageName='Cotizacion';
        opp1.CloseDate=System.today();
        oportunidades.add(opp1);
        return oportunidades;
    }    
    public static List<Proyecto__c> getProyectos(){
        List<Proyecto__c> proyectos = new List<Proyecto__c>();
        Proyecto__c proyecto = new Proyecto__c();
        proyecto.CEN_Descripci_n_proyecto__c='LAS PALMERAS ETAPA 4';
        proyecto.CEN_FchInicio__c = Date.newInstance(2018, 5, 23);
        proyecto.CEN_Fecha_entrega__c = Date.newInstance(2019, 12, 20);
        proyecto.CEN_Sociedad__c = '0010';
        proyecto.CEN_Status_del_proyecto__c = 'Liberados';
        proyecto.CEN_Etapa__c = '4';
        proyecto.CEN_Area__c = '55054,34';
        //proyecto.CEN_Distrito__c;
        //proyecto.CEN_Departamento__c = 'Piura';
        //proyecto.CEN_Provincia__c = 'Piura';
        proyecto.CEN_CODIGOSAP__c = '10U1.231E';
        proyecto.Name = 'Las Palmeras Etapa 4';
        proyectos.add(proyecto);
        return proyectos;
    }
    public static List<Product2> getProducts(){
        List<Product2> productos = new List<Product2>();
        Product2  prod= new Product2 ();
        prod.Name='LAS PALMERAS ETAPA 4 Mz.F Lt.06';
        prod.CODLOTE__c='840001257';
        prod.IsActive =true;
        prod.DESCRIPCIONLOTE__c = 'LAS PALMERAS ETAPA 4 Mz.F Lt.06';
        productos.add(prod);
        return productos;
    }
    public static List<Pricebook2> getPricebook2s(){
        List<Pricebook2> registros = new List<Pricebook2>();
        Pricebook2 priceb= new Pricebook2();
        priceb.name='Standard Price Book';
        priceb.IsActive=true;
        registros.add(priceb);
        return registros;
    }
    public static List<PricebookEntry> getPricebookEntries(){
        List<PricebookEntry> registros = new List<PricebookEntry>();
        PricebookEntry  pric= new PricebookEntry ();
        //pric.Product2ID=prod.id;
        //pric.Pricebook2Id=pricebookId;
        pric.UnitPrice =20000;
        pric.IsActive=true;
        registros.add(pric);
        return registros;
    }
    public static List<Case> getCases(){
        List<Case> registros = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Interacción - Entrega de documentos - Cláusula de prepago';
        caso.Description = 'El cliente quiere la entrega de sus documentos por correo.';
        caso.Status = 'En proceso';
        //caso.ContactId = cuentas[2].PersonContactId;
        caso.CEN_Actualizar_Datos__c = true;
        caso.Reason = 'Entrega de documentos';
        caso.CEN_Sub_Categoria__c ='Cláusula de prepago';
        caso.Origin ='Presencial';
        caso.Type ='Solicitud';
        caso.CEN_Area_Responsable__c = 'Post venta';
        registros.add(caso);
        return registros;
    }
}