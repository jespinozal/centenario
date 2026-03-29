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
 * 1.0   12-08-2024   Diego Bravo   Initial Version
 * 1.1   22-08-2025   Felipe Bermudez  Se mejoro el metodo crearArchivosContrato
**/
public class CEN_ConvertBase64ToPdf {

    static final String TITLE_CLAUSULA     = 'Cláusula de Resolución';
    static final String TITLE_RESOLUCION   = 'Liquidación de Pagos';
    
    @InvocableMethod (label = 'Convert File' description = 'convertir archivo base64 a pdf')
    public static void convertFile (List<CEN_convertFile> listFile){
        crearArchivosContrato(listFile[0].clausulaPdfContent, listFile[0].recordId, TITLE_CLAUSULA);
        crearArchivosContrato(listFile[0].resolucionPdfContent, listFile[0].recordId, TITLE_RESOLUCION);
    }

    // public static void crearArchivosContrato(String pdfContent, String recordId, String titlePDF){
    //     // Blob bodyBlob = Blob.toPdf((EncodingUtil.base64Decode(listFile[0].pdfContent).toString()));
    //     Blob bodyBlob =EncodingUtil.base64Decode(pdfContent);
        
    //     ContentVersion contentVersion1 = new ContentVersion(
    //         Title='Preview' + '-' + titlePDF, 
    //         PathOnClient ='Preview' + '-' + titlePDF + '.pdf',
    //         VersionData = bodyBlob, 
    //         origin = 'H'
    //     );
    //     // insert contentVersion1;

    //     Database.SaveResult saveList = Database.insert(contentVersion1, false);

    //     if(saveList.isSuccess()){
    //         System.debug('I was successful = ' + saveList.getID());
    //     }else {
    //         System.debug('I was Unsuccessful = '+ saveList.getID() + 'because of following errors');
    //         for (Database.error dr: saveList.getErrors()) {
    //             System.debug(dr.getStatusCode() + '' +dr.getMessage());
    //             System.debug('fields affected by insertion are: '+dr.getFields());
    //         }
    //     }
        
        
    //     ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId 
    //                                 FROM ContentVersion WHERE Id = :contentVersion1.Id WITH SYSTEM_MODE LIMIT 1];
                    
    //     ContentDocumentLink contentlink = new ContentDocumentLink();
    //     contentlink.LinkedEntityId = recordId;
    //     contentlink.contentdocumentid = contentVersion2.contentdocumentid;
    //     contentlink.ShareType = 'V';
    //     insert contentlink;

    // } 
    public static void crearArchivosContrato(String pdfContent, String recordId, String titlePDF) {
        try {
            // Decodificar el contenido del PDF
            Blob bodyBlob = EncodingUtil.base64Decode(pdfContent);
            
            // Crear ContentVersion
            ContentVersion contentVersion1 = new ContentVersion(
                Title = 'Preview' + '-' + titlePDF, 
                PathOnClient = 'Preview' + '-' + titlePDF + '.pdf',
                VersionData = bodyBlob, 
                Origin = 'H',
                FirstPublishLocationId = recordId // Vincular al registro
            );

            // Insertar ContentVersion
            Database.SaveResult saveResult = Database.insert(contentVersion1, false);

            if (saveResult.isSuccess()) {
                System.debug('Éxito: ContentVersion insertado con ID = ' + saveResult.getId());
            } else {
                System.debug('Fallo al insertar ContentVersion. Errores:');
                for (Database.Error err : saveResult.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Campos afectados: ' + err.getFields());
                }
                return; // Salir si la inserción falla para evitar consultar un ID nulo
            }
            
            // Consultar ContentVersion para obtener ContentDocumentId (si es necesario)
            ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId 
                                            FROM ContentVersion 
                                            WHERE Id = :contentVersion1.Id 
                                            WITH SYSTEM_MODE 
                                            LIMIT 1];
            
            // Crear ContentDocumentLink (si FirstPublishLocationId no se usa)
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.LinkedEntityId = recordId;
            contentLink.ContentDocumentId = contentVersion2.ContentDocumentId;
            contentLink.ShareType = 'V';
            Database.SaveResult linkResult = Database.insert(contentLink, false);

            if (linkResult.isSuccess()) {
                System.debug('Éxito: ContentDocumentLink creado para ContentDocumentId = ' + contentLink.ContentDocumentId);
            } else {
                System.debug('Fallo al crear ContentDocumentLink. Errores:');
                for (Database.Error err : linkResult.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Campos afectados: ' + err.getFields());
                }
            }
        } catch (Exception e) {
            System.debug('Excepción ocurrida: ' + e.getMessage() + ' en la línea: ' + e.getLineNumber());
            throw new AuraHandledException('Error al crear el archivo: ' + e.getMessage());
        }
    }
    
    


}