public with sharing class CEN_BotEnhGetOptionsMenu {
    @InvocableMethod(label='Obtener opciones por bot enh' description='Obtener opciones por bot enh')
    /**
     * @description Obtener opciones
     * @param input
     * @return lstRespuesta
    **/ 
    public static List<List<Response>> getOptions(List<Request> input) {

        if(input == null || input.size() <> 1) {return null;}

        Request req = input[0];

        List<List<Response>> lstRespuesta = new List<List<Response>>();
        List<Response> menu = new List<Response>();

        String channel = String.escapeSingleQuotes(req.channel);
        String reqMenu = String.escapeSingleQuotes(req.menu);
        
        string query = 'SELECT Id, CEN_OptionName__c, CEN_OptionEmoji__c, CEN_Order__c '+
            			'FROM CEN_ConfigurationOptionMenu__c ' +
            			'WHERE CEN_Active__c = true AND CEN_Channel__c INCLUDES (\'' + channel  + '\') '+
        				(String.isNotBlank(reqMenu)?' AND CEN_NameMenu__c = \'' + reqMenu + '\'':'AND CEN_NameMenu__c = \'\'')+
            			'ORDER BY CEN_Order__c';

                        
        List<CEN_ConfigurationOptionMenu__c> options  = Database.query(query);

        if(options.size()>0){
            for(CEN_ConfigurationOptionMenu__c op: options){
                Response res = new Response();
                res.name = String.isNotBlank(op.CEN_OptionEmoji__c)? op.CEN_OptionEmoji__c  + ' ' + op.CEN_OptionName__c: op.CEN_OptionName__c;
                res.flowName = op.CEN_OptionName__c;
                res.code = Integer.valueOf(op.CEN_Order__c);
                menu.add(res);
            }
        }
        lstRespuesta.add(menu);
        return lstRespuesta;

    }

    /**
     * @description Class representing a request service.
    */
    public class Request {
        @InvocableVariable public String menu;
        @InvocableVariable public String channel;
    }

    /**
     * @description Class representing a response service.
    */
    public class Response{
        @InvocableVariable public String name;
        @InvocableVariable public String flowName;
        @InvocableVariable public Integer code;
    }

}