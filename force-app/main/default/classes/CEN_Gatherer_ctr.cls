/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-07
* @description: Clase de controladora call Api SAP - Recaudadora. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-07           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_Gatherer_ctr {
    
    @InvocableMethod(label='callGatherer' callout=true)
    public static List<String> callGatherer(List<FlowParameters> parameters) {
        system.debug('***CEN_Gatherer_ctr-callGatherer');
        List<String> resp = new List<String>();
        if (
            parameters != null &&
            parameters.size() > 0 &&
            parameters[0].paymentIds != null &&
            parameters[0].paymentIds.size() > 0
        ) {
            String myId = parameters[0].paymentIds[0];
            CEN_CashRegistred__c cash = [SELECT Id, Name
                                         FROM CEN_CashRegistred__c 
                                         WHERE Id = :myId]; 
            
            CEN_GathererResponse respSap = new CEN_GathererResponse();
            try{
                respSap = CEN_Gatherer_cls.generateGathererByCashId(myId);
                if(respSap.E_OK != null){
                    cash.CEN_Status__c = 'Entregado';
                    cash.CEN_ErrorSapSynchronization__c = false;
                    cash.CEN_ErrorSapMessage__c = '';
                    update cash;
                    resp.add('Se envió notificación de traslado de efectivo a SAP: ' + cash.Name);    
                }else{
                    String errorSap = respSap.E_RETURN.item[0].MESSAGE;
                    cash.CEN_Status__c = 'PendienteSAP';
                    cash.CEN_ErrorSapSynchronization__c = true;
                    cash.CEN_ErrorSapMessage__c = errorSap;
                    update cash;
                    resp.add('Error SAP: '+ errorSap +'. Contactar al administrador del sistema');
                }
            }catch(Exception ex){
                String errorSap;
                errorSap = ex.getMessage();
                resp.add('Error SAP: '+ errorSap +'. Contactar al administrador del sistema');
            }
        }else{
            resp.add('Error al generar constancia de recojo de dinero de Hermes en SAP. Contactar al administrador del sistema');
        }
        system.debug('***CEN_Gatherer_ctr-callGatherer-resp: ' + resp);
        return resp;
    }
    
    public class FlowParameters {
        @InvocableVariable(
            label='paymentsIdsParamts'
            description='Id Payments parameter'
            required=true
        )
        public List<String> paymentIds;
    }
    
}