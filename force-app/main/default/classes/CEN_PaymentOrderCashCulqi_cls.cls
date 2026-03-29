/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 07-09-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
public class CEN_PaymentOrderCashCulqi_cls {
    public static Map<String, Object> PaymentOrderCash(map<String,String> mapData) {
        System.debug('Entrando a PaymentOrderCash');
        Map<String, Object> mapResp = new Map<String, Object>();
        ValidateData(mapData);

        try {
            String codSociety = mapData.get('codSociety');
            mapData.remove('codSociety');
            String myCulqiSociety  = CEN_CulqiCommerce__mdt.getInstance('S'+codSociety).Label;
            String myConfig = 'CEN_CulquiConsultPaymentOrder'+myCulqiSociety;
            
            mapResp = callPaymentOrderCashCulqiApi(null, myConfig, mapData);
        } catch (Exception ex) { mapResp.put('error', ex.getMessage()); }
        return mapResp;
    }

    private static void ValidateData(map<String,String> mapData){
        System.debug('Entrando a ValidateData');
        for(String keyData : mapData.keySet()){
            String strData = mapData.get(keyData);
            //Validar un valor vacio dentro del mapa
            if(strData == null || String.isEmpty(strData)){   throw new PaymentOrderCashException('Error no puedo ser vacio: ' + keyData);}
        }
    }
    
    private static Map<String, Object> callPaymentOrderCashCulqiApi(CEN_PaymentOrderCashCulqiRequest myReq, String myConfig, Map<String, String> paraments) {
        System.debug('Entrando a callPaymentOrderCashCulqiApi');
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_PaymentOrderCashCulqiParse_cls.attributesList resp = new CEN_PaymentOrderCashCulqiParse_cls.attributesList();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);
        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }
        System.debug('Entrando a linea 44');
        httpResp = myApi.makeCallout().getResponse();
        if (httpResp.getStatusCode() == 200) {
            String strBody = httpResp.getBody();
            //resp = (CEN_PaymentOrderCashCulqiParse_cls.attributesList) myApi.makeCallout().getParsedResponse();
           System.debug('strBody aqui: '+strBody);
           CEN_PaymentOrderCashCulqiParse_cls respp = new CEN_PaymentOrderCashCulqiParse_cls();
           
           System.debug('respData' + respp.parseResponse(strBody));
           CEN_PaymentOrderCashCulqiParse_cls.attributesList oldData = new CEN_PaymentOrderCashCulqiParse_cls.attributesList();
           oldData = (CEN_PaymentOrderCashCulqiParse_cls.attributesList)respp.parseResponse(strBody);
            mapApiResp.put('sucess', oldData.data);
        } else {
            Map<String, Object> map1 = (Map<String, Object>)JSON.deserializeUntyped(httpResp.getBody());
            mapApiResp.put('error', map1.get('merchant_message'));
        }
        
        return mapApiResp;
    }

    public class PaymentOrderCashException extends Exception {
    }
}