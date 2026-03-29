@isTest
public class CEN_BotEnhSetValues_tst {
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
    }
    
	@isTest
    public static void Test_OK(){
       User u = [SELECT Id FROM User WHERE Email = 'puser000@amamama.com'];
        System.runAs(u) { 
            Test.startTest();
            //final Account acc = [Select Id from Account where LastName='Apellido'];
            List<CEN_BotEnhSetValues.Request> input = new List<CEN_BotEnhSetValues.Request>();
            CEN_BotEnhSetValues.Request rq = new CEN_BotEnhSetValues.Request();
            rq.Input1 = 'a';
            rq.Input2 = 'b';
            rq.Input3 = 'c';
            rq.Input4 = 'd';
            input.add(rq);
            List<CEN_BotEnhSetValues.response> respuesta = new List<CEN_BotEnhSetValues.response>();
            respuesta = CEN_BotEnhSetValues.create(input);
            Test.stopTest(); 
        }
    }    
}