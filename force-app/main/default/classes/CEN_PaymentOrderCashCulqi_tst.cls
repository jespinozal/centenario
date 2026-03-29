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
public class CEN_PaymentOrderCashCulqi_tst {
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
        Map<String, Object> mapResp  = CEN_PaymentOrderCashCulqi_ctr.ListCashCulqi(parameterList);
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
                res.setBody('{"data":[{"object":"order","id":"ord_test_hTnSilc7xLOdGG0h","amount":15000,"payment_code":"013177540","currency_code":"PEN","description":"Néstor Andrés Sanjinéz Ticona  - Santa Maria 10F","order_number":"PO-3000280","state":"pending","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623347998,"expiration_date":1623542400,"updated_at":1623348047,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_7iJVL7Q10cAIsoTm","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000498","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623192725,"expiration_date":1623196800,"updated_at":1623192725,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_0IC3ZvIm0SnHTQXg","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000497","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623192559,"expiration_date":1623196800,"updated_at":1623192559,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_Bvf0Vhgzj4Z2VUT4","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000496","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623192499,"expiration_date":1623196800,"updated_at":1623192499,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_DjWz89bTW8rODIKi","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000495","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623191476,"expiration_date":1623196800,"updated_at":1623191476,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_blCNS0LNuxfP01Gy","amount":15000,"payment_code":"027927624","currency_code":"PEN","description":"Lorena Alexandra Bartolo Ascarza  - Santa Maria 10F","order_number":"PO-3000221","state":"pending","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623092407,"expiration_date":1623283200,"updated_at":1623092414,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_YaeKRjoDPAT1CG65","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000398","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1623092329,"expiration_date":1623128400,"updated_at":1623092329,"paid_at":null,"available_on":null,"metadata":{}},{"object":"order","id":"ord_test_eqx6JE2mh1R0O6db","amount":15000,"payment_code":null,"currency_code":"PEN","description":"Nayib Tamayo  - Proyecto Etapa II","order_number":"PO-000349","state":"created","total_fee":null,"net_amount":null,"fee_details":null,"creation_date":1622688547,"expiration_date":1622696400,"updated_at":1622688547,"paid_at":null,"available_on":null,"metadata":{}}],"paging":{"previous":"https://api.culqi.com/v2/orders?limit=50&before=ord_test_hTnSilc7xLOdGG0h","next":"https://api.culqi.com/v2/orders?limit=50&after=ord_test_eqx6JE2mh1R0O6db","cursors":{"before":"ord_test_hTnSilc7xLOdGG0h","after":"ord_test_eqx6JE2mh1R0O6db"},"remaining_items":283}}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"object":"error","type":"parameter_error","merchant_message":"El filtro creation_date tiene un valor inválido o está vacío. El valor debe estar en formato formato UNIX Time Stamp. Ejem: 1486150271.","param":"date"}');
                res.setStatusCode(400);
            }
    
            return res;
        }
    }
}