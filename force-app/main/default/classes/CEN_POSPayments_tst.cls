/**
 * @description       : CEN_POSPayments_tst
 * @author            : @everis.com
 * @group             : CENTENARIO
 * @last modified on  : 24-06-2025
 * @last modified by  : Felipe Bermudez
 * Test de            : Clase test para CEN_POSPayments_ctr
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   05-09-2021   @everis.com       Initial Version
 * 1.0   24-06-2025   Felipe Bermudez   Se agrego validacion a campo .bank cuando llegue vacio nuevo panel CULQI
 **/
@isTest
public with sharing class CEN_POSPayments_tst {
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
        pyOrder.CEN_Reference__c = 'TruhtdSpA';
        pyOrder.CEN_PaymentCode__c= '000024';
        pyOrder.CEN_LastFour__c= '0049';
        //pyOrder.Name = 'PO00001';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;

    }

    @IsTest static void getPosPaymentCulqiSuccess_tst(){

        Test.startTest();
        try
      	{
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
        String inAutorizacion;
        String inCode;
        String inCard;
        String inAmount = '';

        system.debug('getPosPaymentCulqiSuccess_tst');
        CEN_POSPayments_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_POSPayments_ctr.PaymentWrapper> result = CEN_POSPayments_ctr.getPosPaymentCulqi(inCreationDateFrom, inCreationDateTo, inAutorizacion, inCode, inCard, inAmount, '0019', 'PEN', false);

        system.debug('responsegetPosPaymentCulqiSuccess_tst: '+ result);

        }
      	catch(exception e)
        {

		}
        Test.stopTest();
    }

     @IsTest static void getPosPaymentCulqiExistSuccess_tst(){


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
        String inAutorizacion = 'TruhtdSpA';
        String inCode = '';
        String inCard = '';
        String inAmount = '';

        system.debug('getPosPaymentCulqiSuccess_tst');
        CEN_POSPayments_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_POSPayments_ctr.PaymentWrapper> result = CEN_POSPayments_ctr.getPosPaymentCulqi(inCreationDateFrom, inCreationDateTo, inAutorizacion, inCode, inCard, inAmount, '0019', 'PEN', true);

        system.debug('response: '+ result);
        Test.stopTest();
    }

    @IsTest static void getPosPaymentCulqiExistDateSuccess_tst(){

        Test.startTest();
		Date dateExp = System.today();
        String inCreationDateFrom = String.valueOf(dateExp);
        String inCreationDateTo = String.valueOf(dateExp);
        String inAutorizacion= 'TruhtdSp1';
        String inCode;
        String inCard;
        String inAmount = '';

        system.debug('getPosPaymentCulqiExistDateSuccess_tst');
        CEN_POSPayments_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_POSPayments_ctr.PaymentWrapper> result = CEN_POSPayments_ctr.getPosPaymentCulqi(inCreationDateFrom, inCreationDateTo, inAutorizacion, inCode, inCard, inAmount, '0019', 'PEN', false);

        system.debug('response: '+ result);
        Test.stopTest();
    }

     @IsTest static void generatePaymentPOS_tst(){
         Test.startTest();
         Date dateExp = System.today();
         //String fecha = String.valueOf(dateExp);
         DateTime fecha = Datetime.now();
         String oppId = [Select Id From Opportunity Limit 1].Id;
         List<CEN_POSPayments_ctr.PaymentWrapper> listObj = new List<CEN_POSPayments_ctr.PaymentWrapper>();
         CEN_POSPayments_ctr.PaymentWrapper obj = new CEN_POSPayments_ctr.PaymentWrapper();
         obj.amount = Decimal.valueOf('1000');
         obj.autorizacion = 'TruhtdSpA2';
         obj.description = 'Test Description';
         obj.clientFirstName = 'Test FirstName';
         obj.clientLastName = 'Test LastName';
         obj.id = 'Id_TruhtdSpA2';
         obj.bank = 'BBVA';
         obj.currencyCode = 'PEN';
         obj.opportunity = 'Test_001';
         obj.paymentCode = '000014';
         obj.lastFour = '2356';
         obj.cardNumber = '428581******2356';
         obj.creationDate = fecha;
         listObj.add(obj);
         CEN_POSPayments_ctr.generatePaymentPOS(listObj,oppId);
         CEN_POSPayments_ctr.validateInitialAmountPayment(oppId);
         Test.stopTest();
     }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'application/json');
            if (CEN_POSPayments_tst.respType.equals('ok')) {
                //res.setBody('{sucess=attributesList:[data=(CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=59NtdQ, capture=true, capture_date=1620164701000, creation_date=1620164701000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=testeveris@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=420]], fraud_score=16.0, id=chr_test_nt0mEZiKSe6Y6bs9, installments=1, installments_amount=100, operations=null, outcome=Outcome:[code=AUT0000, merchant_message=La operación de venta ha sido autorizada exitosamente, type=venta_exitosa, user_message=Su compra ha sido exitosa.], paid=true, reference_code=TruhtdSpA8, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164690000, email=richard@piedpiper.com, id=tkn_test_NV9rbB55ekXuujf7, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=76, transfer_amount=9504, wObject=charge],CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=tD6KR3, capture=true, capture_date=1620164525000, creation_date=1620164525000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=richard@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=null]], fraud_score=16.0, id=chr_test_zdaVyrMkGtunXC19, installments=0, installments_amount=null, operations=null, outcome=Outcome:[code=DNGA0054, merchant_message=Fecha de Expiracion Invalida., type=expiracion_invalida, user_message=La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta.], paid=true, reference_code=3jFXi0K7Dz, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164518000, email=richard@piedpiper.com, id=tkn_test_bmIi6FGexHVX8dnF, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=null, transfer_amount=null, wObject=charge],CEN_PaymentOrderChargesCulqiResponse:[amount=10000, amount_refunded=0, authorization_code=QibgeH, capture=true, capture_date=1620164466000, creation_date=1620164466000, currency_code=PEN, current_amount=10000, description=null, dispute=false, duplicated=false, email=richard@piedpiper.com, fee_details=Fee_Details:[fixed_fee=Fixed_Fee:[], variable_fee=Variable_Fee:[commision=0.042, currency_code=PEN, total=null]], fraud_score=16.0, id=chr_test_n6VPXDkom79C0Glt, installments=0, installments_amount=null, operations=null, outcome=Outcome:[code=DNGA0054, merchant_message=Fecha de Expiracion Invalida., type=expiracion_invalida, user_message=La fecha de expiración de su tarjeta es inválida. Intente nuevamente o utilice otra tarjeta.], paid=true, reference_code=NCfATNUPDz, source=Source:[active=false, card_number=411111******1111, client=Client:[browser=Desconocido, device_fingerprint=null, device_type=null, ip=187.86.164.155, ip_country=Peru, ip_country_code=PE], creation_date=1620164405000, email=richard@piedpiper.com, id=tkn_test_yjFupbGikxCHQ5VR, iin=Iin:[card_brand=Visa, card_category=null, card_type=Crédito, id=null, installments_allowed=(2, 4, 6, 8, 10, 12, 3, 5, 7, 9, ...), issuer=Issuer:[country=PERU, country_code=PE, name=BBVA, phone_number=null, website=null], wObject=iin], last_four=1111, metadata=null, type=card, wObject=token], statement_descriptor=CULQI*, total_fee_taxes=null, transfer_amount=null, wObject=charge])]}":0}}');
                res.setBody('{"data":[{"duplicated":null,"object":"charge","id":"chr_live_Lne53LRnTnSHLH7n","creation_date":1628554647000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":null,"installments_amount":null,"currency_code":"PEN","email":null,"description":null,"source":{"object":"token","id":"tkn_live_CuBSTQPV9NBMQBgS","type":"card","creation_date":null,"email":"-----","card_number":"421410******9543","last_four":"9543","active":null,"iin":{"object":"iin","bin":"421410","card_brand":"Visa","card_type":"Débito","card_category":null,"issuer":{"name":"BANCO DE LA NACION","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":null},"client":{"ip":null,"ip_country":null,"ip_country_code":null,"browser":null,"device_fingerprint":null,"device_type":"Pos"},"metadata":null},"outcome":{"type":"venta_exitosa","code":"AUT0000","merchant_message":"La operación de venta ha sido autorizada exitosamente","user_message":"Su compra ha sido exitosa."},"fraud_score":null,"antifraud_details":{"first_name":"-----","last_name":"-----","address":"-----","address_city":"-----","country_code":"-----","phone":null,"object":"client"},"dispute":false,"capture":false,"reference_code":"50044-210809191726-710337","authorization_code":"203599","metadata":{"captureType":"chip","terminalID":"43295","transactionID":"1d763f77-b5ff-4a90-a143-e53c111ff771","purchaseNumber":"000210"},"total_fee":0,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.0365,"total":0}},"total_fee_taxes":0,"transfer_amount":0,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1628554742000},{"duplicated":null,"object":"charge","id":"chr_live_T0opizAHbbzqMFHm","creation_date":1628360174000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":null,"installments_amount":null,"currency_code":"PEN","email":null,"description":null,"source":{"object":"token","id":"tkn_live_piL6u4MBmj8BrJDk","type":"card","creation_date":null,"email":"-----","card_number":"455788******9388","last_four":"9388","active":null,"iin":{"object":"iin","bin":"455788","card_brand":"Visa","card_type":"Débito","card_category":null,"issuer":{"name":"BCP","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":null},"client":{"ip":null,"ip_country":null,"ip_country_code":null,"browser":null,"device_fingerprint":null,"device_type":"Pos"},"metadata":null},"outcome":{"type":"venta_exitosa","code":"AUT0000","merchant_message":"La operación de venta ha sido autorizada exitosamente","user_message":"Su compra ha sido exitosa."},"fraud_score":null,"antifraud_details":{"first_name":"-----","last_name":"-----","address":"-----","address_city":"-----","country_code":"-----","phone":null,"object":"client"},"dispute":false,"capture":false,"reference_code":"50044-210807131613-704999","authorization_code":"774189","metadata":{"captureType":"chip","terminalID":"20902","transactionID":"bdc01c46-8be0-4b72-a15a-04ef14a87c6c","purchaseNumber":"000074"},"total_fee":0,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.0365,"total":0}},"total_fee_taxes":0,"transfer_amount":0,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1628360221000},{"duplicated":null,"object":"charge","id":"chr_live_5ruNKJLU2yN4oPsQ","creation_date":1627575289000,"amount":10000,"amount_refunded":0,"current_amount":10000,"installments":null,"installments_amount":null,"currency_code":"PEN","email":null,"description":null,"source":{"object":"token","id":"tkn_live_TeHzVKt86cAswRVo","type":"card","creation_date":null,"email":"-----","card_number":"428581******9752","last_four":"9752","active":null,"iin":{"object":"iin","bin":"428581","card_brand":"Visa","card_type":"Débito","card_category":null,"issuer":{"name":"SCOTIABANK ","country":"PERU","country_code":"PE","website":null,"phone_number":null},"installments_allowed":null},"client":{"ip":null,"ip_country":null,"ip_country_code":null,"browser":null,"device_fingerprint":null,"device_type":"Pos"},"metadata":null},"outcome":{"type":"venta_exitosa","code":"AUT0000","merchant_message":"La operación de venta ha sido autorizada exitosamente","user_message":"Su compra ha sido exitosa."},"fraud_score":null,"antifraud_details":{"first_name":"-----","last_name":"-----","address":"-----","address_city":"-----","country_code":"-----","phone":null,"object":"client"},"dispute":false,"capture":false,"reference_code":"50044-210729111447-686295","authorization_code":"164776","metadata":{"captureType":"chip","terminalID":"35714","transactionID":"7c56510b-bd95-4898-8b65-f9036bdff6f6","purchaseNumber":"000009"},"total_fee":0,"fee_details":{"fixed_fee":{},"variable_fee":{"currency_code":"PEN","commision":0.0365,"total":0}},"total_fee_taxes":0,"transfer_amount":0,"paid":true,"statement_descriptor":"CULQI*","transfer_id":null,"capture_date":1627575302000}],"paging":{"previous":"https://api.culqi.com/v2/charges?limit=50&before=chr_live_Lne53LRnTnSHLH7n","next":"https://api.culqi.com/v2/charges?limit=50&after=chr_live_5ruNKJLU2yN4oPsQ","cursors":{"before":"chr_live_Lne53LRnTnSHLH7n","after":"chr_live_5ruNKJLU2yN4oPsQ"},"remaining_items":3}}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"object":"error","type":"parameter_error","merchant_message":"El filtro creation_date tiene un valor inválido o está vacío. El valor debe estar en formato formato UNIX Time Stamp. Ejem: 1486150271.","param":"date"}');
                res.setStatusCode(400);
            }

            return res;
        }
    }

}