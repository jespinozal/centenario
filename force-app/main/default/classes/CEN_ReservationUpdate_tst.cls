/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-29
* @description: Clase test para la generación de PDF del informe
*               de solicitud de modificación de reserva.
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-29           Alan Alvarez            Creación 
*  
*********************************************************************/
@isTest
public class CEN_ReservationUpdate_tst {
    
    @TestSetup
    static void SetUp(){ 
        //--- TABLA MAESTRA
        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;
        
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;
        
        //---- ATTACHMENT
        Attachment attachment = new Attachment();
        attachment.parentId = projs[0].Id;
        attachment.body = EncodingUtil.base64Decode('Imagen Centenario');
        attachment.name = '2020-30-10-LogoCentenarioV1';
        attachment.contentType = 'image/jpeg';
        insert attachment;
        
        //---- LOTE
        Product2 lote = new Product2();
        lote.Name='Lote prueba1';
        lote.CEN_Proyecto__c=projs[0].Id;
        lote.CODLOTE__c='123123123';
        lote.CODCOMPANIA__c='0010';
        lote.CEN_Tiene_Reserva__c='No';
        lote.CODESTADOLOTE__c='L';
        lote.CEN_PRECIOVENTAFUN__c='10000';
        lote.IsActive=true;
        lote.MANZANA__c = 'Mz. A1';
        lote.AREA__c = '100';
        lote.CEN_TIPOLOGIA__c= 'ESQUINA';
        lote.CEN_IdLotSAP__c = '00000073';
        lote.CEN_Proyecto__c = projs[0].Id;
        insert lote;
        
        //---- ACCOUNTS
        Account acc = new Account();
        acc.CEN_Tipo_de_documento__pc='DNI';
        acc.CEN_N_mero_de_documento__pc='10203040';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.PersonEmail='juan@everis.com';
        acc.CEN_Tel_fono_Trabajo__pc='987654321';
        acc.PersonMobilePhone='5555000';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc =distrito.Id;
        insert acc;
        
        //---- PRICEBOOK
        PricebookEntry precio2= new PricebookEntry();
        precio2.UseStandardPrice=false;
        precio2.IsActive=true;
        precio2.Pricebook2Id=Test.getStandardPricebookId();
        precio2.Product2Id=lote.Id;
        precio2.UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        insert precio2;
        
        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_Proforma__c = '00001';
        opps[0].AccountId = acc.Id;
        opps[0].CEN_devolucion_saldo_Afavor__c = true;
        insert opps;
        
        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = lote.Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
        oppItem.PricebookEntryId = precio2.Id;
        oppItem.TotalPrice = precio2.UnitPrice;
        insert oppItem;
        
        //---- QUOTE
        Quote cotizacion = new Quote();
        cotizacion.Name = 'Coti';
        cotizacion.OpportunityId = opps[0].Id;
        cotizacion.Pricebook2Id = Test.getStandardPricebookId();        
        insert cotizacion;
        
        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.Product2Id = lote.Id;
        objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
        objQuoteLineItem.PricebookEntryId = precio2.Id;
        objQuoteLineItem.Quantity = 1;
        objQuoteLineItem.UnitPrice = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.QuoteId = cotizacion.Id;
        objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
        objQuoteLineItem.CEN_lote__c = lote.DESCRIPCIONCORTA__c;
        objQuoteLineItem.CEN_manzana_del_lote__c = lote.MANZANA__c.capitalize();
        objQuoteLineItem.CEN_precio_m2_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c)/objQuoteLineItem.CEN_area_del_lote__c;
        objQuoteLineItem.CEN_precio_venta_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.CEN_fld_precioVentaDscto__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.CEN_tipologia_del_lote__c = lote.CEN_TIPOLOGIA__c;        
        objQuoteLineItem.CEN_urbanizacion_proyecto__c = projs[0].Name;
        objQuoteLineItem.CEN_etapa__c = projs[0].CEN_Etapa__c;
        insert objQuoteLineItem;
        
        //---- PAYMENTORDER
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        insert oPaymentOrder;
        
    }
    
    @IsTest 
    static void callCashReceiptPdf_test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Id> parameterList = new List<Id>();
        parameterList.add(opp.Id);
        Test.startTest();
        PageReference pageref = Page.CEN_ReservationUpdate_vf;
        pageref.getParameters().put('id',opp.Id);
        Test.setCurrentPage(pageref);
        //Controlador de visualforce
        ApexPages.StandardController scontr = new ApexPages.StandardController(opp);
        CEN_ReservationUpdate_ctr controller = new CEN_ReservationUpdate_ctr(scontr);
        List<CEN_SocietySAP__mdt> lstSociety = controller.getLstSociety();
        String societyName = controller.getSocietyName();
        Double totalAmount = controller.getTotalAmount();
        String writeToday = controller.getWriteToday();
        Attachment logoProyecto = controller.getLogoProyecto();
        Proyecto__c proyecto = controller.getProyecto();
        Opportunity oportunidads = controller.getOportunidads();
        Account cliente = controller.getCliente();
        String nroDocument = controller.getNroDocument();
        List<CEN_PaymentOrder__c> lstPaymentOrder = controller.getLstPaymentOrder();
        Quote cotizacion = controller.getCotizacion();
        List<QuoteLineItem> lotesCotizados = controller.getLotesCotizados();
        List<String> response = CEN_ReservationUpdateEmail_ctr.processReservationUpdatePdfEmail(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCashReceiptPdfError_test(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Id> parameterList = new List<Id>();
        parameterList.add(acc.Id);
        Test.startTest();
        PageReference pageref = Page.CEN_ReservationUpdate_vf;
        pageref.getParameters().put('id',parameterList[0]);
        Test.setCurrentPage(pageref);
        List<String> responseError = CEN_ReservationUpdateEmail_ctr.processReservationUpdatePdfEmail(parameterList);
        List<Id> parameterListNull = new List<Id>();
        List<String> responseNull = CEN_ReservationUpdateEmail_ctr.processReservationUpdatePdfEmail(parameterListNull);
        Test.stopTest();
    }
    
}