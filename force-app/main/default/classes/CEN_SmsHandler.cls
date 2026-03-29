public class CEN_SmsHandler {
    
    public static String SendSMS(String recipient, String messagedata){
        
        system.debug('Recipient: '+recipient);
        system.debug('Messagedata '+messagedata.length()+' characters: '+messagedata);
        //	Data
        //messagedata = messagedata.replace(' ', '%20');
        //messagedata = messagedata.replace('ñ','%C3%B1');
        
        messagedata = EncodingUtil.urlEncode(messagedata, 'UTF-8');
        
        String endpoint = 'callout:WS_SmsHandler';
        String queryParam = 'action=sendmessage&'+
            'username=Api_KQV52&'+
            'password=X-IQ8DUTXD&'+
            'recipient='+recipient+'&'+
            'messagedata='+messagedata+'&';
        if(messagedata.length()<160){
            queryParam = queryParam + 'longMessage=false&'+
            'flash=false&';
        }else{
             queryParam = queryParam + 'longMessage=true&'+
            'flash=false&';
        }
        
        if(messagedata.containsAny('ñáéíóú')){
              queryParam = queryParam +'premiu%20m=true';
        }else{
             queryParam = queryParam +'premiu%20m=false';
        }
        
        System.debug('SMS a enviar:\n'+queryParam);
        //	Service
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint + '?' + queryParam);
            
        //	Consume
        String result = 'error';
        try{
            HttpResponse response = null;
            if(Test.isRunningTest()){
                response = HttpMockFactory.respond(request);
            }else{
                response = http.send(request);
            }
            System.debug('Response |');
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            
            //	Parse response
            if(response.getStatusCode()==200){
                String body_xml = response.getBody();
                //	DEFINE THE START AND THE END OF THE XML OUTPUT LIST
                Integer index_start_output=body_xml.indexOf('<response>');
                Integer index_end_output=body_xml.indexOf('</response>');
                String outputlist=body_xml.substring(index_start_output, index_end_output + 11);
                
                Dom.Document doc=new Dom.Document();
                doc.load(response.getBody());
                Dom.XMLNode root = doc.getRootElement();
                Map<String, Object> map_resp = new Map<String, Object>();
                for(Dom.XmlNode item:root.getChildren()){
                    map_resp.put(item.getName(), item.getText());
                }
                System.debug('map_resp | ' + map_resp);
                result = map_resp.get('action').toString();
                System.debug('Result: ' + result);
            }else{
                result = 'error';
            }
        }catch(Exception e){
            System.debug('Error' + e);
            System.debug('Type: ' + e.getTypeName());
            System.debug('Cause: ' + e.getCause());
            System.debug('Message: ' + e.getMessage());
            result = 'error';
        }
        return result;
    }
}