/**
 * @name               : CEN_BotObtenerDatosMatriz_Test
 * @description        : Prueba unitaria para la clase CEN_BotObtenerDatosMatriz
 * @creation date      : 05/11/2024
 * @modification date  : 05/11/2024
 * @last modified by   : Jhanluck Onofre
**/
@IsTest
public class CEN_BotObtenerDatosMatriz_Test {

    @IsTest
    static void testGetProjectsByFilters_OnlyOption() {
        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.option = new CEN_BotIMatrizPerfilamientoRecomendador.Response();
        request.option.name = 'Test Option Name';
        request.option.nombreProyecto = 'La Planicie - Carabayllo, Lima';
        request.option.zona = 'Lima Norte - Carabayllo';
        request.option.rangosCuota = 'S/1600 - S/2000';
        request.option.rangosInicial = 'S/9000 - S/15000';
        request.option.rangosMetraje = '90 m2 - 100 m2';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Test Option Name', result[0].name);
    }

    @IsTest
    static void testGetProjectsByFilters_WithZonaAndCuotaZero() {
        CEN_MatrizPerfilamiento__c project1 = new CEN_MatrizPerfilamiento__c(
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_Region__c = 'Lima',
            CEN_MetrajeMinimo__c = '90 m2',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project1;

        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.zona = 'Lima Norte - Carabayllo';
        request.metrajeRango = '90 - 120';
        request.cuotaRango = '0';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('La Planicie - Carabayllo, Lima', result[0].nombreProyecto);
    }

    @IsTest
    static void testGetProjectsByFilters_WithZonaCuotaAndMetraje() {
        CEN_MatrizPerfilamiento__c project2 = new CEN_MatrizPerfilamiento__c(
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_CuotaMinima__c = '1800',
            CEN_Region__c = 'Lima',
            CEN_MetrajeMinimo__c = '100 m2',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project2;

        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.zona = 'Lima Norte - Carabayllo';
        request.metrajeRango = '90-120';
        request.cuotaRango = '1600-2000';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('La Planicie - Carabayllo, Lima', result[0].nombreProyecto);
    }

    @IsTest
    static void testGetProjectsByFilters_WithZonaAndPerfil() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_Region__c = 'Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.zona = 'Lima Norte - Carabayllo';
        request.perfil = 'Cuota';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(4, result.size());
        System.assertEquals('La Planicie - Carabayllo, Lima', result[0].nombreProyecto);

    }
    
    @IsTest
    static void testGetProjectsByFilters_WithZonaAndPerfilv2() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_Region__c = 'Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.zona = 'Lima Norte - Carabayllo';
        request.perfil = 'Metraje';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(4, result.size());
        System.assertEquals('La Planicie - Carabayllo, Lima', result[0].nombreProyecto);

    }
    
    @IsTest
    static void testGetProjectsByFilters_WithZonaAndPerfilv3() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_Region__c = 'Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId()
        );
        insert project3;

        CEN_BotObtenerDatosMatriz.Request request = new CEN_BotObtenerDatosMatriz.Request();
        request.zona = 'Lima Norte - Carabayllo';
        request.perfil = 'Inicial';

        List<CEN_BotObtenerDatosMatriz.Request> requests = new List<CEN_BotObtenerDatosMatriz.Request>{ request };

        List<CEN_BotObtenerDatosMatriz.Response> result = CEN_BotObtenerDatosMatriz.getProjectsByFilters(requests);

        System.assertNotEquals(null, result);
        System.assertEquals(4, result.size());
        System.assertEquals('La Planicie - Carabayllo, Lima', result[0].nombreProyecto);

    }

    @IsTest
    static void testInvalidInput() {
        List<CEN_BotObtenerDatosMatriz.Response> resultNull = CEN_BotObtenerDatosMatriz.getProjectsByFilters(null);
        System.assertEquals(null, resultNull);

        List<CEN_BotObtenerDatosMatriz.Request> emptyRequests = new List<CEN_BotObtenerDatosMatriz.Request>();
        List<CEN_BotObtenerDatosMatriz.Response> resultEmpty = CEN_BotObtenerDatosMatriz.getProjectsByFilters(emptyRequests);
        System.assertEquals(null, resultEmpty);
    }
}