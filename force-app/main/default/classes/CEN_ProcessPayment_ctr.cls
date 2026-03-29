/**
* @description       : Métodos para procesar órdenes de pago
* @author            : @everis.com
* @group             :
* @last modified on  : 07-24-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-13-2021   @everis.com   Initial Version
* 1.1   31/07/2025   Elvis Q.      Se ha subido modificado la secuencia del método updateAmountPaidDate(myOpp) para que sea ejecutado 2 línas antes. Y se ha gestionado el método SendMail mediante un try catch.
**/
public with sharing class CEN_ProcessPayment_ctr {
    public static Map<String,String> generateAndUpdateProcessPayment(String paymentId) {

        Map<String,String> generatedMapResp = new Map<String,String>();

        try{
            String notiTitle;
            String notiBody;

            CEN_PaymentOrder__c paymentData = [SELECT Id, RecordType.Name, Name,CEN_Opportunity__c, CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c,
                                            CEN_Opportunity__r.Account.CEN_Numero_de_documento_del__c, CEN_Opportunity__r.Account.CEN_N_mero_de_documento__pc,
                                            CEN_Opportunity__r.Id,CEN_Opportunity__r.CEN_Proyecto__r.CEN_CODIGOSAP__c,CEN_Opportunity__r.CEN_NroFinanciamiento_SAP__c,
                                            CEN_Opportunity__r.CEN_N_Cuotas_del_Saldo_del_precio__c,CEN_Opportunity__r.CEN_AmountPaidDate__c,
                                            CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c,CEN_PaymentDate__c,CEN_Opportunity__r.CEN_Proforma__c,
                                            CEN_Installments__c,CEN_Amount__c,CEN_OriginPayment__c ,CEN_DueDate__c,CEN_PaymentCode__c,CEN_SocietySAP__c,
                                            CEN_AccountNumberByBank__c,CEN_Fee__c,CEN_LastFour__c,CEN_PaymentDescription__c,CEN_MessageError__c,
                                            CEN_CountryCode__c, CEN_Banks__c, CEN_BankDescription__c,CEN_DocumentNumberSAP__c,CEN_DocumentDateSAP__c,OwnerId, CEN_PaymentStatus__c,
                                            CEN_AdvanceNumber__c, CEN_AdvanceSociety__c, CEN_AdvanceYear__c, CEN_OriginData__c, CEN_Observations__c, CEN_ID_Culqi__c,
                                            CEN_Processing__c, CEN_CurrencyCode__c
                                            FROM CEN_PaymentOrder__c WHERE Id =:paymentId ];
            String myOpp = paymentData.CEN_Opportunity__c;
            if(paymentData.CEN_DocumentNumberSAP__c == null){
                if(paymentData.CEN_Opportunity__r.CEN_Proforma__c !=null){
                    CEN_ProcessPaymentObjectResponse resp = CEN_ProcessPayments_cls.generateOperationByOppId(paymentData);

                    Set<String> recipientId = new Set<String> {paymentData.OwnerId};
                    List<String> recipientIdList = new List<String> {paymentData.OwnerId};

                    if(resp != null && resp.ET_RETURN!=null && resp.ET_RETURN.item[0].TYPE_x == 'S'){
                        String numPaymentSap;
                        String societySap;
                        String yearSap;
                        if (paymentData.CEN_OriginPayment__c == 'Anticipos Sueltos'){
                            if(resp.BELNR_ANTI!=null){
                                numPaymentSap = String.valueOf(resp.BELNR_ANTI);
                                societySap = String.valueOf(resp.BUKRS_ANTI);
                                yearSap = String.valueOf(resp.GJAHR_ANTI);
                            }else{
                                numPaymentSap = paymentData.CEN_AdvanceNumber__c;
                                societySap = paymentData.CEN_AdvanceSociety__c;
                                yearSap = paymentData.CEN_AdvanceYear__c;
                            }
                        }else{
                            numPaymentSap = String.valueOf(resp.ET_PAGOS_CLIENTE.item[0].BELNR);
                            societySap = String.valueOf(resp.ET_PAGOS_CLIENTE.item[0].BUKRS);
                            yearSap = String.valueOf(resp.ET_PAGOS_CLIENTE.item[0].GJAHR);
                        }
                        notiTitle='Pago procesado en SAP';
                        notiBody='Se ha registrado en SAP el pago numero: ' + numPaymentSap;
                        paymentData.CEN_DocumentNumberSAP__c = numPaymentSap;
                        paymentData.CEN_SocietySAP__c = societySap;
                        paymentData.CEN_DocumentYearSAP__c = yearSap;
                        paymentData.CEN_PaymentStatus__c = 'Pagado';
                        paymentData.CEN_PaymentDateSAP__c = DateTime.Now();
                        paymentData.CEN_MessageError__c = null;
                        generatedMapResp.put('success', resp.ET_RETURN.item[0].MESSAGE);

                        String myTemplate;
                        Decimal amountPaidDate = paymentData.CEN_Opportunity__r.CEN_AmountPaidDate__c + paymentData.CEN_Amount__c;
                        if(amountPaidDate >= paymentData.CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c){
                            myTemplate = 'CEN_ParcialPaymentRegisteredSuccessfullyInitialAmountCompleted';
                            CEN_InformativeTotalPayment_ctr.generarPDF(paymentData.CEN_Opportunity__r.Id);
                        }else{
                            myTemplate = 'CEN_ParcialPaymentRegisteredSuccessfully';
                            CEN_InformativeParcialPayment_ctr.generarPDF(paymentData.Id);
                        }

                        update paymentData;
                        updateAmountPaidDate(myOpp); // v1.1 Elvis
                        try { // v1.1 Elvis
                            SendMail(recipientIdList, paymentData.Id, myTemplate);
                        } catch (Exception ex) {
                            System.debug('Error: '+ex);
                        }
                       

                    }else{
                        String errorPaymentSap = resp.ET_RETURN.item[0].MESSAGE;
                        notiTitle='Error al registrar pago en SAP';
                        notiBody='Error:' + errorPaymentSap;
                        paymentData.CEN_PaymentStatus__c = 'PendienteSAP';
                        paymentData.CEN_MessageError__c = errorPaymentSap;
                        generatedMapResp.put('error',errorPaymentSap);
                        update paymentData;
                    }

                    paymentNotification(notiTitle,  notiBody, paymentId, recipientId);

                    //update paymentData;
                    ID jobID = System.enqueueJob(new CEN_PaymentOrderProcess_ctr(myOpp),1);

                }else{
                    paymentData.CEN_MessageError__c = 'Pago sin proforma';
                    update paymentData;
                }

            }else{
                paymentData.CEN_PaymentStatus__c = 'Pagado';
                update paymentData;
            }
        }catch(Exception ex){
            CEN_PaymentOrder__c payment = new CEN_PaymentOrder__c();
            payment.Id =paymentId;
            payment.CEN_Observations__c = ex.getMessage() + ' Line:' + ex.getLineNumber() + ' Type:' + ex.getTypeName();
            update payment;
            generatedMapResp.put('error',ex.getMessage());
        }

        return generatedMapResp;
    }

    private static void updateAmountPaidDate(String oppId){

        List<CEN_PaymentOrder__c> paymentOrderList = [SELECT Id,
                                                      CEN_Amount__c,
                                                      CEN_PaymentStatus__c,
                                                      CEN_Opportunity__r.CEN_Proyecto__r.CEN_monto_minimo_reserva__c,
                                                      CEN_Opportunity__r.CEN_Proyecto__r.CEN_monto_minimo_deposito__c ,
                                                      CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c,
                                                      CEN_Opportunity__r.CEN_Sub_estado__c,
                                                      CEN_Opportunity__r.CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c
                                                      FROM CEN_PaymentOrder__c
                                                      WHERE CEN_Opportunity__c =: oppId
                                                      AND CEN_PaymentStatus__c IN ('Pagado', 'Procesando')];

        if(paymentOrderList != null && paymentOrderList.size()> 0){
            Decimal montoPagoFecha = 0;
            Opportunity opp = new Opportunity();
            for(CEN_PaymentOrder__c po :paymentOrderList ){
                montoPagoFecha = montoPagoFecha + po.CEN_Amount__c;
            }
            Decimal montoReserva = paymentOrderList[0].CEN_Opportunity__r.CEN_Proyecto__r.CEN_monto_minimo_reserva__c; //20
            Decimal montoDeposito = paymentOrderList[0].CEN_Opportunity__r.CEN_Proyecto__r.CEN_monto_minimo_deposito__c; //100
            Decimal montoInicial = paymentOrderList[0].CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c;
            String subEstado = paymentOrderList[0].CEN_Opportunity__r.CEN_Sub_estado__c;
            opp.CEN_TypeOperation__c = 'OPERACION CON DEPOSITO' ;

            if(montoPagoFecha == 0 && (subEstado == 'OPERACION CON DEPOSITO PARCIAL' ||  subEstado == 'OPERACION CON DEPOSITO TOTAL')){opp.CEN_Sub_estado__c = 'OPERACION CON DEPOSITO';}
            else if(montoPagoFecha<montoInicial && montoPagoFecha != 0){opp.CEN_Sub_estado__c = 'OPERACION CON DEPOSITO PARCIAL'; }
            else if(montoPagoFecha>=montoInicial){ opp.CEN_Sub_estado__c = 'OPERACION CON DEPOSITO TOTAL'; }

            opp.CEN_SubTypeOperation__c =  opp.CEN_Sub_estado__c == 'OPERACION CON DEPOSITO PARCIAL'?'Parcial':'total';
            opp.CEN_AmountPaidDate__c = montoPagoFecha;
            opp.Id = oppId;
            opp.CEN_LastApiCall__c = System.now();
            update opp;
        }
    }

    private static void paymentNotification (String notiTitle, String notiBody, String notiTarget,Set<String> notiRecipients){
        String notiId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notificacin_de_la_organizacin' ].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notiTitle);
        notification.setBody(notiBody);
        notification.setNotificationTypeId(notiId);
        notification.setTargetId(notiTarget);
        notification.send(notiRecipients);
    }

    private static void SendMail(List<String> ownerId, String paymentId, String myTemplate){

        CEN_PaymentOrder__c pay = [SELECT Id,
                                   Name,
                                   LastModifiedDate,
                                   RecordType.Name,
                                   CEN_Amount__c,
                                   CEN_Opportunity__c,
                                   CEN_Opportunity__r.Name,
                                   CEN_Opportunity__r.Owner.Name,
                                   CEN_Opportunity__r.CEN_AmountPaidDate__c,
                                   CEN_Opportunity__r.CEN_Inicial_de_precio__c,
                                   CEN_Opportunity__r.CEN_Moneda__c
                                   FROM CEN_PaymentOrder__c
                                   WHERE Id =: paymentId];

        List<EmailTemplate> lstEmailTemplates =  new List<EmailTemplate>();
        lstEmailTemplates = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName =: myTemplate];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String sSubject = lstEmailTemplates[0].Subject;
        sSubject = sSubject.replace('{!Opportunity.Name}', pay.CEN_Opportunity__r.Name);
        String sBody = lstEmailTemplates[0].HtmlValue;
        sBody = sBody.replace('{!Opportunity.OwnerFullName}', Test.isRunningTest() ? 'Prueba Test' : pay.CEN_Opportunity__r.Owner.Name);
        sBody = sBody.replace('{!CEN_PaymentOrder__c.LastModifiedDate}', String.valueOf(pay.LastModifiedDate));
        sBody = sBody.replace('{!Opportunity.Name}', pay.CEN_Opportunity__r.Name);
        sBody = sBody.replace('{!CEN_PaymentOrder__c.Name}', pay.Name);
        sBody = sBody.replace('{!CEN_PaymentOrder__c.RecordType}', pay.RecordType.Name);
        sBody = sBody.replace('{!CEN_PaymentOrder__c.CEN_Amount__c}', String.valueOf(pay.CEN_Amount__c));
        sBody = sBody.replace('{!Opportunity.CEN_Moneda__c}', String.valueOf(pay.CEN_Opportunity__r.CEN_Moneda__c));
        sBody = sBody.replace('{!Opportunity.CEN_AmountPaidDate__c}', String.valueOf(pay.CEN_Opportunity__r.CEN_AmountPaidDate__c));
        sBody = sBody.replace('{!Opportunity.CEN_Inicial_de_precio__c}', String.valueOf(pay.CEN_Opportunity__r.CEN_Inicial_de_precio__c));
        sBody = sBody.replace('<a href="{!Opportunity.Link}">Link</a>','<a href="'+URL.getSalesforceBaseUrl()+'/'+pay.CEN_Opportunity__c+'">Link</a>');

        mail.setSubject(sSubject);
        mail.setHtmlBody(sBody);
        mail.setToAddresses(ownerId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSaveAsActivity(true);
		mail.setWhatId(pay.Id);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @future (callout=true)
    public static void generateAndUpdateProcessPaymentAsinc(String payId){
        Map<String,String> mapResp =  generateAndUpdateProcessPayment(payId) ;
    }

    @InvocableMethod(label='processPaymentInSap')
    public static List<String> processPaymentInSap(List<FlowParameters> parameters){

        List<String> resp = new List<String> ();
        List<String> myIds = new List<String> ();
        system.debug('IN processPaymentInSap : '+parameters);
        if(parameters!=null && parameters.size()>0 && parameters[0].opIds!=null && parameters[0].opIds.size()>0 ){
            system.debug('processPaymentInSap-Ids : '+parameters[0].opIds);
            CEN_ProcessPayment_ctr.generateAndUpdateProcessPaymentAsinc(parameters[0].opIds[0]);
            resp.add('ok-'+parameters[0].opIds[0]);
        }else{
            resp.add('');
        }

        return resp;
    }

    public class FlowParameters {
        @InvocableVariable(label='OPIdsParamts' description='Ids Payments Order parameter' required=true)
        public List<String> opIds;
    }

    public class ProcessPaymentException extends Exception {
    }

}