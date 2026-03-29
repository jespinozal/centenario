/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 02-12-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   02-12-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_Interaccion_tst {
    @testSetup
    public static void setup() {
        Case oCase = new Case();
        oCase.Origin = 'App';
        oCase.Status='Pendiente';
        oCase.Description = 'test';
        insert oCase;
    } 
    
    @isTest
    public static void CaseOriginAppInsert(){
    	Test.startTest();
        Case oCase = new Case();
        oCase.Origin = 'App';
        oCase.Status='Pendiente';
        insert oCase;
        Test.stopTest();
    }
  
    @isTest
    public static void CaseOriginAppUpdateStatusCerrado(){
    	Test.startTest();
        Case oCase = [SELECT Origin, Status FROM Case Limit 1];
        oCase.Status = 'Cerrado';
        update oCase;
        Test.stopTest();
    }

    @isTest
    public static void CaseOriginAppUpdateStatusAtendido(){
    	Test.startTest();
        Case oCase = [SELECT Origin, Status FROM Case Limit 1];
        oCase.Status = 'Atendido';
        update oCase;
        Test.stopTest();
    }

    @isTest
    public static void CaseOriginAppUpdateStatusEnProceso(){
    	Test.startTest();
        Case oCase = [SELECT Origin, Status, Reason FROM Case Limit 1];
        oCase.Status = 'En proceso';
        oCase.Reason = 'Pagos';
        update oCase;
        Test.stopTest();
    }

}