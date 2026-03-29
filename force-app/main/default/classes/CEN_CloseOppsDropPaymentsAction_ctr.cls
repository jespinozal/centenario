/**
 * @description       : Clase controladora para cerrar oportunidades con lote eliminado y actualizar ordenes de pago a 'Suelto'.
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/
public class CEN_CloseOppsDropPaymentsAction_ctr {
    @invocableMethod(label = 'Close Opportunities and Drop Payments' description = 'Retorna las oportunidades que coincidan con los Opportunities Product')
    public static void closeOpportunities(List<FlowParameters> parameterId){
        if((parameterId!=null && parameterId.size()>0 && parameterId[0].opIds!=null && parameterId[0].opIds.size()>0 )  &&
         (parameterId!=null && parameterId.size()>0 && parameterId[0].prodIds!=null && parameterId[0].prodIds.size()>0)){
            List<Opportunity> opps = [SELECT id,name,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c,
                                      CEN_LoteEliminado__c,CEN_devolucion_saldo_Afavor__c,ownerId 
                                      FROM Opportunity where stagename NOT IN ('Oportunidad Perdida','Oportunidad Ganada') AND id IN:parameterId[0].opIds];
            List<Opportunity> oppsGanados = [SELECT id,name,stagename,ownerId FROM Opportunity where stagename ='Oportunidad Ganada' AND id IN:parameterId[0].opIds];
            Product2 productoObj = [Select id,name FROM Product2 WHERE id =: parameterId[0].prodIds[0] ];
            List<String> oppIdsCerrado = new List<String>();
            List<String> oppIdsCotizado = new List<String>();
            List<Opportunity> oppsCotizado = new List<Opportunity>();
            List<Opportunity> oppsCerrado = new List<Opportunity>();
            for (Opportunity op :opps){
                if(String.isNotBlank(String.valueOf(op.CEN_Onbase_documento_id_arras__c)) || 
                   String.isNotBlank(String.valueOf(op.CEN_Onbase_documento_id__c))){
                    op.StageName = 'Oportunidad Perdida';
                    op.CEN_LoteEliminado__c = true;
                    op.CEN_devolucion_saldo_Afavor__c = true;
                    oppIdsCerrado.add(op.Id);
                    oppsCerrado.add(op);
                }else{
                    System.debug('Entro a poner cotizados');
                    op.StageName = 'Cotización';
                    oppIdsCotizado.add(op.Id);
                    oppsCotizado.add(op);
                }
            }
            
            anulatePayments(oppIdsCotizado);
            anulatePayments(oppIdsCerrado);
            dropPayments(oppIdsCerrado);
            update opps;
            List<CEN_PaymentOrder__c> paysCotizado = [SELECT Id FROM CEN_PaymentOrder__c WHERE CEN_PaymentStatus__c = 'Pendiente' AND CEN_Opportunity__c IN: oppIdsCotizado];
            List<CEN_PaymentOrder__c> paysCerrado = [SELECT Id FROM CEN_PaymentOrder__c WHERE CEN_PaymentStatus__c = 'Pendiente' AND CEN_Opportunity__c IN: oppIdsCerrado];
            List<String> payIds = new List<String>();
            for(CEN_PaymentOrder__c pay : paysCotizado){
                payIds.add(pay.id);
            }
            for(CEN_PaymentOrder__c pay : paysCerrado){
                payIds.add(pay.id);
            }
            for(String paid : payIds){                
                CEN_CancelEffectivePaymentOrder_ctr.processOrderEffectiveAsync(paid);
            }
            
            //Borrado de quotes y oppLineItems
            borradoQuotes(parameterId[0].prodIds[0]);
            borradoOppLineItems(parameterId[0].prodIds[0]);
            //Notificaciones
            for(Opportunity opp : oppsCotizado){
                notificationCotizado(opp.Id,opp.ownerId,opp.Name,productoObj.name);
            }
            for(Opportunity opp : oppsCerrado){
                system.debug('Se esta llamando a la clase de lote eliminado!');
                CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(opp.Id);
                notificationCerrado(opp.Id,opp.ownerId,opp.Name,productoObj.name);
            }
            for(Opportunity opp : oppsGanados){
                notificationGanado(opp.Id,opp.ownerId,opp.Name,productoObj.name);
            }
        }
    }
    
    public static void dropPayments(List<String> oppsIds){
        List<CEN_PaymentOrder__c> pays = [Select id,CEN_PaymentStatus__c from CEN_PaymentOrder__c where 
                                          CEN_PaymentStatus__c IN ('Pagado') AND CEN_Opportunity__c IN:oppsIds];
        for(CEN_PaymentOrder__c pay :pays){
            pay.CEN_PaymentStatus__c = 'Suelto';
        }
        update pays;
    }
    
    public static void anulatePayments(List<String> oppsIds){
        List<CEN_PaymentOrder__c> pays = [Select id,CEN_PaymentStatus__c from CEN_PaymentOrder__c where 
                                          CEN_PaymentStatus__c IN ('PendienteCulqi') AND CEN_Opportunity__c IN:oppsIds];
        for(CEN_PaymentOrder__c pay :pays){
            pay.CEN_PaymentStatus__c = 'Anulado';
        }
        update pays;
    }
    
    @Future(callout=true)
    public static void borradoQuotes(String idProd){
        List<QuoteLineItem> quoLi = [SELECT id, quoteId, Product2Id FROM QuoteLineItem WHERE Product2Id =: idProd];
        Set<String> quotid = new Set<String>();
        System.debug('Antes de eliminar quotes');
        if(quoLi != null){
            System.debug('Entró eliminar quotes');
            for(QuoteLineItem qLt : quoLi){
            	quotid.add(qLt.quoteId);                
            }                
         List<Quote> quoteLiminar = [SELECT id FROM Quote where id in: quotid];
         delete quoteLiminar;
         }
    }
    
    @Future(callout=true)
    public static void borradoOppLineItems(String idProd){
        List<OpportunityLineItem> oppLi = [SELECT id, Product2Id,OpportunityId FROM OpportunityLineItem WHERE Product2Id =: idProd];
        List<String> oppLid = new List<String>();
        System.debug('Antes de eliminar oppLines');
        if(oppLi != null){
            System.debug('Entró eliminar oppLines');
            for(OpportunityLineItem oppL : oppLi){                
                oppLid.add(oppL.OpportunityId);
             }            
         List<OpportunityLineItem>oppLineLiminar = [SELECT id FROM OpportunityLineItem WHERE OpportunityId in: oppLid];
         delete oppLineLiminar;
         }
    }
    
    @Future(callout=true)
    public static void notificationCotizado(String idOportunidad, String propietarioId, String oportunidadNombre, String loteNombre){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notificacin_de_la_organizacin'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Set<String> recipientId = new Set<String>();
        recipientId.add(propietarioId);
        notification.setTitle('Retroceso a COTIZACIÓN por lote eliminado');
        notification.setBody('La oportunidad '+ oportunidadNombre + ' pasó a estado COTIZACIÓN debido a que su lote '+ loteNombre + ' se eliminó' );
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(idOportunidad);
        notification.send(recipientId);            
    }
    
    @Future(callout=true)
    public static void notificationCerrado(String idOportunidad, String propietarioId, String oportunidadNombre, String loteNombre){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notificacin_de_la_organizacin'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Set<String> recipientId = new Set<String>();
        recipientId.add(propietarioId);
        notification.setTitle('Cierre de oportunidad por lote eliminado');
        notification.setBody('La oportunidad '+ oportunidadNombre + ' pasó a estado CERRADA PERDIDA debido a que su lote '+ loteNombre + ' se eliminó' );
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(idOportunidad);
        notification.send(recipientId);            
    }

    @Future(callout=true)
    public static void notificationGanado(String idOportunidad, String propietarioId, String oportunidadNombre, String loteNombre){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notificacin_de_la_organizacin'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Set<String> recipientId = new Set<String>();
        recipientId.add(propietarioId);
        notification.setTitle('Se eliminó el lote de una oportunidad ganada');
        notification.setBody('La oportunidad '+ oportunidadNombre + ' la cual se encuentra GANADA, su lote '+ loteNombre + ' se eliminó' );
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(idOportunidad);
        notification.send(recipientId);            
    }
 
    public class FlowParameters {
        @InvocableVariable(label = 'OPIdsParamts' description = 'Ids Ops parameters' required = true)
        public List<String> opIds;
        @InvocableVariable(label = 'ProductIdsParamts' description = 'Ids Product parameters' required = true)
        public List<String> prodIds;
        
    }
}