/**
 * @description       Clase de prueba para CEN_AdjuntarArchivoController.
 * Verifica que el registro de relación personalizado se cree correctamente
 * cuando se le proporcionan datos válidos.
 * @author            Jose Miguel Espinoza Mestanza
 * @email             josemiguel.espinozamestanza@emeal.nttdata.com
 * @version           1.0
 */
@isTest
private class CEN_AdjuntarArchivoController_tst {

    /**
     * @description Método de configuración que crea los datos de prueba necesarios
     * para todos los métodos en esta clase. Se ejecuta una sola vez.
     * Usar @testSetup es una buena práctica porque es más eficiente.
     */
    @testSetup
    static void makeData(){
        // 1. Crear un registro de Caso, ya que nuestro LWC siempre estará en el contexto de un registro.
        Case testCase = new Case(Subject = 'Test Case for Attachment');
        insert testCase;

        // 2. Crear un archivo (ContentVersion) para simular el archivo que el LWC sube.
        // Al insertar un ContentVersion, Salesforce crea automáticamente el ContentDocument padre.
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('This is a test document body'),
            IsMajorVersion = true
        );
        insert cv;
    }

    /**
     * @description Prueba el "camino feliz": que el método cree exitosamente el registro
     * de adjunto relacionado cuando todos los parámetros son correctos.
     */
    @isTest
    static void testCrearRegistroAdjunto_Success() {
        // --- ARRANGE (Preparar) ---
        // Obtener los datos creados en el método @testSetup.
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case for Attachment' LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];

        String tipoDeDocumento = 'Contrato'; // Un valor de ejemplo para el picklist.
        
        // --- ACT (Actuar) ---
        // Iniciar un contexto de prueba para aislar los límites del gobernador.
        Test.startTest();
        
        // Llamar al método que queremos probar.
        CEN_AdjuntarArchivoController.crearRegistroAdjunto(
            testCase.Id,
            cv.ContentDocumentId,
            tipoDeDocumento,
            'TestDocument.pdf'
        );
        
        Test.stopTest();

        // --- ASSERT (Verificar) ---
        // Verificar que el registro 'CEN_AdjuntoRelacionado__c' fue creado.
        List<CEN_AdjuntoRelacionado__c> adjuntos = [
            SELECT Id, CEN_CaseID__c, CEN_IdDocumento__c, CEN_TipoDocumentoCaso__c 
            FROM CEN_AdjuntoRelacionado__c
        ];

        // Verificamos que se haya creado exactamente UN registro.
        System.assertEquals(1, adjuntos.size(), 'Se esperaba que se creara un registro de adjunto.');

        // Verificamos que los datos en el registro creado sean los correctos.
        System.assertEquals(testCase.Id, adjuntos[0].CEN_CaseID__c, 'El ID del Caso no coincide.');
        System.assertEquals(cv.ContentDocumentId, adjuntos[0].CEN_IdDocumento__c, 'El ID del Documento no coincide.');
        System.assertEquals(tipoDeDocumento, adjuntos[0].CEN_TipoDocumentoCaso__c, 'El Tipo de Documento no coincide.');
    }
}