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
private class CEN_SchedulerCancelPaymentOrderEFEC_test {

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
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day() - 1);
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;
    }

    static testmethod void testScheduledJob() {

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;

        Test.startTest();
        CEN_SchedulerCancelPaymentOrderEFEC reminder = new CEN_SchedulerCancelPaymentOrderEFEC();
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '50 25 10 16 6 ?';
        String jobID = System.schedule('CEN_SchedulerCancelPaymentOrderEFEC', sch, reminder);

        System.debug(jobID);
        Test.stopTest();

    }
}