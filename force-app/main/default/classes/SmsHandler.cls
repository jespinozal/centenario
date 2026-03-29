public class SmsHandler {

    
    public static String SendSMS(String recipient, String messagedata){
        //	Data
        messagedata = messagedata.replace(' ', '%20');
        String endpoint = 'callout:WS_SmsHandler';
        String queryParam = 'action=sendmessage&'+
            'username=Api_KQV52&'+
            'password=X-IQ8DUTXD&'+
            'recipient='+recipient+'&'+
            'messagedata='+messagedata+'&'+
            'longMessage=false&'+
            'flash=false&'+
            'premiu%20m=false';
         
        //	Service
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint + '?' + queryParam);
            
        //	Consume
        String result = 'error';
        try{
            HttpResponse response = http.send(request);
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