/**
* @description       :
* @author            : @nttdata.com
* @group             :
* @last modified on  : 28-09-2023
* @last modified by  : @nttdata.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   28-09-2023   @everis.com   Initial Version
**/
public with sharing class CEN_OpportunityDueDate_ctr {

    public static void annulmentOpportunityDueDatePayment(String oppId) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: oppId];
        opp.CEN_estado_aprobacion__c = 'ACEPTADO';
        opp.CEN_Cola__c = 'Exito';
        System.debug('opp-anula: ' + opp);
        update opp;
        ID jobID = System.enqueueJob(new CEN_OpportunityDueDateQueueable_ctr(),2);
    }

}