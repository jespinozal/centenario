public with sharing class CEN_AlertaProspecto {
    
    @AuraEnabled
    public static string getAlertasProspecto (string idCliente, string objname)
    {
        system.debug('idCliente :'+idCliente);
        system.debug('nameobj'+objname);
        
        string resultado ='';
        User u = [select id,Name,ProfileId, Profile.Name, Caseta_de_Venta__c from User where id =: userInfo.getUserId()];
        String perfil = [select Name from profile where id = :u.ProfileId].Name;
        
        if(objname=='Lead'){
             
        boolean nodatos  = [SELECT CEN_No_brindo_datos__c 
                                FROM Lead 
                                WHERE id =:idCliente].CEN_No_brindo_datos__c;
        
        string documento = [SELECT CEN_N_mero_de_documento__c 
                                FROM Lead 
                                WHERE id =:idCliente].CEN_N_mero_de_documento__c;
        string celular   = [SELECT MobilePhone 
                                FROM Lead 
                                WHERE id =:idCliente].MobilePhone;
        
        boolean acepto   = [SELECT CEN_T_rminos_y_condiciones__c 
                                FROM Lead 
                                WHERE id =:idCliente].CEN_T_rminos_y_condiciones__c;
            
         
        if(nodatos==true && documento=='00000000' && celular=='000000000')
        {  
          resultado= 'A tener en cuenta: El Prospecto no brindó Datos.';
        }else
        if(nodatos==true && documento=='00000000' && celular!='000000000'){
          resultado= 'El Prospecto no registro su número de documento.';
        }else
        if(nodatos==true && documento!='00000000' && celular=='000000000'){
          resultado= 'El Prospecto no registro su número celular.';
        }
        
        
        if(perfil!='CEN_Callcenter'){
        if(acepto==false){
            resultado = +resultado+ ' El prospecto, no aceptó términos y condiciones.';
        }
       
        }
            
            
        }else{    
        
        boolean aceptoacc   = [SELECT Prospecto_acept_t_rminos_y_condiciones__c 
                                FROM account 
                                WHERE id =:idCliente ].Prospecto_acept_t_rminos_y_condiciones__c;
            
        if(perfil!='CEN_Callcenter'){
        
        if(aceptoacc==false){
            resultado = +resultado+ ' La cuenta, no aceptó términos y condiciones.';
        }
        }
       
        }    
            
       
        
        
        return resultado;
    }
    
}