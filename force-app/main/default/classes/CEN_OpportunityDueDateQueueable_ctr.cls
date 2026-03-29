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
public with sharing class CEN_OpportunityDueDateQueueable_ctr implements Queueable,Database.AllowsCallouts {

    private List<Opportunity> opps;
    public CEN_OpportunityDueDateQueueable_ctr() {

        this.opps = [SELECT Id FROM Opportunity WHERE CEN_Cola__c IN ('Procesando')];
    }

    public void execute(QueueableContext context) {

        if (!TEST.isRunningTest() && opps!=null && opps.size()> 0){
            CEN_OpportunityDueDate_ctr.annulmentOpportunityDueDatePayment(opps[0].Id);
        }
    }

}