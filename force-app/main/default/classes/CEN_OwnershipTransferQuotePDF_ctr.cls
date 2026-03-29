/**
 * @description       : Genera el pdf cotizador para la transferencia de la titularidad.
 * @author            : augusto.nayib.tamayo.bedregal@nttdata.com
 * @group             : 
 * @last modified on  : 07-01-2021
 * @last modified by  : @nttdata.com
 * Test Class         :CEN_OwnershipTransferQuotePDF_tst
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-01-2021   @nttdata.com   Initial Version
**/
public class CEN_OwnershipTransferQuotePDF_ctr {
    public Proyecto__c proyecto;
    public Attachment logoProyecto;
    public Opportunity oportunidads;
    public Opportunity oportunidadsd;
    public Account cliente;
    public String tipoDocumento;
    public String documento;
    public String telefono;
    public Quote cotizacion;
    public List<QuoteLineItem> lotesCotizados;
    //public List<fCEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones;
  
    public class FormaPago {
      public String valor { get; private set; }
      public List<DetalleFormaPago> detallesFormaPago { get; private set; }
    }
    public class DetalleFormaPago {
      public String valor { get; private set; }
    }
    public String montoFinanciar; 
    public String numCuotas; 
    public String montoCuotas;
    public Integer diaMaxPago;
    public Integer diaMaxFirma;
    public String fechaCierre;
    public String writeToday;
    public String writeTodayB;

    public Decimal inicial;
    public Decimal inicialPorcentage;
    public Double numeroCuotaInicial;
    public Decimal montoCuotaInicial;
    public Decimal montoFraccionar;
    public Double numeroCuota;
    public Decimal tasaInteresCompensatorio;
    public Decimal montoCuota;
  
