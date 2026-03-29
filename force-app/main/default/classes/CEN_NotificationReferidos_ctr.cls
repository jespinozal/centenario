/**
 * @name               : CEN_NotificationReferidos_ctr
 * @author             : Joel Espinoza
 * @creation date      : 09-10-2024
 * @modification date  : 09-10-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : Clase para notificar a gestor por campana y a referido y referente.
 * @versions           : version 1.0: clase apex inicial
 * @test class         : CEN_Referidos_tst
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-10-2024   Joel Espinoza   Initial Version
**/

public with sharing class CEN_NotificationReferidos_ctr {

    @InvocableMethod
    public static void notificationReferido (List<Requests> requestList) {
        List<Results> responseWrapper= new List<Results>();
        Set<id> recordId = New Set<id>();

        for(Requests r: requestList){
            recordId.add(r.recordId);
            enviarEmailReferente(r.recordId,r.addresses, r.emailNotification);/**DESCOMENTAR SOLO PRUEBAS */
        }


        List<Case> records = [SELECT id FROM Case WHERE Id IN :recordId AND opportunity__r.stageName = 'Oportunidad Ganada'];
        if(records.size()>0){
            for(Case record : records){
                notificarCampanaGestor(record.id);
            }
        }

    }

    public static void notificarCampanaGestor(String recordId){
        List<User> gestores = [SELECT Id FROM User WHERE  profile.Name = 'CEN_GestorReferidos' AND IsActive = true];

        Set<String> recipientId = new Set<String>();
        for(User g : gestores){
            recipientId.add(g.id);
        }

        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Notificacin_de_la_organizacin'
        ];

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        String bodyNotification = 'Revisar Interacción Oportunidad Ganada';
        notification.setTitle('Notificación Referido');
        notification.setBody(bodyNotification);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(recordId);
        notification.send(recipientId);
    }

    public static void enviarEmailReferente(String recordId,List<String> addresses, String emailNotification){
        List<Case> lstCase = [SELECT Id, Account__r.FirstName,  LeadId__r.Referente__r.FirstName,  CEN_nombre_actualizado__c, LeadId__r.FirstName FROM Case WHERE Id =: recordId AND Origin = 'Referidos' order by createddate desc];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<EmailTemplate> lstTemplate = [Select Id, Subject, HtmlValue, body, Description From EmailTemplate Where Name =: emailNotification];
        System.debug('lstTemplate ' + lstTemplate);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'referidos@centenario.com.pe'];
        if ( owea.size() > 0) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        email.setSubject(lstTemplate[0].Subject);
        String cuerpoCorreo = lstTemplate[0].HtmlValue;
        cuerpoCorreo = cuerpoCorreo.replace('{{{Referente}}}', lstCase[0].Account__r.FirstName!=null? lstCase[0].Account__r.FirstName: (lstCase[0].LeadId__r.Referente__r.FirstName != null ? lstCase[0].LeadId__r.Referente__r.FirstName : 'Referente'));
        cuerpoCorreo = cuerpoCorreo.replace('{{{Referido}}}', lstCase[0].CEN_nombre_actualizado__c!=null? lstCase[0].CEN_nombre_actualizado__c: (lstCase[0].LeadId__r.FirstName!=null? lstCase[0].LeadId__r.FirstName : 'Referido'));
        email.setTemplateId(lstTemplate[0].Id);
        email.setHTMLBody(cuerpoCorreo);
        List<String> addressSF = new List<String>();
        addressSF.add('soportesf@nttdata.com');
        email.setToAddresses(addresses.size()>0 ? addresses : addressSF);
        email.setTreatTargetObjectAsRecipient(false);
        email.setSaveAsActivity(true);
        email.setWhatId(recordId);
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    public  class Requests {
      @InvocableVariable(required=true)
      public String recordId;
      @InvocableVariable(required=true)
      public List<String> addresses;
      @InvocableVariable
      public String emailNotification;
    }
    public class Results {
      @InvocableVariable
      public String textValue;
    }
}