/**
 * @name               : CEN_BotObtenerGestionCurso_Test
 * @author             : Jhanluck Onofre
 * @creation date      : 04/11/2024
 * @modification date  : 08-11-2024
 * @last modified by   : Diego Bravo
**/
@IsTest
public with sharing class CEN_BotObtenerGestionCurso_Test {

    @testSetup
    private static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> usuarios = CEN_cls_Test_Ventas_DF.getUsers();
        System.runAs(thisUser) {
      	insert usuarios;
    	}
        
        List<Account> cuentas = CEN_cls_TestClass_DF.getAccounts();
        cuentas[0].PersonMobilePhone = '+51123456789';
        cuentas[0].CEN_Tipo_de_documento__pc = 'DNI';
        cuentas[0].CEN_N_mero_de_documento__pc = '12345678';
        insert cuentas;

        List<Opportunity> oportunidades = CEN_cls_TestClass_DF.getOpportunities();
        oportunidades[0].AccountId = cuentas[0].Id;
        oportunidades[0].StageName = 'Cotización';
        oportunidades[0].Proyecto__c = 'Macropolis';
        insert oportunidades;

        List<Lead> leads = CEN_cls_TestClass_DF.getLeads();
        leads[0].MobilePhone = '+51555123456';
        leads[0].CEN_Tipo_de_documento__c = 'DNI';
        leads[0].CEN_N_mero_de_documento__c = '87654321';
        leads[0].OwnerId = usuarios[0].Id;
        insert leads;
    }

    @IsTest
    static void testGetOpportunityOrLeadByFilters_OnlyPhoneInOpportunity() {
        List<Account> accounts = [SELECT Id, PersonMobilePhone FROM Account WHERE PersonMobilePhone = '+51123456789' LIMIT 1];
        System.assert(!accounts.isEmpty(), 'No se encontró la cuenta esperada');
        
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId = :accounts[0].Id LIMIT 1];
        System.assert(!opportunities.isEmpty(), 'No se encontró la oportunidad esperada');

        CEN_BotObtenerGestionCurso.Request request = new CEN_BotObtenerGestionCurso.Request();
        request.numeroTelefono = '123456789';

        List<CEN_BotObtenerGestionCurso.Request> requests = new List<CEN_BotObtenerGestionCurso.Request>{ request };

        List<CEN_BotObtenerGestionCurso.Response> result = CEN_BotObtenerGestionCurso.getOpportunityOrLeadByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(opportunities[0].Id, result[0].opportunityId);
    }

    @IsTest
    static void testGetOpportunityOrLeadByFilters_WithAllFiltersInOpportunity() {
        List<Account> accounts = [SELECT Id FROM Account WHERE CEN_Tipo_de_documento__pc = 'DNI' AND CEN_N_mero_de_documento__pc = '12345678' LIMIT 1];
        System.assert(!accounts.isEmpty(), 'No se encontró la cuenta esperada');

        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE AccountId = :accounts[0].Id LIMIT 1];
        System.assert(!opportunities.isEmpty(), 'No se encontró la oportunidad esperada');

        CEN_BotObtenerGestionCurso.Request request = new CEN_BotObtenerGestionCurso.Request();
        request.numeroTelefono = '123456789';
        request.tipoDocumento = 'DNI';
        request.numeroDocumento = '12345678';
        // request.nombreProyecto = 'Condominio Finca Bonita';
        request.nombreProyecto = 'Macropolis';

        List<CEN_BotObtenerGestionCurso.Request> requests = new List<CEN_BotObtenerGestionCurso.Request>{ request };

        List<CEN_BotObtenerGestionCurso.Response> result = CEN_BotObtenerGestionCurso.getOpportunityOrLeadByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(opportunities[0].Id, result[0].opportunityId);
    }

    @IsTest
    static void testGetOpportunityOrLeadByFilters_FallbackToLead() {
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone = '+51555123456' LIMIT 1];
        System.assert(!leads.isEmpty(), 'No se encontró el lead esperado');

        CEN_BotObtenerGestionCurso.Request request = new CEN_BotObtenerGestionCurso.Request();
        request.numeroTelefono = '555123456';
        request.tipoDocumento = 'DNI';
        request.numeroDocumento = '87654321';

        List<CEN_BotObtenerGestionCurso.Request> requests = new List<CEN_BotObtenerGestionCurso.Request>{ request };

        List<CEN_BotObtenerGestionCurso.Response> result = CEN_BotObtenerGestionCurso.getOpportunityOrLeadByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(leads[0].Id, result[0].leadId);
    }

    @IsTest
    static void testGetOpportunityOrLeadByFilters_NoResults() {
        CEN_BotObtenerGestionCurso.Request request = new CEN_BotObtenerGestionCurso.Request();
        request.numeroTelefono = '111222333';
        request.tipoDocumento = 'DNI';
        request.numeroDocumento = '99999999';

        List<CEN_BotObtenerGestionCurso.Request> requests = new List<CEN_BotObtenerGestionCurso.Request>{ request };

        List<CEN_BotObtenerGestionCurso.Response> result = CEN_BotObtenerGestionCurso.getOpportunityOrLeadByFilters(requests);

        System.assertEquals(1, result.size());
    }
}