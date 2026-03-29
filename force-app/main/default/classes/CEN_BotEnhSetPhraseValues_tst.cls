/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 08-11-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   08-11-2024   Diego Bravo   Initial Version
**/
@isTest
public class CEN_BotEnhSetPhraseValues_tst {
    
    @TestSetup
    static void setup(){
        
        string developerNameQueue='';
        List<Group >  listQueue = [SELECT id,Name,DeveloperName  from Group where Type ='Queue'  limit 1];
        
        if (!listQueue.isEmpty()) {
            Group firstQueue = listQueue[0];
            developerNameQueue  = firstQueue.DeveloperName; 
        }
        
        CEN_BotPhrase__c botPhrase = new CEN_BotPhrase__c();
        botPhrase.CEN_Phrase__c='Hola, estoy interesado en el proyecto  Altos del Valle - Moche, Trujillo';
        botPhrase.CEN_Queue__c=developerNameQueue;
        botPhrase.CEN_Activo__c= true;
        //botPhrase.RS_IdCampaign__c='Cyber';
        insert(botPhrase);
        
        CEN_BotPhrase__c botPhrase2 = new CEN_BotPhrase__c();
        botPhrase2.CEN_Phrase__c='Hola, estoy interesado en el proyecto  La Planicie - Carabayllo, Lima';
        botPhrase2.CEN_Queue__c=developerNameQueue;
        //botPhrase2.CEN_IdCampaign__c='';
        insert botPhrase2;
        
        CEN_BotPhrase__c botPhrase3 = new CEN_BotPhrase__c();
        botPhrase3.CEN_Phrase__c='Hola, estoy interesado en el proyecto  Entrevalles - Km 40 Panam. Sur, Lurín';
        //botPhrase3.RS_IdCampaign__c='Pagina error';
        insert botPhrase3;
     }
    
    @isTest static void testSetValues() {
        CEN_BotEnhSetPhraseValues.request req = new CEN_BotEnhSetPhraseValues.request();
        // req.Phrase = 'Hola, estoy interesado en el proyecto  Golf De Santa Clara - Lima Este';
        req.Phrase = 'Hola, estoy interesado en el proyecto  Altos del Valle - Moche, Trujillo';

        List<CEN_BotEnhSetPhraseValues.response> result = CEN_BotEnhSetPhraseValues.setValues(new List<CEN_BotEnhSetPhraseValues.request>{req});

        System.assertEquals(1, result.size(),'Un resultado.');
        CEN_BotEnhSetPhraseValues.response r = result[0];
        //System.assertEquals('Cyber', r.CampaignId,'Id campaña correcto');
    }
   
    @isTest static void testSetValuesWithoutCampaignId() {
        CEN_BotEnhSetPhraseValues.request req = new CEN_BotEnhSetPhraseValues.request();
        req.Phrase = 'Hola, estoy interesado en el proyecto  Arenas de San Antonio - Km 77 Panam. Sur, Lima';

        List<CEN_BotEnhSetPhraseValues.response> result = CEN_BotEnhSetPhraseValues.setValues(new List<CEN_BotEnhSetPhraseValues.request>{req});

        System.assertEquals(1, result.size(),'Un resultado.');
        CEN_BotEnhSetPhraseValues.response r = result[0];
        //System.assertEquals(null, r.CampaignId, 'Sin id campaña');
    }
    
    @isTest static void testSetValuesWithoutQueueId() {
        CEN_BotEnhSetPhraseValues.request req = new CEN_BotEnhSetPhraseValues.request();
        req.Phrase = 'Hola, estoy interesado en el proyecto  Finca Bonita - Km 72 Panam. Sur, Lima';

        List<CEN_BotEnhSetPhraseValues.response> result = CEN_BotEnhSetPhraseValues.setValues(new List<CEN_BotEnhSetPhraseValues.request>{req});

        System.assertEquals(1, result.size(),'Un resultado.');
        CEN_BotEnhSetPhraseValues.response r = result[0];
        System.assertEquals(null, r.idQueue,'Sin cola');
    }
    
    @isTest static void testSetValuesNull() {
        CEN_BotEnhSetPhraseValues.request req = new CEN_BotEnhSetPhraseValues.request();
        req.Phrase = null;
        
        List<CEN_BotEnhSetPhraseValues.response> result = CEN_BotEnhSetPhraseValues.setValues(new List<CEN_BotEnhSetPhraseValues.request>{req});
        System.assertEquals(null, result, 'Frase nula');
    }
    
    @isTest static void testSetValuesInputEmpty() {
        List<CEN_BotEnhSetPhraseValues.response> result = CEN_BotEnhSetPhraseValues.setValues(new List<CEN_BotEnhSetPhraseValues.request>{});
        System.assertEquals(null, result, 'Sin input');
    }
  
}