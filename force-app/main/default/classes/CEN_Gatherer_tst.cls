/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-07
* @description: Clase Test call Api SAP - Recaudadora. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-07           Alan Alvarez            Creación 
*  
*********************************************************************/
@isTest
public with sharing class CEN_Gatherer_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;
        
        //---- PRODUCT2
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_IdLotSAP__c = '00000073';
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        update prod2s ;
        
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;
        
        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_Proforma__c = '00001';
        insert opps;
        
        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
        oppItem.TotalPrice = 1000;
        insert oppItem;
        
        //---- PAYMENTS
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 1000;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        pyOrder.CEN_paymentCode__c = '785478285';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_DocumentNumberSAP__c = '8400000601';
        pyOrder.CEN_FiscalYearSAP__c = currentDay.year();
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
        
        CEN_CashRegistred__c cash = new CEN_CashRegistred__c();
        cash.Name = 'Prueba';
        cash.CEN_OfficeProyect__c = projs[0].Id;
        cash.CEN_PhysicalMoneyAvailable__c = 1000;
        cash.RecordTypeId = Schema.SObjectType.CEN_CashRegistred__c.getRecordTypeInfosByDeveloperName().get('CEN_WithdrawalOfMoneyRecordType').getRecordTypeId();
        insert cash;
        
        CEN_CashRegisterAndPayOrder__c cashAndPay = new CEN_CashRegisterAndPayOrder__c();
        cashAndPay.CEN_CAshRegistred__c = cash.Id;
        cashAndPay.CEN_PayOrder__c = pyOrder.Id;
        insert cashAndPay;
        
    }
    
    @IsTest 
    static void callGatherer_test(){
        String cashId = [SELECT Id FROM CEN_CashRegistred__c LIMIT 1].Id;
        List<CEN_Gatherer_ctr.FlowParameters> parameterList = new List<CEN_Gatherer_ctr.FlowParameters>();
        CEN_Gatherer_ctr.FlowParameters parameter = new CEN_Gatherer_ctr.FlowParameters();
        parameter.paymentIds = new List<String>{cashId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_Gatherer_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_Gatherer_ctr.callGatherer(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callGathererWarning_test(){
        String cashId = [SELECT Id FROM CEN_CashRegistred__c LIMIT 1].Id;
        List<CEN_Gatherer_ctr.FlowParameters> parameterList = new List<CEN_Gatherer_ctr.FlowParameters>();
        CEN_Gatherer_ctr.FlowParameters parameter = new CEN_Gatherer_ctr.FlowParameters();
        parameter.paymentIds = new List<String>{cashId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_Gatherer_tst.respType = 'warning';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_Gatherer_ctr.callGatherer(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callGathererError_test(){
        String cashId = [SELECT Id FROM CEN_CashRegistred__c LIMIT 1].Id;
        List<CEN_Gatherer_ctr.FlowParameters> parameterList = new List<CEN_Gatherer_ctr.FlowParameters>();
        CEN_Gatherer_ctr.FlowParameters parameter = new CEN_Gatherer_ctr.FlowParameters();
        parameter.paymentIds = new List<String>{cashId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_Gatherer_tst.respType = null;
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_Gatherer_ctr.callGatherer(parameterList);
        Test.stopTest();
    }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_Gatherer_tst.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_PROCESAR_PAGO_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><E_OK>X</E_OK><E_RETURN/></n0:ZRFC_OTC_PROCESAR_PAGO_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_Gatherer_tst.respType.equals('warning'))  {
                String respError = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_PROCESAR_PAGO_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><E_OK/><E_RETURN>';
                respError = respError + '<item><TYPE>E</TYPE><ID/><NUMBER>000</NUMBER><MESSAGE>Montos de los documentos agrupados no coincide con el importe recaudado</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO>';
                respError = respError + '<MESSAGE_V1/><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM/></item></E_RETURN></n0:ZRFC_OTC_PROCESAR_PAGO_WSResponse></soap-env:Body></soap-env:Envelope>';
                res.setBody(respError);
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    }
    
    
    
}