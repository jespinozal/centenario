/**
 * @name               : CEN_PerfilamientoRecomendadorTest
 * @author             : Jhanluck Onofre
 * @creation date      : 04/11/2024
 * @modification date  : 04/11/2024
 * @last modified by   : Jhanluck Onofre
**/
@IsTest
public class CEN_PerfilamientoRecomendadorTest {

    @IsTest
    static void testCuotaAndZona() {
        CEN_MatrizPerfilamiento__c project1 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'Proyecto A',
            CEN_CuotaMinima__c = '1800',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project1;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.cuotaRango = 'S/1600 - S/2000';
        req.zona = 'Lima Norte - Carabayllo';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(1, response[0].size());
        System.assertEquals('Proyecto A', response[0][0].nombreProyecto);
        System.assertEquals('1800', response[0][0].rangosCuota);
    }

    @IsTest
    static void testZonaAndPerfil() {
        CEN_MatrizPerfilamiento__c project2 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 a más',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoZona').getRecordTypeId()
        );
        insert project2;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.zona = 'Lima Norte - Carabayllo';
        req.perfil = 'Metraje';
        req.proyecto = 'La Planicie - Carabayllo, Lima';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosMetraje.contains('90 m2 - 100 m2'));
    }

    @IsTest
    static void testZonaAndPerfilv2() {
        CEN_MatrizPerfilamiento__c project2 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 a más',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoZona').getRecordTypeId()
        );
        insert project2;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.zona = 'Lima Norte - Carabayllo';
        req.perfil = 'Inicial';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosInicial.contains('S/9000 - S/15000'));
    }

    @IsTest
    static void testZonaAndPerfilv3() {
        CEN_MatrizPerfilamiento__c project2 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 a más',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoZona').getRecordTypeId()
        );
        insert project2;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.zona = 'Lima Norte - Carabayllo';
        req.perfil = 'Cuota';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosCuota.contains('S/1600 - S/2000'));
    }

    @IsTest
    static void testInvalidInput() {
        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> responseNull = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(null);
        System.assertEquals(null, responseNull);

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> emptyRequestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>();
        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> responseEmpty = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(emptyRequestList);
        System.assertEquals(null, responseEmpty);
    }

    @IsTest
    static void testZonaAndCuotaWithNoMatch() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'Proyecto C',
            CEN_CuotaMinima__c = '3000',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.cuotaRango = 'S/1600 - S/2000';
        req.zona = 'Lima Norte - Carabaylloo';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(0, response[0].size());
    }

    @IsTest
    static void testZonaAndCuotaWithNoMatch1() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'Proyecto C',
            CEN_CuotaMinima__c = '3000',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.cuotaRango = 'Menor a S/1400';
        req.zona = 'Lima Norte - Carabaylloo';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(0, response[0].size());
    }

    @IsTest
    static void testZonaAndCuotaWithNoMatch2() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'Proyecto C',
            CEN_CuotaMinima__c = '3000',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotIMatrizPerfilamientoRecomendador.Request req = new CEN_BotIMatrizPerfilamientoRecomendador.Request();
        req.cuotaRango = 'S/2500 a más';
        req.zona = 'Lima Norte - Carabayllo';

        List<CEN_BotIMatrizPerfilamientoRecomendador.Request> requestList = new List<CEN_BotIMatrizPerfilamientoRecomendador.Request>{ req };

        List<List<CEN_BotIMatrizPerfilamientoRecomendador.Response>> response = CEN_BotIMatrizPerfilamientoRecomendador.getRecommendedProjectsByFilters(requestList);

        System.assertNotEquals(null, response);
        System.assertEquals(1, response[0].size());
    }
}