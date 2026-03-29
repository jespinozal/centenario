/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-24-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-22-2021   @everis.com   Initial Version
**/

@isTest
public with sharing class CEN_OperationSafeToTransferOwner_Test {

    public static String respType;
    @TestSetup
	static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        projs[0].CEN_Sociedad__c = '123213';
        insert projs;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '02430322';
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        opps[0].CEN_Proyecto__c = projs[0].Id;
        opps[0].CEN_ProformaVersion__c = 1;

        insert opps;

        String fecha = '2021-03-01';
        Date dt = Date.valueOf(fecha);
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'Pagado';
        oPaymentOrder.CEN_OriginPayment__c = 'TCRE';
        oPaymentOrder.CEN_PaymentDescription__c = 'Test pago';
        oPaymentOrder.CEN_LastFour__c = '1111';
        Id devRecordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();
        oPaymentOrder.RecordTypeId = devRecordTypeId;
        oPaymentOrder.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrder.CEN_PaymentDate__c= dt;
        oPaymentOrder.CEN_CountryCode__c= 'PE';
        oPaymentOrder.CEN_Banks__c= '020';
        oPaymentOrder.CEN_ID_Culqi__c = 'chr_1s2d4fghxkl1';
        oPaymentOrder.CEN_DocumentNumberSAP__c = '8400004974';
        oPaymentOrder.CEN_DocumentYearSAP__c = '2023';

        insert oPaymentOrder;

        CEN_PaymentOrder__c oPaymentOrder2 = new CEN_PaymentOrder__c();
        oPaymentOrder2.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder2.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder2.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder2.CEN_Amount__c = 2000;
        oPaymentOrder2.CEN_PaymentStatus__c = 'Pagado';
        oPaymentOrder2.CEN_OriginPayment__c = 'TCRE';
        oPaymentOrder2.CEN_PaymentDescription__c = 'Test pago';
        oPaymentOrder2.CEN_LastFour__c = '1111';
        Id devRecordTypeId2 = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();
        oPaymentOrder2.RecordTypeId = devRecordTypeId2;
        oPaymentOrder2.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrder2.CEN_PaymentDate__c= dt;
        oPaymentOrder2.CEN_CountryCode__c= 'PE';
        oPaymentOrder2.CEN_Banks__c= '020';
        oPaymentOrder2.CEN_ID_Culqi__c = 'chr_1s2d4fghxkl2';
        oPaymentOrder2.CEN_DocumentNumberSAP__c = '8400004973';
        oPaymentOrder2.CEN_DocumentYearSAP__c = '2023';

        insert oPaymentOrder2;

        CEN_PaymentOrder__c oPaymentOrder3 = new CEN_PaymentOrder__c();
        oPaymentOrder3.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder3.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder3.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder3.CEN_Amount__c = 6000;
        oPaymentOrder3.CEN_PaymentStatus__c = 'Pagado';
        oPaymentOrder3.CEN_OriginPayment__c = 'TCRE';
        oPaymentOrder3.CEN_PaymentDescription__c = 'Test pago';
        oPaymentOrder3.CEN_LastFour__c = '1111';
        Id devRecordTypeId3 = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();
        oPaymentOrder3.RecordTypeId = devRecordTypeId3;
        oPaymentOrder3.CEN_PaymentDateAux__c= Date.today();
        oPaymentOrder3.CEN_PaymentDate__c= Date.today();
        oPaymentOrder3.CEN_CountryCode__c= 'PE';
        oPaymentOrder3.CEN_Banks__c= '020';
        oPaymentOrder3.CEN_ID_Culqi__c = 'chr_1s2d4fghxkl3';
        oPaymentOrder3.CEN_DocumentNumberSAP__c = '8400004973';
        oPaymentOrder3.CEN_DocumentYearSAP__c = '2023';

        insert oPaymentOrder3;
    }

    @IsTest static void changeOwnerFromOperationSafeSucess_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id; // Opp
        Test.startTest();
        CEN_OperationSafeToTransferOwner_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_OperationSafeToTransferOwner_ctr.FlowParameters params = new CEN_OperationSafeToTransferOwner_ctr.FlowParameters();
        params.opIds = new List<String>{oppId};
        List<CEN_OperationSafeToTransferOwner_ctr.FlowParameters> listParamns = new List<CEN_OperationSafeToTransferOwner_ctr.FlowParameters>();
        listParamns.add (params);
        system.debug('listParamns: '+listParamns);
        List<String> response = CEN_OperationSafeToTransferOwner_ctr.changeOwnerFromOperationSafSAP(listParamns);
        system.debug('responseSucess: '+response);
        Test.stopTest();
    }

    @IsTest static void changeOwnerFromOperationSafeError_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id; // Opp
        Test.startTest();
        CEN_OperationSafeToTransferOwner_Test.respType = 'warning';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            Map<String,String> response = CEN_OperationSafeToTransferOwner_ctr.changeOwnerFromOperationSafe(oppId);
        system.debug('responseError: '+response);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'text/xml');
            if (CEN_OperationSafeToTransferOwner_Test.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_TRANSFE_CLIENTE_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_PAGOS_CLIENTE><item><BUKRS>0019</BUKRS><GJAHR>2021</GJAHR><BELNR>8400004978</BELNR><BELNR_ANTERIOR>8400004973</BELNR_ANTERIOR></item><item><BUKRS>0019</BUKRS><GJAHR>2021</GJAHR><BELNR>8400004979</BELNR><BELNR_ANTERIOR>8400004974</BELNR_ANTERIOR></item></ET_PAGOS_CLIENTE><ET_RETURN><item><TYPE>S</TYPE><ID>F5</ID><NUMBER>312</NUMBER><MESSAGE>Doc.8700007866 se contabilizó en sociedad 0019</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>8700007866</MESSAGE_V1><MESSAGE_V2>0019</MESSAGE_V2><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>F5</ID><NUMBER>312</NUMBER><MESSAGE>Doc.8400004975 se contabilizó en sociedad 0019</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>8400004975</MESSAGE_V1><MESSAGE_V2>0019</MESSAGE_V2><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400004976</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000497600192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400004977</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000497700192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400004978</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000497800192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400004979</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000497900192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>ZAC_OTC</ID><NUMBER>038</NUMBER><MESSAGE>Se realizó correctamente la transferencia.</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1/><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_OK>X</E_OK></n0:ZRFC_OTC_TRANSFE_CLIENTE_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_OperationSafeToTransferOwner_Test.respType.equals('warning')){
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_TRANSFE_CLIENTE_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_RETURN><item><TYPE>E</TYPE><ID>ZAC_B14</ID><NUMBER>126</NUMBER><MESSAGE>El cliente: 0046709014  no exite.</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>El cliente:</MESSAGE_V1><MESSAGE_V2>0046709014</MESSAGE_V2><MESSAGE_V3>no exite.</MESSAGE_V3><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>D00CLNT100</SYSTEM></item></ET_RETURN><E_OK/></n0:ZRFC_OTC_TRANSFE_CLIENTE_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(404);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }

            return res;
        }
    }
}