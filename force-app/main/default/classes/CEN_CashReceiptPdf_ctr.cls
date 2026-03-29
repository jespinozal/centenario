/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-07
* @description: Clase de controladora para la generación de PDF del informe
*               de constancia de recepcion de efectivo en caseta.
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-07           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_CashReceiptPdf_ctr {
  
  public String writeToday;

  public Proyecto__c proyecto;
  public Attachment logoProyecto;

  public Opportunity oportunidads;
  public Account cliente;
  public String tipoDocumento;
  public String documento;
  public String telefono;

  public CEN_PaymentOrder__c paymentOrder;
  public List<CEN_PaymentOrder__c> lstPaymentOrder;
  public Double totalAmount = 0;

  public Quote cotizacion;
  public List<QuoteLineItem> lotesCotizados;
  public String montoFinanciar; 
  public String numCuotas; 
  public String montoCuotas;

  public Decimal inicial;
  public Decimal inicialPorcentage;
  public Double numeroCuotaInicial;
  public Decimal montoCuotaInicial;
  public Decimal montoFraccionar;
  public Double numeroCuota;
  public Decimal tasaInteresCompensatorio;
  public Decimal montoCuota;
  public Opportunity oportunidadsd;

  public CEN_CashReceiptPdf_ctr(
    ApexPages.StandardController controller
  ) {
    Id proyectoId = null;
    proyecto = new Proyecto__c();
    logoProyecto = new Attachment();
    oportunidads = new Opportunity();
    cliente = new Account();
    paymentOrder = new CEN_PaymentOrder__c();
    lstPaymentOrder = new List<CEN_PaymentOrder__c>();
    cotizacion = new Quote();
    lotesCotizados = new List<QuoteLineItem>();
    
    //Fecha de HOY
    DateTime dt = Datetime.now();
    Integer day = dt.day();
    Integer month = dt.month();
    Integer year =dt.year();
    Map<Integer, String> spanishDates = new Map<Integer, String>();
    spanishDates.put(1, 'Enero');
    spanishDates.put(2, 'Febrero');
    spanishDates.put(3, 'Marzo');
    spanishDates.put(4, 'Abril');
    spanishDates.put(5, 'Mayo');
    spanishDates.put(6, 'Junio');
    spanishDates.put(7, 'Julio');
    spanishDates.put(8, 'Agosto');
    spanishDates.put(9, 'Septiembre');
    spanishDates.put(10, 'Octubre');
    spanishDates.put(11, 'Noviembre');
    spanishDates.put(12, 'Diciembre');
    writeToday = String.valueOf(day)+' de ' +spanishDates.get(month)+' de '+String.valueOf(year);

    //Get recordId
    Id recordId = controller.getRecord().Id;
    System.debug(LoggingLevel.INFO, recordId);

    paymentOrder = [
      SELECT
      Name,
      CEN_Amount__c, 
      CEN_Opportunity__c, 
      CEN_PaymentDate__c,
      CreatedDate
      FROM CEN_PaymentOrder__c
      WHERE Id = :recordId
    ];
    System.debug(LoggingLevel.INFO, paymentOrder);

    String idOpp = paymentOrder.CEN_Opportunity__c;
    System.debug(LoggingLevel.INFO, idOpp);

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
        CEN_fld_anotaciones__c,
        CEN_Precio_de_venta_con_descuento__c,
        CEN_Cuota_Facilote__c,
        OpportunityId
      FROM Quote
      WHERE OpportunityId = :idOpp
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    System.debug(LoggingLevel.INFO, cotizacion);

    oportunidads = [
      SELECT
      CEN_Tipo_de_venta__c,
      CEN_Monto_Cuota_del_Saldo_de_precio__c,
      AccountId,
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
      WHERE Id = :idOpp
    ];

    oportunidadsd = [
      SELECT
      toLabel(CEN_Tipo_de_venta__c)
      FROM Opportunity
      WHERE Id = :idOpp
    ];
    System.debug(LoggingLevel.INFO, oportunidads);

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
      WHERE Id =: oportunidads.AccountId
    ];
    System.debug(LoggingLevel.INFO, cliente);
    documento = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.CEN_N_mero_de_documento__pc : cliente.CEN_Numero_de_documento_del__c;
    telefono = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.PersonMobilePhone : cliente.Phone;
    tipoDocumento = cliente.RecordType.DeveloperName == 'PersonAccount' ? cliente.CEN_Tipo_de_documento__pc : cliente.CEN_Tipo_de_documento__c;

    lstPaymentOrder = [
      SELECT
      CEN_Amount__c, 
      CEN_Opportunity__c, 
      CEN_PaymentDate__c,
      CreatedDate
      FROM CEN_PaymentOrder__c
      WHERE CEN_Opportunity__c = :idOpp 
      AND (Id =: recordId OR CEN_PaymentStatus__c = 'Pagado' OR CEN_PaymentStatus__c = 'PendienteSAP')
      ORDER BY CEN_PaymentDate__c ASC
    ];
    System.debug(LoggingLevel.INFO, lstPaymentOrder);
    
    for(CEN_PaymentOrder__c p: lstPaymentOrder){
      totalAmount = totalAmount + p.CEN_Amount__c;
    }

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
      WHERE QuoteId = :cotizacion.Id
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
        SELECT Id, Name
        FROM Proyecto__c
        WHERE Id = :proyectoId
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
      System.debug(LoggingLevel.INFO, logoProyecto);
      
    }

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

  public String getMontoFinanciar(){
    System.debug(LoggingLevel.INFO, montoFinanciar);
    return this.montoFinanciar;
  }

  public String getNumCuotas(){
    System.debug(LoggingLevel.INFO, numCuotas);
    return this.numCuotas;
  }

  public String getMontoCuotas(){
    System.debug(LoggingLevel.INFO, montoCuotas);
    return this.montoCuotas;
  }
  
  public Double getTotalAmount(){
    System.debug(LoggingLevel.INFO, totalAmount);
    return this.totalAmount;
  }

  public String getWriteToday(){
    System.debug(LoggingLevel.INFO, writeToday);
    return this.writeToday;
  }

  public Attachment getLogoProyecto() {
    System.debug(LoggingLevel.INFO, logoProyecto);
    return this.logoProyecto;
  }
  public Proyecto__c getProyecto() {
    System.debug(LoggingLevel.INFO, proyecto);
    return this.proyecto;
  }

  public Opportunity getOportunidads() {
    System.debug(LoggingLevel.INFO, oportunidads);
    return this.oportunidads;
  }

  public Account getCliente() {
    System.debug(LoggingLevel.INFO, cliente);
    return this.cliente;
  }

  public String getTelefono(){
    System.debug(LoggingLevel.INFO, telefono);
    return this.telefono;
  }

  public String getDocumento(){
    System.debug(LoggingLevel.INFO, documento);
    return this.documento;
  }

  public String getTipoDocumento(){
    System.debug(LoggingLevel.INFO, tipoDocumento);
    return this.tipoDocumento;
  }

  public CEN_PaymentOrder__c getPaymentOrder() {
    System.debug(LoggingLevel.INFO, paymentOrder);
    return this.paymentOrder;
  }

  public List<CEN_PaymentOrder__c> getLstPaymentOrder() {
    System.debug(LoggingLevel.INFO, lstPaymentOrder);
    return this.lstPaymentOrder;
  }

  public Quote getCotizacion() {
    System.debug(LoggingLevel.INFO, cotizacion);
    return this.cotizacion;
  }

  public List<QuoteLineItem> getLotesCotizados() {
    System.debug(LoggingLevel.INFO, lotesCotizados);
    return this.lotesCotizados;
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
  public Opportunity getOportunidadsd() {
    System.debug(LoggingLevel.INFO, oportunidadsd);
    return this.oportunidadsd;
  }

}