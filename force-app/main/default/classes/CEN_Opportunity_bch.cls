/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-04-14 
* @description: Clase que instancia clase Bacth de actualización de Oportunidad. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-04-14           Alan Alvarez            Creación 
*  
*********************************************************************/ 
global class CEN_Opportunity_bch implements Database.Batchable<sObject>{
    
    public List<Id> proyectIds;
    
    @InvocableMethod(label='Ejecutar apex batch Opportunity' description='Este metodo ejecutará CEN_Opportunity_bch')
    public static void executeBatchMethod(List<Id> lst) {
        Database.executeBatch(new CEN_Opportunity_bch(lst), 2000);
    }
    
    public CEN_Opportunity_bch(List<Id> fromProcess){
        this.proyectIds = fromProcess;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        List<String> estadosOpp = new List<String>();
        estadosOpp.add('Oportunidad Perdida');
        estadosOpp.add('Oportunidad Ganada');
        String query = 'SELECT CEN_StatusLot__c, CEN_Proyecto__c, CEN_Proyecto__r.CEN_StatusLots__c, CEN_Proyecto__r.CEN_ChangeInLotsStatus__c FROM Opportunity WHERE CEN_Proyecto__c IN: proyectIds AND createddate >= 2021-06-01T00:00:00.000+0000 AND stageName NOT IN : estadosOpp';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    /********************************************************************* 
* @description: Método para actualizar el Estatus de lotes de Arras a CVG.
*********************************************************************/
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Opportunity objOpportunity : scope){
            if(objOpportunity.CEN_Proyecto__r.CEN_ChangeInLotsStatus__c == true){
                objOpportunity.CEN_StatusLot__c = 'DE ARRAS A CVG';
            }
            else{
                objOpportunity.CEN_StatusLot__c = objOpportunity.CEN_Proyecto__r.CEN_StatusLots__c;   
            }
            lstOpportunity.add(objOpportunity);     
        }
        if(lstOpportunity.size() > 0){
            update lstOpportunity;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }   
    
}