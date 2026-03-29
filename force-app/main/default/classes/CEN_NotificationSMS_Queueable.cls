/**
 * @description       : Sincronizar notificaciones SMS
 * @author            : Joel Espinoza
 * @group             :
 * @last modified on  : 24-05-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   24-05-2023   @nttdata.com  Initial Version
**/
public without sharing class CEN_NotificationSMS_Queueable implements Queueable,Database.AllowsCallouts {

    //private List<SObject> lst;
    private Set<Id> ids;
    private Map<String,String> mapPhoneNumberById;
    private Map<String,String> mapMessageReplaceById;
    public CEN_NotificationSMS_Queueable(Set<Id> recordsId, Map<String,String> phoneNumberById, Map<String,String> messageReplaceById) {
        Id recordId = (new list<Id>(recordsId)[0]);
        String sObjectApiName = recordId.getSObjectType().getDescribe().getName();
        String whereSOQL = 'Procesando';
        String someSOQL = 'SELECT Id FROM '+sObjectApiName+' WHERE Id IN :recordsId AND CEN_StatusNotificationSMS__c IN (\'' + whereSOQL + '\''+ ')';
        List<SObject> results = Database.query(someSOQL);
        Set<Id> resultIds = (new Map<Id,SObject>(results)).keySet();
        this.ids = resultIds;
        this.mapPhoneNumberById = phoneNumberById;
        this.mapMessageReplaceById = messageReplaceById;
    }

    public void execute(QueueableContext context) {
        if (!TEST.isRunningTest() && ids!=null && ids.size()> 0){
            CEN_WS_NotificationSMS_ctr.notificationSMSAsync(ids, mapPhoneNumberById, mapMessageReplaceById); //CAMBIO
        }
    }

}