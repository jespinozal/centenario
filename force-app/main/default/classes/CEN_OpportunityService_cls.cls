/********************************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-04-14
* @description: web service para envío de oportunidades hacia la web de terrenos.
* 
* VERSION		DATE			AUTOR					ACTION
* 0.1			2021-04-12		Alan Alvarez			Creación
*
********************************************************************************/
@RestResource(urlMapping='/opportunity/*')
global class CEN_OpportunityService_cls {
    
    @HttpGet
    global static List<opportunityresp> doGet(){
        
        RestRequest req = RestContext.request;
        String dni = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<opportunity> lstopportunity = [select 
                                            Id
                                            ,Name
                                            ,Amount
                                            ,CEN_Cantidad_de_Lotes__c
                                            ,CEN_MaximumPaymentDate__c
                                            ,CEN_Importe__c
                                            ,CEN_Inicial_de_precio__c
                                            ,CEN_Moneda__c
                                            ,CEN_Saldo_del_precio__c
                                            ,CEN_Monto_Cuota_del_Saldo_de_precio__c
                                            ,CEN_Monto_cuota_de_inicial_de_precio__c
                                            ,CEN_AmountPaidDate__c
                                            ,CEN_N_Cuotas_del_Saldo_del_precio__c
                                            ,CEN_N_Cuotas_de_inicial_de_precio__c
                                            ,CEN_MinimumAmountPaymentOrder__c
                                            ,CEN_MaximumAmountPaymentOrder__c
                                            ,Account.Name
                                            ,CEN_Proyecto__r.Name
                                            ,CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c
                                            ,CEN_Proyecto__r.CEN_monto_minimo_reserva__c
                                            ,CEN_Proyecto__r.CEN_monto_minimo_deposito__c
                                            ,CEN_Proyecto__r.CEN_Sociedad__c
                                            ,(SELECT Product2.Name, Product2.ProductCode, Product2.DESCRIPCIONLOTE__c, Product2.CEN_PRECIOVENTAFUN__c, Product2.MANZANA__c, Product2.AREA__c FROM OpportunityLineItems  ORDER BY Product2.Name) 
                                            from opportunity where (Account.CEN_Numero_de_documento_del__c=:dni or 
                                                                    Account.CEN_N_mero_de_documento__pc =:dni) and
                                            StageName = 'Operación'];
        
        List<opportunityresp> lstoppResp = new List<opportunityresp>();
        opportunityresp oppResp;
        productresp proResp;
        for(opportunity opp: lstopportunity){
            oppResp = new opportunityresp();
            Blob blobOpp = Blob.valueOf(opp.Id);
            oppResp.opportunityid = EncodingUtil.base64Encode(blobOpp);
            oppResp.amount = opp.Amount;
            oppResp.numberlots = Integer.valueOf(opp.CEN_Cantidad_de_Lotes__c);
            oppResp.maximumpaymentdate = opp.CEN_MaximumPaymentDate__c;
            oppResp.importe = opp.CEN_Importe__c;
            oppResp.currencycode = opp.CEN_Moneda__c;
            oppResp.initial = opp.CEN_Inicial_de_precio__c;
            oppResp.financingamount = opp.CEN_Saldo_del_precio__c;
            oppResp.financingquotasamount = opp.CEN_Monto_Cuota_del_Saldo_de_precio__c;
            oppResp.initialquotaamount = opp.CEN_Monto_cuota_de_inicial_de_precio__c;
            oppResp.accumulatedamount = opp.CEN_AmountPaidDate__c;
            oppResp.financingquotasnumber = opp.CEN_N_Cuotas_del_Saldo_del_precio__c;
            oppResp.initialquotanumber = opp.CEN_N_Cuotas_de_inicial_de_precio__c;
            oppResp.opportunityname = opp.Name;
            oppResp.clientname = opp.Account.Name;  
            oppResp.minimumamountpaymentorder = opp.CEN_MinimumAmountPaymentOrder__c;
            oppResp.maximumamountpaymentorder = opp.CEN_MaximumAmountPaymentOrder__c;   
            oppResp.projectname = opp.CEN_Proyecto__r.Name;
            oppResp.projectmaximumpaymentdueperiod = opp.CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c;
            oppResp.projectminimumreserve = opp.CEN_Proyecto__r.CEN_monto_minimo_reserva__c;
            oppResp.projectminimumdeposit = opp.CEN_Proyecto__r.CEN_monto_minimo_deposito__c;
            oppResp.society = opp.CEN_Proyecto__r.CEN_Sociedad__c;
            List<productresp> lstproResp = new List<productresp>();
            for(OpportunityLineItem Item: opp.OpportunityLineItems){
                proResp = new productresp();
                proResp.opportunityname = opp.Name;
                proResp.productname = Item.Product2.Name;
                proResp.productcode = Item.Product2.ProductCode;
                proResp.lotdescripcion = Item.Product2.DESCRIPCIONLOTE__c;
                proResp.salesprice = Item.Product2.CEN_PRECIOVENTAFUN__c;
                proResp.block = Item.Product2.MANZANA__c;
                proResp.area = Item.Product2.AREA__c;
                lstproResp.add(proResp);
            }
            oppResp.lstpProducts = lstproResp;
            lstoppResp.add(oppResp);
        }
        return lstoppResp;   
    }
    
    global class opportunityresp{
        
        private String opportunityid  { get; set; }
        private double amount { get; set; }
        private Integer numberlots { get; set; }
        private date maximumpaymentdate { get; set; }
        private double importe { get; set; }
        private String currencycode { get; set; }
        private double initial { get; set; }
        private double financingamount { get; set; }
        private double financingquotasamount { get; set; }
        private double initialquotaamount { get; set; }
        private double financingquotasnumber { get; set; }
        private double initialquotanumber { get; set; }
        private String opportunityname { get; set; }
        private String clientname { get; set; }
        private double accumulatedamount { get; set; }
        private Decimal minimumamountpaymentorder { get; set; }
        private Decimal maximumamountpaymentorder { get; set; }
        private String projectname { get; set; }
        private Decimal projectmaximumpaymentdueperiod { get; set; }
        private Decimal projectminimumreserve { get; set; }
        private Decimal projectminimumdeposit { get; set; }
        private String society { get; set; }
        private List<productresp> lstpProducts { get; set; }
    }
    
    global class productresp{     
        
        private String opportunityname;
        private String productname;
        private String productcode;
        private String lotdescripcion;
        private String salesprice;
        private String block;
        private String area;  
    }
       
}