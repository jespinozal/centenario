/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 09-09-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_PreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId, String tipoDocumento, Boolean resolucionEspecial) {

        // recordId = '500Em000005LQRcIAO';
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH USER_MODE];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        System.debug('fileIDs: ' + fileIDs);
 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Title LIKE '%Preview%' WITH USER_MODE];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        System.debug('docs: ' + docs);
        System.debug('mapIdTitle: ' + mapIdTitle);

        return mapIdTitle;
    }
}