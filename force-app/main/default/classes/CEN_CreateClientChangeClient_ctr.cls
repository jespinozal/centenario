/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-08-04 
* @description: Clase de controladora call Api SAP - Crear Cliente desde
*               transferencia de titularidad. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-08-04           Alan Alvarez            Creación 
*  
*********************************************************************/
public with sharing class CEN_CreateClientChangeClient_ctr {
    
    @InvocableMethod(label='processCreateClientChangeClient')
    public static List<String> processCreateClientChangeOwnership(List<FlowParametersCreateClientChangeClient> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].oppId!=null && parameters[0].newClientAccount!=null && parameters[0].society!=null){  
            String respSAp = '';
            Account acc = [Select Id, CEN_N_mero_de_documento__pc, CEN_Numero_de_documento_del__c, CEN_Cod_Interno_SAP__pc, Cod_Interno_SAP_Empresa__c, CEN_SocietySAP__c 
                            From Account 
                            Where Id =: parameters[0].newClientAccount];
            //List<CEN_SocietySAP__mdt> lstSociety = [Select Label From CEN_SocietySAP__mdt];
            //for(CEN_SocietySAP__mdt society_mdt :lstSociety){
                Account accNew = new Account();
                accNew.Id = acc.Id;
                wrapperCreateClient wrapRespSAP = CreateClientChangeClient(parameters[0].oppId, parameters[0].newClientAccount, parameters[0].society);
                if(wrapRespSAP != null && wrapRespSAP.typeResponse == 'error'){
                    respSAp = wrapRespSAP.typeResponse + wrapRespSAP.message;
                }else{
                    if(wrapRespSAP.typeDocumntSAP == 'RUC'){
                        accNew.Cod_Interno_SAP_Empresa__c = wrapRespSAP.numDocumentSAP;
                    }else{
                        accNew.CEN_Cod_Interno_SAP__pc = wrapRespSAP.numDocumentSAP;
                    }
                    if(acc.CEN_SocietySAP__c != null){
                        if(!acc.CEN_SocietySAP__c.contains(parameters[0].society)){
                            accNew.CEN_SocietySAP__c = acc.CEN_SocietySAP__c + ';' + parameters[0].society;
                        }
                    }else{
                        accNew.CEN_SocietySAP__c = parameters[0].society;
                    }
                }
            //}
            update accNew;
            resp.add(respSAp);
        }else{
            resp.add('empty');
        }
        return resp;
    }

    public class FlowParametersCreateClientChangeClient {
        @InvocableVariable(label='oppIdParamt' description='Id Opportunities parameter' required=true)
        public String oppId;
        @InvocableVariable(label='newClientAccountParamt' description='Id New Account parameter' required=true)
        public String newClientAccount;
        @InvocableVariable(label='society' description='Sociedad' required=true)
        public String society;
    }

    public static wrapperCreateClient CreateClientChangeClient(String oppId, String accId, String societyProy) {
        system.debug('***CreateClientChangeClient-callCreateClientApi');
        String titleNotification='Creación de Cliente en SAP';
        String bodyNotification;
        String targetNotification = oppId;
        wrapperCreateClient resp = new wrapperCreateClient();
        Opportunity oppData = [Select Id, OwnerId From Opportunity Where Id = :oppId];
        Account acc = [Select Id, CEN_N_mero_de_documento__pc, CEN_Numero_de_documento_del__c, CEN_Cod_Interno_SAP__pc, Cod_Interno_SAP_Empresa__c, CEN_SocietySAP__c 
                       From Account 
                       Where Id =: accId];
        Set<String> recipientId = new Set<String> {oppData.OwnerId};
        List<CEN_SocietySAP__mdt> lstSocietySap = [Select Label, DeveloperName From CEN_SocietySAP__mdt];
        Map<String, String> mapSocietySap = new Map<String, String>();
        for(CEN_SocietySAP__mdt so : lstSocietySap){
            mapSocietySap.put(so.Label, so.DeveloperName.replace('_',' '));
        }
        //Validar Sociedad
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
            //if((acc.CEN_Cod_Interno_SAP__pc == null && acc.Cod_Interno_SAP_Empresa__c == null) || nullSociety == true){
                respSap = CEN_CreateClientChangeClient_cls.createClientSap(oppData.Id, acc.Id, societyProy);
                if(respSap.ET_RETURN.item[0].TYPE_x == 'S'){
                    resp.numDocumentSAP = respSap.ET_CLIENTE.item[0].KUNNR;
                    resp.typeDocumntSAP = respSap.ET_CLIENTE.item[0].TIPO_DOC;
                    bodyNotification = 'Se registró al cliente '+ respSap.ET_CLIENTE.item[0].NAME +' con número de documento '+respSap.ET_CLIENTE.item[0].STCD1+' en SAP para la sociedad ' + mapSocietySap.get(societyProy);
                    resp.typeResponse = 'success';
                    resp.message = 'Se creó cuenta en SAP';
                    myNotification (titleNotification, bodyNotification, acc.Id, recipientId);    
                }else{
                    String errorSap = respSap.ET_RETURN.item[0].MESSAGE;
                    if(respSap.ET_CLIENTE.item[0].KUNNR != NULL){
                        resp.numDocumentSAP = respSap.ET_CLIENTE.item[0].KUNNR;
                        resp.typeDocumntSAP = respSap.ET_CLIENTE.item[0].TIPO_DOC;
                        resp.typeResponse = 'success';
                        resp.message = 'El cliente ya existe en SAP';
                    }else{
                        titleNotification = 'Error técnico en la creación de cliente en SAP';
                        bodyNotification = 'Error: '+errorSap;
                        resp.typeResponse = 'error';
                        resp.message = 'Error al crear cliente en SAP: '+ errorSap; 
                        myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
                    }                    
                }
            // }else{
            //     resp.typeResponse = 'success';
            //     resp.message = 'El cliente ya existe en SAP';
            // }
        }catch(Exception ex){
            resp.typeResponse = 'error';
            resp.message = 'Error al crear cliente en SAP: '+ ex.getMessage();
        }
        system.debug('***callCreateClient-callCreateClientApi-resp: ' + resp);
        return resp;
    }

    public class wrapperCreateClient{
        String typeResponse;
        String message;
        String typeDocumntSAP;
        String numDocumentSAP;
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