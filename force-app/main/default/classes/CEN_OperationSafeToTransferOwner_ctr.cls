/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-14-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-16-2021   @everis.com   Initial Version
**/
public without sharing class CEN_OperationSafeToTransferOwner_ctr {

    public static Map<String,String> changeOwnerFromOperationSafe(String oppId) {
        Map<String,String>  mapResp = new Map<String,String> ();
        Opportunity oppAux = [SELECT Account.IsPersonAccount, OwnerId FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
        Set<String> recipientId = new Set<String> {oppAux.OwnerId};
        Opportunity opp = new Opportunity();
        String myClient;
        if(oppAux.Account.IsPersonAccount){
            opp = [SELECT CEN_Proyecto__r.CEN_Sociedad__c, CEN_Proyecto__r.CEN_CODIGOSAP__c,
            Account.CEN_N_mero_de_documento__pc,  CEN_Proforma__c,CEN_ProformaVersion__c, OwnerId, CEN_Moneda__c
            FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
            myClient = opp.Account.CEN_N_mero_de_documento__pc;
        }else{
            opp = [SELECT CEN_Proyecto__r.CEN_Sociedad__c, CEN_Proyecto__r.CEN_CODIGOSAP__c,
            Account.CEN_Numero_de_documento_del__c,  CEN_Proforma__c,CEN_ProformaVersion__c, OwnerId, CEN_Moneda__c
            FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED];
            myClient = opp.Account.CEN_Numero_de_documento_del__c;
        }
        CEN_TransferOwnerObjectResponse resp = CEN_OperationSafeToTransferOwner_cls.executeTransferOwner(opp, myClient);
        mapResp = clonePayment(resp, opp);

        CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = 'Notificacin_de_la_organizacin' WITH SECURITY_ENFORCED
        ];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        String msg = String.isEmpty(mapResp.get('sucess')) ? mapResp.get('error') : mapResp.get('sucess');
        notification.setTitle('Cambio de titular');
        notification.setBody(msg);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(oppId);
        notification.send(recipientId);

        return mapResp;
    }

    public static Map<String,String> clonePayment(CEN_TransferOwnerObjectResponse resp, Opportunity opp){
        Map<String,String>  mapResp = new Map<String,String> ();
        String msg;
        if(resp.E_OK !=null && resp.E_OK=='X'){
            msg = 'Cambio de titularidad realizado con Exito';
            mapResp.put('sucess', msg);
            Map <String,String> mapPayments = new Map <String,String>();
            Set<String>listPaymentsIds = new Set<String>();
            List<CEN_PaymentOrder__c> myNewsPayments = new List<CEN_PaymentOrder__c>();
            if(resp.ET_PAGOS_CLIENTE!=null && resp.ET_PAGOS_CLIENTE.item != null ){
                for(CEN_TransferOwnerObjectResponse.PAGO myPayment: resp.ET_PAGOS_CLIENTE.item ){
                    mapPayments.put(myPayment.BELNR_ANTERIOR + myPayment.GJAHR, myPayment.BELNR);
                    listPaymentsIds.add(myPayment.BELNR_ANTERIOR);
                }
                if(listPaymentsIds.size()>0){
                    List<CEN_PaymentOrder__c> myPayments = [SELECT  Id, OwnerId, RecordTypeId, CEN_AddressCity__c, CEN_Address__c, CEN_Amount__c,
                                                                CEN_Bin__c, CEN_CardBrand__c, CEN_CardType__c, CEN_CountryCode__c, CEN_CreationDateFrom__c,
                                                                CEN_CreationDateTo__c, CEN_CurrencyCode__c, CEN_DeviceType__c, CEN_DocumentNumber__c, CEN_DueDate__c,
                                                                CEN_Email__c, CEN_Fee__c, CEN_FirstName__c, CEN_ID_Culqi__c, CEN_Installments__c, CEN_LastName__c,
                                                                CEN_Opportunity__c, CEN_OriginPayment__c, CEN_Paid__c, CEN_PaymentCode__c, CEN_PaymentDescription__c,
                                                                CEN_PaymentStatus__c, CEN_PhoneNumber__c, CEN_Reference__c, CEN_TypeDocument__c, CEN_MessageError__c,
                                                                CEN_DocumentNumberSAP__c, CEN_AccountNumberBank__c, CEN_AccountNumberByBank__c, CEN_AmountLocalCurrencySAP__c,
                                                                CEN_Banks__c, CEN_CashRetired__c, CEN_CodePaymentLink__c, CEN_DocumentClassSAP__c, CEN_DocumentDateSAP__c,
                                                                CEN_FiscalYearSAP__c, CEN_OldSecureOperationSAP__c, CEN_OriginData__c, CEN_ReservationSap__c, CEN_SocietySAP__c,
                                                                CEN_According__c, CEN_CashAmount__c, CEN_LastFour__c, CEN_Observations__c, CEN_OppProyect__c, CEN_PaymentType__c,
                                                                CEN_PhysicalMoneyWithdrawn__c, CEN_AdvanceNumber__c, CEN_PaymentDateAux__c, CEN_PaymentDate__c, CEN_CulqiExpress__c,
                                                                CEN_OrderExpirationDate__c, CEN_DocumentYearSAP__c
                                                                FROM CEN_PaymentOrder__c
                                                                WHERE (CEN_DocumentNumberSAP__c IN :listPaymentsIds
                                                                OR CEN_AdvanceNumber__c IN :listPaymentsIds)
                                                                AND CEN_Opportunity__r.CEN_Proforma__c =: opp.CEN_Proforma__c WITH SECURITY_ENFORCED];
                    List<CEN_PaymentOrder__c> auxPayList = new List<CEN_PaymentOrder__c>();

                    if(myPayments.size()>0){
                        try {
                            Set<Id> idSet = new Set<Id>();
                            for(CEN_PaymentOrder__c getPay: myPayments){
                                CEN_PaymentOrder__c auxPay = new CEN_PaymentOrder__c();
                                String currentId = getPay.Id;
                                idSet.add(getPay.Id);
                                auxPay = getPay;
                                auxPay.Id = null;
                                String anio = String.valueOf(getPay.CEN_PaymentDate__c.Year());

                                if(getPay.CEN_OriginPayment__c == 'Anticipos Sueltos' && mapPayments.get(getPay.CEN_AdvanceNumber__c + anio) != null){
                                    auxPay.CEN_DocumentNumberSAP__c = mapPayments.get(getPay.CEN_AdvanceNumber__c + anio);
                                }else{
                                    auxPay.CEN_DocumentNumberSAP__c = mapPayments.get(getPay.CEN_DocumentNumberSAP__c + anio);
                                }
                                auxPay.CEN_PaymentStatus__c = 'Pagado';
                                auxPay.CEN_PaymentDateSAP__c = DateTime.Now();
                                auxPay.CEN_Opportunity__c = opp.Id;
                                if(auxPay.CEN_DocumentNumberSAP__c!=null){myNewsPayments.add(auxPay);}
                                if(getPay.CEN_ID_Culqi__c != null && auxPay.CEN_DocumentNumberSAP__c!=null){
                                    CEN_PaymentOrder__c payUpdateByDuplicate = new CEN_PaymentOrder__c();
                                    payUpdateByDuplicate.Id = currentId;
                                    payUpdateByDuplicate.CEN_ID_Culqi__c = 'SAP_'+auxPay.CEN_DocumentNumberSAP__c+anio;
                                    auxPayList.add(payUpdateByDuplicate);
                                }
                            }

                            if(auxPayList.size()>0){update auxPayList;}
                            insert myNewsPayments;

                            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:idSet WITH SECURITY_ENFORCED];
                            if(cdlList.size()>0){
                                List<ContentDocumentLink> cdlCloneList = new List<ContentDocumentLink>();
                                for(ContentDocumentLink cdl : cdlList){
                                    ContentDocumentLink cdlClone = new ContentDocumentLink();
                                    cdlClone.ContentDocumentId = cdl.ContentDocumentId;
                                    cdlClone.LinkedEntityId = getNewIdPayment(myNewsPayments, cdl.LinkedEntityId);
                                    cdlCloneList.add(cdlClone);
                                }
                                insert cdlCloneList;
                            }

                        } catch (Exception ex) {
                            List<String> addresses = new List<String>();                        addresses.add('soportesf@nttdata.com');                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                                    email.setSubject('Notificación de Error Cambio de Titularidad');                        String msgEmail = 'Estimado Administrador, <br/><br/>';                        msgEmail += 'Los pagos no fueron enviados a la nueva oportunidad. <br/><br/>';                        msgEmail += 'Lista de actualizacion de pagos en la oportunidad perdida: ' + auxPayList +'. <br/><br/>';                        msgEmail += 'Lista de nuevos pagos de la nueva oportunidad: ' + myNewsPayments +'. <br/><br/>';                        msgEmail += 'Detalle del error: ' + ex.getMessage();                        email.setHTMLBody(msgEmail);                        email.setToAddresses(addresses);                        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                        }
                    }
                }
            }
        }else{
            msg = resp.ET_RETURN.item[0].MESSAGE!=null?resp.ET_RETURN.item[0].MESSAGE:'Error en SAP. Verificar si el cliente existe en SAP';
            mapResp.put('error', msg);
        }

        return mapResp;
    }

    public static Id getNewIdPayment(List<CEN_PaymentOrder__c> listPayment, Id linkId){
        Id id;
        String code = [SELECT CEN_PaymentCode__c FROM CEN_PaymentOrder__c WHERE Id=:linkId]?.CEN_PaymentCode__c;
        String pCode = '';
        Integer i = 0;
        while (code != pCode) {
            pCode = listPayment[i].CEN_PaymentCode__c;
            id = listPayment[i].Id;
            i++;
        }
        return id;
    }

    @Future(callout=true)
    public static void changeOwnerFromOperationSafeAsin(String oppId) {
        Map<String,String> resp= changeOwnerFromOperationSafe(oppId);
     }

    @InvocableMethod(label='changeOwnerFromOperationSafSAP')
    public static List<String> changeOwnerFromOperationSafSAP(List<FlowParameters> parameters){
        List<String> resp = new List<String> ();

        if(parameters!=null && parameters.size()>0 && parameters[0].opIds!=null && parameters[0].opIds.size()>0 ){
            for(String strOPId : parameters[0].opIds){
                changeOwnerFromOperationSafeAsin(strOPId);
            }
            resp.add('ok');
        }else{
            resp.add('empty');
        }

        return resp;
    }

    public class FlowParameters {
    @InvocableVariable(label='OPIdsParamts' description='Ids Payments Order parameter' required=true)
    public List<String> opIds;
    }
}