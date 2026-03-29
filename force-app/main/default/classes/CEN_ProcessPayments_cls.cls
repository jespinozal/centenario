/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-19-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
 **/
public class CEN_ProcessPayments_cls {
   
    private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">'  + 
    '<soapenv:Header/>'  + 
    '<soapenv:Body>myBody' +
    '</soapenv:Body>'  + 
    '</soapenv:Envelope>';

    private static CEN_ProcessPaymentsObjectRequest.EFECTIVO setEfectivo(CEN_PaymentOrder__c opData, Boolean isEfect) {
      CEN_ProcessPaymentsObjectRequest.EFECTIVO efectivo = new CEN_ProcessPaymentsObjectRequest.EFECTIVO();
      
        List<CEN_ProcessPaymentsObjectRequest.EFECTIVO_ITEM> efectivoItemList = new List<CEN_ProcessPaymentsObjectRequest.EFECTIVO_ITEM>();
        CEN_ProcessPaymentsObjectRequest.EFECTIVO_ITEM efectivoItem = new CEN_ProcessPaymentsObjectRequest.EFECTIVO_ITEM();
        if(isEfect){
          efectivoItem.IMPORTE = String.valueOf(opData.CEN_Amount__c); //'400'; 
          efectivoItem.MONEDA_PAGO = opData.CEN_CurrencyCode__c;
        }
        efectivoItemList.add(efectivoItem);
        efectivo.item = efectivoItemList;

      return efectivo;
    }

    private static CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO setPagosElectronicos(CEN_PaymentOrder__c oppData, Boolean isExec) {
      CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO pagosElectronicos = new CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO();
      List<CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO_ITEM> myItems = new List<CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO_ITEM>();

      CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO_ITEM pagosElectronicosItems = new CEN_ProcessPaymentsObjectRequest.PAGO_ELECTRONICO_ITEM();
      if(isExec){
        pagosElectronicosItems.IMPORTE= String.valueOf(oppData.CEN_Fee__c);
        Datetime localPaymentDate;// = myPaymentDate.addSeconds(offset/1000);
          if(oppData.CEN_PaymentDate__c != null){
            Datetime myPaymentDate = oppData.CEN_PaymentDate__c;
            Timezone tz = Timezone.getTimeZone('America/Lima');
            Integer offset = tz.getOffset(myPaymentDate);
            localPaymentDate = myPaymentDate.addSeconds(offset/1000);
          }
        pagosElectronicosItems.FECHA_PAGO_ESTIM= String.valueOf(Date.valueOf(localPaymentDate));
        pagosElectronicosItems.MONEDA_PAGO = oppData.CEN_CurrencyCode__c;
      }
      myItems.add(pagosElectronicosItems);

      pagosElectronicos.item = myItems ; 
      return pagosElectronicos;
    }

    private static CEN_ProcessPaymentsObjectRequest.ABONO_CTA setAbonoCta(CEN_PaymentOrder__c oppData, Boolean isABCU) {
      CEN_ProcessPaymentsObjectRequest.ABONO_CTA abonosCta = new CEN_ProcessPaymentsObjectRequest.ABONO_CTA();
      List<CEN_ProcessPaymentsObjectRequest.ABONO_CTA_ITEM> myItems = new List<CEN_ProcessPaymentsObjectRequest.ABONO_CTA_ITEM>();
      
      CEN_ProcessPaymentsObjectRequest.ABONO_CTA_ITEM abonosCtaItems = new CEN_ProcessPaymentsObjectRequest.ABONO_CTA_ITEM();
      if(isABCU){
        abonosCtaItems.OPE_NUMERO= oppData.CEN_PaymentCode__c;
        abonosCtaItems.OPE_IMPORTE = String.valueOf(oppData.CEN_Amount__c) ;
        Datetime localPaymentDate;// = myPaymentDate.addSeconds(offset/1000);
        Datetime actualPaymentDate = system.now();
        if(oppData.CEN_PaymentDate__c != null){
          Datetime myPaymentDate = oppData.CEN_PaymentDate__c;
          Timezone tz = Timezone.getTimeZone('America/Lima');
          Integer offset = tz.getOffset(myPaymentDate);
          localPaymentDate = myPaymentDate.addSeconds(offset/1000);
        }
        abonosCtaItems.OPE_FECHA= String.valueOf(Date.valueOf(localPaymentDate));
        abonosCtaItems.BNKN2= oppData.CEN_AccountNumberByBank__c;
        //abonosCtaItems.FECCON= String.valueOf(oppData.CEN_PaymentDate__c);
        abonosCtaItems.FECCON= String.valueOf(actualPaymentDate).substring(0, 10);
        abonosCtaItems.MONEDA_PAGO= oppData.CEN_CurrencyCode__c;
      }
      myItems.add(abonosCtaItems);
      abonosCta.item = myItems ; //new List<CEN_ProcessPaymentsObjectRequest.ABONO_CTA_ITEM>{
      return abonosCta;
    }

