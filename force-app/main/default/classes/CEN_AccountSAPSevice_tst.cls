/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-20-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_AccountSAPSevice_tst {
   @TestSetup
    static void SetUp(){
        Tabla_maestra__c tm = new Tabla_maestra__c();
		tm.CEN_Codigo_departamento__c = '00001';  
        tm.CEN_Codigo_distrito__c = '00001';  
        tm.CEN_Codigo_provincia__c = '00001'; 
        insert tm; 
    }
    static testMethod void CEN_AccountSAPSevice_doPost() {
       
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/account/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":"0125","salesOffice":null,"phoneAccount":"988004919","numberDocument":"12345679","nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":"test@test.com","departamento":"00001","provincia":"00001","distrito":"00001","commentary":null,"codSap":"Test_003 MOD","addressReference":"Javier prado","addressAccount":"dir test"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_AccountSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_AccountSAPSevice_doPostError() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/account/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":"0125","salesOffice":null,"phoneAccount":"988004919","numberDocument":"12345679","nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":null,"departamento":"00001","provincia":"00001","distrito":"00001","commentary":null,"codSap":"Test_003 MOD","addressReference":"Javier prado","addressAccount":"dir test"}');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_AccountSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_AccountSAPSevice_doPostErrorData() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Test.startTest();    
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/account/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":"0125","salesOffice":null,"phoneAccount":"988004919","numberDocument":"12345679","nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":null,"departamento":"00001","provincia":"00001","distrito":"00001","commentary":null,"codSap":"Test_003 MOD","addressReference":"Javier prado","addressAccount":"dir test"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_AccountSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
     static testMethod void CEN_AccountSAPSevice_doPut() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/account/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":"0125","salesOffice":null,"phoneAccount":"988004919","numberDocument":"12345679","nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":"test@test.com","departamento":"00001","provincia":"00001","distrito":"00001","commentary":null,"codSap":"Test_003 MOD","addressReference":"Javier prado","addressAccount":"dir test"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_AccountSAPSevice_cls.doPut();
        Test.stopTest();
    }
}