/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-12-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-12-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_StatusMessageToUser_Test {
    @TestSetup
	static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        insert projs;

        //---- PRODUCT2
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        //insert prod2s ;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558711';
        insert accs;

        //---- PROYECTO
        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U1.011E';
        proyecto.CEN_Etapa__c='Etapa 1';
        insert proyecto;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].StageName = 'Operación';
        opps[0].CEN_DiscountRate__c = 'Descuento táctico';
        opps[0].CEN_LastApiCall__c = System.Now().addHours(-60);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = proyecto.Id;
        opps[0].CEN_Oficina_de_Venta__c = 'ZV022';
        insert opps;

        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
           //PricebookEntryId = pbEntry.Id,
        oppItem.TotalPrice = 1000;
        insert oppItem;
        // SELECT Product2Id FROM OpportunityLineItem WHERE Product2.CODESTADOLOTE__c = 'L' AND OpportunityId=:oppData.Id

        //---- PAYMENTORDER
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.OwnerId = UserInfo.getUserId();
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        insert oPaymentOrder;
    }

    @IsTest static void getStatusFromOpp_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        Opportunity oppTest = CEN_StatusMessageToUser_ctr.getStatusFromOpp(opp.Id);
        Test.stopTest();
    }

    @IsTest static void getErrorPaymentByOppId_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        CEN_PaymentOrder__c payment = new CEN_PaymentOrder__c();
        payment.CEN_Amount__c = 10000;
        payment.CEN_PaymentStatus__c = 'PendienteSAP';
        payment.CEN_Opportunity__c = opp.Id;

        List<CEN_PaymentOrder__c>  payments = CEN_StatusMessageToUser_ctr.getErrorPaymentByOppId(opp.Id);
        Test.stopTest();
    }

    @IsTest static void sendOperationToSap_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_Proforma__c, CEN_MessageError__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Operación';
        opp.CEN_MessageError__c = 'test';
        opp.CEN_Oficina_de_Venta__c = 'ZV022';
        update opp;
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendOperationToSap(opp.Id);
        Test.stopTest();
    }
    @IsTest static void sendPaymentsToSap_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_Proforma__c,CEN_MessageError__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Operación';
        opp.CEN_MessageError__c = '';
        opp.CEN_Oficina_de_Venta__c = 'ZV022';
        update opp;
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendPaymentsToSap(opp.Id);
        Test.stopTest();
    }

    @IsTest static void sendOperationToSapNow_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_LastApiCall__c,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Operación';
        opp.CEN_Oficina_de_Venta__c = 'ZV022';
        opp.CEN_LastApiCall__c = System.Now();
        update(opp);
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendOperationToSap(opp.Id);
        Test.stopTest();
    }
    @IsTest static void sendPaymentsToSapNow_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,CEN_LastApiCall__c,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Operación';
        opp.CEN_LastApiCall__c = System.Now();
        opp.CEN_Oficina_de_Venta__c = 'ZV022';
        update(opp);
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendPaymentsToSap(opp.Id);
        Test.stopTest();
    }

    @IsTest static void sendOperationToSapCotizacion_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,StageName,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Cotización';
        update(opp);
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendOperationToSap(opp.Id);
        Test.stopTest();
    }
    @IsTest static void sendPaymentsToSapCotizacion_tst(){
        Test.startTest();
        Opportunity opp = [SELECT Id,StageName,CEN_Proforma__c FROM Opportunity LIMIT 1]; // Opp
        opp.StageName = 'Cotización';
        update(opp);
        Map<String, String> mapTest = CEN_StatusMessageToUser_ctr.sendPaymentsToSap(opp.Id);
        Test.stopTest();
    }
}