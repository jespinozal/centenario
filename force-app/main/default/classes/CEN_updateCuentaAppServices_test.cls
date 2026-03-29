/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 07-10-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   07-10-2024   Diego Bravo   Initial Version
**/
@isTest 
public with sharing class CEN_updateCuentaAppServices_test {

    @TestSetup
    static void SetUp(){
        Account newAccount = new Account();
        newAccount.LastName                         = 'Test';
        newAccount.PersonLeadSource                 = 'Call Center';
        newAccount.CEN_Medio__c                     = '0125';
        newAccount.CEN_Tipo_de_documento__pc        = 'DNI';
        newAccount.CEN_Numero_de_documento_del__c   = '45634234';
        newAccount.CEN_N_mero_de_documento__pc      = '45634234';

        insert newAccount;
    }

    @isTest
    public static void referidosExito(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Test.startTest();
        req.requestURI = '/services/apexrest/updateCuentaApp/';  
        req.httpMethod = 'PATCH';
        Blob strJson = Blob.valueOf('[{"numeroDocumentoReferente" : "45634234","cantidadLinks" : 1,"nombreReferente": "Lucia","apellidosReferente": "Sanchez","tipoDocumentoReferente": "DNI","referidos":[{"nombreReferido": "Joel","apellidoReferido": "Espinoza","parentescoReferido": "Padre","fechaRegistro": "1727750447","URL": "https://www.linkAppReferidos.com/12345678","fechaVigenciaURL": "1727750447"}]}]');
        req.requestBody = strJson;
        RestContext.request = req;
        RestContext.response= res;
        String results = CEN_updateCuentaAppServices_cls.doPatch();
        Test.stopTest();

    }
}