    private static CEN_ProcessPaymentsObjectRequest.ANTICIPOS setAnticipos(CEN_PaymentOrder__c opData, Boolean isANT) {
      CEN_ProcessPaymentsObjectRequest.ANTICIPOS anticipos = new CEN_ProcessPaymentsObjectRequest.ANTICIPOS();
      CEN_ProcessPaymentsObjectRequest.ANTICIPOS_ITEM anticiposItems = new CEN_ProcessPaymentsObjectRequest.ANTICIPOS_ITEM();
      if(isANT){
        anticiposItems.BELNR = opData.CEN_AdvanceNumber__c;
        anticiposItems.BUKRS = String.valueOf(opData.CEN_SocietySAP__c); //TRASLADO DE ABONOS - descomentar
        //anticiposItems.BUKRS = String.valueOf(opData.CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c); //TRASLADO DE ABONOS - comentar
        Date docDate = opData.CEN_DocumentDateSAP__c;
        anticiposItems.GJAHR = String.valueOf(docDate.year());
        anticiposItems.WRBTR = '50';
        //anticiposItems.VIA_PAGO = opData.CEN_OriginPayment__c;
      }
    
      List<CEN_ProcessPaymentsObjectRequest.ANTICIPOS_ITEM> myItem = new List<CEN_ProcessPaymentsObjectRequest.ANTICIPOS_ITEM>();
      myItem.add(anticiposItems);
      anticipos.item = myItem;
      return anticipos;
    }

    private static CEN_ProcessPaymentsObjectRequest.TARJETA setTarjeta(CEN_PaymentOrder__c oppData, Boolean isTCRE, String strBank) {
      CEN_ProcessPaymentsObjectRequest.TARJETA tarjeta = new CEN_ProcessPaymentsObjectRequest.TARJETA();
      List<CEN_ProcessPaymentsObjectRequest.TARJETA_ITEM> myItems = new List<CEN_ProcessPaymentsObjectRequest.TARJETA_ITEM>();

      CEN_ProcessPaymentsObjectRequest.TARJETA_ITEM tarjetaItems = new CEN_ProcessPaymentsObjectRequest.TARJETA_ITEM();
      if(isTCRE){
        String myDesc = oppData.CEN_PaymentDescription__c;
        //String limpio = strBank==''?myDesc.replaceAll('[^a-zA-Z0-9- ]', ' '):oppData.CEN_PaymentCode__c;

        tarjetaItems.NRO_CHEQUE= strBank==''?oppData.CEN_LastFour__c:strBank;
        //tarjetaItems.REFERENCIA = limpio.length()>20?limpio.substring(0,20):limpio;
        tarjetaItems.REFERENCIA = oppData.CEN_ID_Culqi__c;
        tarjetaItems.OPE_IMPORTE= String.valueOf(oppData.CEN_Amount__c);
        Datetime localPaymentDate;// = myPaymentDate.addSeconds(offset/1000);
          if(oppData.CEN_PaymentDate__c != null){
            Datetime myPaymentDate = oppData.CEN_PaymentDate__c;
            Timezone tz = UserInfo.getTimeZone(); // Timezone.getTimeZone('America/Lima');
            Integer offset = tz.getOffset(myPaymentDate);
            localPaymentDate = myPaymentDate.addSeconds(offset/1000);
          }
        tarjetaItems.OPE_FECHA= String.valueOf(Date.valueOf(localPaymentDate));
        tarjetaItems.PAIS_BANCO= strBank==''?String.valueOf(oppData.CEN_CountryCode__c):'PE';  
        tarjetaItems.CLAVE_BANC= strBank==''?oppData.CEN_Banks__c:strBank;
        tarjetaItems.DESCRIPCION_BANCO= oppData.CEN_Banks__c=='999'?oppData.CEN_BankDescription__c:'';
        tarjetaItems.MONEDA_PAGO = oppData.CEN_CurrencyCode__c; 
      }
         
      myItems.add(tarjetaItems);
      tarjeta.item = myItems ; 
      return tarjeta;
    }

