trigger CEN_Formate_Client on Account (before insert,before update) {
if (Trigger.isBefore) {
    User usuario = null;
    Map<Id, Account> cuentas = null;
    try{
        usuario = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id=:System.UserInfo.getUserId() LIMIT 1];
        cuentas = new Map<Id, Account>([SELECT Id, CEN_Estado__c FROM Account WHERE Id IN :trigger.new LIMIT 50000]);
    }catch(Exception ex){
        System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
    }
               for(Account acc: trigger.new){
                   if(cuentas!=null&&cuentas.get(acc.Id)!=null&&cuentas.get(acc.Id).CEN_Estado__c=='Cuenta Centenario'&&usuario!=null
                      &&String.isNotBlank(usuario.ProfileId)&&String.isNotBlank(usuario.Profile.Name)&&usuario.Profile.Name=='CEN_Asesor_de_ventas_urbano'){
                          System.debug('User can not update: '+acc);
                          System.debug('No tienes suficientes permisos para poder editar un cliente centenario, consulta con tu administrador de sistema.');
                       //acc.addError('No tienes suficientes permisos para poder editar un cliente centenario, consulta con tu administrador de sistema.');
                   }
                      //Convierte Solo la primera letra del texto en mayuscula
						if(acc.Name <> null){
                                acc.Name = WordToUpperCase.ConvertWord(acc.Name);
                   	  			system.debug('valor obtenido 1 : '+ acc.Name);                    
                   }
                   		if(acc.FirstName <> null){
                                acc.FirstName = WordToUpperCase.ConvertWord(acc.FirstName);
                   	  			system.debug('valor obtenido 1 : '+ acc.FirstName);                    
                   }
                   		if(acc.LastName <> null){
                                acc.LastName = WordToUpperCase.ConvertWord(acc.LastName);
                   	  			system.debug('valor obtenido 1 : '+ acc.LastName);                    
                   }
                   
                   		if(acc.CEN_Direcci_n__c  <> null){
                              
                                acc.CEN_Direcci_n__c = WordToUpperCase.ucFirst(acc.CEN_Direcci_n__c);
                   	  			system.debug('valor obtenido 2 : '+ acc.CEN_Direcci_n__c);    
                   }
                   		if(acc.CEN_Direcci_n_Centro_de_Trabajo__pc	  <> null){
                              
                                acc.CEN_Direcci_n_Centro_de_Trabajo__pc	 = WordToUpperCase.ucFirst(acc.CEN_Direcci_n_Centro_de_Trabajo__pc	);
                   	  			system.debug('valor obtenido 2 : '+ acc.CEN_Direcci_n_Centro_de_Trabajo__pc	);    
                   }
                   		if(acc.CEN_Cargo_que_ocupa__pc		  <> null){
                              
                                acc.CEN_Cargo_que_ocupa__pc		 = WordToUpperCase.ucFirst(acc.CEN_Cargo_que_ocupa__pc);
                   	  			system.debug('valor obtenido 2 : '+ acc.CEN_Cargo_que_ocupa__pc);    
                   }
                   		if(acc.CEN_Jefe_Directo__pc			  <> null){
                              
                                acc.CEN_Jefe_Directo__pc			 = WordToUpperCase.ucFirst(acc.CEN_Jefe_Directo__pc);
                   	  			system.debug('valor obtenido 2 : '+ acc.CEN_Jefe_Directo__pc);    
                   }
               }
		}
}