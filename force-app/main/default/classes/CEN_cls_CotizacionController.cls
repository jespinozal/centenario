public class CEN_cls_CotizacionController {

    private final Opportunity q;
    
    public CEN_cls_CotizacionController(ApexPages.StandardController stdController) {
        this.q = (Opportunity)stdController.getRecord();         
        system.debug('CEN_vf_CotizacionPDF - oportunidad ID:'+q.Id);
    }
    
    public List<Quote> getQuote() {
       system.debug('getQuote');

        List<Quote> CQuote = [SELECT id, CEN_Area__c, CEN_Precio_por_mt2__c, CEN_Inicial__c, CEN_Cuota_inicial__c,CEN_N_cuotas_de_inicial_de_precio__c,CEN_Saldo_del_precio__c,
                              CEN_Inicial_porct__c, CEN_Numero_de_cuentas_inicial__c, CEN_Lote__c,CEN_Precio_de_venta__c,
                              CEN_Tipologia__c, CEN_Manzana__c, CEN_Tasa_de_Interes_compensatorio_anual__c,
                              CEN_Numero_de_cuotas_a_financiar__c, CEN_Monto_cuota_de_inicial_de_precio__c,
                              CEN_Monto_cuota_del_saldo_de_precio__c, CEN_Saldo_capital_a_financiar__c
                              FROM Quote WHERE OpportunityId =:q.Id order by CreatedDate desc limit 1];       
        system.debug(CQuote);
        return CQuote; 
    }
    
    
    
    
}