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
public with sharing class CEN_OpportunitySapService_tst {

    @TestSetup
    static void SetUp(){
        Opportunity opp = new Opportunity();
        opp.CEN_Proforma__c = '0001';
        opp.Name = '00001'; 
        opp.StageName = 'Operación';
        opp.CloseDate = System.today();
       // opp.Estado_Proforma__c
       // opp.Sub_Estado_Proforma__c FROM  WHERE StageName <> 'Oportunidad Perdida' AND 
        insert opp; 
    }

    static testMethod void CEN_OpportunitySapService_doPost() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/opportunity/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{"budgetNumber":"0001","codStateBudget":"L","codSubStateBudget":"DP"}');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_OpportunitySapService_cls.doPost();
        Test.stopTest();
    }
    
     static testMethod void CEN_OpportunitySapService_doPostErrorData() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/opportunity/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{"budgetNumber":null,"codStateBudget":"L","codSubStateBudget":"DP"}');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_OpportunitySapService_cls.doPost();
        Test.stopTest();
    }
    
     static testMethod void CEN_OpportunitySapService_doPostError() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/opportunity/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{}');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_OpportunitySapService_cls.doPost();
        Test.stopTest();
    }
}