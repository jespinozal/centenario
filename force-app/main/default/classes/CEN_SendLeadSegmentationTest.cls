/**
 * @name               : CEN_SendLeadSegmentationTest
 * @description        : Clase de prueba simplificada para CEN_SendLeadSegmentation y CEN_LeadSegmentationTrigger.
 * @author             : Jesus Jaime Poco Salvador
 * @creation date      : 10-04-2025
 */
@isTest
private class CEN_SendLeadSegmentationTest {
    
    @TestSetup
    static void setup() {
        // Crear un registro de Tabla_maestra__c para pruebas
        Tabla_maestra__c distrito = new Tabla_maestra__c(
            Name = 'Lima'
        );
        insert distrito;
        
        // Usar el ID dinámico del distrito
        
        Lead oldLead = new Lead(
            LastName = 'Old Test Lead',
            Company = 'Test Company',
            CEN_N_mero_de_documento__c = '12345678',
            CEN_Tipo_de_documento__c = 'DNI',
            MobilePhone = '+51987654321',
            CEN_Distrito__c = distrito.Id, // Usar el ID dinámico
            Email = 'mailmail@mail.com',
            LeadSource = 'Call Center',
            CEN_Medio__c = '0084',
            CEN_Donde_comprar__c = 'LIMA_Lima_Norte_LU',
            CEN_Elige_donde_vivir__c = 'Boulevard Santa María',
            CEN_Estado_Envio_Tannua__c = 'Exitoso'
        );
        insert oldLead;
        
        CEN_Lead_Data_Segmentation__c oldSeg = new CEN_Lead_Data_Segmentation__c(
            CEN_IdLead__c = oldLead.Id,
            CEN_LDS_numero_documento__c = '12345678',
            CEN_LDS_Tipo_de_documento__c = 'DNI',
            CEN_LDS_Puntuacion_ponderada__c = '75.50',
            CEN_LDS_Variable_42__c = 'Universitario',      // Nuevo campo añadido
            CEN_LDS_Variable_202__c = 'Tecnología',        // Nuevo campo añadido
            CEN_LDS_Variable_287__c = 'Alto',              // Nuevo campo añadido
            CEN_LDS_Variable_315__c = 'Urbano',            // Nuevo campo añadido
            CEN_LDS_Variable_370__c = '2',                 // Nuevo campo añadido
            CEN_LDS_Variable_749__c = '750',                // Nuevo campo añadido
            CEN_LDS_Variable_46__c = 'Universitario',      // Nuevo campo añadido
            CEN_LDS_Variable_50__c = 'Tecnología',        // Nuevo campo añadido
            CEN_LDS_Variable_51__c = 'Alto',              // Nuevo campo añadido
            CEN_LDS_Variable_53__c = 'Urbano',            // Nuevo campo añadido
            CEN_LDS_Variable_55__c = '2',                 // Nuevo campo añadido
            CEN_LDS_Variable_59__c = '750',                // Nuevo campo añadido
            CEN_LDS_Variable_60__c = 'Universitario',      // Nuevo campo añadido
            CEN_LDS_Variable_63__c = 'Tecnología',        // Nuevo campo añadido
            CEN_LDS_Variable_67__c = 'Alto',              // Nuevo campo añadido
            CEN_LDS_Variable_68__c = 'Urbano',            // Nuevo campo añadido
            CEN_LDS_Variable_70__c = '2',                 // Nuevo campo añadido
            CEN_LDS_Variable_76__c = '750',                // Nuevo campo añadido
            CEN_LDS_Variable_80__c = 'Universitario',      // Nuevo campo añadido
            CEN_LDS_Variable_86__c = 'Tecnología',        // Nuevo campo añadido
            CEN_LDS_Variable_88__c = 'Alto',              // Nuevo campo añadido
            CEN_LDS_Variable_97__c = 'Urbano',            // Nuevo campo añadido
            CEN_LDS_Variable_104__c = '2'                 // Nuevo campo añadido
            
        );
        insert oldSeg;
        
        
    }
    
