/*
 * Name: CEN_cls_pdfInformativeTotalPayment_ccvf
 * Version: 1.0
 * Descripción: Controlador para Documento Informativo de Pago Total para la firma de contrato
 * Fecha: 28/06/2020
 * TestClass: CEN_InformativePayments_test
 */
public class CEN_cls_pdfInformativeTotalPayment_vf {
    public List<CEN_PaymentOrder__c> payments;
    public Account cliente;
    public Proyecto__c proyecto;
    public Attachment logoProyecto;
    public Opportunity oportunidads;
    public Opportunity oportunidadsd;
    public Quote cotizacion;
    public List<QuoteLineItem> lotesCotizados;
    public List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones;
    public String montoFinanciar; 
    public String numCuotas; 
    public String montoCuotas;
    public String writeToday;
    public String writeTodayB;
    public Decimal montoPagarContrato = 0;
    public Decimal cuotaFacilote;
    public String tipoDocumento;
    public String documento;
    public String telefono;

    public Decimal inicial;
    public Decimal inicialPorcentage;
    public Double numeroCuotaInicial;
    public Decimal montoCuotaInicial;
    public Decimal montoFraccionar;
    public Double numeroCuota;
    public Decimal tasaInteresCompensatorio;
    public Decimal montoCuota;
  
    public CEN_cls_pdfInformativeTotalPayment_vf(ApexPages.StandardController controller ) {
      Id proyectoId = null;
      anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
      lotesCotizados = new List<QuoteLineItem>();
      proyecto = new Proyecto__c();
      logoProyecto = new Attachment();
      cotizacion = new Quote();
  
      //	Get recordId
      Id recordId = controller.getRecord().Id;
      System.debug(LoggingLevel.INFO, recordId);   
  
      cotizacion = [
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
          toLabel(CEN_Moneda__c)
        FROM Quote
        WHERE OpportunityId =: recordId
        ORDER BY CreatedDate DESC LIMIT 1
      ];
      System.debug(LoggingLevel.INFO, cotizacion);
      String idOportunidad = cotizacion.OpportunityId;

      cliente = [
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
      WHERE Id =: cotizacion.AccountId
      ];

      payments = [ SELECT	
        CEN_Amount__c, 
        CEN_PaymentDate__c,
        CEN_CreationDateFrom__c
      FROM CEN_PaymentOrder__c
      WHERE CEN_Opportunity__c =: idOportunidad
      AND CEN_PaymentStatus__c IN ('Pagado','Procesando')
      ORDER BY CEN_PaymentDate__c ASC];

      for(CEN_PaymentOrder__c payment : payments){
        montoPagarContrato = montoPagarContrato + payment.CEN_Amount__c;
      }

      oportunidads = [
        SELECT
        CEN_Tipo_de_venta__c,
        CEN_Monto_Cuota_del_Saldo_de_precio__c,
        CEN_Monto_cuota_de_inicial_de_precio__c,
        CEN_fld_totalPrecioVentaDscto__c,
        CEN_AmountFeeFacilitate__c,
        CEN_MaximumPaymentDate__c,
        CEN_N_Cuotas_de_inicial_de_precio__c,
        CEN_N_Cuotas_del_Saldo_del_precio__c,
        CreatedDate,
        CloseDate,
        Account.name
        FROM Opportunity
        WHERE Id =: idOportunidad
      ];
  
      oportunidadsd = [
        SELECT
        toLabel(CEN_Tipo_de_venta__c)
        FROM Opportunity
        WHERE Id =: idOportunidad
      ];
      System.debug(LoggingLevel.INFO, oportunidads);
      
      lotesCotizados = [
        SELECT
          Id,
          Product2Id,
          Product2.CEN_Proyecto__c,
          CEN_manzana_del_lote__c,
          CEN_lote__c,
          CEN_tipologia_del_lote__c,
          CEN_area_del_lote__c,
          CEN_fld_precioVentaDscto__c,
          CEN_precio_venta_cotizado_lote__c
        FROM QuoteLineItem
        WHERE QuoteId =: cotizacion.Id
        ORDER BY LineNumber ASC
      ];
      System.debug(LoggingLevel.INFO, lotesCotizados);
      if(lotesCotizados.size() > 0){
        for (QuoteLineItem qli : lotesCotizados) {
          if (qli.Product2Id != null && qli.Product2.CEN_Proyecto__c != null) {
            proyectoId = qli.Product2.CEN_Proyecto__c;
            break;
          }
        }
        proyecto = [
          SELECT Id,Name,CEN_MaximumPaymentDuePeriod__c,CEN_MaximumTermForSigningTheContract__c
          FROM Proyecto__c
          WHERE Id =: proyectoId
          LIMIT 1
        ];
        System.debug(LoggingLevel.INFO, proyecto);
        try {
          logoProyecto = [
            SELECT Id, Name, ParentId
            FROM Attachment
            WHERE ParentId = :proyectoId
            ORDER BY CreatedDate DESC
            LIMIT 1
          ];
        } catch (Exception ex) {
          System.debug(
            LoggingLevel.ERROR,
            ex.getMessage() +
            '. ' +
            ex.getLineNumber()
          );
        }
      }
      //Fecha de HOY
      DateTime dt = Datetime.now();
      Integer day = dt.day();
      Integer year =dt.year();
      writeToday = String.valueOf(day)+' de ';
      writeTodayB = ' de '+String.valueOf(year); 

      cuotaFacilote = cotizacion.CEN_Cuota_Facilote__c ? oportunidads.CEN_AmountFeeFacilitate__c : cotizacion.CEN_Monto_cuota_del_saldo_de_precio__c;
      documento = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.CEN_N_mero_de_documento__pc : cliente.CEN_Numero_de_documento_del__c;
      telefono = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.PersonMobilePhone : cliente.Phone;
      tipoDocumento = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.CEN_Tipo_de_documento__pc : cliente.CEN_Tipo_de_documento__c;

      switch on oportunidads.CEN_Tipo_de_venta__c {
        when 'CO' {
          montoFinanciar = 'MONTO A FINANCIAR';
          numCuotas = 'NÚMERO DE CUOTAS';
          montoCuotas = 'MONTO DE LAS CUOTAS';
          inicial = 0;
          inicialPorcentage = 0;
          numeroCuotaInicial = 0;
          montoCuotaInicial = 0;
          montoFraccionar = 0;
          numeroCuota = 0;
          tasaInteresCompensatorio = 0;
          montoCuota = 0;
        }
        when 'CD' {
          montoFinanciar = 'MONTO A FINANCIAR';
          numCuotas = 'NÚMERO DE CUOTAS DEL FINANCIAMIENTO';
          montoCuotas = 'MONTO DE LAS CUOTAS DEL FINANCIAMIENTO (CAPITAL + INTERESES)';
          inicial = Cotizacion.CEN_Inicial__c;
          inicialPorcentage = Cotizacion.CEN_Inicial_porct__c;
          numeroCuotaInicial = Cotizacion.CEN_N_cuotas_de_inicial_de_precio__c;
          montoCuotaInicial = Cotizacion.CEN_Monto_cuota_de_inicial_de_precio__c;
          montoFraccionar = Cotizacion.CEN_Saldo_del_precio__c;
          numeroCuota = Cotizacion.CEN_Numero_de_cuotas_a_financiar__c;
          tasaInteresCompensatorio = Cotizacion.CEN_Tasa_de_Interes_compensatorio_anual__c;
          montoCuota = Cotizacion.CEN_Monto_cuota_del_saldo_de_precio__c;
        }
        when 'CS' {
          montoFinanciar = 'MONTO A FRACCIONAR';
          numCuotas = 'NÚMERO DE CUOTAS DEL FRACCIONAMIENTO';
          montoCuotas = 'MONTO DE LAS CUOTAS DEL FRACCIONAMIENTO';
          inicial = 0;
          inicialPorcentage = 0;
          numeroCuotaInicial = 0;
          montoCuotaInicial = 0;
          montoFraccionar = oportunidads.CEN_fld_totalPrecioVentaDscto__c;
          numeroCuota = oportunidads.CEN_N_Cuotas_de_inicial_de_precio__c + oportunidads.CEN_N_Cuotas_del_Saldo_del_precio__c;
          tasaInteresCompensatorio = 0;
          montoCuota = oportunidads.CEN_Monto_cuota_de_inicial_de_precio__c;
        }
      }
      
    }

