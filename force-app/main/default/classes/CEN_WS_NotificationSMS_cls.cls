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
public without sharing class CEN_WS_NotificationSMS_cls {

    public static Map<String, Object> sendNotificationSMS(Map<String,String> mapObj) {
        Map<String, Object> mapResp = new Map<String, Object>();
        try {
            CEN_NotificationSMSRequest myReq = new CEN_NotificationSMSRequest();
            myReq.business = mapObj.get('business');
            myReq.phoneNumber = mapObj.get('phoneNumber');
            myReq.message = mapObj.get('message');
            myReq.taskId = mapObj.get('taskId');

            String myConfig = 'CEN_NotificationSMS';
            mapResp = callNotificacionSMS(myReq, myConfig, null);
        } catch (Exception ex) {mapResp.put('error', ex.getMessage());}
        return mapResp;
    }

    private static Map<String, Object> callNotificacionSMS(CEN_NotificationSMSRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }
        myApi.setTimeout(60000);
        httpResp = myApi.makeCallout().getResponse();

        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            strBody = strBody.replace('"object"', '"wObject"');
            CEN_NotificationSMSResponse myResp = (CEN_NotificationSMSResponse) JSON.deserialize(strBody,CEN_NotificationSMSResponse.class);
            mapApiResp.put('success', myResp);
        } else {
            Map<String, Object> map1 = (Map<String, Object>) JSON.deserializeUntyped(httpResp.getBody());
            mapApiResp.put('error', map1.get('developerMessage'));
        }

        return mapApiResp;
    }

}