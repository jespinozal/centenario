/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 06-30-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-30-2021   @everis.com   Initial Version
**/
public with sharing class CEN_OperationSafeQueueable_ctr implements Queueable,Database.AllowsCallouts {
    
    private String oppId;
    public CEN_OperationSafeQueueable_ctr(String myIds) {
        this.oppId = myIds;
    }

    public void execute(QueueableContext context) {
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id=: this.oppId];
        for(Opportunity myOpp: opp){
            CEN_OperactionSafe_ctr.generateAndUpdateOperationSafeAsinc(myOpp.Id);
        }
    }

}