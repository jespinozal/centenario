/**
 * @description Trigger principal para el objeto Case. Delega la lógica a clases handler
 * @author      jesusjaime.pocosalvador@emeal.nttdata.com
 * @date        06/09/2025
 * @see         CaseTrigger
 */
trigger CEN_CaseEventoClaveTrigger on Case (after update) {
    
    // En el evento 'after update', se invoca el método correspondiente del handler.
    if (Trigger.isAfter && Trigger.isUpdate) {
        CEN_CaseEventoClaveTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}