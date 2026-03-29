/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 19-08-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_resolucionRequest {
    @AuraEnabled @InvocableVariable public String  modo;
    @AuraEnabled @InvocableVariable public Integer proforma;
    @AuraEnabled @InvocableVariable public String  bukrs;
    @AuraEnabled @InvocableVariable public String  processo;
    @AuraEnabled @InvocableVariable public String  stcd1;
    @AuraEnabled @InvocableVariable public String  solVen;
    @AuraEnabled @InvocableVariable public String  solCom;
    @AuraEnabled @InvocableVariable public String  solEsp;
    @AuraEnabled @InvocableVariable public String  transfTitular; 
    @AuraEnabled @InvocableVariable public String  capital; 
    @AuraEnabled @InvocableVariable public String  capIntGas; 
    @AuraEnabled @InvocableVariable public String  fechaCartaNotarial; 
    @AuraEnabled @InvocableVariable public Decimal penalidad; 
    @AuraEnabled @InvocableVariable public Decimal porcenComisionVentas; 
    @AuraEnabled @InvocableVariable public Decimal cargosPorCtaCliente; 
    @AuraEnabled @InvocableVariable public Decimal otrosGastos; 
    @AuraEnabled @InvocableVariable public Decimal otrosGastosCliente; 
    @AuraEnabled @InvocableVariable public String  motivo; 
    @AuraEnabled @InvocableVariable public String  idIteracion;
    @AuraEnabled @InvocableVariable public String  apoderadoCentenario1;
    @AuraEnabled @InvocableVariable public String  apoderadoCentenario2;

}