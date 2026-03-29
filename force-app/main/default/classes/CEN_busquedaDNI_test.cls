/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 08-10-2024
 * @last modified by   : Luis Maldonado
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-10-2024   Luis Maldonado   Initial Version
 * 1.1   26-03-2024   Felipe Bermudez  El test solo cubria 41% se llego a 79%
**/
@isTest
private class CEN_busquedaDNI_test {
    @testSetup
    private static void setup() {
        // Crear un Lead de prueba
        Lead testLead = new Lead(
            FirstName='Luis',
			LastName='Maldonado',
			CEN_Tipo_de_documento__c = 'DNI',
			CEN_N_mero_de_documento__c = '86954785',
			Email = 'rm.gh@hotmail.com',
			MobilePhone = '+51999966251',
			Company = 'NTT',
			CEN_Direcci_n_Prospecto__c = 'prueba',
			CEN_Comentario__c = 'prueba',
			LeadSource = 'Presencial',
			CEN_Medio__c = '0110'
        );
        insert testLead;
        
        // Crear un Lead de prueba
        Lead testLead2 = new Lead(
            FirstName='Luis',
			LastName='Bermudez',
			CEN_Tipo_de_documento__c = 'DNI',
			CEN_N_mero_de_documento__c = '86954784',
			Email = 'rm2gh@hotmail.com',
			MobilePhone = '+51999966254',
			Company = 'NTT',
			CEN_Direcci_n_Prospecto__c = 'prueba',
			CEN_Comentario__c = 'prueba',
			LeadSource = 'Presencial',
			CEN_Medio__c = '0110'
        );
        insert testLead2;
        
        // Crear una Account de prueba
		Account testAccount = new Account(
    		Name = 'Test Business Account',
            CEN_Tipo_de_documento__c = 'RUC',
            CEN_Numero_de_documento_del__c = '10201074440'
		);
		insert testAccount;
        
        // Crear un contacto relacionado con la cuenta
        Contact contact = new Contact(
            FirstName = 'Test', 
            LastName = 'Contact', 
            Email = 'testcontact@example.com', 
            Phone = '123456789',
            AccountId = testAccount.Id
        );
        insert contact;
        
        // Seleccionar un RecordType existente de prueba para Event
        RecordType rt = [SELECT Id 
                         FROM RecordType 
                         WHERE SObjectType = 'Event' 
                         AND DeveloperName = 'CEN_Reunion_presencial_Visita_presencial' 
                         LIMIT 1];

        // Crear un Evento de prueba
        Event testEvent = new Event(
            WhoId = testLead2.Id,
            Subject = 'Visita Presencial',
            StartDateTime = System.now().addDays(-1),
            EndDateTime = System.now().addHours(1),
            RecordTypeId = rt.Id,
            CreatedDate = System.now(),
            CEN_Asistio_a_Cita__c = true,
            ActivityDate = System.today(),
            CEN_Estado__c = 'Programado'
        );
        insert testEvent;
        
        // Crear un evento de prueba relacionado con la cuenta
        Event testEvent24 = new Event(
            Subject = 'Visita Presencial',
            StartDateTime = System.today(),
            EndDateTime = System.today(),
            WhatId = testAccount.Id,
            RecordTypeId = rt.Id,
            CreatedDate = System.now(),
            CEN_Asistio_a_Cita__c = true,
            ActivityDate = System.today(),
            CEN_Estado__c = 'Programado'
        );
        insert testEvent24;
        
        // Crear un perfil de prueba (asegúrate de que el perfil "CEN_Anfitriona" exista)
        Profile anfitrionaProfile = [SELECT Id FROM Profile WHERE Name = 'CEN_Anfitriona' LIMIT 1];
        
        Profile callCenterProfile = [SELECT Id FROM Profile WHERE Name = 'CEN_Callcenter' LIMIT 1];
        
        if (anfitrionaProfile == null) {
            System.assert(false, 'El perfil CEN_Anfitriona no fue encontrado.');
        }

        // Crear un usuario de prueba
        User testUser = new User(
            Username = 'testanfitriona@example.com',
            Email = 'testanfitriona@example.com',
            Alias = 'tanfi',
            ProfileId = anfitrionaProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Anfitriona',
            FirstName = 'Nac'
        );
        insert testUser;
        
        // Crear un usuario de prueba
        User testUser2 = new User(
            Username = 'testcall@example.com',
            Email = 'testcall@example.com',
            Alias = 'tcall',
            ProfileId = callCenterProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Center',
            FirstName = 'Nac'
        );
        insert testUser2;
        
        String RecTypeId = [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
		Account oAccount= new Account();
        oAccount.FirstName='A00001 Martin';
        oAccount.LastName='Guerrero';
        oAccount.CEN_Tipo_de_documento__pc = 'Sin especificar';
        oAccount.CEN_N_mero_de_documento__pc = '86954786';
        oAccount.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti';
        oAccount.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount.CEN_Direcci_n__c = 'Protiviti';
        oAccount.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount.RecordTypeId= RecTypeId;
        
        Account oAccount8= new Account();
        oAccount8.FirstName='A00003 protiviti';
        oAccount8.LastName='salesforce';
        oAccount8.CEN_Tipo_de_documento__pc = 'RUC';
        oAccount8.CEN_N_mero_de_documento__pc = '10201074440';
        oAccount8.CEN_Direcci_n_Centro_de_Trabajo__pc = 'Protiviti';
        oAccount8.CEN_Cargo_que_ocupa__pc = 'Ingeniero';
        oAccount8.CEN_Jefe_Directo__pc = 'Protiviti';
        oAccount8.CEN_Direcci_n__c = 'Protiviti';
        oAccount8.Prospecto_acept_t_rminos_y_condiciones__c=false;
        oAccount8.RecordTypeId= RecTypeId;
        
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name = 'Test District');
        insert distrito;
        
        // Create test profiles
        Profile callCenterProfile2 = [SELECT Id FROM Profile WHERE Name = 'CEN_Callcenter' LIMIT 1];

        // Create test user with Call Center profile
        User callCenterUser = new User(
            Username = 'testcallcenter@example.com',
            Email = 'testcallcenter@example.com',
            Alias = 'tcall',
            ProfileId = callCenterProfile2.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Center',
            FirstName = 'Test'
        );
        insert callCenterUser;
        
        Profile callCenterProfile3 = [SELECT Id FROM Profile WHERE Name = 'CEN_Anfitriona' LIMIT 1];

        // Create test user with Call Center profile
        User anfitrionaUser2 = new User(
            Username = 'testcallcenter2@example.com',
            Email = 'testcallcenter2@example.com',
            Alias = 'tcalls',
            ProfileId = callCenterProfile3.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'Center2',
            FirstName = 'Test2'
        );
        insert anfitrionaUser2;
        
        Account testAccount2 = new Account(
            LastName = 'User',
            FirstName = 'Test',
            PersonEmail = 'testaccount@example.com',
            PersonMobilePhone = '1234567890',
            CEN_N_mero_de_documento__pc = '12345678',
            CEN_Direcci_n__c = '123 Test St',
            CEN_Distrito__c = distrito.Id
        );
        insert testAccount2;
        
    }
    @IsTest
    static void testGetselectEveProspecto() {
        User anfitrionaUser2 = [SELECT Id, Profile.Name FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Maldonado' LIMIT 1];
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];
        
        List<Schema.PicklistEntry> picklistEntries = Case.CEN_Oficina_de_Venta__c.getDescribe().getPicklistValues();
        String validPicklistValue = picklistEntries.size() > 0 ? picklistEntries[0].getValue() : null;
        
        System.runAs(anfitrionaUser2) {
            Test.startTest();
            String result = CEN_busquedaDNI.getselectEve(
                testLead.Id, 'Prospecto', 'Venta', '12345678', 'Test', 'User',
                'testuser@example.com', '985810704', '123 Test St', distrito.Id,
                'Normal', null, validPicklistValue, 'Email'
            );
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testGetselectEvePostventaCuentaActualizar() {
        User anfitrionaUser2 = [SELECT Id, Profile.Name FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];
        Account testAccount2 = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc = '12345678' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testcontact@example.com' LIMIT 1];
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];
        
		List<Schema.PicklistEntry> picklistEntries = Case.CEN_Oficina_de_Venta__c.getDescribe().getPicklistValues();
        String validPicklistValue = picklistEntries.size() > 0 ? picklistEntries[0].getValue() : null;
        
        System.runAs(anfitrionaUser2) {
            Test.startTest();
            String result = CEN_busquedaDNI.getselectEve(
                testAccount2.Id, 'Cuenta', 'Postventa', '12345678', 'NewName', 'NewUser',
                'newemail@example.com', '999999999', '456 New St', distrito.Id,
                'Preferencial', null, validPicklistValue, 'Phone'
            );
            Test.stopTest();
        }
    }
    
	@IsTest
    static void testGetselectEvePostventaContactoNoActualizar() {
        User anfitrionaUser2 = [SELECT Id, Profile.Name FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];
        Account testAccount2 = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc = '12345678' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testcontact@example.com' LIMIT 1];
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];
        
		List<Schema.PicklistEntry> picklistEntries = Case.CEN_Oficina_de_Venta__c.getDescribe().getPicklistValues();
        String validPicklistValue = picklistEntries.size() > 0 ? picklistEntries[0].getValue() : null;
        
        System.runAs(anfitrionaUser2) {
        	Test.startTest();
            String result = CEN_busquedaDNI.getselectEve(
                testAccount2.Id, 'Cuenta', 'Postventa', '12345678', 'Test', 'User',
                'testaccount@example.com', '1234567890', '123 Test St', distrito.Id,
                'Normal', testContact.Id, validPicklistValue, 'Chat'
            );
            Test.stopTest();
        }
    }    
    
