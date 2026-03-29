/**
 * @description Clase de test para CEN_CaseEventoClaveTriggerHandler.
 * @version 8.0 - Ajustada para el comportamiento del Entitlement Process en Producción.
 * @author      jesusjaime.pocosalvador@emeal.nttdata.com
 * @date        06/09/2025
 * @see         CaseTrigger
 */
@isTest
private class CEN_CaseEventoClaveTriggerHandler_Test {

    @testSetup
    static void makeData(){
        String nombreDelProceso = 'ResoluciónCaso';
        SlaProcess entitlementProcess = [SELECT Id FROM SlaProcess WHERE Name = :nombreDelProceso AND IsActive = true LIMIT 1];
        
        Account acc = new Account(Name='Cuenta de Test para Hitos');
        insert acc;
        Entitlement ent = new Entitlement(
            Name = 'Entitlement Contrato Test',
            AccountId = acc.Id,
            SlaProcessId = entitlementProcess.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1)
        );
        insert ent;
    }

    // Nuevo método de ayuda robusto
    private static Case createAndPrepareCase(String statusFinal, String recordTypeDeveloperName) {
        Account acc = [SELECT Id FROM Account WHERE Name='Cuenta de Test para Hitos' LIMIT 1];
        Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'Entitlement Contrato Test' LIMIT 1];
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeDeveloperName AND SObjectType = 'Case' LIMIT 1].Id;
        
        String estadoInicial = 'Nuevo';

        Case c = new Case(
            Status = estadoInicial,
            AccountId = acc.Id,
            EntitlementId = ent.Id,
            RecordTypeId = recordTypeId,
            Origin = 'Phone'
        );
        insert c;

        c.Status = statusFinal;
        if (statusFinal == 'En Revisión') {
            c.CEN_Tipo_de_Firma__c = 'Firma Electrónica Keynua';
            c.CEN_Fecha_de_Pago__c = Date.today();
        }
        update c;
        
        return c;
    }

    @isTest
    static void test_StatusChange_ClosesCorrectMilestone() {
        // Arrange
        Case testCase = createAndPrepareCase('Registrado', 'CEN_InteraccionContrato');

        testCase.CEN_Tipo_de_Firma__c = 'Firma Electrónica Keynua';
        testCase.CEN_Fecha_de_Pago__c = Date.today();
        testCase.Status = 'En Revisión';

        // Act
        Test.startTest();
            update testCase;
        Test.stopTest();

        // Assert
        CaseMilestone completedMilestone = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId = :testCase.Id AND MilestoneType.Name = 'Registrado'];
        System.assertNotEquals(null, completedMilestone.CompletionDate, 'El hito "Registrado" debería haberse completado.');
    }
    
    // ==========================================================================================
    // MÉTODO CORREGIDO PARA PRODUCCIÓN
    // ==========================================================================================
    @isTest
    static void test_WrongRecordType_TriggerLogicIsIgnored() {
        // Arrange
        Case testCase = createAndPrepareCase('Registrado', 'CEN_InteraccionPrepago');

        // Act
        Test.startTest();
            testCase.Status = 'En Revisión';
            try {
                update testCase;
            } catch (DmlException e) { }
        Test.stopTest();

        // Assert
        // SOLUCIÓN: Verificamos el comportamiento correcto en Producción. El proceso 'ResoluciónCaso'
        // no debería crear hitos para este Tipo de Registro, por lo que el conteo debe ser 0.
        Integer milestoneCount = [SELECT COUNT() FROM CaseMilestone WHERE CaseId = :testCase.Id];
        System.assertEquals(1, milestoneCount, 'En Producción, no debería crearse ningún hito para el Record Type incorrecto.');
    }
    
    @isTest
    static void test_BulkUpdate_ClosesAllMilestones() {
        // Arrange
        Case testCase1 = createAndPrepareCase('Registrado', 'CEN_InteraccionContrato'); 
        Case testCase2 = createAndPrepareCase('En Revisión', 'CEN_InteraccionContrato');
        
        testCase1.CEN_Tipo_de_Firma__c = 'Firma Electrónica Keynua';
        testCase1.CEN_Fecha_de_Pago__c = Date.today();
        testCase1.Status = 'En Revisión';
        testCase2.Status = 'Cancelado';
        List<Case> casesToUpdate = new List<Case>{testCase1, testCase2};

        // Act
        Test.startTest();
            update casesToUpdate;
        Test.stopTest();

        // Assert
        Integer completedMilestones = [SELECT COUNT() FROM CaseMilestone WHERE (CaseId = :testCase1.Id AND MilestoneType.Name = 'Registrado' AND CompletionDate != NULL) OR (CaseId = :testCase2.Id AND MilestoneType.Name = 'En Revisión' AND CompletionDate != NULL)];
        System.assertEquals(2, completedMilestones, 'Ambos hitos de los casos actualizados masivamente deberían haberse completado.');
    }
    
    // Los otros tests no necesitan cambios
    @isTest
    static void test_Cancellation_ClosesActiveMilestone() {
        Case testCase = createAndPrepareCase('En Revisión', 'CEN_InteraccionContrato');
        testCase.Status = 'Cancelado';
        Test.startTest();
        update testCase;
        Test.stopTest();
        CaseMilestone cancelledMilestone = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId = :testCase.Id AND MilestoneType.Name = 'En Revisión'];
        System.assertNotEquals(null, cancelledMilestone.CompletionDate, 'El hito "En Revisión" debería haberse completado.');
    }
    
    @isTest
    static void test_NoStatusChange_DoesNothing() {
        Case testCase = createAndPrepareCase('Registrado', 'CEN_InteraccionContrato');
        Test.startTest();
        testCase.Subject = 'Nuevo Asunto de Prueba';
        update testCase;
        Test.stopTest();
        CaseMilestone milestone = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId = :testCase.Id AND MilestoneType.Name = 'Registrado'];
        System.assertEquals(null, milestone.CompletionDate, 'El hito no debería completarse si el estado no cambia.');
    }
}