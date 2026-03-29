/*********************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-06-22
* @description: Clase de controladora call Api SAP - Crear Cliente.
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2021-06-22           Alan Alvarez            Creación
*
*********************************************************************/
public with sharing class CEN_CreateClient_ctr {

    public static Map<String, String> callCreateClient(String oppId) {
        system.debug('***CEN_CreateClient_ctr-callCreateClientApi');
        String titleNotification='Creación de Cliente en SAP';
        String bodyNotification;
        String targetNotification = oppId;
        Map<String, String> resp = new Map<String, String>();
        Opportunity oppData = [Select Id, OwnerId, AccountId, CEN_MessageError__c, Account.Name, CEN_Proyecto__r.CEN_Sociedad__c From Opportunity Where Id = :oppId];
        Account acc = [Select Id, CEN_N_mero_de_documento__pc, CEN_Numero_de_documento_del__c, CEN_Cod_Interno_SAP__pc, Cod_Interno_SAP_Empresa__c, CEN_SocietySAP__c 
                       From Account Where Id = :oppData.AccountId];
        Set<String> recipientId = new Set<String> {oppData.OwnerId};

        String societyProy = oppData.CEN_Proyecto__r.CEN_Sociedad__c;
        Boolean nullSociety = false;
        if(acc.CEN_SocietySAP__c != null){
            if(!acc.CEN_SocietySAP__c.contains(societyProy)){
                nullSociety = true;
            }
        }else{
            nullSociety = true;
        }

        CEN_CreateClientResponse respSap = new CEN_CreateClientResponse();
        try{
            if((acc.CEN_Cod_Interno_SAP__pc == null && acc.Cod_Interno_SAP_Empresa__c == null) || nullSociety == true){
                respSap = CEN_CreateClient_cls.createClientByOppId(oppData.Id);
                if(respSap.ET_RETURN.item[0].TYPE_x == 'S'){
                    if(respSap.ET_CLIENTE.item[0].TIPO_DOC == 'RUC'){acc.Cod_Interno_SAP_Empresa__c = respSap.ET_CLIENTE.item[0].KUNNR;}else{acc.CEN_Cod_Interno_SAP__pc = respSap.ET_CLIENTE.item[0].KUNNR;}
                    if(acc.CEN_SocietySAP__c != null){
                        if(!acc.CEN_SocietySAP__c.contains(societyProy)){
                            acc.CEN_SocietySAP__c = acc.CEN_SocietySAP__c + ';' + societyProy;
                        }
                    }else{
                        acc.CEN_SocietySAP__c = societyProy;
                    }
                    update acc;
                    bodyNotification = 'Se creó el cliente '+oppData.Account.Name+' con número de documento '+respSap.ET_CLIENTE.item[0].STCD1+' en SAP';
                    resp.put('success','Se creó cuenta en SAP: ' + oppData.Account.Name);
                    myNotification (titleNotification, bodyNotification, acc.Id, recipientId);
                }else{
                    String errorSap = respSap.ET_RETURN.item[0].MESSAGE;
                    if(respSap.ET_CLIENTE.item[0].KUNNR != NULL){
                        if(respSap.ET_CLIENTE.item[0].TIPO_DOC == 'RUC'){acc.Cod_Interno_SAP_Empresa__c = respSap.ET_CLIENTE.item[0].KUNNR;}else{acc.CEN_Cod_Interno_SAP__pc = respSap.ET_CLIENTE.item[0].KUNNR;}
                        if(acc.CEN_SocietySAP__c != null){
                            if(!acc.CEN_SocietySAP__c.contains(societyProy)){
                                acc.CEN_SocietySAP__c = acc.CEN_SocietySAP__c + ';' + societyProy;
                            }
                        }else{
                            acc.CEN_SocietySAP__c = societyProy;
                        }
                        update acc;
                        resp.put('success','Se creó cuenta en SAP: ' + oppData.Account.Name);
                    }else{
                        oppData.CEN_MessageError__c = errorSap;
                        update oppData;
                        titleNotification = 'Error técnico en la creación de cliente en SAP';
                        bodyNotification = 'Error: '+errorSap;
                        resp.put('error','Error al crear cliente en SAP1: '+ errorSap);
                        myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
                    }
                }
            }else{
                resp.put('success','El cliente ya existe en SAP');
            }
        }catch(Exception ex){
            resp.put('error','Error al crear cliente en SAP: '+ ex.getMessage());
        }
        system.debug('***callCreateClient-callCreateClientApi-resp: ' + resp);
        return resp;
    }

    @future(callout=true)
    public static void callCreateClientAsinc(String oppIds) {
        System.Debug('***IN CEN_CreateClient_ctr.callCreateClientAsinc***');
        try {
            Map<String, String> mapResp = callCreateClient(oppIds);
            if(mapResp.get('success') != null){
                ID jobID = System.enqueueJob(new CEN_OperationSafeQueueable_ctr(oppIds));
                system.debug('CEN_OperactionSafe_ctr-CEN_PaymentOrderProcess_ctr-jobID: '+jobID);
            }
        } catch (Exception ex) {
            Set<String> recipientId = new Set<String> {System.UserInfo.getUserId()};
                myNotification ('Error Tecnico', 'Error: '+ex.getMessage()+'. Linea: '+ex.getLineNumber(), oppIds, recipientId );
        }
    }

    @InvocableMethod(label='processCreateClient')
    public static List<String> processCreateClient(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].oppIds!=null && parameters[0].oppIds.size()>0 ){
            for(Integer i=0; i < parameters.size(); i++){
                if(i==0){
                    callCreateClientAsinc(parameters[0].oppIds[0]);
                    resp.add(parameters[0].oppIds[0]+'inProccess');
                }else{
                    resp.add(parameters[0].oppIds[0]+'inProccess2');
                }
            }
        }else{
            resp.add('empty');
        }
        return resp;
    }

    public class FlowParameters {
        @InvocableVariable(label='oppIdsParamt' description='Ids Opportunities parameter' required=true)
        public List<String> oppIds;
    }

    private static void myNotification (String notiTitle, String notiBody, String notiTarget, Set<String> notiRecipients ){
        String notiId = [SELECT Id, DeveloperName
                         FROM CustomNotificationType
                         WHERE DeveloperName = 'Notificacin_de_la_organizacin' ].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notiTitle);
        notification.setBody(notiBody);
        notification.setNotificationTypeId(notiId);
        notification.setTargetId(notiTarget);
        notification.send(notiRecipients);
    }

}