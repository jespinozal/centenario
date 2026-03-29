/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-22 
* @description: Clase de test call Api SAP - Crear Cliente. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-22           Alan Alvarez            Creación 
*  
*********************************************************************/
@isTest
public class CEN_CreateClient_tst {
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
        distrito.CEN_Codigo_distrito__c='150130';
        insert distrito;
        
        //--- TABLA MAESTRA
        Tabla_maestra__c distrito2 = new Tabla_maestra__c();
        distrito2.Name='Lima';
        distrito2.Departamento__c='Lima';
        distrito2.Provincia__c='Lima';
        distrito2.CEN_Codigo_departamento__c='16';
        distrito2.CEN_Codigo_provincia__c='1502';
        distrito2.CEN_Codigo_distrito__c='150131';
        insert distrito2;
        
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
        acc.CEN_N_mero_de_documento__pc='1020304';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.PersonEmail='juan@everis.com';
        acc.CEN_Tel_fono_Trabajo__pc='3302221';
        acc.PersonMobilePhone='5555000';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.CEN_Tipo_de_relaci_n_laboral__pc = 'Dependiente';
        acc.CEN_Fecha_de_Nacimiento__c = Date.today();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc = distrito.Id;
        acc.CEN_Distrito__c = distrito.Id;
        acc.CEN_fld_Tiene_apoderado__c = true;
        insert acc;
        
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
        
        //---- PROJECTS
        Map<String,Integer> mapProj2 = new Map<String,Integer>();
        mapProj2.put('myProj', 1);
        List<Proyecto__c> projs2 =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj2);
        for(Proyecto__c p: projs2){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs2;
        
        //---- PRODUCT2
        Map<String,Integer> mapProd3 = new Map<String,Integer>();
        mapProd3.put('urbano', 1);
        List<Product2> prod3s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd3);
        prod3s[0].CEN_IdLotSAP__c = '00000073';
        prod3s[0].CEN_Proyecto__c = projs2[0].Id;
        update prod3s ;
        
        Account acc2 = new Account();
        acc2.CEN_Tipo_de_documento__c='CAREXTRAN';
        acc2.Name = 'Luisillo';
        acc2.CEN_Telefono_Trabajo_Empresa__c='987654322';
        acc2.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
        acc2.CEN_Distrito__c = distrito2.Id;        
        insert acc2;
        
        
        //---- OPPORTUNITY
        Map<String,Integer> mapOpp2 = new Map<String,Integer>();
        mapOpp2.put('Urbano', 1);
        List<Opportunity> opps2 = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp2);
        opps2[0].Pricebook2Id = Test.getStandardPricebookId();
        opps2[0].CEN_Proyecto__c = projs[0].Id;
        opps2[0].CEN_Proforma__c = '00002';
        opps2[0].AccountId = acc2.Id;
        insert opps2;
        
        OpportunityLineItem oppItem2 = new OpportunityLineItem();
        oppItem2.Product2Id = prod3s[0].Id;
        oppItem2.OpportunityId = opps2[0].Id;
        oppItem2.Quantity = 1;
        oppItem2.TotalPrice = 1000;
        insert oppItem2;
        
    }
    
    
    @IsTest 
    static void callCreateClient_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<CEN_CreateClient_ctr.FlowParameters> parameterList = new List<CEN_CreateClient_ctr.FlowParameters>();
        CEN_CreateClient_ctr.FlowParameters parameter = new CEN_CreateClient_ctr.FlowParameters();
        parameter.oppIds = new List<String>{oppId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClient_ctr.processCreateClient(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClient2_test(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id From Account WHERE Id =:opp.AccountId];
        acc.CEN_Tipo_de_documento__pc = 'CAREXTRAN';
        acc.CEN_Tipo_de_relaci_n_laboral__pc = 'Independiente';
        update acc;
        System.debug('cuentaaa: ' + acc);
        List<CEN_CreateClient_ctr.FlowParameters> parameterList = new List<CEN_CreateClient_ctr.FlowParameters>();
        CEN_CreateClient_ctr.FlowParameters parameter = new CEN_CreateClient_ctr.FlowParameters();
        parameter.oppIds = new List<String>{opp.Id};
            parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClient_ctr.processCreateClient(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientCompany_test(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id From Account WHERE Id =:opp.AccountId];
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
        update acc;
        List<CEN_CreateClient_ctr.FlowParameters> parameterList = new List<CEN_CreateClient_ctr.FlowParameters>();
        CEN_CreateClient_ctr.FlowParameters parameter = new CEN_CreateClient_ctr.FlowParameters();
        parameter.oppIds = new List<String>{opp.Id};
            parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClient_ctr.processCreateClient(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientWarning_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<CEN_CreateClient_ctr.FlowParameters> parameterList = new List<CEN_CreateClient_ctr.FlowParameters>();
        CEN_CreateClient_ctr.FlowParameters parameter = new CEN_CreateClient_ctr.FlowParameters();
        parameter.oppIds = new List<String>{oppId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClient_tst.respType = 'warning';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClient_ctr.processCreateClient(parameterList);
        Test.stopTest();
    }
    
    @IsTest 
    static void callCreateClientrError_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<CEN_CreateClient_ctr.FlowParameters> parameterList = new List<CEN_CreateClient_ctr.FlowParameters>();
        CEN_CreateClient_ctr.FlowParameters parameter = new CEN_CreateClient_ctr.FlowParameters();
        parameter.oppIds = new List<String>{oppId};
            parameterList.add(parameter);
        Test.startTest();
        CEN_CreateClient_tst.respType = '';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<String> response = CEN_CreateClient_ctr.processCreateClient(parameterList);
        Test.stopTest();
    }
    
    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_CreateClient_tst.respType.equals('ok')) {
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
            } else if (CEN_CreateClient_tst.respType.equals('warning'))  {
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