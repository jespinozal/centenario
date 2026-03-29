/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-14 
* @description: Trigger Arqueo de Caja. 
* 
* VERSION      DATE                 AUTOR                  ACTION 
* 0.1          2021-06-14           Alan Alvarez           Creación 
*  
*********************************************************************/ 
trigger CEN_CashRegistred_tgr on CEN_CashRegistred__c (before insert, before update, after undelete) {

    if ( Trigger.IsBefore && Trigger.IsInsert ) {
        CEN_CashRegistredTriggerHandler_cls.triggerInsert(trigger.new);
    }

}