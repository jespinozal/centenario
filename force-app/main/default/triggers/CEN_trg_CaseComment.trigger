trigger CEN_trg_CaseComment on CaseComment (after insert) {
    
    if(trigger.isInsert){
        if(trigger.isAfter){
            if(trigger.new.size()==1){
                CaseComment respuesta=trigger.new[0];
                Case interacciones_a = null;
                try{
                    interacciones_a =[SELECT Id, Origin, ParentId, CEN_Visto__c FROM Case WHERE Id=:respuesta.ParentId AND Origin='App' LIMIT 1];
                }catch(Exception ex){
                    System.debug('Interaccion Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                }
                System.debug('Interacciones encontrada: '+interacciones_a);
                if(interacciones_a!=null){
                    if(interacciones_a.ParentId!=null){
                        try{
                            CaseComment duplicado = new CaseComment(IsPublished=respuesta.IsPublished,
                                                                   ParentId=interacciones_a.ParentId,
                                                                   CommentBody=respuesta.CommentBody);
                            insert duplicado;
                        }catch(Exception ex){
                            System.debug('duplicado Insert Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                        }
                        if(respuesta.Id!=null){
                            System.debug('Respuesta se insertó: '+respuesta);
                        }else{
                            System.debug('Respuesta no se insertó: '+respuesta);
                        }
                    }else{
                        interacciones_a.CEN_Visto__c=false;
                        interacciones_a.CEN_Fecha_Respuesta_App__c=respuesta.CreatedDate;
                        update interacciones_a;
                    }
                }
            }     
        }
    }
}