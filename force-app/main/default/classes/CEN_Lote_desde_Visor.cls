public with sharing class CEN_Lote_desde_Visor {
    @InvocableMethod
    public static List<Result> ObtenerIdLoteOportunidad(List<Requests> request){
        System.debug(request);
        List<String> respuesta = new List<String>();
        List<Result> results = new List<Result>();
        Result response = new Result();
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        List<Product2> lotes = new List<Product2>();
        List<String> productos_id = new List<String>();
        //	Se busca los lotes de oportunidad existentes
        try{
            olis = [SELECT Id, OpportunityId, Product2Id, Product2.CODLOTE__c, Description FROM OpportunityLineItem WHERE OpportunityId=:request[0].recorIdrequest];
        }catch(Exception ex){
            System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        //	Si hay lotes de oportunidad se debe traer sus datos de SAP
        if(!olis.isEmpty()){
            for(OpportunityLineItem oli:olis){
                productos_id.add(oli.Product2Id);
            }
            try{
                lotes = [SELECT Id, CODLOTE__c, CEN_Proyecto__r.CEN_CODIGOSAP__c, MANZANA__c FROM Product2 WHERE Id IN :productos_Id ];
            }catch(Exception ex){
                System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            }
            //	Si los lotes están registrados en SF
            if(!lotes.isEmpty()){
                response.loteContentResponse = new List<CEN_ResponseContentVisorLotes>();
                //	Extraer data de lotes desde SAP
                for(Product2 lote:lotes){
                    CEN_ResponseContentVisorLotes rcvl = null;
                    try{
                        rcvl = CEN_ConsultVisorLotes.ByProyectCodloteManzana(lote.CODLOTE__c, lote.CEN_Proyecto__r.CEN_CODIGOSAP__c, '');
                    }catch(Exception ex){
                        System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    }
                    if(rcvl!=null){
                        response.loteContentResponse.add(rcvl);
                    }
                }
                //	Si hay lotes extraidos de SAP devolver data a Flujo
                if(!response.loteContentResponse.isEmpty()){
                    response.JSONlotes = JSON.serialize(response.loteContentResponse);
                    results.add(response);
                    return results;
                }
            }
        }
        return null;
    }
    
    public class Requests {
        @InvocableVariable
        public String recorIdrequest;
    }
    public class Result{
        @InvocableVariable
        public List<CEN_ResponseContentVisorLotes> loteContentResponse;
        @InvocableVariable
        public String IDlote;
        @InvocableVariable
        public String JSONlotes;
    }

}