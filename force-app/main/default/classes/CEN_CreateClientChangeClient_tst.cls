/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-08-04 
* @description: Clase test call Api SAP - Crear Cliente desde
*               transferencia de titularidad. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-08-04           Alan Alvarez            Creación 
*  
*********************************************************************/
@isTest
public class CEN_CreateClientChangeClient_tst {
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
        
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;
        
        //---- PRODUCT2
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_IdLotSAP__c = '00000073';
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        update prod2s ;
        
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
        acc2.CEN_N_mero_de_documento__pc='50607080';
        acc2.LastName='Perez';
        acc2.FirstName='Roberto';
        acc2.PersonEmail='Roberto@everis.com';
        acc2.CEN_Tel_fono_Trabajo__pc='987654444';
        acc2.PersonMobilePhone='5555666';
        acc2.CEN_Direccion__pc='Calle San Lorenzo';
        acc2.CEN_fld_Tiene_apoderado__c = true;
        acc2.CEN_fld_Nombres_Apoderado__c = 'Roberto';
        acc2.CEN_fld_Apellidos_apoderado__c = 'Grau Seminario';
        acc2.CEN_fld_Apellido_mat_apoderado__c = 'Grau';
        acc2.CEN_fld_Tipo_de_documento_de_apoderado__c = 'DNI';
        acc2.CEN_fld_Numero_de_documento_apoderado__c = '55668745';
        acc2.CEN_fld_Nacionalidad_apoderado__c = 'PE';
        acc2.CEN_fld_Numero_de_partida_registral__c = '123456789';
        acc2.CEN_fld_Direccion_apoderado__c = 'Calle San Lorenzo';
        acc2.CEN_Tipo_poder__c = 'RP';
        acc2.CEN_Fecha_de_Nacimiento__c = Date.valueOf('1990-01-01');
        acc2.CEN_Tel_fono_Trabajo__pc = '987654444';
        acc2.CEN_Promedio_Mensual_Ingresos__pc = 1000;
        acc2.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc2.CEN_Distrito__pc =distrito.Id;
        insert acc2;
        
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;
        
        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_Proforma__c = '00001';
        opps[0].AccountId = acc.Id;
        insert opps;
        
        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
        oppItem.TotalPrice = 1000;
        insert oppItem;
        
    }
    
    @IsTest 
    static void callCreateClient_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String accId = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc='50607080'].Id;
        List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient> parameterList = new List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient>();
        CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient parameter = new CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient();
        parameter.oppId = oppId;
        parameter.newClientAccount = accId;
        parameter.society = '0010';
        System.debug(':::::::');
        System.debug(parameter);
        parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClientChangeClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClientChangeClient_ctr.processCreateClientChangeOwnership(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientCompany_test(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id From Account WHERE CEN_N_mero_de_documento__pc='50607080'];
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
        update acc;
        List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient> parameterList = new List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient>();
        CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient parameter = new CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient();
        parameter.oppId = opp.Id;
        parameter.newClientAccount = acc.Id;
        parameter.society = '0010';
        parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClientChangeClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClientChangeClient_ctr.processCreateClientChangeOwnership(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientWarning_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String accId = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc='50607080'].Id;
        List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient> parameterList = new List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient>();
        CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient parameter = new CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient();
        parameter.oppId = oppId;
        parameter.newClientAccount = accId;
        parameter.society = '0010';
        parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClientChangeClient_tst.respType = 'warning';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClientChangeClient_ctr.processCreateClientChangeOwnership(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientrError_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String accId = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc='50607080'].Id;
        List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient> parameterList = new List<CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient>();
        CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient parameter = new CEN_CreateClientChangeClient_ctr.FlowParametersCreateClientChangeClient();
        parameter.oppId = oppId;
        parameter.newClientAccount = accId;
        parameter.society = '0010';
        parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClientChangeClient_tst.respType = '';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClientChangeClient_ctr.processCreateClientChangeOwnership(parameterList);
        Test.stopTest();
    }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_CreateClientChangeClient_tst.respType.equals('ok')) {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_CREAR_CLIENTES_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_CLIENTE>';
                result += '<item>';
                result += '<TIPO_DOC>DNI</TIPO_DOC>';
                result += '<STCD1>55668745</STCD1>';
                result += '<KUNNR>0055668745</KUNNR>';
                result += '<NAME>GRAU SEMINARIO MIGUEL</NAME>';
                result += '</item>';
                result += '</ET_CLIENTE>';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>S</TYPE>';
                result += '<ID>F2</ID>';
                result += '<NUMBER>174</NUMBER>';
                result += '<MESSAGE>El deudor 0055668745 se ha creado para sociedad 0010 y área de ventas 0100 10 10</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>0055668745</MESSAGE_V1>';
                result += '<MESSAGE_V2>0010</MESSAGE_V2>';
                result += '<MESSAGE_V3>0100 10 10</MESSAGE_V3>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM/>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '</n0:ZRFC_OTC_CREAR_CLIENTES_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (CEN_CreateClientChangeClient_tst.respType.equals('warning'))  {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_CREAR_CLIENTES_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_CLIENTE>';
                result += '<item>';
                result += '<TIPO_DOC>DNI</TIPO_DOC>';
                result += '<STCD1>55668745</STCD1>';
                result += '<KUNNR/>';
                result += '<NAME>GRAU SEMINARIO MIGUEL</NAME>';
                result += '</item>';
                result += '</ET_CLIENTE>';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>E</TYPE>';
                result += '<ID>F2</ID>';
                result += '<NUMBER>155</NUMBER>';
                result += '<MESSAGE>El deudor 55668745 ya se ha creado para sociedad 0010 área de ventas 0100 10 10</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>55668745</MESSAGE_V1>';
                result += '<MESSAGE_V2>0010</MESSAGE_V2>';
                result += '<MESSAGE_V3>0100 10 10</MESSAGE_V3>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM/>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '</n0:ZRFC_OTC_CREAR_CLIENTES_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    }    
}