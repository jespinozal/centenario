/**
 * @description       :
 * @author            : Adolfo Crispin
 * @group             :
 * @last modified on  : 29-01-2021
 * @last modified by  : Luis Maldonado
 * Modifications Log
 * Ver   Date         Author           Modification
 * 2.0   29-01-2021   Adolfo Crispin   Asignar supervisor a tareas
**/
trigger CEN_ProspectosDuplicados on Lead (before insert, after insert, after update) {
    
   if(trigger.isBefore && trigger.isInsert){
        System.debug('Before Insert');
        Map<String, Id> coincidentes = CEN_Lead_trg_Helper.getCoincidentes(trigger.new);
        //List<Lead> coincidentes = CEN_Lead_trg_Helper.getCoincidentes2(trigger.new);
        System.debug('Before Insert-coincidentes: ' + coincidentes);

        if(coincidentes.size()>0){
            CEN_Lead_trg_Helper.crearTareas(coincidentes, trigger.new);
            //CEN_Lead_trg_Helper.crearTareas2(coincidentes, trigger.new);
        }
    }
    else if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        Boolean ejecutar = false;
        //CEN_Lead_trg_Helper.updateOppCase(trigger.new);
        if(trigger.isInsert){
            ejecutar = true;
        }else if(trigger.isUpdate){
            for(Lead ld: trigger.new){
                if (
                    ld.CEN_N_mero_de_documento__c != trigger.oldMap.get(ld.Id).CEN_N_mero_de_documento__c ||
                    ld.CEN_Elige_donde_vivir__c != trigger.oldMap.get(ld.Id).CEN_Elige_donde_vivir__c
                    )
                {
                    System.debug('ld.CEN_N_mero_de_documento__c: ' + ld.CEN_N_mero_de_documento__c);
                    System.debug('oldMap.get(ld.Id).CEN_N_mero_de_documento__c: ' + trigger.oldMap.get(ld.Id).CEN_N_mero_de_documento__c);
                    System.debug('ld.CEN_Elige_donde_vivir__c: ' + ld.CEN_Elige_donde_vivir__c);
                    System.debug('oldMap.get(ld.Id).CEN_Elige_donde_vivir__c: ' + trigger.oldMap.get(ld.Id).CEN_Elige_donde_vivir__c);
                    ejecutar = true;
                    
                }
            }
        }

        if(ejecutar){
            System.debug('After Insert');
            Map<String, Id> coincidentes = CEN_Lead_trg_Helper.getCoincidentes(trigger.new);
            System.debug('After Insert-coincidentes: ' + coincidentes);
            System.debug('After Insert-coincidentes SIZE: ' + coincidentes.size());

            if(coincidentes.size()>=0 ){
                List<Lead> leads = new List<Lead>();
                for(String key : coincidentes.keySet()){
                    Lead ld = new Lead();
                    ld.Id = key;
                    ld.CEN_LeadParent__c = coincidentes.get(key);
                    //if(!String.isBlank(ld.CEN_N_mero_de_documento__c)){
                    //    leads.add(ld);
                    //}
                    leads.add(ld);
                }

                //if(leads.size()>0){
                //    update leads;
                //}
                update leads;

                
                List<String> ids = CEN_Lead_trg_Helper.crearReactivo(coincidentes,trigger.new);
                System.debug('ids: ' + ids);
                if(ids.size()>0){
                List<Lead> tbdLeads = [Select ID FROM Lead WHERE ID IN: ids];
                delete tbdLeads;
                System.debug('se eliminó '+ tbdLeads.size()+' prospectos');
                
                
                }
            }
        }
    }
}