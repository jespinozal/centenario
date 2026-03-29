/**
 * @description Trigger for the CEN_CaseTracking__c object.
 * Delegates all logic to the CEN_CaseTrackingTriggerHandler class.
 * Jesus Poco - jpocosal@emeal.nttdata.com
 */
trigger CEN_CaseTrackingTrigger on CEN_CaseTracking__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        CEN_CaseTrackingTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}