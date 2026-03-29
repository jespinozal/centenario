/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
@isTest
private class CEN_EnlazarFileACase_tst {
    
    @testSetup
    static void setup() {
        Case casoPrueba = new Case(
            Subject = 'Test Case',
            Status  = 'New'
        );
        insert casoPrueba;
        
        ContentVersion cv = new ContentVersion(
            Title        = 'Test Document',
            PathOnClient = 'test.pdf',
            VersionData  = Blob.valueOf('Test content')
        );
        insert cv;
    }

    @isTest
    static void testIgnoraSiTipoOrigenNulo() {
        Case caso = [SELECT Id FROM Case LIMIT 1];
        ContentVersion cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Document'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        Test.startTest();
        insert new CEN_AdjuntoRelacionado__c(
            Name               = 'Sin TipoOrigen',
            CEN_CaseID__c      = caso.Id,
            CEN_IdDocumento__c = String.valueOf(cv.ContentDocumentId)
        );
        Test.stopTest();
        
        Integer total = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caso.Id
        ];
        System.assertEquals(0, total, 'No debe crear link si TipoOrigen es nulo.');
    }

    @isTest
    static void testEnlazarFileACase_File() {
        Case caso = [SELECT Id FROM Case LIMIT 1];
        ContentVersion cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Document'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        Test.startTest();
        insert new CEN_AdjuntoRelacionado__c(
            Name                   = 'Con TipoOrigen File',
            CEN_CaseID__c          = caso.Id,
            CEN_IdDocumento__c     = String.valueOf(cv.ContentDocumentId),
            CEN_TipoOrigen__c      = 'File',
            CEN_TipoDocumentoCaso__c = 'Autorizaciones'
        );
        Test.stopTest();
        
        ContentDocumentLink link = [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId   = :caso.Id
              AND ContentDocumentId = :cv.ContentDocumentId
            LIMIT 1
        ];
        
        System.assertEquals(caso.Id, link.LinkedEntityId,       'LinkedEntityId debe ser el Case');
        System.assertEquals(cv.ContentDocumentId, link.ContentDocumentId, 'ContentDocumentId debe coincidir');
        System.assertEquals('V', link.ShareType,                 'ShareType debe ser V');
        System.assertEquals('AllUsers', link.Visibility,         'Visibility debe ser AllUsers');
    }
    
    @isTest
    static void testNoCreaLinkConCamposNulos() {
        Case caso = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        insert new CEN_AdjuntoRelacionado__c(
            Name                   = 'Campos Nulos',
            CEN_CaseID__c          = caso.Id,
            CEN_IdDocumento__c     = null,
            CEN_TipoDocumentoCaso__c = null,
            CEN_TipoOrigen__c      = 'File'
        );
        Test.stopTest();
        
        Integer total = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caso.Id
        ];
        System.assertEquals(0, total, 'No debe crear link si faltan campos requeridos.');
    }
    @isTest
    static void testConvierteAttachmentACreaFileYLink() {
        Case caso = [SELECT Id FROM Case LIMIT 1];
    
        Attachment att = new Attachment(
            Name        = 'att-convert-prueba.txt',
            Body        = Blob.valueOf('contenido de prueba'),
            ContentType = 'text/plain',
            ParentId    = caso.Id
        );
        insert att;
    
        Test.startTest();
        insert new CEN_AdjuntoRelacionado__c(
            Name                 = 'AR para convertir attachment',
            CEN_CaseID__c        = caso.Id,
            CEN_IdDocumento__c   = att.Id,              // <- dispara la rama 'Attachment'
            CEN_TipoOrigen__c    = 'Attachment',
            CEN_NombreArchivo__c = 'att-convert-prueba.txt'
        );
        Test.stopTest();
    
        ContentVersion cvCreado = [
            SELECT Id, ContentDocumentId, Title, PathOnClient
            FROM ContentVersion
            WHERE Title = 'att-convert-prueba.txt'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertNotEquals(null, cvCreado.ContentDocumentId, 'Debe haberse creado un ContentDocument.');
    
        ContentDocumentLink link = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId   = :caso.Id
              AND ContentDocumentId = :cvCreado.ContentDocumentId
            LIMIT 1
        ];
        System.assertEquals(caso.Id, link.LinkedEntityId, 'El File convertido debe quedar vinculado al Case.');
    }
}