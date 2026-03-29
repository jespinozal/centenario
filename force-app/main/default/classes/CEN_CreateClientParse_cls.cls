public with sharing class CEN_CreateClientParse_cls implements CEN_CalloutParser {
    
    public Object parseRequest(String obj){
        return false;
    }
    
    public Object parseResponse(String obj){
        system.debug('CEN_CreateClientParse_cls-parseResponse: '+obj);
        XMLSerializer xmlConvertToJson = new XMLSerializer();
        Set<string> items = new Set<string>();
        items.add('item');
        String jsonString =  xmlConvertToJson.xmlToJSON(obj,items);
        jsonString= jsonString.replace('""', 'null');
        jsonString = jsonString.replace('TYPE', 'TYPE_x');
      	jsonString = jsonString.replace('NUMBER', 'NUMBER_x');
      	jsonString = jsonString.replace('SYSTEM', 'SYSTEM_x');
        system.debug('xmlToJSON: '+jsonString);
        CEN_CreateClientParse_cls.Envelope respon = (CEN_CreateClientParse_cls.Envelope) JSON.deserialize(jsonString, CEN_CreateClientParse_cls.Envelope.class);
        return respon.Envelope.Body.ZMF_CREAR_CLIENTEResponse;
    }       
    
    public class Envelope {
        public BodyHttp  Envelope;
        
    }
    
    public class BodyHttp {
        public BodyData  Body;
        
    }
    
    public class BodyData {
        public CEN_CreateClientResponse ZMF_CREAR_CLIENTEResponse;
        
    }

}