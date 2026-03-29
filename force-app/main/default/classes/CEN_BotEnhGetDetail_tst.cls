/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 08-11-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   08-11-2024   Diego Bravo   Initial Version
**/
@isTest
public class CEN_BotEnhGetDetail_tst {
    @testSetup
    public static void dataCreation() {

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
    
    @IsTest
    public static void Test_OKOption(){
        Test.StartTest();
        CEN_BotEnhGetDetail.request req = new CEN_BotEnhGetDetail.request();
        CEN_BotGetOptionsMenu.response option = new CEN_BotGetOptionsMenu.response();
        option.Code = 3;
        option.Name = '🔍';
        req.Option = option;
        //req.Weekday = null;
        //req.Turn = null;
        List<CEN_BotEnhGetDetail.request> input = new List<CEN_BotEnhGetDetail.request>();
        input.add(req);
        List<CEN_BotEnhGetDetail.response> res = CEN_BotEnhGetDetail.validateDecisionCode(input);
        Test.StopTest();
    }
    
    @IsTest
    public static void Test_OKWeekday(){
        Test.StartTest();
        CEN_BotEnhGetDetail.request req = new CEN_BotEnhGetDetail.request();
        //RS_BotEnhGetWeekday.response Weekday = new RS_BotEnhGetWeekday.response();
        //Weekday.Weekday = 'Miercoles';
        req.Option = null;

        //req.Weekday = Weekday;
        //req.Turn = null;
        List<CEN_BotEnhGetDetail.request> input = new List<CEN_BotEnhGetDetail.request>();
        input.add(req);
        List<CEN_BotEnhGetDetail.response> res = CEN_BotEnhGetDetail.validateDecisionCode(input);
        Test.StopTest();
    }
    
  
}