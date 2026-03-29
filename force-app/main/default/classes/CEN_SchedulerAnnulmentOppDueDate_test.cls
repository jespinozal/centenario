/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 04-28-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
@isTest
private class CEN_SchedulerAnnulmentOppDueDate_test {

    @TestSetup
	static void SetUp(){
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558711';
        insert accs;

         //---- PROJECTS
         Map<String,Integer> mapProj = new Map<String,Integer>();
         mapProj.put('myProj', 1);
         List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
         projs[0].CEN_Sociedad__c = '0019';
         insert projs;

        //---- OPPORTUNITY
        Date fecha = system.today();
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        mapOpp.put('Urbano', 2);
        mapOpp.put('Urbano', 3);
        mapOpp.put('Urbano', 4);
        mapOpp.put('Urbano', 5);
        mapOpp.put('Urbano', 6);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        opps[0].StageName = 'Operación';
        opps[0].CEN_MaximumPaymentDate__c = fecha;
        opps[0].CEN_Motivo_Cierre_Perdida__c = NULL;
        opps[0].CEN_estado_aprobacion__c = '';
        opps[0].CEN_Proyecto__c= projs[0].id;
        opps[0].OwnerId = '0054T000001F0o2QAC';
        opps[0].CEN_AmountPaidDate__c = 500;

        opps[1].Pricebook2Id = Test.getStandardPricebookId();
        opps[1].AccountId = accs[0].Id;
        opps[1].StageName = 'Oportunidad Perdida';
        opps[1].CEN_MaximumPaymentDate__c = fecha.addDays(-2);
        opps[1].CEN_Motivo_Cierre_Perdida__c = '';
        opps[1].CEN_estado_aprobacion__c = '';
        opps[1].CEN_AmountPaidDate__c = 500;
        opps[1].CEN_Sub_estado__c = 'EN PROCESO';
        opps[1].CEN_Proyecto__c= projs[0].id;
        opps[1].OwnerId = '0054T000001F0o2QAC';

        opps[2].Pricebook2Id = Test.getStandardPricebookId();
        opps[2].AccountId = accs[0].Id;
        opps[2].StageName = 'Oportunidad Perdida';
        opps[2].CEN_MaximumPaymentDate__c = fecha;
        opps[2].CEN_Motivo_Cierre_Perdida__c = '';
        opps[2].CEN_estado_aprobacion__c = '';
        opps[2].CEN_AmountPaidDate__c = 500;
        opps[2].CEN_Sub_estado__c = 'EN PROCESO';
        opps[2].CEN_MaximumDateSigningContract__c = fecha.addDays(-2);
        opps[2].CEN_Proyecto__c= projs[0].id;
        opps[2].OwnerId = '0054T000001F0o2QAC';

        opps[3].Pricebook2Id = Test.getStandardPricebookId();
        opps[3].AccountId = accs[0].Id;
        opps[3].StageName = 'Operación';
        opps[3].CEN_MaximumPaymentDate__c = fecha.addDays(1);
        opps[3].CEN_Motivo_Cierre_Perdida__c = '';
        opps[3].CEN_estado_aprobacion__c = '';
        opps[3].CEN_AmountPaidDate__c = 500;
        opps[3].CEN_Sub_estado__c = 'EN PROCESO';
        opps[3].CEN_Proyecto__c= projs[0].id;
        opps[3].OwnerId = '0054T000001F0o2QAC';

        opps[4].Pricebook2Id = Test.getStandardPricebookId();
        opps[4].AccountId = accs[0].Id;
        opps[4].StageName = 'Operación';
        opps[4].CEN_MaximumPaymentDate__c = fecha.addDays(-1);
        opps[4].CEN_Motivo_Cierre_Perdida__c = '';
        opps[4].CEN_estado_aprobacion__c = '';
        opps[4].CEN_AmountPaidDate__c = 500;
        opps[4].CEN_Sub_estado__c = 'EN PROCESO';
        opps[4].CEN_Proyecto__c= projs[0].id;
        opps[4].OwnerId = '0054T000001F0o2QAC';

        opps[5].Pricebook2Id = Test.getStandardPricebookId();
        opps[5].AccountId = accs[0].Id;
        opps[5].StageName = 'Preliminar';
        opps[5].CEN_MaximumPaymentDate__c = fecha;//0
        opps[5].CEN_Motivo_Cierre_Perdida__c = '';
        opps[5].CEN_estado_aprobacion__c = '';
        opps[5].CEN_Monto_cuota_de_inicial_de_precio__c = 500;
        opps[5].CEN_AmountPaidDate__c = 500;
        opps[5].CEN_Sub_estado__c = 'EN PROCESO';
        opps[5].CEN_MaximumDateSigningContract__c = fecha.addDays(-1);
        opps[5].CEN_Proyecto__c= projs[0].id;
        opps[5].OwnerId = '0054T000001F0o2QAC';

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
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day() - 1);
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
    }

    static testmethod void testScheduledJob() {

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;

        Test.startTest();
        CEN_SchedulerAnnulmentOpportunityDueDate reminder = new CEN_SchedulerAnnulmentOpportunityDueDate();
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '50 25 10 16 6 ?';
        String jobID = System.schedule('CEN_SchedulerAnnulmentOpportunityDueDate', sch, reminder);

        System.debug(jobID);
        Test.stopTest();
    }

}