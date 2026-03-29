/**
 * @description       : 
 * @author            : NTT Data
 * @group             : 
 * @last modified on  : 07-09-2023
 * @last modified by  : NTT Data
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-09-2023   NTT Data    Initial Version
**/
@isTest
public with sharing class CEN_parambuscadorGoogleMap_tst {
    @TestSetup
    static void SetUp(){

        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;

        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_Latitude__c = 3.89;
        acc.CEN_Longitude__c = 1.34;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Tipo_de_documento__pc = 'DNI';
        acc.CEN_N_mero_de_documento__pc = '43686876';
        acc.CEN_Sexo__pc = 'Masculino';
        acc.CEN_Nacionalidad__pc = 'Albania';
        acc.CEN_Distrito__pc = distrito.id;
        acc.CEN_Tipo_Via__c = 'Jr.';
        acc.CEN_Direccion__pc = 'X284+JMV Parque, El Agustino 15007, Perú';
        acc.CEN_Referencia_direccion__c = 'al frente de plaza norte, a 1 cuadra de la comisaria';
        acc.CEN_Situacion_vivienda__c = 'Alquilada';
        acc.PersonEmail = 'test@email.com';
        acc.CEN_Tiempo_de_Residencia__c = 'Años';
        acc.CEN_Estado_civil__pc ='Divorc';
        acc.CEN_Tel_fono_Trabajo__pc = '01 5647832';
        acc.PersonMobilePhone = '111111111';
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Empresa X';
        acc2.CEN_Latitude__c = 3.89;
        acc2.CEN_Longitude__c = 1.34;
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
        acc2.CEN_Tipo_de_documento__c = 'RUC';
        acc2.CEN_Numero_de_documento_del__c = '12345678988';
        acc2.CEN_Distrito__c = distrito.id;
        acc2.CEN_Tipo_Via__c = 'Jr.';
        acc2.CEN_Direcci_n__c = 'X284+JMV Parque, El Agustino 15007, Perú';
        acc2.CEN_Referencia_direccion__c = 'al frente de plaza norte, a 1 cuadra de la comisaria';
        acc2.CEN_Situacion_vivienda__c = 'Alquilada';
        acc2.CEN_fld_Correo_empresa__c = 'test@email.com';
        acc2.CEN_Tiempo_de_Residencia__c = 'Años';
        acc2.CEN_Telefono_Trabajo_Empresa__c = '01 5647832';
        insert acc2;
    }


    /*
     * Validar el buscador del mapa de google al actualizar la direccion de la cuenta
     */
    @isTest
    public static void OK_buscadorGoogleMapsPersona(){
        Account acc = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc = '43686876'];
        ApexPages.StandardController scontr = new ApexPages.StandardController(acc);
        CEN_parambuscadorGoogleMap_cls buscadorGoogleUpdateAddress = new CEN_parambuscadorGoogleMap_cls(scontr);
        PageReference pr2 = new PageReference('/'+acc.Id );

        Test.startTest();
            PageReference pr1 = buscadorGoogleUpdateAddress.guardarDireccion();
        Test.stopTest();

        System.assertEquals(pr2.getURL(), pr1.getURL(), 'Debe ser la misma PageReference url');
    }

    @isTest
    public static void OK_buscadorGoogleMapsEmpresa(){
        Account acc = [SELECT Id FROM Account WHERE CEN_Numero_de_documento_del__c = '12345678988'];
        ApexPages.StandardController scontr = new ApexPages.StandardController(acc);
        CEN_parambuscadorGoogleMap_cls buscadorGoogleUpdateAddress = new CEN_parambuscadorGoogleMap_cls(scontr);
        PageReference pr2 = new PageReference('/'+acc.Id );

        Test.startTest();
            PageReference pr1 = buscadorGoogleUpdateAddress.guardarDireccion();
        Test.stopTest();

        System.assertEquals(pr2.getURL(), pr1.getURL(), 'Debe ser la misma PageReference url');
    }
}