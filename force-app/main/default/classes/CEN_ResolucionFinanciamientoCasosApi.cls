/**
 * @name               : CEN_ResolucionFinanciamientoCasosApi
 * @author             : Diego Bravo
 * @creation date      : 12-08-2024
 * @modification date  : 06-09-2024
 * @last modified by   : Diego Bravo
 * @description        : Clase con la estructura del servicio Resolución Financiamiento.
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   12-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_ResolucionFinanciamientoCasosApi {

    @AuraEnabled public Integer proforma;
    @AuraEnabled public String  bukrs;
    @AuraEnabled public String  processo;
    @AuraEnabled public String  stcd1;
    @AuraEnabled public String  fechaCartaNotarial;
    @AuraEnabled public Decimal penalidad;
    @AuraEnabled public Decimal porcenComisionVentas;
    @AuraEnabled public Decimal cargosPorCtaCliente;
    @AuraEnabled public Decimal otrosGastos;
    @AuraEnabled public Decimal otrosGastosCliente;
    @AuraEnabled public String  motivo;
    @AuraEnabled public String  idIteracion;
    @AuraEnabled public Integer codLiquidacion;
    @AuraEnabled public String saldoFavorCliente;
    @AuraEnabled public String  estado;
    @AuraEnabled public String  clausula;
    @AuraEnabled public String  resolucion;
    @AuraEnabled public List<Mensaje> mensaje;

    public class Mensaje{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public String message;
        @AuraEnabled public String logNo;
        @AuraEnabled public Integer logMsgNo;
        @AuraEnabled public String messageV1;
        @AuraEnabled public String messageV2;
        @AuraEnabled public String messageV3;
        @AuraEnabled public String messageV4;
        @AuraEnabled public String parameter;
        @AuraEnabled public Integer row;
        @AuraEnabled public String field;
    }

    public static CEN_ResolucionFinanciamientoCasosApi parse(String json) {
        System.debug('Json Test: ' + json);
		return (CEN_ResolucionFinanciamientoCasosApi) System.JSON.deserialize(json, CEN_ResolucionFinanciamientoCasosApi.class);
	}
}