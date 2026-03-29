/**
 * @description       : Clase TEST para cerrar oportunidades con lote eliminado y actualizar ordenes de pago a 'Suelto'.
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 05-23-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_CloseOppsDropPaymentsAction_tst {
    public static String respType = '';
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
        opps[0].stagename='Operación';
        opps[0].CEN_Onbase_documento_id__c = '17785';
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
        oPaymentOrder.CEN_Amount__c = 100;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteCulqi';
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder);
        
        CEN_PaymentOrder__c oPaymentOrder1 = new CEN_PaymentOrder__c();
        oPaymentOrder1.CEN_FirstName__c = 'test_FirstName1';
        oPaymentOrder1.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder1.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder1.CEN_Amount__c = 100;
        oPaymentOrder1.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrder1.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder1);
        
        CEN_PaymentOrder__c oPaymentOrder2 = new CEN_PaymentOrder__c();
        oPaymentOrder2.CEN_FirstName__c = 'test_FirstName2';
        oPaymentOrder2.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder2.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder2.CEN_Amount__c = 100;
        oPaymentOrder2.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrder2.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder2);
        insert paymentOrderList;  
    }
    
    @IsTest static void closeOpportunitiesSucess_test(){        
        Test.startTest();
        Opportunity opp = [Select id,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c FROM Opportunity LIMIT 1];
        Product2 prodi = [Select id FROM Product2 LIMIT 1]; // Opp
        update opp;
        update prodi;
        List<Opportunity> opps = new List<Opportunity>{opp};
        List<String> prodiList = new List<String>();
        List<String> oppList = new List<String>();
        oppList.add(opp.Id);
        prodiList.add(prodi.Id);             
        List<CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters> parameterList = new List<CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters>();
        CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters parameter = new CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters();
        parameter.prodIds = prodiList;
        parameter.opIds = oppList;
        parameterList.add(parameter);
        CEN_CloseOppsDropPaymentsAction_ctr.closeOpportunities(parameterList);
        Test.stopTest();
    }
    
    @IsTest static void closeOpportunitiesWinSucess_test(){        
        Test.startTest();
        Opportunity opp = [Select id,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c FROM Opportunity LIMIT 1];
        Product2 prodi = [Select id FROM Product2 LIMIT 1];
        opp.StageName = 'Oportunidad Ganada';
        opp.CEN_Oficina_de_Venta__c = 'ZV031';
        opp.CEN_DiscountRate__c = 'Descuento táctico';
        update opp;
        update prodi;
        List<Opportunity> opps = new List<Opportunity>{opp};
        List<String> prodiList = new List<String>();
        List<String> oppList = new List<String>();
        oppList.add(opp.Id);
        prodiList.add(prodi.Id);             
        List<CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters> parameterList = new List<CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters>();
        CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters parameter = new CEN_CloseOppsDropPaymentsAction_ctr.FlowParameters();
        parameter.prodIds = prodiList;
        parameter.opIds = oppList;
        parameterList.add(parameter);
        CEN_CloseOppsDropPaymentsAction_ctr.closeOpportunities(parameterList);
        Test.stopTest();
    }
}