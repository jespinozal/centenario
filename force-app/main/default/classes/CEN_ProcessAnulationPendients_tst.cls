/*
 * Name: CEN_ProcessAnulationPendients_tst
 * Version: 1.0
 * Descripción: Clase test del controlador CEN_ProcessAnulationPendients_ctr
 * Fecha: 05/07/2021
 * TestClass: ...
 */
@isTest
public class CEN_ProcessAnulationPendients_tst {
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
        opps[0].CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        opps[0].CEN_AmountPaidDate__c = 0;
        insert opps;

        //---- PAYMENTS
        List<CEN_PaymentOrder__c> pyOrderList = new List<CEN_PaymentOrder__c>();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 500;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment';
        pyOrder.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder.CEN_Opportunity__c = opps[0].Id;
        Date currentDay = system.today();
        pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PhoneNumber__c = '913122422';
        pyOrder.CEN_Email__c = 'test@test.com';
        pyOrder.CEN_LastName__c = 'Test';
        pyOrder.CEN_FirstName__c = 'Test';
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        pyOrderList.add(pyOrder);

        CEN_PaymentOrder__c pyOrder2 = new CEN_PaymentOrder__c();
        pyOrder2.CEN_Amount__c = 1000;
        pyOrder2.CEN_CurrencyCode__c = 'PEN';
        pyOrder2.CEN_PaymentDescription__c = 'Test payment';
        pyOrder2.CEN_PaymentStatus__c = 'PendienteSap';
        pyOrder2.CEN_Opportunity__c = opps[0].Id;
        Date currentDay2 = system.today();
        pyOrder2.CEN_DueDate__c = Date.newInstance(currentDay2.year(), currentDay2.month(), currentDay2.day()+5);
        pyOrder2.CEN_PhoneNumber__c = '913122422';
        pyOrder2.CEN_Email__c = 'test@test.com';
        pyOrder2.CEN_LastName__c = 'Test';
        pyOrder2.CEN_FirstName__c = 'Test';
        pyOrder2.CEN_PaymentDate__c = Datetime.now();
        pyOrderList.add(pyOrder2);

        insert pyOrderList;
    }

    @IsTest static void paymentOrderAnulationSucess_test(){
        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        List<String> opIds = new List<String>();
        opIds.add(paymentData.Id);

        List<CEN_ProcessAnulationPendients_ctr.FlowParameters> parameterList = new List<CEN_ProcessAnulationPendients_ctr.FlowParameters>();
		CEN_ProcessAnulationPendients_ctr.FlowParameters parameter = new CEN_ProcessAnulationPendients_ctr.FlowParameters();
        parameter.opIds = opIds;
        parameterList.add(parameter);

        Test.startTest();
        system.debug('paymentOrderAnulationSucess_test');
        CEN_ProcessAnulationPendients_ctr.processAnulationPendients(parameterList);
        Test.stopTest();
    }

}