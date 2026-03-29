/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 04-28-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
public with sharing class CEN_CancelEffectivePaymentOrder_cls {

    @future(callout=true)
    public static void PaymentOrderDeleteByIdAsync(String inIdCulqi) {
        CEN_CancelEffectivePaymentOrder_cls.PaymentOrderDeleteById(inIdCulqi);
    }

    public static Map<String, Object> PaymentOrderDeleteById(String inIdCulqi) {
        Map<String, Object> resp = new Map<String, Object>();
        try {
            Map<String, String> myParaments = new Map<String, String>();
            myParaments.put('inIdCulqi', inIdCulqi);
            ValidateData(myParaments);
            resp = callPaymentOrderDeleteCulqiApi(null,'CEN_CulquiDeletePaymentOrder',myParaments);
        } catch (Exception ex) {
            resp.put('error', ex.getMessage());
        }
        
        return resp;
    }

    private static void ValidateData(map<String,String> mapData){
        for(String keyData : mapData.keySet()){
            String strData = mapData.get(keyData);
            //Validar un valor vacio dentro del mapa
            if(strData == null || String.isEmpty(strData)){   throw new PaymentOrderDeleteException('Error no puedo ser vacio: ' + keyData);}
        }
    }
    
    private static Map<String, Object> callPaymentOrderDeleteCulqiApi(CEN_PaymentOrderDeleteCulqiRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);
        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }
        
        httpResp = myApi.makeCallout().getResponse();
        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            mapApiResp.put('response', null);
        } else {
            String strBody = httpResp.getBody();
            strBody = strBody.replace('"object"', '"wObject"');
            CEN_PaymentOrderDeleteCulqiResponse myResp = (CEN_PaymentOrderDeleteCulqiResponse) JSON.deserialize(strBody,CEN_PaymentOrderDeleteCulqiResponse.class);
           system.debug('myResp: '+myResp);
            mapApiResp.put('response', myResp.merchant_message+myResp.type+myResp.user_message+myResp.wObject);
        }        
        return mapApiResp;
    }

    public class PaymentOrderDeleteException extends Exception {
    }
}