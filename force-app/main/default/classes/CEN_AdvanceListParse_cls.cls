/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-05-09 
* @description: Clase Parse de evento call Api SAP - Listado de Anticipos. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-05-09           Alan Alvarez            Creación 
*  
*********************************************************************/
public with sharing class CEN_AdvanceListParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
    
    public Object parseResponse(String obj){
        system.debug('CEN_AdvanceListParse_cls-parseResponse: '+obj);

        CEN_AdvanceListObjectResponse myResp = new CEN_AdvanceListObjectResponse();
       Set<string> myTags = new Set<string>{
            'ET_ANTICIPOS'
          };
          Map<String, Object> mapResp = new Map<String, Object>();
          for (string tg : myTags) {
            if(obj.contains(tg) && obj.indexOf('<' + tg + '>')>= 0 && obj.lastIndexOf('</' + tg + '>') >=0 ){
              String myXmlString = obj.substring(obj.indexOf('<' + tg + '>'), obj.lastIndexOf('</' + tg + '>') + tg.length() + 3 );
              if(myXmlString.contains('<item>')){
                  myXmlString = myXmlString.remove('<' + tg + '>');
                  myXmlString = myXmlString.remove('</' + tg + '>');
                  String[] arrStrObj = myXmlString.split('<item>');
                  List<CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV> myItems = new List<CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV>();
                  Map<String, Object> mapItem = new Map<String, Object>();
                  for(String strObj: arrStrObj){
                      XMLSerializer xmlConvertToJson = new XMLSerializer();
                      String jsonString = xmlConvertToJson.xmlToJSON('<item>'+strObj);
                      jsonString = jsonString.replace('""', 'null');
                      Map<String, Object> mapItemAux = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

                      if(mapItemAux.get('item')!=null){
                          CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV myItem = (CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV)JSON.deserialize( JSON.serialize(mapItemAux.get('item')), CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV.class);
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
          CEN_AdvanceListObjectResponse resp = (CEN_AdvanceListObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_AdvanceListObjectResponse.class);
          system.debug('resp: '+resp);

          return resp;
    }      
    
}