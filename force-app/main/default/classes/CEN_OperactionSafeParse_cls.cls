/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-11-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
 **/
public with sharing class CEN_OperactionSafeParse_cls implements CEN_CalloutParser {
  public Object parseRequest(String obj) {
    return false;
  }

  public Object parseResponse(String obj) {
    Set<string> myTags = new Set<string>{
      'ET_ANTICIPOS',
      'ET_CUOTAS_PROFORMA_SF',
      'ET_INTERLOCUTORES',
      'ET_RETURN',
      'E_CAB_PROFORMA_SF',
      'IT_CUOTAS_PREPAGO',
      'ES_DATOS_PREPAGO',
      'ET_DETALLE_DSCTO_ADICIONAL',
      'ET_DETALLE_PALANCAS',
      'ET_MENSAJE_DSCTO_PALANCAS',
      'ET_TASAS_POLITVEN',
      'ET_CUOTAS_SIMU_PROF'
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
        jsonString = jsonString.replace('SYSTEM', 'SYSTEM_x');
        jsonString = jsonString.replace('CASH_FIRMA_MIN__--25', 'CASH_FIRMA_MIN_x_x25');
        jsonString = jsonString.replace('CASH_FIRMA_MAX__--25', 'CASH_FIRMA_MAX_x_x25');
        Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(
          jsonString
        );
        mapResp.put(tg, mapAux.get(tg));
      }

    }
    CEN_OperactionSafeObjectResponse resp = (CEN_OperactionSafeObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_OperactionSafeObjectResponse.class);

    return resp;
  }

}