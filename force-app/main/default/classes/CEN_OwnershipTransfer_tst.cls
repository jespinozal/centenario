/**
 * @description       : Clase test de CEN_OwnershipTransfer_ctr
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_OwnershipTransfer_tst {
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
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 2);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        insert opps;
        
        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
           //PricebookEntryId = pbEntry.Id,
        oppItem.TotalPrice = 1000;
        insert oppItem;
        // SELECT Product2Id FROM OpportunityLineItem WHERE Product2.CODESTADOLOTE__c = 'L' AND OpportunityId=:oppData.Id
        //---- PaymentOrder
        List<CEN_PaymentOrder__c> paymentOrderList = new List<CEN_PaymentOrder__c>();
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder);
        
        CEN_PaymentOrder__c oPaymentOrder1 = new CEN_PaymentOrder__c();
        oPaymentOrder1.CEN_FirstName__c = 'test_FirstName1';
        oPaymentOrder1.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder1.CEN_Opportunity__c = opps[1].Id;
        oPaymentOrder1.CEN_Amount__c = 5000;
        oPaymentOrder1.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrder1.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder1);
        insert paymentOrderList;  
    }
    @IsTest static void CEN_OwnershipTransfer_ctrSucess_test(){
        Test.startTest();
        Opportunity opp = [Select id,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c FROM Opportunity LIMIT 1];
        Opportunity oppt = [Select id,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c FROM Opportunity where id !=: opp.id LIMIT 1]; // Opp
        update opp;
        update oppt;
        List<Opportunity> opps = new List<Opportunity>{opp,oppt};
        List<String> oppList = new List<String>();
        List<String> oppListt = new List<String>();
        oppList.add(opp.Id);
        oppListt.add(oppt.Id);             
        List<CEN_OwnershipTransfer_ctr.FlowParameters> parameterList = new List<CEN_OwnershipTransfer_ctr.FlowParameters>();
        CEN_OwnershipTransfer_ctr.FlowParameters parameter = new CEN_OwnershipTransfer_ctr.FlowParameters();
        parameter.opIds = oppList;
        parameter.opIdsNew = oppListt;
        parameterList.add(parameter);
        
        //CEN_CloseOppsDropPaymentsAction_tst.respType = 'ok';
        CEN_OwnershipTransfer_ctr.GeneratePDF(parameterList);
        Test.stopTest();
    }    
}