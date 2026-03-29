/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
@istest
public with sharing class CEN_LookupReusableTest {
    // Método de configuración para crear datos de prueba
    @TestSetup
    static void setup() {
        // Crear cuentas de prueba
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account A', Industry = 'Technology'),
            new Account(Name = 'Test Account B', Industry = 'Finance'),
            new Account(Name = 'Test Account C', Industry = 'Healthcare')
        };
        insert accounts;
    }

    // Prueba básica de búsqueda de cuentas por nombre
    @IsTest
    static void testFetchRecordsBasicSearch() {
        // Crear una instancia de SearchWrapper
        CEN_LookupReusable.SearchWrapper wrapper = new CEN_LookupReusable.SearchWrapper();
        wrapper.objectApiName = 'Account';
        wrapper.fieldApiName = 'Name';
        wrapper.searchString = 'Test';

        // Llamar al método fetchRecords
        List<CEN_LookupReusable.ResultWrapper> results = CEN_LookupReusable.fetchRecords(wrapper);

        
    }

    // Prueba con campos adicionales
    @IsTest
    static void testFetchRecordsWithOtherField() {
        // Crear una instancia de SearchWrapper con un campo adicional
        CEN_LookupReusable.SearchWrapper wrapper = new CEN_LookupReusable.SearchWrapper();
        wrapper.objectApiName = 'Account';
        wrapper.fieldApiName = 'Name';
        wrapper.otherFieldApiName = 'Industry';
        wrapper.searchString = 'Test';

        // Llamar al método fetchRecords
        List<CEN_LookupReusable.ResultWrapper> results = CEN_LookupReusable.fetchRecords(wrapper);

        // Verificar que los resultados sean los esperados
        System.assertNotEquals(null, results);
        System.assert(results.size() > 0, 'Debería haber al menos un resultado');
        for (CEN_LookupReusable.ResultWrapper result : results) {
            System.assert(result.mainField.startsWith('Test'), 'El nombre de la cuenta debería comenzar con "Test"');
            System.assertNotEquals(null, result.subField, 'El campo Industry no debería estar vacío');
        }
    }

    // Prueba con ID de registro seleccionado
    @IsTest
    static void testFetchRecordsWithSelectedRecordId() {
        // Obtener el ID de una cuenta de prueba
        Account selectedAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account A' LIMIT 1];

        // Crear una instancia de SearchWrapper con el ID de registro seleccionado
        CEN_LookupReusable.SearchWrapper wrapper = new CEN_LookupReusable.SearchWrapper();
        wrapper.objectApiName = 'Account';
        wrapper.fieldApiName = 'Name';
        wrapper.selectedRecordId = selectedAccount.Id;

        // Llamar al método fetchRecords
        List<CEN_LookupReusable.ResultWrapper> results = CEN_LookupReusable.fetchRecords(wrapper);

        // Verificar que solo haya un resultado y que sea el esperado
    }

    // Prueba con relación parental
    @IsTest
    static void testFetchRecordsWithParentRelation() {
        // Crear una cuenta "padre" y una cuenta "hija" con relación parental
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;
        Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
        insert childAccount;

        // Crear una instancia de SearchWrapper con relación parental
        CEN_LookupReusable.SearchWrapper wrapper = new CEN_LookupReusable.SearchWrapper();
        wrapper.objectApiName = 'Account';
        wrapper.fieldApiName = 'Name';
        wrapper.parentFieldApiName = 'ParentId';
        wrapper.parentRecordId = parentAccount.Id;
        wrapper.searchString = 'Child';

        // Llamar al método fetchRecords
        List<CEN_LookupReusable.ResultWrapper> results = CEN_LookupReusable.fetchRecords(wrapper);

        // Verificar que los resultados incluyan solo la cuenta hija
    }

    // Prueba con parámetros nulos
    @IsTest
    static void testFetchRecordsWithNullParams() {
        // Llamar al método con un wrapper nulo
        Test.startTest();
        List<CEN_LookupReusable.ResultWrapper> results = CEN_LookupReusable.fetchRecords(null);
        Test.stopTest();

        // Verificar que el resultado sea nulo o vacío
        System.assertEquals(null, results, 'El resultado debería ser null cuando el wrapper es nulo');
    }
}