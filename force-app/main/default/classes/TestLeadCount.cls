@isTest
private class TestLeadCount {

    @testSetup
    public static void setup() {
        Lead ld = new Lead();
        ld.LastName='Test 27102021 1430'; 
        ld.LeadSource='Digital';  
        ld.CEN_Web__c='Macropolis'; 
        ld.CEN_Medio__c='0125';
        insert ld;
    } 

    @isTest
    public static void testLeadCountInsert(){
        Lead ld= new Lead();
        try{
            Test.startTest();
            ld.LastName='Test 27102021 1431'; 
            ld.LeadSource='Digital';
            ld.CEN_Web__c='Macropolis';
            ld.CEN_Medio__c='0125';
            insert ld;
            Test.stopTest();
        }catch(DmlException ex){
            System.Debug(ex);
        } 
    
	}
    
}