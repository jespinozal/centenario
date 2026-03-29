public class CEN_ConsultVisorLotes {
    private static String endpoint_ws = label.CEN_ws_visorlotes;
    
    public static List<CEN_ResponseContentVisorLotes> ByProyect(String codProyecto){    
        String body='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
            '<urn:ZaccoRfcIcmapLotesList>'+
            '<!--Optional:-->'+
            '<Codproyecto>'+codProyecto+'</Codproyecto>'+
            '</urn:ZaccoRfcIcmapLotesList>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        
        //	SERVICE
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint_ws);
        request.setMethod('POST');
        request.setHeader('Authorization', getAuthorization());
        //request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(body);
       // System.debug('REQUEST|'+ request);
        
        //	CONSUME
        HttpResponse response = null;
        if(Test.isRunningTest()){
            response = HttpMockFactory.respond(request);
        }else{
            response = http.send(request);
        }
        //	PARSE
        List<CEN_ResponseContentVisorLotes> lotes = parseLotesList(response);
        
        //System.debug(lotes);
        return lotes;
    }

    public static CEN_ResponseContentVisorLotes ByProyectCodloteManzana(String codLote, String codProyecto, String Manzana){
        String body='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:soap:functions:mc-style">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
            '<urn:ZaccoRfcIcmapLotesSingle>'+
            '<!--Optional:-->'+
            '<Codlote>'+codLote+'</Codlote>'+
            '<!--Optional:-->'+
            '<Codproyecto>'+codProyecto+'</Codproyecto>'+
            '<!--Optional:-->'+
            '<Manzana>'+Manzana+'</Manzana>'+
            '</urn:ZaccoRfcIcmapLotesSingle>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        
        //	SERVICE
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(endpoint_ws);
        request.setMethod('POST');
        request.setHeader('Authorization', getAuthorization());
        //request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('Content-Type', 'text/xml');
        request.setBody(body);
        //System.debug('REQUEST|'+ request);
        
        //	CONSUME
        HttpResponse response = null;
        if(Test.isRunningTest()){
            response = HttpMockFactory.respond(request);
        }else{
            response = http.send(request);
        }
        
        //	PARSE
        CEN_ResponseContentVisorLotes lote=parseLote(response);
        System.debug(lote.toString());
        return lote;
    }
    private static CEN_ResponseContentVisorLotes parseLote(HttpResponse response){        
        String body_xml = response.getBody();
        System.debug(LoggingLevel.INFO, body_xml);
        //	DEFINE THE START AND THE END OF THE XML OUTPUT LIST
        Integer index_start_output=body_xml.indexOf('<Output');
        Integer index_end_output=body_xml.indexOf('</n0:ZaccoRfcIcmapLotesSingleResponse>');
        String outputlist=body_xml.substring(index_start_output, index_end_output);
        
        //	USE DOM DOCUMENT FOR READ THE XML RESPONSE
        Dom.Document doc = new Dom.Document();
        doc.load(outputlist);
        Dom.XMLNode root = doc.getRootElement();
        
        //	PARSE THE ITEM FROM A RESPONSE
        CEN_ResponseContentVisorLotes lote = CEN_ResponseContentVisorLotes.parseFromXMLitem(root);
            
        return lote;
     }
    
    private static String getAuthorization(){
         //	AUTHORIZATION
        //String user='CENT_VISOR2';
        //String pass='Visor$20';
        String user=label.CEN_user_visorlotes;
        String pass=label.CEN_pass_visorlotes;
        Blob headerValue = Blob.valueOf(user + ':' + pass);
        String authorization = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authorization;
    }

    public static List<CEN_ResponseContentVisorLotes> parseLotesList(HttpResponse response){
        String body_xml = response.getBody();
        System.debug(body_xml);
        //	DEFINE THE START AND THE END OF THE XML OUTPUT LIST
        Integer index_start_output=body_xml.indexOf('<OutputList');
        Integer index_end_output=body_xml.indexOf('</n0:ZaccoRfcIcmapLotesListResponse>');
        String outputlist=body_xml.substring(index_start_output, index_end_output);
        
        //	USE DOM DOCUMENT FOR READ THE XML RESPONSE
        Dom.Document doc = new Dom.Document();
        doc.load(outputlist);
        Dom.XMLNode root = doc.getRootElement(); 
        List<CEN_ResponseContentVisorLotes> lotes=new List<CEN_ResponseContentVisorLotes>();
        
        //	PARSE THE ITEM FROM A RESPONSE
        for(Dom.XmlNode item:root.getChildren()){
            CEN_ResponseContentVisorLotes newlote = CEN_ResponseContentVisorLotes.parseFromXMLitem(item);
            lotes.add(newlote);
            //System.debug(newlote.toString());
        }
        System.debug('Total Lotes: ' + lotes.size());
        return lotes;
    }
}