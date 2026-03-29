/**
 * @name               : CEN_UpdateFechaDeEntregaOppService_test
 * @author             : Felipe Bermudez
 * @creation date      : 17-06-2025
 * @description        : clase test para CEN_UpdateFechaDeEntregaOppService_cls
 * @versions           : 1.0 - Clase Apex inicial
 * @test class         : 
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   17-06-2025   Felipe Bermudez Initial Version
 */
@isTest
public with sharing class CEN_UpdateFechaDeEntregaOppService_test {
    @TestSetup
    static void SetUp() {
        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_N_mero_de_documento__pc = '12345678';
        insert acc;

        Proyecto__c pro = new Proyecto__c();
        pro.Name = 'Proyecto 1';
        pro.CEN_CODIGOSAP__c = '10U.11E';
        insert pro;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.CloseDate = System.today();
        opp.StageName = 'Cotización';
        opp.CEN_Tipo_de_solicitud__c = 'Solicitud';
        opp.CEN_Tiene_Reserva__c = 'No';
        opp.CEN_Oficina_de_Venta__c = 'ZV008';
        opp.CEN_Con_sustento__c = 'No';
        opp.CEN_Medio_Publicitario__c = 'Radio';
        opp.CEN_Tipo_de_venta__c = 'CD';
        opp.CEN_Fecha_Entrega_Lote__c = Date.valueOf('2025-11-15');
        opp.CEN_Fecha_EntregaLote_Espejo__c = '15 de noviembre de 2025';
        opp.CEN_Proforma__c = 'PROF123';
        opp.CEN_INTERLOCUTOR_1__c = 'Interlocutor 1';
        opp.CEN_INTERLOCUTOR_2__c = 'Interlocutor 2';
        opp.CEN_INTERLOCUTOR_3__c = 'Interlocutor 3';
        opp.CEN_INTERLOCUTOR_4__c = 'Interlocutor 4';
        opp.CEN_INTERLOCUTOR_5__c = 'Interlocutor 5';
        opp.CEN_INTERLOCUTOR_6__c = 'Interlocutor 6';
        opp.CEN_INTERLOCUTOR_7__c = 'Interlocutor 7';
        opp.CEN_INTERLOCUTOR_8__c = 'Interlocutor 8';
        opp.CEN_INTERLOCUTOR_9__c = 'Interlocutor 9';
        opp.CEN_INTERLOCUTOR_10__c = 'Interlocutor 10';
        opp.CEN_TITULAR__c = 'Titular Test';
        opp.CEN_TITULAR_EMAIL__c = 'titular@test.com';
        opp.CEN_INTERLOCUTOR_1_EMAIL__c = 'interlocutor1@test.com';
        opp.CEN_INTERLOCUTOR_2_EMAIL__c = 'interlocutor2@test.com';
        opp.Amount = 1000;
        opp.AccountId = acc.id;
        opp.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        opp.CEN_Proyecto__c = pro.Id;
        insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.CloseDate = System.today();
        opp2.StageName = 'Cotización';
        opp2.CEN_Tipo_de_solicitud__c = 'Solicitud';
        opp2.CEN_Tiene_Reserva__c = 'No';
        opp2.CEN_Con_sustento__c = 'No';
        opp2.CEN_Medio_Publicitario__c = 'Radio';
        opp2.CEN_Tipo_de_venta__c = 'CD';
        opp2.CEN_Proforma__c = 'PROF124';
        opp2.CEN_INTERLOCUTOR_1__c = 'Interlocutor A';
        opp2.CEN_INTERLOCUTOR_2__c = 'Interlocutor B';
        opp2.CEN_TITULAR__c = 'Titular Test 2';
        opp2.CEN_TITULAR_EMAIL__c = 'titular2@test.com';
        opp2.CEN_INTERLOCUTOR_1_EMAIL__c = 'interlocutora@test.com';
        opp2.CEN_INTERLOCUTOR_2_EMAIL__c = 'interlocutorb@test.com';
        opp2.CEN_Oficina_de_Venta__c = 'ZV008';
        opp2.Amount = 1000;
        opp2.AccountId = acc.id;
        opp2.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        opp2.CEN_Proyecto__c = pro.Id;
        insert opp2;

        // Actualizar las oportunidades a StageName = 'Oportunidad Ganada'
        opp.StageName = 'Oportunidad Ganada';
        opp2.StageName = 'Oportunidad Ganada';
        update new List<Opportunity>{opp, opp2};
    }

    @isTest
    static void testDoPostSuccess() {
        // Preparar el CSV válido con todos los campos nuevos
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'PROF123;2025-11-15;New Interlocutor 1;New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;New Titular;titular@test.com;interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com\r\n' +
                         'PROF124;2025-12-20;New Interlocutor A;New Interlocutor B;New Interlocutor C;New Interlocutor D;New Interlocutor E;New Interlocutor F;New Interlocutor G;New Interlocutor H;New Interlocutor I;New Interlocutor J;New Titular 2;titular2@test.com;interlocutora@test.com;interlocutorb@test.com;interlocutorc@test.com;interlocutord@test.com;interlocutore@test.com;interlocutorf@test.com;interlocutorg@test.com;interlocutorh@test.com;interlocutori@test.com;interlocutorj@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('OK', response[0].Estado, 'El estado debe ser OK');
        System.assertEquals(2, response[0].Actualizados, 'Deben actualizarse 2 oportunidades');

        // Verificar que las oportunidades se actualizaron correctamente
        Opportunity updatedOpp = [SELECT CEN_Fecha_Entrega_Lote__c, CEN_Fecha_EntregaLote_Espejo__c, 
                                        CEN_INTERLOCUTOR_1__c, CEN_INTERLOCUTOR_2__c, CEN_INTERLOCUTOR_3__c,
                                        CEN_INTERLOCUTOR_4__c, CEN_INTERLOCUTOR_5__c, CEN_INTERLOCUTOR_6__c,
                                        CEN_INTERLOCUTOR_7__c, CEN_INTERLOCUTOR_8__c, CEN_INTERLOCUTOR_9__c,
                                        CEN_INTERLOCUTOR_10__c, CEN_TITULAR__c, CEN_TITULAR_EMAIL__c,
                                        CEN_INTERLOCUTOR_1_EMAIL__c, CEN_INTERLOCUTOR_2_EMAIL__c, 
                                        CEN_INTERLOCUTOR_3_EMAIL__c, CEN_INTERLOCUTOR_4_EMAIL__c, 
                                        CEN_INTERLOCUTOR_5_EMAIL__c, CEN_INTERLOCUTOR_6_EMAIL__c, 
                                        CEN_INTERLOCUTOR_7_EMAIL__c, CEN_INTERLOCUTOR_8_EMAIL__c, 
                                        CEN_INTERLOCUTOR_9_EMAIL__c, CEN_INTERLOCUTOR_10_EMAIL__c
                                 FROM Opportunity 
                                 WHERE CEN_Proforma__c = 'PROF123' LIMIT 1];
        System.assertEquals(Date.valueOf('2025-11-15'), updatedOpp.CEN_Fecha_Entrega_Lote__c, 'La fecha de entrega debe ser 2025-11-15');
        System.assertEquals('15 de noviembre de 2025', updatedOpp.CEN_Fecha_EntregaLote_Espejo__c, 'El campo espejo debe estar formateado correctamente');
        System.assertEquals('New Interlocutor 1', updatedOpp.CEN_INTERLOCUTOR_1__c, 'Interlocutor 1 debe actualizarse');
        System.assertEquals('New Interlocutor 2', updatedOpp.CEN_INTERLOCUTOR_2__c, 'Interlocutor 2 debe actualizarse');
        System.assertEquals('New Interlocutor 3', updatedOpp.CEN_INTERLOCUTOR_3__c, 'Interlocutor 3 debe actualizarse');
        System.assertEquals('New Interlocutor 4', updatedOpp.CEN_INTERLOCUTOR_4__c, 'Interlocutor 4 debe actualizarse');
        System.assertEquals('New Interlocutor 5', updatedOpp.CEN_INTERLOCUTOR_5__c, 'Interlocutor 5 debe actualizarse');
        System.assertEquals('New Interlocutor 6', updatedOpp.CEN_INTERLOCUTOR_6__c, 'Interlocutor 6 debe actualizarse');
        System.assertEquals('New Interlocutor 7', updatedOpp.CEN_INTERLOCUTOR_7__c, 'Interlocutor 7 debe actualizarse');
        System.assertEquals('New Interlocutor 8', updatedOpp.CEN_INTERLOCUTOR_8__c, 'Interlocutor 8 debe actualizarse');
        System.assertEquals('New Interlocutor 9', updatedOpp.CEN_INTERLOCUTOR_9__c, 'Interlocutor 9 debe actualizarse');
        System.assertEquals('New Interlocutor 10', updatedOpp.CEN_INTERLOCUTOR_10__c, 'Interlocutor 10 debe actualizarse');
        System.assertEquals('New Titular', updatedOpp.CEN_TITULAR__c, 'Titular debe actualizarse');
        System.assertEquals('titular@test.com', updatedOpp.CEN_TITULAR_EMAIL__c, 'Email del titular debe actualizarse');
        System.assertEquals('interlocutor1@test.com', updatedOpp.CEN_INTERLOCUTOR_1_EMAIL__c, 'Email del interlocutor 1 debe actualizarse');
        System.assertEquals('interlocutor2@test.com', updatedOpp.CEN_INTERLOCUTOR_2_EMAIL__c, 'Email del interlocutor 2 debe actualizarse');
        System.assertEquals('interlocutor3@test.com', updatedOpp.CEN_INTERLOCUTOR_3_EMAIL__c, 'Email del interlocutor 3 debe actualizarse');
        System.assertEquals('interlocutor4@test.com', updatedOpp.CEN_INTERLOCUTOR_4_EMAIL__c, 'Email del interlocutor 4 debe actualizarse');
        System.assertEquals('interlocutor5@test.com', updatedOpp.CEN_INTERLOCUTOR_5_EMAIL__c, 'Email del interlocutor 5 debe actualizarse');
        System.assertEquals('interlocutor6@test.com', updatedOpp.CEN_INTERLOCUTOR_6_EMAIL__c, 'Email del interlocutor 6 debe actualizarse');
        System.assertEquals('interlocutor7@test.com', updatedOpp.CEN_INTERLOCUTOR_7_EMAIL__c, 'Email del interlocutor 7 debe actualizarse');
        System.assertEquals('interlocutor8@test.com', updatedOpp.CEN_INTERLOCUTOR_8_EMAIL__c, 'Email del interlocutor 8 debe actualizarse');
        System.assertEquals('interlocutor9@test.com', updatedOpp.CEN_INTERLOCUTOR_9_EMAIL__c, 'Email del interlocutor 9 debe actualizarse');
        System.assertEquals('interlocutor10@test.com', updatedOpp.CEN_INTERLOCUTOR_10_EMAIL__c, 'Email del interlocutor 10 debe actualizarse');
    }

    @isTest
    static void testDoPostInvalidCSV() {
        // Preparar un CSV con encabezados inválidos
        String csvBody = 'InvalidHeader;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c\r\n' +
                         'PROF123;2025-11-15;New Interlocutor 1';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
    }

    @isTest
    static void testDoPostEmptyCSV() {
        // Preparar un CSV vacío
        String csvBody = '';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
        System.assert(response[0].Error.contains('CSV vacío'), 'Debe reportar error de CSV vacío');
    }

    @isTest
    static void testDoPostInvalidProforma() {
        // Preparar un CSV con una proforma que no existe
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'INVALID123;2025-11-15;New Interlocutor 1;New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;New Titular;titular@test.com;interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
        System.assertEquals(0, response[0].Actualizados, 'No deben actualizarse oportunidades');
        System.assertEquals(1, response[0].Proformas_con_error.size(), 'Debe haber 1 proforma con error');
        System.assertEquals('INVALID123 - No existe en Salesforce', response[0].Proformas_con_error[0].proforma, 'La proforma con error debe ser INVALID123');
    }

    @isTest
    static void testDoPostInterlocutorTooLong() {
        // Preparar un CSV con un interlocutor que excede los 50 caracteres
        String longInterlocutor = 'This is a very long interlocutor name that exceeds the fifty character limit';
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'PROF123;2025-11-15;' + longInterlocutor + ';New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;New Titular;titular@test.com;interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
        System.assert(response[0].Error.contains('excede 50 caracteres'), 'Debe reportar error de interlocutor largo');
    }

    @isTest
    static void testDoPostTitularTooLong() {
        // Preparar un CSV con un titular que excede los 255 caracteres
        String longTitular = 'This is a very long titular name that exceeds the 255 character limit. ' +
                            'This is a very long titular name that exceeds the 255 character limit. ' +
                            'This is a very long titular name that exceeds the 255 character limit. ' +
                            'This is a very long titular name that exceeds the 255 character limit.';
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'PROF123;2025-11-15;New Interlocutor 1;New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;' + longTitular + ';titular@test.com;interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
        System.assert(response[0].Error.contains('excede 255 caracteres'), 'Debe reportar error de titular largo');
    }

    @isTest
    static void testDoPostInvalidEmail() {
        // Preparar un CSV con un email inválido
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'PROF123;2025-11-15;New Interlocutor 1;New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;New Titular;invalid-email;interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
        System.assert(response[0].Error.contains('no es un email válido'), 'Debe reportar error de email inválido');
    }

    @isTest
    static void testDoPostEmailTooLong() {
        // Preparar un CSV con un email que excede los 80 caracteres
        String longEmail = 'thisisaverylongemailaddressthatexceedstheeightycharacterlimit@domain.com';
        String csvBody = 'CEN_Proforma__c;CEN_Fecha_Entrega_Lote__c;CEN_INTERLOCUTOR_1__c;CEN_INTERLOCUTOR_2__c;CEN_INTERLOCUTOR_3__c;CEN_INTERLOCUTOR_4__c;CEN_INTERLOCUTOR_5__c;CEN_INTERLOCUTOR_6__c;CEN_INTERLOCUTOR_7__c;CEN_INTERLOCUTOR_8__c;CEN_INTERLOCUTOR_9__c;CEN_INTERLOCUTOR_10__c;CEN_TITULAR__c;CEN_TITULAR_EMAIL__c;CEN_INTERLOCUTOR_1_EMAIL__c;CEN_INTERLOCUTOR_2_EMAIL__c;CEN_INTERLOCUTOR_3_EMAIL__c;CEN_INTERLOCUTOR_4_EMAIL__c;CEN_INTERLOCUTOR_5_EMAIL__c;CEN_INTERLOCUTOR_6_EMAIL__c;CEN_INTERLOCUTOR_7_EMAIL__c;CEN_INTERLOCUTOR_8_EMAIL__c;CEN_INTERLOCUTOR_9_EMAIL__c;CEN_INTERLOCUTOR_10_EMAIL__c\r\n' +
                         'PROF123;2025-11-15;New Interlocutor 1;New Interlocutor 2;New Interlocutor 3;New Interlocutor 4;New Interlocutor 5;New Interlocutor 6;New Interlocutor 7;New Interlocutor 8;New Interlocutor 9;New Interlocutor 10;New Titular;' + longEmail + ';interlocutor1@test.com;interlocutor2@test.com;interlocutor3@test.com;interlocutor4@test.com;interlocutor5@test.com;interlocutor6@test.com;interlocutor7@test.com;interlocutor8@test.com;interlocutor9@test.com;interlocutor10@test.com';

        // Configurar el contexto REST
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updateFechaDeEntregaOpp/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(csvBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Ejecutar el método
        Test.startTest();
        CEN_UpdateFechaDeEntregaOppService_cls.doPost();
        Test.stopTest();

        // Verificar la respuesta
        String responseBody = RestContext.response.responseBody.toString();
        List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap> response = (List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>) JSON.deserialize(responseBody, List<CEN_UpdateFechaDeEntregaOppService_cls.ResponseWrap>.class);
        
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado debe ser 200');
        System.assertEquals('ERROR', response[0].Estado, 'El estado debe ser ERROR');
    }

    
}