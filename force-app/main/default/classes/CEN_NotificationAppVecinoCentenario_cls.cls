/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 13-11-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-11-2023  @nttdata.com  Initial Version
 **/

public with sharing class CEN_NotificationAppVecinoCentenario_cls {
  public static Map<String, Object> notificationAppVecinoCentenario(
    CEN_NotificationAppVecinoCentRequest mapData
  ) {
    Map<String, Object> mapResp = new Map<String, Object>();
    String myConfig = 'CEN_NotificationAppVecinoCentenario';
    mapResp = NotificationAppVecinoCentenarioApi(mapData, myConfig);
    return mapResp;
  }

  private static Map<String, Object> notificationAppVecinoCentenarioApi(
    CEN_NotificationAppVecinoCentRequest myReq,
    String myConfig
  ) {
    Map<String, Object> mapApiResp = new Map<String, Object>();
    HttpResponse httpResp = new HttpResponse();
    CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);

    System.debug(myReq);
    if (myReq != null) {
      String jsonReq = JSON.serialize(myReq);
      myApi.setRequestBody(jsonReq);
    }
    // if (paraments != null) {myApi.setParams(paraments); }
    myApi.setTimeout(60000);
    httpResp = myApi.makeCallout().getResponse();

    if (httpResp.getStatusCode() == 200) {
      String strBody = httpResp.getBody();
      //strBody = strBody.replace('"object"', '"wObject"');
      CEN_NotificationAppVecinoCentResponse myResp = (CEN_NotificationAppVecinoCentResponse) JSON.deserialize(
        strBody,
        CEN_NotificationAppVecinoCentResponse.class
      );
      mapApiResp.put('success', myResp);
    } else {
      Map<String, Object> map1 = (Map<String, Object>) JSON.deserializeUntyped(
        httpResp.getBody()
      );
      mapApiResp.put('error', map1.get('developerMessage'));
    }

    System.debug(mapApiResp);
    return mapApiResp;
  }
}