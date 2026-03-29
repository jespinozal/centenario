/**
 * @description       : Clase test de CEN_LotesFinanciamientoCasos
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-20-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Ayleen Salcedo - Se agregó el método testGetCamposProyectoFin - 13/03/2026
**/
@isTest
public with sharing class CEN_LotesFinanciamientoCasos_test {

    @TestSetup
    static void makeData(){
        // Crear Proyecto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto Test',
            CEN_CODIGOSAP__c = '19U1.293E',
            CEN_Tipo_de_proyecto__c = 'Urbano',
            CEN_Sociedad__c = '0019',
            CEN_Estado_proyecto__c = 'Independizado',
            CEN_Estado_Servicio_Agua_Alcantarillado__c = 'Con recepción de redes de agua y alcantarillado',
            CEN_Proveedor_servicio_agua__c = 'EMAPICA',
            CEN_Estado_Servicio_Energia_Electrica__c = 'Con recepción de redes eléctricas',
            CEN_Proveedor_servicio_energa_electrica__c = 'LUZ DEL SUR'
        );
        insert proyecto;

        // Crear Account
        Account acc = new Account(
            Name = 'Test Account',
            CEN_Numero_de_documento_del__c = '87654321'
        );
        insert acc;

        // Crear Case
        Case testCase = new Case(
            AccountId = acc.Id,
            CEN_Lotes_asignados__c = '840037564',
            CEN_CodigoDeLotes__c = '840037564',
            CEN_CodFinanciamiento__c = '59530'
        );
        insert testCase;

        // Crear Opportunity relacionada con Proyecto y Proforma
        Opportunity opp = new Opportunity(
            Name = 'Opp Test',
            StageName = 'Cotización',
            CloseDate = Date.today().addDays(30),
            CEN_Proforma__c = '0000059530',
            CEN_Proyecto__c = proyecto.Id
        );
        insert opp;
    }

    // Mock response from the callout
    private class MockFinanciamientoLotesCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"financiamientos":[{"proforma":59530,"version":1,"bukrs":"0019","processo":"19U1.902E","estadoFinanciamiento":"A","urbanizacion":"INDRA ETAPA 1","lotes":[{"idLoteSap":872,"codLote":"000000000840037564","valor":185714.00,"estadoLote":"E","subestadoLote":"NI","manzana":"XY","lote":"24"}]}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetLotesFinanciamientos() {
        Test.startTest();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockFinanciamientoLotesCallout());
        CEN_LotesFinanciamientoCasosApi result = CEN_LotesFinanciamientoCasos.getLotesFinanciamientos(testCase.Id);
        Test.stopTest();

        System.assertEquals(1, result.financiamientos.size());
        System.assertEquals(59530, result.financiamientos[0].proforma);
        System.assertEquals('Activo', result.financiamientos[0].estadoFinanciamientoFormateado);
    }

    @isTest
    static void testSaveFinanciamientoLotes() {
        Test.startTest();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String financiamiento = '{"proforma":59530,"version":1,"bukrs":"0019","processo":"19U1.902E","estadoFinanciamiento":"A","urbanizacion":"INDRA ETAPA 1"}';
        String lotes = '[{"idLoteSap":872,"codLote":"000000000840037564","valor":185714.00,"estadoLote":"E","subestadoLote":"NI","manzana":"XY","lote":"24"}]';
        CEN_LotesFinanciamientoCasos.saveFinanciamientoLotes(financiamiento, lotes, testCase.Id);
        Case updatedCase = [SELECT CEN_CodFinanciamiento__c, CEN_VersionFinanciamiento__c, CEN_Lotes_asignados__c, CEN_CodigoDeLotes__c FROM Case WHERE Id = :testCase.Id];
        Test.stopTest();

        System.assertEquals('59530', updatedCase.CEN_CodFinanciamiento__c);
        System.assertEquals('1', updatedCase.CEN_VersionFinanciamiento__c);
    }

    @isTest
    static void testgetFinanciamientoLotesInicial(){
        Test.startTest();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CEN_LotesFinanciamientoCasosApi lotes = CEN_LotesFinanciamientoCasos.getFinanciamientoLotesInicial(testCase.Id);
        Test.stopTest();

        System.assertEquals(1, lotes.financiamientos.size());
    }

    @isTest
    static void testgetTipoDeRegistroDeveloper(){
        Test.startTest();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String recordType = CEN_LotesFinanciamientoCasos.getTipoDeRegistroDeveloper(testCase.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetCamposProyectoFin() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        String resultado = CEN_LotesFinanciamientoCasos.getCamposProyectoFin('59530', testCase.Id);
        Test.stopTest();

        System.assertEquals('Independizado', resultado);

        Case updatedCase = [SELECT CEN_Estado_del_proyecto__c, 
                                    CEN_Estado_servicio_agua__c, 
                                    CEN_Proveedor_servicio_agua__c,
                                    CEN_Estado_servicio_energia__c, 
                                    CEN_Proveedor_servicio_energia__c
                            FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Independizado', updatedCase.CEN_Estado_del_proyecto__c);
        System.assertEquals('Con recepción de redes de agua y alcantarillado', updatedCase.CEN_Estado_servicio_agua__c);
        System.assertEquals('EMAPICA', updatedCase.CEN_Proveedor_servicio_agua__c);
        System.assertEquals('Con recepción de redes eléctricas', updatedCase.CEN_Estado_servicio_energia__c);
        System.assertEquals('LUZ DEL SUR', updatedCase.CEN_Proveedor_servicio_energia__c);
    }
}