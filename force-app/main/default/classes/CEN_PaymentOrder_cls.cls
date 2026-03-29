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
public with sharing class CEN_PaymentOrder_cls {
    public static Map<String, Object> consultPaymentOrderById(String payId) {
        Map<String, Object> resp = new Map<String, Object>();
        try {
            Map<String, String> myParaments = new Map<String, String>();
            myParaments.put('myPayId', payId);
            String codSociety = [SELECT CEN_ProjectSociety__c FROM CEN_PaymentOrder__c WHERE CEN_ID_Culqi__c = :payId].CEN_ProjectSociety__c;
            String myCulqiSociety  = CEN_CulqiCommerce__mdt.getInstance('S'+codSociety).Label;
            String myConfig = 'CEN_CulquiConsultPaymentOrder'+myCulqiSociety;
            resp = callPaymentOrderApi(null,myConfig,myParaments);
        } catch (Exception ex) {resp.put('error', ex.getMessage());}
        
        return resp;
    }
    
    public static Map<String, Object> generatePaymentOrderFromCash(CEN_PaymentOrder__c payment) {
        Map<String, Object> mapResp = new Map<String, Object>();
        system.debug('IN-generatePaymentOrderFromCash: '+payment);
        try {
            validatePaymentData(payment);
             //String accId = payment.CEN_Opportunity__r.AccountId;
            /*Account acc = [
                SELECT FirstName, LastName, PersonEmail, PersonMobilePhone
                FROM Account
                WHERE Id = :accId
            ];
            validateAccountData(acc);*/
            CEN_PaymentOrderRequest myReq = new CEN_PaymentOrderRequest();
            String strAmount = String.valueOf(payment.CEN_Amount__c);
            strAmount = strAmount.replace('.', '');
            myReq.amount = Integer.valueOf(strAmount);
            myReq.currency_code = payment.CEN_CurrencyCode__c;
            myReq.description = payment.CEN_PaymentDescription__c;
            myReq.order_number = payment.Name;
            Date dateExp = payment.CEN_DueDate__c;
            Datetime dt = DateTime.newInstance(
                dateExp.year(),
                dateExp.month(),
                dateExp.day(),23,59,59);
            String strDt = String.valueOf(dt.getTime());
            myReq.expiration_date = Long.valueOf(strDt.substring(0, 10));
            
            CEN_PaymentOrderRequest.ClientPayment clientCEN = new CEN_PaymentOrderRequest.ClientPayment();
            String myFirstName = payment.CEN_FirstName__c;
            myFirstName =  myFirstName.remove('.');
            clientCEN.first_name = myFirstName.length()>50?myFirstName.substring(50):myFirstName;
            String myLastName = payment.CEN_LastName__c;
            myLastName =  myLastName.remove('.');
            clientCEN.last_name = myLastName.length()>50?myLastName.substring(50):myLastName;
            clientCEN.email = payment.CEN_Email__c;
            clientCEN.phone_number = payment.CEN_PhoneNumber__c;
            
            myReq.client_details = clientCEN;
            String myCulqiSociety  = CEN_CulqiCommerce__mdt.getInstance('S'+payment.CEN_ProjectSociety__c).Label;
            String myConfig = 'CEN_CulquiPaymentOrder'+myCulqiSociety;
            mapResp = callPaymentOrderApi(myReq, myConfig, null);
        } catch (Exception ex) {mapResp.put('error', ex.getMessage());}
        return mapResp;
    }
    
    private static void validatePaymentData(CEN_PaymentOrder__c payment) {
        if (payment.CEN_Amount__c == null || payment.CEN_Amount__c < 6) {throw new PaymentOrderException('Error en importe de la orden de pago');}
        if (payment.CEN_CurrencyCode__c == null) {throw new PaymentOrderException('Error en tipo de moneda de la orden de pago');}
        String srtDes = payment.CEN_PaymentDescription__c;
        if (srtDes == null || srtDes.length() < 5) {throw new PaymentOrderException('Error en descripcion de la orden de pago');}
        if (payment.Name == null || payment.Name == '') {throw new PaymentOrderException('Error en descripcion de la orden de pago');}
        Date myDate = payment.CEN_DueDate__c;
        Date currentDate = System.today();
        if (myDate == null || currentDate.daysBetween(myDate) < 0) {throw new PaymentOrderException('Error en fecha de expiracion de la orden de pago: ' + myDate.daysBetween(System.today()));}
        String strFirstName = payment.CEN_FirstName__c;
        if (strFirstName == null || strFirstName.length() < 2) {throw new PaymentOrderException('Error en nombre del cliente de la orden de pago');}
        String strLastName = payment.CEN_LastName__c;
        if (strLastName == null || strLastName.length() < 2) {throw new PaymentOrderException('Error en apellido del cliente de la orden de pago');}
        String strPersonEmail = payment.CEN_Email__c;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern myPattern = Pattern.compile(emailRegex);
        if (strPersonEmail == null) {throw new PaymentOrderException('Error en mail del cliente de la orden de pago');}
        else{
            Matcher myMatcher = myPattern.matcher(strPersonEmail);
            if(strPersonEmail.length() < 5 ||!myMatcher.matches()){throw new PaymentOrderException('Error en mail del cliente de la orden de pago');}
        }
        String strPersonMobilePhone = payment.CEN_PhoneNumber__c;
        if (strPersonMobilePhone == null || strPersonMobilePhone.length() < 8) {throw new PaymentOrderException('Error en telefono del cliente de la orden de pago');}
    }
    
    private static Map<String, Object> callPaymentOrderApi(CEN_PaymentOrderRequest myReq, String myConfig, Map<String, String> paraments) {
        Map<String, Object> mapApiResp = new Map<String, Object>();
        HttpResponse httpResp = new HttpResponse();
        CEN_Callout_cls myApi = new CEN_Callout_cls(myConfig);
        
        if (myReq != null) {
            String jsonReq = JSON.serialize(myReq);
            myApi.setRequestBody(jsonReq);
        }
        if (paraments != null) {myApi.setParams(paraments); }
        myApi.setTimeout(30000);
        httpResp = myApi.makeCallout().getResponse();
        
        if (httpResp.getStatusCode() == 201) {
            String strBody = httpResp.getBody();
            strBody = strBody.replace('"object"', '"wObject"');
            CEN_PaymentOrderResponse myResp = (CEN_PaymentOrderResponse) JSON.deserialize(strBody,CEN_PaymentOrderResponse.class);
            mapApiResp.put('sucess', myResp);
        } else {
            Map<String, Object> map1 = (Map<String, Object>) JSON.deserializeUntyped(httpResp.getBody());
            mapApiResp.put('error', map1.get('merchant_message'));
        }
        
        return mapApiResp;
    }
    
    public class PaymentOrderException extends Exception {
    }
}