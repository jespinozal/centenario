/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 07-09-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
public class CEN_CashPayment_ctr {
    @AuraEnabled(cacheable=true)
    public static List<PaymentWrapper> getCashPaymentCulqi(String inCreationDateFrom, String inCreationDateTo, String inPaymentCode, String inAmount, String productCulqi, String sociedad){
        System.debug('Entrando al metodo getCashPaymentCulqi');
        List<PaymentWrapper> pws = new List<PaymentWrapper>();
        try {
            Map<String, String> mapReq = new Map<String, String>();
            Map<String, Object> response = new Map<String, Object>();

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

            mapReq.put('creation_date_from', inCreationDateFrom );
            mapReq.put('creation_date_to', inCreationDateTo);
            mapReq.put('amount', inAmount );
            mapReq.put('codSociety', sociedad);

            System.debug('mapReq: ' + mapReq);
            List<CEN_PaymentOrderCashCulqiResponse> listResponse = new List<CEN_PaymentOrderCashCulqiResponse>();
            response = CEN_PaymentOrderCashCulqi_ctr.ListCashCulqi(mapReq);
            System.debug('response: ' + response);
            List<CEN_PaymentOrderCashCulqiResponse>  respList = (List<CEN_PaymentOrderCashCulqiResponse>)response.get('sucess');
            System.debug('ListaResp: '+ respList);
            List<String> listIdsCulqi = new List<String>();
            
            if(respList != null && respList.size() > 0){
                
                    for(CEN_PaymentOrderCashCulqiResponse resp : respList){
                        if(String.isEmpty(inPaymentCode) || ( String.isNotEmpty(inPaymentCode) && resp.payment_code == inPaymentCode )){ 
                        if((resp.metadata == null  && productCulqi == null) || resp.metadata.product == productCulqi){
                            if(resp.state == 'pending' || resp.state == 'paid'){
                                PaymentWrapper pw = new PaymentWrapper();
                                listIdsCulqi.add(resp.id);
                                String strAmount;
                                strAmount = String.valueOf(resp.amount);
                                pw.paymentCode = resp.payment_code;
                                String strAmountLeft = strAmount.left(strAmount.length()-2) + '.' + strAmount.right(2);
                                Decimal decAmount = Decimal.valueOf(strAmountLeft);
                                pw.amount = decAmount; 
                                String pruebita = resp.creation_date.rightPad(resp.creation_date.length() + 3 ,'000');
                                Datetime dt = Datetime.newInstance(long.valueOf(pruebita) );
                                String strDt = String.valueOf(dt).substring(0,10);
                                pw.creationDate = strDt;
                                System.debug('fecha creacion: ' + dt);
                                System.debug('fecha creacionS: ' + strDt);
                                System.debug('fecha creacionAPI: ' + resp.creation_date);
                                String pruebitaa = resp.expiration_date.rightPad(resp.expiration_date.length() + 3 ,'000');
                                Datetime edt = Datetime.newInstance(long.valueOf(pruebitaa) );
                                String striDt = String.valueOf(edt).substring(0,10);
                                pw.expirationDate = striDt;
                                pw.description = resp.description;
                                pw.currencyCode = resp.currency_code;
                                pw.totalFee = resp.total_fee;
                                pw.orderNumber = resp.order_number;
                                pw.esCulqiExpress = productCulqi != null? true : false;
                                switch on resp.state {
                                when 'pending' {
                                    pw.status = 'Pendiente';
                                }
                                when 'paid' {
                                    pw.status = 'Pagado';
                                }
                            }
                            pw.id = resp.id;
                            pws.add(pw);
                            }                            
                        }
                    }
                    }
                
            }

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

            //System.debug('response: ' + response.get('sucess'));
            
            
        } catch (Exception e) {
            System.debug('Error aqui:'+ e.getMessage());
            //throw new AuraHandledException(e.getMessage());
        }
        return pws;
    }

