/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-02-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-15-2021   @everis.com   Initial Version
**/
public class CEN_TransferOwnerObjectParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
  
    public Object parseResponse(String obj){
        Set<string> myTags = new Set<string>{
            'ET_RETURN',
            'E_OK',
            'ET_PAGOS_CLIENTE'
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

              if(myXmlString.contains('<item>')){
                myXmlString = myXmlString.remove('<' + tg + '>');
                myXmlString = myXmlString.remove('</' + tg + '>');
                String[] arrStrObj = myXmlString.split('<item>');
                List<CEN_TransferOwnerObjectResponse.PAGO> myItems = new List<CEN_TransferOwnerObjectResponse.PAGO>();
                Map<String, Object> mapItem = new Map<String, Object>();
                for(String strObj: arrStrObj){
                    XMLSerializer xmlConvertToJson = new XMLSerializer();
                    String jsonString = xmlConvertToJson.xmlToJSON('<item>'+strObj);
                    jsonString = jsonString.replace('""', 'null');
                    Map<String, Object> mapItemAux = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

                    if(mapItemAux.get('item')!=null){
                      CEN_TransferOwnerObjectResponse.PAGO myItem = (CEN_TransferOwnerObjectResponse.PAGO)JSON.deserialize( JSON.serialize(mapItemAux.get('item')), CEN_TransferOwnerObjectResponse.PAGO.class);
                        myItems.add(myItem);
                    }
                }                  
                mapItem.put('item', myItems);
                mapResp.put(tg, mapItem);
              }else{
                XMLSerializer xmlConvertToJson = new XMLSerializer();
                Set<string> items = new Set<string>();
                items.add('item');
                String jsonString = xmlConvertToJson.xmlToJSON(myXmlString, items);
                jsonString = jsonString.replace('""', 'null');
                jsonString = jsonString.replace(',null', '');
                Map<String, Object> mapAux = (Map<String, Object>) JSON.deserializeUntyped(
                  jsonString
                );
                mapResp.put(tg, mapAux.get(tg));
              }

              


            }
            
          }
          CEN_TransferOwnerObjectResponse resp = (CEN_TransferOwnerObjectResponse)JSON.deserialize( JSON.serialize(mapResp), CEN_TransferOwnerObjectResponse.class);
      return resp;
  }
  
}