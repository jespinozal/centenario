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
public with sharing class CEN_AccountStatementFinancingParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
    
    public Object parseResponse(String obj){
        system.debug('CEN_AccountStatementFinancingParse_cls-parseResponse: '+obj);

        CEN_AccountStatementFinancingResponse myResp = new CEN_AccountStatementFinancingResponse();
        Set<string> myTags = new Set<string>{
            'ET_LOG_ENVIO'
          };
          Map<String, Object> mapResp = new Map<String, Object>();
          for (string tg : myTags) {
            if(obj.contains(tg) && obj.indexOf('<' + tg + '>')>= 0 && obj.lastIndexOf('</' + tg + '>') >=0 ){
              String myXmlString = obj.substring(obj.indexOf('<' + tg + '>'), obj.lastIndexOf('</' + tg + '>') + tg.length() + 3 );
              if(myXmlString.contains('<item>')){
                  myXmlString = myXmlString.remove('<' + tg + '>');
                  myXmlString = myXmlString.remove('</' + tg + '>');
                  String[] arrStrObj = myXmlString.split('<item>');
                  List<CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC> myItems = new List<CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC>();
                  Map<String, Object> mapItem = new Map<String, Object>();
                  for(String strObj: arrStrObj){
                      XMLSerializer xmlConvertToJson = new XMLSerializer();
                      String jsonString = xmlConvertToJson.xmlToJSON('<item>'+strObj);
                      jsonString = jsonString.replace('""', 'null');
                      Map<String, Object> mapItemAux = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

                      if(mapItemAux.get('item')!=null){
                        CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC myItem = (CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC)JSON.deserialize( JSON.serialize(mapItemAux.get('item')), CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC.class);
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
          CEN_AccountStatementFinancingResponse resp = (CEN_AccountStatementFinancingResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_AccountStatementFinancingResponse.class);
          system.debug('resp: '+resp);

          return resp;
    }      
    
}