/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 07-09-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
public with sharing class CEN_AccountStatementFinancing_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';


    public static CEN_AccountStatementFinancingResponse getAccountStatementFinancing(CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element myObjectElement){

        CEN_AccountStatementFinancingResponse myObjectRes = new CEN_AccountStatementFinancingResponse();
        try {
            CEN_AccountStatementFinancingRequest myObjectReq = new CEN_AccountStatementFinancingRequest();
            
            //CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element myObjectElement = new CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element();
            // myObjectElement.I_FECHA_INI = '';
            // myObjectElement.I_FECHA_FIN = '';
            // myObjectElement.I_HORA_INI = '';
            // myObjectElement.I_HORA_FIN = '';
            myObjectReq.ZWS_CONSULTA_ENVIO_EC = myObjectElement;
            myObjectRes = callAccountStatementFinancingApi(myObjectReq);
        } catch (Exception ex) {
            System.debug('CEN_AccountStatementFinancing_cls-Error: ' + ex.getMessage());
            throw new AccountStatementFinancingException(ex.getMessage());
        }

        return myObjectRes;
    }   
    
    public static CEN_AccountStatementFinancingResponse callAccountStatementFinancingApi(CEN_AccountStatementFinancingRequest reqProcess) {
        system.debug('IN callAccountStatementFinancingApi');
        String customReqBody;
        CEN_AccountStatementFinancingResponse resp = new CEN_AccountStatementFinancingResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZWS_CONSULTA_ENVIO_EC',
            'urn:ZWS_CONSULTA_ENVIO_EC'
        );
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_ListaEstadoCuenta');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            system.debug('CEN_AccountStatementFinancing_cls-setReq: ' + setReq);
            docReq.load(setReq);
            callApi.setRequestBody(docReq);
            resp = (CEN_AccountStatementFinancingResponse) callApi.makeCallout().getParsedResponse();
            system.debug('CEN_AccountStatementFinancing_cls-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_AccountStatementFinancing_cls-Error: ' + ex.getMessage());
        }
        return resp;
    }
    
    public class AccountStatementFinancingException extends Exception {
    }

}