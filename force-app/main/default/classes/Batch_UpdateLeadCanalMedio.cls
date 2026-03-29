//EJECUTAR PROCESO BACHERO
//Id <variable name>= Database.executeBatch(new <Class name>(), batch size);
//Id batchJobId = Database.executeBatch(new RunThisBatch(), 200);
global class Batch_UpdateLeadCanalMedio implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select createddate, id,whoid,who.name, CEN_City_OAC__c, CEN_tipo__c,CEN_canal__c,CEN_Medio__c from event where who.type=\'Lead\' AND (CEN_canal__c = \'\' OR CEN_Medio__c = \'\')');
    }
    
    global void execute(Database.BatchableContext BC, List<Event> eventsToUpdate){
    
        try{
    
            List<Event> lst = new List<Event>();
            for(Event e:eventsToUpdate){
                Lead ld = [SELECT Id, LeadSource, CEN_Medio__c FROM Lead WHERE Id =: e.WhoId LIMIT 1];    
                e.CEN_canal__c	= ld.LeadSource;
                e.CEN_Medio__c	= ld.CEN_Medio__c;
                lst.add(e);
            }
    
            update lst;
    
        }catch (Exception e){
           //Handle error
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    }