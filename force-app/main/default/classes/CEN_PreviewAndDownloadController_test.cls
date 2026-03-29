/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 03-09-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   03-09-2024   Diego Bravo   Initial Version
**/
@isTest
public with sharing class CEN_PreviewAndDownloadController_test {
    static final String RECORDTYPEID_CASE_INTERACCION_RESOLUCION     = 'CEN_InteraccionUrbanoResolucion';
    static final String CASE_ORIGIN                                  = 'Web';
    static final String CASE_NOMBRE_ACTUALIZADO                      = 'Test';
    static final String CASE_APELLIDO_ACTUALIZADO                    = 'Test1';
    static final String CASE_TIPO_DOCUMENTO                          = 'DNI';
    static final String CASE_N_DOCUMENTO                             = '75325845';
    static final String BASE64BASE64_FILE                            = 'SG9sYSwKCkVzdGUgZXMgdW4gUERGIGRlIHBydWViYSBwYXJhIGVsIGNhc28gZGUgaW50ZXJhY2Npw7NuIGRlIHJlc29sdWNpw7NuLgoKU2FsdWRvcy4=';
    static final String TIPO_DOCUMENTO                               = 'Cláusula de Resolución';
    static final Boolean RESOLUCION_ESPECIAL                         = false;
    static final String TITLE                                        ='Preview Document';

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
        
        String caseId = [SELECT Id FROM Case WHERE N_mero_de_documento__c =: CASE_N_DOCUMENTO WITH SYSTEM_MODE].Id;

        //Creación de contentDocument
        Blob bodyBlob =EncodingUtil.base64Decode(BASE64BASE64_FILE);
        ContentVersion contentVersion1 = new ContentVersion(
            Title='Preview Document', 
            PathOnClient ='Preview Document.pdf',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion1;
        
        ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId 
                                    FROM ContentVersion WHERE Id = :contentVersion1.Id WITH SYSTEM_MODE LIMIT 1];
                    
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = caseId;
        contentlink.contentdocumentid = contentVersion2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }


    @isTest 
    static void previewFileTest(){

        String caseId = [SELECT Id FROM Case WHERE N_mero_de_documento__c =: CASE_N_DOCUMENTO WITH SYSTEM_MODE].Id;
        Id documentId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseId WITH SYSTEM_MODE].ContentDocumentId;
        Map<ID, String> mapTest = new Map<ID, String>();

        mapTest = CEN_PreviewAndDownloadController.getRelatedFilesByRecordId(caseId, TIPO_DOCUMENTO, RESOLUCION_ESPECIAL);
        System.assertEquals(TITLE, mapTest.get(documentId));


    }

}