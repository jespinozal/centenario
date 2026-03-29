@isTest
public class ONI_cls_ContentVersion_SaveImgToProd_tst {

    @TestSetup
    static void setup() {
        Pricebook2 customPb = new Pricebook2(Name = 'Urbano',IsActive = true);
        insert customPb;
        
        Id pricebookId = Test.getStandardPricebookId(); 
        Pricebook2 standardPricebook =  new Pricebook2(Id = pricebookId,IsActive = true); 
        update standardPricebook;
        
        Proyecto__c proyecto = new Proyecto__c(Name='Proyecto Test', CEN_CODIGOSAP__c='CODTEST', CEN_MaximumTermForSigningTheContract__c = 5, CEN_Sociedad__c = '0019');
        insert proyecto;
        // Crear producto
        Product2 prod = new Product2(
            Name = 'Producto Test',
            ProductCode = 'TEST001',
            IDPROYECTO__c='CODTEST',
            MANZANA__c='F11', 
            CODESTADOLOTE__c='C',
            DESCRIPCIONCORTA__c='SM1F11014',
            CEN_USOINMUEBLE__c='CV', 
            AREA__c='126', 
            CODMONEDAFUNCIONAL__c='Soles', 
            CEN_TIPOINMUEBLE__c='LO', 
            CEN_TIPOLOTE__c='V', 
            CEN_MEDIDAFRENTE__c='8.4', 
            CEN_MEDIDAFONDO__c='8.4', 
            CEN_MEDIDAIZQUIERDA__c='15', 
            CEN_MEDIDADERECHA__c='15', 
            LINDERODERECHA__c='LOTE 13', 
            CEN_LINDEROIZQUIERDA__c='CALLE 22', 
            CEN_LINDEROFRENTE__c='CALLE 5', 
            CEN_LINDEROFONDO__c='PROP. TERCEROS', 
            CEN_Tipo_de_proyecto__c='Urbano',
            CEN_IdLotSAP__c='00000001',
            CEN_PRECIOVENTAFUN__c='61878',
            DESCRIPCIONLOTE__c='SANTA MARÍA ETAPA 1 Mz.F11 Lt.14',
            CODLOTE__c='940108361',
            IsActive = true
        );
        insert prod;

        // Crear ContentVersion (simula subida de imagen)
        ContentVersion cv = new ContentVersion(
            Title = 'test_image',
            PathOnClient = 'test_image.png',
            VersionData = Blob.valueOf('fake image data'),
            IsMajorVersion = true
        );
        insert cv;
        
        // Crear ContentVersion (simula subida de imagen)
        ContentVersion cv1 = new ContentVersion(
            Title = 'test_image2',
            PathOnClient = 'test_image2.jpg',
            VersionData = Blob.valueOf('fake image2 data'),
            IsMajorVersion = true
        );
        insert cv1;
    }

    @isTest
    static void testLinkImageToProduct_Success() {
        // Obtener datos de prueba
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'test_image' LIMIT 1];

        Test.startTest();
        // Llamar al método
        ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(cv.ContentDocumentId, prod.Id);
        List<Product2> misProductos = ONI_cls_Product2_GetProducts.ONI_cls_Product2_GetProducts();
        Test.stopTest();

        // Verificar ContentDocumentLink
        List<ContentDocumentLink> links = [
            SELECT Id, ShareType, Visibility 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :cv.ContentDocumentId 
              AND LinkedEntityId = :prod.Id
        ];
        System.assertEquals(1, links.size(), 'Debe existir un enlace');
        System.assertEquals('V', links[0].ShareType);
        System.assertEquals('AllUsers', links[0].Visibility);

        // Verificar URL en el producto
        Product2 updatedProd = [SELECT Imagen_URL__c FROM Product2 WHERE Id = :prod.Id];
        System.assertNotEquals(null, updatedProd.Imagen_URL__c, 'La URL debe guardarse');
        System.assert(updatedProd.Imagen_URL__c.contains(cv.Id), 'La URL debe contener el ID de la versión');
    }

    @isTest
    static void testLinkImageToProduct_DuplicateLink() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'test_image' LIMIT 1];

        // Insertar enlace manualmente
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = prod.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(cv.ContentDocumentId, prod.Id);
        Test.stopTest();

        // Debe haber solo 1 enlace (no duplicado)
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink 
            WHERE ContentDocumentId = :cv.ContentDocumentId 
              AND LinkedEntityId = :prod.Id
        ];
        System.assertEquals(1, links.size(), 'No debe duplicar el enlace');
    }
/*
    @isTest
    static void testLinkImageToProduct_InvalidFileType() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];

        // Crear archivo no imagen
        ContentVersion cv = new ContentVersion(
            Title = 'document',
            PathOnClient = 'document.pdf',
            VersionData = Blob.valueOf('fake pdf'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion insertedCv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        Test.startTest();
        try {
            ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(insertedCv.ContentDocumentId, prod.Id);
            //System.assert(false, 'Debe lanzar excepción por tipo inválido');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Solo se permiten imágenes'), 'Mensaje de error incorrecto');
        }
        Test.stopTest();
    }

    @isTest
    static void testLinkImageToProduct_NoContentDocument() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Id fakeId = '069000000000000AAA'; // ID inválido
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct(fakeId, prod.Id);
            //System.assert(false, 'Debió lanzar AuraHandledException');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('Error al vincular imagen'),
                'Debe devolver mensaje controlado'
            );
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'La excepción debió lanzarse');
    }
*/
}