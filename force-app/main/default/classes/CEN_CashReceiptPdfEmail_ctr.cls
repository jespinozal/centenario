public class CEN_CashReceiptPdfEmail_ctr {
    
    @future(callout=true)
    public static void doSendEmail(String idPayment) {
        try {
            CEN_PaymentOrder__c payment = [Select Id, Name, OwnerId, CEN_Amount__c, CEN_Opportunity__c, CEN_Opportunity__r.Name, CEN_Opportunity__r.AccountId From CEN_PaymentOrder__c Where Id = :idPayment];
			Account acc = [Select Id, Name, PersonEmail, CEN_fld_Correo_empresa__c, RecordType.DeveloperName From Account Where Id = :payment.CEN_Opportunity__r.AccountId];
            //Generacion PDF            
            List<Attachment> listAttachments = new List<Attachment>();
            Blob pdfGenerado;
            PageReference pdfPage = (PageReference) Page.CEN_CashReceiptPdf_vf;
            pdfPage.getParameters().put('id', idPayment);
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContent();
            }
            if (pdfGenerado != null && String.isNotBlank(idPayment)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idPayment;
                objAttachment.Name = 'Constancia de recepcion de efectivo en caseta - '+payment.Name+'.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(payment.CEN_Opportunity__c)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = payment.CEN_Opportunity__c;
                objAttachment.Name = 'Constancia de recepcion de efectivo en caseta - '+payment.Name+'.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            insert listAttachments;
            //Create Email
            List<EmailTemplate> lstTemplate = [Select Id, Subject, HtmlValue, body, Description From EmailTemplate Where DeveloperName = 'CEN_TemplateCashReceiptPdf'];
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSaveAsActivity(true);
            message.setwhatid(payment.CEN_Opportunity__c);
            message.setSubject(lstTemplate[0].Subject.replace('{{{CEN_PaymentOrder__c.Name}}}', payment.Name));
            String body = lstTemplate[0].HtmlValue;
            body = body.replace('{{{Account.Name}}}', acc.Name);
            body = body.replace('{{{Opportunity.Name}}}', payment.CEN_Opportunity__r.Name);
            body = body.replace('{{{CEN_PaymentOrder__c.Name}}}', payment.Name);
            body = body.replace('{{{CEN_PaymentOrder__c.CEN_Amount__c}}}', String.valueOf(payment.CEN_Amount__c));
            message.setHtmlBody(body);
            message.setTemplateId(lstTemplate[0].Id);
            //Attachment
            attach.setFileName('Constancia de recepcion de efectivo en caseta.pdf');
            attach.setBody(pdfGenerado);
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            //To
            List<String> lstEmail = new List<String>();
            if(acc.RecordType.DeveloperName == 'PersonAccount'){
                lstEmail.add(acc.PersonEmail);
            }else{
                lstEmail.add(acc.CEN_fld_Correo_empresa__c);
            }
            message.toaddresses = lstEmail;
            //Send
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            if (results[0].success) {
                System.debug('Success:El correo fue enviado con éxito');
            }else{ 
                System.debug('Error: No se pudo enviar correo: ' + results[0].errors[0].message);
            }
        } catch (Exception e) {
            System.debug('Error: No se pudo generar el PDF: ' + e.getMessage());
        }
    }
    
    @InvocableMethod(label='CashReceiptPdfEmail')
    public static List<String> processCashReceiptPdfEmail(List<Id> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0){
            for(Id myPayment : parameters){
                doSendEmail(myPayment);
                resp.add(myPayment+'inProccess');
            }
        }else{
            resp.add('empty');
        }
        return resp;
    }
    
}