    public CEN_OwnershipTransferQuotePDF_ctr(
      ApexPages.StandardController controller
    ) {
     // anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
      //lotesCotizados = new List<QuoteLineItem>();
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
        WHERE Id = :recordId
      ];
      System.debug(LoggingLevel.INFO, cotizacion);
      String idCotizacion = cotizacion.OpportunityId;

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
        Account.name,
        CEN_Proyecto__c
        FROM Opportunity
        WHERE Id = :idCotizacion
    ];
  
      oportunidadsd = [
        SELECT
        toLabel(CEN_Tipo_de_venta__c)
        FROM Opportunity
        WHERE Id = :idCotizacion
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
        WHERE Id =: cotizacion.AccountId
      ];
  
      proyecto = [
        SELECT Id,Name,CEN_MaximumPaymentDuePeriod__c,CEN_MaximumTermForSigningTheContract__c
        FROM Proyecto__c
        WHERE Id = : oportunidads.CEN_Proyecto__c
        LIMIT 1
      ];
      System.debug(LoggingLevel.INFO, proyecto);
      try {
        logoProyecto = [
          SELECT Id, Name, ParentId
          FROM Attachment
          WHERE ParentId = :proyecto.id
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

      lotesCotizados = [
      SELECT
        Id,        
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
      //Fecha de HOY
      DateTime dt = Datetime.now();
      Integer day = dt.day();
      Integer year =dt.year();
      writeToday = String.valueOf(day)+' de ';
      writeTodayB = ' de '+String.valueOf(year);    
  
      fechaCierre = oportunidads.CloseDate.format();
      Date createdDated = Date.today();
      Integer numberOfDays = Date.daysInMonth(createdDated.year(), createdDated.month());
      Date lastDayOfMonth = Date.today().addMonths(1).toStartofMonth().addDays(-1);
      Integer remainingDays = createdDated.daysBetween(lastDayOfMonth);
      diaMaxPago =  remainingDays>=proyecto.CEN_MaximumPaymentDuePeriod__c.intValue() ? proyecto.CEN_MaximumPaymentDuePeriod__c.intValue() : remainingDays;
      diaMaxFirma = remainingDays>=proyecto.CEN_MaximumTermForSigningTheContract__c.intValue() ? proyecto.CEN_MaximumTermForSigningTheContract__c.intValue() : remainingDays;
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
  
    public String getfechaCierre(){
      System.debug(LoggingLevel.INFO, fechaCierre);
      return this.fechaCierre;
    }
  
    public Integer getdiaMaxPago(){
      System.debug(LoggingLevel.INFO, diaMaxPago);
      return this.diaMaxPago;
    }
  
    public Integer getdiaMaxFirma(){
      System.debug(LoggingLevel.INFO, diaMaxFirma);
      return this.diaMaxFirma;
    }
  
    public String getWriteToday(){
      System.debug(LoggingLevel.INFO, writeToday);
      return this.writeToday;
    }
  
    public String getWriteTodayB(){
      System.debug(LoggingLevel.INFO, writeTodayB);
      return this.writeTodayB;
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
  
    public Opportunity getOportunidadsd() {
      System.debug(LoggingLevel.INFO, oportunidadsd);
      return this.oportunidadsd;
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
  
    /*
     * obtener las precisiones y beneficios segun los metadatados configurados
     */
    public List<CEN_cmt_precisionesYObeneficios__mdt> getPrecisionesYObeneficios() {
      List<CEN_cmt_precisionesYObeneficios__mdt> precisionesYObeneficios = [
        SELECT Id, Label, DeveloperName, CEN_fld_activo__c, CEN_fld_descripcion__c
        FROM CEN_cmt_precisionesYObeneficios__mdt
        WHERE CEN_fld_activo__c = TRUE
        ORDER BY DeveloperName ASC
      ];
      return precisionesYObeneficios;
    }
  
    /*
     * obtener los terminos y condiciones segun los metadatados configurados
     */
    public List<CEN_cmt_terminosYcondiciones__mdt> getTerminosYcondiciones() {
      List<CEN_cmt_terminosYcondiciones__mdt> terminosYcondiciones = [
        SELECT Id, Label, DeveloperName, CEN_fld_activo__c, CEN_fld_descripcion__c
        FROM CEN_cmt_terminosYcondiciones__mdt
        WHERE CEN_fld_activo__c = TRUE
        ORDER BY DeveloperName ASC
      ];
      return terminosYcondiciones;
    }
    
  
    /*
     * obtener detalles de forma de pago segun los metadatados configurados
     */
    public List<FormaPago> getFormasDePagoMasDetalles() {
      List<FormaPago> listaFormaPago = new List<FormaPago>();
      Map<String, List<DetalleFormaPago>> mapListaDetalles = new Map<String, List<DetalleFormaPago>>();
      List<CEN_cmt_formasPago__mdt> listaFormasPagoCMT = new List<CEN_cmt_formasPago__mdt>();
      List<CEN_cmt_detallesFormaPago__mdt> detallesFormaPagosCMT = new List<CEN_cmt_detallesFormaPago__mdt>();
  
      listaFormasPagoCMT = [
        SELECT Id, DeveloperName, Label, CEN_fld_activo__c
        FROM CEN_cmt_formasPago__mdt
        WHERE CEN_fld_activo__c = TRUE
        ORDER BY DeveloperName ASC
      ];
      detallesFormaPagosCMT = [
        SELECT
          Id,
          CEN_fld_valorDetalle__c,
          CEN_fld_activo__c,
          CEN_fld_formaPago__c,
          Label,
          DeveloperName
        FROM CEN_cmt_detallesFormaPago__mdt
        WHERE CEN_fld_activo__c = TRUE
        ORDER BY DeveloperName ASC
      ];
  
      
  
      //	clasificar los detalles de pago por la Forma de Pago
      for (CEN_cmt_detallesFormaPago__mdt detalle : detallesFormaPagosCMT) {
        List<DetalleFormaPago> listaDetalles = new List<DetalleFormaPago>();
        DetalleFormaPago obj = new DetalleFormaPago();
        obj.valor = detalle.CEN_fld_valorDetalle__c;
        if (mapListaDetalles.keySet().contains(detalle.CEN_fld_formaPago__c)) {
          listaDetalles = mapListaDetalles.get(detalle.CEN_fld_formaPago__c);
          listaDetalles.add(obj);
          mapListaDetalles.put(detalle.CEN_fld_formaPago__c, listaDetalles);
        } else {
          listaDetalles.add(obj);
          mapListaDetalles.put(detalle.CEN_fld_formaPago__c, listaDetalles);
        }
      }
      //	clasificar por formas de pago y enlistar para devolver
      for (CEN_cmt_formasPago__mdt obj : listaFormasPagoCMT) {
        FormaPago objFormaPago = new FormaPago();
        objFormaPago.valor = obj.Label;
        objFormaPago.detallesFormaPago = new List<DetalleFormaPago>();
        if (mapListaDetalles.keySet().contains(obj.Id)) {
          objFormaPago.detallesFormaPago.addAll(mapListaDetalles.get(obj.Id));
        }
        listaFormaPago.add(objFormaPago);
      }
      return listaFormaPago;
    }
}