/**
 * @description       : Servicio de notification SMS - Tannua
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 22-05-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   22-05-2023   @nttdata.com  Initial Version
 **/
@isTest
public without sharing class CEN_WS_NotificationSMS_Test {
    public static String respType = '';
    @TestSetup
	static void SetUp(){
        List<String> numberPhones = new List<String>();
        numberPhones.add('+51900000001');
        numberPhones.add('+51900000002');
        numberPhones.add('900000003');
        numberPhones.add('+5491100000004');
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 4;i++){
            Lead ld = new Lead();
            ld.Salutation = 'Sr.';
            ld.FirstName = 'Test 00'+i;
            ld.LastName = 'Test 11'+i;
            ld.CEN_N_mero_de_documento__c = '8880000'+i;
            ld.LeadSource = 'Call Center';
            ld.CEN_Medio__c = '0138';
            ld.MobilePhone = numberPhones[i];
            ld.CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda';
            ld.CEN_Tema_de_inter_s__c = 'Quiero comprar un lote';
            ld.CEN_Donde_comprar__c = 'LIMA_Pachacamac_LU';
            ld.CEN_Elige_donde_vivir__c = 'Pachacamác - Urbanización Valle Las Higueras';
            leads.add(ld);
        }
        insert leads;
    }

    // @IsTest static void serviceNotificationSMS_Success(){

    //     Test.startTest();
    //     Map<String,String> mapObj = new Map<String,String>();
    //     mapObj.put('business','test');
    //     mapObj.put('phoneNumber','+51948160461');
    //     mapObj.put('message','Hola Mundo');
    //     mapObj.put('taskId','Lead');
    //     CEN_WS_NotificationSMS_Test.respType = 'ok';
    //     Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
    //     Map<String, Object> mapResp = CEN_WS_NotificationSMS_cls.sendNotificationSMS(mapObj);
    //     System.debug('mapResp:' + mapResp);
    //     Test.stopTest();
    // }

    @IsTest static void sendNotificationSMS_Success(){

        Test.startTest();
        List<Lead> lst = [SELECT Id,FirstName,CEN_Elige_donde_vivir__c,MobilePhone FROM Lead LIMIT 4];
		List<CEN_WS_NotificationSMS_ctr.Requests> requestList = new List<CEN_WS_NotificationSMS_ctr.Requests>();
        CEN_NotificationSMSResponse response = new CEN_NotificationSMSResponse();
        for(Lead ld : lst){
            CEN_WS_NotificationSMS_ctr.Requests request = new CEN_WS_NotificationSMS_ctr.Requests();
            request.phoneNumber = ld.MobilePhone;
            request.recordId = ld.Id;
            request.messageReplace = 'Hola ' + ld.FirstName + 'Proyecto: ' + ld.CEN_Elige_donde_vivir__c;
            requestList.add(request);
        }

        CEN_WS_NotificationSMS_Test.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        List<CEN_WS_NotificationSMS_ctr.Results> result = CEN_WS_NotificationSMS_ctr.executeNotificationSMS(requestList);
        response.success = true;
        response.message = '';
        system.debug('response: '+ result);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_WS_NotificationSMS_Test.respType.equals('ok')) {
                res.setBody('{"success": true,"message": ""}');
                res.setStatusCode(200);
            } else if (CEN_WS_NotificationSMS_Test.respType.equals('error'))  {
                res.setBody('{"messages": ["ERRORINTERNO"],"messageType": "INTERNAL_ERROR","developerMessage": "Permission to send an SMS has not been enabled for the region indicated by the To number: +5491100000004."}');
                res.setStatusCode(500);
            }
            return res;
        }
    }
}