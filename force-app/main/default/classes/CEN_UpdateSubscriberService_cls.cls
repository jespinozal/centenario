/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 02-02-2022
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   02-02-2022   @everis.com   Initial Version
**/
public with sharing class CEN_UpdateSubscriberService_cls {

    @future (callout=true)
    public static void executeSubscriberApi(Id idLeadOrAccount){

        if (String.isNotBlank(idLeadOrAccount)) {
            makePostSubscribeCallout(idLeadOrAccount);
        }
    }

    public static SubscriberTokenResp makeGetSubscribeTokenCallout() {
        SubscriberTokenResp resp = new SubscriberTokenResp();
        try {
            resp = callTokenSubscribeServiceApi('CEN_TokenAPI');
        } catch (Exception ex) {
            System.debug('error-makeGetSubscribeTokenCallout: ' + ex.getMessage());
        }
        
        return resp;
    }

    public static String makePostSubscribeCallout(Id idLeadOrAccount) {
        String resp;
        Map<String, String> mapReq = new Map<String, String>();

        try {
            SubscriberTokenResp respToken = makeGetSubscribeTokenCallout();
            mapReq.put('token', respToken.access_token);
            mapReq.put('id', idLeadOrAccount);
            resp = callSubscribeServiceApi('CEN_Resubscribe',mapReq);
        } catch (Exception ex) {
            System.debug('error-makePostSubscribeCallout: ' + ex.getMessage());
        }
        
        return resp;
    }

    private static SubscriberTokenResp callTokenSubscribeServiceApi(String myConfig) {
        SubscriberTokenResp mapApiResp = new SubscriberTokenResp();
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

        httpResp = myApi.makeCallout().getResponse();
        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            mapApiResp = (SubscriberTokenResp) JSON.deserialize(strBody,SubscriberTokenResp.class);
        } else {
            String strBody = httpResp.getBody();
            System.debug('strBody: ' + strBody);
        }        
        return mapApiResp;
    }    
    
    private static String callSubscribeServiceApi(String myConfig, Map<String, String> paraments) {
        String strApiResp;
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

        if (paraments != null) {myApi.setParams(paraments); }

        httpResp = myApi.makeCallout().getResponse();

        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            System.debug('strBody: '+strBody);
        } else {
            String strBody = httpResp.getBody();
            System.debug('strBody: '+ strBody);
        }        
        return strApiResp;
    }

    public class SubscriberTokenResp{
        public String access_token { get; set; }
    }
}