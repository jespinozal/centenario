/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-14-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-27-2021   @everis.com   Initial Version
**/
public class CEN_AnulationOperationSafe_cls {
    private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';
   
    public static CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse anulateOperationByOppId(String oppId){
        system.debug('Estoy en el metodo anulateOperationByOppId');
        CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse resp = new CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse();
        try{
            Opportunity opp = [
                Select id,CEN_Motivo_Cierre_Perdida__c, CEN_devolucion_saldo_Afavor__c, CEN_Proyecto__r.CEN_CODIGOSAP__c,
                CEN_Proforma__c, CEN_Proyecto__r.CEN_Sociedad__c,CEN_TipoAnulacionOperacionSegura__c,CEN_LotsRemoved__c,
                Account.CEN_BankClient__c, Account.CEN_LocalAccountNumber__c,Account.CEN_InterbankAccountNumber__c, CEN_Moneda__c 
                from opportunity where ID = :oppId
            ];
            boolean aFavor = opp.CEN_devolucion_saldo_Afavor__c;
            
            CEN_AnulationOperationSafeRequest.ANULAR myReq  = new CEN_AnulationOperationSafeRequest.ANULAR();
            myReq.I_PROCESO = opp.CEN_TipoAnulacionOperacionSegura__c; //ANULA CHAR5
            myReq.I_GUARDAR_MONTO = aFavor? 'X':''; //CEN_devolucion_saldo_Afavor__c CHAR1
            myReq.IS_ANULACION = setAnulacion(opp);
            myReq.IS_REALIZAR_DEVOLUCION = setDevolucion(opp,!aFavor);

            system.debug('Error aqui URN: '+ myReq);
            CEN_AnulationOperationSafeRequest myObjectReq = new CEN_AnulationOperationSafeRequest();
            myObjectReq.ZRFC_OTC_ANULAR_OPS_WS = myReq;
            resp = callAnulationOperationSafeApi(myObjectReq);
        }catch (Exception ex) {
            System.debug('Error aqui: ' + ex.getMessage());
            CEN_AnulationOperationSafeResponse.BAPIRET2_T respError = new CEN_AnulationOperationSafeResponse.BAPIRET2_T();
            List<CEN_AnulationOperationSafeResponse.BAPIRET2> respErrorList = new List<CEN_AnulationOperationSafeResponse.BAPIRET2>();
            CEN_AnulationOperationSafeResponse.BAPIRET2 respErrorDetails = new CEN_AnulationOperationSafeResponse.BAPIRET2();
            respErrorDetails.MESSAGE = ex.getMessage();
            respErrorDetails.TYPE_x ='errorCatch';
            respErrorList.add(respErrorDetails);
            respError.item = respErrorList;
            resp.ET_RETURN = respError;
        }
        return resp;
        
    }
    
    private static CEN_AnulationOperationSafeRequest.ANULACION setAnulacion(Opportunity opp){
      CEN_AnulationOperationSafeRequest.ANULACION anul = new CEN_AnulationOperationSafeRequest.ANULACION();
      anul.CREAR_MOTIVO = '';
      anul.DESCRIPCION = ''; 
      anul.MOTIVO = 'DC'; //opp.CEN_Motivo_Cierre_Perdida__c; 
      anul.PROCESSO = opp.CEN_Proyecto__r.CEN_CODIGOSAP__c; //Codigo de proyecto CEN_CODIGOSAP__c CHAR24
      anul.PROFORMA = opp.CEN_Proforma__c; //proforma NUMC10
      anul.SOCIEDAD = opp.CEN_Proyecto__r.CEN_Sociedad__c; //proyectoSociedad CHAR4
      anul.MONEDA_PROFORMA = opp.CEN_Moneda__c; //moneda de la proforma

    return anul;
  }
    
  private static CEN_AnulationOperationSafeRequest.DEVOLUCION setDevolucion(Opportunity opp, Boolean isDevol){
    CEN_AnulationOperationSafeRequest.DEVOLUCION devol = new CEN_AnulationOperationSafeRequest.DEVOLUCION();
      if(isDevol && (String.isEmpty(opp.Account.CEN_BankClient__c) || String.isEmpty(opp.Account.CEN_LocalAccountNumber__c) || String.isEmpty(opp.Account.CEN_InterbankAccountNumber__c))){
        throw new AnulationOperationSafeException('Debe completar los datos bancarios del cliente para la devolucion');
      }else if(isDevol){
        devol.REALIZAR_DEVOLUCION = 'X';
        devol.BANCO = opp.Account.CEN_BankClient__c;
        devol.CUENTA_BANCARIA = opp.Account.CEN_LocalAccountNumber__c;
        devol.CUENTA_INTERBANCARIA = opp.Account.CEN_InterbankAccountNumber__c;
      }
  return devol;
}
  private static CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse callAnulationOperationSafeApi(CEN_AnulationOperationSafeRequest reqProcess) {
    system.debug('IN callAnulationOperactionSafeApi: ' + reqProcess);
    String customReqBody;
    CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse resp = new CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse();
    XMLSerializer serializerXML = new XMLSerializer();
    customReqBody = serializerXML.serialize(reqProcess);
    customReqBody = customReqBody.replace(
      'ZRFC_OTC_ANULAR_OPS_WS',
      'urn:ZRFC_OTC_ANULAR_OPS_WS'
    );
    system.debug('Error aqui Call: '+ customReqBody);
    try {
      CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Anulacion_Operacion_Segura');
      Dom.Document docReq = new Dom.Document();
      String setReq = customReq.replace('myBody', customReqBody);
      system.debug('callOperactionSafeApi-setReq: ' + setReq);
      docReq.load(setReq);
      callApi.setRequestBody(docReq);
      callApi.setTimeout(60000);
      resp = (CEN_AnulationOperationSafeResponse.ZRFC_OTC_ANULAR_OPS_WSResponse) callApi.makeCallout().getParsedResponse();
      system.debug('callOperactionSafeApi-resp: ' + resp);
    } catch (Exception ex) {
      System.debug('callOperactionSafeApi-Error: ' + ex.getMessage());
      CEN_AnulationOperationSafeResponse.BAPIRET2_T respError = new CEN_AnulationOperationSafeResponse.BAPIRET2_T();
      List<CEN_AnulationOperationSafeResponse.BAPIRET2> respErrorList = new List<CEN_AnulationOperationSafeResponse.BAPIRET2>();
      CEN_AnulationOperationSafeResponse.BAPIRET2 respErrorDetails = new CEN_AnulationOperationSafeResponse.BAPIRET2();
      respErrorDetails.MESSAGE = ex.getMessage();
      respErrorDetails.TYPE_x ='apiErrorCatch';
      respErrorList.add(respErrorDetails);
      respError.item = respErrorList;
      resp.ET_RETURN = respError;
    }
    return resp;
  }

  public class AnulationOperationSafeException extends Exception {}
  
}