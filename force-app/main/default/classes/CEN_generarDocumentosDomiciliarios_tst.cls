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
public with sharing class CEN_generarDocumentosDomiciliarios_tst {
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
        acc.CEN_N_mero_de_documento__pc = '12345678';
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
        acc.CEN_Tipo_de_documento__c = 'RUC';
        insert acc;
    }


    /*
     * Valida la generacion de documentos
     */
    @isTest
    public static void OK_flowGenerarDocumentos(){
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        List<CEN_generarDocumentosDomiciliarios.FlowParameters> parameterList = new List<CEN_generarDocumentosDomiciliarios.FlowParameters>();
        CEN_generarDocumentosDomiciliarios.FlowParameters parameter = new CEN_generarDocumentosDomiciliarios.FlowParameters();
        parameter.accIds = acc[0].id;
        parameterList.add(parameter);

        Test.startTest();
            List<String> listResp = CEN_generarDocumentosDomiciliarios.processGenerateDocumentAddress(parameterList);
        Test.stopTest();

        System.assertEquals(listResp.size()>0, true, 'Error generar documentos');
    }
}