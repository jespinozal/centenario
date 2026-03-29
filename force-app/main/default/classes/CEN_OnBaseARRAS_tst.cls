/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_OnBaseARRAS_tst {
    @testSetup
    public static void setup(){

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> usuarios = CEN_cls_Test_Ventas_DF.getUsers();
        System.runAs(thisUser){        
            insert usuarios;        
        }
        
        List<Tabla_maestra__c> distritos = CEN_cls_Test_Ventas_DF.getDistritos();
        insert distritos;
        
        List<Account> cuentas = null;
        List<Opportunity> oportunidades = null;
        List<Contact> contactos = null;
        System.runAs(usuarios[0]){
            cuentas = CEN_cls_Test_Ventas_DF.getAccounts();
            cuentas[0].CEN_Distrito__c=distritos[0].Id;
            cuentas[0].CEN_Distrito__pc=distritos[0].Id;
            cuentas[1].CEN_Distrito__c=distritos[0].Id;
            insert cuentas;
            
            oportunidades = CEN_cls_Test_Ventas_DF.getOpportunities();
            oportunidades[0].AccountId=cuentas[0].Id;
            oportunidades[0].CEN_Direcci_n_Legal_Contrato__c = cuentas[0].CEN_Direccion__pc;
            oportunidades[0].CEN_Distrito_opp__c = cuentas[0].CEN_Distrito__pc;
            oportunidades[0].CEN_Referencia_Direcci_n__c = cuentas[0].CEN_Referencia_direccion__c;
            oportunidades[0].CEN_Monto_cuota_de_inicial_de_precio__c = 5000;
            oportunidades[0].CEN_AnnulmentFlag__c=true;
            insert oportunidades;
            
            contactos = CEN_cls_Test_Ventas_DF.getContacts();
            contactos[0].AccountId=cuentas[1].Id;
            insert contactos;
            
            
        }
        
        
        List<Proyecto__c> proyectos = CEN_cls_Test_Ventas_DF.getProyectos();
        insert proyectos;
        
        List<Product2> productos = CEN_cls_Test_Ventas_DF.getProduct2s();
        productos[0].CEN_Proyecto__c=proyectos[0].Id;
        insert productos;
        
        List<Pricebook2> pricebooks = CEN_cls_Test_Ventas_DF.getPricebook2s();
        insert pricebooks;
        
        List<PricebookEntry> pricebookentrys = CEN_cls_Test_Ventas_DF.getPricebookEntrys();
        pricebookentrys[0].Product2Id=productos[0].Id;
        insert pricebookentrys;
        
        List<Quote> quotas = null;
        System.runAs(usuarios[0]){
            quotas = CEN_cls_Test_Ventas_DF.getQuotes();
            quotas[0].OpportunityId=oportunidades[0].Id;
            insert quotas;
            
            QuoteLineItem qli = new QuoteLineItem(Product2Id=productos[0].Id, 
                                                  QuoteId=quotas[0].Id, 
                                                  PricebookEntryId=pricebookentrys[0].Id, 
                                                  Quantity=1, 
                                                  UnitPrice=1000.00);
            insert qli;
            OpportunityLineItem oli = new OpportunityLineItem(Product2Id=productos[0].Id, 
                                                              PricebookEntryId=pricebookentrys[0].Id, 
                                                              OpportunityId=oportunidades[0].Id, 
                                                              UnitPrice=1000, 
                                                              Quantity=1);
            insert oli;
        }
            CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
            pyOrder.CEN_Amount__c = 5000;
            pyOrder.CEN_CurrencyCode__c = 'PEN';
            pyOrder.CEN_PaymentDescription__c = 'Test payment';
            //pyOrder.Name = 'PO00001';
            pyOrder.CEN_PaymentStatus__c = 'PendienteSAP';
            pyOrder.CEN_ID_Culqi__c = 'ord_test_nLJsG4ZLYmjxGewm';
            //pyOrder.CEN_Opportunity__c = opps[0].Id;
            pyOrder.CEN_Opportunity__c = oportunidades[0].Id;
            Date currentDay = system.today();
            pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
            pyOrder.CEN_PaymentDate__c = Datetime.now();
            insert pyOrder; 
    }

    @isTest
    public static void Onbase(){
        //List<User> usuarios = [SELECT Id, Name FROM User ORDER BY LastName ASC];
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        //User us2 = [SELECT Id, Name FROM User WHERE LastName='A0002 Supervisor'];
                
        List<Account> cuentas = [SELECT Id FROM Account ORDER BY Name ASC];
        Opportunity oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olitems = [SELECT Id FROM OpportunityLineItem];
        
        System.debug('Usuario 2: '+System.UserInfo.getUserId() +'. Name: '+System.UserInfo.getName());
        
        Test.startTest();        
        System.runAs(us1){
            CEN_cls_Reservas_Oportunidad.Response resp0 = CEN_cls_Reservas_Oportunidad.getOportunidad(oportunidad.Id);
            System.debug('resp0: '+resp0);
            System.assertEquals('OK', resp0.estado);
            System.assertEquals(olitems[0].Id, resp0.loteDeOportunidad.Id);
            
            CEN_cls_Reservas_Oportunidad.Response resp0a = CEN_cls_Reservas_Oportunidad.reservarLotesDeOportunidad(resp0.loteDeOportunidad.Id);
            System.debug('resp0a: '+resp0a);
           // System.assertEquals('OK', resp0a.estado);
            
            CEN_OnbaseArras_ctr.ResponseInit resp1= CEN_OnbaseArras_ctr.validarDatosDeOnbase(oportunidad.Id);
            System.debug('resp1: '+resp1);
            System.assertEquals(false, resp1.esSolicitudOnbase);
            System.assertEquals(false, resp1.etapaEsPreliminar);
            
            CEN_OnbaseArras_ctr.Response resp2 =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
            System.debug('resp2: '+resp2);
            System.assertEquals('error', resp2.estado);
            
            //  cambiar de oportunidad natural a jurídica
            oportunidad = generarOportunidad('Jurídica',null);

            resp2 =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);            
            System.debug('resp2: '+resp2);
            //System.assertEquals('OK', resp2.estado);

            CEN_OnbaseArras_ctr.Response resp4 =  CEN_OnbaseArras_ctr.enviarActualizacionSolicitudOnbase(oportunidad.Id);
            //System.assertEquals('OK', resp4.estado);
        }
        
        oportunidad.StageName='Preliminar';
        oportunidad.CEN_NroValidacionOrdenesDePago__c = 0;
        oportunidad.CEN_AmountPaidDate__c = 5000;
        update oportunidad;
        
        System.runAs(us1)
        {
            CEN_cls_Reservas_Oportunidad.getOportunidad(oportunidad.Id);
         	CEN_OnbaseArras_ctr.validarDatosDeOnbase(oportunidad.Id);
            
            oportunidad.StageName='Preliminar';
            oportunidad.CEN_Sub_estado__c='PENDIENTE';
            oportunidad.Description='Opportunity OnBase';
            update oportunidad;
            
            CEN_OnbaseArras_ctr.abrirSolicitud_en_OnBase(oportunidad.Id);
            CEN_OnbaseArras_ctr.abrirDocumentos_en_Onbase(oportunidad.Id);
            
			oportunidad.CEN_Sub_estado__c='FINALIZADO';
        	update oportunidad;                           
        }
        
        oportunidad.AccountId=cuentas[1].Id;
        oportunidad.StageName='Cotizacion';
        oportunidad.CEN_Sub_estado__c=null;
        //oportunidad.CEN_TypeOperation__c = 'OPERACION DE RESERVA';
        //update oportunidad;

        // System.runAs(us1){
        // 	CEN_OnbaseArras_ctr.Response resp3 =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
        //     for(CEN_OnbaseArras_ctr.FaltantesWrapper obj:resp3.listaFaltantes){
        //         System.debug(LoggingLevel.ERROR, obj.key +': '+obj.camposFaltantes);
        //     }
        //     //System.assertEquals('OK', resp3.estado);
        // }
        
        Test.stopTest();
        
     }
    @isTest
    public static void CuentaNuevaOportunidad(){
        Test.startTest();
        RecordType actual= CEN_cls_Nueva_Cuenta.getRecordTypeCuentaNatural();
        Test.stopTest();
        System.assertEquals('Cuenta Natural', actual.Name);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest
    public static void OK_solicitudNatural(){
        CEN_OnbaseArras_ctr.Response resp = null;
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc, 
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta);
            Account socio = CEN_cls_Test_Ventas_DF.getSocio(RecTypeId);
            insert socio;
            OpportunityPartner objOpportunityPartner = new OpportunityPartner();
            objOpportunityPartner.AccountToId = socio.Id;
            objOpportunityPartner.OpportunityId = oportunidad.Id;
            insert objOpportunityPartner;
            resp =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
            oportunidad = [
                SELECT Id, CEN_Link_Solicitud_arras__c,
                CEN_onbase_id_bandeja_arras__c, CEN_Onbase_documento_id_arras__c,
                CEN_Nro_solicitud_presolicitud__c 
                FROM Opportunity WHERE Id=:oportunidad.Id
            ];
            oportunidad.CEN_Link_Solicitud_arras__c = '';
            oportunidad.CEN_onbase_id_bandeja_arras__c = 100;
            oportunidad.CEN_Onbase_documento_id_arras__c = '1234';
            oportunidad.CEN_Nro_solicitud_presolicitud_arras__c = '5678';
            oportunidad.CEN_conversionARRAS__c = true;
            oportunidad.CEN_Motivo_Compra__c = '';
            oportunidad.CEN_modalidadPresencial__c = true;
            oportunidad.CEN_esContratoARRAS__c = true;
            oportunidad.CEN_Motivo_de_Compra__c = 'Inversión';
            update oportunidad;
            CEN_OnbaseArras_ctr.abrirSolicitud_en_OnBase(oportunidad.Id);
            CEN_OnbaseArras_ctr.abrirDocumentos_en_Onbase(oportunidad.Id);
        }
        Test.stopTest();
        System.debug('resp: '+resp);
        //System.assertEquals('OK', resp.estado);
    }
    @isTest
    public static void OK_solicitudJuridica(){
        CEN_OnbaseArras_ctr.Response resp = null;
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeIdCJ= [select Id from RecordType where (Name='Cuenta Jurídica') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeIdCJ
            ];
            Opportunity oportunidad = generarOportunidad('Jurídica',cuenta);
            resp = CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
            oportunidad = [
                SELECT Id, CEN_Link_Solicitud__c,
                CEN_onbase_id_bandeja__c, CEN_Onbase_documento_id__c,
                CEN_Nro_solicitud_presolicitud__c 
                FROM Opportunity WHERE Id=:oportunidad.Id
            ];
            oportunidad.CEN_Link_Solicitud__c = '';
            oportunidad.CEN_onbase_id_bandeja__c = 100;
            oportunidad.CEN_Onbase_documento_id__c = '1234';
            oportunidad.CEN_Nro_solicitud_presolicitud__c = '5678';
            update oportunidad;
            CEN_OnbaseArras_ctr.abrirSolicitud_en_OnBase(oportunidad.Id);
            CEN_OnbaseArras_ctr.abrirDocumentos_en_Onbase(oportunidad.Id);
        }
        Test.stopTest();
        System.debug('resp: '+resp);
        //System.assertEquals('OK', resp.estado);
    }
    @isTest
    public static void ERROR_solicitudNatural(){
        CEN_OnbaseArras_ctr.Response resp = null;
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc, 
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural',cuenta);
            oportunidad.CEN_Motivo_de_Compra__c = null;
            update oportunidad;
            Account socio = CEN_cls_Test_Ventas_DF.getSocio(RecTypeId);
            insert socio;
            OpportunityPartner objOpportunityPartner = new OpportunityPartner();
            objOpportunityPartner.AccountToId = socio.Id;
            objOpportunityPartner.OpportunityId = oportunidad.Id;
            insert objOpportunityPartner;
            resp =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
        }
        Test.stopTest();
        System.debug('resp: '+resp);
        System.assertEquals('error', resp.estado);
    }
    @isTest
    public static void ERROR_solicitudJuridica(){
        CEN_OnbaseArras_ctr.Response resp = null;
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeIdCJ= [select Id from RecordType where (Name='Cuenta Jurídica') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc, 
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeIdCJ
            ];
            Opportunity oportunidad = generarOportunidad('Jurídica',cuenta);
            oportunidad.CEN_Motivo_de_Compra__c = null;
            update oportunidad;
            resp =  CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oportunidad.Id);
        }
        Test.stopTest();
        System.debug('resp: '+resp);
        System.assertEquals('error', resp.estado);
    }
    private static Opportunity generarOportunidad(String type, Account cuenta){
        List<QuoteLineItem> qlitems = [
            SELECT Id, CEN_urbanizacion_proyecto__c, CEN_etapa__c, 
            CEN_manzana_del_lote__c, CEN_area_del_lote__c,
            CEN_lote__c,  CEN_fld_precioVentaDscto__c 
            FROM QuoteLineItem
        ];
        List<Tabla_maestra__c> distritos = [SELECT Id FROM Tabla_maestra__c];
        List<Opportunity> oportunidades = [
            SELECT Id, Type, CEN_Sub_estado__c, CEN_Tipo_de_solicitud__c, CEN_Tiene_Reserva__c, 
            CEN_Motivo_de_Compra__c, CEN_Con_sustento__c, CEN_Moneda__c, CEN_Medio_Publicitario__c, 
            CEN_Oficina_de_Venta__c, CEN_Tipo_de_venta__c, Amount, StageName, Description, AccountId, 
            OwnerId, Owner.Name, CEN_Fecha_de_pago__c, CEN_Direcci_n_Legal_Contrato__c, CEN_Distrito__c,
            CEN_Referencia_Direcci_n__c, CEN_fld_totalPrecioVentaDscto__c, CEN_DiscountRate__c
            FROM Opportunity
        ];
        if(cuenta!=null){
            oportunidades[0].AccountId = cuenta.Id;
            oportunidades[0].CEN_Referencia_Direcci_n__c = cuenta.CEN_Referencia_direccion__c;
            if(cuenta.IsPersonAccount){
                oportunidades[0].CEN_Direcci_n_Legal_Contrato__c = cuenta.CEN_Direccion__pc;
                oportunidades[0].CEN_Distrito_opp__c = cuenta.CEN_Distrito__pc;
            }else{
                oportunidades[0].CEN_Direcci_n_Legal_Contrato__c = cuenta.CEN_Direcci_n__c;
                oportunidades[0].CEN_Distrito_opp__c = cuenta.CEN_Distrito__c;
            }
        }
        oportunidades[0].StageName='Preliminar';
        //oportunidades[0].StageName='Operación';
        oportunidades[0].Type = type;               
        oportunidades[0].CEN_Sub_estado__c ='';         
        oportunidades[0].CEN_Tipo_de_solicitud__c='Solicitud';
        oportunidades[0].CEN_Tiene_Reserva__c='No';
        oportunidades[0].CEN_Motivo_de_Compra__c='Vivienda';
        oportunidades[0].CEN_Con_sustento__c='No';
        oportunidades[0].CEN_Moneda__c='PEN';
        oportunidades[0].CEN_Medio_Publicitario__c='0118';
        oportunidades[0].CEN_Oficina_de_Venta__c='ZV022';
        oportunidades[0].CEN_Tipo_de_venta__c='CD';
        oportunidades[0].Amount=1000;
        //oportunidades[0].CEN_Tipo_de_venta__c='CD';
        oportunidades[0].CEN_Motivo_de_Compra__c='Vivienda';
        oportunidades[0].CEN_Con_sustento__c ='No';
        oportunidades[0].CEN_Fecha_de_pago__c = Date.today().addDays(10);
        oportunidades[0].CEN_DiscountRate__c = 'Descuento táctico';
        update oportunidades[0];

        qlitems[0].CEN_urbanizacion_proyecto__c = 'Urbanizacion';
        qlitems[0].CEN_etapa__c = 'Etapa Prueba';
        qlitems[0].CEN_manzana_del_lote__c = 'A1';
        qlitems[0].CEN_area_del_lote__c = 100.00;
        qlitems[0].CEN_lote__c = 'Lt.1';
        qlitems[0].CEN_fld_precioVentaDscto__c = 10000;
        update qlitems[0];
        return oportunidades[0];
    }
    @isTest
    public static void enviarActualizacionSolicitudOnbase_OtherOwnerId_Test(){       
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        Opportunity opp = new Opportunity();
        	opp.Name = 'Test Opp';
        	opp.CloseDate = System.today();
            opp.StageName='Preliminar';          
            opp.CEN_Tipo_de_solicitud__c='Solicitud';
            opp.CEN_Tiene_Reserva__c='No';
            opp.CEN_Con_sustento__c='No';
            opp.CEN_Medio_Publicitario__c='0117';
           // opp.CEN_Oficina_de_Venta__c='Sala santa maría(lima)';
            opp.CEN_Tipo_de_venta__c='CD';
            opp.Amount=1000;
        insert opp;
        CEN_OnbaseArras_ctr.Response resp = new CEN_OnbaseArras_ctr.Response();
        Test.startTest();
            System.runAs(us1){
                String oppId = opp.Id;
                resp = CEN_OnbaseArras_ctr.enviarActualizacionSolicitudOnbase(oppId);
            }
        Test.stopTest();
       // System.assertEquals(resp.mensaje, 'No puede enviarse a Onbase. Debe ser el propietario de la Oportunidad.');
    }
    
    /* 
    @isTest
    public static void enviarActualizacionSolicitudOnbase_Cotizacion_Test(){
        
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        Opportunity opp = new Opportunity();
        	opp.Name = 'Test Opp2';
        	opp.CloseDate = System.today();
            opp.StageName='Cotización';          
            opp.CEN_Tipo_de_solicitud__c='Solicitud';
            opp.CEN_Tiene_Reserva__c='No';
            opp.CEN_Con_sustento__c='No';
            opp.CEN_Medio_Publicitario__c='0117';
           // opp.CEN_Oficina_de_Venta__c='Sala santa maría(lima)';
            opp.CEN_Tipo_de_venta__c='CD';
            opp.Amount=1000;
        insert opp;
        CEN_OnbaseArras_ctr.Response resp = new CEN_OnbaseArras_ctr.Response ();
        Test.startTest();        
            System.runAs(us1){
                String oppId = opp.Id;
                resp= CEN_OnbaseArras_ctr.enviarActualizacionSolicitudOnbase(oppId);
            }
        Test.stopTest();
        System.assertEquals(resp.mensaje, 'No puede enviarse a actualizar a Onbase. La etapa de la solicitud debe ser Preliminar.');
    }
    
    @isTest
    public static void enviarActualizacionSolicitudOnbase_OppNull_Test(){
        
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        Opportunity opp = new Opportunity();
        	opp.Name = 'Test Opp3';
        	opp.CloseDate = System.today();
            opp.StageName='Cotización';          
            opp.CEN_Tipo_de_solicitud__c='Solicitud';
            opp.CEN_Tiene_Reserva__c='No';
            opp.CEN_Con_sustento__c='No';
            opp.CEN_Medio_Publicitario__c='0117';
          //  opp.CEN_Oficina_de_Venta__c='Sala santa maría(lima)';
            opp.CEN_Tipo_de_venta__c='CD';
            opp.Amount=1000;
        insert opp;
        String oppId = opp.Id;
        delete opp;
        CEN_OnbaseArras_ctr.Response resp = new CEN_OnbaseArras_ctr.Response ();
        CEN_OnbaseArras_ctr.Response resp2 = new CEN_OnbaseArras_ctr.Response ();
        Test.startTest();
            System.runAs(us1){
                resp= CEN_OnbaseArras_ctr.enviarActualizacionSolicitudOnbase(oppId);
                resp2 = CEN_OnbaseArras_ctr.enviarOportunidad_a_OnBase(oppId);
            }  
        Test.stopTest();
        
        System.assertEquals(resp.mensaje, 'No puede enviarse a Onbase. Ocurrió un error tratando los datos.');
        System.assert(resp2.detalle != null);
    }*/
}