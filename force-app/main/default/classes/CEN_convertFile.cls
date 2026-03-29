/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 09-09-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_convertFile {
    @AuraEnabled @InvocableVariable public String  recordId;
    @AuraEnabled @InvocableVariable public String  clausulaPdfContent;
    @AuraEnabled @InvocableVariable public String  resolucionPdfContent;
}