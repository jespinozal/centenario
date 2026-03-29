/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-12-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2021   @everis.com   Initial Version
 **/
public with sharing class CEN_CancelEffectivePaymentOrder_ctr {
    
    @InvocableMethod(label='cancelPaymentEFEC')
    public static void cancelPaymentEFECProcess(List<FlowParameters> parameterId){
        if(parameterId!=null && parameterId.size()>0 && parameterId[0].opIds!=null && parameterId[0].opIds.size()>0 ){
            List<CEN_PaymentOrder__c> pays = [SELECT Id, Name, CEN_PaymentStatus__c, CEN_ID_Culqi__c FROM CEN_PaymentOrder__c 
                                             WHERE recordType.Name = 'Pago Efectivo' AND (CEN_PaymentStatus__c = 'Pendiente' OR CEN_PaymentStatus__c = 'PendienteCulqi') AND CEN_Opportunity__c IN: parameterId[0].opIds];
            for(CEN_PaymentOrder__c pay : pays){
                processOrderEffectiveAsync(pay.id);
            }            
        }
    }

    @AuraEnabled(cacheable=false)
    public static String cancelPaymentEFEC(String inPaymentId){
        System.debug('******cancelPaymentEFEC');
        String resp; 
        Map<String,Object> mapResp = new Map<String,Object>();
        try {
            
            CEN_PaymentOrder__c paymentOrder = [SELECT Id,Name,CEN_PaymentStatus__c,CEN_ID_Culqi__c FROM CEN_PaymentOrder__c WHERE Id=:inPaymentId AND recordType.Name = 'Pago Efectivo' AND  (CEN_PaymentStatus__c = 'Pendiente' OR CEN_PaymentStatus__c = 'PendienteCulqi')];
            String paymentId = paymentOrder.Id;
            String paymentName = paymentOrder.Name;
            String culqiId = paymentOrder.CEN_ID_Culqi__c;
            String paymentStatus = paymentOrder.CEN_PaymentStatus__c;
            //Object result = null;
            
            if(paymentStatus != 'Anulado'){

                if(!String.isEmpty(culqiId)){
                    System.debug('culqiId: ' + culqiId);
                    CEN_CancelEffectivePaymentOrder_cls.PaymentOrderDeleteByIdAsync(culqiId);
                    //CEN_CancelEffectivePaymentOrder_cls.PaymentOrderDeleteById(culqiId);
                }

                CEN_PaymentOrder__c oPayment = new CEN_PaymentOrder__c();
                oPayment.Id = paymentId;
                oPayment.CEN_PaymentStatus__c = 'Anulado';
                update oPayment;

                resp = 'Se anuló la orden de pago: ' + paymentName;
            }else{
                resp = 'La orden de pago: ' + paymentName + ' ya se encuentra anulada';
            }
        } catch (Exception e) { 
            resp = 'error: ' + e.getMessage(); 
            System.debug('error ' + e.getMessage());
        }

        return resp;
    }

    @future(callout=true)
    public static void processOrderEffectiveAsync(String paymentId){
        System.debug('processOrderEffectiveAsync metodo' + paymentId);
        CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC(paymentId);
    }

    public class FlowParameters {
        @InvocableVariable(label = 'OPIdsParamts' description = 'Ids Ops parameters' required = true)
        public List<String> opIds;
    }

}