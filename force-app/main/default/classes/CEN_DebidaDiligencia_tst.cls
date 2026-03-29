/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 09-10-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   09-10-2023   @nttdata.com  Initial Version
**/
@isTest
public with sharing class CEN_DebidaDiligencia_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp(){

        //--- TABLA MAESTRA
        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;

        //---- ACCOUNTS
        Account acc = new Account();
        acc.CEN_Tipo_de_documento__pc='DNI';
        acc.CEN_N_mero_de_documento__pc='10203040';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.PersonEmail='juan@everis.com';
        acc.CEN_Tel_fono_Trabajo__pc='987654321';
        acc.PersonMobilePhone='5555000';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc =distrito.Id;
        insert acc;

        Account acc2 = new Account();
        acc2.CEN_Tipo_de_documento__pc='DNI';
        acc2.CEN_N_mero_de_documento__pc='10203041';
        acc2.LastName='Maradona';
        acc2.FirstName='Diego';
        acc2.PersonEmail='diego@everis.com';
        acc2.CEN_Tel_fono_Trabajo__pc='984160461';
        acc2.PersonMobilePhone='5555001';
        acc2.CEN_Direccion__pc='Calle Aguirre';
        acc2.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc2.CEN_Distrito__pc =distrito.Id;
        insert acc2;

        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_Proforma__c = '00001';
        opps[0].AccountId = acc.Id;
        insert opps;

    }

    @IsTest static void sendDebidaDiligencia_Success(){

        Test.startTest();
        Id idOpportunity = [SELECT Id FROM Opportunity LIMIT 1]?.Id;
		List<CEN_DebidaDiligencia_ctr.FlowParameters> requestList = new List<CEN_DebidaDiligencia_ctr.FlowParameters>();
        CEN_NotificationSMSResponse response = new CEN_NotificationSMSResponse();
        CEN_DebidaDiligencia_ctr.FlowParameters request = new CEN_DebidaDiligencia_ctr.FlowParameters();
        request.idOpportunity = idOpportunity;
        request.firstName = 'Ollanta';
        request.lastName = 'Humala Tasso';
        request.numberDocument = '10002345';
        requestList.add(request);

        CEN_DebidaDiligencia_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());

        List<String> result = CEN_DebidaDiligencia_ctr.procesoDebidaDiligencia(requestList);

        //response.success = true;
        //response.message = '';
        //system.debug('response: '+ result);
        Test.stopTest();
    }

    @IsTest static void generateToken_Success(){

        Test.startTest();
        Id idOpportunity = [SELECT Id FROM Opportunity LIMIT 1]?.Id;
		CEN_TokenRequest req = new CEN_TokenRequest();
        req.username = 'localhost'; //label
        req.password = '81gE6gLb7HFCGdcc3MbeACUnp1NWnMpuVyuD0MIuvgM';

        CEN_DebidaDiligencia_tst.respType = 'token';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        String result = CEN_DebidaDiligencia_cls.getToken(req);
        String banner = CEN_DebidaDiligencia_ctr.getBannerDetail(idOpportunity);

        Test.stopTest();
    }

    @IsTest static void processPartner_Success(){

        Test.startTest();
        CEN_PartnerHelper_ctr.getPartnerRole();

        Id idOpportunity = [SELECT Id FROM Opportunity LIMIT 1]?.Id;
        Id idAccount = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc = '10203041']?.Id;
        List<Partner> partnerList = new List<Partner>{new Partner(opportunityId = idOpportunity, accountToId = idAccount, role = 'Hermano', isPrimary = false)};
        CEN_PartnerHelper_ctr.savePartners(partnerList);
        CEN_PartnerHelper_ctr.getPartner(idOpportunity);
        CEN_PartnerHelper_ctr.deletePartner(idAccount);

        CEN_DebidaDiligenciaParse_cls pr = new CEN_DebidaDiligenciaParse_cls();
        pr.parseRequest('Vacio');
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_DebidaDiligencia_tst.respType.equals('ok')) {
                res.setBody('[ { "datetime": "31/10/2023 11:14:50", "second_keyword": "", "first_keyword": "Ollanta Humala Tasso", "exists_results": true, "results": [ { "link": "https://es.wikipedia.org/wiki/Ollanta_Humala", "title": "Ollanta Humala - Wikipedia, la enciclopedia libre", "description": "... Ollanta Humala Tasso habría sido uno de los receptores de dinero enviado presuntamente por el gobierno de Venezuela para financiar ilegalmente movimientos ..." } ], "system": "SF01", "dni_ce": "10002345", "opportunity": "006Em0000065PjtIAE", "user": "UsuarioSF", "identifier": null, "fiscal_number": null, "role": null, "entity_type": "N", "supplier_origin": null, "exception_message": null }, { "datetime": "31/10/2023 11:14:52", "second_keyword": "corrupción", "first_keyword": "Ollanta Humala Tasso", "exists_results": true, "results": [ { "link": "https://actualidadpenal.pe/revista/edicion/actualidad-penal-83/el-delito-de-corrupcion-del-testigo-ollanta-humala-tasso-y-caso-madre-mia", "title": "El delito de corrupción del testigo: Ollanta Humala Tasso y caso ...", "description": "El delito de corrupción del testigo: Ollanta Humala Tasso y caso Madre Mía. Audio. Sumario. 1. Introducción. - 2. Planteamiento.- 2.1. Los fundamentos fácticos ..." } ], "system": "SF01", "dni_ce": "10002345", "opportunity": "006Em0000065PjtIAE", "user": "UsuarioSF", "identifier": null, "fiscal_number": null, "role": null, "entity_type": "N", "supplier_origin": null, "exception_message": null }, { "datetime": "31/10/2023 11:14:52", "second_keyword": "lavado de activos", "first_keyword": "Ollanta Humala Tasso", "exists_results": true, "results": [ { "link": "https://elpais.com/internacional/2019/05/08/america/1557281664_481749.html", "title": "La Fiscalía peruana pide 20 años de prisión para el expresidente ...", "description": "May 7, 2019 ... La Fiscalía peruana pide 20 años de prisión para el expresidente Ollanta Humala por lavado de activos ... Ollanta Humala Tasso · Caso Odebrecht ..." } ], "system": "SF01", "dni_ce": "10002345", "opportunity": "006Em0000065PjtIAE", "user": "UsuarioSF", "identifier": null, "fiscal_number": null, "role": null, "entity_type": "N", "supplier_origin": null, "exception_message": null }, { "datetime": "31/10/2023 11:14:53", "second_keyword": "terrorismo", "first_keyword": "Ollanta Humala Tasso", "exists_results": true, "results": [ { "link": "https://elpais.com/internacional/2012/09/12/actualidad/1347484650_581322.html", "title": "Humala: “La lucha contra el terrorismo no pertenece al pasado ...", "description": "Sep 12, 2012 ... Humala: “La lucha contra el terrorismo no pertenece al pasado”. A 20 ... Ollanta Humala Tasso · Sendero Luminoso · Alberto Fujimori ..." } ], "system": "SF01", "dni_ce": "10002345", "opportunity": "006Em0000065PjtIAE", "user": "UsuarioSF", "identifier": null, "fiscal_number": null, "role": null, "entity_type": "N", "supplier_origin": null, "exception_message": null } ]');
                res.setStatusCode(200);
            }
            else if (CEN_DebidaDiligencia_tst.respType.equals('token'))  {
                res.setBody('{"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTk1NTkyODUsImlhdCI6MTY5OTU1NzQ4NSwic3ViIjoibG9jYWxob3N0In0.Oz4N408riKAbindKRIcsejJB5nhgA4ORW9OTHzVc8sk"}');
                res.setStatusCode(200);
            }
            else if (CEN_DebidaDiligencia_tst.respType.equals('error'))  {
                res.setBody('{ "errors": { "entity_type": "Is invalid" } }');
                res.setStatusCode(500);
            }
            return res;
        }
    }

}