    @AuraEnabled(cacheable=false)
    public static String generatePaymentCashCulqi(List<PaymentWrapper> inArray, String inOppId){
        String resp; 
        String payments;

        try {
            
            Opportunity opp = [SELECT Id, Account.FirstName, Account.LastName from Opportunity where Id =: inOppId];
            List<CEN_PaymentOrder__c> listPaymentOrder = new List<CEN_PaymentOrder__c>();
            System.debug('inArray: ' + inArray);
            
           
            Id devRecordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
            System.debug('a punto de generar: ');
            for(PaymentWrapper item: inArray){
                System.debug('item: ' + item);                
                CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
                oPaymentOrder.CEN_Amount__c = item.amount;
                oPaymentOrder.CEN_PaymentDescription__c = item.description;
                oPaymentOrder.CEN_FirstName__c = opp.Account.FirstName;
                oPaymentOrder.CEN_LastName__c = opp.Account.LastName;
                oPaymentOrder.CEN_ID_Culqi__c = item.id;
                oPaymentOrder.CEN_Opportunity__c = inOppId;
                oPaymentOrder.CEN_OriginPayment__c = 'EFEC';
                oPaymentOrder.RecordTypeId = devRecordTypeId;
                oPaymentOrder.CEN_CurrencyCode__c = item.currencyCode;
                oPaymentOrder.CEN_PaymentCode__c = item.paymentCode;
                oPaymentOrder.CEN_PaymentDate__c = Date.valueOf(item.creationDate);
                oPaymentOrder.CEN_OrderExpirationDate__c = Date.valueOf(item.expirationDate);
                oPaymentOrder.CEN_Fee__c = item.totalFee==0?0.01:item.totalFee;
                oPaymentOrder.CEN_CulqiExpress__c = item.esCulqiExpress;
                switch on item.status {
                    when 'Pendiente' {
                        oPaymentOrder.CEN_PaymentStatus__c = 'Pendiente';
                    }
                    when 'Pagado' {
                        oPaymentOrder.CEN_PaymentStatus__c = 'Pagado';
                    }                                       
                }
                
                listPaymentOrder.add(oPaymentOrder);
                payments = payments + ',' + item.paymentCode;
            }

            if(listPaymentOrder != null && listPaymentOrder.size() > 0){
                System.debug('listPaymentOrder: ' + listPaymentOrder);
                insert listPaymentOrder;
            }

            payments = payments.replace('null,','');
            resp = 'Se generó orden de pago con las referencias: ' + payments.split(',');
        } catch (Exception e) { resp = 'error: ' + e.getMessage(); }

        return resp;
    }

    @AuraEnabled(cacheable=false)
    public static AmountWrapper validateInitialAmountPaymentCash(String inOppId){
      AmountWrapper resp = new AmountWrapper(); 
        try {
            Opportunity getOppAmounts = [SELECT CEN_Monto_cuota_de_inicial_de_precio__c, CEN_AmountPaidDate__c,cen_Proyecto__r.CEN_monto_minimo_deposito__c, 
                                        cen_Proyecto__r.CEN_monto_minimo_reserva__c,cen_Proyecto__r.CEN_Sociedad__c  FROM Opportunity WHERE id =: inOppId];
            Decimal initialAmount = getOppAmounts.CEN_Monto_cuota_de_inicial_de_precio__c != null ? getOppAmounts.CEN_Monto_cuota_de_inicial_de_precio__c : 0;
            Decimal amountPaidDate = getOppAmounts.CEN_AmountPaidDate__c != null ? getOppAmounts.CEN_AmountPaidDate__c : 0;
            if(amountPaidDate == 0){
              resp.amountMinimun = getOppAmounts.cen_Proyecto__r.CEN_monto_minimo_reserva__c;
            }else if(amountPaidDate < getOppAmounts.cen_Proyecto__r.CEN_monto_minimo_deposito__c){
              resp.amountMinimun = getOppAmounts.cen_Proyecto__r.CEN_monto_minimo_deposito__c - amountPaidDate;
            }else{
              resp.amountMinimun = 1;
            }
            resp.amountMaximun = initialAmount - amountPaidDate;

            resp.projectSociety = getOppAmounts.cen_Proyecto__r.CEN_Sociedad__c;
        } catch (Exception e) {resp.amountMinimun = 0; resp.amountMaximun = 0; }

        return resp;
    }
    public class AmountWrapper{
      @AuraEnabled
      public Decimal amountMinimun {get;set;}
      @AuraEnabled
      public Decimal amountMaximun {get;set;}
      @AuraEnabled
      public String projectSociety {get;set;}
    }


    public class PaymentWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public Decimal amount {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String paymentType {get;set;}
        @AuraEnabled
        public String paymentCode {get;set;}
        @AuraEnabled
        public String creationDate {get;set;} 
        @AuraEnabled
        public String expirationDate {get;set;}
        @AuraEnabled
        public String clientFirstName {get;set;}
        @AuraEnabled
        public String clientLastName {get;set;}
        @AuraEnabled
        public String reference {get;set;}
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
        public String orderNumber {get;set;}
        @AuraEnabled 
        public Boolean esCulqiExpress {get;set;}
    }
}