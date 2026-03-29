@isTest
public class CEN_BotEnhGetOptionsMenu_tst {
@testSetup
    public static void dataCreation() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
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
        
        RecordType rt = [SELECT Id, DeveloperName, SobjectType 
                         FROM RecordType 
                         WHERE DeveloperName='CEN_InteraccionUrbanoResolucion'  AND SobjectType='Case'];
        
        Case caso = new Case();
        caso.AccountId = acc.Id;
        caso.ContactId = ct.Id;
        caso.RecordTypeId = RT.Id;
        insert caso;
        
        CEN_ConfigurationOptionMenu__c menu = new CEN_ConfigurationOptionMenu__c ();
        menu.CEN_Active__c = true;
        menu.CEN_Channel__c = 'Whatsapp';
        menu.CEN_NameMenu__c = 'Menú Principal';
        insert menu;
    }
    
    @isTest
    public static void Test_OK(){
       User u = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
        System.runAs(u) { 
            Test.startTest();
            final Account acc = [Select Id from Account where LastName='Apellido'];
            List<CEN_BotEnhGetOptionsMenu.Request> input = new List<CEN_BotEnhGetOptionsMenu.Request>();
            CEN_BotEnhGetOptionsMenu.Request rq = new CEN_BotEnhGetOptionsMenu.Request();
            rq.Menu = 'Menú Principal';
            rq.Channel = 'Whatsapp';
            input.add(rq);
            CEN_BotEnhGetOptionsMenu.getOptions(input);
            Test.stopTest(); 
        }
    }
}