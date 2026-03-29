trigger CEN_Interaccion on Case (before insert, before update) {
    System.debug('<!--Iniciando trg CEN_Interaccion, total: '+trigger.new.size());
    if(trigger.isInsert){
        if(trigger.isBefore){
            if(trigger.new.size()==1){
                System.debug('Interaccion: '+trigger.new[0]);
                if(trigger.new[0].Origin=='App'){
                    System.debug('Interaccion desde App: '+trigger.new[0]);
                    trigger.new[0].CEN_Fecha_Respuesta_App__c=Datetime.now();
                }                
            }
        }
    }else if(trigger.isUpdate){
        if(trigger.isBefore){
            if(trigger.new.size()==1){
                System.debug('Interaccion a actualizar: '+trigger.new[0]);
                if(trigger.new[0].Status=='Cerrado'){
                    System.debug('Interaccion es parent');
                    List<Case> hijas = null;
                    try{
                        hijas = [SELECT Id, Status, ParentId FROM Case WHERE ParentId=:trigger.new[0].Id AND Status!='Cerrado' AND RecordType.DeveloperName NOT IN ('CEN_InteraccionUrbanoResolucion','CEN_InteraccionPrepago') LIMIT 50000];
                    }catch(Exception ex){
                        System.debug('Exception buscando hijas de la interaccion: '+ex.getMessage()+
                                    '. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                    }
                    if(hijas!=null&&hijas.size()>0){
                        System.debug('Las hijas no cerradas de la interacción '+trigger.new[0].Id +' son en total '+hijas.size()+': '+hijas);
                        trigger.new[0].AddError('No puede cerrar esta interacción porque tiene '+hijas.size()+' relacionados no cerrados.');
                    }else if(trigger.new[0].CEN_Actualizar_Datos__c==true){
                        System.debug('No puede "Cerrar" la interacción sin Gestionar la Actualización de los datos.');
                        trigger.new[0].AddError('No puede "Cerrar" la interacción sin Gestionar la Actualización de los datos.');
                    }
                    trigger.new[0].CEN_Fecha_de_Solucion__c  = Datetime.now();
                    if(trigger.new[0].CEN_Fecha_de_Atencion__c==null){
                        trigger.new[0].CEN_Fecha_de_Atencion__c = Datetime.now();
                    }
                    if(trigger.new[0].CEN_Fecha_de_Respuesta__c ==null){
                        trigger.new[0].CEN_Fecha_de_Respuesta__c  = Datetime.now();
                    }
                }
                else if(trigger.new[0].Status=='Atendido'){
                    if(trigger.new[0].CEN_Actualizar_Datos__c==true){
                        System.debug('No puede cambiar el estado a "Atendido" sin Gestionar la Actualización de los datos.');
                        trigger.new[0].AddError('No puede cambiar el estado a "Atendido" sin Gestionar la Actualización de los datos.');
                    }
                    //trigger.new[0].CEN_Fecha_de_Respuesta__c =Datetime.now();
                    if(trigger.new[0].CEN_Fecha_de_Respuesta__c==null){
                        trigger.new[0].CEN_Fecha_de_Respuesta__c = Datetime.now();
                    }
                    if(trigger.new[0].CEN_Fecha_de_Atencion__c==null){
                        trigger.new[0].CEN_Fecha_de_Atencion__c = Datetime.now();
                    }
                }
                else if(trigger.new[0].Status=='En proceso'){
                    trigger.new[0].CEN_Fecha_de_Atencion__c=Datetime.now();
                    if(String.isBlank(trigger.new[0].Reason)){
                        trigger.new[0].AddError('Interacción no tiene Asunto');
                    }
                }
            }
        }
    }
    System.debug('--!>Terminando trg CEN_Interaccion, total: '+trigger.new.size());
}