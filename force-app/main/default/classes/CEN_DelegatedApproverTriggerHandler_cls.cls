/********************************************************************* 
* @author: Joel Espinoza (joel.carlos.eugenio.espinoza.ludena@everis.com) 
* @date: 2021-04-05 
* @description: Valida si existe el supervisor en los registros, no dejará insertar, actualizar o restaurar. 
* 
* VERSION      DATE                 AUTOR                  ACTION 
* 0.1          2021-04-05           Joel Espinoza          Creación 
*  
*********************************************************************/ 
public class CEN_DelegatedApproverTriggerHandler_cls{
    
    public static void validateSupervisorMethod(Map<Id,CEN_DelegatedApprover__c> CEN_DelegatedApproverMapNew, Map<Id,CEN_DelegatedApprover__c> CEN_DelegatedApproverMapOld){
    
        Set<String> existingSupervisorSet = new Set<String>();    
        Set<Id> setFilteredId = new Set<Id>();
        Set<Id> newSupervisorSet = new Set<Id>();
        
        //Agregar los ID's nuevos a una lista
        if (CEN_DelegatedApproverMapNew != null && !CEN_DelegatedApproverMapNew.isEmpty()) {
            for (CEN_DelegatedApprover__c da : CEN_DelegatedApproverMapNew.values()) {
                setFilteredId.add(da.Id);
            }
        }
        
        //Agregar al nuevo supervisor en una lista, solo si es diferente al id antiguo.
        if (!setFilteredId.isEmpty()) {
            for (Id ids : setFilteredId) {
                if (CEN_DelegatedApproverMapNew.get(ids).CEN_Supervisor__c != CEN_DelegatedApproverMapOld.get(ids).CEN_Supervisor__c) {
                    newSupervisorSet.add(CEN_DelegatedApproverMapNew.get(ids).CEN_Supervisor__c);
                } 
            }
        }
        
        //Hacer un SOQL de Aprobadores Secundarios para obtener el registro duplicado
        map<Id, CEN_DelegatedApprover__c> existingDelegatedApproverMap = new map<Id, CEN_DelegatedApprover__c>([Select Id, CEN_Supervisor__c From CEN_DelegatedApprover__c Where CEN_Supervisor__c IN: newSupervisorSet AND CEN_Supervisor__c != null ]);
        
        //Agregar a los supervisores existentes en una lista
        for(CEN_DelegatedApprover__c da: existingDelegatedApproverMap.values()){
            existingSupervisorSet.add(da.CEN_Supervisor__c);
        }
        
        //Validamos si existe en la lista, en caso no exista, se agrega a la lista.
        for(CEN_DelegatedApprover__c da : CEN_DelegatedApproverMapNew.values()) { 
            if(existingSupervisorSet.contains(da.CEN_Supervisor__c)){ 
                da.CEN_Supervisor__c.AddError('Ya existe un registro para este supervisor');
            }
            else{
                existingSupervisorSet.add(da.CEN_Supervisor__c);   
            }
        }
    }
    
    public static void validateSupervisorNewMethod(List<CEN_DelegatedApprover__c> DelegatedApproverList){
        
        //Obtener una lista de todos los Aprobadores Secundarios nuevos.
        Set<String> newSupervisorSet = new Set<String>();
        Set<String> existingSupervisorSet = new Set<String>();
        
        // Agregar un nuevo nombre del supervisor dentro de un Set
        for ( CEN_DelegatedApprover__c sa : DelegatedApproverList ){
            if ( sa.CEN_Supervisor__c != null ) {
                newSupervisorSet.add(sa.CEN_Supervisor__c);
            }
        }
        //Hacer un SOQL de Aprobadores Secundarios para obtener el registro duplicado
        List<CEN_DelegatedApprover__c> existingSecondaryApproverList = [Select Id, CEN_Supervisor__c From CEN_DelegatedApprover__c Where CEN_Supervisor__c IN: newSupervisorSet AND CEN_Supervisor__c != null];
    
        for(CEN_DelegatedApprover__c  sa : existingSecondaryApproverList ) {
            existingSupervisorSet.add(sa.CEN_Supervisor__c);
        }
        
        for(CEN_DelegatedApprover__c sa : DelegatedApproverList ) { 
            if(existingSupervisorSet.contains(sa.CEN_Supervisor__c)){
                sa.CEN_Supervisor__c.AddError('Ya existe un registro para este supervisor');
            }else{
                existingSupervisorSet.add(sa.CEN_Supervisor__c);	
            }
        }
    }
}