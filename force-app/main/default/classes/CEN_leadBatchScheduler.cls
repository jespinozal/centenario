/**
 * @name               : CEN_leadBatchScheduler
 * @author             : Diego Bravo
 * @creation date      : 26-09-2024
 * @modification date  : 26-09-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   26-09-2024   Diego Bravo   Initial Version
**/
global class CEN_leadBatchScheduler implements Database.AllowsCallouts, Schedulable{
    global void execute(SchedulableContext context) {
        // Create an instance of the batch class
        CEN_massLeadEmailBatch batch = new CEN_massLeadEmailBatch();
        
        // Schedule the batch job
        Database.executeBatch(batch);
    }
}