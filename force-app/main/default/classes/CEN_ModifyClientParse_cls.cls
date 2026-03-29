/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 20-12-2021
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   20-12-2021   @nttdata.com   Initial Version
 **/
public with sharing class CEN_ModifyClientParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj) {
      return false;
    }
  
    public Object parseResponse(String obj) {
      Set<string> myTags = new Set<string>{
        'ET_RETURN',
        'E_OK'
      };
      Map<String, Object> mapResp = new Map<String, Object>();
      for (string tg : myTags) {
        if(obj.contains(tg) && obj.indexOf('<' + tg + '>')>= 0 && obj.lastIndexOf('</' + tg + '>') >=0 ){
          String myXmlString = obj.substring(
            obj.indexOf('<' + tg + '>'),
            obj.lastIndexOf('</' + tg + '>') +
            tg.length() +
            3
          );
          XMLSerializer xmlConvertToJson = new XMLSerializer();
          Set<string> items = new Set<string>();
          items.add('item');
          String jsonString = xmlConvertToJson.xmlToJSON(myXmlString, items);
          jsonString = jsonString.replace('""', 'null');
          jsonString = jsonString.replace(',null', '');
          jsonString = jsonString.replace('TYPE', 'TYPE_x');
          jsonString = jsonString.replace('NUMBER', 'NUMBER_x');
          Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(
            jsonString
          );
          mapResp.put(tg, mapAux.get(tg));
        }
        
      }
      CEN_ModifyClientObjectResponse resp = (CEN_ModifyClientObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_ModifyClientObjectResponse.class);
  
      return resp;
    }
  
  }