    public static CEN_ProcessPaymentObjectResponse generateOperationByOppId(CEN_PaymentOrder__c opData) {
      CEN_ProcessPaymentObjectResponse resp = new CEN_ProcessPaymentObjectResponse();
      CEN_ProcessPaymentsObjectRequest myObjectReq = new CEN_ProcessPaymentsObjectRequest();
      try {
          CEN_ProcessPaymentsObjectRequest.CAJA_AUTO cajaAuto = new CEN_ProcessPaymentsObjectRequest.CAJA_AUTO();

        if(opData != null && opData.CEN_Opportunity__r.CEN_Proforma__c != null) {
          String paymentType =  String.valueOf(opData.CEN_OriginPayment__c);
        //---- EFECTIVO -----
        cajaAuto.IT_EFECTIVO = setEfectivo(opData, paymentType=='Dinero en Efectivo');
            
        //---- PAGO ELECTRONICO -----
        cajaAuto.IT_PAGO_ELECTRONICO = setPagosElectronicos(opData, (paymentType=='EFEC' || paymentType=='TCRE'));

        //---- ABONO CUENTA -----
        cajaAuto.IT_ABCU = setAbonoCta(opData, paymentType=='ABCU');

        //---- ANTICIPOS -----
        cajaAuto.IT_ANTICIPOS = setAnticipos(opData, paymentType=='Anticipos Sueltos');

        //---- TARJETA -----
        cajaAuto.IT_TARJETA = setTarjeta(opData, (paymentType=='EFEC' || paymentType=='TCRE'), (paymentType=='EFEC'?'615':''));


        //---- CAJA AUTO -----
        cajaAuto.I_BUKRS = String.valueOf(opData.CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c); //'0019';
        cajaAuto.I_CAJA = '03';// String.valueOf(opData.CEN_Opportunity__r.CEN_Proyecto__r.CEN_CODIGOSAP__c); 
        cajaAuto.I_CUOTA = 1; //Integer.valueOf(opData.CEN_Installments__c); //1;
        String myKunnr = String.valueOf(opData.CEN_Opportunity__r.Account.CEN_N_mero_de_documento__pc!=null?opData.CEN_Opportunity__r.Account.CEN_N_mero_de_documento__pc:opData.CEN_Opportunity__r.Account.CEN_Numero_de_documento_del__c) ; //'0012399992';
        cajaAuto.I_STCD1 =  myKunnr;
        cajaAuto.I_PROFORMA = String.valueOf(opData.CEN_Opportunity__r.CEN_Proforma__c); //'2763';
        paymentType = paymentType == 'EFEC'?'PEFE':paymentType;
        cajaAuto.I_VIA_PAGO = paymentType=='Anticipos Sueltos'||paymentType=='Dinero en Efectivo'?'EFEC':paymentType;
        if (paymentType =='TCRE' ){
          cajaAuto.I_TIPO_PAGO = opData.CEN_OriginData__c == 'WEBTERRENO'? 'WEB': 'POS';
        }else if(paymentType =='PEFE'){
          cajaAuto.I_TIPO_PAGO = 'WEB';
        }
        //TRASLADO DE ABONOS - INICIO
        List<CEN_SocietySAP__mdt> lst = [SELECT MasterLabel, AccountNumberByBank__c,DeveloperName, CEN_CulqiCommerce__c FROM CEN_SocietySAP__mdt WHERE Moneda__c = 'PEN'];

        CEN_ProcessPaymentsObjectRequest.IS_PAGO_OTRA_SOCIEDAD isOtraSoc = new CEN_ProcessPaymentsObjectRequest.IS_PAGO_OTRA_SOCIEDAD();
        
        if (opData.RecordType.Name == 'Pago POS' || opData.RecordType.Name == 'Anticipo') {
          if ((opData.CEN_SocietySAP__c != null) && (opData.CEN_SocietySAP__c != opData.CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c)) {
            isOtraSoc.PAG_OTRA_SOC = 'X';
            isOtraSoc.SOCIEDAD = opData.CEN_SocietySAP__c;
          }
        } else {
          String tipoSociedad;
          for(CEN_SocietySAP__mdt l : lst){
              if(opData.CEN_AccountNumberByBank__c == l.AccountNumberByBank__c){
                  tipoSociedad = l.MasterLabel;
              }
          }
          if ((tipoSociedad != null) && (tipoSociedad != opData.CEN_Opportunity__r.CEN_Proyecto__r.CEN_Sociedad__c)) {
            isOtraSoc.PAG_OTRA_SOC = 'X';
            isOtraSoc.SOCIEDAD = tipoSociedad;
          }
        }
        
        cajaAuto.IS_PAGO_OTRA_SOCIEDAD = isOtraSoc;

        //TRASLADO DE ABONOS - FIN
        cajaAuto.I_MONEDA_PROFORMA = opData.CEN_CurrencyCode__c;

      }else{
        CEN_ProcessPaymentObjectResponse.BAPIRET2 respError = new CEN_ProcessPaymentObjectResponse.BAPIRET2();
        List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>respErrorList = new List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>();
        CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM respErrorDetails = new CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM();
        respErrorDetails.MESSAGE = 'Sin Proforma para procesar pago de operacion segura';
        respErrorList.add(respErrorDetails);
        respError.item = respErrorList;
        resp.ET_RETURN = respError;
        resp.E_OK = 'sinProforma';
        return resp;
      }

      myObjectReq.ZRFC_OTC_CAJA_AUTO_WS = cajaAuto;

      } catch (Exception ex )  {
              CEN_ProcessPaymentObjectResponse.BAPIRET2 respError = new CEN_ProcessPaymentObjectResponse.BAPIRET2();
              List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>respErrorList = new List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>();
              CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM respErrorDetails = new CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM();
              respErrorDetails.MESSAGE = ex.getMessage()+' dataErrorCatch-linea: '+ex.getLineNumber();
              respErrorList.add(respErrorDetails);
              respError.item = respErrorList;
              resp.ET_RETURN = respError;
              resp.E_OK = 'errorData';
              return resp;
      }
          
        
            resp = callProcessPaymentsApi(myObjectReq) ;
        
            return resp;
    }

