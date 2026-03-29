public class CEN_WS_Consultar_Datos {
    
    public class DatosPersona{
        @AuraEnabled public String Nombres {get;set;}
        @AuraEnabled public String Apellidos {get;set;}
    }
    
    public static DatosPersona ReniecDNI(String dni){
        DatosPersona data = null;
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:WS_Reniec'+'/Consultar.php?dni='+dni);
        request.setMethod('GET');
        request.setTimeout(20000);

        HttpResponse response = null;
        if(Test.isRunningTest()){
            response = HttpMockFactory.respond(request);
        }else{
            response = http.send(request) ;    
        }
        
        if(response.getStatusCode()==200){
            String full_name = response.getBody();
            if(String.isNotBlank(full_name.trim())){
                data = new DatosPersona();
                Integer cantidad_espacios = full_name.countMatches(' ');                
                if(cantidad_espacios>=3){
                    data.Nombres = full_name.substringBefore(' ');
                    full_name = full_name.substringAfter(' ');
                    data.Nombres = WordToUpperCase.ConvertWord(data.Nombres +' '+full_name.substringBefore(' '));
                    data.Apellidos = WordToUpperCase.ConvertWord(full_name.substringAfter(' '));
                }else{
                    data.Nombres = WordToUpperCase.ConvertWord(full_name.substringBefore(' '));
                    data.Apellidos = WordToUpperCase.ConvertWord(full_name.substringAfter(' '));
                }
                if(String.isNotBlank(data.Nombres)){
                     data.Nombres = data.Nombres.trim();
                }
                if(String.isNotBlank(data.Apellidos)){
                     data.Apellidos = data.Apellidos.trim();
                }
            }
            System.debug('data: '+data);
        }
        
        return data;        
    }
 
}