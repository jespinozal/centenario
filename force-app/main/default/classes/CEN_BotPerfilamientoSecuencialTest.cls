/**
 * @name               : CEN_BotPerfilamientoSecuencialTest
 * @author             : Jhanluck Onofre
 * @creation date      : 04/11/2024
 * @modification date  : 04/11/2024
 * @last modified by   : Jhanluck Onofre
**/
@IsTest
public class CEN_BotPerfilamientoSecuencialTest {

    @IsTest
    static void testPromotionalOnly() {
        CEN_MatrizPerfilamiento__c project1 = new CEN_MatrizPerfilamiento__c(
            CEN_CampanaPromocional__c = true,
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId(),
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS'
        );
        insert project1;

        CEN_BotInfoMatrizPerfilamientoSecuencial.Request req = new CEN_BotInfoMatrizPerfilamientoSecuencial.Request();
        req.promotional = true;
        
        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> requestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>{ req };
        
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> response = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(requestList);
        
        System.assertNotEquals(null, response);
        System.assertEquals(1, response[0].size());
        System.assertEquals('La Planicie - Carabayllo, Lima', response[0][0].nombreProyecto);
    }

    @IsTest
    static void testRegionOnly() {
        CEN_MatrizPerfilamiento__c project2 = new CEN_MatrizPerfilamiento__c(
            CEN_Region__c = 'Lima',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId(),
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS'
        );
        insert project2;

        CEN_BotInfoMatrizPerfilamientoSecuencial.Request req = new CEN_BotInfoMatrizPerfilamientoSecuencial.Request();
        req.region = 'Lima';
        
        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> requestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>{ req };
        
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> response = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(requestList);
        
        System.assertNotEquals(null, response);
        System.assertEquals(1, response[0].size());
        System.assertEquals('La Planicie - Carabayllo, Lima', response[0][0].nombreProyecto);
    }

    @IsTest
    static void testRegionAndPerfil() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_Region__c = 'Lima',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId(),
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS'
        );
        insert project3;
    
        CEN_BotInfoMatrizPerfilamientoSecuencial.Request req = new CEN_BotInfoMatrizPerfilamientoSecuencial.Request();
        req.region = 'Lima';
        req.perfil = 'Metraje';
        req.proyecto = 'La Planicie - Carabayllo, Lima';
    
        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> requestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>{ req };
        
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> response = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(requestList);
        
        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosMetraje.contains('90 m2 - 100 m2'));
    }

    @IsTest
    static void testRegionAndPerfilv2() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_Region__c = 'Lima',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId(),
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS'
        );
        insert project3;
    
        CEN_BotInfoMatrizPerfilamientoSecuencial.Request req = new CEN_BotInfoMatrizPerfilamientoSecuencial.Request();
        req.region = 'Lima';
        req.perfil = 'Cuota';
    
        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> requestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>{ req };
        
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> response = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(requestList);
        
        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosCuota.contains('S/1600 - S/2000'));
    }

    @IsTest
    static void testRegionAndPerfilv3() {
        CEN_MatrizPerfilamiento__c project3 = new CEN_MatrizPerfilamiento__c(
            CEN_Region__c = 'Lima',
            RecordTypeId = Schema.SObjectType.CEN_MatrizPerfilamiento__c.getRecordTypeInfosByDeveloperName().get('CEN_MatrizPerfilamientoProyecto').getRecordTypeId(),
            CEN_ZonaGrupo__c = 'Lima Norte - Carabayllo',
            CEN_NombreProyecto__c = 'La Planicie - Carabayllo, Lima',
            CEN_RangosCuota__c = 'S/1600 - S/2000;S/2000 - S/2500;S/2500 A MÁS',
            CEN_RangosInicial__c = 'S/9000 - S/15000;S/15000 - S/18000;S/18000 A MÁS',
            CEN_RangosMetraje__c = '90 m2 - 100 m2;100 m2 - 120 m2;120 m2 A MÁS'
        );
        insert project3;
    
        CEN_BotInfoMatrizPerfilamientoSecuencial.Request req = new CEN_BotInfoMatrizPerfilamientoSecuencial.Request();
        req.region = 'Lima';
        req.perfil = 'Inicial';
    
        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> requestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>{ req };
        
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> response = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(requestList);
        
        System.assertNotEquals(null, response);
        System.assertEquals(3, response[0].size());
        System.assert(response[0][0].rangosInicial.contains('S/9000 - S/15000'));
    }

    @IsTest
    static void testInvalidInput() {
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> responseNull = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(null);
        System.assertEquals(null, responseNull);

        List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request> emptyRequestList = new List<CEN_BotInfoMatrizPerfilamientoSecuencial.Request>();
        List<List<CEN_BotInfoMatrizPerfilamientoSecuencial.Response>> responseEmpty = CEN_BotInfoMatrizPerfilamientoSecuencial.getProjectsByFilters(emptyRequestList);
        System.assertEquals(null, responseEmpty);
    }
}