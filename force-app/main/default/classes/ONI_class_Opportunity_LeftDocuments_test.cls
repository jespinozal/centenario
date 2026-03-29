@isTest
public with sharing class ONI_class_Opportunity_LeftDocuments_test {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Cotización',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test Carta Fianza Document',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert cv;
        
        // Get ContentDocument
        ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // Create ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = insertedCV.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
    @isTest
    static void testFindDocumentExists() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<Boolean> result = ONI_class_Opportunity_LeftDocuments.ONI_class_Opportunity_LeftDocuments_find(
            testOpp.Id, 
            'Carta Fianza'
        );
        Test.stopTest();
    }
}