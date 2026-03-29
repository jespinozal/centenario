/**
 * @description       : Clase para extraer el Value en vez de API de un Picklist.
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 30-12-2021
 * @last modified by  : @nttdata
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   30-12-2021   @nttdata     Initial Version
**/
public class CEN_ExtractTextFromPicklistField {
	@InvocableMethod
    public static List <Results> extract (List<Requests> requestList) {    

        List<Results> responseWrapper= new List<Results>();
        Set<id> recordId = New Set<id>();
        for(Requests r: requestList){
            recordId.add(r.recordId);
        }       
        List<Lead> record = [Select ID, tolabel(CEN_Medio__c) from Lead where Id IN :recordId];
        for(Lead listado:record){
            Results response = new Results();
            response.textValue = listado.CEN_Medio__c;
            responseWrapper.add(response);
        }
        return responseWrapper;
    }
    
    public  class Requests {
      @InvocableVariable(required=true)
      public String recordId;
    }    
    public class Results {     
      @InvocableVariable
      public String textValue;
    }
}