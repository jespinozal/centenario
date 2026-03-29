/*
 ====================================================================================================
 | Creado por: Jose Miguel Espinoza Mestanza
 | Email: josemiguel.espinozamestanza@emeal.nttdata.com
 | Versión: 2.0
 | Fecha de Modificación: 12 de septiembre de 2025
 |
 | Descripción:
 | Trigger que se ejecuta después de insertar un registro en 'CEN_AdjuntoRelacionado__c'.
 | Su propósito es doble:
 | 1. Para registros de tipo 'File', asegura que el archivo (ContentDocument) esté vinculado
 |    al Caso correspondiente. Esta lógica AHORA VERIFICA SI EL VÍNCULO YA EXISTE para
 |    evitar errores de duplicados cuando se usan componentes como lightning-file-upload.
 | 2. Para registros de tipo 'Attachment', convierte el adjunto clásico a un nuevo registro de
 |    'File' (ContentVersion) y lo vincula automáticamente al Caso.
 ====================================================================================================
*/
trigger CEN_EnlazarFileACase on CEN_AdjuntoRelacionado__c (after insert) {

    // --- SECCIÓN 1: MANEJO DE REGISTROS DE TIPO 'FILE' ---

    // Mapas y listas para manejar eficientemente los registros de tipo 'File'.
    Map<Id, Id> mapaDocumentoACaso = new Map<Id, Id>();
    List<ContentDocumentLink> linksParaCrear = new List<ContentDocumentLink>();

    // Primero, recolectamos los IDs de los registros relevantes del trigger.
    for (CEN_AdjuntoRelacionado__c ar : Trigger.new) {
        if (ar.CEN_TipoOrigen__c == 'File' && ar.CEN_IdDocumento__c != null && ar.CEN_CaseID__c != null) {
            mapaDocumentoACaso.put(ar.CEN_IdDocumento__c, ar.CEN_CaseID__c);
        }
    }

    // Solo ejecutamos la lógica si encontramos registros de tipo 'File' para procesar.
    if (!mapaDocumentoACaso.isEmpty()) {
        
        // Consultamos la base de datos para encontrar todos los vínculos que YA EXISTEN
        // para los pares de Archivo-Caso que estamos procesando.
        Set<String> clavesDeVinculosExistentes = new Set<String>();
        for (ContentDocumentLink linkExistente : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :mapaDocumentoACaso.keySet() 
              AND LinkedEntityId IN :mapaDocumentoACaso.values()
        ]) {
            // Creamos una clave única (ej: "069...-500...") para identificar fácilmente los vínculos existentes.
            String clave = linkExistente.ContentDocumentId + '-' + linkExistente.LinkedEntityId;
            clavesDeVinculosExistentes.add(clave);
        }

        // Volvemos a recorrer los registros del trigger para decidir cuáles necesitan un nuevo vínculo.
        for (CEN_AdjuntoRelacionado__c ar : Trigger.new) {
            if (ar.CEN_TipoOrigen__c == 'File' && ar.CEN_IdDocumento__c != null && ar.CEN_CaseID__c != null) {
                
                String claveActual = ar.CEN_IdDocumento__c + '-' + ar.CEN_CaseID__c;
                
                // ¡LA LÓGICA CLAVE! Si la clave de este registro NO está en nuestro conjunto de
                // vínculos existentes, significa que debemos crearlo.
                if (!clavesDeVinculosExistentes.contains(claveActual)) {
                    linksParaCrear.add(new ContentDocumentLink(
                        ContentDocumentId = ar.CEN_IdDocumento__c,
                        LinkedEntityId    = ar.CEN_CaseID__c,
                        ShareType         = 'V', // 'V' = Viewer. El usuario puede ver el archivo.
                        Visibility        = 'AllUsers' // Visible para todos los usuarios con acceso al registro.
                    ));
                }
            }
        }

        // Finalmente, insertamos en la base de datos ÚNICAMENTE la lista de vínculos que no existían.
        // Si la lista está vacía, esta operación no hace nada y no gasta límites.
        if (!linksParaCrear.isEmpty()) {
            insert linksParaCrear;
        }
    }

    // --- SECCIÓN 2: MANEJO DE REGISTROS DE TIPO 'ATTACHMENT' (LÓGICA ORIGINAL) ---

    // Esta parte del código se mantiene para seguir dando soporte a la conversión de Attachments clásicos.
    List<CEN_AdjuntoRelacionado__c> adjuntosParaConvertir = new List<CEN_AdjuntoRelacionado__c>();
    for (CEN_AdjuntoRelacionado__c ar : Trigger.new) {
        if (ar.CEN_TipoOrigen__c == 'Attachment' && ar.CEN_IdDocumento__c != null && ar.CEN_CaseID__c != null) {
            adjuntosParaConvertir.add(ar);
        }
    }

    if (!adjuntosParaConvertir.isEmpty()) {
        Set<Id> attachmentIds = new Set<Id>();
        for (CEN_AdjuntoRelacionado__c ar : adjuntosParaConvertir) {
            attachmentIds.add(ar.CEN_IdDocumento__c);
        }

        List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachmentIds];
        
        List<ContentVersion> versionesParaCrear = new List<ContentVersion>();
        for (Attachment att : attachments) {
            for (CEN_AdjuntoRelacionado__c ar : adjuntosParaConvertir) {
                if (ar.CEN_IdDocumento__c == att.Id) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = ar.CEN_NombreArchivo__c != null ? ar.CEN_NombreArchivo__c : att.Name;
                    cv.PathOnClient = ar.CEN_NombreArchivo__c != null ? ar.CEN_NombreArchivo__c : att.Name;
                    cv.VersionData = att.Body;
                    // Al poblar 'FirstPublishLocationId', Salesforce crea el File (ContentDocument)
                    // y lo enlaza al Caso (ContentDocumentLink) automáticamente en una sola operación.
                    cv.FirstPublishLocationId = ar.CEN_CaseID__c;
                    versionesParaCrear.add(cv);
                    break; 
                }
            }
        }

        if (!versionesParaCrear.isEmpty()) {
            insert versionesParaCrear;
        }
    }
}