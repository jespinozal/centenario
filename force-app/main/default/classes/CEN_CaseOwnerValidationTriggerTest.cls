/**
 * Jesus Poco
 * jpocosal@emeal.nttdata.com
 */
@isTest
private class CEN_CaseOwnerValidationTriggerTest {
    @TestSetup
    static void makeData() {
        // Crear un usuario de prueba
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        // Consultar la cola existente
        Group testQueue = [SELECT Id FROM Group WHERE DeveloperName = 'CEN_Cola_de_Administradores_de_Casos' AND Type = 'Queue' LIMIT 1];
        
        // Asociar usuario a la cola
        List<GroupMember> existingMembers = [SELECT Id FROM GroupMember WHERE GroupId = :testQueue.Id AND UserOrGroupId = :testUser.Id];
        if (existingMembers.isEmpty()) {
            GroupMember gm = new GroupMember(GroupId = testQueue.Id, UserOrGroupId = testUser.Id);
            insert gm;
        }
    }

    @isTest
    static void testValidOwnerChange() {
        // Obtener el usuario de prueba creado en @TestSetup
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        
        // Consultar la cola existente
        Group testQueue = [SELECT Id FROM Group WHERE DeveloperName = 'CEN_Cola_de_Administradores_de_Casos' AND Type = 'Queue' LIMIT 1];
        
        // Crear Record Type
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'CEN_InteraccionContrato' LIMIT 1];
        
        // Crear caso
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Registrado',
            OwnerId = testQueue.Id,
            RecordTypeId = rt.Id
        );
        insert testCase;
        
        // Cambiar propietario como usuario miembro
        System.runAs(testUser) {
            testCase.OwnerId = testUser.Id;
            Test.startTest();
            update testCase; // Debería pasar
            Test.stopTest();
        }
        
        // Verificar que el propietario cambió
        Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(testUser.Id, updatedCase.OwnerId, 'El propietario debería haber cambiado correctamente.');
    }
    
    @isTest
    static void testInvalidOwnerChange() {
        // Obtener el usuario de prueba creado en @TestSetup
        User nonMemberUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        
        // Consultar la cola existente
        Group testQueue = [SELECT Id FROM Group WHERE DeveloperName = 'CEN_Cola_de_Administradores_de_Casos' AND Type = 'Queue' LIMIT 1];
        
        // Crear Record Type
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'CEN_InteraccionContrato' LIMIT 1];
        
        // Crear caso
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Registrado',
            OwnerId = testQueue.Id,
            RecordTypeId = rt.Id
        );
        insert testCase;
        
        // Intentar cambiar propietario como usuario no miembro
        System.runAs(nonMemberUser) {
            testCase.OwnerId = nonMemberUser.Id;
            Test.startTest();
            try {
                update testCase;
                System.assert(true, 'Debería haber fallado por no ser miembro de la cola.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('No eres miembro'), 'Debería mostrar error de membresía.');
            }
            Test.stopTest();
        }
    }
}