/**
 * @description       : CEN_POSPayments_ctr
 * @author            : @everis.com
 * @group             : CENTENARIO
 * @last modified on  : 24-06-2025
 * @last modified by  : Felipe Bermudez
 * Clase Test         : CEN_POSPayments_tst
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   05-09-2021   @everis.com       Initial Version
 * 1.0   24-06-2025   Felipe Bermudez   Se agrego validacion a campo .bank cuando llegue vacio nuevo panel CULQI
 **/
public with sharing class CEN_POSPayments_ctr {

    @AuraEnabled(cacheable=true)
    public static List<PaymentWrapper> getPosPaymentCulqi(String inCreationDateFrom, String inCreationDateTo, String inAutorizacion, String inCode, String inCard, String inAmount,String sociedad, String moneda, Boolean traslado){
        List<PaymentWrapper> Prueba = getPosPaymentCulqi(inCreationDateFrom, inCreationDateTo, inAutorizacion, inCode, inCard, inAmount, null,sociedad, moneda, traslado);
        return Prueba;
    }

    @AuraEnabled(cacheable=true)
    public static List<PaymentWrapper> getPosPaymentCulqi(String inCreationDateFrom, String inCreationDateTo, String inAutorizacion, String inCode, String inCard, String inAmount, String productCulqi, String sociedad, String moneda, Boolean traslado){    
        try {
            Map<String, String> mapReq = new Map<String, String>();
            Map<String, Object> response = new Map<String, Object>();
            List<PaymentWrapper> pws = new List<PaymentWrapper>();

            if(String.isNotEmpty(inAutorizacion)){
                List<CEN_PaymentOrder__c> listPaymentReference = new List<CEN_PaymentOrder__c>();
                listPaymentReference = [SELECT Id, Name, CEN_Reference__c, CEN_Opportunity__r.Name FROM CEN_PaymentOrder__c WHERE CEN_Reference__c =: inAutorizacion];

                if(listPaymentReference.size() > 0){
                    PaymentWrapper pw = new PaymentWrapper();
                    pw.status = 'pagado';
                    pw.id = listPaymentReference[0].Id;
                    pw.description = listPaymentReference[0].Name;
                    pw.opportunity = listPaymentReference[0].CEN_Opportunity__r.Name;
                    pws.add(pw);
                    return pws;
                 }
            }

            if(String.isEmpty(inCreationDateFrom)){
                Date dateToday = System.today();
                Datetime dt = DateTime.newInstance(
                    dateToday.year(),
                    dateToday.month(),
                    dateToday.day(),00,00,00);
                inCreationDateFrom = String.valueOf(dt.getTime()).substring(0,10);
            }
            else{
                Date dateFrom = Date.valueOf(inCreationDateFrom);
                Datetime dt = DateTime.newInstance(
                    dateFrom.year(),
                    dateFrom.month(),
                    dateFrom.day(),00,00,00);
                inCreationDateFrom = String.valueOf(dt.getTime()).substring(0,10);
            }

            if(String.isEmpty(inCreationDateTo)){
                Date dateToday = System.today();
                Datetime dt = DateTime.newInstance(
                    dateToday.year(),
                    dateToday.month(),
                    dateToday.day(),23,59,59);
                inCreationDateTo = String.valueOf(dt.getTime()).substring(0,10);
            }
            else{
                Date dateTo = Date.valueOf(inCreationDateTo);
                Datetime dt = DateTime.newInstance(
                    dateTo.year(),
                    dateTo.month(),
                    dateTo.day(),23,59,59);
                inCreationDateTo = String.valueOf(dt.getTime()).substring(0,10);
            }

            if(!String.isBlank(inCode)){
                inCode = inCode.leftPad(6, '0');
            }
            
            mapReq.put('creation_date_from', inCreationDateFrom );
            mapReq.put('creation_date_to', inCreationDateTo);
            mapReq.put('amount', inAmount.trim() );
            mapReq.put('currency_code', moneda);
            mapReq.put('limit', '500');

            System.debug('Ver request'+ mapReq);
            if(!traslado){
                mapReq.put('codSociety', sociedad);
                getCharges(response, mapReq, pws, inAutorizacion, inCard, inCode, productCulqi, sociedad);
            }else{
                Set<String> sociedades = new Set<String>(); 
                for (CEN_SocietySAP__mdt sociedadQuery : [SELECT Id, MasterLabel, DeveloperName FROM CEN_SocietySAP__mdt]) {
                    sociedades.add(sociedadQuery.Masterlabel);
                }

                for(String strSociedad : sociedades){
                    mapReq.put('codSociety', strSociedad);
                    system.debug('filtrando por sociedad: '+strSociedad);
                    getCharges(response, mapReq, pws, inAutorizacion, inCard, inCode, productCulqi, strSociedad);
                }
            }

            return pws;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    public static void getCharges(Map<String, Object> response, Map<String, String> mapReq, List<PaymentWrapper> pws, String inAutorizacion, String inCard, String inCode, String productCulqi, String sociedadQuery){
        response = CEN_PaymentOrderChargesCulqi_ctr.ListChargesCulqi(mapReq);
        System.debug('response: ' + response);
        List<CEN_PaymentOrderChargesCulqiResponse>  respList = (List<CEN_PaymentOrderChargesCulqiResponse>)response.get('sucess');
        List<String> listIdsCulqi = new List<String>();
        System.debug('InAutorizacion: '+inAutorizacion);
        if(respList != null && respList.size() > 0){
            for(CEN_PaymentOrderChargesCulqiResponse resp : respList){
                //if(resp.paid){
                if(resp.outcome.type == 'venta_exitosa' && resp.current_amount > 0){
                    if(String.isEmpty(inAutorizacion) || ( String.isNotEmpty(inAutorizacion) && resp.authorization_code == inAutorizacion.trim() )){
                        if(String.isEmpty(inCode) || ( String.isNotEmpty(inCode) && resp.metadata.purchaseNumber == inCode.trim() )){
                            if(String.isEmpty(inCard) || ( String.isNotEmpty(inCard) && resp.source.last_four == inCard.trim() )){
                                if((resp.metadata == null  && productCulqi == null) || resp.metadata.product == productCulqi){
                                    PaymentWrapper pw = new PaymentWrapper();
                                    listIdsCulqi.add(resp.id);
                                    pw.autorizacion = resp.authorization_code;
                                    pw.amount = resp.amount == null ? 0 : resp.amount/100.00;
                                    Datetime dt = DateTime.newInstance(resp.creation_date);
                                    String strDt = String.valueOf(dt).substring(0,10);
                                    pw.creationDate = dt;//strDt;
                                    pw.description = resp.description;
                                    pw.paymentType = resp.source.type == 'card' ? 'Tarjeta' : 'Efectivo';
                                    pw.cardNumber = resp.source.card_number;
                                    pw.paymentCode = resp.metadata.purchaseNumber; //COMENTAR PARA PRUEBAS
                                    pw.clientFirstName = resp.antifraud_details.first_name;
                                    pw.clientLastName = resp.antifraud_details.last_name;
                                    pw.bank = !String.isBlank(resp?.source?.iin?.issuer?.name) ? resp.source.iin.issuer.name.trim().replace(',', '') : 'DESCONOCIDO';//Felipe
                                    pw.currencyCode = resp.currency_code;
                                    pw.lastFour = resp.source.last_four;
                                    pw.countryCode = resp.source.iin.issuer.country_code;
                                    pw.totalFee = resp.total_fee == null ? 0 : resp.total_fee/100.00;
                                    pw.esCulqiExpress = productCulqi != null? true : false;
                                    pw.id = resp.id;
                                    //pw.society = sociedadQuery.Masterlabel;
                                    pw.society = sociedadQuery;
                                    pws.add(pw);
                                }
                            }
                        }
                    }
                }
            }

        }

        System.debug('listIdsCulqi ' + listIdsCulqi.size());
        if(listIdsCulqi != null && listIdsCulqi.size() > 0){
            List<CEN_PaymentOrder__c> lstPayments = new List<CEN_PaymentOrder__c>();
            lstPayments = [SELECT CEN_ID_Culqi__c FROM CEN_PaymentOrder__c WHERE CEN_ID_Culqi__c IN: listIdsCulqi] ;
            string payments = string.join(lstPayments,',');
            Integer j = 0;
            while (j < pws.size())
            {
                if(pws.get(j).id != null && payments.contains(pws.get(j).id))
                {
                    pws.remove(j);
                }else
                {
                    j++;
                }
            }
        }
    }

    @AuraEnabled(cacheable=false)
    public static String generatePaymentPOS(List<PaymentWrapper> inArray,
                                            String inOppId
                                            ){
        String resp;
        String payments = '';
        try {
            List<CEN_Banks__mdt> listBanks = new List<CEN_Banks__mdt>();
            Map<String,String> mapBanks = new Map<String,String>();
            listBanks = [SELECT MasterLabel,DeveloperName FROM CEN_Banks__mdt];

            for(CEN_Banks__mdt oBank :listBanks){
                mapBanks.put(oBank.DeveloperName, oBank.MasterLabel);
            }

            List<CEN_PaymentOrder__c> listPaymentOrder = new List<CEN_PaymentOrder__c>();
            System.debug('inArray: ' + inArray);
            String StatusPO = Test.isRunningTest() ? 'Pendiente': 'Pagado';
            Id devRecordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();

            opportunity opp = [Select Id, CEN_Proyecto__r.CEN_Sociedad__c, CEN_Proforma__c, CEN_LastApiCall__c from opportunity where id= :inOppId limit 1];
            Integer countPaymentsProcessing = [SELECT COUNT() FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =: inOppId AND  CEN_PaymentStatus__c = 'Procesando'];
            Integer cantPayPending = 0 ;

            for(PaymentWrapper item: inArray){
                System.debug('item: ' + item);
                CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
                oPaymentOrder.CEN_Amount__c = item.amount;
                oPaymentOrder.CEN_Reference__c = item.autorizacion;
                DateTime dt = Datetime.now();
                Time myTime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
                String ref = dt.day()+'-'+dt.month()+'-'+dt.year()+'T'+String.valueOf(myTime);
                oPaymentOrder.CEN_PaymentDescription__c = String.isBlank(item.description) ? ref : item.description;
                oPaymentOrder.CEN_FirstName__c = item.clientFirstName;
                oPaymentOrder.CEN_LastName__c = item.clientLastName;
                oPaymentOrder.CEN_ID_Culqi__c = item.id;
                oPaymentOrder.CEN_Opportunity__c = inOppId;
                oPaymentOrder.CEN_OriginPayment__c = 'TCRE';
                //oPaymentOrder.CEN_PaymentStatus__c = StatusPO;
                if(cantPayPending == 0){
                    //oPaymentOrder.CEN_PaymentStatus__c = opp.CEN_Proforma__c!=null ? StatusPO : 'Procesando';
                    oPaymentOrder.CEN_PaymentStatus__c = countPaymentsProcessing > 0 ? 'Procesando' : StatusPO;
                }else{
                    oPaymentOrder.CEN_PaymentStatus__c = 'Procesando';
                }
                oPaymentOrder.RecordTypeId = devRecordTypeId;
                oPaymentOrder.CEN_CurrencyCode__c = item.currencyCode;
                //String nombreBanco = item.bank.replace(',', '');
                String nombreBanco = (item.bank != null) ? item.bank.replace(',', '') : 'BCP_PEN';//Felipe
                nombreBanco = nombreBanco.replace('.', '');
                nombreBanco = nombreBanco.replace('-', '');
                nombreBanco = nombreBanco.replace(' ', '');
                nombreBanco = nombreBanco.length() > 37 ? nombreBanco.subString(0,37).trim() : nombreBanco.trim();
                String banco = mapBanks.get(nombreBanco + '_' + item.currencyCode);
                oPaymentOrder.CEN_Banks__c = String.isBlank(banco) ? '999': banco;
                oPaymentOrder.CEN_BankDescription__c = (item.bank != null) ? item.bank.replace(',', '') : 'BCP_PEN';//Felipe
                oPaymentOrder.CEN_PaymentDate__c = item.creationDate;//Date.valueOf(item.creationDate);
                oPaymentOrder.CEN_LastFour__c = item.lastFour;
                oPaymentOrder.CEN_CountryCode__c = item.countryCode;
                oPaymentOrder.CEN_Fee__c = item.totalFee;
                oPaymentOrder.CEN_CulqiExpress__c = item.esCulqiExpress;
                oPaymentOrder.CEN_PaymentCode__c = item.paymentCode;
                oPaymentOrder.CEN_SocietySAP__c = item.society;
                oPaymentOrder.CEN_TransferMoney__c = opp.CEN_Proyecto__r.CEN_Sociedad__c != item.society ? true : false;
                ++cantPayPending;
                listPaymentOrder.add(oPaymentOrder);

                payments += item.paymentCode + ',';
            }

            if(listPaymentOrder != null && listPaymentOrder.size() > 0){
                payments = payments.removeEnd(',');
                List<String> lstPayments = payments.split(',');
                String respSingle = 'Se generó orden de pago con el código de pago: [ ' + payments + ' ]';
                String respMulti = 'Se generaron las ordenes de pago con los códigos de pago: [ ' + payments + ' ]';
                resp = lstPayments.size() > 1 ?  respMulti : respSingle;
                insert listPaymentOrder;
            }

        } catch (Exception e) { resp = 'error: ' + e.getMessage(); System.debug('error: ' + e.getMessage());}

        return resp;
    }

    @AuraEnabled(cacheable=false)
    public static InitDataWrapper validateInitialAmountPayment(String inOppId){
        InitDataWrapper resp = new InitDataWrapper();
        try {

            List<CEN_PaymentOrder__c> lstPayments = new List<CEN_PaymentOrder__c>();
            lstPayments = [SELECT Id
                           FROM CEN_PaymentOrder__c
                           WHERE CEN_Opportunity__c =: inOppId
                           AND CEN_PaymentStatus__c IN ('Pagado','PendienteSAP')] ;

            Opportunity getOppAmounts = [SELECT CEN_Monto_cuota_de_inicial_de_precio__c,
                                        CEN_AmountPaidDate__c,
                                        CEN_Proyecto__r.CEN_Sociedad__c,
                                        CEN_Proyecto__r.CEN_monto_minimo_reserva__c,
                                        Comentarios__c
                                        FROM Opportunity
                                        WHERE id =: inOppId];
            Decimal initialAmount = getOppAmounts.CEN_Monto_cuota_de_inicial_de_precio__c != null ? getOppAmounts.CEN_Monto_cuota_de_inicial_de_precio__c : 0;
            Decimal amountPaidDate = getOppAmounts.CEN_AmountPaidDate__c != null ? getOppAmounts.CEN_AmountPaidDate__c : 0;

            if(lstPayments != null && lstPayments.size() > 0){
                resp.amountMinimun = 0.0;
            }else{
                resp.amountMinimun = getOppAmounts.CEN_Proyecto__r.CEN_monto_minimo_reserva__c;
            }

            resp.amountMaximun = initialAmount - amountPaidDate;
            resp.projectSociety = getOppAmounts.CEN_Proyecto__r.CEN_Sociedad__c;

        } catch (Exception e) {
            resp.amountMinimun = 0;
            resp.amountMaximun = 0;
            resp.projectSociety = null;}

        return resp;
    }

    public class PaymentWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public Decimal amount {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String opportunity {get;set;}
        @AuraEnabled
        public String paymentType {get;set;}
        @AuraEnabled
        public DateTime creationDate {get;set;}
        @AuraEnabled
        public String clientFirstName {get;set;}
        @AuraEnabled
        public String clientLastName {get;set;}
        @AuraEnabled
        public String autorizacion {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String bank {get;set;}
        @AuraEnabled
        public String currencyCode {get;set;}
        @AuraEnabled
        public String lastFour {get;set;}
        @AuraEnabled
        public String countryCode {get;set;}
        @AuraEnabled
        public Decimal totalFee {get;set;}
        @AuraEnabled
        public Boolean esCulqiExpress {get;set;}
        @AuraEnabled
        public String paymentCode {get;set;}
        @AuraEnabled
        public String cardNumber {get;set;}
        @AuraEnabled
        public String society {get;set;}
    }

    public class InitDataWrapper{
        @AuraEnabled
        public Decimal amountMinimun {get;set;}
        @AuraEnabled
        public Decimal amountMaximun {get;set;}
        @AuraEnabled
        public String projectSociety {get;set;}
    }
}