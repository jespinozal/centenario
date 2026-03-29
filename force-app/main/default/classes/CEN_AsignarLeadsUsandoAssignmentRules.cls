/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 28-10-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   28-10-2024   Diego Bravo   Initial Version
**/
public class CEN_AsignarLeadsUsandoAssignmentRules
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;          
            Lead leads=[SELECT Id FROM lead WHERE Id IN: LeadIds WITH USER_MODE LIMIT 1];
            leads.setOptions(dmo);

            update leads;
   }
}