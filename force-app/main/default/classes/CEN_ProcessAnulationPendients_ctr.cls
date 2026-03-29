/*
 * Name: CEN_ProcessAnulationPendients_ctr
 * Version: 1.0
 * Descripción: Controlador para anular pagos pendientes
 * Fecha: 05/07/2021
 * TestClass: CEN_ProcessAnulationPendients_tst
 */
public class CEN_ProcessAnulationPendients_ctr {

    @future(callout=true)
    public static void anulationPendients(String idPayment) {  
        
        //String idPayment = 'a0W6u0000000r5KEAQ';

        CEN_PaymentOrder__c paymentOrder = new CEN_PaymentOrder__c();
        paymentOrder = [SELECT Id, CEN_Amount__c, CEN_Opportunity__c FROM CEN_PaymentOrder__c WHERE Id =: idPayment];

        Map<Id, CEN_PaymentOrder__c> payments = new Map<Id,CEN_PaymentOrder__c>([SELECT Id, CEN_Amount__c, CEN_Opportunity__c 
        FROM CEN_PaymentOrder__c 
        WHERE CEN_Opportunity__c =: paymentOrder.CEN_Opportunity__c
        AND CEN_PaymentStatus__c = 'Pendiente']);

        Opportunity opp = [SELECT Id, CEN_AmountPaidDate__c, CEN_Monto_cuota_de_inicial_de_precio__c  
        FROM Opportunity 
        WHERE Id =: paymentOrder.CEN_Opportunity__c];

        Decimal montoPendiente = opp.CEN_Monto_cuota_de_inicial_de_precio__c - (opp.CEN_AmountPaidDate__c + paymentOrder.CEN_Amount__c);

        List<CEN_PaymentOrder__c> listUpdate = new List<CEN_PaymentOrder__c>();
        
        for(CEN_PaymentOrder__c payment : payments.values()){
            if(payment.CEN_Amount__c > montoPendiente && payment.Id != paymentOrder.Id){
                payment.CEN_PaymentStatus__c = 'Anulado';
                listUpdate.add(payment);
            }
        }

        if(listUpdate.size() > 0){
            update listUpdate;
        }

    }

    @InvocableMethod(label='processAnulationPendients')
    public static List<String> processAnulationPendients(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].opIds!=null && parameters[0].opIds.size()>0 ){
        for(Integer i=0; i < parameters.size(); i++){  
            for(String myPayment : parameters[i].opIds){
                anulationPendients(myPayment);
            resp.add(myPayment+'inProccess');
            }
        }
        }else{
            resp.add('empty');
        }

    return resp;
    }

    public class FlowParameters {
		@InvocableVariable(label='opIdsParamt' description='Ids Payments parameter' required=true)
		public List<String> opIds;
  	}
}