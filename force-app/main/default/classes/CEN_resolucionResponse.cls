/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 06-09-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_resolucionResponse {
    @AuraEnabled @InvocableVariable public Integer proforma;
    @AuraEnabled @InvocableVariable public String  bukrs;
    @AuraEnabled @InvocableVariable public String  processo;
    @AuraEnabled @InvocableVariable public String  sTCD1;
    @AuraEnabled @InvocableVariable public String  fechaCartaNotarial;
    @AuraEnabled @InvocableVariable public Decimal penalidad;
    @AuraEnabled @InvocableVariable public Decimal porcenComisionVentas;
    @AuraEnabled @InvocableVariable public Decimal cargosPorCtaCliente;
    @AuraEnabled @InvocableVariable public Decimal otrosGastos;
    @AuraEnabled @InvocableVariable public Decimal otrosGastosCliente;
    @AuraEnabled @InvocableVariable public String  motivo;
    @AuraEnabled @InvocableVariable public String  idIteracion;
    @AuraEnabled @InvocableVariable public Integer  codLiquidacion;
    @AuraEnabled @InvocableVariable public String  estado;
    @AuraEnabled @InvocableVariable public String  clausula;
    @AuraEnabled @InvocableVariable public String  resolucion;
    @AuraEnabled @InvocableVariable public String saldoFavorCliente;
    @AuraEnabled @InvocableVariable public String mensaje;

}