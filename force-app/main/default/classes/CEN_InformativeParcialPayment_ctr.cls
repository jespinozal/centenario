public class CEN_InformativeParcialPayment_ctr {

    // @future(callout=true)
    public static void generarPDF(String idPayment) {          

        CEN_PaymentOrder__c payment = new CEN_PaymentOrder__c();
        payment = [SELECT Id, CEN_Opportunity__c, CEN_OriginPayment__c  
        FROM CEN_PaymentOrder__c
        WHERE Id=:idPayment];

        String idOportunidad = payment.CEN_Opportunity__c;
        
        Opportunity opp = new Opportunity();
        opp = [SELECT Owner.Name, Owner.Email, Name, Account.CEN_fld_Correo_empresa__c, Account.PersonEmail, Account.RecordTypeId, Account.Name 
        FROM Opportunity 
        WHERE Id=:idOportunidad];
        String NombreCuenta = opp.Account.Name;

        RecordType rt = new RecordType();
        rt = [SELECT Id,DeveloperName 
        FROM RecordType 
        WHERE Id =: opp.Account.RecordTypeId];
        String TipoPersona = rt.DeveloperName;
        String correoCliente;
        correoCliente = TipoPersona == 'PersonAccount' ? opp.Account.PersonEmail : opp.Account.CEN_fld_Correo_empresa__c;

        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_vf_pdfInformativeParcialPayment;
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
                objAttachment.Name = 'Documento_Informativo_Pago_Parcial' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            
            insert listAttachments;

            System.debug('payment.CEN_OriginPayment__c ' + payment.CEN_OriginPayment__c);

            if(payment.CEN_OriginPayment__c != 'Dinero en Efectivo'){
                //Create Email
                System.debug('entro al if');
                List<EmailTemplate> lstTemplate = [Select Id, Subject, HtmlValue, body, Description From EmailTemplate Where DeveloperName = 'CEN_TemplateParcialPaymentPdf'];
                System.debug('lstTemplate ' + lstTemplate);
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'notificaciones.ventas@centenario.com.pe'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                System.debug('email ' + message);
                message.setSubject(lstTemplate[0].Subject);
                String body = lstTemplate[0].HtmlValue;
                body = body.replace('{{{Owner.Name}}}', NombreCuenta);
                body = body.replace('{{{Opportunity.Name}}}', opp.Name);
                System.debug('body ' + body);
                message.setHtmlBody(body);
                message.setTemplateId(lstTemplate[0].Id);
                //Attachment
                System.debug('entro attachment');
                attach.setFileName('Documento_Informativo_Pago_Parcial.pdf');
                attach.setBody(pdfGenerado);
                message.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
                message.setSaveAsActivity(true);
                message.setwhatid(payment.Id);
                //To
                System.debug('entro to');
                List<String> lstEmail = new List<String>();
                System.debug('correoCliente ' + correoCliente);
                lstEmail.add(correoCliente); //Pendiente
                message.toaddresses = lstEmail;
                //Send
                System.debug('entro send');
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                if (results[0].success) {
                    //  return 'Success:El correo fue enviado con éxito';
                    System.debug('Success:El correo fue enviado con éxito');
                }else{ 
                    //return 'Error: No se pudo enviar correo: ' + results[0].errors[0].message;
                    System.debug('Error: No se pudo enviar correo: ' + results[0].errors[0].message);
                }
            }

        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'No se pudo generar el PDF: ' +
                e.getMessage() +
                '. Type: ' +
                e.getTypeName() +
                '. Line: ' +
                e.getLineNumber()
            );
        }
    }

    // @InvocableMethod(label='processInformativeParcialPayment')
    // public static List<String> processInformativeParcialPayment(List<FlowParameters> parameters){
    //     List<String> resp = new List<String>();
    //     if(parameters!=null && parameters.size()>0 && parameters[0].opIds!=null && parameters[0].opIds.size()>0 ){
    //     for(Integer i=0; i < parameters.size(); i++){  
    //         for(String myPayment : parameters[i].opIds){
    //             generarPDF(myPayment);
    //         resp.add(myPayment+'inProccess');
    //         }
    //     }
    //     }else{
    //         resp.add('empty');
    //     }

    // return resp;
    // }

    // public class FlowParameters {
	// 	@InvocableVariable(label='OPIdsParamts' description='Ids Payments parameter' required=true)
	// 	public List<String> opIds;
  	// }

}