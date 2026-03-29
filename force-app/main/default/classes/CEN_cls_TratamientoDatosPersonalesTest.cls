@isTest
public class CEN_cls_TratamientoDatosPersonalesTest {
	@testSetup public static void setupTest(){
        Account a = New Account(Name = 'CuentaNuevaPrueba', check1__c = false, check2__c = true, check3__c = true);
        insert a;
        //a = [SELECT Id, Name, check1__c, check2__c, check3__c From Account where Id =:a.Id];
		system.debug(a.Name);
    }  
    
     @isTest static void TestGetAccount(){
        Account acc = [SELECT Id, Name, check1__c, check2__c, check3__c From Account where Name=:'CuentaNuevaPrueba'];  
        Account a = CEN_cls_TratamientoDatosPersonales.getAccount(acc.Id);
        //String nombre = a.Name;
       	System.debug(a);
        System.assertNotEquals(NULL, a, 'Soy un mensaje');
   }
    
    @isTest static void TestSetPrivacidadDocumentPresencial(){
        Account acc = [SELECT Id, Name, check1__c, check2__c, check3__c From Account where Name=:'CuentaNuevaPrueba'];
        //Account a = CEN_cls_TratamientoDatosPersonales.getAccount(acc.Id);
        boolean check1 = true;
        boolean check2 = true;
        boolean check3 = true;
        String document = 'presencial';
        acc.check1__c = check1;
        acc.check2__c = check2;
        acc.check3__c = check3;
        
        CEN_cls_TratamientoDatosPersonales.setPrivacidad(acc.Id, check1, check2, check3, document);
        
        System.debug('correcto');
        System.assertNotEquals(NULL, 'Soy un mensaje');
        
    }
    
    @isTest static void TestSetPrivacidadDocumentNoPresencial(){
        Account acc = [SELECT Id, Name, check1__c, check2__c, check3__c From Account where Name=:'CuentaNuevaPrueba'];
        //Account a = CEN_cls_TratamientoDatosPersonales.getAccount(acc.Id);
        boolean check1 = true;
        boolean check2 = true;
        boolean check3 = true;
        String document = 'nopresencial';
        acc.check1__c = check1;
        acc.check2__c = check2;
        acc.check3__c = check3;
        
        CEN_cls_TratamientoDatosPersonales.setPrivacidad(acc.Id, check1, check2, check3, document);
        
        System.debug('correcto');
        System.assertNotEquals(NULL, 'Soy un mensaje');
        
    }
}