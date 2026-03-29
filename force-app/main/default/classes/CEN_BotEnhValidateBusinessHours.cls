public with sharing class CEN_BotEnhValidateBusinessHours {
    @InvocableMethod(label='Validar Horario de oficina - bot enh' description='Validar Horario de oficina - bot enh')
    /**
     * @description obtiene la información del ejecutivo
     * @param input
     * @return devuelve la lista
    **/     
    public static List<Boolean> validateBusinessHours(List<request> input) {
        
        request req = new request();
        String bussinnesHours = 'CEN_Ventas';
        
        if(Input.size()>0){
            req = Input[0]; 
            if(String.isNotBlank(req.BusinessHoursName)){
                BussinnesHours = req.BusinessHoursName;
            }
        }
        
        List<Boolean> lstRpta = new List<Boolean>();

        // Obtener el horario de oficina
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name =:BussinnesHours AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
		
        Datetime targetTime = System.now();

        //Validar si la hora actual está dentro del horario de oficina
        Boolean isWithin = BusinessHours.isWithin(bh.id, targetTime);
		//System.debug('isWithin >>'+isWithin);
        lstRpta.add(isWithin);
        return lstRpta;
    }
    /**
    * @description datos que se obtiene del bot
    */      
    public class Request {
        @InvocableVariable public String businessHoursName;
    }
}