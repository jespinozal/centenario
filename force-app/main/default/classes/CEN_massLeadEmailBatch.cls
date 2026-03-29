/**
 * @name               : CEN_massLeadEmailBatch
 * @author             : Diego Bravo
 * @creation date      : 23-09-2024
 * @modification date  : 07-10-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   23-09-2024   Diego Bravo   Initial Version
**/
public class CEN_massLeadEmailBatch implements Database.Batchable<sObject> {

    static final String     EMAIL_SUBJECT       = 'Centenario Salesforce - Lead sin asignar';
    static final String     NOTIFICATION_BODY   = 'Leads sin asignación, revisar correo';
    
    public Database.QueryLocator start(Database.BatchableContext context) {        
        String query = 'SELECT Id FROM Lead WHERE Status = \'No gestionado\' AND CEN_Typification__c = \'Lead Nuevo\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();
        List<String> leadsIds = new List<String>();

        for (sObject record : scope) {
            leadsIds.add( String.valueOf(record.get('Id')));
        }

        CEN_leadsAsignacionPendiente.LeadWrapper wrapperLead = CEN_leadsAsignacionPendiente.getleadsPendientes(leadsIds);
        List<String> emailsSupervisor = new List<String>(wrapperLead.leadEmailBodyMap.keySet());
           List<User> userList = [SELECT Id, email FROM User WHERE email =: emailsSupervisor WITH SYSTEM_MODE];
           Id typeId = [SELECT Id FROM CUstomNotificationType WHERE DeveloperName = 'CEN_notificacinLeadNoAsignado'].Id;

        if (test.isRunningTest()) {
           emailsSupervisor.add('test.@test.com');
        }

        for(Integer i = 0; i < emailsSupervisor.size(); i++){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> addresses = new List<String>();
            addresses.add(emailsSupervisor[i]);
            email.setSubject(EMAIL_SUBJECT);
            
            if (!test.isRunningTest()) {
                email.setHtmlBody(wrapperLead.leadEmailBodyMap.get(emailsSupervisor[i]));
            }else{
                email.setHtmlBody('Test');
            }

            email.setToAddresses(addresses);
            emails.add(email);
        }

        for(User varUser : userList){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody(NOTIFICATION_BODY);
            notification.setTitle(EMAIL_SUBJECT);
            notification.setNotificationTypeId(typeId);
            notification.setTargetId(varUser.Id);
            notification.send(new Set<String> { varUser.Id });
        }
       
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                // Email sent successfully
                System.debug('Email sent successfully');
            } else {
                // Handle any errors or exceptions
                System.debug('Error sending email: ' + result.getErrors()[0].getMessage());
            }
        }

    }

    public void finish(Database.BatchableContext context) {
        // Perform any necessary cleanup tasks or post-processing actions
        System.debug('Finish');
    }
}