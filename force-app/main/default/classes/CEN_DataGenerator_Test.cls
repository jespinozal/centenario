/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 04-19-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_DataGenerator_Test {

    public static List<Product2> getProduct2DataBasic(Map<String, Integer> recordTypeAndCantProd2) {
       system.debug('getProduct2DataBasic: '+recordTypeAndCantProd2);
       Map<String, Integer> mapAux = recordTypeAndCantProd2;
       // mapAux.put('ESStandar', 1);
        system.debug('mapAux: '+mapAux);
        List<Product2> prod2s = new List<Product2>();
        Set<String> rts = mapAux.keySet();
        system.debug('rts: '+rts);
       // rts.add('EsStandar');
        
        system.debug('getProduct2DataBasic2');
        for(String rt: rts){
            system.debug('String');
            for(Integer i=0; i < mapAux.get(rt);i++){
                system.debug('Integer'+i);
                Product2 prod2 = new Product2();
                prod2.Name = 'Test '+rt+'00'+i;
                prod2.CODLOTE__c = '000000'+i;
                prod2.CODESTADOLOTE__c = 'L';
                prod2.IsActive=true;
                prod2s.add(prod2);
            }
        }
        insert prod2s;
        List<Pricebook2> priceBooks = getPriceBook(recordTypeAndCantProd2.keyset());
        system.debug('priceBooks: '+priceBooks);
        Boolean isOK = setPricebookEntry(prod2s,priceBooks);
        return prod2s;
    }

    public static List<Proyecto__c> getProjectsDataBasic(Map<String, Integer> recordTypeAndCantProj) {
        system.debug('getProjectsDataBasic');
        List<Proyecto__c> projects = new List<Proyecto__c>();
        Set<String> rts = recordTypeAndCantProj.keySet();
        for(String rt: rts){
            for(Integer i=0; i < recordTypeAndCantProj.get(rt);i++){
                Proyecto__c proj = new Proyecto__c();
                proj.Name = 'Test '+rt+'00'+i;
                proj.CEN_CODIGOSAP__c = '19U'+i+'.085E';
                projects.add(proj);
            }
        }
        return projects;
    }

    public static List<Account> getAccountsDataBasic(Map<String, Integer> recordTypeAndCantAcc) {
        system.debug('getAccountsDataBasic');
        List<Account> accs = new List<Account>();
        Set<String> rts = recordTypeAndCantAcc.keySet();
        for(String rt: rts){
            for(Integer i=0; i < recordTypeAndCantAcc.get(rt);i++){
                Account acc = new Account();
                acc.FirstName = 'A_Test_'+rt+' 00'+i;
                acc.LastName = 'L_Test_'+rt+' 00'+i;
                acc.PersonEmail = 'Test'+rt+'00'+i+'@tst.com';
                acc.PersonMobilePhone = '91299900'+i;
                acc.PersonLeadSource = 'Call Center';
                acc.CEN_Medio__c = '0110';
                acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
                accs.add(acc);
            }
        }
        return accs;
    }

    public static List<Opportunity> getOpportunitiesDataBasic(Map<String, Integer> recordTypeAndCantOpp) {
        system.debug('getOpportunitiesDataBasic');
        List<Opportunity> opps = new List<Opportunity>();
        Set<String> rts = recordTypeAndCantOpp.keySet();
        for(String rt: rts){
            for(Integer i=0; i < recordTypeAndCantOpp.get(rt);i++){
                Opportunity opp = new Opportunity();
                opp.Name = 'Test_'+rt+'00'+i;
                opp.StageName = 'Cotización';
                opp.CloseDate = Date.today();
                opp.CEN_Importe__c = 9999.00;
                opp.CEN_Inicial_de_precio__c = 1000.00;
                opp.CEN_Medio_Publicitario__c = '0113';
                opp.CEN_MaximumPaymentDate__c=Date.today();
                opp.CEN_Motivo_de_Compra__c = 'Vivienda';
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
                opps.add(opp);
            }
        }
        return opps;
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItemsDataBasic(Map<String, Integer> recordTypeAndCantOpp) {
        system.debug('getOpportunityLineItemsDataBasic');
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Set<String> rts = recordTypeAndCantOpp.keySet();
        for(String rt: rts){
            for(Integer i=0; i < recordTypeAndCantOpp.get(rt);i++){
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Product2Id = getProduct2DataBasic(recordTypeAndCantOpp)[0].Id;
                oppLineItem.UnitPrice = 5993048;
                oppLineItem.Quantity = 2;
                oppLineItems.add(oppLineItem);
            }
        }
        return oppLineItems;
    }
    
    private static List<Pricebook2> getPriceBook(Set<String> nameBook){
        system.debug('getPriceBook');
        List<Pricebook2> bookResp = new List<Pricebook2>();
        for(String book2: nameBook){
              Pricebook2 setBook2 = new Pricebook2();
            setBook2.Name = book2;
            setBook2.IsActive = true;
            bookResp.add(setBook2);  
            
        }
        insert bookResp;
        return bookResp;
    }
    
    private static Boolean setPricebookEntry(List<Product2> prod2s, List<Pricebook2> priceBooks){
       system.debug('setPricebookEntry');
        system.debug('setPricebookEntry-prod2s: '+prod2s);
        Boolean resp = false;
        List<PricebookEntry> priceList = new List<PricebookEntry>();
        for(Pricebook2 pb2: priceBooks){
            for(Product2 prod2: prod2s){
                String prodName = prod2.Name;
                if(prodName.contains(pb2.Name)){
                    system.debug('pb2-IsStandard: '+pb2.IsStandard);
                    system.debug('prodName: '+prodName);
                    PricebookEntry setPrice = new PricebookEntry();                    
                    setPrice.Pricebook2Id= Test.getStandardPricebookId();//prodName.contains('ESStandar')?Test.getStandardPricebookId():pb2.Id;
                    setPrice.Product2Id=prod2.Id;
                    setPrice.UnitPrice=10000;
                    setPrice.IsActive=true;
                    setPrice.UseStandardPrice = false;// prodName.contains('ESStandar')?true:false;
                    priceList.add(setPrice);
                }
            }
        }
        system.debug('priceList: '+priceList);
        if(priceList.size()>0){
            insert priceList;
            resp=true;}
        return resp;
    }

}