    public Account getCliente() {
      return this.cliente;
    }

    public String getTelefono(){
      return this.telefono;
    }
  
    public String getDocumento(){
      return this.documento;
    }
  
    public String getTipoDocumento(){
      return this.tipoDocumento;
    }
    
    public String getMontoFinanciar(){
      return this.montoFinanciar;
    }
  
    public String getNumCuotas(){
      return this.numCuotas;
    }
  
    public String getMontoCuotas(){
      return this.montoCuotas;
    }
   
    public String getWriteToday(){
      return this.writeToday;
    }
  
    public Attachment getLogoProyecto() {
      return this.logoProyecto;
    }
    public Proyecto__c getProyecto() {
      return this.proyecto;
    }
  
    public List<CEN_PaymentOrder__c> getPayments() {
      return this.payments;
    }

    public Opportunity getOportunidads() {
      return this.oportunidads;
    }
  
    public Opportunity getOportunidadsd() {
      return this.oportunidadsd;
    }
    public Quote getCotizacion() {
      return this.cotizacion;
    }

    public List<QuoteLineItem> getLotesCotizados() {
      return this.lotesCotizados;
    }
  
    public Decimal getMontoPagarContrato(){
      return this.montoPagarContrato;
    }

    public Decimal getCuotaFacilote(){
      return this.cuotaFacilote;
    }
    public Decimal getinicial(){
      System.debug(LoggingLevel.INFO, inicial);
      return this.inicial;
    }
    public Decimal getinicialPorcentage(){
      System.debug(LoggingLevel.INFO, inicialPorcentage);
      return this.inicialPorcentage;
    }
    public Double getNumeroCuotaInicial(){
      System.debug(LoggingLevel.INFO, numeroCuotaInicial);
      return this.numeroCuotaInicial;
    }
    public Decimal getMontoCuotaInicial(){
      System.debug(LoggingLevel.INFO, montoCuotaInicial);
      return this.montoCuotaInicial;
    }
    public Decimal getMontoFraccionar(){
      System.debug(LoggingLevel.INFO, montoFraccionar);
      return this.montoFraccionar;
    }
    public Double getNumeroCuota(){
      System.debug(LoggingLevel.INFO, numeroCuota);
      return this.numeroCuota;
    }
    public Decimal getTasaInteresCompensatorio(){
      System.debug(LoggingLevel.INFO, tasaInteresCompensatorio);
      return this.tasaInteresCompensatorio;
    }
    public Decimal getMontoCuota(){
      System.debug(LoggingLevel.INFO, montoCuota);
      return this.montoCuota;
    }
    public String getWriteTodayB(){
      System.debug(LoggingLevel.INFO, writeTodayB);
      return this.writeTodayB;
    }

  }