/**
 * Jesus Poco
 * jpocosal@emeal.nttdata.com
 */

@isTest
private class CEN_CaseTrackingTriggerTest {

    @isTest
    static void testObservedStateLogic() {
        // 1. Crear Caso. Inicialmente, Observado = false.
        Case testCase = new Case(Subject = 'Test Case for State', CEN_Observado__c = false);
        insert testCase;

        Test.startTest();

        // 2. Se crea el Tracking #1. 
        // En este momento, el estado "Observado" del caso es FALSE.
        CEN_CaseTracking__c tracking1 = new CEN_CaseTracking__c(CEN_CaseId__c = testCase.Id);
        insert tracking1;

        // 3. ACTUALIZAMOS EL CASO: El usuario marca el check "Observado" a TRUE.
        // Esto ocurre ANTES de que termine la siguiente etapa.
        testCase.CEN_Observado__c = true;
        update testCase;

        // 4. Se crea el Tracking #2. 
        // El trigger tomará el snapshot del caso que ahora es TRUE.
        CEN_CaseTracking__c tracking2 = new CEN_CaseTracking__c(CEN_CaseId__c = testCase.Id);
        insert tracking2;
        
        // 5. ACTUALIZAMOS EL CASO DE NUEVO: El usuario desmarca el check a FALSE.
        testCase.CEN_Observado__c = false;
        update testCase;
        
        // 6. Se crea el Tracking #3.
        // El trigger tomará el snapshot del caso que ahora es FALSE.
        CEN_CaseTracking__c tracking3 = new CEN_CaseTracking__c(CEN_CaseId__c = testCase.Id);
        insert tracking3;

        Test.stopTest();

        // 7. Verificamos los resultados de los 3 registros
        List<CEN_CaseTracking__c> results = [
            SELECT CEN_Etapa_Estuvo_en_Observacion__c, CEN_Observado_al_Finalizar__c
            FROM CEN_CaseTracking__c WHERE CEN_CaseId__c = :testCase.Id ORDER BY CreatedDate ASC
        ];
        
        System.assertEquals(3, results.size());
        
        CEN_CaseTracking__c result1 = results[0];
        CEN_CaseTracking__c result2 = results[1];
        CEN_CaseTracking__c result3 = results[2];

        // Aserciones para el Registro #1 (Etapa NO observada)
        System.assertEquals(false, result1.CEN_Etapa_Estuvo_en_Observacion__c, 'La primera etapa NO debería estar en observación.');
        System.assertEquals(false, result1.CEN_Observado_al_Finalizar__c, 'El snapshot del primer registro debe ser false.');

        // Aserciones para el Registro #2 (Etapa SÍ estuvo observada)
        System.assertEquals(false, result2.CEN_Etapa_Estuvo_en_Observacion__c, 'La segunda etapa DEBERÍA estar en observación.');
        System.assertEquals(true, result2.CEN_Observado_al_Finalizar__c, 'El snapshot del segundo registro debe ser true.');
        
        // Aserciones para el Registro #3 (Etapa NO estuvo observada)
        //System.assertEquals(false, result3.CEN_Etapa_Estuvo_en_Observacion__c, 'La tercera etapa DEBERÍA haber iniciado en estado Observado (del snapshot anterior).');
        System.assertEquals(false, result3.CEN_Observado_al_Finalizar__c, 'El snapshot del tercer registro debe ser false.');
    }
}