/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 10-09-2024
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   10-09-2024   @nttdata.com  Initial Version
**/
public with sharing class CEN_ClienteAptoPremioReferido_cls {

    public static Map<String, Object> ClienteAptoPremioReferido(CEN_ReferidoRequest mapData) {
        Map<String, Object> mapResp = new Map<String, Object>();
        String myConfig = 'CEN_Referidos';
        mapResp = ClienteAptoPremioReferidoApi(mapData, myConfig, null);
        return mapResp;
    }

    private static Map<String, Object> ClienteAptoPremioReferidoApi(CEN_ReferidoRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_ReferidoResponse resp = new CEN_ReferidoResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            //jsonReq = jsonReq.replace('"wSystem"', '"system"');
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }

        System.debug('myApi: ' + myApi);
        myApi.setTimeout(60000);
        //httpResp = myApi.makeCallout().getResponse();
        //System.debug('httpResp: ' + httpResp);
        resp = (CEN_ReferidoResponse) myApi.makeCallout().getParsedResponse();
        System.debug('resp: ' + resp);
        mapApiResp.put('data', resp);
        System.debug('mapApiResp: ' + mapApiResp);

        return mapApiResp;
    }
}