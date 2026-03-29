@IsTest
public class CEN_RomperEnlaceDocumentoPorMigrado_tst {

    // Método Helper para crear un usuario administrador y evitar fallos por Validation Rules
    private static User createAdminUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(
            Alias = 'admtest', 
            Email='adminuser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='adminuser' + DateTime.now().getTime() + '@testorg.com'
        );
        return u;
    }

    @IsTest
    static void testEliminacionParcial() {
        User admin = createAdminUser();
        
        // El setup inicial puede ser con el usuario actual
        Account acc = new Account(Name = 'Cuenta prueba');
        insert acc;

        Case c = new Case(Origin = 'Phone', Status = 'New', Subject = 'Caso prueba');
        insert c;

        ContentVersion cv = new ContentVersion(
            Title = 'Doc Parcial',
            PathOnClient = 'doc.txt',
            VersionData = Blob.valueOf('contenido parcial')
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id docId = cv.ContentDocumentId;

        ContentDocumentLink linkCase = new ContentDocumentLink(
            ContentDocumentId = docId, LinkedEntityId = c.Id, ShareType = 'V', Visibility = 'AllUsers'
        );
        ContentDocumentLink linkAccount = new ContentDocumentLink(
            ContentDocumentId = docId, LinkedEntityId = acc.Id, ShareType = 'V', Visibility = 'AllUsers'
        );
        insert new List<ContentDocumentLink>{ linkCase, linkAccount };

        CEN_AdjuntoRelacionado__c ar = new CEN_AdjuntoRelacionado__c(
            Name = 'AR Parcial',
            CEN_CaseID__c = c.Id,
            CEN_IdDocumento__c = String.valueOf(docId),
            CEN_Migrado__c = false
        );
        insert ar;

        // Ejecución como Administrador para saltar la Regla de Validación
        Test.startTest();
        System.runAs(admin) {
            ar.CEN_Migrado__c = true;
            update ar;
        }
        Test.stopTest();

        // Validaciones (Se mantienen igual)
        Integer linksCaseCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :docId AND LinkedEntityId = :c.Id];
        Integer linksAccountCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :docId AND LinkedEntityId = :acc.Id];
        Integer docCount = [SELECT COUNT() FROM ContentDocument WHERE Id = :docId];

        System.assertEquals(0, linksCaseCount, 'El link hacia el Case debe eliminarse');
        System.assertEquals(1, linksAccountCount, 'El link hacia Account debe mantenerse');
        System.assertEquals(1, docCount, 'El documento debe existir todavía');
    }

    @IsTest
    static void testEliminacionTotal() {
        User admin = createAdminUser();
        Case c = new Case(Origin = 'Phone', Status = 'New', Subject = 'Caso total');
        insert c;

        ContentVersion cv = new ContentVersion(Title = 'Doc Total', PathOnClient = 'doc.txt', VersionData = Blob.valueOf('contenido total'));
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id docId = cv.ContentDocumentId;

        insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = c.Id, ShareType = 'V', Visibility = 'AllUsers');

        CEN_AdjuntoRelacionado__c ar = new CEN_AdjuntoRelacionado__c(
            Name = 'AR Total', CEN_CaseID__c = c.Id, CEN_IdDocumento__c = String.valueOf(docId), CEN_Migrado__c = false
        );
        insert ar;

        Test.startTest();
        System.runAs(admin) {
            ar.CEN_Migrado__c = true;
            update ar;
        }
        Test.stopTest();

        Integer linksCaseCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :docId AND LinkedEntityId = :c.Id];
        Integer docCount = [SELECT COUNT() FROM ContentDocument WHERE Id = :docId];

        System.assertEquals(0, linksCaseCount);
        System.assertEquals(0, docCount);
    }

    @IsTest
    static void testIgnorarSoloUser() {
        User admin = createAdminUser();
        // Usamos un usuario activo del sistema para el link
        User someUser = [SELECT Id FROM User WHERE IsActive = true AND Id != :admin.Id LIMIT 1];

        Case c = new Case(Origin = 'Phone', Status = 'New', Subject = 'Caso User');
        insert c;

        ContentVersion cv = new ContentVersion(Title = 'Doc User', PathOnClient = 'doc.txt', VersionData = Blob.valueOf('contenido user'));
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id docId = cv.ContentDocumentId;

        insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = someUser.Id, ShareType = 'V', Visibility = 'AllUsers');

        CEN_AdjuntoRelacionado__c ar = new CEN_AdjuntoRelacionado__c(
            Name = 'AR User', CEN_CaseID__c = c.Id, CEN_IdDocumento__c = String.valueOf(docId), CEN_Migrado__c = false
        );
        insert ar;

        Test.startTest();
        System.runAs(admin) {
            ar.CEN_Migrado__c = true;
            update ar;
        }
        Test.stopTest();

        Integer linksUserCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :docId AND LinkedEntityId = :someUser.Id];
        System.assertEquals(1, linksUserCount);
    }
}