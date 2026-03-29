/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-19-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_PaymentOrderProcess_tst {
    public static String respType;

    @testSetup
    public static void setup() {

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
        projs[0].CEN_MaximumPaymentDuePeriod__c = 15;
        projs[0].CEN_monto_minimo_deposito__c = 100;

        insert projs;

        Account oAccount = new Account();
        oAccount.FirstName = 'A_Test_01';
        oAccount.LastName = 'L_Test_01';
        oAccount.PersonEmail = 'Test01@tst.com';
        oAccount.PersonMobilePhone = '912999001';
        oAccount.CEN_N_mero_de_documento__pc = '45558711';
        accountList.add(oAccount);
        insert accountList;

        Product2 oProduct1= new Product2();
        oProduct1.Name = 'El Haras LT 11';
        oProduct1.CEN_PRECIOVENTAFUN__c= '50000';
        oProduct1.CODLOTE__c='840001258';
        oProduct1.IsActive =true;
        oProduct1.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.11';
        oProduct1.CODCOMPANIA__c='0010';
        oProduct1.CEN_Tiene_Reserva__c='No';
        oProduct1.CODESTADOLOTE__c='L';
        productList.add(oProduct1);

        Product2 oProduct2= new Product2();
        oProduct2.Name = 'El Haras LT 12';
        oProduct2.CEN_PRECIOVENTAFUN__c= '50000';
        oProduct2.CODLOTE__c='840001259';
        oProduct2.IsActive =true;
        oProduct2.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.12';
        oProduct2.CODCOMPANIA__c='0010';
        oProduct2.CEN_Tiene_Reserva__c='No';
        oProduct2.CODESTADOLOTE__c='L';
        productList.add(oProduct2);

        insert productList;

        Pricebook2 priceBook= new Pricebook2();
        priceBook.name='Standard Price Book';
        priceBook.IsActive=true;
        pricebookList.add(priceBook);
        insert pricebookList;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry priceBookEntry1= new PricebookEntry();
        priceBookEntry1.Product2ID=productList[0].id;
        priceBookEntry1.Pricebook2Id=pricebookId;
        priceBookEntry1.UnitPrice =20000;
        priceBookEntry1.IsActive=true;
        pricebookEntryList.add(priceBookEntry1);

        PricebookEntry priceBookEntry2= new PricebookEntry();
        priceBookEntry2.Product2ID=productList[1].id;
        priceBookEntry2.Pricebook2Id=pricebookId;
        priceBookEntry2.UnitPrice =30000;
        priceBookEntry2.IsActive=true;
        pricebookEntryList.add(priceBookEntry2);
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
                CEN_Proforma__c = '0000'+i

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

        OpportunityLineItem oOpportunityLineItem4 = new OpportunityLineItem();
        oOpportunityLineItem4.Product2Id = productList[1].Id;
        oOpportunityLineItem4.UnitPrice = 59930.48;
        oOpportunityLineItem4.Quantity = 2;
        oOpportunityLineItem4.OpportunityId = opportunityList[0].Id;
        opportunityLineItemList.add(oOpportunityLineItem4);
        /*
        OpportunityLineItem oOpportunityLineItem5 = new OpportunityLineItem();
        oOpportunityLineItem5.Product2Id = productList[1].Id;
        oOpportunityLineItem5.UnitPrice = 59930.48;
        oOpportunityLineItem5.Quantity = 2;
        oOpportunityLineItem5.OpportunityId = opportunityList[1].Id;
        opportunityLineItemList.add(oOpportunityLineItem5);
*/
        insert opportunityLineItemList;

        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opportunityList[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.CEN_MessageError__c = null;
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder);
        insert paymentOrderList;

    }

     @IsTest  static void updatingPaymentOrder(){
        String oppId = [Select Id From Opportunity Where CEN_Correo__c = 'test1@test.test' Limit 1].Id;
        List<String> products = new List<String>();
        List<OpportunityLineItem> oppLineItems = [SELECT Product2Id
                                                   FROM OpportunityLineItem
                                                   WHERE OpportunityId =: oppId];

        for(OpportunityLineItem product : oppLineItems){
            products.add(product.Product2Id);
        }

        List<CEN_PaymentOrder__c> oPaymentOrder = [Select Id From CEN_PaymentOrder__c];

        Test.startTest();
        CEN_PaymentOrderProcess_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> listStr = new List<String>();
        for(CEN_PaymentOrder__c po : oPaymentOrder){
        	   listStr.add(po.Id);
        }

        //CEN_PaymentOrderProcess_ctr.oppToCotizado(listStr,oppId);
        //CEN_PaymentOrderProcess_ctr.oppToCotizado(products,oppId);
        ID jobID = System.enqueueJob(new CEN_PaymentOrderProcess_ctr(oppId));
        system.debug('CEN_OperactionSafe_ctr-CEN_PaymentOrderProcess_ctr-jobID: '+jobID);

        Test.stopTest();
        //System.assertNotEquals(oPaymentOrder[0].Id,null);
    }

 /*
     public  static testMethod void updatingOpportunity() {

        Opportunity opp = [Select Id, CEN_Proforma__c, StageName From Opportunity Limit 1];
        String oppId = opp.Id;
        opp.CEN_Proforma__c = '00001';
        opp.StageName = 'Operación';
        update opp;
        List<String> oppList = new List<String>();
        oppList.add(oppId);

        List<CEN_PaymentOrderProcess_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrderProcess_ctr.FlowParameters>();
		CEN_PaymentOrderProcess_ctr.FlowParameters parameter = new CEN_PaymentOrderProcess_ctr.FlowParameters();
        parameter.oppIds = oppList;
        parameterList.add(parameter);

        Test.startTest();
        CEN_PaymentOrderProcess_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_PaymentOrderProcess_ctr.paymentOrderProcess(parameterList);
        Test.stopTest();

        //l = [Select OwnerID From Lead where ID = :l.id];
        //system.assertEquals(WHATYOUEXPECT, l.OwnerID);

    }

    public  static testMethod void updatingOpportunityNull() {
        List<String> oppList = new List<String>();
        List<CEN_PaymentOrderProcess_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrderProcess_ctr.FlowParameters>();
		CEN_PaymentOrderProcess_ctr.FlowParameters parameter = new CEN_PaymentOrderProcess_ctr.FlowParameters();
        parameter.oppIds = oppList;
        parameterList.add(parameter);
        Test.startTest();
        CEN_PaymentOrderProcess_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_PaymentOrderProcess_ctr.paymentOrderProcess(parameterList);
        Test.stopTest();

        //l = [Select OwnerID From Lead where ID = :l.id];
        //system.assertEquals(WHATYOUEXPECT, l.OwnerID);

    }

     public static testMethod void updatingPaymentOrderSAP() {
        String opId = [Select Id From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1].Id;
        List<String> opList = new List<String>();
        opList.add(opId);
        List<CEN_PaymentOrderProcessSAP_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrderProcessSAP_ctr.FlowParameters>();
		CEN_PaymentOrderProcessSAP_ctr.FlowParameters parameter = new CEN_PaymentOrderProcessSAP_ctr.FlowParameters();
        parameter.opIds = opList;
        parameterList.add(parameter);
        Test.startTest();
        CEN_PaymentOrderProcess_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_PaymentOrderProcessSAP_ctr.paymentOrderProcessSAP(parameterList);
        Test.stopTest();
        //l = [Select OwnerID From Lead where ID = :l.id];
        //system.assertEquals(WHATYOUEXPECT, l.OwnerID);
    }

     public static testMethod void updatingPaymentOrderSAPNull() {
        //String opId = [Select Id From CEN_PaymentOrder__c Where CEN_FirstName__c = 'test_FirstName' Limit 1].Id;
        List<String> opList = new List<String>();
        //opList.add(opId);
        List<CEN_PaymentOrderProcessSAP_ctr.FlowParameters> parameterList = new List<CEN_PaymentOrderProcessSAP_ctr.FlowParameters>();
		CEN_PaymentOrderProcessSAP_ctr.FlowParameters parameter = new CEN_PaymentOrderProcessSAP_ctr.FlowParameters();
        parameter.opIds = opList;
        parameterList.add(parameter);
        Test.startTest();
        CEN_PaymentOrderProcess_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_PaymentOrderProcessSAP_ctr.paymentOrderProcessSAP(parameterList);
        Test.stopTest();
        //l = [Select OwnerID From Lead where ID = :l.id];
        //system.assertEquals(WHATYOUEXPECT, l.OwnerID);

    }

    public static testMethod void notifyUsers_tst() {
        Opportunity opp = [Select Id,OwnerId From Opportunity Limit 1];
        Set<String> recipientId = new Set<String>();
        recipientId.add(opp.OwnerId);
        String targetId = opp.Id;
        Test.startTest();
    	CEN_PaymentOrderProcess_ctr.notifyUsers(recipientId,targetId );
        Test.stopTest();
    }

    public static testMethod void SendMail_tst() {
        Opportunity opp = [Select Id,OwnerId From Opportunity Limit 1];
        List<String> recipientId = new List<String>();
        recipientId.add(opp.OwnerId);
        String targetId = opp.Id;
        Test.startTest();
    	CEN_PaymentOrderProcess_ctr.SendMail(recipientId,targetId );
        Test.stopTest();
    }
*/
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'application/json');
           if (CEN_PaymentOrder_Test.respType.equals('ok')) {
                res.setBody('{"object": "order","id": "ord_test_HpRLsdwLOF2YF8Xh","amount": 10000,"payment_code": "073599089","currency_code": "PEN","description": "Alan pago","order_number": "PO-0000911","state": "pending","total_fee": null,"net_amount": null,"fee_details": null,"creation_date": 1619061537,"expiration_date": 1619067600,"updated_at": 1619061537,"paid_at": null,"available_on": null,"metadata": {}}');
                res.setStatusCode(201);
            }else{
                res.setBody('{"object": "error","type": "parameter_error","merchant_message": "El campo description no tiene un formato válido, debe tener entre 5 y 80 caracteres.","param": "description"}');
                res.setStatusCode(404);
            }
            return res;
        }
    }

}