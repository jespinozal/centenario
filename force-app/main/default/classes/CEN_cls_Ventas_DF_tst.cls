/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-04-2021
 * @last modified by  : Luis Maldonado
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-04-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_cls_Ventas_DF_tst {
public static List<User> getUsers(){
        List<User> registros = new List<User>();
        User u9 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Asesor_de_ventas_urbano'].Id,
            LastName = 'A0001 Anfitriona',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV023',
            LocaleSidKey = 'en_US',
            CorreoAD__c='ASESOR1@TEST.TEST',
            CEN_UserNameAD__c ='ASESOR1'
        );
        registros.add(u9);
        User u10 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_de_ventas_urbano'].Id,
            LastName = 'A0002 Supervisor',
            Email = 'onbasedev@centenario.com.pe',
            Username = 'onbasedev@centenario.com.pe' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV023',
            LocaleSidKey = 'en_US',
            CorreoAD__c='SUPERVISOR1@TEST.TEST',
            CEN_UserNameAD__c ='SUPERVISOR1'
        );
        registros.add(u10);
        return registros;
    }
    public static List<Tabla_maestra__c> getDistritos(){
        List<Tabla_maestra__c> registros = new List<Tabla_maestra__c>();
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', 
                                                         Departamento__c='Lima', 
                                                         Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', 
                                                         CEN_Codigo_provincia__c='1501', 
                                                         CEN_Codigo_distrito__c='150105');
        registros.add(distrito);
        return registros;
    }
    public static List<Account> getAccounts(){        
        List<Account> registros = new List<Account>();
        
        String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        String RecTypeIdCJ= [select Id from RecordType where (Name='Cuenta Jurídica') and (SobjectType='Account')].Id;
        
        Account oAccount9= new Account();
        oAccount9.FirstName='A0001 Protiviti';
        oAccount9.LastName='Salesforce';
        oAccount9.CEN_Tipo_de_documento__pc = 'DNI';
        oAccount9.CEN_N_mero_de_documento__pc = '74859658';
        oAccount9.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti Perú';
        oAccount9.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount9.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount9.CEN_Direcci_n__c = 'Protiviti';
        oAccount9.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount9.Phone='5554444';
        oAccount9.PersonEmail='account@test.com';
        oAccount9.CEN_Lugar_de_nacimiento__pc='Lima';
        //oAccount9.CEN_Distrito__c=distrito.Id;
        //oAccount9.CEN_Distrito__pc=distrito.Id;
        oAccount9.CEN_Direcci_n__c='Av test';
        oAccount9.CEN_Direccion__pc='Av test';
        oAccount9.CEN_Nacionalidad__pc='Perú';
        oAccount9.CEN_Tel_fono_Trabajo__pc='8987923';
        oAccount9.CEN_Fecha_de_Nacimiento__c=Date.today();
        oAccount9.Moneda__pc='S/';
        oAccount9.CEN_Estado_civil__pc='Soltero';
        oAccount9.CEN_Tipo_de_relaci_n_laboral__pc='Dependiente';
        oAccount9.CEN_Jefe_Directo__pc='Oscar';
        oAccount9.CEN_Profesion_u_oficio__pc='Abogado';
        oAccount9.CEN_Cargo_que_ocupa__pc='Consultor';
        oAccount9.CEN_Promedio_Mensual_Ingresos__pc=1000;
        oAccount9.CEN_Centro_de_trabajo__c='Protiviti';
        oAccount9.CEN_Direcci_n_Centro_de_Trabajo__pc='Av test 1';
        oAccount9.PersonMobilePhone ='999888777';
        //oAccount9.OwnerId=u9.Id;
        oAccount9.RecordTypeId= RecTypeId;
        oAccount9.CEN_Nro_deudor_SAP__pc='74859658';
        oAccount9.CEN_Cod_Interno_SAP__pc ='74859658';
        oAccount9.CEN_Referencia_direccion__c = 'Frente al parque';
        oAccount9.CEN_Direccion__pc  = 'Av. Tupac Amaru';
        registros.add(oAccount9);
        
        Account oAccount10= new Account();
        oAccount10.CEN_Direcci_n__c = 'Protiviti';
        oAccount10.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount10.Phone='5554444';
        //oAccount10.CEN_Distrito__c=distrito.Id;
        oAccount10.CEN_Direcci_n__c='Av test';
        oAccount10.CEN_Fecha_de_Nacimiento__c=Date.today();
        oAccount10.CEN_Centro_de_trabajo__c='Protiviti';
        oAccount10.RecordTypeId = RecTypeIdCJ;
        oAccount10.Name='A0002 EMPRESA SAC';
        oAccount10.CEN_Numero_de_documento_del__c='10202020201';
        oAccount10.CEN_Referencia_direccion__c = 'Frente al parque';
        oAccount10.CEN_Direcci_n__c = 'Av. Tupac Amaru';
        registros.add(oAccount10);
        return registros;
    }
    public static List<Opportunity> getOpportunities(){        
        List<Opportunity> registros = new List<Opportunity>();
        String RecOppTypeId= [select Id from RecordType where (Name='Urbano') and (SobjectType='Opportunity')].Id;
        
        Opportunity opp9= new Opportunity();
        opp9.name='prueba';
        opp9.RecordTypeId= RecOppTypeId;
        //opp9.AccountId=oAccount9.id;
        opp9.StageName='Cotizacion';
        opp9.CloseDate=System.today();
        //opp9.OwnerId=u9.Id;
        
        registros.add(opp9);
        return registros;
    }
    public static List<Contact> getContacts(){
        List<Contact> registros = new List<Contact>();
        Contact repre = new Contact();
        repre.FirstName = 'A002 FirstName';
        repre.LastName = 'LastName';
        repre.CEN_N_mero_de_documento__c = '98989898';
        repre.CEN_Tipo_de_documento__c = 'DNI';
        repre.MobilePhone='989898764';
        repre.Phone='5556665';
        repre.Email='test@ts.ts';
        repre.CEN_Nacionalidad__c='Perú';
        repre.CEN_Tel_fono_Trabajo__c='5556665';
        repre.N_Partida_Vigencia_de_poder__c = '11111';
        registros.add(repre);
        return registros;
    }
    public static List<Proyecto__c> getProyectos(){
        List<Proyecto__c> registros = new List<Proyecto__c>();
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');        
        registros.add(proyecto);
        return registros;
    }
    public static List<Product2> getProduct2s(){
        List<Product2> registros = new List<Product2>();
         Product2  prod2= new Product2 ();
        prod2.name='prueba';
        prod2.CODLOTE__c='840001258';
        prod2.IsActive =true;
        prod2.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.11';
        prod2.CODCOMPANIA__c='0010';
        prod2.CEN_Tiene_Reserva__c='No';
        prod2.CODESTADOLOTE__c='L';
        prod2.CEN_PRECIOVENTAFUN__c='10000';
        //prod2.CEN_Proyecto__c=proyecto.Id;
         registros.add(prod2);
        return registros;
    }
    public static List<Pricebook2> getPricebook2s(){
        List<Pricebook2> registros = new List<Pricebook2>();
        Pricebook2   priceb2= new Pricebook2  ();
        priceb2.name='Standard Price Book';
        priceb2.IsActive=true;
        registros.add(priceb2);
        return registros;
    }
    public static List<PricebookEntry> getPricebookEntrys(){        
        List<PricebookEntry> registros = new List<PricebookEntry>();        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry  pric2= new PricebookEntry ();
        //pric2.Product2ID=prod2.id;
        pric2.Pricebook2Id=pricebookId;
        pric2.UnitPrice =20000;
        pric2.IsActive=true;
        registros.add(pric2);
        return registros;
    }
    public static List<Quote> getQuotes(){        
        List<Quote> registros = new List<Quote>();
        Quote q=new Quote();
        q.Name='840001258';        
        //q.OpportunityId=opp9.id;
        q.Pricebook2Id=Test.getStandardPricebookId();
        q.CEN_Area__c=100;  
        q.CEN_Precio_por_mt2__c=200; 
        q.CEN_Precio_de_venta__c=2000;
        q.CEN_Inicial__c= 1000;
        q.CEN_Cuota_inicial__c=1000;
        q.CEN_Inicial_porct__c=20;
        q.CEN_N_cuotas_de_inicial_de_precio__c=10; 
        q.CEN_Monto_cuota_de_inicial_de_precio__c=10;  
        q.CEN_Saldo_del_precio__c=1000;
        q.CEN_Numero_de_cuotas_a_financiar__c=10;
        q.CEN_N_cuotas_del_saldo_de_precio__c=10;
        q.CEN_Tasa_de_Interes_compensatorio_anual__c=23;
        q.CEN_Monto_cuota_del_saldo_de_precio__c=10000;
        q.CEN_Tipologia__c='Tipologia1';
        q.CEN_Lote__c='lote1';
        q.CEN_Manzana__c='manzana1';
        q.CEN_Precio_de_venta_con_descuento__c=2000;
        registros.add(q);
        return registros;
    }
    public static Account getSocio(String RecTypeId){
        Account socio = new Account();
        socio.RecordTypeId = RecTypeId;
        socio.FirstName='Socio Protiviti';
        socio.LastName='Salesforce';
        socio.CEN_N_mero_de_documento__pc = '76543210';
        socio.CEN_Tipo_de_documento__pc = 'DNI';
        socio.PersonEmail = 'socio@test.com';
        socio.Phone = '4445556';
        socio.CEN_Tel_fono_Trabajo__pc = '9876543';
        socio.CEN_Nacionalidad__pc = 'Perú';
        socio.CEN_Lugar_de_nacimiento__pc = 'Lima';
        socio.CEN_Fecha_de_Nacimiento__c = Date.today().addYears(-20);
        socio.CEN_Distrito__pc = null;
        socio.Moneda__pc = 'S/';
        socio.CEN_Estado_civil__pc = 'Soltero';
        socio.CEN_Tipo_de_relaci_n_laboral__pc = 'Dependiente';
        socio.CEN_Profesion_u_oficio__pc = 'Abogado';
        socio.CEN_Cargo_que_ocupa__pc = 'Consultor';
        socio.CEN_Centro_de_trabajo__c = 'Protiviti';
        socio.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Av test 2';
        socio.CEN_fld_Tiene_apoderado__c = false;
        socio.CEN_fld_Nombres_Apoderado__c = 'Apoderado Nombre';
        socio.CEN_fld_Apellidos_apoderado__c = 'Apoderado Apellido';
        socio.CEN_fld_Apellido_mat_apoderado__c = 'Apoderado Apellido Materno';
        socio.CEN_fld_Tipo_de_documento_de_apoderado__c = 'DNI';
        socio.CEN_fld_Numero_de_documento_apoderado__c = '12345678';
        socio.CEN_fld_Nacionalidad_apoderado__c = 'Perú';
        socio.CEN_fld_Direccion_apoderado__c = 'Av. Test 3';
        socio.CEN_fld_Numero_de_partida_registral__c = '987654321';
        return socio;
    }
}