/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 08-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-10-2023   jesusjaime.pocosalvador@nttdata.com  Initial Version
**/
@isTest
private class CEN_PartnerControllerTest {

    // Se vuelve a usar @TestSetup para crear datos comunes, es más eficiente.
    // Los datos específicos para cada prueba se crearán en los métodos individuales.
    @TestSetup
    static void makeCommonData() {
        Account clientAccount = new Account(Name='Cliente Principal');
        insert clientAccount;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidad de Prueba', 
            AccountId = clientAccount.Id, 
            StageName = 'Cotización', 
            CloseDate = Date.today().addMonths(1)
        );
        insert opp;
    }

    /**
     * @description Prueba que el método devuelve solo el partner más reciente cuando hay duplicados.
     */
    @isTest
    static void testGetOpportunityPartners_ReturnsLatestUniquePartner() {
        // --- CONFIGURACIÓN DE DATOS ESPECÍFICA PARA ESTA PRUEBA ---
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account clientAccount = [SELECT Id FROM Account WHERE Name='Cliente Principal' LIMIT 1];

        Account partnerAccount = new Account(Name='Partner Duplicado', Phone='987654321');
        insert partnerAccount;
        
        // Creamos los dos partners duplicados para la misma cuenta
        Partner oldPartner = new Partner(OpportunityId = opp.Id, AccountToId = partnerAccount.Id, Role = 'Rol Antiguo');
        insert oldPartner;

        Partner newPartner = new Partner(OpportunityId = opp.Id, AccountToId = partnerAccount.Id, Role = 'Rol Nuevo y Correcto');
        insert newPartner;

        Case testCase = new Case(Subject = 'Caso de prueba', Status = 'New', AccountId = clientAccount.Id, Opportunity__c = opp.Id);
        insert testCase;

        // --- CORRECCIÓN DEL ERROR 1 ---
        // Test.setCreatedDate() DEBE ser llamado ANTES de Test.startTest().
        Test.setCreatedDate(oldPartner.Id, System.now().addDays(-1)); // Antiguo: ayer
        Test.setCreatedDate(newPartner.Id, System.now());            // Nuevo: hoy

        // --- EJECUCIÓN DE LA PRUEBA ---
        Test.startTest();
        CEN_PartnerController.PartnerResult result = CEN_PartnerController.getOpportunityPartners(testCase.Id);
        Test.stopTest();

        // --- ASEVERACIONES (VERIFICACIONES) ---
        System.assertNotEquals(null, result, 'El resultado no debe ser nulo.');
        System.assertEquals(1, result.partners.size(), 'La lista debería tener solo 1 registro después de de-duplicar.');
        System.assertEquals('Rol Nuevo y Correcto', result.partners[0].role, 'El rol devuelto no es el del partner más reciente.');
        System.assertEquals('Partner Duplicado', result.partners[0].accountName, 'El nombre del partner no es el esperado.');
    }

    /**
     * @description Prueba que la lista de partners devuelta está ordenada alfabéticamente,
     * cubriendo así el método 'compareTo'.
     */
    @isTest
    static void testPartnersAreSortedAlphabetically() {
        // --- CONFIGURACIÓN DE DATOS ESPECÍFICA PARA ESTA PRUEBA ---
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account clientAccount = [SELECT Id FROM Account WHERE Name='Cliente Principal' LIMIT 1];

        // --- CORRECCIÓN DEL ERROR 2 ---
        // Creamos partners con nombres válidos pero fuera de orden alfabético.
        // No se puede crear una cuenta con Name=null.
        Account partnerZ = new Account(Name='Zenith Partner');
        Account partnerA = new Account(Name='Apex Partner');
        Account partnerC = new Account(Name='Charlie Partner');
        insert new List<Account>{partnerZ, partnerA, partnerC};
        
        // Insertamos los partners en un orden no alfabético para probar el sort()
        insert new Partner(OpportunityId = opp.Id, AccountToId = partnerZ.Id, Role = 'Rol Z');
        insert new Partner(OpportunityId = opp.Id, AccountToId = partnerA.Id, Role = 'Rol A');
        insert new Partner(OpportunityId = opp.Id, AccountToId = partnerC.Id, Role = 'Rol C');

        Case testCase = new Case(Subject = 'Caso de prueba', Status = 'New', AccountId = clientAccount.Id, Opportunity__c = opp.Id);
        insert testCase;

        // --- EJECUCIÓN DE LA PRUEBA ---
        Test.startTest();
        CEN_PartnerController.PartnerResult result = CEN_PartnerController.getOpportunityPartners(testCase.Id);
        Test.stopTest();

        // --- ASEVERACIONES (VERIFICACIONES) ---
        System.assertNotEquals(null, result, 'El resultado no debe ser nulo.');
        System.assertEquals(3, result.partners.size(), 'La lista debería tener 3 partners únicos.');
        
        // Verificamos que el método .sort() que llama a compareTo funcionó correctamente.
        // La lista debe estar ahora en orden: Apex, Charlie, Zenith.
        System.assertEquals('Apex Partner', result.partners[0].accountName, 'El primer partner no es "Apex Partner", la lista no está ordenada.');
        System.assertEquals('Charlie Partner', result.partners[1].accountName, 'El segundo partner no es "Charlie Partner", la lista no está ordenada.');
        System.assertEquals('Zenith Partner', result.partners[2].accountName, 'El tercer partner no es "Zenith Partner", la lista no está ordenada.');
    }
}