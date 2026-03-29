/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 09-10-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   09-10-2023  @nttdata.com  Initial Version
**/
public with sharing class CEN_DebidaDiligencia_cls {
    public static Map<String, Object> DebidaDiligencia(CEN_DebidaDiligenciaRequest mapData) {
        Map<String, Object> mapResp = new Map<String, Object>();
        String myConfig = 'CEN_DebidaDiligencia';
        mapResp = DebidaDiligenciaApi(mapData, myConfig, null);
        return mapResp;
    }

    private static Map<String, Object> DebidaDiligenciaApi(CEN_DebidaDiligenciaRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        List<CEN_DebidaDiligenciaResponse> resp = new List<CEN_DebidaDiligenciaResponse>();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            jsonReq = jsonReq.replace('"wSystem"', '"system"');
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }

        System.debug('myApi: ' + myApi);
        CEN_TokenRequest req = new CEN_TokenRequest();
        req.username = 'localhost'; //label
        req.password = '81gE6gLb7HFCGdcc3MbeACUnp1NWnMpuVyuD0MIuvgM='; //label
        //String access_token = getToken(req);
        String access_token;
        if(Test.isRunningTest()){
            access_token = 'test';
        }else{
            access_token = getToken(req);
        }
        System.debug('token: ' + access_token);
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Authorization','Bearer ' + access_token);
        myApi.setHeaders(mapHeader);
        myApi.setTimeout(60000);
        resp = (List<CEN_DebidaDiligenciaResponse>) myApi.makeCallout().getParsedResponse();

        if(resp.size()>0){
            mapApiResp.put('success', resp);
        }else{
            Map<String, Object> map1 = (Map<String, Object>) JSON.deserializeUntyped(httpResp.getBody());
            mapApiResp.put('error', map1.get('errors'));
        }

        return mapApiResp;
    }

    public static String getToken(CEN_TokenRequest myReq){
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls('CEN_TokenOnbase');
        CEN_TokenCacheController cc = new CEN_TokenCacheController();

        String token = cc.GetTokenFromCacheOrg(cc.token_label_name_sinergy);
        if(String.isNotBlank(token)){
            return token;
        }

        String jsonReq = JSON.serialize(myReq);
        myApi.setRequestBody(jsonReq);
        myApi.setTimeout(120000);
        httpResp = myApi.makeCallout().getResponse();

        if(httpResp.getStatusCode()==200){
            Map<String, Object> br = (Map<String, Object>)JSON.deserializeUntyped(httpResp.getBody());
            token = String.valueOf(br.get('token'));
            if(String.isNotBlank(token)){
                cc.StoreTokenInCacheOrg(token, cc.token_label_name_sinergy);
            }
        }
        return token;
    }
}