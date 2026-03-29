/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 28-12-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   28-12-2021   @everis.com   Initial Version
**/
public with sharing class CEN_ModifyClientQueueable_ctr implements Queueable,Database.AllowsCallouts {
    
    private String accId;
    public CEN_ModifyClientQueueable_ctr(String myIds) {
        this.accId = myIds;
    }

    public void execute(QueueableContext context) {

        System.debug('context: ' + context);
        List<Account> acc = [SELECT Id,CEN_SocietySAP__c FROM Account WHERE Id=: this.accId];

        System.debug('acc: ' + acc);
        String strSociety = acc[0].CEN_SocietySAP__c;
        String[] arrSociety = strSociety.split(';');
        Integer contSociety = arrSociety.size();

        for (Integer i = 0; i < contSociety; i++) {
            CEN_ModifyClient_ctr.callModifyClient(acc[0].Id, arrSociety[i], acc[0].CEN_SocietySAP__c);
            // Integer counter = 0;
            // Datetime initialTime = System.now();
            // Datetime seconds = initialTime.addSeconds(20);
            // System.debug('initialTime ' + initialTime);
            // System.debug('seconds ' + seconds);

            // if(i == 0){
            //     CEN_ModifyClient_ctr.callModifyClient(acc[0].Id, arrSociety[i]);
            // }else{
            //     while(seconds <= System.now() == false) {
            //         counter++;
            //         System.debug('counter ' + counter);
            //     }
            //     CEN_ModifyClient_ctr.callModifyClient(acc[0].Id, arrSociety[i]);
            // }
        }
    }

}