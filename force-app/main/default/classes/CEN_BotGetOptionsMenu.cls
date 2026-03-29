public with sharing class CEN_BotGetOptionsMenu {
    @InvocableMethod(label='Obtener opciones por bot' description='Obtener opciones por bot')
    public static List<List<response>> getOptions(List<request> Input) {

        if(Input == null || Input.size() <> 1) return null;

        request req = Input[0];

        List<List<response>> lstRespuesta = new List<List<response>>();
        List<response> menu = new List<response>();
        
        string query = 'SELECT Id, CEN_OptionName__c, CEN_OptionEmoji__c, CEN_Order__c '+
            			'FROM CEN_ConfigurationOptionMenu__c ' +
            			'WHERE CEN_Active__c = true AND CEN_Channel__c INCLUDES (\'' + req.Channel + '\') '+
        				(String.isNotBlank(req.Menu)?' AND CEN_NameMenu__c = \'' + req.Menu + '\'':'AND CEN_NameMenu__c = \'\'')+
            			'ORDER BY CEN_Order__c';
        List<CEN_ConfigurationOptionMenu__c> options  = Database.query(query);

        if(options.size()>0){
            for(CEN_ConfigurationOptionMenu__c op: options){
                response res = new response();
                res.Name = String.isNotBlank(op.CEN_OptionEmoji__c)? op.CEN_OptionEmoji__c  + ' ' + op.CEN_OptionName__c: op.CEN_OptionName__c;
                res.FlowName = op.CEN_OptionName__c;
                res.Code = Integer.valueOf(op.CEN_Order__c);
                menu.add(res);
            }
        }
        lstRespuesta.add(menu);
        return lstRespuesta;

    }

    public class request {
        @InvocableVariable public String Menu;
        @InvocableVariable public String Channel;
    }

    public class response{
        @InvocableVariable public String Name;
        @InvocableVariable public String FlowName;
        @InvocableVariable public Integer Code;
    }
}