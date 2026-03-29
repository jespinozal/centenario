/*********************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-04-22
* @description: Clase Test que instancia clase Api de CEN_OpportunityService_cls.
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2021-04-22           Alan Alvarez            Creación
*
*********************************************************************/
@isTest
public class CEN_OpportunityService_tst {

    @testSetup
    public static void setup(){

        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_N_mero_de_documento__pc = '12345678';
        insert acc;

        List<Product2> productList = new List<Product2>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        List<CEN_PaymentOrder__c> paymentOrderList = new List<CEN_PaymentOrder__c>();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();

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
                StageName = 'Operación',
                CEN_Correo__c = 'test'+i+'@test.test',
                AccountId = acc.Id,
                Pricebook2Id = pricebookId,
                CEN_Motivo_de_Compra__c = 'Vivienda'
            );
        	opportunityList.add(opp);
        }

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

        insert opportunityLineItemList;

    }

    /*********************************************************************
* @description: Método para consumo api Get.
*********************************************************************/
    @isTest
    public static void CallApiGet(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/opportunity/12345678';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<CEN_OpportunityService_cls.opportunityresp> lstOpportunity = CEN_OpportunityService_cls.doGet();
        //system.assert(lstOpportunity.size() > 0);
    }

}