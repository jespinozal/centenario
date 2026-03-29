public with sharing class CEN_SMS {
    
    @AuraEnabled
    public static NivelPagerWrapper getSMS (string idCliente){
        system.debug('Entro Id : ' + idCliente);
        
        string id=idCliente;
        
        List <Event> lstOfevent = [Select id,WhoId,WhatId,CEN_Oficina__c,StartDateTime,OwnerId,Description from event WHERE id =:idCliente LIMIT 1];
		
        System.debug('OWNERID:' +lstOfevent[0].OwnerId);
        System.debug('WHATID:' +lstOfevent[0].WhatId);
        System.debug('WHOID:' +lstOfevent[0].WhoId);
        system.debug('Campos de Evento : ' + lstOfevent);
        
        string numero;
        String lastname;
        //if(lstOfevent[0].WhatId == '' || lstOfevent[0].WhatId == null)
         system.debug('WHAT ID = VACIO');
        if(lstOfevent[0].WhoId!=null){
            List <lead> lstOflead = [Select id,FirstName,LastName,MobilePhone from lead WHERE id =:lstOfevent[0].WhoId LIMIT 1];
            system.debug('Campos de lead : ' + lstOflead);
            List <Contact> lstOfContact = [Select id,FirstName,LastName,MobilePhone from Contact WHERE id =:lstOfevent[0].WhoId LIMIT 1];
            
            if(lstOflead.size()>0)
            {numero = '+51'+lstOflead[0].MobilePhone;
             lastname = lstOflead[0].LastName;}
            if(lstOfContact.size()>0)
            {numero = '+51'+lstOfContact[0].MobilePhone;
             lastname = lstOfContact[0].LastName;}
            
            system.debug('Campos de lead : ' + numero);
            system.debug('Campos de contacto  : ' + lastname);
        }
        /*Se comenta porque OpenCTI siempre brindara el WhoId en su creación de tarea
         * else if(lstOfevent[0].WhatId!=null){
            List <Account> lstOflead = [Select id,FirstName,LastName,RecordType.Name, Phone, PersonContactId from Account WHERE id =:lstOfevent[0].WhatId LIMIT 1];
            system.debug('Campos de lead : ' + lstOflead);
            if(lstOflead[0].RecordType.Name=='Cuenta Jurídica'){
                numero = '+51'+lstOflead[0].Phone;
                lastname = lstOflead[0].Name;
            }else{
                try{
                    Contact contacto = [SELECT Id, MobilePhone, LastName FROM Contact WHERE Id=:lstOflead[0].PersonContactId LIMIT 1];
                    numero = '+51'+contacto.MobilePhone; 
                    lastname = contacto.LastName;
                }catch(Exception ex){
                    System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getMessage());
                }
            }
        }*/
 		 
          /*}
         if(lstOfevent[0].WhatId <> '' || lstOfevent[0].WhatId <> null)
         {system.debug('WHAT ID <> VACIO');
         List <account> lstOfacc = [Select id,FirstName,LastName,PersonMobilePhone from account WHERE id =:lstOfevent[0].WhatId LIMIT 1];
         numero = '+51'+lstOfacc[0].PersonMobilePhone;
         lastname = lstOfacc[0].LastName;
         system.debug('Campos de account : ' + lstOfacc);}*/
         
        
		       
		        

		
        //Centenario - Sr(a) Apellido, se agendo su cita para el 00/00 a las 00:00 
        //en nuestra oficina ubicada en XXXXXXXXX.  (Dirección corta de Of.).
        //  “Esto se habilita según la ciudad proyecto que se haya seleccionado“
        string mensaje = 'Centenario - Sr(a) ' + lastName +', se agendo su cita para el ' + lstOfevent[0].StartDateTime.day() 
            			 + '/' + lstOfevent[0].StartDateTime.format('MM') +' a las ' + lstOfevent[0].StartDateTime.hour() + ':'
            			 + lstOfevent[0].StartDateTime.minute() + ' en nuestra oficina ubicada en ' + lstOfevent[0].CEN_Oficina__c +'.';
        
        
        
        system.debug('SMS'+numero +' -- '+mensaje);
        
        
        NivelPagerWrapper obj =  new NivelPagerWrapper();
        obj.result = CEN_SmsHandler.SendSMS(numero,mensaje);
        obj.mensaje = mensaje;
        
        if(obj.result!='error'){
            lstOfevent[0].CEN_SMS_Enviado__c = true;
            update lstOfevent;
        }
      
        
        system.debug('Result'+ obj.result);
        system.debug('SMS'+numero +' -- '+obj.mensaje);
        
        return obj;
     
    }
    
    public class NivelPagerWrapper {
        @AuraEnabled public String result {get;set;}
        @AuraEnabled public String mensaje {get;set;}
   }

}