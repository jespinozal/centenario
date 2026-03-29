/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-12-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2021   @everis.com   Initial Version
 **/
@isTest
public with sharing class CEN_CancelEffectivePaymentOrder_test {
    public static String respType;
    @TestSetup
	static void SetUp(){

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558711';
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        insert opps;

        //---- PAYMENTS
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 1000;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        //pyOrder.Name = 'PO00001';
        pyOrder.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder.CEN_ID_Culqi__c = 'ord_test_nLJsG4ZLYmjxGewm';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
    }
    
    @IsTest static void cancelPaymentEFECProcessSucess_test(){
        
        Opportunity opp = [Select id FROM Opportunity LIMIT 1]; // Opp
        update opp;
        List<Opportunity> opps = new List<Opportunity>{opp};
            
        List<String> oppList = new List<String>();
        oppList.add(opp.Id);
        
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        paymentData.CEN_Opportunity__c = opp.Id;
        update paymentData;
        String paymentIds = paymentData.Id;
        Test.startTest();
        List<CEN_CancelEffectivePaymentOrder_ctr.FlowParameters> parameterList = new List<CEN_CancelEffectivePaymentOrder_ctr.FlowParameters>();
        CEN_CancelEffectivePaymentOrder_ctr.FlowParameters parameter = new CEN_CancelEffectivePaymentOrder_ctr.FlowParameters();
        parameter.opIds = oppList;
        parameterList.add(parameter);
        
        CEN_CloseOppsDropPaymentsAction_tst.respType = 'ok';
        CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFECProcess(parameterList);
        Test.stopTest();
    }

    @IsTest static void paymentOrderEFECSucess_test(){
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        String paymentIds = paymentData.Id;
        
        Test.startTest();
        CEN_PaymentOrderDeleteCulqiRequest myReq = new CEN_PaymentOrderDeleteCulqiRequest ();            
        CEN_PaymentOrder_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        //String idCulqi  = CEN_CancelEffectivePaymentOrder_ctr.getIdCulqi(paymentIds);
        String resp = CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC(paymentIds);
        system.debug('response: '+ resp);

        Test.stopTest();
    }
    
     @IsTest static void paymentOrderEFECError_test(){
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        String paymentIds = paymentData.Id;
        
        Test.startTest();
        CEN_PaymentOrder_Test.respType = 'Not_ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        //String idCulqi  = CEN_CancelEffectivePaymentOrder_ctr.getIdCulqi(paymentIds);
        String resp = CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC(paymentIds);
        system.debug('response: '+ resp);

        Test.stopTest();
    }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
    
            res.setHeader('Content-Type', 'application/json');
            if (CEN_PaymentOrder_Test.respType.equals('ok')) {
                res.setBody('');
                res.setStatusCode(200);
            }else{
                res.setBody('{"object":"error","type":"parameter_error","merchant_message":"Esta orden no puede ser confirmada porque se encuentra en un estado diferente de creación.  ","user_message":"Hubo algunos problemas al intentar validar tu compra. Contáctanos para ayudarte."}');
                res.setStatusCode(400);
            }
    
            return res;
        }
    }
}