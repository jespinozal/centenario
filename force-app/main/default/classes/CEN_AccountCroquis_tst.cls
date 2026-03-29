/**
 * @description       : 
 * @author            : edson escobedo
 * @group             : 
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   09-07-2023   edson escobedo    Initial Version
**/
@isTest
public with sharing class CEN_AccountCroquis_tst {
    @TestSetup
    static void SetUp(){

        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_N_mero_de_documento__pc = '12345678';
        acc.CEN_Latitude__c = 3.89;
        acc.CEN_Longitude__c = 1.34;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert acc;
        
    }


    /*
     * Validar la generacion del pdf CEN_AccountCroquis_cls
     */
    @isTest
    public static void OK_CroquisPDF(){
        Account acc = [SELECT Id,CEN_Longitude__c,CEN_Latitude__c FROM Account LIMIT 1];
        ApexPages.StandardController scontr = new ApexPages.StandardController(acc);
        CEN_AccountCroquis_cls pdf = new CEN_AccountCroquis_cls(scontr);
        
        String marker = 'markers=size:mid%7Ccolor:red%7C';
        String googleMap = 'https://maps.googleapis.com/maps/api/staticmap?';
        String zoom = '16';
        String size = '600x400';
        String key = Label.CEN_url_api_google_maps_static;
        String latitud = String.valueOf(acc.CEN_Latitude__c);
        String longitud = String.valueOf(acc.CEN_Longitude__c);
        String urlMapaReferencia = googleMap+'center='+latitud+','+longitud+'&zoom='+zoom+'&size='+size+'&'+marker+latitud+','+longitud+'&key='+key;

        Test.startTest();
            String urlMapaReferenciaTest = pdf.getMapaReferencia();
            String recordTypeAcc = pdf.getTipoCuenta();
        Test.stopTest();

        System.assertEquals(urlMapaReferencia, urlMapaReferenciaTest, 'Debe ser misma url');
        System.assertEquals('PersonAccount', recordTypeAcc, 'Debe tener RT');
    }
}