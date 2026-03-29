/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 06-17-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_AccountStatementFinancing_tst {
    public static String respType = '';
    @TestSetup
	static void SetUp(){
        List<Account> accountList = new List<Account>();
        List<CEN_AccountStatement__c> accStList = new List<CEN_AccountStatement__c>();
        DateTime dt = System.today();
        Date myDate =date.newinstance(dt.year(), dt.month(), dt.day());
        Time timeChange = Time.newInstance(dt.hourGmt(),dt.minute(),dt.second(),0);  

        Account oAccount = new Account();
        oAccount.FirstName = 'A_Test_01';
        oAccount.LastName = 'L_Test_01';
        oAccount.PersonEmail = 'Test01@tst.com';
        oAccount.CEN_N_mero_de_documento__pc = '9999999999';
        oAccount.PersonMobilePhone = '912999001';
        accountList.add(oAccount);
        insert accountList;

        CEN_AccountStatement__c oAccSt = new CEN_AccountStatement__c();
        oAccSt.CEN_Account__c = accountList[0].id;
        oAccSt.CEN_Client__c = 'testName';
        oAccSt.CEN_Email__c = 'testName@test.cen.com';
        oAccSt.CEN_Status__c = 'ok'; 
        oAccSt.CEN_ShippingDate__c = myDate;
        oAccSt.CEN_ShippingTime__c = timeChange;
        oAccSt.CEN_Proforma__c = '0000000009';
        accStList.add(oAccSt);

        insert accStList;
    }

    @IsTest static void generateAndUpdateAccountStatementSuccess_test(){
        Test.startTest();
        CEN_ProcessPayment_Test.respType = 'ok';
		Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AccountStatementFinancing_ctr.updateAccountStatementFinancingAsync();
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_ProcessPayment_Test.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZWS_CONSULTA_ENVIO_ECResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_LOG_ENVIO><item><CLIENTE>9999999999</CLIENTE><PROFORMA>0000099999</PROFORMA><FECHA_ENVIO>3112-99-99</FECHA_ENVIO><HORA_ENVIO>23:59:59</HORA_ENVIO><CORREO>test@test.com</CORREO><ESTADO>01</ESTADO></item></ET_LOG_ENVIO></n0:ZWS_CONSULTA_ENVIO_ECResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_ProcessPayment_Test.respType.equals('warning'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><soap-env:Fault><faultcode>soap-env:Server</faultcode><faultstring xml:lang="en">Error en el tratamiento de servicio web; Más detalles en log de error de servicio web en la página de proveedor (Cronomarcador UTC 20220221221203; ID de transacción 80771D38D56A0030E00620DDA1013808)</faultstring><detail/></soap-env:Fault></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(500);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }   
    }
}