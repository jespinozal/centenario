/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 07-09-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
public with sharing class CEN_PaymentOrderChargesCulqi_cls {

    public static Map<String, Object> PaymentOrderCharges(map<String,String> mapData) {
        Map<String, Object> mapResp = new Map<String, Object>();
        ValidateData(mapData);
        try {
            CEN_PaymentOrderChargesCulqiRequest myReq = new CEN_PaymentOrderChargesCulqiRequest();
            String mySociety = mapData.get('codSociety');
            String myCulqiSociety  = CEN_CulqiCommerce__mdt.getInstance('S'+mySociety).Label;
            String myConfig = 'CEN_CulquiChargesPaymentOrder'+myCulqiSociety;
            mapData.remove('codSociety');
            mapResp = callPaymentOrderChargesCulqiApi(null, myConfig, mapData);
        } catch (Exception ex) { mapResp.put('error', ex.getMessage()); }
        return mapResp;
    }

    private static void ValidateData(map<String,String> mapData){
        for(String keyData : mapData.keySet()){
            String strData = mapData.get(keyData);
            //Validar un valor vacio dentro del mapa
            if(strData == null || String.isEmpty(strData)){   throw new PaymentOrderChargesException('Error no puedo ser vacio: ' + keyData);}
        }
    }
    
    private static Map<String, Object> callPaymentOrderChargesCulqiApi(CEN_PaymentOrderChargesCulqiRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_PaymentOrderChargesCulqiParse_cls.attributesList resp = new CEN_PaymentOrderChargesCulqiParse_cls.attributesList();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);
        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }
        
        httpResp = myApi.makeCallout().getResponse();
        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            resp = (CEN_PaymentOrderChargesCulqiParse_cls.attributesList) myApi.makeCallout().getParsedResponse();
           
            mapApiResp.put('sucess', resp.data);
        } else {
            Map<String, Object> map1 = (Map<String, Object>)JSON.deserializeUntyped(httpResp.getBody());
            mapApiResp.put('error', map1.get('merchant_message'));
        }
        
        return mapApiResp;
    }

    public class PaymentOrderChargesException extends Exception {
    }
}