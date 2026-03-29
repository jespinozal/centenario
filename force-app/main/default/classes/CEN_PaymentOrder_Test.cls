/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-07-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-21-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_PaymentOrder_Test {
    public static String respType;
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
        opps[0].CEN_Proyecto__c = projs[0].Id;

        insert opps;

        //---- PAYMENTS
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 1000;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        //pyOrder.Name = 'PO00001';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PhoneNumber__c = '913122422';
        pyOrder.CEN_Email__c = 'test@test.com';
        pyOrder.CEN_LastName__c = 'Test';
        pyOrder.CEN_FirstName__c = 'Test';
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
    }

    @IsTest static void paymentOrderSucess_test(){
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        List<String> paymentIds = new List<String>();
        paymentIds.add(paymentData.Id);

        List<CEN_PaymentOrder_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrder_ctr.FlowParameters>();
		CEN_PaymentOrder_ctr.FlowParameters parameter = new CEN_PaymentOrder_ctr.FlowParameters();
        parameter.paymentIds = paymentIds;
        parameterList.add(parameter);

        Test.startTest();
            system.debug('paymentOrderSucess_test');
        CEN_PaymentOrder_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
          List<String> response = CEN_PaymentOrder_ctr.paymentOrder(parameterList);
        system.debug('response: '+response);

        Test.stopTest();
    }

     @IsTest static void paymentOrderError_test(){
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        List<String> paymentIds = new List<String>();
        paymentIds.add(paymentData.Id);

        List<CEN_PaymentOrder_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrder_ctr.FlowParameters>();
		CEN_PaymentOrder_ctr.FlowParameters parameter = new CEN_PaymentOrder_ctr.FlowParameters();
        parameter.paymentIds = paymentIds;
        parameterList.add(parameter);

        Test.startTest();
            system.debug('paymentOrderSucess_test');
        CEN_PaymentOrder_Test.respType = 'error';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
          List<String> response = CEN_PaymentOrder_ctr.paymentOrder(parameterList);
        system.debug('response: '+response);

        Test.stopTest();
    }

    @IsTest static void changePaymentStatus_test(){

        CEN_PaymentOrder__c paymentData = [SELECT Id, CEN_ID_Culqi__c,recordType.DeveloperName, CEN_Amount__c,CEN_CurrencyCode__c, CEN_PaymentDescription__c,Name, 
        CEN_Opportunity__r.AccountId,CEN_DueDate__c, CEN_PaymentCode__c, CEN_PaymentStatus__c 
        FROM CEN_PaymentOrder__c LIMIT 1];

        String jsonString ='{"wObject": "order","id": "ord_test_HpRLsdwLOF2YF8Xh","amount": 1000,"payment_code": "073599089","currency_code": "PEN","description": "Alan pago","order_number": "PO-100000","state": "pending","total_fee": 0,"net_amount": 0,"fee_details":"Sin comision","creation_date": 1619061537,"expiration_date": 1619067600,"updated_at": 1619061537,"paid_at": null,"available_on": null,"metadata": {}}';
        CEN_PaymentOrderResponse dataPayment= (CEN_PaymentOrderResponse) JSON.deserialize(jsonString, CEN_PaymentOrderResponse.class);

        paymentData.CEN_ID_Culqi__c =dataPayment.id;
        //paymentData.CEN_Amount__c = dataPayment.amount;
        paymentData.CEN_CurrencyCode__c = dataPayment.currency_code;
        paymentData.CEN_PaymentDescription__c = dataPayment.description;
        //paymentData.Name
        //paymentData.CEN_DueDate__c = dataPayment.expiration_date;
        paymentData.CEN_PaymentCode__c = dataPayment.payment_code;
        //paymentData.CEN_PaymentStatus__c = dataPayment.state;

        update paymentData;

        Test.startTest();
                system.debug('paymentOrderSucess_test');
            CEN_PaymentOrder_Test.respType = 'ok';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());

            Map<String, String>  response = CEN_PaymentOrder_ctr.changePaymentStatus(dataPayment) ;
            system.debug('response: '+response);

    Test.stopTest();

    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'application/json');
            if (CEN_PaymentOrder_Test.respType.equals('ok')) {
                res.setBody('{"wObject": "order","id": "ord_test_HpRLsdwLOF2YF8Xh","amount": 1000,"payment_code": "073599089","currency_code": "PEN","description": "Alan pago","order_number": "PO-100000","state": "pending","total_fee": 0,"net_amount": 0,"fee_details":"Sin comision","creation_date": 1619061537,"expiration_date": 1619067600,"updated_at": 1619061537,"paid_at": null,"available_on": null,"metadata": {}}');
                res.setStatusCode(201);
            }else{
                res.setBody('{"wObject": "error","type": "parameter_error","merchant_message": "El campo description no tiene un formato válido, debe tener entre 5 y 80 caracteres.","param": "description"}');
                res.setStatusCode(404);
            }

            return res;
        }
    }
}