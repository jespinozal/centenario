@isTest
private class Batch_UpdateLeadCanalMedio_tst {
    @testSetup
    static void setup() {
        Lead ld = new Lead();
        ld.Salutation = 'Sr.';
        ld.FirstName = 'Joel';
        ld.LastName = 'Espinoza';
        ld.CEN_N_mero_de_documento__c = '22063637';
        ld.LeadSource = 'Digital';
        ld.CEN_Medio__c = '0110';
        insert ld;

        List<event> events = new List<event>();

        // insert 10 accounts
        Date dt = Date.Today();
        DateTime dtn = DateTime.Now();
        for (Integer i=0;i<10;i++) {
            events.add(new event(
                WhoId=ld.Id,
                //CEN_canal__c='Digital', 
                //CEN_Medio__c='0110',
                DurationInMinutes=60,
                ActivityDate=dt,
                ActivityDateTime=dtn
                ));
        }
        insert events;
        
    }
    @isTest static void test() {
        Test.startTest();
        Batch_UpdateLeadCanalMedio uca = new Batch_UpdateLeadCanalMedio();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
}