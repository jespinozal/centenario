/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 03-10-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   03-09-2024   Diego Bravo   Initial Version
**/
@isTest
public with sharing class CEN_ConvertBase64ToPdf_test {
    
    static final String RECORDTYPEID_CASE_INTERACCION_RESOLUCION     = 'CEN_InteraccionUrbanoResolucion';
    static final String CASE_ORIGIN                                  = 'Web';
    static final String CASE_NOMBRE_ACTUALIZADO                      = 'Test';
    static final String CASE_APELLIDO_ACTUALIZADO                    = 'Test1';
    static final String CASE_TIPO_DOCUMENTO                          = 'DNI';
    static final String CASE_N_DOCUMENTO                             = '75325845';
    static final String BASE64BASE64_FILE                            = 'SG9sYSwKCkVzdGUgZXMgdW4gUERGIGRlIHBydWViYSBwYXJhIGVsIGNhc28gZGUgaW50ZXJhY2Npw7NuIGRlIHJlc29sdWNpw7NuLgoKU2FsdWRvcy4=';
    static final String TEST_RESULT_COMPLETADO                       = 'ERROR'; 

    @testSetup
    static void makeData(){
        //Creación del Caso
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPEID_CASE_INTERACCION_RESOLUCION).getRecordTypeId();

        Case caseRecord = new Case();
        caseRecord.RecordTypeId                 = recordTypeId;
        caseRecord.Origin                       = CASE_ORIGIN;
        caseRecord.CEN_nombre_actualizado__c    = CASE_NOMBRE_ACTUALIZADO;
        caseRecord.CEN_apellido_actualizado__c  = CASE_APELLIDO_ACTUALIZADO;
        caseRecord.CEN_Tipo_de_documento__c     = CASE_TIPO_DOCUMENTO;
        caseRecord.N_mero_de_documento__c       = CASE_N_DOCUMENTO;

        insert caseRecord;
    }

    @isTest 
    static void convertFileTest(){

        String caseId = [SELECT Id FROM Case WHERE N_mero_de_documento__c =: CASE_N_DOCUMENTO WITH SYSTEM_MODE].Id;
        String resultTest;

        CEN_convertFile varFile = new CEN_convertFile();
        varFile.recordId = caseId;
        varFile.clausulaPdfContent = BASE64BASE64_FILE;

        List<CEN_convertFile> listFile = new List<CEN_convertFile>();
        listFile.add(varFile);

        try {
            CEN_ConvertBase64ToPdf.convertFile(listFile);
            resultTest = 'COMPLETADO';
        } catch (Exception e) {
            resultTest = 'ERROR';
        }

        System.assertEquals(TEST_RESULT_COMPLETADO, resultTest);

        
    }




}