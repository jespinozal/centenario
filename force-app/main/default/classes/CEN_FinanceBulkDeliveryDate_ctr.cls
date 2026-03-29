public class CEN_FinanceBulkDeliveryDate_ctr {

    public class BatchWrapper {
        @AuraEnabled
        public String Id { get; set; } 
        @AuraEnabled
        public String Descripcionlote { get; set; }
        @AuraEnabled
        public String Codestadolote { get; set; }
        @AuraEnabled
        public String Desestadolote { get; set; }
        @AuraEnabled
        public String Codsituacionlote { get; set; }
        @AuraEnabled
        public String Fecentrega { get; set; }
        @AuraEnabled
        public String Numeroletra { get; set; }
        @AuraEnabled
        public String Manzana { get; set; }
        @AuraEnabled
        public String Proforma { get; set; }
        @AuraEnabled
        public String CodigoSAP { get; set; }
    }

    public class rWrapper {
        @AuraEnabled
        public List<BatchWrapper> batchList { get; set; }
        @AuraEnabled
        public Integer totalRegistros { get; set; }
        @AuraEnabled
        public String CodigoSAP { get; set; }
    }

    @AuraEnabled
    public static rWrapper getBatchPagination (List<BatchWrapper> mapResp, String pageSize, String pageNumber) {
        Integer ps = Integer.valueOf(pageSize);
        Integer pn = Integer.valueOf(pageNumber);

        try{
            List<BatchWrapper> bws = new List<BatchWrapper>();
            rWrapper rw = new rWrapper();

            if(mapResp != null && mapResp.size() > 0){
              Integer desde = 0;
              Integer hasta = 0;
              if((ps*pn) > mapResp.size()){
                desde  = (ps*(pn-1));
                hasta  = mapResp.size()-1;
              }else{
                desde = (ps*pn)-ps;
                hasta = (ps*pn)-1;
              }
              for(Integer i=desde; i<=hasta; i++){
                BatchWrapper bw = new BatchWrapper();
                bw.Id = mapResp[i].Id;
                bw.Desestadolote = mapResp[i].Desestadolote;
                bw.Codestadolote = mapResp[i].Codestadolote;
                bw.Codsituacionlote = mapResp[i].Codsituacionlote;
                bw.Descripcionlote = mapResp[i].Descripcionlote;
                bw.Fecentrega = mapResp[i].Fecentrega;
                bw.Numeroletra = mapResp[i].Numeroletra;
                bw.Manzana = mapResp[i].Manzana;
                bw.Proforma = mapResp[i].Proforma;
                bws.add(bw);
              }

              rw.CodigoSAP = mapResp[0].CodigoSAP;
              rw.totalRegistros = mapResp.size();
              rw.batchList = bws;
            }

            return rw;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static string getProjectData(string Idproyecto){
      Proyecto__c proyecto = null; 
      try {
        proyecto = [
            SELECT Id, Name
            FROM Proyecto__c
            WHERE Id = :Idproyecto
            LIMIT 1
            ];
        return proyecto.Name;
      } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
    
    @AuraEnabled 
    public static List<BatchWrapper> getBatchList (string Idproyecto) {
        Proyecto__c proyecto = null; 

        try{
            List<CEN_ResponseContentVisorLotes> responseList = new List<CEN_ResponseContentVisorLotes>();
            List<BatchWrapper> bws = new List<BatchWrapper>();

            proyecto = [
            SELECT Id, Name, CEN_CODIGOSAP__c, Zona__c
            FROM Proyecto__c
            WHERE Id = :Idproyecto
            LIMIT 1
            ];

            responseList = CEN_ConsultVisorLotes.ByProyect(proyecto.CEN_CODIGOSAP__c);
            if(responseList != null && responseList.size() > 0){
             
              for(CEN_ResponseContentVisorLotes resp : responseList){
                if(resp.Codestadolote == 'E' && resp.Codsituacionlote == 'NI'){
                  BatchWrapper bw = new BatchWrapper();
                  bw.Id = resp.Idlote;
                  bw.Desestadolote = cambiarEstadoLote(resp.Codestadolote);
                  bw.Codestadolote = resp.Codestadolote;
                  bw.Codsituacionlote = resp.Codsituacionlote;
                  bw.Descripcionlote = resp.Descripcionlote;
                  bw.Fecentrega = resp.Fecentrega;
                  bw.CodigoSAP = proyecto.CEN_CODIGOSAP__c;
                  bw.Manzana = resp.Manzana;
                  bw.Numeroletra = resp.Numeroletra;
                  bw.Proforma = resp.Proforma;
                  bws.add(bw);
                }
              }
            }

            return bws;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled(cacheable=false)
    public static String updateDeliveryDate(List<BatchWrapper> inArrayLotes, String inDeliverDate){
      String msg = '';
      CEN_FinancingObjectResponse resp;
      CEN_FinancingObjectRequest req = new CEN_FinancingObjectRequest();

      try{

        System.debug('inDeliverDate: ' + inDeliverDate);
        CEN_FinancingObjectRequest.ZRFC_OTC_MODIF_DATOS_FINANC_WS_element reqElement = new CEN_FinancingObjectRequest.ZRFC_OTC_MODIF_DATOS_FINANC_WS_element();
        List<CEN_FinancingObjectRequest.ZPROFORMA_S> items = new List<CEN_FinancingObjectRequest.ZPROFORMA_S>();
        CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEN reqData = new CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEN();
        CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEX reqDatax = new CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEX();
        CEN_FinancingObjectRequest.ZPROFORMA_S item;
      
        for(BatchWrapper lote : inArrayLotes){
          item = new CEN_FinancingObjectRequest.ZPROFORMA_S();
          System.debug('proforma: ' + lote.Proforma);
          item.PROFORMA = lote.Proforma;
          items.add(item);
        }

        System.debug('items: ' + items);
        reqElement.IT_PROFORMA = CEN_cls_Financiamiento.setProforma(items);

        reqData.NOMBRE_NOTARIO = '';
        reqData.LOCAL_REGISTRO = '';
        reqData.NUMERO_KARDEX = '';
        reqData.NO_PARTIDA = '';
        reqData.FECHA_ENTREGA_FISICA = inDeliverDate ;
    
        reqDatax.NOMBRE_NOTARIO = '';
        reqDatax.LOCAL_REGISTRO = '';
        reqDatax.NUMERO_KARDEX = '';
        reqDatax.NO_PARTIDA = '';
        reqDatax.FECHA_ENTREGA_FISICA = 'X';

        reqElement.IS_MODIF_DATOS_FINANCIAMIENTO = reqData;
        reqElement.IS_MODIF_DATOS_FINANCIAMIENTOX = reqDatax;

        req.ZRFC_OTC_MODIF_DATOS_FINANC_WS = reqElement;

        if(resp == null ){
          resp = new CEN_FinancingObjectResponse();
          resp = CEN_cls_Financiamiento.updateFinancing(req);
        }

      } catch (Exception ex) { 
        //return msg = 'error: ' + e.getMessage(); 
        resp = new CEN_FinancingObjectResponse();
        CEN_FinancingObjectResponse.BAPIRET2_T respError = new CEN_FinancingObjectResponse.BAPIRET2_T();
        List<CEN_FinancingObjectResponse.BAPIRET2> respErrorList = new List<CEN_FinancingObjectResponse.BAPIRET2>();
        CEN_FinancingObjectResponse.BAPIRET2 respErrorDetails = new CEN_FinancingObjectResponse.BAPIRET2();
        respErrorDetails.TYPE_x ='dataErrorCatch';
        respErrorDetails.MESSAGE = ex.getMessage()+', en la linea: '+ex.getLineNumber();
        respErrorList.add(respErrorDetails);
        respError.item = respErrorList;
        resp.ET_RETURN = respError;
      }

      System.debug('***OUT CEN_cls_Financiamiento.setUpdateFinancing***');

      if(resp != null && resp.E_OK == 'X'){
        msg = inArrayLotes.size() > 1 ? 'Se actualizaron ' + inArrayLotes.size() + ' financiamientos' : 'Se actualizó ' + inArrayLotes.size() + ' financiamiento';
      }


      return msg;
    }

    private static String cambiarEstadoLote(String estadoLote) {
        estadoLote = estadoLote.toUpperCase();
        switch on estadoLote {
          when 'E' {
            return 'Entregado';
          }
          when 'B' {
            return 'Borrado';
          }
          when 'L' {
            return 'Libre';
          }
          when 'Q' {
            return 'Bloqueado';
          }
          when 'C' {
            return 'Vendido';
          }
          when 'R' {
            return 'Reservado';
          }
          when else {
            return estadoLote;
          }
        }
      }
}