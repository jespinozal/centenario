/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 05-09-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2023   @nttdata.com  Initial Version
**/
@isTest
public with sharing class CEN_GoogleMaps_tst {
    public static String respType;
    @TestSetup
	static void SetUp(){
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '22063455';
        accs[0].CEN_URL_map__c = 'https://www.google.com/maps/search/-34.844494775330865,-62.46563356613159';
        insert accs;
    }

    @IsTest static void processUpdateMapURL_error(){

        String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_N_mero_de_documento__pc, CEN_URL_map__c
                FROM Account WHERE RecordTypeId = :RecTypeId
        ];

        Test.startTest();
        System.debug('cuenta: ' + cuenta);
        List<CEN_GoogleMaps_ctr.FlowParameters> parameterList = new List<CEN_GoogleMaps_ctr.FlowParameters>();
        CEN_GoogleMaps_ctr.FlowParameters parameter = new CEN_GoogleMaps_ctr.FlowParameters();
        parameter.accId = cuenta.Id;
        parameterList.add(parameter);

        //CEN_GoogleMaps_ctr.processUpdateMapURL(parameterList);

        CEN_GoogleMaps_tst.respType = 'OK';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_GoogleMaps_ctr.processUpdateMapURL(parameterList);
        Test.stopTest();
    }

    @IsTest static void processUpdateMapURL_success(){

        String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_N_mero_de_documento__pc, CEN_URL_map__c
                FROM Account WHERE RecordTypeId = :RecTypeId
        ];

        cuenta.CEN_Direccion__pc = 'Av. Las Palmeras';
        update cuenta;
        Test.startTest();
        System.debug('cuenta: ' + cuenta);
        List<CEN_GoogleMaps_ctr.FlowParameters> parameterList = new List<CEN_GoogleMaps_ctr.FlowParameters>();
        CEN_GoogleMaps_ctr.FlowParameters parameter = new CEN_GoogleMaps_ctr.FlowParameters();
        parameter.accId = cuenta.Id;
        parameterList.add(parameter);

        //CEN_GoogleMaps_ctr.processUpdateMapURL(parameterList);

        CEN_GoogleMaps_tst.respType = 'OK';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_GoogleMaps_ctr.processUpdateMapURL(parameterList);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'text/xml');
            if (CEN_GoogleMaps_tst.respType.equals('OK')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZWS_REGISTRA_URL_MAPSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><E_MESSAGE>OK. Se registró correctamente.</E_MESSAGE></n0:ZWS_REGISTRA_URL_MAPSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_GoogleMaps_tst.respType.equals('ERROR')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"> <soap-env:Header/> <soap-env:Body> <soap-env:Fault> <faultcode>soap-env:Server</faultcode> <faultstring xml:lang="en">Error en el tratamiento de servicio web; Más detalles en log de error de servicio web en la página de proveedor (Cronomarcador UTC 20231009163143; ID de transacción 80771D38D56A0060E0064E775FC4F94E)</faultstring> <detail/> </soap-env:Fault> </soap-env:Body> </soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }

            return res;
        }
    }
}