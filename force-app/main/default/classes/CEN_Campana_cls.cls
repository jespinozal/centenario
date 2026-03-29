/********************************************************************* 
* @author: Jose Hernandez (jherncal@emeal.nttdata.com) 
* @date: 2022-10-27 
* @description: Clase Parse de evento call Api SAP - Campañas disponibles. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2022-10-27           Jose Hernandez          Creación 
*  
*********************************************************************/
public with sharing class CEN_Campana_cls {
    private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';

    public static CEN_CampanaObjectResponse getCampanabyProject(String idProyecto) {
        CEN_CampanaObjectResponse resp = new CEN_CampanaObjectResponse();
        try {
            CEN_CampanaObjectRequest myObjectReq = new CEN_CampanaObjectRequest();
            CEN_CampanaObjectRequest.ZRFC_OTC_CAMPANA_SF_WS_element myObjectElement = new CEN_CampanaObjectRequest.ZRFC_OTC_CAMPANA_SF_WS_element();
            List<Proyecto__c> lstProy= new List<Proyecto__c>();
            lstProy = [
                SELECT CEN_CODIGOSAP__c,CEN_Sociedad__c
                FROM Proyecto__c
                WHERE Id = :idProyecto WITH SECURITY_ENFORCED
            ];        
			system.debug('lstProy: ' + lstProy);
            system.debug('lstProy[0].CEN_CODIGOSAP__c: ' + lstProy[0].CEN_CODIGOSAP__c);
            system.debug('lstProy[0].CEN_Sociedad__c: ' + lstProy[0].CEN_Sociedad__c);
            system.debug('myObjectElement1:' + myObjectElement);
            //preguntar a joel

            CEN_CampanaObjectRequest.ZTT_LOTE_DESCT filasItems = new CEN_CampanaObjectRequest.ZTT_LOTE_DESCT();
            List<CEN_CampanaObjectRequest.ZACCO_LOTE_DESCT> operItems = new List<CEN_CampanaObjectRequest.ZACCO_LOTE_DESCT>();
            CEN_CampanaObjectRequest.ZACCO_LOTE_DESCT operItem = new CEN_CampanaObjectRequest.ZACCO_LOTE_DESCT();
            operItem.PROYECTO = lstProy[0].CEN_CODIGOSAP__c;
            operItems.add(operItem);
            filasItems.item = operItems;
            myObjectElement.IT_LOTE_DESCT = filasItems;
            myObjectElement.SOCIEDAD = lstProy[0].CEN_Sociedad__c;
            system.debug('myObjectElement2:' + myObjectElement);
            
            myObjectReq.ZRFC_OTC_CAMPANA_SF_WS = myObjectElement;
            system.debug('myObjectReq:' + myObjectReq);
            resp = callCampanaListApi(myObjectReq);
        } catch (Exception ex) {
            System.debug('CEN_Campana-Error: ' + ex.getMessage());
        }
        return resp;
    }
    
    private static CEN_CampanaObjectResponse callCampanaListApi(
        CEN_CampanaObjectRequest reqProcess
    ) {
        system.debug('IN callCampanaApi');
        String customReqBody;
        CEN_CampanaObjectResponse resp = new CEN_CampanaObjectResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_OTC_CAMPANA_SF_WS',
            'urn:ZRFC_OTC_CAMPANA_SF_WS'
        );
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Campana');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            system.debug('CEN_Campana-setReq: ' + setReq);
            docReq.load(setReq);
            callApi.setRequestBody(docReq);
            resp = (CEN_CampanaObjectResponse) callApi.makeCallout().getParsedResponse();
            system.debug('CEN_Campana-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_Campana-Error: ' + ex.getMessage());
        }
        return resp;
    }

}