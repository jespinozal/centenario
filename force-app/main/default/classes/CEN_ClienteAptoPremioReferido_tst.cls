/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 11-20-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   07-10-2024   @nttdata.com  Initial Version
**/
@isTest
public with sharing class CEN_ClienteAptoPremioReferido_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp(){
        DateTime dt = System.now();

        /** Tabla maestra */
        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;

        /** Account */
        Account acc = new Account();
        acc.CEN_Tipo_de_documento__pc='DNI';
        acc.CEN_N_mero_de_documento__pc='43214321';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.PersonEmail='email@test.com';
        acc.CEN_Tel_fono_Trabajo__pc='987654321';
        acc.PersonMobilePhone='5555000';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc =distrito.Id;
        insert acc;

        /** Lead */
        Lead ld = new Lead();
        ld.FirstName='Clive';
        ld.LastName='Atkins';
        ld.Email='email@test.com';
        ld.CEN_Tipo_de_documento__c='DNI';
        ld.CEN_N_mero_de_documento__c='22210045';
        ld.MobilePhone='+51999999011';
        ld.CEN_Motivo__c='Otros';
        ld.CEN_Divisi_n_de_inter_s__c='Lotes de vivienda';
        ld.CEN_Tema_de_inter_s__c='Quiero comprar un lote';
        ld.CEN_Donde_comprar__c='PROV_Trujillo_LU';
        ld.CEN_Elige_donde_vivir__c='Trujillo - Urbanización Altos del Valle';
        ld.CEN_T_rminos_y_condiciones__c=true;
        ld.LeadSource='Referidos';
        ld.CEN_Web__c=null;
        ld.CEN_Medio__c='0013';
        ld.CEN_Formulario__c='Lead Generation';
        ld.OwnerId='0054T000000Gvs5QAC';
        ld.CEN_utm_source__c='FBIG';
        ld.CEN_utm_medium__c='GN~RMKT-ALTOS-DEL-VALLE_GM~FBIG_GG~P_GE~25-60_GT~RTG';
        ld.CEN_utm_term__c='';
        ld.CEN_utm_content__c='AN~PPL-2-01ABR23-ALTOS-DEL-VALLE_AC~DISPLAY_AF~SPOST_AV~1_AL~NA';
        ld.CEN_utm_campaign__c='CB~CEN_CS~PRIMERA-VIVIENDA_CC~AON-PERFORMANCE_CO~CONV_CE~LDS_CM~FBIG_CV~TRUJILLO_CP~ALTOS-DEL-VALLE';
        ld.CEN_Rubro__c=null;
        ld.Company=null;
        ld.CEN_ClientID__c=null;
        ld.CEN_campaign_id__c='23848107687020011';
        ld.CEN_StatusMobilePhone__c='No completado';
        ld.CEN_StatusEmail__c='Por validar';
        ld.CEN_AceptoEnvioPublicidad__c=false;
        ld.CEN_AceptoPerfilamiento__c=false;
        ld.CEN_DateTimeCheckServed__c = dt;
        ld.CEN_StartDateContact__c= dt.date();
        ld.CEN_EndDateContact__c= dt.date();
        ld.CEN_StartTimeContact__c=dt.time();
        ld.CEN_EndTimeContact__c=dt.time();
        ld.CEN_EmailOwner__c='';
        ld.CEN_Referido__c=true;
        ld.CEN_NumeroDocumentoReferente__c='43214321';
        ld.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CEN_Urbano').getRecordTypeId();
        insert ld;

        /** Protecto__c */
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;

        /** Product2 */
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_IdLotSAP__c = '00000073';
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        update prod2s ;

        /** Opportunity */
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_Proforma__c = '00001';
        opps[0].AccountId = acc.Id;
        insert opps;

        // Opportunity opp=new Opportunity(AccountId=acc.Id, StageName='Oportunidad Ganada', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today());
        // insert opp;

        /** Case */
        Case caso = new Case();
        caso.Subject='Programa de Referidos: Clive Atkins';
        caso.Origin='Referidos';
        List<User> gestores = [SELECT Id FROM User WHERE profile.Name = 'CEN_GestorReferidos' AND IsActive = true];
        caso.OwnerId=gestores[0].Id;
        caso.CEN_nombre_actualizado__c='Clive';
        caso.CEN_apellido_actualizado__c='Atkins';
        caso.CEN_Tipo_de_documento__c='DNI';
        caso.N_mero_de_documento__c='22210045';
        caso.CEN_Bonificacion__c=1000;
        caso.LeadId__c=ld.Id;
        caso.Account__c =acc.Id;
        //caso.opportunity__c =opps[0].Id;
        //caso.opportunity__c =opp.Id;
        caso.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEN_InteraccionReferido').getRecordTypeId();
        insert caso;
    }

    @IsTest
    static void callClienteAptoPremio_success(){
        String documentoReferido = '80000008';
        String documentoReferente = '80000007';

        Test.startTest();
        CEN_ClienteAptoPremioReferido_tst.respType = 'success';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        //CEN_ClienteAptoPremioReferido_ctr.ActualizarDatosReferidoCasoAsync(documentoReferido,documentoReferente);
        CEN_ReferidoParse_cls pr = new CEN_ReferidoParse_cls();
        pr.parseRequest('Vacio');
        //System.assert(data.get('data') != null);
        Test.stopTest();
    }

    @IsTest
    static void notification_success(){
        Test.startTest();
        Opportunity opp = [SELECT Id,StageName,CEN_Oficina_de_Venta__c FROM Opportunity LIMIT 1];
        opp.CEN_Oficina_de_Venta__c = 'ZV031';
        opp.StageName = 'Oportunidad Ganada';
        update opp;
        System.debug('opp-test: ' + opp);
        Id idCase = [SELECT Id FROM Case LIMIT 1]?.Id;
        Case caso = [SELECT id,CEN_Bonificacion__c,Account__c,LeadId__c,opportunity__c,opportunity__r.stageName FROM Case WHERE Id =: idCase];
        caso.opportunity__c = opp.Id;
        update caso;
        System.debug('caso-test: ' + caso);

        List<CEN_NotificationReferidos_ctr.Requests> requestList = new List<CEN_NotificationReferidos_ctr.Requests>();
        CEN_NotificationReferidos_ctr.Requests request = new CEN_NotificationReferidos_ctr.Requests();
        request.recordId = idCase;
        //request.title = 'Salesforce';
        //request.message = 'Hola Mundo';
        request.addresses = new List<String>{'soportesf@nttdata.com'};
        request.emailNotification = 'CEN_RegistroCompletadoReferido';
        requestList.add(request);
        CEN_NotificationReferidos_ctr.notificationReferido(requestList);
        Test.stopTest();
    }


    @IsTest
    static void callClienteAptoPremioLWC_success(){
        Id recordId = [SELECT Id,Account.CEN_N_mero_de_documento__pc,Account.CEN_Numero_de_documento_del__c,N_mero_de_documento__c FROM Case LIMIT 1]?.Id;
        Test.startTest();
        CEN_ClienteAptoPremioReferido_tst.respType = 'success';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_ReferidoResponse respData = CEN_ClienteAptoPremioReferido_ctr.ActualizarDatosReferidoCasoLWC(recordId);
        System.assert(respData.data.size() > 0);
        System.assertEquals('Se encontraron datos', respData.mensaje);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_ClienteAptoPremioReferido_tst.respType.equals('success')) {
                String result = '{"mensaje":"Se encontraron datos","data":[{"referente":"80000007","referido":"80000008","aprobado":"X","estado":"NO ACTIVO","fecCventaEnte":"0000-00-00","precioVentaEnte":190042.10,"ciudadEnte":"CAÑETE","proformaEnte":58199,"deudaEnte":5,"fechaArrasEnte":"2023-08-14","resueltoEnte":"X","observacionEnte":"Con Resolución","fecCventaIdo":"2023-08-15","precioVentaIdo":190042.10,"ciudadIdo":"CAÑETE","proformaIdo":58200,"fechaArrasIdo":"0000-00-00","observacionIdo":"Cantidad Ventas 1"}]}';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (CEN_ClienteAptoPremioReferido_tst.respType.equals('noData'))  {
                String result = '{"mensaje":"El cliente 80000009 no tiene ventas cerradas","data":[]}';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (CEN_ClienteAptoPremioReferido_tst.respType.equals('requerid'))  {
                String result = '{"mensaje":"Campos Referente/Referido son obligatorios","data":[]}';
                res.setBody(result);
                res.setStatusCode(200);
            }
            return res;
        }
    }
}