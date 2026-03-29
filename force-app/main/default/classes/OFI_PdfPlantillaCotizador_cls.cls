public  class OFI_PdfPlantillaCotizador_cls {
    public List<QuoteLineItem> lotList;
    public List<QuoteLineItem>  uniqueOffice;
    public Quote q;
    public Account acc;
    public String divisa;

    public OFI_PdfPlantillaCotizador_cls( ApexPages.StandardController controller) {
      System.debug(1);
        Id recordId = controller.getRecord().Id;
System.debug(recordId);
        System.debug(LoggingLevel.INFO, recordId); 
System.debug(3);
        uniqueOffice = [SELECT Product2.OFI_fld_Product2_DescUnidadEconomica__c, Product2.OFI_fld_Product2_DescEdificio__c FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];
System.debug(uniqueOffice[0]);
        q = [
        SELECT
          Id,
          QuoteNumber,
          CreatedDate,
          CEN_Area__c,
          CEN_Precio_por_mt2__c,
          CEN_Inicial__c,
          CEN_Cuota_inicial__c,
          CEN_N_cuotas_de_inicial_de_precio__c,
          CEN_Saldo_del_precio__c,
          CEN_Inicial_porct__c,
          CEN_Numero_de_cuentas_inicial__c,
          CEN_Lote__c,
          CEN_Precio_de_venta__c,
          CEN_Tipologia__c,
          CEN_Manzana__c,
          CEN_Tasa_de_Interes_compensatorio_anual__c,
          CEN_Numero_de_cuotas_a_financiar__c,
          CEN_Monto_cuota_de_inicial_de_precio__c,
          CEN_Monto_cuota_del_saldo_de_precio__c,
          OFI_fld_Quote_InformacionAdicional__c,
          CEN_Saldo_capital_a_financiar__c,
          CEN_fld_nombres__c,
          CEN_fld_apellidos__c,
          toLabel(CEN_fld_tipoDocumento__c),
          CEN_fld_nroDocumento__c,
          CEN_fld_celular__c,
          CEN_fld_anotaciones__c,
          CEN_Precio_de_venta_con_descuento__c,
          CEN_Cuota_Facilote__c,
          OpportunityId,
          AccountId,
          CEN_FirstInstallmentAmount__c,
          CEN_Moneda__c,
          CEN_N_cuotas_del_saldo_de_precio__c,
          CEN_FinanciamientoCuotasRestantes__c,
          toLabel(CEN_TypeOfSale__c),
          OFI_fld_Quote_PlazoForzoso__c,
          OFI_fld_Quote_IncrementosAnuales__c,
          OFI_fld_Quote_Garantias__c,
          ONI_fld_Quote_Moneda__c,
          OFI_fld_Quote_GastosCondominio__c,
          OFI_fld_Quote_PeriodoGraciaRenta__c,
          IND_fld_Cotizacion_Condiciones__c,
          ONI_fld_Quote_Lead__c
        FROM Quote
        WHERE Id = :recordId
      ];
        
        lotList = [
        SELECT
          Id,
          Product2Id,
          Product2.Name,
          Product2.OFI_fld_Product2_DescUnidadEconomica__c,
          Product2.OFI_fld_Product2_DescEdificio__c,
          Product2.OFI_fld_Product2_Piso__c,
          Product2.OFI_fld_Product2_BaseMedida__c,
          Product2.OFI_fld_Product2_DenominacionTipoMedida__c,
          Product2.CEN_Proyecto__c,
          Product2.MANZANA__c,
          Product2.CEN_NUM_LOTE__c,
          Product2.CEN_TIPOLOGIA__c,
          Product2.AREA__c,
          CEN_manzana_del_lote__c,
          CEN_lote__c,
          CEN_tipologia_del_lote__c,
          CEN_area_del_lote__c,
          CEN_fld_precioVentaDscto__c,
          CEN_precio_venta_cotizado_lote__c,
          CEN_precio_m2_cotizado_lote__c
          
        FROM QuoteLineItem
        WHERE QuoteId = :recordId
        ORDER BY Product2.Name DESC
      ];

      List<Lead> leads;
      if (String.isBlank(q.ONI_fld_Quote_Lead__c)) {
        acc = [
        SELECT
          Id,
          Name,
          CEN_Tipo_de_documento__pc,
          CEN_Tipo_de_documento__c,
          CEN_N_mero_de_documento__pc,
          CEN_Numero_de_documento_del__c,
          PersonMobilePhone,
          Phone,
          RecordType.DeveloperName
        FROM Account
        WHERE Id =: q.AccountId
      ];
      }else{
        leads = [SELECT Name, Company FROM Lead WHERE Id = :q.ONI_fld_Quote_Lead__c LIMIT 1];
        if (!leads.isEmpty()) {
          Lead ld = leads[0];
          acc = new Account(
            Name = String.isNotBlank(ld.Company) ? ld.Company : ld.Name
          );
        } else {
          acc = new Account(Name = 'Cliente');
        }
      }
      divisa = q.ONI_fld_Quote_Moneda__c != null ? q.ONI_fld_Quote_Moneda__c : '';
    }

    public String getDivisa() {
      System.debug(LoggingLevel.INFO, divisa);
      return this.divisa;
    }

    public List<QuoteLineItem> getLotList() {
      System.debug(LoggingLevel.INFO, lotList);
      return this.lotList;
    }

    public Account getAccount() {
      System.debug(LoggingLevel.INFO, acc);
      return this.acc;
    }

    public Quote getQuote() {
      System.debug(LoggingLevel.INFO, q);
      return this.q;
    }

    public Quote getCotizacion() {
      System.debug(LoggingLevel.INFO, q);
      return this.q;
    }

    public String getUnidadNegocio(){
      System.debug(this.uniqueOffice[0].Product2.OFI_fld_Product2_DescUnidadEconomica__c);
      return this.uniqueOffice[0].Product2.OFI_fld_Product2_DescUnidadEconomica__c;
    }

    public String getImagenUrl(){
      String nombreRecurso = this.uniqueOffice[0].Product2.OFI_fld_Product2_DescEdificio__c;
      return String.isNotBlank(nombreRecurso) ? nombreRecurso.replace(' ', '') : 'RealDoce';
    }

    public String getFecha(){
      DateTime dt = q.CreatedDate;
    Date fecha = dt.date(); // ← método correcto
    
    Integer day = fecha.day();
    Integer year = fecha.year();
    
    String[] meses = new String[]{'', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};
    
    String month = meses[fecha.month()];
    
    return day + ' de ' + month + ' de ' + year;
    }

    // public List<Map<String,Object>> getCondiciones(){
    //   // String plano = q.IND_fld_Cotizacion_Condiciones__c;
    //   // List<Map<String,Object>> condiciones = new List<Map<String,Object>>();
    //   // List<Map<String,Object>> jsonList = (List<Map<String,Object>>) JSON.deserialize(plano, List<Map<String,Object>>.class);
    //   // return jsonList;
    //   if(String.isBlank(q.IND_fld_Cotizacion_Condiciones__c)){
    //     return new List<Map<String,Object>>();
    //   } 
    //   return (List<Map<String,Object>>)JSON.deserializeUntyped(q.IND_fld_Cotizacion_Condiciones__c);
    // }
    public List<Map<String, Object>> getCondiciones() {
      if (String.isBlank(q.IND_fld_Cotizacion_Condiciones__c)) {
          return new List<Map<String, Object>>();
      }

      // Esta es la forma correcta y que NUNCA falla
      List<Object> tempList = (List<Object>) JSON.deserializeUntyped(q.IND_fld_Cotizacion_Condiciones__c);
      List<Map<String, Object>> condiciones = new List<Map<String, Object>>();
      
      for (Object obj : tempList) {
          condiciones.add((Map<String, Object>) obj);
      }
      
      return condiciones;
    }

    private String getValorCondicion(String descripcionBuscada) {
      List<Map<String, Object>> condiciones = this.getCondiciones();
      for (Map<String, Object> condicion : condiciones) {
          String description = (String) condicion.get('description');
          if (descripcionBuscada.equalsIgnoreCase(description)) {
              return (String) condicion.get('value');
          }
      }
      return null;
    }

    public String getPlazoForzoso() {
      return getValorCondicion('Plazo Forzoso');
    }
    public String getIncrementosAnuales() {
      return getValorCondicion('Incrementos Anuales');
    }
    public String getGarantia() {
      return getValorCondicion('Garantías (Fianza)');
    }
    public String getGastosCondominio() {
      return getValorCondicion('Gastos de Condominio');
    }
    public String getPeriodoGracia() {
      return getValorCondicion('Periodo de Gracia de Renta');
    }
    public String getPlazoVoluntario() {
      return getValorCondicion('Plazo Voluntario');
    }
    public String getInformacionAdicional() {
      return getValorCondicion('Información Adicional');
    }

    public Boolean getIsPlazoForzoso(){
      return this.getPlazoForzoso() != null && this.getPlazoForzoso()!='';
    }
    public Boolean getIsIncrementosAnuales(){
      return this.getIncrementosAnuales() != null && this.getIncrementosAnuales()!='';
    }
    public Boolean getIsGarantia(){
      return this.getGarantia() != null && this.getGarantia()!='';
    }
    public Boolean getIsGastosCondominio(){
      return this.getGastosCondominio() != null && this.getGastosCondominio()!='';
    }
    public Boolean getIsPeriodoGracia(){
      return this.getPeriodoGracia() != null && this.getPeriodoGracia()!='';
    }
    public Boolean getIsPlazoVoluntario(){
      return this.getPlazoVoluntario() != null && this.getPlazoVoluntario()!='';
    }
    public Boolean getIsInformacionAdicional(){
      return this.getInformacionAdicional() != null && this.getInformacionAdicional()!='';
    }

    public Boolean   getIsMoreThanFour(){
      return lotList.size() > 4;
    }

    public Boolean   getIsLessThanThree(){
      return lotList.size() < 3;
    }
}