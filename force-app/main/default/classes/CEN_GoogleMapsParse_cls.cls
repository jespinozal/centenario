/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 05-09-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_GoogleMapsParse_cls implements CEN_CalloutParser {

    public Object parseRequest(String obj){
        return false;
    }

    public Object parseResponse(String obj){
        XMLSerializer xmlConvertToJson = new XMLSerializer();
        Set<string> items = new Set<string>();
        items.add('item');
        String jsonString =  xmlConvertToJson.xmlToJSON(obj,items);
        jsonString= jsonString.replace('""', 'null');
        jsonString = jsonString.replace('TYPE', 'TYPE_x');
      	jsonString = jsonString.replace('NUMBER', 'NUMBER_x');
      	jsonString = jsonString.replace('SYSTEM', 'SYSTEM_x');

        CEN_GoogleMapsParse_cls.Envelope respon = (CEN_GoogleMapsParse_cls.Envelope) JSON.deserialize(jsonString, CEN_GoogleMapsParse_cls.Envelope.class);
        return respon.Envelope.Body.ZWS_REGISTRA_URL_MAPSResponse;
    }

    public class Envelope {
        public BodyHttp  Envelope;

    }

    public class BodyHttp {
        public BodyData  Body;

    }

    public class BodyData {
        public CEN_GoogleMapsResponse ZWS_REGISTRA_URL_MAPSResponse;
    }

}