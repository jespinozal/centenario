@IsTest
private class ONI_cls_ContentVersion_SaveImg_tst {

    @IsTest
    static void testLinkImageToProductSuccess() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName='OFI_rt_Product2_Oficina'LIMIT 1];
        Product2 prod = new Product2(Name = 'Producto Test', IsActive = true, RecordTypeId = rt.Id);
        insert prod;

        ContentVersion cv = new ContentVersion(
            Title = 'Imagen Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Fake Image Data'),
            IsMajorVersion = true
        );
        insert cv;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        Test.startTest();
        ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(conDocId, prod.Id);
        Test.stopTest(); 

        Product2 updatedProd = [SELECT Imagen_URL__c FROM Product2 WHERE Id = :prod.Id];
        System.assertNotEquals(null, updatedProd.Imagen_URL__c, 'La URL no debe estar vacía');
        
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :conDocId AND LinkedEntityId = :prod.Id];
        System.assertEquals(1, links.size(), 'Debería existir un link');
    }

    @IsTest
    static void testLinkInvalidFileType() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName='OFI_rt_Product2_Oficina'LIMIT 1];
        Product2 prod = new Product2(Name = 'Producto Fail', IsActive = true, RecordTypeId = rt.Id);
        insert prod;

        // Insertamos un PDF (esto disparará el throw en tu clase)
        ContentVersion cv = new ContentVersion(
            Title = 'Archivo Invalido',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Fake PDF Data')
        );
        insert cv;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // 2. Ejecución
        Test.startTest();
        ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(conDocId, prod.Id);
        
        try {
            // El método @future se ejecuta AQUÍ. 
            // Como lanzará un error, el código saltará al catch.
            Test.stopTest(); 
        } catch (AuraHandledException e) {
            // 3. Validación del error
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Se esperaba una AuraHandledException');
        }
        
        // 4. Verificación final: El producto NO debe tener URL
        Product2 updatedProd = [SELECT Imagen_URL__c FROM Product2 WHERE Id = :prod.Id];
        System.assertEquals(null, updatedProd.Imagen_URL__c, 'La URL debe ser nula porque el formato era inválido');
    }
}