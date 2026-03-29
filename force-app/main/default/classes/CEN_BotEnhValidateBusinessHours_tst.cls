@isTest 
public class CEN_BotEnhValidateBusinessHours_tst {
    @TestSetup
    static void Test_Setup(){
        
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
    }
    
    @IsTest
    static void Test_1(){
        User u = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];

        System.runAs(u) { 
        	Test.startTest();
            List<CEN_BotEnhValidateBusinessHours.request> Input = new List<CEN_BotEnhValidateBusinessHours.request>();
            CEN_BotEnhValidateBusinessHours.validateBusinessHours(Input);
            Test.stopTest();        
        }
            
    }
    
    @IsTest
    static void Test_2(){
        User u = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];

        System.runAs(u) { 
        	Test.startTest();
            List<CEN_BotEnhValidateBusinessHours.request> Input = new List<CEN_BotEnhValidateBusinessHours.request>();
            CEN_BotEnhValidateBusinessHours.request req = new CEN_BotEnhValidateBusinessHours.request();
            req.BusinessHoursName = 'CEN_Ventas';
            Input.add(req);
            CEN_BotEnhValidateBusinessHours.validateBusinessHours(Input);
            Test.stopTest();        
        }
            
    }
}