/**
 * @name               : CEN_ResolucionFinanciamientoCasos_test
 * @author             : Diego Bravo
 * @creation date      : 26-08-2024
 * @modification date  : 02-09-2024
 * @last modified by   : Diego Bravo
 * @description        : Clase Test de la clase CEN_ResolucionFinanciamientoCasos
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   26-08-2024   Diego Bravo   Initial Version
**/
@isTest
public with sharing class CEN_ResolucionFinanciamientoCasos_test {
        
    private static final String SERVICE_RESPONSE_ESTADO_COMPLETADO      = 'COMPLETADO';
    private static final String SERVICE_RESPONSE_ESTADO_ENPROCESO       = 'EN PROCESO';
    private static final String SERVICE_RESPONSE_ESTADO_ERROR           = null;

    @isTest
    public static void resolucionContratoExito(){
        Test.startTest();
            CEN_resolucionRequest requestMock = new CEN_resolucionRequest();
            requestMock.modo                 = 'SIMU';
            requestMock.proforma             = 59380;
            requestMock.bukrs                = '0019';
            requestMock.processo             = '19U1.902E';
            requestMock.stcd1                = '43322112';
            requestMock.solVen               = '';
            requestMock.solCom               = 'X';
            requestMock.solEsp               = '';
            requestMock.transfTitular        = '';
            requestMock.capital              = 'X';
            requestMock.capIntGas            = '';
            requestMock.fechaCartaNotarial   = '2024-08-01';
            requestMock.penalidad            = 0;
            requestMock.porcenComisionVentas = 0; 
            requestMock.cargosPorCtaCliente  = 0;
            requestMock.otrosGastos          = 0;
            requestMock.otrosGastosCliente   = 0;
            requestMock.motivo               = 'CUO'; 
            requestMock.idIteracion          = '1234';
            List<CEN_resolucionRequest> listRequest = new List<CEN_resolucionRequest>();
            listRequest.add(requestMock);
            List<CEN_resolucionResponse> response = CEN_ResolucionFinanciamientoCasos.executeApi(listRequest);
        Test.stopTest();
        System.assertEquals(SERVICE_RESPONSE_ESTADO_COMPLETADO, response[0].estado,'');
    }
}