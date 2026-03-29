public with sharing class CEN_BotEnhSetValues {
@InvocableMethod(label='Setear valores por bot enh' description='Setear valores por bot enh')
         /**
         * @description setea los valores del bot
         * @param input
         * @return devuelve la lista
        **/ 
        public static List<response> create(List<request> input) {
        if(Input == null || Input.size() <> 1) {return null;}

        request req = Input[0];  
        
        List<response> lista = new List<response>();
        
        response r =  new response();
      	r.Output1 = req.Input1;
		r.Output2 = req.Input2;
        r.Output3 = req.Input3;
        r.Output4 = req.Input4;
        r.Output5 = req.Input5;
        r.Output6 = req.Input6;
        r.outputNumber = req.Input7;   
        r.OutputConcat = req.Input4 + ' ' + req.Input5?.toUpperCase() + ' ' + req.Input6;
        r.OutputOne = 1;
        r.OutputTrue = true;
        r.OutputFalse = false;
        r.OutputCapitalLetters1 = String.isNotBlank(req.Input1)? req.Input1.toUpperCase():req.Input1;
        lista.add(r);
        return lista;
    }
    /**
    * @description datos que se obtiene del bot
    */      
    public class Request {
        @InvocableVariable public String input1;
        @InvocableVariable public String input2;
        @InvocableVariable public String input3;
        @InvocableVariable public String input4;
        @InvocableVariable public String input5;
        @InvocableVariable public String input6;
        @InvocableVariable public Integer input7;
    }
     /**
    * @description respuesta de datos
    */     
    public class Response{
        @InvocableVariable public String output1;
        @InvocableVariable public String output2;
        @InvocableVariable public String output3;
        @InvocableVariable public String output4;
        @InvocableVariable public String output5;
        @InvocableVariable public String output6;
        @InvocableVariable public String outputConcat;
        @InvocableVariable public Integer outputOne;
        @InvocableVariable public Boolean outputTrue;
        @InvocableVariable public Boolean outputFalse;
        @InvocableVariable public String outputCapitalLetters1;
        @InvocableVariable public Integer outputNumber;
        
    }
}