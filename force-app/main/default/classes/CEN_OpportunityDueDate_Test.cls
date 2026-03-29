/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 28-09-2023
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   28-09-2023   @nttdata.com   Initial Version
**/
@isTest
public with sharing class CEN_OpportunityDueDate_Test {
    @testSetup
    public static void setup() {
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        projs[0].CEN_Sociedad__c = '0019';
        insert projs;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '0016728109';
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        mapOpp.put('Urbano', 2);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].CEN_Proyecto__c = projs[0].id;
        opps[0].AccountId = accs[0].id;
        opps[0].CEN_Cola__c = 'Procesando';
        opps[1].CEN_Proyecto__c = projs[0].id;
        opps[1].AccountId = accs[0].id;
        opps[1].CEN_Cola__c = 'Procesando';
        insert opps;
    }
    @IsTest  static void annulmentOpportunity(){

        Test.startTest();
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        CEN_OpportunityDueDate_ctr.annulmentOpportunityDueDatePayment(oppId);

        Test.stopTest();
    }

    // @IsTest  static void annulmentOpportunityQueueable(){

    //     Test.startTest();
    //     ID jobID = System.enqueueJob(new CEN_OpportunityDueDateQueueable_ctr());

    //     Test.stopTest();
    // }
}