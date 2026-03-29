/**
 * @description       : Servicio de notification App Vecino Centenario
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 01-12-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-12-2023   @nttdata.com  Initial Version
 **/

@isTest
public with sharing class CEN_NotificationAppVecinoCentenario_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp() {
        //---- CASES
        Case cas = new Case();
        cas.Status='Pendiente';
        cas.CEN_Tipo_de_documento__c = 'DNI';
        cas.N_mero_de_documento__c='10203040';
        cas.Origin='App';
        cas.Subject='Interacción - Entrega de documentos -';   
        insert cas;
    }

    @IsTest
    static void CEN_NotificationAppVecinoCentenario_Success() {
        Test.startTest();
        List<Case> lstCase = [
        SELECT Id,CaseNumber,Status,CEN_Tipo_de_documento__c,N_mero_de_documento__c,Origin,Subject
        FROM Case
        LIMIT 1
        ];        
		List<CEN_NotificationAppVecinoCentenario_ctr.FlowParameters> requestList = new List<CEN_NotificationAppVecinoCentenario_ctr.FlowParameters>();
        CEN_NotificationAppVecinoCentResponse response = new CEN_NotificationAppVecinoCentResponse();
        CEN_NotificationAppVecinoCentenario_ctr.FlowParameters request = new CEN_NotificationAppVecinoCentenario_ctr.FlowParameters();
        request.caseNumber=lstCase[0].caseNumber;
        request.estado=lstcase[0].Status;
        request.tipoDocumento=lstCase[0].CEN_Tipo_de_documento__c;
        request.numeDocumento=lstCase[0].N_mero_de_documento__c;
        request.origen=lstCase[0].Origin;
        request.subject=lstCase[0].Subject;
        requestList.add(request);

        CEN_NotificationAppVecinoCentenario_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());

        List<String> result = CEN_NotificationAppVecinoCentenario_ctr.notificacionInteraccionAppVecino(requestList);

        //response.success = true;
        //response.message = '';
        //system.debug('response: '+ result);
        Test.stopTest();
        
    }           

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        if (CEN_NotificationAppVecinoCentenario_tst.respType.equals('ok')) {
            res.setBody('{"success": true,"message": ""}');
            res.setStatusCode(200);
        } else if (CEN_NotificationAppVecinoCentenario_tst.respType.equals('error')) {
            res.setBody(
            '{"messages": ["ERRORINTERNO"],"messageType": "INTERNAL_ERROR","developerMessage": "Permission to send an SMS has not been enabled for the region indicated by the To number: +5491100000004."}'
            );
            res.setStatusCode(500);
        }
        return res;
        }
    }
}