public class CEN_Visor_Centenario {
    @AuraEnabled
    public static Response getData(String idOportunidad){
        Response respuesta = new Response();
        respuesta.status='ERROR';
        respuesta.mensaje='Hubo un problema intentenlo más tarde.';
        Proyecto__c proyecto = null;
        Opportunity oportunidad =null;
        try{
            oportunidad = [SELECT Id, CEN_Proyecto__c, StageName FROM Opportunity WHERE Id=:idOportunidad LIMIT 1];
        }catch(Exception ex){
            System.debug('No se encontró la oportunidad '+idOportunidad+'. Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(oportunidad!=null){
            respuesta.oportunidad = oportunidad;
            if(oportunidad.StageName=='Cotización'){
                if(oportunidad.CEN_Proyecto__c!=null){
                    try{
                        proyecto = [SELECT Id, Name, CEN_CODIGOSAP__c FROM Proyecto__c WHERE Id=:oportunidad.CEN_Proyecto__c LIMIT 1];
                    }catch(Exception ex){
                        System.debug('No se encontró el proyecto '+oportunidad.CEN_Proyecto__c+'. Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    }
                    if(proyecto!=null){
                        respuesta.status='OK';
                        respuesta.endpoint = getEndpoint(oportunidad.Id, proyecto.CEN_CODIGOSAP__c);
                        respuesta.proyecto = proyecto;
                        respuesta.mensaje='Se conectó al visor. Asegurese de no tener las pestañas emergentes bloqueados en su navegador.';
                    }else{
                        respuesta.status='NO PROYECTO';
                        respuesta.mensaje='No se encontró el proyecto y su etapa en la oportunidad. Asegurese haber seleccionado alguno.';
                    }
                }else{
                    respuesta.status='NO PROYECTO';
                    respuesta.mensaje='Esta oportunidad no tiene un proyecto y etapa seleccionado. Asegurese haber seleccionado alguno.';
                }
            }else{
                respuesta.status='NO PERMITIDO';
                respuesta.mensaje='Lo sentimos, solo puede abrir el visor en la etapa de Cotización de la oportunidad.';
            }            
       }
        else{
            respuesta.mensaje='No se encontró la oportunidad. Probablemente este eliminado.';
        }
       return respuesta;
    }
    
    public static String getEndpoint(String idOportunidad, String codProyecto){
        String token = getToken();
        if(String.isBlank(token)){
            token = getToken();
            if(String.isBlank(token)){
                return '';
            }
        }
        String endpoint = '/salesforce?token='+token+'&OpportunityId='+idOportunidad+'&IdProyecto='+codProyecto;
        NamedCredential ncredencial = null;
        try{
            ncredencial = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName='CEN_api_visor' LIMIT 1];
        }catch(Exception ex){
            System.debug('No se encontró la credencial oportunidad '+idOportunidad+'. Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(ncredencial!=null){
            endpoint = ncredencial.Endpoint + endpoint;
        }else if(ncredencial==null && String.isNotBlank(label.CEN_api_visor_lotes)){
            endpoint = label.CEN_api_visor_lotes + endpoint;
        }else{
            endpoint = '';
        } 
        return endpoint;
    }
    public static String getToken(){
        CEN_TokenCacheController cc = new CEN_TokenCacheController();
        String token = cc.GetTokenFromCacheOrg(cc.token_label_name_visor);
        System.debug('token in getToken 1: '+token);
        if(String.isNotBlank(token)){
            return token;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CEN_api_visor'+'/token');
        request.setBody('{"username":"'+label.CEN_user_visor_lotes_web+'","password":"'+label.CEN_pass_visor_lotes_web+'"}');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setTimeout(120000);
        HttpResponse response = null;
        if(Test.isRunningTest()){
            response = HttpMockFactory.respond(request);
        }else{
            response = http.send(request);
        }
        System.debug(response);
        if(response.getStatusCode()==200){
            Map<String, Object> br = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('br: '+br);
            token = String.valueOf(br.get('token'));
            if(String.isNotBlank(token)){
                cc.StoreTokenInCacheOrg(token, cc.token_label_name_visor);
            }
        }
        System.debug('token in getToken 2: '+token);
        return token;
    }
 
    public class Response{
        @AuraEnabled public Opportunity oportunidad {get;set;}
        @AuraEnabled public Proyecto__c proyecto {get;set;}
        @AuraEnabled public String endpoint {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String mensaje {get;set;}
    }
}