/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-01-2021   @everis.com   Initial Version
**/
public with sharing class CEN_ProcessPaymentParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
  
    public Object parseResponse(String obj){
      system.debug('CEN_ProcessPaymentParse_cls-parseResponse: '+obj);
      Set<string> myTags = new Set<string>{
      'BELNR_ANTI',
      'BUKRS_ANTI',
      'ET_PAGOS_CLIENTE',
      'ET_RETURN',
      'E_OK',
      'GJAHR_ANTI'
    };
    
    Map<String, Object> mapResp = new Map<String, Object>();
    for (string tg : myTags) {
      if(obj.contains(tg) && obj.indexOf('<' + tg + '>')>= 0 && obj.lastIndexOf('</' + tg + '>') >=0 ){
            try{
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
      jsonString = jsonString.replace('SYSTEM', 'SYSTEM_x');
      Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(
        jsonString
      );
      mapResp.put(tg, mapAux.get(tg));
                } catch (Exception ex) {
            system.debug('Error: '+ex.getMessage());
        }
         
        }
    }
    CEN_ProcessPaymentObjectResponse resp = (CEN_ProcessPaymentObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_ProcessPaymentObjectResponse.class);
    return resp;
  } 
  }