public class CEN_WS_SolicitudContratoVenta {
    private CEN_TokenCacheController token_cache_controller;
    private String endpoint = label.CEN_url_api_onbase;
    
    public CEN_WS_SolicitudContratoVenta(){
        token_cache_controller = new CEN_TokenCacheController();
    }
    public class ResponseSolicitud{
        public String NroSolicitud;
        public String IDDocumento;
        public String IDBandeja;
    }
    public class ResponseUpdateSolicitud{
        public String NroSolicitud;
    }
    public class ResponseController{
        public String message;
        public Boolean ok;
        public ResponseSolicitud responseSolicitud;
        public ResponseUpdateSolicitud responseUpdateSolicitud;
    }
    /*
     * Esta función consume la API de M_GenerarSolicitud Onbase
     * Response: "NroSolictud" de la nueva solicitud
     * Content: Contenido xml de información necesaria para generar nueva solicitud
	*/
    public ResponseController M_GenerarSolicitudPreSolicitud(String content){
        System.debug('<!--M_GenerarSolicitudPreSolicitud inicia');
        ResponseController respuesta_m = new ResponseController();
        respuesta_m.ok = false;
        respuesta_m.message = 'Hubo un problema. Por favor, inténtelo más tarde.';        
        ResponseSolicitud respuesta = null;
        //	Validate Token
        String access_token = GetToken();
        if(String.isBlank(access_token)){
            access_token = GetToken();
        }
        if(String.isBlank(access_token)){
            return null;
        }
        System.debug(content);
        //	Make Service
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint+'/api/post');
        System.debug(LoggingLevel.INFO, request.getEndpoint());
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + access_token);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/xml');
        request.setTimeout(20000);
        request.setBody(content);
        Http http = new Http();
        //	Consume
        HttpResponse response = null;
        try{
            if(Test.isRunningTest()){
                response = HttpMockFactory.respond(request);
            }else{
                response = http.send(request);
            }
        }catch(Exception ex){
            System.debug('Exception trying create solicitud onbase: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        System.debug('response from api: ' + response);
        if(response!=null){
            System.debug('response from api body: ' + response.getBody());
            //	Parse response
            if(response.getStatusCode()==200){
                try{
                    respuesta = (ResponseSolicitud)JSON.deserializeStrict(response.getBody(), ResponseSolicitud.class);
                    respuesta_m.responseSolicitud = respuesta;
                    respuesta_m.ok = true;
                    respuesta_m.message = 'Se envió la data ok';
                }catch(JSONException ex){
                    System.debug('JSON Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                    respuesta_m.ok = false;
                    respuesta_m.message = 'OnBase: '+response.getBody();
                }
            }else{
                System.debug('Error tratando de crear solicitud: ' + response.getStatusCode() + '. Body: '+response.getBody());
                respuesta_m = generarError(respuesta_m, response);
            }
        }
        System.debug('<!--M_GenerarSolicitudPreSolicitud termina: '+respuesta_m);
        return respuesta_m;
    }

    /*
     * Esta función consume la API de M_ActualizarSolicitud Onbase
     * Response: ResponseUpdateSolicitud - Estado de actualizacion de la solicitud
     * Content: Contenido xml de información necesaria para actualizar la solicitud
	*/
    public ResponseController M_ActualizarSolicitudPreSolicitud(String content){
        System.debug('<!--M_ActualizarSolicitudPreSolicitud inicia');
        ResponseController respuesta_m = new ResponseController();
        respuesta_m.ok = false;
        respuesta_m.message = 'Hubo un problema. Por favor, inténtelo más tarde.';        
        ResponseUpdateSolicitud respuesta = null;
        //	Validate Token
        String access_token = GetToken();
        if(String.isBlank(access_token)){
            access_token = GetToken();
        }
        if(String.isBlank(access_token)){
            return null;
        }
        System.debug(content);
        //	Make Service
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint+'/api/put');
        System.debug(LoggingLevel.INFO, request.getEndpoint());
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Bearer ' + access_token);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/xml');
        request.setTimeout(20000);
        request.setBody(content);
        Http http = new Http();
        //	Consume
        HttpResponse response = null;
        try{
            if(Test.isRunningTest()){
                response = HttpMockFactory.respond(request);
            }else{
                response = http.send(request);
            }
        }catch(Exception ex){
            System.debug('Exception trying update solicitud onbase: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        System.debug('response from api: ' + response);
        if(response!=null){
            System.debug('response from api body: ' + response.getBody());
            //	Parse response
            if(response.getStatusCode()==200){
                try{
                    respuesta = (ResponseUpdateSolicitud)JSON.deserializeStrict(response.getBody(), ResponseUpdateSolicitud.class);
                    respuesta_m.responseUpdateSolicitud = respuesta;
                    respuesta_m.ok = true;
                    respuesta_m.message = 'Se envió la data ok';
                }catch(JSONException ex){
                    System.debug('JSON Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                    respuesta_m.ok = false;
                    respuesta_m.message = 'OnBase: '+response.getBody();
                }
            }else{
                System.debug('Error tratando de actualizar solicitud: ' + response.getStatusCode() + '. Body: '+response.getBody());
                respuesta_m = generarError(respuesta_m, response);
            }
        }
        System.debug('<!--M_ActualizarSolicitudPreSolicitud termina: '+respuesta_m);
        return respuesta_m;
    }

    private ResponseController generarError(ResponseController respuesta_m, HttpResponse response){
      String access_token = null;
      if(response.getStatusCode()==401){
          access_token = getTokenFromApi();
      }else if(response.getStatusCode()==500){
          respuesta_m.message = 'Servicio de OnBase: Error 500';
          try{
              Map<String,Object> response_map = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
              respuesta_m.message += ', '+response_map.get('Message');
          }catch(Exception ex){
              System.debug('Exception tratando el response body: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
          }
      }
      return respuesta_m;
    }
    
    public String M_Token(){
        System.debug('<!--M_Token iniciando');
        String access_token = '';
        //	Make Service
        String body = 'username='+EncodingUtil.urlEncode(label.CEN_url_api_onbase_user,'UTF-8')+
            '&password='+EncodingUtil.urlEncode(label.CEN_url_api_onbase_pass,'UTF-8')+
            '&grant_type='+EncodingUtil.urlEncode('password','UTF-8');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint+'/token');
        System.debug(LoggingLevel.INFO, request.getEndpoint());
        System.debug(LoggingLevel.INFO, body);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setTimeout(10000);
        request.setBody(body);
        
        //	Consume
        HttpResponse response = null;
        if(Test.isRunningTest()){
            response = HttpMockFactory.respond(request);
        }else{
            response = http.send(request);
        }
         System.debug('response from api: ' + response);
        if(response!=null){
            System.debug('response from api body: ' + response.getBody());
            if(response.getStatusCode()==200){
                try{
                    Map<String,Object> parsed=(Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    access_token= parsed.get('access_token').toString();
                }catch(Exception ex){
                    System.debug('Exception trying parse token from api token onbase: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                }
            }else{
                System.debug('Error: Algó sucedió con el servicio.');
                System.debug('Info:\nStatus code HTTP: '+response.getStatusCode()+'\nBody message: '+response.getBody());
            }
        }
        System.debug('--> M_Token finalizando');
        return access_token;
    }    
    private String getTokenFromApi(){
        String access_token = M_Token();
        System.debug('Access_token from api token onbase: ' + access_token);
        if(String.isNotBlank(access_token)){
            System.debug('Guardando access_token en caché de org');
            token_cache_controller.StoreTokenInCacheOrg(access_token, token_cache_controller.token_label_name_onbase);
            return access_token;
        }else{
            System.debug('No se obtuvo un access_token desde el sevicio Onbase');
        }
        return null;
    }
    public String GetToken(){
        System.debug('<!--GetToken inicia');
        String access_token = null;
        try{
            access_token = token_cache_controller.GetTokenFromCacheOrg(token_cache_controller.token_label_name_onbase);
        }catch(Exception ex){
            System.debug('Exception trying get token onbase from cache: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        if(String.isBlank(access_token)){
            //	GET TOKEN FROM API AND STORE IN CACHE
            access_token = getTokenFromApi();
        }
        System.debug('Access_token: ' + access_token);
        System.debug('-->GetToken termina');
        return access_token;
    }
}