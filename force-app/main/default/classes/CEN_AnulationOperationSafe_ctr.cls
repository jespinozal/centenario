/**
 * @description       : Clase controladora para cerrar oportunidades a pedido de devolución del cliente y actualizar ordenes de pago a 'Suelto' o 'Devuelto'.
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             :
 * @last modified on  : 07-13-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/
public without sharing class CEN_AnulationOperationSafe_ctr {

    @InvocableMethod(label='anulatePaymentOrder')
    public static void anulatePaymentOrderProcess(List<Opportunity> opps){
        Opportunity opp = opps[0];
            if(!opp.CEN_devolucion_saldo_Afavor__c){
                generarPDF(opp.id);
            }else{
                CEN_ReservationUpdateEmail_ctr.doSendEmail(opp.id);
            }
        system.debug('CEN_AnulationOperationSafe_ctr');

        anulatePaymentSAP(opp.id);
    }

    @future(callout=true)
    public static void generarPDF(String idOportunidad) {
        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_MoneyRefundRequestPDF_vf;
        pdfPage.getParameters().put('Id', idOportunidad);

        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContentAsPDF();
            }

            if (pdfGenerado != null && String.isNotBlank(idOportunidad)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Solicitud devolución de dinero PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                insert objAttachment;
                listAttachments.add(objAttachment);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: '+e.getMessage()+'. Type: '+e.getTypeName()+'. Line: '+e.getLineNumber());
        }
    }

    @Future(callout=true)
    public static void anulatePaymentSAP(Id oppId){
        System.debug('Anulacion en masa comienzo IDopp: ' + oppId);
        Boolean executeNotification = false;
        System.debug('anulatePaymentSAP');
        Opportunity opp = [Select Id, Name, CEN_estado_aprobacion__c,CEN_devolucion_saldo_Afavor__c, ownerId, CEN_LoteEliminado__c, StageName,
                            Owner.Name, CEN_Supervisor__r.Name, Owner.Email, CEN_Supervisor__r.Email, CEN_Motivo_Cierre_Perdida__c
                            from Opportunity where id =:oppId];

        List<CEN_PaymentOrder__c> payments = new List<CEN_PaymentOrder__c>();
        payments = [SELECT Name FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =: oppId AND 	CEN_PaymentStatus__c = 'Pagado'];
        String namePayments = '';
        for(CEN_PaymentOrder__c payment : payments){
            namePayments +=  payment.Name + ',';
        }

        namePayments = namePayments.removeEnd(',');

        List<String> addresses = new List<String>();
        addresses.add(opp.Owner.Email);
        addresses.add(opp.CEN_Supervisor__r.Email);

        List<User> analistas = [SELECT id FROM User WHERE userRole.developername = 'Analista_de_Gesti_n_de_la_informaci_n' AND IsActive = true];

        CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse resp = CEN_AnulationOperationSafe_cls.anulateOperationByOppId(opp.Id);
        System.debug('Response: ' + resp);
        Set<String> recipientId = new Set<String> {opp.OwnerId};
        for(User us : analistas){
            recipientId.add(us.id);
        }
        CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = 'Notificacin_de_la_organizacin'
        ];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        String bodyNotification = '';
        String bNotificationFavor = 'Se ha notificado a SAP el proceso de asignación a Saldo a favor: ' + resp.ET_RETURN.item[0].MESSAGE;
        String bNotificationDevolucion = 'Se ha notificado a SAP el proceso de devolución al cliente: ' + resp.ET_RETURN.item[0].MESSAGE;
        System.debug('TIPO DATO');
		System.debug(resp.ET_RETURN.item[0].TYPE_x );
        if(resp != null && (resp.ET_RETURN.item[0].TYPE_x != 'S' && resp.ET_RETURN.item[0].TYPE_x != 'I' && resp.ET_RETURN.item[0].TYPE_x != 'W')){

            if(resp != null && resp.ET_RETURN.item[0].MESSAGE == 'La OCD no se anula porque el pago no fue depositado'){

                bodyNotification = 'La OCD no se anula porque el pago no ha sido procesado por el área de cuentas por cobrar';

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Notificación de Anulación');
                String msgEmail = 'Hola ' + opp.Owner.Name + ' y ' + opp.CEN_Supervisor__r.Name + ', <br/><br/>';
                msgEmail += 'No se pudo procesar la devolución a la oportunidad ' + opp.Name + ' porque no se ha validado que el(los) pago(s) ' + namePayments + ' estén en las cuentas de centenario. <br/><br/>';
                msgEmail += 'Favor contactar al área de cuentas por cobrar (' + label.CEN_UserAccountReceivable + ') y asegurarse que los pagos estén contabilizados. <br/><br/>';
                email.setHTMLBody(msgEmail);
                email.setToAddresses(addresses);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(true);
		        email.setWhatId(oppId);
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }

            }else{
                bodyNotification = 'Ocurrio el siguiente error al registrar a SAP: ' + resp.ET_RETURN.item[0].MESSAGE;
            }
        }else{

            Set<String> documentNumberSAP = new Set<String>();
            Set<String> societySAP = new Set<String>();
            Set<String> documentYearSAP = new Set<String>();
            Map<String, CEN_PaymentOrder__c> mapPayment = new Map<String, CEN_PaymentOrder__c> {};
            for(CEN_AnulationOperationSafeResponse.ZST_DOCUMENTOS_OTC wrp : resp.ET_DOCUMENTOS.item){
                mapPayment.put(wrp.BELNR_PAGO, new CEN_PaymentOrder__c(CEN_AdvanceNumber__c=wrp.BELNR, CEN_AdvanceSociety__c=wrp.BUKRS, CEN_AdvanceYear__c=wrp.GJAHR));
                documentNumberSAP.add(wrp.BELNR_PAGO);
                societySAP.add(wrp.BUKRS_PAGO);
                documentYearSAP.add(wrp.GJAHR_PAGO);
            }

            List<CEN_PaymentOrder__c> foundPayments = [SELECT
                                                        Id,
                                                        CEN_AdvanceNumber__c,
                                                        CEN_AdvanceSociety__c,
                                                        CEN_AdvanceYear__c,
                                                        CEN_SocietySAP__c,
                                                        CEN_DocumentNumberSAP__c,
                                                        CEN_DocumentYearSAP__c
                                                        FROM CEN_PaymentOrder__c
                                                        WHERE CEN_DocumentNumberSAP__c IN: documentNumberSAP
                                                        AND CEN_SocietySAP__c IN: societySAP
                                                        AND CEN_DocumentYearSAP__c IN: documentYearSAP
                                                    ];

            List<CEN_PaymentOrder__c> paymentsUpdate = new List<CEN_PaymentOrder__c>();
            for(CEN_PaymentOrder__c p: foundPayments){
                CEN_PaymentOrder__c payment = new CEN_PaymentOrder__c();
                payment.Id = p.Id;
                payment.CEN_AdvanceNumber__c = mapPayment.get(p.CEN_DocumentNumberSAP__c).CEN_AdvanceNumber__c;
                payment.CEN_AdvanceSociety__c = mapPayment.get(p.CEN_DocumentNumberSAP__c).CEN_AdvanceSociety__c;
                payment.CEN_AdvanceYear__c = mapPayment.get(p.CEN_DocumentNumberSAP__c).CEN_AdvanceYear__c;
                paymentsUpdate.add(payment);
            }

            update paymentsUpdate;

            bodyNotification = opp.CEN_devolucion_saldo_Afavor__c? bNotificationFavor : bNotificationDevolucion;
            if(!opp.CEN_LoteEliminado__c){
                opp.CEN_estado_aprobacion__c = 'EJECUTADO';
                opp.StageName = 'Oportunidad Perdida';
                opp.CEN_Motivo_Cierre_Perdida__c = String.isBlank(opp.CEN_Motivo_Cierre_Perdida__c) ? 'DC' : opp.CEN_Motivo_Cierre_Perdida__c;
                update opp;
            }
        }
            notification.setTitle('Notificacion SAP');
            notification.setBody(bodyNotification);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(opp.Id);
        if(!opp.CEN_LoteEliminado__c && String.isNotEmpty(bodyNotification)){
            notification.send(recipientId);
        }
    }
}