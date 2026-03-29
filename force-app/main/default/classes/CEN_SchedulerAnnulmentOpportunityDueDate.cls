/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 24-09-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   24-09-2021   @everis.com   Initial Version
**/
global class CEN_SchedulerAnnulmentOpportunityDueDate implements Schedulable{
    global void execute(SchedulableContext SC) {

        List<Opportunity> opps = [SELECT Id,
                                        CEN_AmountPaidDate__c,
                                        Name,
                                        CEN_Monto_cuota_de_inicial_de_precio__c,
                                        CEN_MaximumPaymentDate__c,
                                        CEN_MaximumDateSigningContract__c,
                                        CEN_Estado_Onbase__c,
                                        OwnerId,
                                        CEN_Supervisor__c,
                                        CEN_devolucion_saldo_Afavor__c,
                                        CEN_StatusLot__c,
                                        CEN_TipoAnulacionOperacionSegura__c,
                                        CEN_Motivo_Cierre_Perdida__c
                                    FROM Opportunity
                                    WHERE CEN_MaximumPaymentDate__c != NULL
                                    AND CEN_Sub_etapa_ARRAS__c != 'FINALIZADO'
                                    AND CEN_Motivo_Cierre_Perdida__c = NULL
                                    AND CEN_StatusLot__c != 'DE ARRAS A CVG'
                                    AND CEN_estado_aprobacion__c != 'EJECUTADO'
                                    AND CEN_AmountPaidDate__c > 0
                                    //AND CEN_Proyecto__c = 'a074T0000016dPAQAY'
                                    //AND OwnerId = '0054T000001F0o2QAC'
                                    AND StageName IN('Cotización','Operación','Preliminar','Oportunidad Perdida')
                                    AND Id NOT IN (SELECT CEN_Opportunity__c
                                                FROM CEN_PaymentOrder__c
                                                WHERE CEN_PaymentStatus__c IN ('PendienteSAP')
                                                 )
                                    //AND CEN_MaximumPaymentDate__c = LAST_N_DAYS:5
                                    //AND Id = '0068A00000DeSa7QAF'
                                 ];

        if(opps != null & opps.size() > 0){
            Date hoy = date.today();
            Set<String> notiRecipients;

            List<Opportunity> oppsOtherUpdate = new List<Opportunity>();

            for(Opportunity opp : opps){

                Integer numberDaysPaymentDue;
                Integer numberDaysSigningDue;
                DateTime dT = DateTime.Now().AddDays(2); //Para comprobar si es nulo
                Date dueDate = date.newinstance(dT.year(), dT.month(), dT.day());

                numberDaysPaymentDue = opp.CEN_MaximumPaymentDate__c == null ? hoy.daysBetween(dueDate) : hoy.daysBetween(opp.CEN_MaximumPaymentDate__c);//Dias pendientes para la Fecha Maxima de pago
                numberDaysSigningDue = opp.CEN_MaximumDateSigningContract__c == null ? hoy.daysBetween(dueDate) : hoy.daysBetween(opp.CEN_MaximumDateSigningContract__c);//Dias pendientes para la Fecha Firma de contrato

                DateTime dateOutputMPD = opp.CEN_MaximumPaymentDate__c;
                DateTime dateOutputMDSC = opp.CEN_MaximumDateSigningContract__c;
                notiRecipients = new Set<String>();
                notiRecipients.add(opp.OwnerId);
                if(opp.CEN_Supervisor__c != NULL){notiRecipients.add(opp.CEN_Supervisor__c);}
                Boolean montoPagadoFechaCompleto = opp.CEN_AmountPaidDate__c == opp.CEN_Monto_cuota_de_inicial_de_precio__c;
                String titleNotification = 'Notificación vencimiento del plazo';

                System.debug(montoPagadoFechaCompleto);
                System.debug(opp.CEN_Estado_Onbase__c);
                System.debug(numberDaysSigningDue);
                if(!montoPagadoFechaCompleto && (numberDaysPaymentDue == 1 || numberDaysPaymentDue == 0)){
                    myNotification (titleNotification,'Al vencimiento del plazo de la fecha máxima de pago ' + opp.CEN_MaximumPaymentDate__c + ' de la Oportunidad ' + opp.Name +', si no lo has extendido, la oportunidad se va a cerrar', opp.Id, notiRecipients);
                }else if(!montoPagadoFechaCompleto && numberDaysPaymentDue == -1){
                    Opportunity oppUpdate = new Opportunity();
                    oppUpdate.Id = opp.Id;
                    oppUpdate.StageName = 'Oportunidad Perdida';
                    oppsOtherUpdate.add(oppUpdate);

                    myNotification (titleNotification,'La Oportunidad ' + opp.Name +', ha sido cerrada temporalmente, favor comuníquese con su supervisor ', opp.Id, notiRecipients);
                }else if(!montoPagadoFechaCompleto && numberDaysPaymentDue == -2){
                    annulmentOpportunityAndPayment(opp, 'VPOD');
                }else if(montoPagadoFechaCompleto && (opp.CEN_Estado_Onbase__c != 'Finalizado' && opp.CEN_Estado_Onbase__c !='Pendiente finalización' && opp.CEN_Estado_Onbase__c !='Atendido') && (numberDaysSigningDue == 1 || numberDaysSigningDue == 0)){
                    System.debug('Entra');
                    myNotification (titleNotification,'Al vencimiento del plazo de la fecha máxima de firma de contrato ' + opp.CEN_MaximumDateSigningContract__c + ' de la Oportunidad ' + opp.Name +', si no lo has extendido, la oportunidad se va a cerrar', opp.Id, notiRecipients);
                }
                //}else if(opp.CEN_Estado_Onbase__c != 'Finalizado' && numberDaysSigningDue <= 0 && (opp.CEN_StatusLot__c == 'CVG' || opp.CEN_StatusLot__c == 'DE ARRAS A CVG')){
                else if(montoPagadoFechaCompleto && (opp.CEN_Estado_Onbase__c != 'Finalizado' && opp.CEN_Estado_Onbase__c !='Pendiente finalización' && opp.CEN_Estado_Onbase__c !='Atendido') && numberDaysSigningDue == -1){
                    Opportunity oppUpdate = new Opportunity();
                    oppUpdate.Id = opp.Id;
                    oppUpdate.StageName = 'Oportunidad Perdida';
                    oppsOtherUpdate.add(oppUpdate);

                    myNotification (titleNotification,'La Oportunidad ' + opp.Name +', ha sido cerrada, favor comuníquese con su supervisor', opp.Id, notiRecipients);
                }else if(montoPagadoFechaCompleto && (opp.CEN_Estado_Onbase__c != 'Finalizado' && opp.CEN_Estado_Onbase__c !='Pendiente finalización' && opp.CEN_Estado_Onbase__c !='Atendido') && numberDaysSigningDue == -2){
                    System.debug('Anular');
                    annulmentOpportunityAndPayment(opp, 'VPF');
                }
            }

            //Llamar al encolable;
            ID jobID = System.enqueueJob(new CEN_OpportunityDueDateQueueable_ctr());

            if(oppsOtherUpdate != null && oppsOtherUpdate.size()>0){
                update oppsOtherUpdate;
            }
        }

    }

    private static void annulmentOpportunityAndPayment(Opportunity opp, String motivo){
        // System.debug('Anular opp' + opp);
        // List<CEN_PaymentOrder__c> listUpdatePO = new List<CEN_PaymentOrder__c>() ;
        // List<CEN_PaymentOrder__c> listPayments = [SELECT Id,RecordType.Name,CEN_PaymentStatus__c,CEN_DueDate__c
        //                                           FROM CEN_PaymentOrder__c
        //                                           WHERE CEN_Opportunity__c =: opp.Id
        //                                           AND CEN_PaymentStatus__c = 'Pendiente'];

        // if(listPayments != null && listPayments.size()>0){
        //     for(CEN_PaymentOrder__c payment : listPayments){
        //         if(payment.RecordType.Name == 'Pago Efectivo' && payment.CEN_DueDate__c<=date.today()){
        //             CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC(payment.Id);
        //         }
        //     else if(payment.RecordType.Name == 'Pago Transferencia'){
        //         System.debug('Pago Transferencia: ' + payment);
        //         CEN_PaymentOrder__c updatePO = new CEN_PaymentOrder__c();
        //         updatePO.Id = payment.Id;
        //         updatePO.CEN_PaymentStatus__c = 'Anulado';
        //         listUpdatePO.add(updatePO);
        //     }
        //     }
        //     update listUpdatePO;

        // }

        opp.CEN_devolucion_saldo_Afavor__c = true;
        opp.CEN_TipoAnulacionOperacionSegura__c = 'ANULA';
        opp.StageName = 'Oportunidad Perdida';
        opp.CEN_Motivo_Cierre_Perdida__c = motivo;
        opp.CEN_Cola__c = 'Procesando';
        update opp;
        //CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(opp.Id);
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

}