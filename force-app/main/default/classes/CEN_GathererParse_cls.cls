public with sharing class CEN_GathererParse_cls implements CEN_CalloutParser {
    public Object parseRequest(String obj){
        return false;
    }
    
    public Object parseResponse(String obj){
        system.debug('CEN_GathererParse_cls-parseResponse: '+obj);
        XMLSerializer xmlConvertToJson = new XMLSerializer();
        Set<string> items = new Set<string>();
        items.add('item');
        String jsonString =  xmlConvertToJson.xmlToJSON(obj,items);
        jsonString= jsonString.replace('""', 'null');
        system.debug('xmlToJSON: '+jsonString);
        CEN_GathererParse_cls.Envelope respon = (CEN_GathererParse_cls.Envelope) JSON.deserialize(jsonString, CEN_GathererParse_cls.Envelope.class);
        return respon.Envelope.Body.ZRFC_OTC_PROCESAR_PAGO_WSResponse;
    }       
    
    
    public class Envelope {
        public BodyHttp  Envelope;
        
    }
    
    public class BodyHttp {
        public BodyData  Body;
        
    }
    
    public class BodyData {
        public CEN_GathererResponse ZRFC_OTC_PROCESAR_PAGO_WSResponse;
        
    }
    
}