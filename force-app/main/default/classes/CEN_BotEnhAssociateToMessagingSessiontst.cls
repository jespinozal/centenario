@isTest
public class CEN_BotEnhAssociateToMessagingSessiontst {
    
    @testSetup
    /**
    * @description: dataCreation
    */
    public static void dataCreation() {
        
        List<MessagingChannel> mc = new List<MessagingChannel>([SELECT Id FROM MessagingChannel where DeveloperName like 'WhatsApp%' order by CreatedDate desc]);
        
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = 'Nombre';
        meu.MessageType = 'WhatsApp';
        meu.MessagingPlatformKey = '5902781599734034';
        meu.MessagingChannelId = mc[0].Id;
        insert meu;
        
       // LiveChatVisitor lcv = new LiveChatVisitor();
       // insert lcv;

        
        MessagingSession ms = new MessagingSession();
        ms.Status = 'Active';
        ms.MessagingChannelId = mc[0].Id;
		ms.MessagingEndUserId = meu.Id;
        ms.CEN_MarcaFlujoLead__c = 'Flujo Recomendador';
        ms.ConversationId = system.label.TestConversationId;
        insert ms;
    
        
        Account acc = new Account();
        acc.LastName = 'Apellido';
        //acc.CEN_ApellidoPaterno__pc = 'Apellido';
        acc.PersonBirthdate = Date.valueOf('2020-01-01');
        acc.CEN_N_mero_de_documento__pc = '78965432';
        acc.CEN_Tipo_de_documento__pc = 'DNI';
        insert acc;
        
        Contact ct = [SELECT Id
                      FROM contact 
                      WHERE Account.CEN_N_mero_de_documento__pc='78965432' LIMIT 1];
        
        

                
        Case caso = new Case();
        caso.AccountId = acc.Id;
        caso.ContactId = ct.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEN_InteraccionUrbanoResolucion').getRecordTypeId();
        insert caso;
    }
    
    @IsTest
    public static void testOK(){
        Test.StartTest();
		MessagingSession ms = [SELECT Id FROM MessagingSession LIMIT 1];
        CEN_BotEnhAssociateToMessagingSession.request req = new CEN_BotEnhAssociateToMessagingSession.request();
        req.MessagingSessionId = ms.Id;
        req.Channel = 'Facebook';
        req.CaseToken = 'XYZ';
        List<CEN_BotEnhAssociateToMessagingSession.request> input = new List<CEN_BotEnhAssociateToMessagingSession.request>();
        input.add(req);
        
        CEN_BotEnhAssociateToMessagingSession.associate(input);
        Test.StopTest();
        MessagingSession updatedMs = [SELECT CEN_CaseToken__c FROM MessagingSession WHERE Id =: ms.Id];
        System.assertEquals(req.caseToken, updatedMs.CEN_CaseToken__c, 'case token actualizado');
    }
    
    
    @IsTest
    private static void testMarcaFlujoUpdateFromLead() {
        Test.startTest();

        Lead testLead = new Lead(
            LastName = 'Test', 
            Company = 'TestCompany', 
            CEN_MarcaFlujoDE__c = 'Flujo recomendador',
            LeadSource = 'WhatsApp',
            CEN_Medio__c = 'WhatsApp'
        );
        insert testLead;

        MessagingSession ms = [SELECT Id, CEN_MarcaFlujoLead__c FROM MessagingSession LIMIT 1];

        CEN_BotEnhAssociateToMessagingSession.request req = new CEN_BotEnhAssociateToMessagingSession.request();
        req.LeadId = testLead.Id;
        req.Channel = 'telemarketing'; 
        req.MessagingSessionId = ms.Id;

        CEN_BotEnhAssociateToMessagingSession.associate(new List<CEN_BotEnhAssociateToMessagingSession.request>{req});

        Test.stopTest();

        MessagingSession updatedMs = [SELECT CEN_MarcaFlujoLead__c FROM MessagingSession WHERE Id =: ms.Id];
        System.assertEquals(testLead.CEN_MarcaFlujoDE__c, updatedMs.CEN_MarcaFlujoLead__c, 'Marca flujo actualizado desde Oportunidad');
    }

    @IsTest
    private static void testMarcaFlujoUpdateFromOpportunity() {
        Test.startTest();


        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity', 
            CloseDate = System.today() + 30, 
            StageName = 'Cotización', 
            CEN_MarcaFlujoDE__c = 'Flujo Recomendador'
            
        );
        insert testOpportunity;


        MessagingSession ms = [SELECT Id, CEN_MarcaFlujoLead__c FROM MessagingSession LIMIT 1];

        CEN_BotEnhAssociateToMessagingSession.request req = new CEN_BotEnhAssociateToMessagingSession.request();
        req.OpportunityId = testOpportunity.Id;
        req.Channel = 'telemarketing'; 
        req.MessagingSessionId = ms.Id;

        CEN_BotEnhAssociateToMessagingSession.associate(new List<CEN_BotEnhAssociateToMessagingSession.request>{req});

        Test.stopTest();


        MessagingSession updatedMs = [SELECT CEN_MarcaFlujoLead__c FROM MessagingSession WHERE Id =: ms.Id];
        System.assertEquals(testOpportunity.CEN_MarcaFlujoDE__c, updatedMs.CEN_MarcaFlujoLead__c, 'Marca flujo actualizada desde Oportunidad');
    }
}