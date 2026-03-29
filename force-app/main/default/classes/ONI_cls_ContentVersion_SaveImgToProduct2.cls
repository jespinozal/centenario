public with sharing class ONI_cls_ContentVersion_SaveImgToProduct2 {

    @AuraEnabled(cacheable=true)
    public static void linkImageToProduct(String contentDocumentId, String productId) {
        linkImageToProductFuture(contentDocumentId, productId);
    }

    @future
    public static void linkImageToProductFuture(String contentDocumentId, String productId) {
        try {
            // 1. Validar ContentDocument
            ContentDocument cd = [
                SELECT Id, FileType 
                FROM ContentDocument 
                WHERE Id = :contentDocumentId 
                LIMIT 1
            ];

            String fileType = cd.FileType;
            if (!fileType.equalsIgnoreCase('PNG') && !fileType.equalsIgnoreCase('JPG') && !fileType.equalsIgnoreCase('JPEG') && !fileType.equalsIgnoreCase('GIF')) {
                throw new AuraHandledException('Solo se permiten imágenes (PNG, JPG, JPEG, GIF).');
            }

            // 2. Evitar duplicados
            List<ContentDocumentLink> existingLinks = [
                SELECT Id 
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :contentDocumentId 
                  AND LinkedEntityId = :productId
                LIMIT 1
            ];

            if (existingLinks.isEmpty()) {
                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = contentDocumentId,
                    LinkedEntityId = productId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                );
                insert cdl;
            }

            // 3. Obtener la versión más reciente
            ContentVersion cv = [
                SELECT Id 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId 
                  AND IsLatest = true 
                LIMIT 1
            ];

            // 4. CORREGIDO: Usar getOrgDomainUrl() en lugar de getSalesforceBaseUrl()
            String orgDomain = URL.getOrgDomainUrl().toExternalForm(); // https://tuorg.my.salesforce.com
            String imageUrl = orgDomain + '/sfc/servlet.shepherd/version/download/' + cv.Id;

            // 5. Guardar URL en el producto
            Product2 prod = new Product2(Id = productId, Imagen_URL__c = imageUrl);
            update prod;

        } catch (Exception e) {
            throw new AuraHandledException('Error al vincular imagen: ' + e.getMessage());
        }
    }
}