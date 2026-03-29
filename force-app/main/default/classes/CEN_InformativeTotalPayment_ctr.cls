public class CEN_InformativeTotalPayment_ctr {

    // @future(callout=true)
    public static void generarPDF(String idOportunidad) {    

        // Opportunity opp = new Opportunity();
        // opp = [SELECT Owner.Name,Owner.Email, Name FROM Opportunity WHERE Id=:idOportunidad];

        //String idOportunidad = payment.CEN_Opportunity__c;
        
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
        PageReference pdfPage = (PageReference) Page.CEN_vf_pdfInformativeTotalPayment;
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
                objAttachment.Name = 'Documento_Informativo_Pago_Total' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            
            insert listAttachments;

            //Create Email
            List<EmailTemplate> lstTemplate = [Select Id, Subject, HtmlValue, body, Description From EmailTemplate Where DeveloperName = 'CEN_TemplateTotalPaymentPdf'];
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'notificaciones.ventas@centenario.com.pe'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
                message.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            message.setSubject(lstTemplate[0].Subject);
            String body = lstTemplate[0].HtmlValue;
            body = body.replace('{{{Owner.Name}}}', NombreCuenta);
            body = body.replace('{{{Opportunity.Name}}}', opp.Name);
            message.setHtmlBody(body);
            message.setTemplateId(lstTemplate[0].Id);
            //Attachment
            attach.setFileName('Documento_Informativo_Pago_Total.pdf');
            attach.setBody(pdfGenerado);
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            //To
            List<String> lstEmail = new List<String>();
            lstEmail.add(correoCliente); //Pendiente
            message.toaddresses = lstEmail;
            //Send
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            if (results[0].success) {
                //  return 'Success:El correo fue enviado con éxito';
                System.debug('Success:El correo fue enviado con éxito');
            }else{ 
                //return 'Error: No se pudo enviar correo: ' + results[0].errors[0].message;
                System.debug('Error: No se pudo enviar correo: ' + results[0].errors[0].message);
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

    // @InvocableMethod(label='processInformativeTotalPayment')
    // public static List<String> processInformativeTotalPayment(List<FlowParameters> parameters){
    //     List<String> resp = new List<String>();
    //     if(parameters!=null && parameters.size()>0 && parameters[0].oppIds!=null && parameters[0].oppIds.size()>0 ){
    //     for(Integer i=0; i < parameters.size(); i++){  
    //         for(String myOpp : parameters[i].oppIds){
    //             generarPDF(myOpp);
    //         resp.add(myOpp+'inProccess');
    //         }
    //     }
    //     }else{
    //         resp.add('empty');
    //     }

    // return resp;
    // }

    // public class FlowParameters {
	// 	@InvocableVariable(label='oppIdsParamt' description='Ids Opportunities parameter' required=true)
	// 	public List<String> oppIds;
  	// }
}