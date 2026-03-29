/**
 * @description       : Servicio de notification SMS - Tannua
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 22-05-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   22-05-2023   @nttdata.com  Initial Version
 **/
public without sharing class CEN_WS_NotificationSMS_ctr {

    //CAMBIO - INICIO
    public static String notificationSMS(Set<Id> recordsId, Map<String,String> phoneNumberById, Map<String,String> messageReplaceById) {
        String respuesta;
        try {
            Map<String, Object> mapResp = new Map<String, Object>();
            Map<String,String> mapObj = new Map<String, String>();
            Id recordId = (new list<Id>(recordsId)[0]);
            String sObjectApiName = recordId.getSObjectType().getDescribe().getName();
            CEN_NotificationSMS__mdt mdtSMS = [SELECT Id,
                                                      MasterLabel,
                                                      DeveloperName,
                                                      business__c,
                                                      message__c,
                                                      taskId__c
                                               FROM CEN_NotificationSMS__mdt
                                               WHERE DeveloperName =: sObjectApiName
                                               //WITH SECURITY_ENFORCED
                                               LIMIT 1];
            mapObj.put('business', mdtSMS.business__c);
            mapObj.put('phoneNumber', phoneNumberById.get(recordId));
            mapObj.put('message', messageReplaceById.get(recordId));
            mapObj.put('taskId', mdtSMS.taskId__c);
            mapResp = CEN_WS_NotificationSMS_cls.sendNotificationSMS(mapObj);
            System.debug(mapResp.size());
            System.debug(mapResp.get('success'));

            List<SObject> sObjectsToUpdate = new List<SObject>();
            SObject o1 = recordId.getSObjectType().newSObject(recordId);
            o1.put('CEN_StatusNotificationSMS__c', mapResp.get('success') != null ? 'Enviado' : 'Error');

            updateCustomObject(sObjectApiName, o1);
            //update o1;

            phoneNumberById.remove(recordId);
            messageReplaceById.remove(recordId);
            recordsId.remove(recordId);
            respuesta = 'ok';
            //ID jobID = System.enqueueJob(new CEN_NotificationSMS_Queueable(recordsId, phoneNumberById, messageReplaceById),1);
            ID jobID = System.enqueueJob(new CEN_NotificationSMS_Queueable(recordsId, phoneNumberById, messageReplaceById));
        } catch (Exception ex) {respuesta = 'error: ' + ex.getMessage();}
        return respuesta;
    }

    @future (callout=true)
    public static void notificationSMSAsync(Set<Id> recordsId, Map<String,String> phoneNumberById, Map<String,String> messageReplaceById) {
        try {
            String resp = notificationSMS(recordsId, phoneNumberById, messageReplaceById);
        } catch (Exception ex) {System.debug('error: ' + ex.getMessage());}
    }

    // @future (callout=true)
    // public static void notificationSMSAsync(Map<String,String> mapRequest) {
    //     try {
    //         for(String recordId : mapRequest.keyset()){
    //             Map<String,String> mapObj = new Map<String,String>();
    //             //String sObjectApiName = recordId.getSObjectType().getDescribe().getName();
    //             mapObj.put('business','Test');
    //             mapObj.put('phoneNumber','948160461');
    //             mapObj.put('message',mapRequest.get(recordId));
    //             mapObj.put('taskId','Test');
    //             CEN_WS_NotificationSMS_cls.sendNotificationSMS(mapObj);
    //         }
    //     } catch (Exception ex) {System.debug('error: ' + ex.getMessage());}
    // }
    //CAMBIO - FIN

    @InvocableMethod(label='executeNotificationSMS' category='Collections')
    public static List<Results> executeNotificationSMS (List<Requests> requestList) {
        List<Results> responseWrapper= new List<Results>();
        Map<String,String> phoneNumberById= new Map<String,String>();
        Map<String,String> messageReplaceById= new Map<String,String>();
        Set<Id> recordsId = new Set<Id>();
        Map<String,String> mapRequest = new Map<String,String>(); //CAMBIO
        for(Requests r: requestList){
            recordsId.add(r.recordId); //CAMBIO
            phoneNumberById.put(r.recordId,r.phoneNumber); //CAMBIO
            messageReplaceById.put(r.recordId,r.messageReplace); //CAMBIO
            //mapRequest.put(r.recordId, r.messageReplace); //CAMBIO
            Results response = new Results();
            response.status = 'success';
            responseWrapper.add(response);
        }

        CEN_WS_NotificationSMS_ctr.notificationSMSAsync(recordsId, phoneNumberById, messageReplaceById); //CAMBIO
        //CEN_WS_NotificationSMS_ctr.notificationSMSAsync(mapRequest); //CAMBIO

        return responseWrapper;

    }

    public static void updateCustomObject(String sObjectApiName, SObject obj) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();

        if(!fieldMap.get('CEN_StatusNotificationSMS__c').getDescribe().isUpdateable()) {
            throw new DmlException('No permissions to update.');
         } else {
            update obj;
         }
    }

    public class Requests {
        @InvocableVariable(required=true)
        public String recordId;
        @InvocableVariable(required=true)
        public String phoneNumber;
        @InvocableVariable(required=true)
        public String messageReplace;
    }

    public class Results {
        @InvocableVariable
        public String status;
    }
}