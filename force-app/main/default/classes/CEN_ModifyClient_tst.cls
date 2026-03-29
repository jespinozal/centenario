/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-01-2022
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-01-2022   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_ModifyClient_tst {


    public static String respType = '';
    @TestSetup
    static void SetUp(){

        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;

        Account acc = new Account();
        acc.Salutation = 'Sr.';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.CEN_Estado_civil__pc = 'Casado';
        acc.CEN_Nacionalidad__pc = 'PE';
        acc.CEN_Tipo_de_documento__pc='DNI';
        acc.CEN_N_mero_de_documento__pc='10203040';
        acc.CEN_Lugar_de_nacimiento__pc='';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.CEN_Referencia_direccion__c='';
        acc.CEN_Tel_fono_Trabajo__pc='987654321';
        acc.PersonMobilePhone='5555000';
        acc.PersonEmail='juan@everis.com';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc =distrito.Id;
        acc.CEN_SocietySAP__c = '0010';
        insert acc;

        Account acc2 = new Account();
        acc2.Name='Ferrostal';
        acc2.CEN_Direcci_n__c='Calle San Lorenzo';
        acc2.CEN_Referencia_direccion__c='';
        acc2.Phone='5555000';
        acc2.CEN_Tipo_de_documento__c='RUC';
        acc2.CEN_Numero_de_documento_del__c='201042758912';
        acc2.CEN_fld_Correo_empresa__c='ferrostal@everis.com';
        acc2.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
        acc2.CEN_Distrito__c =distrito.Id;
        acc2.CEN_SocietySAP__c = '0010';
        insert acc2;
    }

    @IsTest 
    static void ModifyClientPersonaSuccess_test(){
        Account acc = [SELECT Id, CEN_Estado_civil__pc,CEN_Distrito__pc FROM Account WHERE PersonEmail ='juan@everis.com' LIMIT 1];
        //Account acc = new Account();
        ///acc.Id = accId.Id;
        acc.CEN_Estado_civil__pc = 'Divorc';
        CEN_ModifyClient_ctr.Requests req = new CEN_ModifyClient_ctr.Requests();
        List<CEN_ModifyClient_ctr.Requests> listReq = new List<CEN_ModifyClient_ctr.Requests>();
        req.recordId = acc.Id;
        req.tratamiento = 'Sr.';
        req.nombres = 'Carlos';
        req.direccion = 'Av. Girasoles';
        req.referencia = 'Colegio Guadalupe';
        req.telefonoFijo = '01522888';
        req.telefonoMovil = '957878456';
        req.email = 'test@prueba.abc';
        req.lugarNacimiento = 'Ica';
        req.fechaNacimiento = '2000-09-29';
        req.estadoCivil = 'Casado';
        req.apellidos = 'Hernandez';
        req.nacionalidad = 'PE';
        req.distrito = acc.CEN_Distrito__pc;
        listReq.add(req);
        update acc;
        Test.startTest();
        CEN_ModifyClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_ModifyClient_ctr.CEN_ModifyClient_ctr(listReq);
        Test.stopTest();
    }

    @IsTest 
    static void ModifyClientEmpresaSuccess_test(){
        Id accId = [SELECT Id, Name FROM Account WHERE CEN_fld_Correo_empresa__c = 'ferrostal@everis.com'].Id;
        Account acc = new Account();  
        acc.Id = accId;	
        acc.Name = 'Ferrostal SAC';
        CEN_ModifyClient_ctr.Requests req = new CEN_ModifyClient_ctr.Requests();
        List<CEN_ModifyClient_ctr.Requests> listReq = new List<CEN_ModifyClient_ctr.Requests>();
        req.recordId = accId;
        listReq.add(req);
        update acc;
        Test.startTest();
        CEN_ModifyClient_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_ModifyClient_ctr.CEN_ModifyClient_ctr(listReq);
        Test.stopTest();
    }

    @IsTest 
    static void ModifyClientPersonaError_test(){
        Id accId = [SELECT Id, CEN_Estado_civil__pc FROM Account WHERE PersonEmail ='juan@everis.com'].Id;
        Account acc = new Account();  
        acc.Id = accId;	
        acc.CEN_Estado_civil__pc = 'Divorc';
        CEN_ModifyClient_ctr.Requests req = new CEN_ModifyClient_ctr.Requests();
        List<CEN_ModifyClient_ctr.Requests> listReq = new List<CEN_ModifyClient_ctr.Requests>();
        req.recordId = accId;
        listReq.add(req);
        update acc;
        Test.startTest();
        CEN_ModifyClient_tst.respType = 'error';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_ModifyClient_ctr.CEN_ModifyClient_ctr(listReq);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_ModifyClient_tst.respType.equals('ok')) {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_CLIENTEResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>S</TYPE>';
                result += '<ID>F2</ID>';
                result += '<NUMBER>056</NUMBER>';
                result += '<MESSAGE>Se han efectuado modificaciones</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1/>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM/>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK>X</E_OK>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_CLIENTEResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (CEN_ModifyClient_tst.respType.equals('error'))  {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_CLIENTEResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>E</TYPE>';
                result += '<ID>AM</ID>';
                result += '<NUMBER>132</NUMBER>';
                result += '<MESSAGE>Introduzca un tratamiento permitido</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1/>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM/>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK/>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_CLIENTEResponse>';
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