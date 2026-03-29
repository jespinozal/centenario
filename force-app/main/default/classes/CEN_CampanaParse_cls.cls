/********************************************************************* 
* @author: Jose Hernandez (jherncal@emeal.nttdata.com) 
* @date: 2022-10-27 
* @description: Clase Parse de evento call Api SAP - Campañas disponibles. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2022-10-27           Jose Hernandez          Creación 
*  
*********************************************************************/

public with sharing class CEN_CampanaParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
    
    public Object parseResponse(String obj){
      system.debug('CEN_CampanaParse_cls-parseResponse: '+obj);
      
      CEN_CampanaObjectResponse myResp = new CEN_CampanaObjectResponse();
        Set<string> myTags = new Set<string>{
          'DETALLE_CAMPANA'
        };
        Map<String, Object> mapResp = new Map<String, Object>();
        for (string tg : myTags) {
          if(obj.contains(tg) && obj.indexOf('<' + tg + '>')>= 0 && obj.lastIndexOf('</' + tg + '>') >=0 ){
            String myXmlString = obj.substring(obj.indexOf('<' + tg + '>'), obj.lastIndexOf('</' + tg + '>') + tg.length() + 3 );
            if(myXmlString.contains('<item>')){
                myXmlString = myXmlString.remove('<' + tg + '>');
                myXmlString = myXmlString.remove('</' + tg + '>');
                String[] arrStrObj = myXmlString.split('<item>');
                List<CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA> myItems = new List<CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA>();
                Map<String, Object> mapItem = new Map<String, Object>();
                for(String strObj: arrStrObj){
                    XMLSerializer xmlConvertToJson = new XMLSerializer();
                    String jsonString = xmlConvertToJson.xmlToJSON('<item>'+strObj);
                    jsonString = jsonString.replace('""', 'null');
                    Map<String, Object> mapItemAux = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

                    if(mapItemAux.get('item')!=null){
                      CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA myItem = (CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA)JSON.deserialize( JSON.serialize(mapItemAux.get('item')), CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA.class);
                        myItems.add(myItem);
                    }
                }                  
                mapItem.put('item', myItems);
              mapResp.put(tg, mapItem);
            }else{
              XMLSerializer xmlConvertToJson = new XMLSerializer();
            
              String jsonString = xmlConvertToJson.xmlToJSON(myXmlString);
              jsonString = jsonString.replace('""', 'null');
              jsonString = jsonString.replace(',null', '');

              Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

              mapResp.put(tg, mapAux.get(tg));
            }
            
          }
        }

        system.debug('mapResp: '+mapResp); 
        CEN_CampanaObjectResponse resp = (CEN_CampanaObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_CampanaObjectResponse.class);
        system.debug('resp: '+resp);
    
        return resp;
      }    
}