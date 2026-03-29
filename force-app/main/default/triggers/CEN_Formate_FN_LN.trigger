trigger CEN_Formate_FN_LN on Lead (before insert,before update, after insert) {
 

if (Trigger.isBefore) {
               for(Lead ld: trigger.new){
                      //Convierte las primeras letras en mayusculas del Nombre Completo
							if(ld.FirstName <> null){
                                ld.FirstName = WordToUpperCase.ConvertWord(ld.FirstName);
                   }
                   	  //Convierte las primeras letras en mayusculas del Apellido Completo
                   			if(ld.LastName <> null){
                               	ld.LastName = WordToUpperCase.ConvertWord(ld.LastName);
                   }
                   	  //Convierte las primeras letras en mayusculas del Apellido Completo
                   			if(ld.Company <> null){
                               	ld.Company = WordToUpperCase.ConvertWord(ld.Company);
                   }
                   			if(ld.CEN_Direcci_n_Prospecto__c <> null){
                                
                                ld.CEN_Direcci_n_Prospecto__c = WordToUpperCase.ucFirst(ld.CEN_Direcci_n_Prospecto__c);
                   	  			system.debug('valor obtenido 1 : '+ ld.CEN_Direcci_n_Prospecto__c);                    
                   }
                   
                   			if(ld.CEN_Comentario__c  <> null){
                               
                                ld.CEN_Comentario__c = WordToUpperCase.ucFirst(ld.CEN_Comentario__c);
                   	  			system.debug('valor obtenido 2 : '+ ld.CEN_Comentario__c);    
                   }
               }
		}
  
    
if (Trigger.isAfter) {    
    if (Trigger.isInsert) {
        
        
        //map<id,User> mapUser = new  map<id,User>([SELECT id,name,UserRoleId,UserRole.name FROM User WHERE id IN  :listOwnerId]);
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;
        system.debug('Perfil'+pname);
        
        for(Lead ld: trigger.new){
            
        //User u = [select id,Name,ProfileId, Profile.Name, Caseta_de_Venta__c from User where id =: userInfo.getUserId()];
        //String perfil = [select Name from profile where id = :u.ProfileId].Name;
        //system.debug('Perfil'+perfil);  
            
        system.debug('Entro al insert');
        if(pname=='CEN_Anfitriona'){
        Id id = ld.id;
    	CEN_cls_Leadattach_insert.createPDF(Id);
        }
        system.debug('Termino correcto');
        }
    }
}    
    
}