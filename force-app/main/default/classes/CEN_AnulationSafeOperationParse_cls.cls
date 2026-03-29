/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 07-24-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-13-2021   @everis.com   Initial Version
**/
public with sharing class CEN_AnulationSafeOperationParse_cls implements CEN_CalloutParser {
  public Object parseRequest(String obj) {
          return false;
      }
      public Object parseResponse(String obj) {

          System.debug('Objeto: ' + obj);
      Set<string> myTags = new Set<string>{
            'ET_RETURN',
            'ET_DOCUMENTOS',
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
            system.debug('JsonString: ' + jsonString);
          jsonString = jsonString.replace('""', 'null');
          jsonString = jsonString.replace(',null', '');
          jsonString = jsonString.replace('"TYPE"', '"TYPE_x"');
          Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(
            jsonString
          );
          mapResp.put(tg, mapAux.get(tg));

        }
      }
          system.debug('mapResp: ' + mapResp);
          CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse resp = (CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse.class);
  system.debug('Response final: ' + resp);
      return resp;
    }
  }