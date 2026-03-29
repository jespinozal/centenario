public class CEN_BotEnhGetDetail {
    @InvocableMethod(label='Obtener detalle por bot enh' description='Obtener detalle por bot enh')
    /**
     * @description obtiene el detalle por bot
     * @param input
     * @return devuelve la lista
    **/ 
    public static List<response> validateDecisionCode (List<request> input){
		List<response> lstRpta = new List<response>();
        
        if(Input[0].Option != null){
            CEN_BotGetOptionsMenu.response option = Input[0].Option;
            response rs = new response();
            rs.Code = Option.Code;
            rs.Name = Option.FlowName; 
            lstRpta.add(rs);
        }  
        return lstRpta;
    }
     /**
    * @description respuesta de datos
    */ 
    public class Response{
        @InvocableVariable public String name;
        @InvocableVariable public String status; 
        @InvocableVariable public String id; 
        @InvocableVariable public String description; 
        @InvocableVariable public Integer code;  
    }
    /**
    * @description datos que se obtiene del bot
    */      
    public class Request {
        @InvocableVariable public CEN_BotGetOptionsMenu.response option;

    }
}