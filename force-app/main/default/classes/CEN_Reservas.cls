public class CEN_Reservas {
    
     @AuraEnabled
    public static NivelPagerWrapper getReserva (string ID){
        
        NivelPagerWrapper obj =  new NivelPagerWrapper();
        obj.id=ID;
        system.debug('ID: '+ID);
        List<OpportunityLineItem>oppitem=[select id,Product2Id,OpportunityId,CEN_Estado_del_lote__c from OpportunityLineItem where id=:ID];
        system.debug('VALORES DE LA LISTA: '+oppitem);
        String mensaje='';
        if(oppitem[0].CEN_Estado_del_lote__c=='Reservado'){
            mensaje = 'No se puede generar la reserva. Debido a que el lote seleccionado se encuentra reservado';
            obj.status='error';
        }else{
            mensaje = CEN_WS_GenerarReserva.CEN_ReservarLote(oppitem[0].OpportunityId, oppitem[0].Product2Id);
            if(mensaje.contains('Error')||mensaje.contains('error')||mensaje.contains('obligatorio')){
                obj.status='error';
            }else{
                obj.status='success';
            }
        }
 		obj.mensaje=mensaje;
        system.debug('ID: '+obj.id);
        system.debug('Mensaje: '+mensaje);
        
        return obj;
        
    }
    
    
    public class NivelPagerWrapper {
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String mensaje {get;set;}
        @AuraEnabled public String id {get;set;}
   }
    
    @AuraEnabled
    public static CEN_Reserva__c validarDatos(String Id){
        OpportunityLineItem lote_de_oportunidad = null;
        CEN_Reserva__c reserva = null;
        try{
            lote_de_oportunidad = [SELECT Id, OpportunityId, Product2Id, CEN_Estado_del_lote__c FROM OpportunityLineItem WHERE Id=:Id LIMIT 1];
            reserva = [SELECT Id, CEN_Cod_Interno_SAP__c, Name, CEN_Producto__c, CEN_Oportunidad__c, Proyecto__c FROM CEN_Reserva__c
                       WHERE CEN_Oportunidad__c=:lote_de_oportunidad.OpportunityId AND CEN_Producto__c=:lote_de_oportunidad.Product2Id 
                       ORDER BY CreatedDate DESC LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception: '+ ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        return reserva;
    }
}