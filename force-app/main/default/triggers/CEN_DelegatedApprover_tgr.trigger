/********************************************************************* 
* @author: Joel Espinoza (joel.carlos.eugenio.espinoza.ludena@everis.com) 
* @date: 2021-04-05 
* @description: Valida si existe el supervisor en los registros, no dejará insertar, actualizar o restaurar. 
* 
* VERSION      DATE                 AUTOR                  ACTION 
* 0.1          2021-04-05           Joel Espinoza          Creación 
*  
*********************************************************************/ 
trigger CEN_DelegatedApprover_tgr on CEN_DelegatedApprover__c (before insert, before update, after undelete) {
     
    if ( Trigger.IsBefore && Trigger.IsInsert ) {
        CEN_DelegatedApproverTriggerHandler_cls.validateSupervisorNewMethod(trigger.new);
    }
    if ( Trigger.IsBefore && Trigger.IsUpdate ) {
        CEN_DelegatedApproverTriggerHandler_cls.validateSupervisorMethod(trigger.newMap, trigger.oldMap);
    }

}