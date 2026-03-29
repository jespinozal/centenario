public with sharing class CEN_BotEnhSetPhraseValues {
@InvocableMethod(label='Setear valores por frase por bot ehn' description='Setear valores por frase por bot enh')
    /**
    * @description Método encargado de establecer los valores según la frase
    * @param input la frase
    * @return List<Response> contiene los valores relacionados
    */
    public static List<Response> setValues(List<Request> input) {

        if(input == null || input.size() <> 1){
            return null;
        }

        Request req = input[0];
        
        if(String.isBlank(req.Phrase)) {
            return null;
        }
                
       List<Response> lista = new List<Response>();
        
        Response r =  new Response();

        

        List<CEN_BotPhrase__c>  listBotPhrase = new List<CEN_BotPhrase__c>([SELECT id,CEN_Phrase__c,CEN_Canal__c,CEN_Formulario__c,CEN_Queue__c,CEN_Activo__c,CEN_Medio__c,CEN_MedioFrase__c,CEN_MarcaFlujo__c 
                                                                            FROM CEN_BotPhrase__c 
                                                                            WHERE CEN_Phrase__c =: req.Phrase 
                                                                            AND CEN_Activo__c=true]);
        
        if (!listBotPhrase.isEmpty()) {
          
            CEN_BotPhrase__c firstBotPhrase = listBotPhrase[0];

            r.canal = firstBotPhrase.CEN_Canal__c;
            r.medio = firstBotPhrase.CEN_Medio__c;
            r.formulario = firstBotPhrase.CEN_Formulario__c;
            r.medioFrase = firstBotPhrase.CEN_MedioFrase__c;
            r.marcaFlujo = firstBotPhrase.CEN_MarcaFlujo__c;
            r.idQueue = obtainQueueId(firstBotPhrase.CEN_Queue__c);
            //r.fromError = validateOrigin(firstBotPhrase.RS_IdCampaign__c);

        }
        lista.add(r);
        return lista;

    }

    /**
    * @description Obtiene id de la cola según el developerName
    * @param queueDeveloperName
    * @return String
    */
    public static String obtainQueueId(String queueDeveloperName){
        String typeGroup = 'Queue';
        if (String.isNotBlank(queueDeveloperName)) {

            List<Group >  listQueue = new List<Group>([SELECT id,Name,DeveloperName  
                                                       FROM Group 
                                                       WHERE Type = :typeGroup 
                                                       AND DeveloperName = :queueDeveloperName 
                                                       LIMIT 1]);

            if (!listQueue.isEmpty()) {

               Group firstQueue = listQueue[0];

               return firstQueue.id;
               
            }
        }
        return null;
    }

    /**
    * @description Devuelve true si la cadena contiene la palabra error
    * @param input
    * @return Boolean
    */
   /* public static Boolean validateOrigin(String input){
        if (String.isNotBlank(input)) {
            String lowercaseInput = input.toLowerCase();
            return lowercaseInput.contains('error');
        }
        return false;
    }*/

    /**
    * @description datos que se obtienen del bot
    */
    public class Request {
        @InvocableVariable public String phrase;
    }
    
    /**
    * @description datos que se otorgan al bot
    */
    public class Response{
        @InvocableVariable public String canal;
        @InvocableVariable public String medio;
        @InvocableVariable public String formulario;
        @InvocableVariable public String marcaFlujo;
        @InvocableVariable public String medioFrase;
        @InvocableVariable public String idQueue;
        //@InvocableVariable public BooleanfromError;
    }
}