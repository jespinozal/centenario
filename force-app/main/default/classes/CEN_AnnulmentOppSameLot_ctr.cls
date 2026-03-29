/**
 * @description       : Clase controladora cerrar oportunidades y anular pagos que tienen el mimsmo lote
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 21-10-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/
public without sharing class CEN_AnnulmentOppSameLot_ctr {

    @InvocableMethod(label='updateOppSameLot')
    public static void updateOppSameLotProcess(List<FlowParameters> parameters){
        System.debug('************updateOppSameLotProcess');
        if(parameters!=null && parameters.size()>0 && parameters[0].oppIds!=null && parameters[0].oppIds.size()>0 ){
            for(Integer i=0; i < parameters.size(); i++){
                for(String myOpp : parameters[i].oppIds){
                    CEN_AnnulmentOppSameLot_ctr.updateOppSameLot(myOpp);
                }
            }
        }
    }

    public static void updateOppSameLot(String oppIds) {
        System.Debug('***IN CEN_AnnulmentOppSameLot_ctr.updateOppSameLot***');
        try {

            Set<String> getProd2Ids = new  Set<String>();

            List<OpportunityLineItem> oppItems = [SELECT Product2Id , OpportunityId
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId = :oppIds];
            for(OpportunityLineItem oppItem: oppItems){
            getProd2Ids.add(oppItem.Product2Id);
            }

            if(getProd2Ids != null && getProd2Ids.size() > 0){
            List<OpportunityLineItem> lstOppSameLot = [SELECT Id, OpportunityId, Opportunity.Name,
                                                                Product2.Name, Product2.CODLOTE__c,
                                                                Opportunity.OwnerId, Opportunity.CEN_Supervisor__c
                                                        FROM OpportunityLineItem
                                                        WHERE Product2Id IN: getProd2Ids
                                                        AND OpportunityId !=: oppIds
                                                        AND Opportunity.StageName IN ('Cotización','Operación','Preliminar','Depósito','Revisión de contrato')];
                System.debug('lstOppSameLot: ' + lstOppSameLot);
                if(lstOppSameLot != null || lstOppSameLot.size()>0){
                    List<Opportunity> oppsOtherUpdate = new List<Opportunity>();
                    for(OpportunityLineItem myLot: lstOppSameLot ){
                        Set<String> notiRecipients = new Set<String>();
                        Opportunity oppToCoti = new Opportunity();
                        oppToCoti.Id = myLot.OpportunityId;
                        oppToCoti.StageName = 'Oportunidad Perdida';
                        oppToCoti.CEN_Motivo_Cierre_Perdida__c = 'DC';
                        oppsOtherUpdate.add(oppToCoti);

                        List<CEN_PaymentOrder__c> listPayments = [SELECT Id,RecordType.Name,CEN_ID_Culqi__c,CEN_DueDate__c
                                                                  FROM CEN_PaymentOrder__c
                                                                  WHERE CEN_Opportunity__c =: myLot.OpportunityId
                                                                  AND CEN_PaymentStatus__c = 'Pendiente' ];
                        System.debug('listPayments: ' + listPayments);
                        List<CEN_PaymentOrder__c> listUpdatePO = new List<CEN_PaymentOrder__c>();
                        if(listPayments != null && listPayments.size()>0){
                            for(CEN_PaymentOrder__c payment : listPayments){
                                if(payment.RecordType.Name == 'Pago Efectivo' && payment.CEN_DueDate__c<=date.today()){
                                    System.debug('Pago Efectivo: ' + payment);
                                    CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC(payment.Id);
                                    //CEN_CancelEffectivePaymentOrder_cls.PaymentOrderDeleteById(payment.CEN_ID_Culqi__c);
                                }else if(payment.RecordType.Name == 'Pago Transferencia'){
                                    System.debug('Pago Transferencia: ' + payment);
                                    CEN_PaymentOrder__c updatePO = new CEN_PaymentOrder__c();
                                    updatePO.Id = payment.Id;
                                    updatePO.CEN_PaymentStatus__c = 'Anulado';
                                    listUpdatePO.add(updatePO);
                                }
                            }

                            if(listUpdatePO != null || listUpdatePO.size()>0){
                                System.debug('listUpdatePO: ' + listUpdatePO);
                                update listUpdatePO;
                            }
                        }

                        notiRecipients.add(myLot.Opportunity.OwnerId);
                        notiRecipients.add(myLot.Opportunity.CEN_Supervisor__c);
                        myNotification ('Notificación Lotes','Se anulo la oportunidad ' + myLot.Opportunity.Name + ' comunícate con tu cliente. El lote ' + myLot.Product2.Name + ' está involucrado en una operación con deposito para otro cliente.', myLot.OpportunityId,notiRecipients);
                    }

                    update oppsOtherUpdate;
                }
            }

        } catch (Exception ex) {
            Set<String> recipientId = new Set<String> {System.UserInfo.getUserId()};
            myNotification ('Error Tecnico', 'Error: '+ex.getMessage()+'. Linea: '+ex.getLineNumber(), oppIds, recipientId );
        }
    }

    private static void myNotification (String notiTitle, String notiBody, String notiTarget, Set<String> notiRecipients ){
        String notiId = [SELECT Id, DeveloperName
                          FROM CustomNotificationType
                          WHERE DeveloperName = 'Notificacin_de_la_organizacin' ].Id;

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notiTitle);
        notification.setBody(notiBody);
        notification.setNotificationTypeId(notiId);
        notification.setTargetId(notiTarget);
        notification.send(notiRecipients);
    }

    public class FlowParameters {
		@InvocableVariable(label='oppIdsParamt' description='Ids Opportunities parameter' required=true)
		public List<String> oppIds;
    }
}