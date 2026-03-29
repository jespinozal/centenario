@isTest
public class CEN_AnnulmentOppSameLot_tst {
    public static String respType;
    @TestSetup
	static void SetUp(){

        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;

        Product2 prod2 = new Product2();
        prod2.Name='Lote prueba1';
        prod2.CEN_Proyecto__c=projs[0].Id;
        prod2.CODLOTE__c='123123123';
        prod2.CODCOMPANIA__c='0010';
        prod2.CEN_Tiene_Reserva__c='No';
        prod2.CODESTADOLOTE__c='L';
        prod2.CEN_PRECIOVENTAFUN__c='10000';
        prod2.IsActive=true;
        prod2.MANZANA__c = 'Mz. A1';
        prod2.AREA__c = '100';
        prod2.CEN_TIPOLOGIA__c= 'ESQUINA';
        prod2.CEN_IdLotSAP__c = '00000073';
        insert prod2;

        PricebookEntry precio2= new PricebookEntry();
        precio2.UseStandardPrice=false;
        precio2.IsActive=true;
        precio2.Pricebook2Id=Test.getStandardPricebookId();
        precio2.Product2Id=prod2.Id;
        precio2.UnitPrice=Decimal.valueOf(prod2.CEN_PRECIOVENTAFUN__c);
        insert precio2;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        mapOpp.put('Urbano', 2);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_N_Cuotas_de_inicial_de_precio__c= 100;
        opps[0].CEN_Cuota_Facilote__c = false;

        opps[1].Pricebook2Id = Test.getStandardPricebookId();
        opps[1].CEN_Proyecto__c = projs[0].Id;
        opps[1].CEN_N_Cuotas_de_inicial_de_precio__c= 100;
        opps[1].CEN_Cuota_Facilote__c = false;

        insert opps;

        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2.Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
        oppItem.CEN_fld_precioVentaDscto__c = 800;
        oppItem.TotalPrice = 1000;
        insert oppItem;

        OpportunityLineItem oppItem2 = new OpportunityLineItem();
        oppItem2.Product2Id = prod2.Id;
        oppItem2.OpportunityId = opps[1].Id;
        oppItem2.Quantity = 1;
        oppItem2.CEN_fld_precioVentaDscto__c = 800;
        oppItem2.TotalPrice = 1000;
        insert oppItem2;

        DateTime todaysDate = System.today();
        Quote qt1 = new Quote();
        qt1.OpportunityId = opps[0].Id;
        qt1.Name = 'quote1';
        qt1.CreatedDate = todaysDate;
        insert qt1;

        Quote qt2 = new Quote();
        qt2.OpportunityId = opps[1].Id;
        qt2.Name = 'quote2';
        qt2.CreatedDate = todaysDate;
        insert qt2;

        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qt1.Id;
        qli.Product2Id = prod2.Id;
        qli.CEN_fld_precioVentaDscto__c = 800;
        qli.Quantity = 1;
        qli.UnitPrice = 1000;
        qli.PricebookEntryId = precio2.Id;
        insert qli;

        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.QuoteId = qt2.Id;
        qli2.Product2Id = prod2.Id;
        qli2.CEN_fld_precioVentaDscto__c = 800;
        qli2.Quantity = 1;
        qli2.UnitPrice = 1000;
        qli2.PricebookEntryId = precio2.Id;
        insert qli2;

		Date currentDay = system.today();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 1000;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        pyOrder.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder.CEN_ID_Culqi__c = 'ord_test_nLJsG4ZLYmjxGewm';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day() - 1);
        insert pyOrder;

        CEN_PaymentOrder__c pyOrder2 = new CEN_PaymentOrder__c();
        pyOrder2.CEN_Amount__c = 1000;
        pyOrder2.CEN_CurrencyCode__c = 'PEN';
        pyOrder2.CEN_PaymentDescription__c = 'Test payment';
        pyOrder2.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder2.CEN_ID_Culqi__c = 'ord_test_nLJsG4ZLYmjxGewz';
        pyOrder2.CEN_Opportunity__c = opps[1].Id;
        pyOrder2.CEN_PaymentDate__c = Datetime.now();
        pyOrder2.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day() - 1);
        insert pyOrder2;
    }

    @IsTest static void updateOppSameLotProcessSucess_test(){

        Opportunity opp = [Select id FROM Opportunity LIMIT 1]; // Opp
        update opp;
        List<Opportunity> opps = new List<Opportunity>{opp};

        List<String> oppList = new List<String>();
        oppList.add(opp.Id);

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        paymentData.CEN_Opportunity__c = opp.Id;
        update paymentData;
        //String paymentIds = paymentData.Id;
        Test.startTest();
        List<CEN_AnnulmentOppSameLot_ctr.FlowParameters> parameterList = new List<CEN_AnnulmentOppSameLot_ctr.FlowParameters>();
        CEN_AnnulmentOppSameLot_ctr.FlowParameters parameter = new CEN_AnnulmentOppSameLot_ctr.FlowParameters();
        parameter.oppIds = oppList;
        parameterList.add(parameter);

        CEN_AnnulmentOppSameLot_ctr.updateOppSameLotProcess(parameterList);
        Test.stopTest();
    }

}