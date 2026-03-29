@isTest
public class CEN_CashPayment_tst {
    public static String respType;
    
    @TestSetup
	static void SetUp(){
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558711';
        insert accs;

        // //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        insert opps;

        // //---- PAYMENTS
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 1000;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        pyOrder.CEN_paymentCode__c = '785478285';
        //pyOrder.Name = 'PO00001';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
        

    }

    @IsTest static void getCashPaymentCulqiSuccess_tst(){
                
        Test.startTest();
        Date dateExp = System.today();
         Datetime dt = DateTime.newInstance(
                dateExp.year(),
                dateExp.month(),
                dateExp.day(),23,59,59);
            String strDt = String.valueOf(dt.getTime());
         
        String inCreationDateFrom;// = strDt.substring(0, 10);
        String inCreationDateTo;// = strDt.substring(0, 10);
        //String inCreationDateFrom = '1597640400';
        //String inCreationDateTo = '1621659599';
        String inPaymentCode;// = 'TruhtdSpA';
        String inAmount = '';
        String inFirstName = '';
        String inLastName = '';
        String productCulqi = null;
        String socieda = '0019';
        

        system.debug('getCashPaymentCulqiSuccess_tst');
        CEN_CashPayment_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_CashPayment_ctr.PaymentWrapper> result = CEN_CashPayment_ctr.getCashPaymentCulqi(inCreationDateFrom, inCreationDateTo, inPaymentCode, inAmount, productCulqi, socieda);
        
        system.debug('response: '+ result);
        Test.stopTest();
    }
    
     @IsTest static void getCashPaymentCulqiExistSuccess_tst(){
        
        
        Test.startTest();
        Date dateExp = System.today();
         Datetime dt = DateTime.newInstance(
                dateExp.year(),
                dateExp.month(),
                dateExp.day(),23,59,59);
            String strDt = String.valueOf(dt.getTime());
         
        String inCreationDateFrom;// = strDt.substring(0, 10);
        String inCreationDateTo;// = strDt.substring(0, 10);
        //String inCreationDateFrom = '1597640400';
        //String inCreationDateTo = '1621659599';
        String inPaymentCode = '785478285';
        String inAmount = '';
        String inFirstName = '';
        String inLastName = '';
        String productCulqi = null;
         String socieda = '0019';

        system.debug('getCashPaymentCulqiSuccess_tst');
        CEN_CashPayment_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_CashPayment_ctr.PaymentWrapper> result = CEN_CashPayment_ctr.getCashPaymentCulqi(inCreationDateFrom, inCreationDateTo, inPaymentCode, inLastName,productCulqi,socieda);
        
        system.debug('response: '+ result);
        Test.stopTest();
    }
    
    @IsTest static void getCashPaymentCulqiExistDateSuccess_tst(){

        Test.startTest();
		Date dateExp = System.today();
        String inCreationDateFrom = String.valueOf(dateExp);
        String inCreationDateTo = String.valueOf(dateExp);
        String inPaymentCode = '';
        String inAmount = '';
        String inFirstName = '';
        String inLastName = '';
        String productCulqi = 'express';
        String socieda = '0019';

        system.debug('getCashPaymentCulqiExistDateSuccess_tst');
        CEN_CashPayment_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_CashPayment_ctr.PaymentWrapper> result = CEN_CashPayment_ctr.getCashPaymentCulqi(inCreationDateFrom, inCreationDateTo, inPaymentCode, inAmount, productCulqi,socieda);
        
        system.debug('response: '+ result);
        Test.stopTest();
    }

     @IsTest static void generatePaymentCash_tst(){
         Test.startTest();
         String oppId = [Select Id From Opportunity Limit 1].Id;
         List<CEN_CashPayment_ctr.PaymentWrapper> listObj = new List<CEN_CashPayment_ctr.PaymentWrapper>();
         CEN_CashPayment_ctr.PaymentWrapper obj = new CEN_CashPayment_ctr.PaymentWrapper();
         obj.amount = Decimal.valueOf('1000');
         obj.reference = 'TruhtdSpA2';
         obj.description = 'Test Description';
         obj.currencyCode = 'PEN';
         listObj.add(obj);
         CEN_CashPayment_ctr.generatePaymentCashCulqi(listObj,oppId);
         CEN_CashPayment_ctr.validateInitialAmountPaymentCash(oppId);
         Test.stopTest();
     }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
    
            res.setHeader('Content-Type', 'application/json');
            if (CEN_CashPayment_tst.respType.equals('ok')) {
                //res.setBody('{sucess=attributesList:[data=(CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=59NtdQ, capture=true, capture_date=1620164701000, creation_date=1620164701000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=testeveris@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=420]], fraud_score=16.0, id=chr_test_nt0mEZiKSe6Y6bs9, installments=1, installments_amount=100, operations=null, outcome=Outcome:[code=AUT0000, merchant_message=La operación de venta ha sido autorizada exitosamente, type=venta_exitosa, user_message=Su compra ha sido exitosa.], paid=true, reference_code=TruhtdSpA8, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164690000, email=richard@piedpiper.com, id=tkn_test_NV9rbB55ekXuujf7, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=76, transfer_amount=9504, wObject=charge],CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=tD6KR3, capture=true, capture_date=1620164525000, creation_date=1620164525000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=richard@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=null]], fraud_score=16.0, id=chr_test_zdaVyrMkGtunXC19, installments=0, installments_amount=null, operations=null, outcome=Outcome:[code=DNGA0054, merchant_message=Fecha de Expiracion Invalida., type=expiracion_invalida, user_message=La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta.], paid=true, reference_code=3jFXi0K7Dz, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164518000, email=richard@piedpiper.com, id=tkn_test_bmIi6FGexHVX8dnF, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=null, transfer_amount=null, wObject=charge],CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=QibgeH, capture=true, capture_date=1620164466000, creation_date=1620164466000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=richard@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=null]], fraud_score=16.0, id=chr_test_n6VPXDkom79C0Glt, installments=0, installments_amount=null, operations=null, outcome=Outcome:[code=DNGA0054, merchant_message=Fecha de Expiracion Invalida., type=expiracion_invalida, user_message=La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta.], paid=true, reference_code=NCfATNUPDz, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164405000, email=richard@piedpiper.com, id=tkn_test_yjFupbGikxCHQ5VR, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=null, transfer_amount=null, wObject=charge])]}":0}}');
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