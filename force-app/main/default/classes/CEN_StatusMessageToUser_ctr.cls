/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 07-21-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   05-09-2021   @everis.com   Initial Version
**/
public with sharing class CEN_StatusMessageToUser_ctr {
  
    @AuraEnabled(cacheable=true)
    public static Opportunity getStatusFromOpp(String oppId) {
        Opportunity oppData = new Opportunity();
        if (String.isNotEmpty(oppId)) {
            oppData = [
                SELECT
                CEN_MaximumDateSigningContract__c,
                CEN_AmountPaidDate__c,
                CEN_Monto_cuota_de_inicial_de_precio__c,
                CEN_Proyecto__r.CEN_MaximumTermForSigningTheContract__c,
                CEN_Proforma__c,
                CEN_MessageError__c,
                CEN_LastApiCall__c,
                StageName,
                CEN_Moneda__c
                FROM Opportunity
                WHERE Id = :oppId
            ];
        }
        
        return oppData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CEN_PaymentOrder__c> getErrorPaymentByOppId(String oppId) {
        List<CEN_PaymentOrder__c> getPaymentError = new List<CEN_PaymentOrder__c>();
        if (String.isNotEmpty(oppId)) {
            Opportunity opp = [SELECT Id, CEN_AmountPaidDate__c, CEN_MessageError__c, CEN_Proyecto__r.CEN_monto_minimo_deposito__c FROM Opportunity WHERE Id =:oppId];
            if(opp.CEN_MessageError__c == null){
                getPaymentError = [
                    SELECT Id, Name, CEN_PaymentStatus__c, CEN_MessageError__c
                    FROM CEN_PaymentOrder__c
                    WHERE
                    CEN_Opportunity__c = :oppId
                    AND (CEN_MessageError__c != NULL
                         OR CEN_PaymentStatus__c = 'PendienteSAP')    
                ];
            }
            
        }
        
        return getPaymentError;
    }
    
    @AuraEnabled
    public static Map<String, String> sendOperationToSap(String oppId) {
        Map<String, String> mapResp = new Map<String, String>();
        Boolean timeBol=false; 
        Integer intDays = 1;
        if (oppId != null && String.isNotEmpty(oppId)) {
            Opportunity opp = getStatusFromOpp(oppId);
            if(opp.StageName == 'Operación'){
                DateTime newDate = System.Now();
                if(opp.CEN_LastApiCall__c != null){
                    intDays = opp.CEN_LastApiCall__c.Date().daysBetween(newDate.Date());
                }

                if(intDays == 0){
                    datetime sameDayEndDate = opp.CEN_LastApiCall__c;
                    Long decMinutes = ((newDate.getTime())/1000/60) - ((sameDayEndDate.getTime())/1000/60);
                    if(decMinutes < 3){
                        mapResp.put('error', 'Debe esperar '+(3 - decMinutes)+' minutos, para volver a enviar a SAP');
                    }else{
                        timeBol = true; 
                    }
                }else{
                    timeBol = true; 
                }
                
                if(timeBol && !Test.isRunningTest() && opp.CEN_MessageError__c != null){
                    mapResp = CEN_CreateClient_ctr.callCreateClient(oppId);
                    if(mapResp.get('success') != null){
                        opp.CEN_MessageError__c = NULL;
                        opp.CEN_LastApiCall__c = System.now();
                        update opp;
                        CEN_OperactionSafe_ctr.generateAndUpdateOperationSafeAsinc(oppId);
                        //CEN_AnnulmentOppSameLot_ctr.updateOppSameLot(oppId);
                        mapResp.put('success', 'Se envió a operación segura');
                    }
                }else{
                    mapResp.put('error', 'Debe esperar 3 minutos, para volver a enviar a SAP');
                }

            }else{
                mapResp.put('error', 'Debe estar en la etapa Operación');
            }
            
        } else {mapResp.put('error', 'Id de la oportunidad de puede ser null');}
        return mapResp;
    }
    
    @AuraEnabled
    public static Map<String, String> sendPaymentsToSap(String oppId) {
        system.debug('En sendPaymentsToSap: '+oppId);
        Map<String, String> mapResp = new Map<String, String>();
        Boolean timeBol=false;
        Integer intDays = 1;
        List<CEN_PaymentOrder__c> getPaymentError = new List<CEN_PaymentOrder__c>();
        if (String.isNotEmpty(oppId)) {
            Opportunity opp = getStatusFromOpp(oppId);
            if(opp.StageName == 'Operación'){
                DateTime newDate = System.Now();
                if(opp.CEN_LastApiCall__c != null){
                    intDays = opp.CEN_LastApiCall__c.Date().daysBetween(newDate.Date());
                }
                if(intDays == 0){
                    datetime sameDayEndDate = opp.CEN_LastApiCall__c;
                    Long decMinutes = ((newDate.getTime())/1000/60) - ((sameDayEndDate.getTime())/1000/60);
                    if(decMinutes < 1){
                        mapResp.put('error', 'Debe esperar '+(1 - decMinutes)+' minutos, para volver a enviar a SAP');
                    }else{
                        timeBol = true; 
                    }
                }else{
                    timeBol = true; 
                }

                if(timeBol && opp.CEN_MessageError__c == null){
                    try {             
                        getPaymentError = [ SELECT Id, CEN_Opportunity__r.CEN_Proforma__c,CEN_PaymentStatus__c FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c = :oppId 
                                            AND (CEN_MessageError__c != NULL OR CEN_PaymentStatus__c = 'PendienteSAP')
                                            ORDER BY CreatedDate desc];
                        for(CEN_PaymentOrder__c getpay: getPaymentError){getpay.CEN_MessageError__c = NULL;getpay.CEN_PaymentStatus__c = 'Procesando';}

                        update getPaymentError[0];
                        if (!Test.isRunningTest()) {
                        opp.CEN_LastApiCall__c = System.now();
                        update opp;
                        if(getPaymentError.size()>0){
                            if(getPaymentError[0].CEN_Opportunity__r.CEN_Proforma__c != null){CEN_ProcessPayment_ctr.generateAndUpdateProcessPaymentAsinc(getPaymentError[0].Id); }
                            else{CEN_OperactionSafe_ctr.generateAndUpdateOperationSafeAsinc(oppId); //CEN_AnnulmentOppSameLot_ctr.updateOppSameLot(oppId); 
                            } 
                        }
                        }
                        mapResp.put('success','Se han enviado las ordenes de pago a procesar en SAP, por favor este atento a las notificaciones' );
                    } catch (Exception ex) {mapResp.put( 'error','Error tecnico, por favor contactar al administrador de sistemas');}
                }else{
                    mapResp.put('error', 'Debe esperar 1 minuto, para volver a enviar a SAP');
                }
            }else{
                mapResp.put('error', 'Debe estar en la etapa Operación');
            }

        } else {mapResp.put('error', 'Id de la oportunidad de puede ser null');}
        return mapResp;
    }
}