/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-05-28 
* @description: Clase de evento call Api SAP - Recaudadora. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-05-28           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_Gatherer_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';
    
    public static CEN_GathererResponse generateGathererByCashId(
        Id cashId
    ) {
        system.debug('***IN CEN_Gatherer_cls.generateGathererByProyectId***');
        system.debug('generateGathererByCashId-cashId: ' + cashId);
        CEN_GathererResponse resp = new CEN_GathererResponse();
        try {
            
            List<CEN_CashRegistred__c> cash = [SELECT Id, OwnerId, CEN_OfficeProyect__c, CEN_ReportedPhysicalMoneySF__c, CEN_PayOrderDate__c,
                                                CEN_ShipmentDocumentNumber__c,
                                                CEN_OfficeProyect__r.CEN_Sociedad__c
                                               FROM CEN_CashRegistred__c 
                                               WHERE Id = :cashId];
            
            List<CEN_CashRegisterAndPayOrder__c> lstCash = [SELECT Id,
                                                            CEN_CashSequence__c,
                                                            CEN_PayOrder__r.CEN_DocumentNumberSAP__c,
                                                            CEN_PayOrder__r.CEN_FiscalYearSAP__c,
                                                            CEN_PayOrder__r.CEN_Opportunity__r.CEN_Proforma__c
                                                            FROM CEN_CashRegisterAndPayOrder__c 
                                                            WHERE CEN_CAshRegistred__c = :cashId];
            
            String strUserNameAD = [SELECT CEN_UserNameAD__c FROM User WHERE Id = :cash[0].OwnerId].CEN_UserNameAD__c;
            
            CEN_GathererRequest req = new CEN_GathererRequest();
            CEN_GathererRequest.ZRFC_OTC_PROCESAR_PAGO_WS_element reqElement = new CEN_GathererRequest.ZRFC_OTC_PROCESAR_PAGO_WS_element();
            reqElement.I_IMPORTE = String.valueOf(cash[0].CEN_ReportedPhysicalMoneySF__c);  
            CEN_GathererRequest.ZATT_PAGO_RECAU lstRecau = new CEN_GathererRequest.ZATT_PAGO_RECAU();
            List<CEN_GathererRequest.ZWS_PAGO_RECAU> lstItem = new List<CEN_GathererRequest.ZWS_PAGO_RECAU>();
            for(CEN_CashRegisterAndPayOrder__c o :lstCash){
                DateTime dT = cash[0].CEN_PayOrderDate__c;
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                CEN_GathererRequest.ZWS_PAGO_RECAU item = new CEN_GathererRequest.ZWS_PAGO_RECAU();
                item.CODIGO = cash[0].CEN_ShipmentDocumentNumber__c;
                item.CORREL = Integer.valueOf(o.CEN_CashSequence__c);
                item.BUKRS = cash[0].CEN_OfficeProyect__r.CEN_Sociedad__c;
                item.BELNR = String.valueOf(o.CEN_PayOrder__r.CEN_DocumentNumberSAP__c);
                item.GJAHR = String.valueOf(dT.year());
                item.PROFORMA = String.valueOf(Integer.valueOf(o.CEN_PayOrder__r.CEN_Opportunity__r.CEN_Proforma__c));
                item.UNAME = strUserNameAD;
                item.SUPERVISOR = strUserNameAD;
                item.FECHA_RECOJO = String.valueOf(myDate);
                item.UNAME_ARQUEO = strUserNameAD;
                item.UNAME_APROBAR = strUserNameAD;
                lstItem.add(item);
            }
            lstRecau.item = lstItem;
            reqElement.IT_IMPORTE = lstRecau;
            req.ZRFC_OTC_PROCESAR_PAGO_WS = reqElement;
            resp = callGathererApi(req);
        } catch (Exception ex) {
            System.debug('generateGathererByCashId-cashId: ' + ex.getMessage());
        }
        return resp;
    }
    
    private static CEN_GathererResponse callGathererApi(
        CEN_GathererRequest reqProcess
    ) {
        system.debug('IN CEN_GathererResponse');
        String customReqBody;
        CEN_GathererResponse resp = new CEN_GathererResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_OTC_PROCESAR_PAGO_WS',
            'urn:ZRFC_OTC_PROCESAR_PAGO_WS'
        );
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Recaudacion');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            System.debug('CEN_Gatherer-setReq: ' + setReq);
            docReq.load(setReq);
            callApi.setRequestBody(docReq);
            resp = (CEN_GathererResponse) callApi.makeCallout().getParsedResponse();
            system.debug('CEN_Gatherer-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_Gatherer-Error: ' + ex.getMessage() + '-' + ex.getLineNumber());
        }
        return resp;
    }
    
}