    @IsTest
    static void testSegmentacionLeadApi_Success() {
        Lead oldLead;
        try {
            oldLead = [SELECT Id FROM Lead WHERE CEN_N_mero_de_documento__c = '12345678' LIMIT 1];
            System.debug('Lead encontrado: ' + oldLead.Id);
        } catch (QueryException e) {
            System.assert(false, 'No se encontró el Lead del setup: ' + e.getMessage());
        }
        CEN_SegmentacionLeadApi.isTestMode = true;
       
        CEN_SegmentacionLeadApi token = CEN_SendLeadSegmentation.getToken();
        System.assertEquals('test-access-token-123', token.access_token, 'El token debe ser test-access-token-123');
        
        Test.startTest();
        CEN_SegmentacionLeadApi.SegmetacionResponse resp = CEN_SendLeadSegmentation.SegmentacionLeadApi(oldLead.Id);
        Test.stopTest();
        System.assertNotEquals(null, resp, 'Respuesta no debe ser nula');
    	System.assertEquals('01', resp.codigoOperacion, 'Código esperado: 00');
    }
    
    @isTest
    static void testValidarDni_ExitosoConError() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        testLead.CEN_Estado_Envio_Tannua__c = 'Exitoso';
        update testLead;
        
        CEN_Lead_Data_Segmentation__c segmentation = [SELECT Id FROM CEN_Lead_Data_Segmentation__c WHERE CEN_IdLead__c = :testLead.Id LIMIT 1];
        segmentation.CEN_LDS_estado__c = 'ERROR';
        update segmentation;
        
        Test.startTest();
        Boolean buttonEnabled = CEN_SendLeadSegmentation.validarDni(testLead.Id);
        Test.stopTest();
        
