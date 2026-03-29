/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 04-28-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
global class CEN_SchedulerCancelPaymentOrderEFEC implements Schedulable{

    global void execute(SchedulableContext SC) {

        DateTime dT = DateTime.Now().AddDays(-1);
        Date dueDate = date.newinstance(dT.year(), dT.month(), dT.day());
        System.debug('Fecha ' + dueDate);

        List<CEN_PaymentOrder__c> payments = [  SELECT Id 
                                                FROM CEN_PaymentOrder__c 
                                                WHERE CEN_PaymentStatus__c IN ('Pendiente','PendienteCulqi') 
                                                AND RecordType.DeveloperName = 'CEN_CashPayment'
                                                AND CEN_DueDate__c =: dueDate];

        if(payments != null & payments.size() > 0){                                                
            for(CEN_PaymentOrder__c payment : payments){
                CEN_CancelEffectivePaymentOrder_ctr.processOrderEffectiveAsync(payment.Id);
            }
        }
    }

}