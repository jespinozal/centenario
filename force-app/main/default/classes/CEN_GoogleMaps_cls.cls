/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 05-09-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_GoogleMaps_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    public static CEN_GoogleMapsResponse updateAccountAddressById(
        Id accId
    ) {
        CEN_GoogleMapsResponse resp;
        try {
            List<Account> lstAccount = [SELECT Id, CEN_N_mero_de_documento__pc, CEN_Direccion__pc, CEN_URL_map__c
                                        FROM Account
                                        WHERE Id = :accId];

            if(lstAccount[0].CEN_Direccion__pc == null){throw new updateAccoundAddressException('Ingresar dirección domiciliaria');}
            if(lstAccount[0].CEN_URL_map__c == null){throw new updateAccoundAddressException('URL no existe, favor de comunicarse con el administrador');}
            CEN_GoogleMapsRequest req = new CEN_GoogleMapsRequest();
            CEN_GoogleMapsRequest.ZWS_REGISTRA_URL_MAPS_element reqUrlMap = new CEN_GoogleMapsRequest.ZWS_REGISTRA_URL_MAPS_element();
            reqUrlMap.I_KUNNR = lstAccount[0].CEN_N_mero_de_documento__pc;
            reqUrlMap.I_URL = lstAccount[0].CEN_URL_map__c;
            req.ZWS_REGISTRA_URL_MAPS = reqUrlMap;
            resp = callUpdateUrlMapApi(req);
        } catch (Exception ex) {
            resp = new CEN_GoogleMapsResponse();
            CEN_GoogleMapsResponse.ZWS_REGISTRA_URL_MAPSResponse_element respError = new CEN_GoogleMapsResponse.ZWS_REGISTRA_URL_MAPSResponse_element();
            respError.E_MESSAGE = ex.getMessage();
            resp.ZWS_REGISTRA_URL_MAPSResponse = respError;
        }
        return resp;
    }

    private static CEN_GoogleMapsResponse callUpdateUrlMapApi(
        CEN_GoogleMapsRequest reqProcess
    ) {
        String customReqBody;
        CEN_GoogleMapsResponse resp = new CEN_GoogleMapsResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZWS_REGISTRA_URL_MAPS',
            'urn:ZWS_REGISTRA_URL_MAPS'
        );
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Google_Maps');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            setReq = setReq.replace('&', '&amp;');
            docReq.load(setReq);

            callApi.setRequestBody(docReq);
            if(!Test.isRunningTest()){
                callApi.setTimeout(50000);
            }
            resp = (CEN_GoogleMapsResponse) callApi.makeCallout().getParsedResponse();
        } catch (Exception ex) {
            System.debug('CEN_GoogleMaps-Error: ' + ex.getMessage() + '-' + ex.getLineNumber());
        }
        return resp;
    }

    public class updateAccoundAddressException extends Exception {
    }

}