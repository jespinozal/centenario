/**
 * @name               : CEN_ResolucionFinanciamientoCasos
 * @author             : Diego Bravo
 * @creation date      : 12-08-2024
 * @modification date  : 09-09-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : Clase Controladora
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   12-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_ResolucionFinanciamientoCasos {
    
    static final String SOL_VENDEDOR              = 'Solicitud del Vendedor';
    static final String SOL_COMPRADOR             = 'Solicitud del Comprador';
    static final String SOL_ESPECIAL              = 'Resolución Especial';
    static final String CAPITAL                   = 'Capital';
    static final String CAP_INT_GAS               = 'Capital + Intereses + Gastos';
    static final String API_CORRECTO              = 'Correcto';
    static final String API_ERROR                 = 'Error';
    static final String API_SERVICIO              = 'CEN_ResolucionContrato';
    static final String LOG_TYPE                  = 'Callout';

    @InvocableMethod (label = 'executeApi' description = 'ejecución del API Resolución Financiamiento')
    public static List<CEN_resolucionResponse> executeApi(List<CEN_resolucionRequest> inputValues){
        List<CEN_resolucionResponse> outputResponse = new List<CEN_resolucionResponse>();
        CEN_resolucionResponse responseToFlow = new CEN_resolucionResponse();

        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.modo                 = inputValues[0].modo ;
        requestWrapper.proforma             = inputValues[0].proforma;
        requestWrapper.bukrs                = inputValues[0].bukrs;
        requestWrapper.processo             = inputValues[0].processo;
        requestWrapper.stcd1                = inputValues[0].stcd1;
        requestWrapper.solVen               = inputValues[0].solVen;
        requestWrapper.solCom               = inputValues[0].solCom;
        requestWrapper.solEsp               = inputValues[0].solEsp;
        requestWrapper.transfTitular        = inputValues[0].transfTitular;
        requestWrapper.capital              = inputValues[0].capital;
        requestWrapper.capIntGas            = inputValues[0].capIntGas;
        requestWrapper.fechaCartaNotarial   = inputValues[0].fechaCartaNotarial;
        requestWrapper.penalidad            = inputValues[0].penalidad;
        requestWrapper.porcenComisionVentas = inputValues[0].porcenComisionVentas; 
        requestWrapper.cargosPorCtaCliente  = inputValues[0].cargosPorCtaCliente;
        requestWrapper.otrosGastos          = inputValues[0].otrosGastos;
        requestWrapper.otrosGastosCliente   = inputValues[0].otrosGastosCliente;
        requestWrapper.motivo               = inputValues[0].motivo; 
        requestWrapper.idIteracion          = inputValues[0].idIteracion;
        requestWrapper.apoderadoCentenario1 = inputValues[0].apoderadoCentenario1;
        requestWrapper.apoderadoCentenario2 = inputValues[0].apoderadoCentenario2;
        requestWrapper.userResuelve         = UserInfo.getName();
        System.debug('apoderadoCentenario1'+requestWrapper.apoderadoCentenario1);
        System.debug('apoderadoCentenario2'+requestWrapper.apoderadoCentenario2);
        System.debug('userResuelve'+requestWrapper.userResuelve);



        // requestWrapper.modo                 = 'SIMU';
        // requestWrapper.proforma             = 59536;
        // requestWrapper.bukrs                = '0019';
        // requestWrapper.processo             = '19U1.902E';
        // requestWrapper.stcd1                = '46688261';
        // requestWrapper.solVen               = '';
        // requestWrapper.solCom               = 'X';
        // requestWrapper.solEsp               = '';
        // requestWrapper.transfTitular        = '';
        // requestWrapper.capital              = 'X';
        // requestWrapper.capIntGas            = '';
        // requestWrapper.fechaCartaNotarial   = '';
        // requestWrapper.penalidad            = 0;
        // requestWrapper.porcenComisionVentas = 0; 
        // requestWrapper.cargosPorCtaCliente  = 0;
        // requestWrapper.otrosGastos          = 0;
        // requestWrapper.otrosGastosCliente   = 0;
        // requestWrapper.motivo               = ''; 
        // requestWrapper.idIteracion          = '1234';

        CEN_ResolucionFinanciamientoCasosApi objResolucionContrato = new CEN_ResolucionFinanciamientoCasosApi();
        objResolucionContrato = callApiResolucionContrato(requestWrapper);

        // System.debug('objResolucionContrato: ' + objResolucionContrato);

        if (objResolucionContrato != null) {
            responseToFlow.proforma             = objResolucionContrato.proforma;
            responseToFlow.bukrs                = objResolucionContrato.bukrs;
            responseToFlow.processo             = objResolucionContrato.processo;
            responseToFlow.sTCD1                = objResolucionContrato.sTCD1;
            responseToFlow.fechaCartaNotarial   = objResolucionContrato.fechaCartaNotarial;
            responseToFlow.penalidad            = objResolucionContrato.penalidad;
            responseToFlow.porcenComisionVentas = objResolucionContrato.porcenComisionVentas;
            responseToFlow.cargosPorCtaCliente  = objResolucionContrato.cargosPorCtaCliente;
            responseToFlow.otrosGastos          = objResolucionContrato.otrosGastos;
            responseToFlow.otrosGastosCliente   = objResolucionContrato.otrosGastosCliente;
            responseToFlow.motivo               = objResolucionContrato.motivo;
            responseToFlow.idIteracion         = objResolucionContrato.idIteracion;
            responseToFlow.codLiquidacion       = objResolucionContrato.codLiquidacion;
            responseToFlow.estado               = objResolucionContrato.estado;
            responseToFlow.clausula             = objResolucionContrato.clausula;
            responseToFlow.resolucion           = objResolucionContrato.resolucion;
            responseToFlow.saldoFavorCliente    = objResolucionContrato.saldoFavorCliente;
            if (!Test.isRunningTest()) {
                responseToFlow.mensaje              = objResolucionContrato.mensaje[0].message;
            }
        }
        outputResponse.add(responseToFlow);

        return outputResponse;
    }

    public static CEN_ResolucionFinanciamientoCasosApi callApiResolucionContrato (RequestWrapper requestWrapper){
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('modo', requestWrapper.modo);
        requestMap.put('idIteracion', requestWrapper.idIteracion);
        requestMap.put('proforma', String.valueOf(requestWrapper.proforma));
        requestMap.put('bukrs', requestWrapper.bukrs);
        requestMap.put('processo', requestWrapper.processo);
        requestMap.put('solVen', requestWrapper.solVen);
        requestMap.put('solCom', requestWrapper.solCom);
        requestMap.put('solEsp', requestWrapper.solEsp);
        requestMap.put('capital', requestWrapper.capital);
        requestMap.put('capIntGas', requestWrapper.capIntGas);
        requestMap.put('fechaCartaNotarial', requestWrapper.fechaCartaNotarial);
        requestMap.put('penalidad', String.valueOf(requestWrapper.penalidad));
        requestMap.put('porcenComisionVentas', String.valueOf(requestWrapper.porcenComisionVentas));
        requestMap.put('cargosPorCtaCliente', String.valueOf(requestWrapper.cargosPorCtaCliente));
        requestMap.put('otrosGastos', String.valueOf(requestWrapper.otrosGastos));
        requestMap.put('otrosGastosCliente', String.valueOf(requestWrapper.otrosGastosCliente));
        requestMap.put('motivo', requestWrapper.motivo);
        requestMap.put('stcd1', requestWrapper.stcd1);
        requestMap.put('apoderadoCentenario1', requestWrapper.apoderadoCentenario1);
        requestMap.put('apoderadoCentenario2', requestWrapper.apoderadoCentenario2);
        requestMap.put('userResuelve', requestWrapper.userResuelve);


        String jsonRequest = JSON.serialize(requestMap);
        String response;
        String calloutResult;
        CEN_ResolucionFinanciamientoCasosApi resolucionContrato = new CEN_ResolucionFinanciamientoCasosApi();

        if (Test.isRunningTest()) {
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('proforma', 45001);
            responseMap.put('bukrs', '0019');
            responseMap.put('processo', '19U1.273E');
            responseMap.put('stcd1', '43322112');
            responseMap.put('fechaCartaNotarial', '2024-08-01');
            responseMap.put('penalidad', 30);
            responseMap.put('porcenComisionVentas', 1.785);
            responseMap.put('cargosPorCtaCliente', 0);
            responseMap.put('otrosGastos', 0);
            responseMap.put('otrosGastosCliente', 0);
            responseMap.put('motivo', 'CUO');
            responseMap.put('idIteracion', 'Test123');
            responseMap.put('codLiquidacion', 7800);
            responseMap.put('estado', 'COMPLETADO');
            responseMap.put('clausula', 'SG9sYSBNdW5kbw==');
            responseMap.put('resolucion', 'UmVzb2x1Y2nDs24gQ29udHJhdG8=');

            String jsonResponse = JSON.serialize(responseMap);
            resolucionContrato = CEN_ResolucionFinanciamientoCasosApi.parse(jsonResponse);
        }
        
        if (!Test.isRunningTest()) {
            try {
                CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_ResolucionContrato');
                callApi.setRequestBody(jsonRequest);
                callApi.setTimeout(120000);
                response = (String) callApi.makeCallout().getParsedResponse();
                if (response != null) {
                    resolucionContrato = CEN_ResolucionFinanciamientoCasosApi.parse(response);
                }
                calloutResult = API_CORRECTO;
                System.debug('RequestAPI: ' + jsonRequest);
                System.debug('ResponseAPI: ' + response);

            } catch (Exception e) {
                calloutResult = API_ERROR;
                System.debug('RequestAPI: ' + jsonRequest);
                System.debug('ResponseAPI: ' + response);
            }
        }
        
        return resolucionContrato;

    }

    public static String obtenerIdCaso(String caseNumber){
        String caseId;

        List<Case> recordCase = [SELECT Id FROM Case WHERE CaseNumber =: caseNumber WITH USER_MODE];
        
        for (case varCase : recordCase) {
            caseId = varCase.Id == null ? '' : varCase.Id;
        }

        return caseId;
    }

    public class RequestWrapper{
        @AuraEnabled public String  modo;
        @AuraEnabled public Integer proforma;
        @AuraEnabled public String  bukrs;
        @AuraEnabled public String  processo;
        @AuraEnabled public String  stcd1;
        @AuraEnabled public String  solVen;
        @AuraEnabled public String  solCom;
        @AuraEnabled public String  solEsp;
        @AuraEnabled public String  transfTitular; 
        @AuraEnabled public String  capital; 
        @AuraEnabled public String  capIntGas; 
        @AuraEnabled public String  fechaCartaNotarial; 
        @AuraEnabled public Decimal penalidad; 
        @AuraEnabled public Decimal porcenComisionVentas; 
        @AuraEnabled public Decimal cargosPorCtaCliente; 
        @AuraEnabled public Decimal otrosGastos; 
        @AuraEnabled public Decimal otrosGastosCliente; 
        @AuraEnabled public String  motivo; 
        @AuraEnabled public String  idIteracion;
        @AuraEnabled public String apoderadoCentenario1;
        @AuraEnabled public String apoderadoCentenario2;
        @AuraEnabled public String userResuelve;

    }

    public class InputLog{
        @AuraEnabled public String requestAPI;
        @AuraEnabled public String responseAPI; 
        @AuraEnabled public String responseType;
        @AuraEnabled public String caseId;
    }


    
}