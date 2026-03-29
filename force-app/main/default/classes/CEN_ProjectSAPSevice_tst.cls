/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-20-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_ProjectSAPSevice_tst {
    @TestSetup
    static void SetUp(){
        Tabla_maestra__c tm = new Tabla_maestra__c();
		tm.CEN_Codigo_departamento__c = '00001';  
        tm.CEN_Codigo_distrito__c = '00001';  
        tm.CEN_Codigo_provincia__c = '00001'; 
        insert tm; 
    }
    
    static testMethod void CEN_LotSAPSevice_doPost() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/project/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"zonaRegistrada":null,"zona":"Lima Sur 2","tipoVivienda":null,"tipoProyecto":"Urbano","statusProyecto":null,"statusLots":"ARRAS","sociedad":"0018","registro":null,"owner":null,"numeroLicencia":null,"name":"SaritaColonia TEST","montoMinimoReserva":100.00,"montoMinimoDeposito":200.00,"maximumTermForSigningTheContract":1,"maximumPaymentDuePeriod":1,"idSap":"120U3","fechaVigenciaPrecio":null,"fechaInicio":"2021-06-01","fechaEntrega":"2021-06-30","etapa":"3","ejecutivoPostVentaAsignado":null,"departamento":"00001","provincia":"00001","distrito":"00001","direccion":"Olimpo","descripcionProyecto":"Primero Proyecto","codInternoSAP":null,"changeInLotsStatus":false,"centro":"Olimpo","area":"50"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_ProjectSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_LotSAPSevice_doPostError() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/project/';  
            req.httpMethod = 'POST';
        Blob strJson = Blob.valueOf('{"zonaRegistrada":null,"zona":"Lima Sur 2","tipoVivienda":null,"tipoProyecto":"Urbano","statusProyecto":null,"statusLots":"ARRAS","sociedad":"0018","registro":null,"owner":null,"numeroLicencia":null,"name":"SaritaColonia TEST","montoMinimoReserva":100.00,"montoMinimoDeposito":200.00,"maximumTermForSigningTheContract":1,"maximumPaymentDuePeriod":1,"idSap":"120U3","fechaVigenciaPrecio":null,"fechaInicio":"2021-06-01","fechaEntrega":"2021-06-30","etapa":"3","ejecutivoPostVentaAsignado":null,"departamento":"00001","provincia":"00001","distrito":"00001","direccion":"Olimpo","descripcionProyecto":"Primero Proyecto","codInternoSAP":null,"changeInLotsStatus":false,"centro":"Olimpo","area":"50"}');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_ProjectSAPSevice_cls.doPost();
        Test.stopTest();

    }
    
    static testMethod void CEN_LotSAPSevice_doPostErrorData() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/project/';  
            req.httpMethod = 'POST';
        Blob strJson = Blob.valueOf('[{"zonaRegistrada":null,"zona":"Lima Sur 2","tipoVivienda":null,"tipoProyecto":"Urbano","statusProyecto":null,"statusLots":"ARRAS","sociedad":"0018","registro":null,"owner":null,"numeroLicencia":null,"name":"SaritaColonia TEST","montoMinimoReserva":100.00,"montoMinimoDeposito":200.00,"maximumTermForSigningTheContract":1,"maximumPaymentDuePeriod":1,"idSap":null,"fechaVigenciaPrecio":null,"fechaInicio":"2021-06-01","fechaEntrega":"2021-06-30","etapa":"3","ejecutivoPostVentaAsignado":null,"departamento":"00001","provincia":"00001","distrito":"00001","direccion":"Olimpo","descripcionProyecto":"Primero Proyecto","codInternoSAP":null,"changeInLotsStatus":false,"centro":"Olimpo","area":"50"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_ProjectSAPSevice_cls.doPost();
        Test.stopTest();

    }
    
     static testMethod void CEN_LotSAPSevice_doPut() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/project/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"zonaRegistrada":null,"zona":"Lima Sur 2","tipoVivienda":null,"tipoProyecto":"Urbano","statusProyecto":null,"statusLots":"ARRAS","sociedad":"0018","registro":null,"owner":null,"numeroLicencia":null,"name":"SaritaColonia TEST","montoMinimoReserva":100.00,"montoMinimoDeposito":200.00,"maximumTermForSigningTheContract":1,"maximumPaymentDuePeriod":1,"idSap":"120U3","fechaVigenciaPrecio":null,"fechaInicio":"2021-06-01","fechaEntrega":"2021-06-30","etapa":"3","ejecutivoPostVentaAsignado":null,"departamento":"00001","provincia":"00001","distrito":"00001","direccion":"Olimpo","descripcionProyecto":"Primero Proyecto","codInternoSAP":null,"changeInLotsStatus":false,"centro":"Olimpo","area":"50"}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_ProjectSAPSevice_cls.doPut();
        Test.stopTest();
    }
}