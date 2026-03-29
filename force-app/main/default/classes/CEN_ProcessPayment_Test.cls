/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 06-17-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_ProcessPayment_Test {
    public static String respType = '';
    @TestSetup
	static void SetUp(){

        List<Account> accountList = new List<Account>();
        List<Product2> productList = new List<Product2>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        List<CEN_PaymentOrder__c> paymentOrderList = new List<CEN_PaymentOrder__c>();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();

        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);

        insert projs;

        Account oAccount = new Account();
        oAccount.FirstName = 'A_Test_01';
        oAccount.LastName = 'L_Test_01';
        oAccount.PersonEmail = 'Test01@tst.com';
        oAccount.PersonMobilePhone = '912999001';
        oAccount.PersonLeadSource = 'Digital';
        oAccount.CEN_Medio__c = '0111';
        oAccount.CEN_N_mero_de_documento__pc = '45558711';
        accountList.add(oAccount);
        insert accountList;

        Product2 oProduct= new Product2();
        oProduct.Name = 'El Haras LT 17';
        oProduct.CEN_PRECIOVENTAFUN__c= '50000';
        oProduct.CODLOTE__c='840001258';
        oProduct.IsActive =true;
        oProduct.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.11';
        oProduct.CODCOMPANIA__c='0010';
        oProduct.CEN_Tiene_Reserva__c='No';
        oProduct.CODESTADOLOTE__c='L';
        productList.add(oProduct);
        insert productList;

        Pricebook2 priceBook= new Pricebook2();
        priceBook.name='Standard Price Book';
        priceBook.IsActive=true;
        pricebookList.add(priceBook);
        insert pricebookList;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry priceBookEntry= new PricebookEntry();
        priceBookEntry.Product2ID=productList[0].id;
        priceBookEntry.Pricebook2Id=pricebookId;
        priceBookEntry.UnitPrice =20000;
        priceBookEntry.IsActive=true;
        pricebookEntryList.add(priceBookEntry);
        insert pricebookEntryList;

        for(Integer i=1;i<=3; i++){
            Opportunity opp = new Opportunity(
                CloseDate = Date.today(),
                Name = 'Oportunidad' + i,
                StageName = 'Cotización',
                CEN_Correo__c = 'test'+i+'@test.test',
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                CEN_Motivo_de_Compra__c = 'Vivienda',
                CEN_Proyecto__c=projs[0].Id,
                CEN_Proforma__c = '0000'+i,
                CEN_DiscountRate__c = 'Descuento Contado',
                CEN_Inicial_de_precio__c = 15000
            );
        	opportunityList.add(opp);
        }
        System.debug('oportunidades: '+ opportunityList);
        insert opportunityList;

        OpportunityLineItem oOpportunityLineItem = new OpportunityLineItem();
        oOpportunityLineItem.Product2Id = productList[0].Id;
        oOpportunityLineItem.UnitPrice = 59930.48;
        oOpportunityLineItem.Quantity = 2;
        oOpportunityLineItem.OpportunityId = opportunityList[0].Id;
        opportunityLineItemList.add(oOpportunityLineItem);

        OpportunityLineItem oOpportunityLineItem2 = new OpportunityLineItem();
        oOpportunityLineItem2.Product2Id = productList[0].Id;
        oOpportunityLineItem2.UnitPrice = 59930.48;
        oOpportunityLineItem2.Quantity = 2;
        oOpportunityLineItem2.OpportunityId = opportunityList[1].Id;
        opportunityLineItemList.add(oOpportunityLineItem2);

        OpportunityLineItem oOpportunityLineItem3 = new OpportunityLineItem();
        oOpportunityLineItem3.Product2Id = productList[0].Id;
        oOpportunityLineItem3.UnitPrice = 59930.48;
        oOpportunityLineItem3.Quantity = 2;
        oOpportunityLineItem3.OpportunityId = opportunityList[2].Id;
        opportunityLineItemList.add(oOpportunityLineItem3);

        insert opportunityLineItemList;

        CEN_PaymentOrder__c oPaymentOrderTCRE = new CEN_PaymentOrder__c();
        oPaymentOrderTCRE.CEN_Opportunity__c = opportunityList[0].Id;
        oPaymentOrderTCRE.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrderTCRE.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrderTCRE.CEN_Amount__c = 5000;
        oPaymentOrderTCRE.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrderTCRE.CEN_OriginPayment__c = 'TCRE';
        oPaymentOrderTCRE.CEN_LastFour__c = '1111';
        Id devRecordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();
        oPaymentOrderTCRE.RecordTypeId = devRecordTypeId;
        oPaymentOrderTCRE.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrderTCRE.CEN_PaymentDate__c = Date.today();
        oPaymentOrderTCRE.CEN_CountryCode__c= 'PE';
        oPaymentOrderTCRE.CEN_Banks__c= '020';
        paymentOrderList.add(oPaymentOrderTCRE);

        CEN_PaymentOrder__c oPaymentOrderABCU = new CEN_PaymentOrder__c();
        oPaymentOrderABCU.CEN_Opportunity__c = opportunityList[0].Id;
        oPaymentOrderABCU.CEN_FirstName__c = 'test_SecondName';
        oPaymentOrderABCU.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrderABCU.CEN_Amount__c = 1000;
        oPaymentOrderABCU.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrderABCU.CEN_OriginPayment__c = 'ABCU';
        oPaymentOrderABCU.CEN_LastFour__c = '1111';
        Id devRecordTypeIdABCU = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_TransferPayment').getRecordTypeId();
        oPaymentOrderABCU.RecordTypeId = devRecordTypeIdABCU;
        oPaymentOrderABCU.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrderABCU.CEN_PaymentDate__c = Date.today();
        oPaymentOrderABCU.CEN_CountryCode__c= 'PE';
        oPaymentOrderABCU.CEN_Banks__c= '020';
        paymentOrderList.add(oPaymentOrderABCU);

        CEN_PaymentOrder__c oPaymentOrderAS = new CEN_PaymentOrder__c();
        oPaymentOrderAS.CEN_Opportunity__c = opportunityList[0].Id;
        oPaymentOrderAS.CEN_FirstName__c = 'AnticiposSueltos';
        oPaymentOrderAS.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrderAS.CEN_Amount__c = 1000;
        oPaymentOrderAS.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrderAS.CEN_OriginPayment__c = 'Anticipos Sueltos';
        oPaymentOrderAS.CEN_LastFour__c = '1111';
        Id devRecordTypeIdAS = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_DownPayment').getRecordTypeId();
        oPaymentOrderAS.RecordTypeId = devRecordTypeIdAS;
        oPaymentOrderAS.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrderAS.CEN_PaymentDate__c = Date.today();
        oPaymentOrderAS.CEN_CountryCode__c= 'PE';
        oPaymentOrderAS.CEN_Banks__c= '020';
        paymentOrderList.add(oPaymentOrderAS);

        CEN_PaymentOrder__c oPaymentOrderEFEC = new CEN_PaymentOrder__c();
        oPaymentOrderEFEC.CEN_Opportunity__c = opportunityList[0].Id;
        oPaymentOrderEFEC.CEN_FirstName__c = 'CodigoEfectivo';
        oPaymentOrderEFEC.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrderEFEC.CEN_Amount__c = 1000;
        oPaymentOrderEFEC.CEN_PaymentStatus__c = 'Procesando';
        oPaymentOrderEFEC.CEN_OriginPayment__c = 'EFEC';
        oPaymentOrderEFEC.CEN_LastFour__c = '1111';
        Id devRecordTypeIdEFEC = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        oPaymentOrderEFEC.RecordTypeId = devRecordTypeIdEFEC;
        oPaymentOrderEFEC.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrderEFEC.CEN_PaymentDate__c = Date.today();
        oPaymentOrderEFEC.CEN_CountryCode__c= 'PE';
        oPaymentOrderEFEC.CEN_Banks__c= '020';
        paymentOrderList.add(oPaymentOrderEFEC);

        insert paymentOrderList;

    }

    @IsTest static void generateAndUpdateProcessPaymentSucessTCRE_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1];
        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
         Map<String,String> resp = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        system.debug('generateAndUpdateProcessPaymentSucess_test-resp: '+resp);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdateProcessPaymentSucessABCU_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_SecondName' Limit 1];
        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
         Map<String,String> resp = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        system.debug('generateAndUpdateProcessPaymentSucess_test-resp: '+resp);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdateProcessPaymentSucessAS_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'AnticiposSueltos' Limit 1];
        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
         Map<String,String> resp = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        system.debug('generateAndUpdateProcessPaymentSucess_test-resp: '+resp);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdateProcessPaymentSucessEFEC_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'CodigoEfectivo' Limit 1];
        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
         Map<String,String> resp = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        system.debug('generateAndUpdateProcessPaymentSucess_test-resp: '+resp);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdateOperationWarning_test(){
        CEN_PaymentOrder__c myPayment = [Select Id, CEN_Opportunity__c  From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1];
        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'warning';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            Map<String,String> response = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdateOperationError_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1];

        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        //oppUdate.CEN_Proforma__c = null;
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'Error';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            Map<String,String> response = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        Test.stopTest();
    }

     @IsTest static void generateAndUpdateOperationNoProforma_test(){
        CEN_PaymentOrder__c myPayment = [Select Id,CEN_Opportunity__c From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1]; 

        Opportunity oppUdate = new Opportunity();
        oppUdate.Id = myPayment.CEN_Opportunity__c;
        oppUdate.StageName = 'Operación';
        oppUdate.CEN_Proforma__c = null;
        oppUdate.CEN_Oficina_de_Venta__c = 'ZV022';
        update oppUdate;

        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'Error';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            Map<String,String> response = CEN_ProcessPayment_ctr.generateAndUpdateProcessPayment(myPayment.Id);
        Test.stopTest();
    }

    @IsTest static void generateAndUpdatePaymentSucess_test(){
        //Test.setMock( HttpCalloutMock.class, getMultiMock(200));
        String opIds = [SELECT Id FROM CEN_PaymentOrder__c LIMIT 1].Id; // Opp
        List<CEN_ProcessPayment_ctr.FlowParameters> parameterList = new List<CEN_ProcessPayment_ctr.FlowParameters>();
		CEN_ProcessPayment_ctr.FlowParameters parameter = new CEN_ProcessPayment_ctr.FlowParameters();
        parameter.opIds = new List<String>{opIds};
        parameterList.add(parameter);
        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
             List<String> response = CEN_ProcessPayment_ctr.processPaymentInSap(parameterList);
        	//CEN_OperactionSafe_ctr.generateAndUpdateOperationSafeAsinc(oppId);
        Test.stopTest();
    }

     public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_ProcessPayment_Test.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header /><soap-env:Body><n0:ZRFC_OTC_CAJA_AUTO_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><BELNR_ANTI /><BUKRS_ANTI /><ET_PAGOS_CLIENTE><item><BUKRS>0019</BUKRS><BELNR>8400000642</BELNR><GJAHR>2021</GJAHR><WRBTR>20.0</WRBTR></item></ET_PAGOS_CLIENTE><ET_RETURN><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400000642</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000064200192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_OK /><GJAHR_ANTI>0000</GJAHR_ANTI></n0:ZRFC_OTC_CAJA_AUTO_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_ProcessPayment_Test.respType.equals('warning'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header /><soap-env:Body><n0:ZRFC_OTC_CAJA_AUTO_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><BELNR_ANTI /><BUKRS_ANTI /><ET_PAGOS_CLIENTE /><ET_RETURN><item><TYPE>E</TYPE><ID>SU</ID><NUMBER>000</NUMBER><MESSAGE>Cliente no tiene documentos pendientes de pago</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>Cliente no tiene documentos pendientes de pago</MESSAGE_V1><MESSAGE_V2 /><MESSAGE_V3 /><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_OK /><GJAHR_ANTI>0000</GJAHR_ANTI></n0:ZRFC_OTC_CAJA_AUTO_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    }
}