        System.assertEquals(true, buttonEnabled, 'El botón debería habilitarse si el estado es Exitoso y la segmentación tiene ERROR.');
    }
    
    @isTest
    static void testValidarDni_DniVacio() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        testLead.CEN_N_mero_de_documento__c = '';
        testLead.CEN_Estado_Envio_Tannua__c = 'Fallido'; // Aunque sea Fallido, DNI vacío debería predominar
        update testLead;
        
        Test.startTest();
        Boolean buttonEnabled = CEN_SendLeadSegmentation.validarDni(testLead.Id);
        Test.stopTest();
        
        System.assertEquals(false, buttonEnabled, 'El botón no debería habilitarse si el DNI está vacío.');
    }
    
    @isTest
    static void testValidarDni_Pendiente() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        testLead.CEN_Estado_Envio_Tannua__c = 'Pendiente';
        update testLead;
        
        Test.startTest();
        Boolean buttonEnabled = CEN_SendLeadSegmentation.validarDni(testLead.Id);
        Test.stopTest();
        
        System.assertEquals(false, buttonEnabled, 'El botón no debería habilitarse si el estado es Pendiente.');
    }
    
    @isTest
    static void testCloningRecentSegmentation() {
        // Obtener el ID del distrito dinámicamente
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Lima' LIMIT 1];
        
        Test.startTest();
        Lead newLead = new Lead(
            LastName = 'New Test Lead',
            Company = 'New Test Company',
            CEN_N_mero_de_documento__c = '12345678',
            CEN_Tipo_de_documento__c = 'DNI',
            MobilePhone = '+51987654321',
            CEN_Distrito__c = distrito.Id,
            Email = 'mailmail@mail.com',
            LeadSource = 'Call Center',
            CEN_Medio__c = '0084',
            CEN_Donde_comprar__c = 'PROV_Chiclayo_LU',
            CEN_Elige_donde_vivir__c = 'Urbanización Villa Los Sauces'
        );
        insert newLead;
        Test.stopTest();
        
        List<Lead> leads = [SELECT Id, CEN_Estado_Envio_Tannua__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];
        System.assertEquals(1, leads.size(), 'El Lead debería haberse insertado.');
        Lead updatedLead = leads[0];
        System.assertEquals('Exitoso', updatedLead.CEN_Estado_Envio_Tannua__c, 'El estado debería ser Exitoso tras clonar.');
        
        List<CEN_Lead_Data_Segmentation__c> newSegs = [SELECT Id, CEN_LDS_Puntuacion_ponderada__c,
                                                      CEN_LDS_Variable_42__c, CEN_LDS_Variable_202__c,
                                                      CEN_LDS_Variable_287__c, CEN_LDS_Variable_315__c,
                                                      CEN_LDS_Variable_370__c, CEN_LDS_Variable_749__c,
                                                      CEN_LDS_Variable_46__c,CEN_LDS_Variable_50__c,CEN_LDS_Variable_51__c,
                                                       CEN_LDS_Variable_53__c,CEN_LDS_Variable_55__c,CEN_LDS_Variable_59__c,CEN_LDS_Variable_60__c,
                                                       CEN_LDS_Variable_63__c,CEN_LDS_Variable_67__c,CEN_LDS_Variable_68__c,CEN_LDS_Variable_70__c,
                                                       CEN_LDS_Variable_76__c,CEN_LDS_Variable_80__c,CEN_LDS_Variable_86__c,CEN_LDS_Variable_88__c,
                                                       CEN_LDS_Variable_97__c,CEN_LDS_Variable_104__c
                                                      FROM CEN_Lead_Data_Segmentation__c 
                                                      WHERE CEN_IdLead__c = :newLead.Id];
        System.assertEquals(1, newSegs.size(), 'Debería haberse clonado una segmentación.');
        System.assertEquals('75.50', newSegs[0].CEN_LDS_Puntuacion_ponderada__c, 'La puntuación clonada debería coincidir.');
        System.assertEquals('Universitario', newSegs[0].CEN_LDS_Variable_42__c, 'Variable_42 debería clonarse correctamente.');
        System.assertEquals('Tecnología', newSegs[0].CEN_LDS_Variable_202__c, 'Variable_202 debería clonarse correctamente.');
        System.assertEquals('Alto', newSegs[0].CEN_LDS_Variable_287__c, 'Variable_287 debería clonarse correctamente.');
        System.assertEquals('Urbano', newSegs[0].CEN_LDS_Variable_315__c, 'Variable_315 debería clonarse correctamente.');
        System.assertEquals('2', newSegs[0].CEN_LDS_Variable_370__c, 'Variable_370 debería clonarse correctamente.');
        System.assertEquals('750', newSegs[0].CEN_LDS_Variable_749__c, 'Variable_749 debería clonarse correctamente.');
        System.assertEquals('Universitario', newSegs[0].CEN_LDS_Variable_46__c, 'Variable_46 debería clonarse correctamente.');
        System.assertEquals('Tecnología', newSegs[0].CEN_LDS_Variable_50__c, 'Variable_50 debería clonarse correctamente.');
        System.assertEquals('Alto', newSegs[0].CEN_LDS_Variable_51__c, 'Variable_51 debería clonarse correctamente.');
        System.assertEquals('Urbano', newSegs[0].CEN_LDS_Variable_53__c, 'Variable_53 debería clonarse correctamente.');
        System.assertEquals('2', newSegs[0].CEN_LDS_Variable_55__c, 'Variable_55 debería clonarse correctamente.');
        System.assertEquals('750', newSegs[0].CEN_LDS_Variable_59__c, 'Variable_59 debería clonarse correctamente.');
        System.assertEquals('Universitario', newSegs[0].CEN_LDS_Variable_60__c, 'Variable_60 debería clonarse correctamente.');
        System.assertEquals('Tecnología', newSegs[0].CEN_LDS_Variable_63__c, 'Variable_63 debería clonarse correctamente.');
        System.assertEquals('Alto', newSegs[0].CEN_LDS_Variable_67__c, 'Variable_67 debería clonarse correctamente.');
        System.assertEquals('Urbano', newSegs[0].CEN_LDS_Variable_68__c, 'Variable_68 debería clonarse correctamente.');
        System.assertEquals('2', newSegs[0].CEN_LDS_Variable_70__c, 'Variable_70 debería clonarse correctamente.');
        System.assertEquals('750', newSegs[0].CEN_LDS_Variable_76__c, 'Variable_76 debería clonarse correctamente.');
        System.assertEquals('Universitario', newSegs[0].CEN_LDS_Variable_80__c, 'Variable_80 debería clonarse correctamente.');
        System.assertEquals('Tecnología', newSegs[0].CEN_LDS_Variable_86__c, 'Variable_86 debería clonarse correctamente.');
        System.assertEquals('Alto', newSegs[0].CEN_LDS_Variable_88__c, 'Variable_88 debería clonarse correctamente.');
        System.assertEquals('Urbano', newSegs[0].CEN_LDS_Variable_97__c, 'Variable_97 debería clonarse correctamente.');
        System.assertEquals('2', newSegs[0].CEN_LDS_Variable_104__c, 'Variable_104 debería clonarse correctamente.');
        
    }
    
    @isTest
    static void testSendToTannua() {
        // Obtener el ID del distrito dinámicamente
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Lima' LIMIT 1];
        
        Test.startTest();
        Lead newLead = new Lead(
            LastName = 'New Test Lead',
            Company = 'New Test Company',
            CEN_N_mero_de_documento__c = '87654321',
            CEN_Tipo_de_documento__c = 'DNI',
            MobilePhone = '+51987654321',
            CEN_Distrito__c = distrito.Id, // Usar el ID dinámico
            Email = 'mailmail@mail.com',
            LeadSource = 'Call Center',
            CEN_Medio__c = '0084',
            CEN_Donde_comprar__c = 'LIMA_Lima_Norte_LU',
            CEN_Elige_donde_vivir__c = 'Boulevard Santa María'
        );
        insert newLead;
        
        CEN_SegmentacionLeadApi.SegmetacionResponse resp = CEN_SendLeadSegmentation.SegmentacionLeadApi(newLead.Id);
        Test.stopTest();
        
        Lead updatedLead = [SELECT CEN_Estado_Envio_Tannua__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];
        System.assertEquals('Fallido', updatedLead.CEN_Estado_Envio_Tannua__c, 'El estado debería ser Fallido en modo prueba por respuesta mockeada.');
        System.assertEquals('01', resp.codigoOperacion, 'El código debería ser 01 en modo prueba.');
    }
    
    @isTest
    static void testSegmentacionLeadApiAndValidarDni() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        testLead.CEN_Estado_Envio_Tannua__c = 'Fallido';
        update testLead;
        
        Test.startTest();
        Boolean buttonEnabled = CEN_SendLeadSegmentation.validarDni(testLead.Id);
        CEN_SegmentacionLeadApi.SegmetacionResponse resp = CEN_SendLeadSegmentation.SegmentacionLeadApi(testLead.Id);
        Test.stopTest();
        
        System.assertEquals(true, buttonEnabled, 'El botón debería habilitarse si el estado es Fallido.');
        System.assertEquals('01', resp.codigoOperacion, 'El código debería ser 01 en modo prueba.');
        Lead updatedLead = [SELECT CEN_Estado_Envio_Tannua__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Fallido', updatedLead.CEN_Estado_Envio_Tannua__c, 'El estado debería ser Fallido en modo prueba por respuesta mockeada.');
    }
    
   
    
    @isTest
    static void testSegmentacionLeadApiError() {
        // Obtener el ID del distrito dinámicamente
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Lima' LIMIT 1];
        
        Lead testLead = new Lead(
            LastName = 'Error Test Lead',
            Company = 'Test Company',
            CEN_N_mero_de_documento__c = '87654321',
            CEN_Tipo_de_documento__c = 'DNI',
            MobilePhone = '+51987654321',
            CEN_Distrito__c = distrito.Id, // Usar el ID dinámico
            Email = 'error@test.com',
            LeadSource = 'Call Center',
            CEN_Medio__c = '0084',
            CEN_Donde_comprar__c = 'LIMA_Lima_Norte_LU',
            CEN_Elige_donde_vivir__c = 'Boulevard Santa María',
            CEN_Estado_Envio_Tannua__c = 'Fallido'
        );
        insert testLead;
        
        Test.startTest();
        // Simular una excepción forzando un error en la prueba
        try {
            CEN_SendLeadSegmentation.SegmentacionLeadApi(null); // Pasar null para forzar una excepción
        } catch (Exception e) {
            System.assertEquals('Pendiente', [SELECT CEN_Estado_Envio_Tannua__c FROM Lead WHERE Id = :testLead.Id].CEN_Estado_Envio_Tannua__c, 
                           'El estado debería seguir siendo Fallido tras excepción.');
        }
        Test.stopTest();
    }
}