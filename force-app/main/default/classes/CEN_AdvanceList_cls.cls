/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-05-09 
* @description: Clase de evento call Api SAP - Listado de Anticipos. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-05-09           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_AdvanceList_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';
    
    public static CEN_AdvanceListObjectResponse getAdvanceListbyClient(Id oppId) {
        CEN_AdvanceListObjectResponse resp = new CEN_AdvanceListObjectResponse();
        try {
            CEN_AdvanceListObjectRequest myObjectReq = new CEN_AdvanceListObjectRequest();
            CEN_AdvanceListObjectRequest.ZRFC_OTC_LISTA_ANTICIPOS_WS_element myObjectElement = new CEN_AdvanceListObjectRequest.ZRFC_OTC_LISTA_ANTICIPOS_WS_element();
            list<Opportunity> lstOpp = [
                SELECT Account.CEN_N_mero_de_documento__pc, CEN_Proyecto__r.CEN_Sociedad__c, Account.CEN_Numero_de_documento_del__c, CEN_Moneda__c
                FROM Opportunity
                WHERE Id = :oppId
            ];
            for (Opportunity opp : lstOpp) {
                //myObjectElement.I_BUKRS = opp.CEN_Proyecto__r.CEN_Sociedad__c; //COMENTAR TRASLADO DE ABONOS
                myObjectElement.I_BUKRS = ''; //DESCOMENTAR TRASLADO DE ABONOS
                String docClient = opp.Account.CEN_N_mero_de_documento__pc!=null?opp.Account.CEN_N_mero_de_documento__pc:opp.Account.CEN_Numero_de_documento_del__c;
                //String strComplete = '0000000000';
                myObjectElement.I_STCD1 = docClient; //docClient.length()<10?docClient.substring(0, 10 - docClient.length())+docClient:docClient;
            }
            myObjectReq.ZRFC_OTC_LISTA_ANTICIPOS_WS = myObjectElement;
            system.debug('getAdvanceListbyClient:' + myObjectReq);
            resp = callAdvanceListApi(myObjectReq);
        } catch (Exception ex) {
            System.debug('CEN_ListaAnticipos-Error: ' + ex.getMessage());
        }
        return resp;
    }
    
    private static CEN_AdvanceListObjectResponse callAdvanceListApi(
        CEN_AdvanceListObjectRequest reqProcess
    ) {
        system.debug('IN callAdvanceListApi');
        String customReqBody;
        CEN_AdvanceListObjectResponse resp = new CEN_AdvanceListObjectResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_OTC_LISTA_ANTICIPOS_WS',
            'urn:ZRFC_OTC_LISTA_ANTICIPOS_WS'
        );
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_ListaAnticipos');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            system.debug('CEN_ListaAnticipos-setReq: ' + setReq);
            docReq.load(setReq);
            callApi.setRequestBody(docReq);
            if(!Test.isRunningTest()){
                callApi.setTimeout(50000);
            }
            resp = (CEN_AdvanceListObjectResponse) callApi.makeCallout().getParsedResponse();
            system.debug('CEN_ListaAnticipos-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_ListaAnticipos-Error: ' + ex.getMessage());
        }
        return resp;
    }
    
}