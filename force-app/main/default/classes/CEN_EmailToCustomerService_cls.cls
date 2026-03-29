/********************************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-05-28
* @description: web service para envío de correos desde la web de terrenos.
* 
* VERSION		DATE			AUTOR					ACTION
* 0.1			2021-05-28		Alan Alvarez			Creación
*
********************************************************************************/
@RestResource(urlMapping='/sendEmailMessage/*')
global class CEN_EmailToCustomerService_cls {
    
    @HttpPost
    global static String doSendEmail() {
        try{
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            wrapEmail newEmail = (wrapEmail)getBodyHtml(params);
            String templateName = (String)params.get('templateName');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(newEmail.subject);
            message.setHtmlBody(newEmail.htmlBody);
            message.toAddresses = newEmail.toAddresses;
            message.setTreatTargetObjectAsRecipient(false);
            //message.setTargetObjectId(customer.Id);
            message.setSaveAsActivity(true);
            if(newEmail.targetId != null) { message.setWhatId(newEmail.targetId); }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            if(newEmail.isNotification == true){
                sendNotification(templateName, newEmail);
            }
            if (results[0].success) {
                return 'Success:El correo fue enviado con éxito';
            }else{ 
                return 'Error:' + results[0].errors[0].message;
            }
        }catch (Exception ex) {
            return 'Error:' + ex.getMessage();
        }
    }
    
    public static wrapEmail getBodyHtml(Map<String, Object> params){
        wrapEmail tmpEmail = new wrapEmail();
        String templateName = (String)params.get('templateName');
        if(String.isEmpty(templateName)){throw new EmailToCustomerServiceException('El Nombre de Plantilla de Correo es obligatorio. Por favor verificar.');}
        EmailTemplate template = getTemplateHtmlValue(templateName);
        if(templateName == 'CEN_WebTerrenoAdviser'){
            //Validamos
            String strDocumentNumber = (String)params.get('documentNumber');
            if(String.isEmpty(strDocumentNumber)){throw new EmailToCustomerServiceException('El Número de Documento es obligatorio. Por favor verificar.');}
            wrapAccount customer = getAccountDocumentNumber(strDocumentNumber);
            //Asignamos
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{{{Recipient.FirstName}}}', customer.ownerName);
            htmlBody = htmlBody.replace('{{{Account.Name}}}', customer.Name);
            htmlBody = htmlBody.replace('{{{Account.CEN_N_mero_de_documento__pc}}}', customer.documentNumber);
            htmlBody = htmlBody.replace('{{!Today()}}', String.valueOf(Datetime.now()));
            String description = template.Description;
            description = description.replace('{{{Account.Name}}}', customer.Name);
            List<String> lstEmail = new List<String>();
            lstEmail.add(customer.ownerEmail);
            Set<String> setRecept = new Set<String>();
            setRecept.add(customer.ownerId);
            //Creamos
            tmpEmail.subject = template.Subject;
            tmpEmail.htmlBody = htmlBody;
            tmpEmail.description = description;
            tmpEmail.toAddresses = lstEmail;
            tmpEmail.isNotification = true;
            tmpEmail.targetId = customer.id;
            tmpEmail.recipient = setRecept;   
        }else if(templateName == 'CEN_WebTerrenoVerificationCode'){
            //Validamos
            String strDocumentNumber = (String)params.get('documentNumber');
            String strVerificationCode = (String)params.get('verificationCode');
            if(String.isEmpty(strDocumentNumber)){throw new EmailToCustomerServiceException('El Número de Documento es obligatorio. Por favor verificar.');}
            if(String.isEmpty(strVerificationCode)){throw new EmailToCustomerServiceException('El Código de Verificación. Por favor verificar.');}
            wrapAccount customer = getAccountDocumentNumber(strDocumentNumber);
            //Asignamos
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{{{Account.Name}}}', customer.Name);
            htmlBody = htmlBody.replace('{{!VerificationCode}}', strVerificationCode);
            List<String> lstEmail = new List<String>();
            lstEmail.add(customer.email);
            //Creamos
            tmpEmail.subject = template.Subject;
            tmpEmail.htmlBody = htmlBody;
            tmpEmail.toAddresses = lstEmail;
            tmpEmail.targetId = customer.id;
        }else if(templateName == 'CEN_WebTerrenoConfirmation'){
            //Validamos
            String strNumberOrderPayment = (String)params.get('numberOrderPayment');
            if(String.isEmpty(strNumberOrderPayment)){throw new EmailToCustomerServiceException('El Número de Orden de Pago es obligatorio. Por favor verificar.');}
            CEN_PaymentOrder__c orderpayment = getOrderPayment(strNumberOrderPayment);
            //Asignamos
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{{{Account.Name}}}', orderpayment.CEN_Opportunity__r.Account.Name);
            htmlBody = htmlBody.replace('{{!Order.Name}}', orderpayment.Name);
            htmlBody = htmlBody.replace('{{!Order.Amount}}', String.valueOf(orderpayment.CEN_Amount__c));
            htmlBody = htmlBody.replace('{{!Order.Sociedad}}', String.valueOf(orderpayment.CEN_Society__c));
            htmlBody = htmlBody.replace('{{!Order.Banco}}', String.isEmpty(orderpayment.CEN_BankDescription__c)?'':orderpayment.CEN_BankDescription__c);
            //htmlBody = htmlBody.replace('{{!Order.CodigoAutorizacion}}', String.valueOf(orderpayment.CEN_PaymentCode__c));
            String paymentdate = '';
            if(orderpayment.CEN_PaymentDate__c != null){paymentdate = String.valueOf(orderpayment.CEN_PaymentDate__c);}
            htmlBody = htmlBody.replace('{{!Order.PaymentDate}}', paymentdate);
            String descrip = '';
            if(orderpayment.CEN_PaymentDescription__c != null){descrip = orderpayment.CEN_PaymentDescription__c;}
            htmlBody = htmlBody.replace('{{!Order.Description}}', descrip);
            List<String> lstEmail = new List<String>();
            String toEmail = orderpayment.CEN_Opportunity__r.Account.PersonEmail != null
                			? orderpayment.CEN_Opportunity__r.Account.PersonEmail
                			: orderpayment.CEN_Opportunity__r.Account.CEN_fld_Correo_empresa__c;
            lstEmail.add(toEmail);
            //Creamos
            tmpEmail.subject = template.Subject;
            tmpEmail.htmlBody = htmlBody;
            tmpEmail.toAddresses = lstEmail;
            tmpEmail.targetId = orderpayment.id;
        }
        return tmpEmail;
    }
    
    public static void sendNotification(String templateName, wrapEmail newEmail){
        try{
            if(templateName == 'CEN_WebTerrenoAdviser'){
                CustomNotificationType notificationType = [select Id, DeveloperName from CustomNotificationType where DeveloperName = 'Notificacin_de_la_organizacin'];
                // Create a new custom notification
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                // Set the contents for the notification
                notification.setTitle(newEmail.subject);
                notification.setBody(newEmail.description);
                //Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(newEmail.targetId);
                notification.send(newEmail.recipient);
            }
        }catch (Exception ex) {
            System.debug('sendNotification-Error: ' + ex.getMessage());
        }
    }
    
    public static CEN_PaymentOrder__c getOrderPayment(String numberOder){
        List<CEN_PaymentOrder__c> lstOrder = [select Id, Name, 
                                              CEN_Amount__c, CEN_PaymentDate__c, CEN_PaymentDescription__c,
                                              CEN_Opportunity__r.Account.PersonEmail,
                                              CEN_Opportunity__r.Account.CEN_fld_Correo_empresa__c,
                                              CEN_Opportunity__r.Account.Name, toLabel(CEN_Society__c),
                                              CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c,
                                              CEN_Banks__c, CEN_PaymentCode__c, CEN_BankDescription__c
                                              from CEN_PaymentOrder__c  where name = :numberOder];
        if(lstOrder.size() > 0){
            return lstOrder[0];
        }else{
            throw new EmailToCustomerServiceException('No existe la Orden de Pago. Por favor verificar.');
        }
    }
    
    public static EmailTemplate getTemplateHtmlValue(String strTemplateName){
        List<EmailTemplate> lstTemplate = [select Subject, HtmlValue, Description from EmailTemplate where DeveloperName = :strTemplateName];
        if(lstTemplate.size() > 0){
            return lstTemplate[0];
        }else{
            throw new EmailToCustomerServiceException('No existe la plantilla de correo enviada. Por favor verificar.');
        }
    }
    
    public static wrapAccount getAccountDocumentNumber(String strDocumentNumber){
        List<Account> lstCustomerPerson = [select Id, Name,
                                           CEN_N_mero_de_documento__pc, PersonEmail,
                                           Owner.Id, Owner.FirstName, Owner.Email
                                           from account where CEN_N_mero_de_documento__pc = :strDocumentNumber];
        if(lstCustomerPerson.size() > 0){
            wrapAccount acc = new wrapAccount();
            acc.id = lstCustomerPerson[0].id;
            acc.name = lstCustomerPerson[0].Name;
            acc.documentNumber = lstCustomerPerson[0].CEN_N_mero_de_documento__pc;
            acc.email = lstCustomerPerson[0].PersonEmail;
            acc.ownerId = lstCustomerPerson[0].Owner.Id;
            acc.ownerName = lstCustomerPerson[0].Owner.FirstName;
            acc.ownerEmail = lstCustomerPerson[0].Owner.Email;
            return acc;
        }else{
            List<Account> lstCustomerCompany = [select Id, Name, 
                                                CEN_Numero_de_documento_del__c, CEN_fld_Correo_empresa__c,
                                                Owner.FirstName, Owner.Email
                                                from account where CEN_Numero_de_documento_del__c=:strDocumentNumber];
            if(lstCustomerCompany.size() > 0){
                wrapAccount acc = new wrapAccount();
                acc.id = lstCustomerCompany[0].id;
                acc.name = lstCustomerCompany[0].Name;
                acc.documentNumber = lstCustomerCompany[0].CEN_Numero_de_documento_del__c;
                acc.email = lstCustomerCompany[0].CEN_fld_Correo_empresa__c;
                acc.ownerId = lstCustomerCompany[0].Owner.Id;
                acc.ownerName = lstCustomerCompany[0].Owner.FirstName;
                acc.ownerEmail = lstCustomerCompany[0].Owner.Email;
                return acc;
            }else{
                throw new EmailToCustomerServiceException('El Número de Documento no se encuentra asociada a una cuenta. Por favor verificar.');
            }
        }
    }
    
    public class wrapAccount{
        public id id;
        public string name;
        public string documentNumber;
        public string email;
        public id ownerId;
        public string ownerName;
        public string ownerEmail;
    }
    
    global class wrapEmail{
        private String subject {get; set;}
        private String htmlBody {get; set;}
        private String description {get; set;}
        private String[] toAddresses {get; set;}
        private boolean isNotification {get; set;}
        private id targetId {get; set;}
        private Set<String> recipient {get; set;}
    }
    
    public class EmailToCustomerServiceException extends Exception {
    }
    
}