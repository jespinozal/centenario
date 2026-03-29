/**
 * @name               : CEN_CreateLeadSegServiceTest
 * @description        : Clase de prueba para CEN_CreateLeadSegService_cls y CEN_LeadDataSegmentationTrigger.
 * @author             : Jesus Jaime Poco Salvador
 * @creation date      : 10-04-2025
 */
@isTest
private class CEN_CreateLeadSegServiceTest {
    
    @TestSetup
    static void setup() {
        // Crear un registro de Tabla_maestra__c para pruebas
        Tabla_maestra__c distrito = new Tabla_maestra__c(
            Name = 'Lima'
        );
        insert distrito;
        // Usar el ID dinámico del distrito
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            CEN_N_mero_de_documento__c = '12345678',
            MobilePhone = '+51987654321',
            CEN_Distrito__c = distrito.Id, // Usar el ID dinámico
            Email = 'mailmail@mail.com',
            LeadSource = 'Call Center',
            CEN_Medio__c = '0084',
            CEN_Donde_comprar__c = 'LIMA_Lima_Norte_LU',
            CEN_Elige_donde_vivir__c = 'Boulevard Santa María'
        );
        insert testLead;
    }
    
    @isTest
    static void testDoPostSuccess() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        String jsonBody = '[{"CEN_IdLead__c":"' + testLead.Id + '","CEN_LDS_Tipo_de_documento__c":"DNI","CEN_LDS_numero_documento__c":"12345678","CEN_LDS_Puntuacion_ponderada__c":"85.75","CEN_LDS_Variable_42__c":"Universitario"}]';
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createLeadSegmentado/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse(); // Inicializamos el objeto response
        
        Test.startTest();
        CEN_CreateLeadSegService_cls.doPost(); // Dispara CEN_LeadDataSegmentationTrigger
        Test.stopTest();
        
        List<CEN_Lead_Data_Segmentation__c> segs = [SELECT Id FROM CEN_Lead_Data_Segmentation__c WHERE CEN_IdLead__c = :testLead.Id];
        System.assertEquals(1, segs.size(), 'Debería crearse un registro de segmentación.');
        Lead updatedLead = [SELECT CEN_Puntuacion_ponderada__c, CEN_Estudio_Superior__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(85.75, updatedLead.CEN_Puntuacion_ponderada__c, 'La puntuación debería actualizarse.');
        System.assertEquals('Universitario', updatedLead.CEN_Estudio_Superior__c, 'El campo Variable_42 debería mapearse.');
    }
    
    @isTest
    static void testDoPostMissingFields() {
        String jsonBody = '[{"CEN_LDS_numero_documento__c":"12345678"}]'; // Falta IdLead y Tipo
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createLeadSegmentado/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse(); // Inicializamos el objeto response
        
        Test.startTest();
        CEN_CreateLeadSegService_cls.doPost();
        Test.stopTest();
        
        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode, 'Debería devolver 400 por campos faltantes.');
        List<CEN_Lead_Data_Segmentation__c> segs = [SELECT Id FROM CEN_Lead_Data_Segmentation__c];
        System.assertEquals(0, segs.size(), 'No debería crearse ninguna segmentación.');
    }
}