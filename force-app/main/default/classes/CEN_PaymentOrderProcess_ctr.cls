/**
 * @description       : Sincronizar pagos en estado procesando
 * @author            : Joel Espinoza
 * @group             :
 * @last modified on  : 24-04-2023
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-14-2021   @everis.com   Initial Version
 * 2.0   24-04-2023   @nttdata.com  Mejoras OTC
**/
public with sharing class CEN_PaymentOrderProcess_ctr implements Queueable,Database.AllowsCallouts {

    private List<CEN_PaymentOrder__c> payments;
    public CEN_PaymentOrderProcess_ctr(String myIds) {
        this.payments = [SELECT Id FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =:myIds AND CEN_PaymentStatus__c IN ('Procesando')];
    }

    public void execute(QueueableContext context) {
        if (!TEST.isRunningTest() && payments!=null && payments.size()> 0){
            CEN_ProcessPayment_ctr.generateAndUpdateProcessPaymentAsinc(payments[0].Id);
        }
    }

}