    @isTest
    static void testRegistrarVisitaDeTerceroPositiveScenario() {
        // Retrieve the district ID
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];

        Test.startTest();
        String result = CEN_busquedaDNI.registrarVisitaDeTercero(
            'DNI', 
            '12345678', 
            'Test', 
            'User', 
            '123 Test St', 
            distrito.Id,  // Pass the district ID here
            'testuser@example.com', 
            '1234567890', 
            'Preferencial', 
            'Test OAC'
        );
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result);
    }
    
    @isTEST 
    static void testRegistrarVisitaDeTerceroAnfitriona(){
        User anfitrionaUser2 = [SELECT Id FROM User WHERE Username = 'testcallcenter2@example.com' LIMIT 1];
        
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];
        // Retrieve valid picklist values for CEN_Oficina_de_Venta__c
        List<Schema.PicklistEntry> picklistEntries = Case.CEN_Oficina_de_Venta__c.getDescribe().getPicklistValues();
        String validPicklistValue = picklistEntries[0].getValue(); // Use the first valid value
        
        System.runAs(anfitrionaUser2) {
            Test.startTest();
            String result = CEN_busquedaDNI.registrarVisitaDeTercero(
                'DNI', 
                '12365676', 
                'Test2', 
                'User2', 
                '123 Test St', 
                distrito.Id, 
                'testuser2@example.com', 
                '985810554', 
                'Presencial', 
                validPicklistValue // Use a valid picklist value
            );
            Test.stopTest();
        }
        
    }
    @isTest
    static void testRegistrarVisitaDeTerceroCallCenter() {
        User callCenterUser = [SELECT Id FROM User WHERE Username = 'testcallcenter@example.com' LIMIT 1];
        
        
        Tabla_maestra__c distrito = [SELECT Id FROM Tabla_maestra__c WHERE Name = 'Test District' LIMIT 1];
        
        // Retrieve valid picklist values for CEN_Oficina_de_Venta__c
        List<Schema.PicklistEntry> picklistEntries = Case.CEN_Oficina_de_Venta__c.getDescribe().getPicklistValues();
        String validPicklistValue = picklistEntries[0].getValue(); // Use the first valid value

        System.runAs(callCenterUser) {
            Test.startTest();
            String result = CEN_busquedaDNI.registrarVisitaDeTercero(
                'DNI', 
                '12345678', 
                'Test', 
                'User', 
                '123 Test St', 
                distrito.Id, 
                'testuser@example.com', 
                '985810704', 
                'Preferencial', 
                validPicklistValue // Use a valid picklist value
            );
            Test.stopTest();
        }
        
    }
    
    
    
    @isTest
    static void testGetOACs() {
        Test.startTest();
        List<CEN_busquedaDNI.PickListWrapper> result = CEN_busquedaDNI.getOACs();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Picklist should not be empty');

        // Validate properties of the first PickListWrapper
        if (result.size() > 0) {
            CEN_busquedaDNI.PickListWrapper firstItem = result[0];

            // Verify that the label and value are not null
            System.assertNotEquals(null, firstItem.label, 'Label should not be null');
            System.assertNotEquals(null, firstItem.value, 'Value should not be null');

            // Verify that the label is in uppercase
            System.assertEquals(firstItem.label, firstItem.label.toUpperCase(), 'Label should be in uppercase');

            // Verify that "selected" is false by default
            System.assertEquals(false, firstItem.selected, 'Selected should be false by default');
        }
    }
    
    
    @isTest
    private static void test_buscarDistritobyId(){
        Test.startTest();
        CEN_busquedaDNI.getObligacionElegirOAC();
        Test.stopTest();
    }
    
    
    @isTest
    private static void getObligacionElegirOAC(){
        Test.startTest();
        CEN_busquedaDNI.buscarDistritobyId('123123');
        Test.stopTest();
    }
    
	
    @isTest
    private static void test_getselectDoc_SinEspecificar(){
        Test.startTest();
        CEN_busquedaDNI.getselectDoc('Sin especificar', '86954786');
        Test.stopTest();
    }
    @isTest
    private static void test_getselectDoc_Ruc(){
        Test.startTest();
        CEN_busquedaDNI.getselectDoc('RUC', '10201074440');
        Test.stopTest();
    }
    
    @isTest
    private static void test_getselectDoc_DNI(){
        Test.startTest();
        CEN_busquedaDNI.NivelPagerWrapper result = CEN_busquedaDNI.getselectDoc('DNI', '86954784');
        system.debug('result clase: '+ result);
        // Validar que los eventos están formateados correctamente
        System.assertEquals(1, result.eventosFormateados.size(), 'Debe devolver un evento formateado');
        
        Map<String, String> eventoFormateado = result.eventosFormateados[0];

        // Validar campos del evento
        System.assertEquals('Visita Presencial', eventoFormateado.get('Subject'), 'El asunto del evento debe coincidir');
        System.assertNotEquals(null, eventoFormateado.get('StartDate'), 'Debe tener una fecha de inicio');
        System.assertNotEquals(null, eventoFormateado.get('StartTime'), 'Debe tener una hora de inicio');
        System.assertNotEquals(null, eventoFormateado.get('EndDate'), 'Debe tener una fecha de fin');
        System.assertNotEquals(null, eventoFormateado.get('EndTime'), 'Debe tener una hora de fin');
        System.assertNotEquals(null, eventoFormateado.get('CreatedDate'), 'Debe tener una fecha de creación');
        System.assertNotEquals(null, eventoFormateado.get('CreatedTime'), 'Debe tener una hora de creación');
        System.assertEquals('Prospecto', eventoFormateado.get('Origen'), 'El origen del evento debe ser la cuenta');
        System.assertEquals('true', eventoFormateado.get('CEN_Asistio_a_Cita__c'), 'El campo CEN_Asistio_a_Cita__c debe ser verdadero');
        
        Test.stopTest();
    }
    
    @isTest
    private static void test_getselectDoc_CuentaOrg(){
        Test.startTest();

        // Ejecutar el método con un tipo de documento RUC
        CEN_busquedaDNI.NivelPagerWrapper result = CEN_busquedaDNI.getselectDoc('RUC', '123456789');
        
        // Validar que se han devuelto las cuentas y contactos correctamente
        System.assertNotEquals(null, result.Cuentaorgs, 'Debe devolver una lista de Cuentaorgs');
		
        
        Test.stopTest();

    }
    
    @IsTest
    private static void test_createNewEventAutomaticPresencialProspecto() {
        // Obtener el lead insertado
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Business Account' LIMIT 1];
        System.debug('account: ' + testAccount);
        
        // Datos de prueba
        String testAccountId = testAccount.Id;
        String tipo = 'Cuenta ';
        String visita = 'Venta';
        String idct = null;
        String oac = null;
        String medio = '0118';
        
        // Crear un usuario de prueba dentro del bloque runAs
        User testUser = [SELECT Id FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];

        System.runAs(testUser) {
            // Llamar al método que estamos probando
            Test.startTest();
            String result = CEN_busquedaDNI.createNewEventAutomaticPresencial(testAccountId, tipo, visita, oac, medio);
            Test.stopTest();
    	}
    }
    
    @IsTest
    private static void test_createNewEventAutomaticPresencialCuenta() {
        // Obtener el lead insertado
        Lead testLead2 = [SELECT Id, LastName FROM Lead WHERE LastName = 'Bermudez' LIMIT 1];
        System.debug('leadddds2: ' + testLead2);
        
        // Datos de prueba
        String testLeadId = testLead2.Id;
        String tipo = 'Prospecto ';
        String visita = 'Venta';
        String idct = null;
        String oac = null;
        String medio = '0118';
        
        // Crear un usuario de prueba dentro del bloque runAs
        User testUser = [SELECT Id FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];

        System.runAs(testUser) {
            // Llamar al método que estamos probando
            Test.startTest();
            String result = CEN_busquedaDNI.createNewEventAutomaticPresencial(testLeadId, tipo, visita, oac, medio);
            Test.stopTest();
    	}
    }
    
    @IsTest
    private static void test_createNewEventAutomaticPresencialError() {
        // Obtener el lead insertado
        Lead testLead2 = [SELECT Id, LastName FROM Lead WHERE LastName = 'Bermudez' LIMIT 1];
        System.debug('leadddds2: ' + testLead2);
        
        // Datos de prueba
        String testLeadId = testLead2.Id;
        String tipo = 'Prospecto ';
        String visita = 'Venta';
        String idct = null;
        String oac = null;
        String medio = '0118';
        
        // Crear un usuario de prueba dentro del bloque runAs
        User testUser2 = [SELECT Id FROM User WHERE Username = 'testanfitriona@example.com' LIMIT 1];

        
        // Llamar al método que estamos probando
        Test.startTest();
        String result = CEN_busquedaDNI.createNewEventAutomaticPresencial(testLeadId, tipo, visita, oac, medio);
        Test.stopTest();
    	
    }
    
    @IsTest
    private static void test_confirmarAsistenciaDeEvento() {
        Event eventTest = [SELECT Id FROM Event WHERE Subject = 'Visita Presencial' LIMIT 1];
        
        String eventId = eventTest.Id;
        
        // Llamar al método que estamos probando
        Test.startTest();
        String result = CEN_busquedaDNI.confirmarAsistenciaDeEvento(eventId);
        Test.stopTest();
    }
    
    @IsTest
    private static void test_getselectEve(){
        
        // Obtener el lead insertado
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Maldonado' LIMIT 1];
        
        // Crear un usuario de prueba
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'CEN_Anfitriona' LIMIT 1];
        User anfitrionaUser2 = [SELECT Id FROM User WHERE Username = 'testcallcenter2@example.com' LIMIT 1];
        
        // Datos de prueba
        String tipo = 'Test Tipo';
        String visita = 'Test Visita';
        String documento = 'Test Documento';
        String name = 'Test';
        String apellido = 'User';
        String correo = 'testuser@example.com';
        String celular = '1234567890';
        String direccion = '123 Test St';
        String distrito = 'Test District';
        String atencion = 'Test Atencion';
        String idct = '987654321098765'; // Cambia esto por un ID válido en tu contexto
        String oac = 'Test OAC';
        String medio = 'Test Medio';
		
        
        Test.startTest();
        String result = CEN_busquedaDNI.getselectEve(testLead.Id, tipo, visita, documento, name, apellido, correo, celular, direccion, distrito, atencion, idct, oac, medio);
        Test.stopTest();

    }
    
   
    @IsTest
    private static void test_getMedio(){
        
        Test.startTest();
        // Llamar al método que queremos probar
        List<CEN_busquedaDNI.PickListWrapper> result = CEN_busquedaDNI.getMedio(); 

        // Validar que se devuelve una lista no vacía
        System.assertNotEquals(0, result.size(), 'El picklist no debe estar vacío.');

        // Validar las propiedades de un PickListWrapper
        if (result.size() > 0) {
            CEN_busquedaDNI.PickListWrapper firstItem = result[0];

            // Verificar que el label y value no estén vacíos
            System.assertNotEquals(null, firstItem.label, 'El label no debe ser null.');
            System.assertNotEquals(null, firstItem.value, 'El valor no debe ser null.');

            // Verificar que el label esté en mayúsculas
            System.assertEquals(firstItem.label, firstItem.label.toUpperCase(), 'El label debe estar en mayúsculas.');

            // Verificar que "selected" sea false por defecto
            System.assertEquals(false, firstItem.selected, 'El campo "selected" debe ser false por defecto.');
        }

        Test.stopTest();
    }
    
    @IsTest
    public static void test_validarActualizacionDatosContacto() {
        List<Tabla_maestra__c> distritos = CEN_cls_TestClass_DF.getDistritos();
    	insert distritos;
        // Crear un contacto de prueba con valores iniciales
        Contact contacto = new Contact(
            FirstName = 'Juan',
            LastName = 'Perez',
            Email = 'juan.perez@example.com',
            Phone = '123456789',
            CEN_Direccion__c = 'Calle Falsa 123',
            CEN_Distrito__c = distritos[0].Id
        );

        // Llamar al método con valores diferentes para simular cambios
        Boolean result = CEN_busquedaDNI.Validar_actualizacion_datos_Contacto(
            contacto, 
            'Carlos',  // Nombre cambiado
            'Maldonado',   // Apellido no cambiado
            'carlos.perez@example.com',  // Correo cambiado
            '987654321',  // Celular cambiado
            'Avenida Siempre Viva 742',  // Dirección cambiada
             distritos[1].Id  // Distrito cambiado
        );

        // Verificar que el resultado sea verdadero (hubo cambios)
        System.assertEquals(true, result, 'Debería retornar true ya que se realizaron varios cambios en el contacto.');
    }

    
    @IsTest
    public static void test_validarActualizacionDatosContacto_SinCambios() {
        List<Tabla_maestra__c> distritos = CEN_cls_TestClass_DF.getDistritos();
    	insert distritos;
        
        // Crear un contacto de prueba con valores iniciales
        Contact contacto = new Contact(
            FirstName = 'Juan',
            LastName = 'Perez',
            Email = 'juan.perez@example.com',
            Phone = '123456789',
            CEN_Direccion__c = 'Calle Falsa 123',
            CEN_Distrito__c = distritos[0].Id
        );

        // Llamar al método con los mismos valores que tiene el contacto
        Boolean result = CEN_busquedaDNI.Validar_actualizacion_datos_Contacto(
            contacto, 
            'Juan',   // Mismo nombre
            'Perez',  // Mismo apellido
            'juan.perez@example.com',  // Mismo correo
            '123456789',  // Mismo celular
            'Calle Falsa 123',  // Misma dirección
            distritos[0].Id  // Mismo distrito
        );

        // Verificar que el resultado sea falso (no hubo cambios)
        System.assertEquals(false, result, 'Debería retornar false ya que no hubo cambios en los datos del contacto.');
    }
    
    
    
    @IsTest
    public static void test_validarActualizacionDatosCuenta_CambiosCuentaNatural() {
        // Crear un tipo de registro para simular una cuenta natural
        RecordType cuentaNaturalRT = [SELECT Id FROM RecordType WHERE Name = 'Cuenta Natural' LIMIT 1];
        
        List<Tabla_maestra__c> distritos = CEN_cls_TestClass_DF.getDistritos();
    	insert distritos;
        
        // Crear una cuenta de prueba con valores iniciales
        Account cuenta = new Account(
            FirstName = 'Juan',
            LastName = 'Perez',
            PersonEmail = 'juan.perez@example.com',
            PersonMobilePhone = '123456789',
            CEN_Direccion__pc = 'Calle Falsa 123',
            CEN_Distrito__pc = distritos[0].Id,
            RecordTypeId = cuentaNaturalRT.Id
        );

        // Llamar al método con valores diferentes para simular cambios
        Boolean result = CEN_busquedaDNI.Validar_actualizacion_datos_Cuenta(
            cuenta, 
            'Carlos',  // Nombre cambiado
            'Maldonado',   // Apellido no cambiado
            'carlos.perez@example.com',  // Correo cambiado
            '987654321',  // Celular cambiado
            'Avenida Siempre Viva 742',  // Dirección cambiada
            distritos[1].Id  // Distrito cambiado
        );

        // Verificar que el resultado sea verdadero (hubo cambios)
        System.assertEquals(true, result, 'Debería retornar true ya que se realizaron varios cambios en la cuenta.');
    }
    
    
}