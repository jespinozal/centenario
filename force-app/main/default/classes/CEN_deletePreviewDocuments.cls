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
 * 1.0   20-08-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_deletePreviewDocuments {

    static final String TITLE              = '%Preview%';

    @InvocableMethod (label = 'Delete Files' description = 'Borrar archivos Preview')
    public static List<List<String>> getContentDocument (List<String> recordId){
        List<List<String>> listContentDocument = new List<List<String>>();
        List<String> varContentDocument = new List<String>();
        List<ID> fileIDs = new List<ID>();

        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH USER_MODE];
        
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Title LIKE : TITLE WITH USER_MODE];

        for (ContentVersion varVersion : docs) {
            varContentDocument.add(varVersion.ContentDocumentId);
        }
        listContentDocument.add(varContentDocument);

        return listContentDocument;
    }
}