/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-01-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-21-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_PaymentOrderChargesCulqi_Test {
    public static String respType;
    @TestSetup
	static void SetUp(){

        
        // //---- ACCOUNTS
        // Map<String,Integer> mapAcc = new Map<String,Integer>();
        // mapAcc.put('PersonAccount', 1);
        // List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        // insert accs;

        // //---- OPPORTUNITY
        // Map<String,Integer> mapOpp = new Map<String,Integer>();
        // mapOpp.put('Urbano', 1);
        // List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        // opps[0].Pricebook2Id = Test.getStandardPricebookId();
        // opps[0].AccountId = accs[0].Id;
        // insert opps;

        // //---- PAYMENTS
        // CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        // pyOrder.CEN_Amount__c = 1000;
        // pyOrder.CEN_CurrencyCode__c = 'PEN';
        // pyOrder.CEN_PaymentDescription__c = 'Test payment';
        // //pyOrder.Name = 'PO00001';
        // pyOrder.CEN_Opportunity__c = opps[0].Id;
        // Date currentDay = system.today();
        // pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        // insert pyOrder;
    }

    // @IsTest static void paymentOrderSucess_test(){
    //     CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
    //     paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
    //     update paymentData;
    //     List<String> paymentIds = new List<String>();
    //     paymentIds.add(paymentData.Id);
        
    //     List<CEN_PaymentOrder_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrder_ctr.FlowParameters>();
	// 	CEN_PaymentOrder_ctr.FlowParameters parameter = new CEN_PaymentOrder_ctr.FlowParameters();
    //     parameter.paymentIds = paymentIds;
    //     parameterList.add(parameter);
        
    //     Test.startTest();
    //         system.debug('paymentOrderSucess_test');
    //     CEN_PaymentOrder_Test.respType = 'ok';
	// 	Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
    //       List<String> response = CEN_PaymentOrder_ctr.paymentOrder(parameterList);
    //     system.debug('response: '+response);

    //     Test.stopTest();
    // }
    
     @isTest static void paymentOrderSuccess_test(){
        
        Map<String,String> parameterList = new Map<String,String>();
        parameterList.put('amount','100');
         Date dateExp = System.today();
         Datetime dt = DateTime.newInstance(
                dateExp.year(),
                dateExp.month(),
                dateExp.day(),23,59,59);
            String strDt = String.valueOf(dt.getTime());
         parameterList.put('creation_date_from',strDt.substring(0, 10));
         parameterList.put('creation_date_to',strDt.substring(0, 10));
        
        Test.startTest();
        system.debug('paymentOrderSuccess_test');
        CEN_PaymentOrder_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        Map<String, Object> mapResp  = CEN_PaymentOrderChargesCulqi_ctr.ListChargesCulqi(parameterList);
        system.debug('response: '+ mapResp);

        Test.stopTest();
    }

    // @IsTest static void changePaymentStatus_test(){
       
        
    //     CEN_PaymentOrder__c paymentData = [SELECT Id, CEN_ID_Culqi__c,recordType.DeveloperName, CEN_Amount__c,CEN_CurrencyCode__c, CEN_PaymentDescription__c,Name, 
    //     CEN_Opportunity__r.AccountId,CEN_DueDate__c, CEN_PaymentCode__c, CEN_PaymentStatus__c 
    //     FROM CEN_PaymentOrder__c LIMIT 1];
        
    //     String jsonString ='{"wObject": "order","id": "ord_test_HpRLsdwLOF2YF8Xh","amount": 1000,"payment_code": "073599089","currency_code": "PEN","description": "Alan pago","order_number": "PO-100000","state": "pending","total_fee": 0,"net_amount": 0,"fee_details":"Sin comision","creation_date": 1619061537,"expiration_date": 1619067600,"updated_at": 1619061537,"paid_at": null,"available_on": null,"metadata": {}}';
    //     CEN_PaymentOrderResponse dataPayment= (CEN_PaymentOrderResponse) JSON.deserialize(jsonString, CEN_PaymentOrderResponse.class);

    //     paymentData.CEN_ID_Culqi__c =dataPayment.id;
    //     //paymentData.CEN_Amount__c = dataPayment.amount;
    //     paymentData.CEN_CurrencyCode__c = dataPayment.currency_code;
    //     paymentData.CEN_PaymentDescription__c = dataPayment.description;
    //     //paymentData.Name
    //     //paymentData.CEN_DueDate__c = dataPayment.expiration_date;
    //     paymentData.CEN_PaymentCode__c = dataPayment.payment_code;
    //     //paymentData.CEN_PaymentStatus__c = dataPayment.state;

    //     update paymentData;

    //     Test.startTest();
    //             system.debug('paymentOrderSucess_test');
    //         CEN_PaymentOrder_Test.respType = 'ok';
    //         Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
           
    //         Map<String, String>  response = CEN_PaymentOrder_ctr.changePaymentStatus(dataPayment) ;
    //         system.debug('response: '+response);

    // Test.stopTest();

    // }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
    
            res.setHeader('Content-Type', 'application/json');
            if (CEN_PaymentOrder_Test.respType.equals('ok')) {
                res.setBody('{"data":[{"duplicated":false,"object":"charge","id":"chr_test_nt0mEZiKSe6Y6bs9","creation_date":1620164701000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":1,"installments_amount":100,"currency_code":"PEN","email":"testeveris@piedpiper.com","description":null,"source":{"object":"token","id":"tkn_test_NV9rbB55ekXuujf7","type":"card","creation_date":1620164690000,"email":"richard@piedpiper.com","card_number":"411111******1111","last_four":"1111","active":false,"iin":{"object":"iin","bin":"411111","card_brand":"Visa","card_type":"Crédito","card_category":null,"issuer":{"name":"BBVA","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":[2,4,6,8,10,12,3,5,7,9,24,48]},"client":{"ip":"187.86.164.155","ip_country":"Peru","ip_country_code":"PE","browser":"Desconocido","device_fingerprint":null,"device_type":null},"metadata":null},"outcome":{"type":"venta_exitosa","code":"AUT0000","merchant_message":"La operación de venta ha sido autorizada exitosamente","user_message":"Su compra ha sido exitosa."},"fraud_score":16,"antifraud_details":{"first_name":null,"last_name":null,"address":null,"address_city":null,"country_code":null,"phone":null,"object":"client"},"dispute":false,"capture":true,"reference_code":"TruhtdSpA8","authorization_code":"59NtdQ","metadata":null,"total_fee":496,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.042,"total":420}},"total_fee_taxes":76,"transfer_amount":9504,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1620164701000},{"duplicated":false,"object":"charge","id":"chr_test_zdaVyrMkGtunXC19","creation_date":1620164525000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":0,"installments_amount":null,"currency_code":"PEN","email":"richard@piedpiper.com","description":null,"source":{"object":"token","id":"tkn_test_bmIi6FGexHVX8dnF","type":"card","creation_date":1620164518000,"email":"richard@piedpiper.com","card_number":"411111******1111","last_four":"1111","active":false,"iin":{"object":"iin","bin":"411111","card_brand":"Visa","card_type":"Crédito","card_category":null,"issuer":{"name":"BBVA","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":[2,4,6,8,10,12,3,5,7,9,24,48]},"client":{"ip":"187.86.164.155","ip_country":"Peru","ip_country_code":"PE","browser":"Desconocido","device_fingerprint":null,"device_type":null},"metadata":null},"outcome":{"type":"expiracion_invalida","code":"DNGA0054","merchant_message":"Fecha de Expiracion Invalida.","user_message":"La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta."},"fraud_score":16,"antifraud_details":{"first_name":null,"last_name":null,"address":null,"address_city":null,"country_code":null,"phone":null,"object":"client"},"dispute":false,"capture":true,"reference_code":"3jFXi0K7Dz","authorization_code":"tD6KR3","metadata":null,"total_fee":null,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.042}},"total_fee_taxes":null,"transfer_amount":null,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1620164525000},{"duplicated":false,"object":"charge","id":"chr_test_n6VPXDkom79C0Glt","creation_date":1620164466000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":0,"installments_amount":null,"currency_code":"PEN","email":"richard@piedpiper.com","description":null,"source":{"object":"token","id":"tkn_test_yjFupbGikxCHQ5VR","type":"card","creation_date":1620164405000,"email":"richard@piedpiper.com","card_number":"411111******1111","last_four":"1111","active":false,"iin":{"object":"iin","bin":"411111","card_brand":"Visa","card_type":"Crédito","card_category":null,"issuer":{"name":"BBVA","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":[2,4,6,8,10,12,3,5,7,9,24,48]},"client":{"ip":"187.86.164.155","ip_country":"Peru","ip_country_code":"PE","browser":"Desconocido","device_fingerprint":null,"device_type":null},"metadata":null},"outcome":{"type":"expiracion_invalida","code":"DNGA0054","merchant_message":"Fecha de Expiracion Invalida.","user_message":"La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta."},"fraud_score":16,"antifraud_details":{"first_name":null,"last_name":null,"address":null,"address_city":null,"country_code":null,"phone":null,"object":"client"},"dispute":false,"capture":true,"reference_code":"NCfATNUPDz","authorization_code":"QibgeH","metadata":null,"total_fee":null,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.042}},"total_fee_taxes":null,"transfer_amount":null,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1620164466000}],"paging":{"previous":"https://api.culqi.com/v2/charges?limit=50&before=chr_test_nt0mEZiKSe6Y6bs9","next":"https://api.culqi.com/v2/charges?limit=50&after=chr_test_n6VPXDkom79C0Glt","cursors":{"before":"chr_test_nt0mEZiKSe6Y6bs9","after":"chr_test_n6VPXDkom79C0Glt"},"remaining_items":0}}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"object":"error","type":"parameter_error","merchant_message":"El filtro creation_date tiene un valor inválido o está vacío. El valor debe estar en formato formato UNIX Time Stamp. Ejem: 1486150271.","param":"date"}');
                res.setStatusCode(400);
            }
    
            return res;
        }
    }
}