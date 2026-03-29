public class CEN_cls_Reservas_Oportunidad {
    @AuraEnabled
    public static Response getOportunidad(String idOportunidad){
        Response respuesta = new Response();
        respuesta.estado='ERROR';
        respuesta.estado='Hubo un problema';
        try{
            respuesta.oportunidad=[SELECT Id, CEN_Sub_estado__c, StageName FROM Opportunity WHERE ID=:idOportunidad LIMIT 1];
            if(respuesta.oportunidad!=null){
                respuesta.estado='OK';
                respuesta.mensaje='Todo ok';
            }
        }catch(Exception ex){
            System.debug('Exception trying get data for Opportunity: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        if(respuesta.oportunidad!=null){
             try{
                respuesta.loteDeOportunidad=[SELECT Id, OpportunityId, CreatedDate FROM OpportunityLineItem
                                             WHERE OpportunityId=:idOportunidad ORDER BY CreatedDate DESC LIMIT 1];
                respuesta.reserva = CEN_Reservas.validarDatos(respuesta.loteDeOportunidad.Id);
            }catch(Exception ex){
                System.debug('Exception trying get OpportunityLineItem for Opportunity: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            }
        }
        return respuesta;
    }
    @AuraEnabled
    public static Response reservarLotesDeOportunidad(String oliid){
        System.debug('<!--reservarLotesDeOportunidad inicia oli_id:'+oliid);
        Response respuesta = new Response();
        respuesta.estado='ERROR';
        respuesta.mensaje='Hubo un problema del lado del servidor de salesforce.';
        if(String.isNotBlank(oliid)){
            CEN_Reservas.NivelPagerWrapper res_reservar = CEN_Reservas.getReserva(oliid);
            System.debug('res_reservar.status:'+res_reservar.status);
            System.debug('res_reservar.mensaje:'+res_reservar.mensaje);
            if(String.isNotBlank(res_reservar.status)&&res_reservar.status=='success'){
                try{
                    respuesta.reserva = CEN_Reservas.validarDatos(respuesta.loteDeOportunidad.Id);
                }catch(Exception ex){
                    System.debug('Exception trying get Reserva from OpportunityLineItem for Opportunity: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                }
                respuesta.estado = 'OK';
                respuesta.mensaje = res_reservar.mensaje;
            }else{
                respuesta.estado = 'ERROR';
                respuesta.mensaje = res_reservar.mensaje;
            }
        }else{
            respuesta.mensaje='No se pudo encontrar el Lote. Intenta refrescar la pantalla.';
        }
        System.debug('-->reservarLotesDeOportunidad termina oli_id:'+oliid);
        return respuesta;
    }
    public class Response{
        @AuraEnabled public String estado {get;set;}
        @AuraEnabled public String mensaje {get;set;}
        @AuraEnabled public Opportunity oportunidad {get;set;}
        @AuraEnabled public OpportunityLineItem loteDeOportunidad {get;set;}
        @AuraEnabled public CEN_Reserva__c reserva {get;set;}
    }
}