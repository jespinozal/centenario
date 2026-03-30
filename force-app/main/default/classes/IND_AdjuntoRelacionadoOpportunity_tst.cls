@isTest
public class IND_AdjuntoRelacionadoOpportunity_tst {
    
    @TestSetup
    static void setupTestData() {
        // Crear una Oportunidad con RecordType válido
        RecordType industrialRecordType = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Opportunity' 
            AND DeveloperName = 'IND_rt_Oportunidad_Industrial'
            LIMIT 1
        ];
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Cotización',
            CloseDate = System.today().addDays(30),
            RecordTypeId = industrialRecordType.Id
        );
        insert testOpp;
        
        // Crear múltiples ContentDocuments reutilizables
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        ContentVersion cv1 = new ContentVersion(
            Title = 'Test Document 1',
            PathOnClient = 'test_document_1.txt',
            VersionData = Blob.valueOf('Test content 1')
        );
        contentVersions.add(cv1);
        
        ContentVersion cv2 = new ContentVersion(
            Title = 'Test Document 2',
            PathOnClient = 'test_document_2.txt',
            VersionData = Blob.valueOf('Test content 2')
        );
        contentVersions.add(cv2);
        
        ContentVersion cv3 = new ContentVersion(
            Title = 'Test Document 3',
            PathOnClient = 'test_document_3.txt',
            VersionData = Blob.valueOf('Test content 3')
        );
        contentVersions.add(cv3);
        
        insert contentVersions;
        
        // Crear ContentDocumentLinks reutilizables
        List<ContentDocument> contentDocs = [
            SELECT Id 
            FROM ContentDocument 
            ORDER BY Title
        ];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for (ContentDocument cd : contentDocs) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = testOpp.Id,
                ShareType = 'V'
            );
            cdlList.add(cdl);
        }
        
        insert cdlList;
    }
    
    @isTest
    static void testValidarYCrearAdjuntoRelacionado_WithValidData() {
        // Obtener datos de prueba
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<ContentDocumentLink> cdlList = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testOpp.Id
            LIMIT 1
        ];
        
        System.assert(!cdlList.isEmpty(), 'Debe existir un ContentDocumentLink');
        
        // Verificar que se creó el CEN_AdjuntoRelacionado__c
        List<CEN_AdjuntoRelacionado__c> createdAdjuntos = [
            SELECT Id, CEN_IdDocumento__c, CEN_OpportunityID__c, CEN_NombreArchivo__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_OpportunityID__c = :testOpp.Id
        ];
        
        System.assertEquals(3, createdAdjuntos.size(), 'Se deben crear 3 CEN_AdjuntoRelacionado__c');
        System.assertEquals(testOpp.Id, createdAdjuntos[0].CEN_OpportunityID__c);
    }
    
    @isTest
    static void testValidarYCrearAdjuntoRelacionado_NoOpportunityPrefix() {
        // Crear un Case (que no es una Oportunidad)
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;
        
        // Obtener un ContentDocument existente
        ContentDocument contentDoc = [
            SELECT Id 
            FROM ContentDocument 
            ORDER BY Title
            LIMIT 1
        ];
        
        // Crear un ContentDocumentLink que apunte al Case (no a Opportunity)
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id,
            LinkedEntityId = testCase.Id,
            ShareType = 'V'
        );
        
        Test.startTest();
        insert cdl;
        Test.stopTest();
        
        // Verificar que NO se creó un nuevo CEN_AdjuntoRelacionado__c para el Case
        List<CEN_AdjuntoRelacionado__c> adjuntosCase = [
            SELECT Id FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_OpportunityID__c = :testCase.Id
        ];
        
        System.assertEquals(0, adjuntosCase.size(), 'No se debe crear adjunto para un Case');
    }
    
    @isTest
    static void testGetAlreadyExistingDocuments() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testOpp.Id
        ];
        
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdlList) {
            documentIds.add(cdl.ContentDocumentId);
        }
        
        Test.startTest();
        Set<Id> existingDocs = IND_AdjuntoRelacionadoOpportunity_cls.getAlreadyExistingDocuments(
            new Set<Id>{testOpp.Id}
        );
        Test.stopTest();
        
        System.assertEquals(documentIds.size(), existingDocs.size(), 'Debe retornar los documentos existentes');
        for (Id docId : documentIds) {
            System.assert(existingDocs.contains(docId), 'Debe contener todos los IDs de documentos');
        }
    }
    
    @isTest
    static void testFilterDocumentsToCreate() {
        // Obtener DocumentIds reales del setup
        List<ContentDocument> contentDocs = [
            SELECT Id 
            FROM ContentDocument 
            ORDER BY Title
        ];
        
        Set<Id> allDocs = new Set<Id>();
        Set<Id> existingDocs = new Set<Id>();
        
        if (contentDocs.size() >= 3) {
            allDocs.add(contentDocs[0].Id);
            allDocs.add(contentDocs[1].Id);
            allDocs.add(contentDocs[2].Id);
            existingDocs.add(contentDocs[0].Id);
            existingDocs.add(contentDocs[1].Id);
        }
        
        Test.startTest();
        Set<Id> documentsToCreate = IND_AdjuntoRelacionadoOpportunity_cls.filterDocumentsToCreate(
            allDocs, 
            existingDocs
        );
        Test.stopTest();
        
        System.assertEquals(1, documentsToCreate.size(), 'Debe retornar solo un documento');
        System.assert(documentsToCreate.contains(contentDocs[2].Id), 'Debe contener el documento no existente');
    }
    
    @isTest
    static void testGetDocumentsById() {
        List<ContentDocument> contentDocs = [
            SELECT Id 
            FROM ContentDocument 
            ORDER BY Title
            LIMIT 2
        ];
        
        Test.startTest();
        Map<Id, ContentDocument> docs = IND_AdjuntoRelacionadoOpportunity_cls.getDocumentsById(
            new Set<Id>{contentDocs[0].Id, contentDocs[1].Id}
        );
        Test.stopTest();
        
        System.assertEquals(2, docs.size(), 'Debe retornar 2 documentos');
        System.assert(docs.containsKey(contentDocs[0].Id), 'Debe contener el primer documento');
        System.assert(docs.containsKey(contentDocs[1].Id), 'Debe contener el segundo documento');
    }
    
    @isTest
    static void testValidateRecordType_ValidType() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Boolean isValid = IND_AdjuntoRelacionadoOpportunity_cls.validateRecordType(
            new Set<Id>{testOpp.Id}
        );
        Test.stopTest();
        
        System.assert(isValid, 'Debe validar correctamente el RecordType');
    }
    
    @isTest
    static void testValidateRecordType_InvalidType() {
        // Crear una Oportunidad con un RecordType que no sea válido
        List<RecordType> allRecordTypes = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Opportunity'
            AND DeveloperName NOT IN ('IND_rt_Oportunidad_Industrial','Industrial','OFI_rt_Oportunidad_Oficina')
            LIMIT 1
        ];
        
        if (!allRecordTypes.isEmpty()) {
            Opportunity invalidOpp = new Opportunity(
                Name = 'Invalid Opp',
                StageName = 'Cotización',
                CloseDate = System.today().addDays(30),
                RecordTypeId = allRecordTypes[0].Id
            );
            insert invalidOpp;
            
            Test.startTest();
            Boolean isValid = IND_AdjuntoRelacionadoOpportunity_cls.validateRecordType(
                new Set<Id>{invalidOpp.Id}
            );
            Test.stopTest();
            
            System.assert(!isValid, 'No debe validar un RecordType inválido');
        }
    }
    
    @isTest
    static void testNewAdjuntoRelacionado() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentDocument cd = [
            SELECT Id, Title 
            FROM ContentDocument 
            ORDER BY Title
            LIMIT 1
        ];
        
        Map<Id, Id> opportunityByDoc = new Map<Id, Id>{cd.Id => testOpp.Id};
        Set<Id> documentsToCreate = new Set<Id>{cd.Id};
        Map<Id, ContentDocument> docs = new Map<Id, ContentDocument>{cd.Id => cd};
        
        Test.startTest();
        IND_AdjuntoRelacionadoOpportunity_cls.newAdjuntoRelacionado(
            opportunityByDoc,
            documentsToCreate,
            docs
        );
        Test.stopTest();
        
        List<CEN_AdjuntoRelacionado__c> createdAdjuntos = [
            SELECT Id, CEN_NombreArchivo__c, CEN_IdDocumento__c, CEN_OpportunityID__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_OpportunityID__c = :testOpp.Id
        ];
        
        System.assert(createdAdjuntos.size() > 0, 'Debe crear al menos un adjunto relacionado');
    }
    
    @isTest
    static void testValidarYCrearAdjuntoRelacionado_DuplicateDocument() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentDocument cd = [
            SELECT Id, Title 
            FROM ContentDocument 
            ORDER BY Title
            LIMIT 1
        ];
        
        // Obtener el ContentDocumentLink existente del setup
        List<ContentDocumentLink> cdlList = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :cd.Id
            AND LinkedEntityId = :testOpp.Id
        ];
        
        System.assert(!cdlList.isEmpty(), 'Debe existir un ContentDocumentLink del setup');
        
        // Verificar que no se creó un duplicado
        List<CEN_AdjuntoRelacionado__c> adjuntos = [
            SELECT Id FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_OpportunityID__c = :testOpp.Id
            AND CEN_IdDocumento__c = :cd.Id
        ];
        
        System.assertEquals(1, adjuntos.size(), 'No debe crear un adjunto duplicado');
    }
    
    @isTest
    static void testValidarYCrearAdjuntoRelacionado_MultipleDocuments() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Obtener todos los ContentDocumentLinks existentes del setup
        List<ContentDocumentLink> cdlList = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testOpp.Id
        ];
        
        // Verificar que se crearon adjuntos para cada ContentDocumentLink
        List<CEN_AdjuntoRelacionado__c> createdAdjuntos = [
            SELECT Id FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_OpportunityID__c = :testOpp.Id
        ];
        
        System.assertEquals(cdlList.size(), createdAdjuntos.size(), 'Debe crear un adjunto por cada ContentDocumentLink');
    }
    
    @isTest
    static void testContentDocumentLinkInsertionTrigger() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Obtener IDs de ContentDocuments ya vinculados
        List<ContentDocumentLink> linkedCdls = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testOpp.Id
        ];
        
        Set<Id> linkedDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : linkedCdls) {
            linkedDocIds.add(cdl.ContentDocumentId);
        }
        
        // Obtener un ContentDocument que NO esté vinculado
        List<ContentDocument> allDocs = [
            SELECT Id 
            FROM ContentDocument 
            ORDER BY Title
        ];
        
        ContentDocument unusedDoc = null;
        for (ContentDocument cd : allDocs) {
            if (!linkedDocIds.contains(cd.Id)) {
                unusedDoc = cd;
                break;
            }
        }
        
        if (unusedDoc != null) {
            // Crear un nuevo ContentDocumentLink
            ContentDocumentLink newCdl = new ContentDocumentLink(
                ContentDocumentId = unusedDoc.Id,
                LinkedEntityId = testOpp.Id,
                ShareType = 'V'
            );
            
            Test.startTest();
            insert newCdl;
            Test.stopTest();
            
            // Verificar que se creó el adjunto relacionado
            List<CEN_AdjuntoRelacionado__c> newAdjuntos = [
                SELECT Id, CEN_IdDocumento__c
                FROM CEN_AdjuntoRelacionado__c
                WHERE CEN_IdDocumento__c = :unusedDoc.Id
                AND CEN_OpportunityID__c = :testOpp.Id
            ];
            
            System.assertEquals(1, newAdjuntos.size(), 'Debe crear un adjunto para el nuevo ContentDocumentLink');
        }
    }
}