    private static CEN_ProcessPaymentObjectResponse callProcessPaymentsApi(CEN_ProcessPaymentsObjectRequest reqProcess) {
      String customReqBody;
      CEN_ProcessPaymentObjectResponse resp = new CEN_ProcessPaymentObjectResponse();
      XMLSerializer serializerXML = new XMLSerializer();
      customReqBody = serializerXML.serialize(reqProcess);
      customReqBody = customReqBody.replace(
        'ZRFC_OTC_CAJA_AUTO_WS',
        'urn:ZRFC_OTC_CAJA_AUTO_WS'
      );
  
      try {
        CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_PaymenProcess');
        Dom.Document docReq = new Dom.Document();
        String setReq = customReq.replace('myBody', customReqBody);
        System.debug('setReqProcessPayment:' + setReq);
        docReq.load(setReq);
        callApi.setRequestBody(docReq);
        if(!Test.isRunningTest()){
          callApi.setTimeout(50000);
        }
        resp = (CEN_ProcessPaymentObjectResponse) callApi.makeCallout().getParsedResponse();
        system.debug('callProcessPaymentsApi-resp: '+resp);
      } catch (Exception ex) {
        System.debug('callOperactionSafeApi-Error: ' + ex.getMessage());
        CEN_ProcessPaymentObjectResponse.BAPIRET2 respError = new CEN_ProcessPaymentObjectResponse.BAPIRET2();
        List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>respErrorList = new List<CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM>();
        CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM respErrorDetails = new CEN_ProcessPaymentObjectResponse.BAPIRET2_ITEM();
        respErrorDetails.MESSAGE = ex.getMessage()+'apiErrorCatch';
        respErrorList.add(respErrorDetails);
        respError.item = respErrorList;
        resp.ET_RETURN = respError;
        resp.E_OK = 'sin proforma';
        
      }
      return resp;
    }    
}