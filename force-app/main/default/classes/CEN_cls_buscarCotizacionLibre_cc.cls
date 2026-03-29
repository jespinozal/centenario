/*
 * Name: CEN_cls_buscarCotizacionLibre_cc
 * Version: 1.0
 * Descripción: clase controladora del componente CEN_cmp_buscarCotizacionLibreHelper
 * Fecha: 06/11/2020
 * TestClass: CEN_cls_buscarCotizacionLibre_test
 */
public class CEN_cls_buscarCotizacionLibre_cc {
  private static final String ERROR_BUSCANDO_LOTE_COTIZACION = 'Error buscando lotes en la cotización. ';
  private static final String ERROR_VALIDANDO_LOTE_COTIZACION = 'Error validando el lote en la cotización. ';
  private static final String ERROR_ASOCIANDO_COTIZACION_A_OPORTUNIDAD = 'Error al asociar la cotización a la oportunidad. ';
  
  @AuraEnabled
  public static Boolean validateStageNameOpp(String IdOportunidad) {
      Opportunity opp = [Select id, stagename from Opportunity where id =: IdOportunidad];
      Boolean resp = false;
      if(opp.stagename == 'Cotización'){
          resp = true;
      }
      return resp;
  }
    
  @AuraEnabled
  public static CEN_cls_utilsQuote.ListatipoDocumentoWrapper getListaTipoDocumentos() {
    return CEN_cls_utilsQuote.getListaTipoDocumentos();
  }
  //  obtener datos de la cuenta natural de la oportunidad
  @AuraEnabled
  public static InputBuscadorWrapper getDatosPersonaOportunidad( String idOportunidad ) {
    InputBuscadorWrapper response = null;
    try {
      Opportunity oportunidad = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE Id = :idOportunidad
      ];
      Account cuenta = [
        SELECT
          Id,
          Name,
          FirstName,
          LastName,
          CEN_Tipo_de_documento__pc,
          CEN_N_mero_de_documento__pc
        FROM Account
        WHERE Id = :oportunidad.AccountId
      ];
      response = new InputBuscadorWrapper();
      response.nombres = cuenta.FirstName;
      response.apellidos = cuenta.LastName;
      response.tipoDocumento = cuenta.CEN_Tipo_de_documento__pc;
      response.nroDocumento = cuenta.CEN_N_mero_de_documento__pc;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Exception: ' +
        e.getMessage() +
        '. Type: ' +
        e.getTypeName() +
        '. Line: ' +
        e.getLineNumber()
      );
    }
    return response;
  }

  private static String getQueryCotizaciones( InputBuscadorWrapper objInputBuscador) {
    String query = '';
    String filtros1 = '';
    String filtros2 = '';
    Date fechaCreacion = null;
    query = 'SELECT Id, QuoteNumber, TotalPrice, CEN_fld_apellidos__c, ' + 'CEN_fld_nombres__c, CEN_fld_nroDocumento__c, CEN_fld_celular__c, ' +
      'CEN_fld_Libre__c, CEN_fld_tipoDocumento__c, CEN_Area__c, Name, CreatedDate, ' +
      'LineItemCount, CEN_Precio_de_venta_con_descuento__c, CEN_Tipo_de_moneda__c ' +
      'FROM Quote WHERE CEN_fld_Libre__c=TRUE {{tag_filtros1}} {{tag_filtros2}} ORDER BY QuoteNumber ASC';

    if (String.isNotBlank(objInputBuscador.nroCotizacion)) { filtros1 += ' AND QuoteNumber LIKE \'%' + objInputBuscador.nroCotizacion.trim() + '%\''; }
    if (objInputBuscador.fechaCotizacion != null) {
      fechaCreacion = objInputBuscador.fechaCotizacion;
      filtros1 += ' AND (CEN_fld_fechaCreacion__c>=' + String.valueOf(fechaCreacion) + ' AND CEN_fld_fechaCreacion__c<' + String.valueOf(fechaCreacion.addDays(1)) + ')';
    }
    query = query.replace('{{tag_filtros1}}', filtros1);

    if (String.isNotBlank(objInputBuscador.nombres)) { filtros2 += ' AND (CEN_fld_nombres__c LIKE \'' + objInputBuscador.nombres.trim() + '%\')'; }
    if (String.isNotBlank(objInputBuscador.apellidos)) {filtros2 += ' AND (CEN_fld_apellidos__c LIKE \'' + objInputBuscador.apellidos.trim() + '%\')'; }
    if (String.isNotBlank(objInputBuscador.tipoDocumento) && objInputBuscador.tipoDocumento != 'todos' ) { filtros2 += ' AND CEN_fld_tipoDocumento__c=\'' + objInputBuscador.tipoDocumento.trim() + '\''; } 
      else if (objInputBuscador.tipoDocumento != null && objInputBuscador.tipoDocumento == '') {filtros2 += ' AND CEN_fld_tipoDocumento__c=null'; }
    
    if (String.isNotBlank(objInputBuscador.nroDocumento)) { filtros2 += ' AND (CEN_fld_nroDocumento__c LIKE \'' + objInputBuscador.nroDocumento.trim() + '%\')'; }
    query = query.replace('{{tag_filtros2}}', filtros2);
    return query;
  }

  //  buscar las cotizaciones libres
  @AuraEnabled
  public static ListaLotesLibresWrapper buscarRegistrosCotizacionesLibres(String objInputBuscadorJSON) {
    InputBuscadorWrapper objInputBuscador = null;
    ListaLotesLibresWrapper objListaLotesLibres = new ListaLotesLibresWrapper();
    List<Quote> cotizaciones = new List<Quote>();
    Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>();
    List<Attachment> attachments = new List<Attachment>();
    List<QuoteLineItem> listaProductosCotizacion = new List<QuoteLineItem>();
    Map<Id, Proyecto__c> mapProyectos = new Map<Id, Proyecto__c>();
    Map<Id, Id> mapCotizacionProyecto = new Map<Id, Id>();

    String query = '';
    try {
      System.debug(LoggingLevel.INFO, objInputBuscador);
      System.debug(LoggingLevel.INFO, objInputBuscadorJSON);

      objInputBuscador = (InputBuscadorWrapper) JSON.deserialize(objInputBuscadorJSON, InputBuscadorWrapper.class);
      query = getQueryCotizaciones(objInputBuscador);
      System.debug(LoggingLevel.WARN, query);
      cotizaciones = (List<Quote>) Database.query(query);
      attachments = [
        SELECT Id, ParentId
        FROM Attachment
        WHERE ParentId IN :cotizaciones
        ORDER BY ParentId, CreatedDate ASC
      ];
      for (Attachment obj : attachments) { mapAttachments.put(obj.ParentId, obj); }
      listaProductosCotizacion = [
        SELECT Id, QuoteId, Product2Id, Product2.CEN_Proyecto__c
        FROM QuoteLineItem
        WHERE QuoteId IN :cotizaciones
      ];
      for (QuoteLineItem obj : listaProductosCotizacion) { 
        if (obj.Product2 != null) {mapCotizacionProyecto.put(obj.QuoteId, obj.Product2.CEN_Proyecto__c);}
      }
      mapProyectos = new Map<Id, Proyecto__c>(
        [
          SELECT Id, Name
          FROM Proyecto__c
          WHERE Id IN :mapCotizacionProyecto.values()
        ]
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Exception: ' +
        e.getMessage() +
        '. Type: ' +
        e.getTypeName() +
        '. Line: ' +
        e.getLineNumber()
      );
    }
    objListaLotesLibres.setCotizacionesLibres(cotizaciones,mapAttachments,mapProyectos,mapCotizacionProyecto);
    return objListaLotesLibres;
  }
  //  Para asociar cotizacion --
  //  obtener los lotes de la cotización
  @AuraEnabled
  public static ReponseLotesCotizacionWrapper getLotesCotizacion(String idCotizacion) {
    Quote objQuote = null;
    List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
    Set<Id> idsLotes = new Set<Id>();
    List<Product2> lotes = new List<Product2>();
    ReponseLotesCotizacionWrapper objReponseLotesCotizacion = new ReponseLotesCotizacionWrapper();
    try {
      listQuoteLineItem = [
        SELECT Id, Product2Id
        FROM QuoteLineItem
        WHERE QuoteId = :idCotizacion
        ORDER BY LineNumber ASC
      ];
      for (QuoteLineItem obj : listQuoteLineItem) { idsLotes.add(obj.Product2Id); }
      lotes = [
        SELECT
          Id,
          Name,
          CODLOTE__c,
          CODESTADOLOTE__c,
          MANZANA__c,
          CEN_Proyecto__c,
          CEN_Proyecto__r.CEN_CODIGOSAP__c
        FROM Product2
        WHERE Id IN :idsLotes
      ];
      for (Product2 lote : lotes) {
        CEN_cls_utilsQuote.LoteCotizacionWrapper objLoteCotizacionWrapper = new CEN_cls_utilsQuote.LoteCotizacionWrapper( lote );
        objReponseLotesCotizacion.lotesCotizacion.add(objLoteCotizacionWrapper);
      }
      objReponseLotesCotizacion.ok = true;
    } catch (Exception e) {
      objReponseLotesCotizacion.detalle = ERROR_BUSCANDO_LOTE_COTIZACION + e.getMessage();
      objReponseLotesCotizacion.mensaje = ERROR_BUSCANDO_LOTE_COTIZACION;
    }
    return objReponseLotesCotizacion;
  }
  //  validar los lotes libres
  @AuraEnabled
  public static ReponseLotesCotizacionWrapper validarLoteLibre(String idLote,String codLote,String codProyecto,String manzana) {
    ReponseLotesCotizacionWrapper objReponseLotesCotizacionWrapper = new ReponseLotesCotizacionWrapper();
    try {
      CEN_ResponseContentVisorLotes response = CEN_ConsultVisorLotes.ByProyectCodloteManzana(codLote,codProyecto,manzana);
      CEN_cls_utilsQuote.LoteCotizacionWrapper objLoteCotizacionWrapper = new CEN_cls_utilsQuote.LoteCotizacionWrapper(response,idLote);
      objReponseLotesCotizacionWrapper.lotesCotizacion.add(objLoteCotizacionWrapper);
      objReponseLotesCotizacionWrapper.ok = true;
    } catch (Exception e) {
      objReponseLotesCotizacionWrapper.detalle = ERROR_VALIDANDO_LOTE_COTIZACION + e.getMessage();
      objReponseLotesCotizacionWrapper.mensaje = ERROR_VALIDANDO_LOTE_COTIZACION;
    }
    return objReponseLotesCotizacionWrapper;
  }

  private static List<OpportunityLineItem> convertLotesOportunidadFromLotesCotizacion(String idCotizacion,String idOportunidad) {
    List<QuoteLineItem> lotesCotizacion = new List<QuoteLineItem>();
    List<OpportunityLineItem> lotesOportunidad = new List<OpportunityLineItem>();
    try {
      //  get lotes de cotizacion
      lotesCotizacion = [
        SELECT
          Id,
          Product2Id,
          Quantity,
          CEN_precio_venta_cotizado_lote__c,
          CEN_fld_precioVentaDscto__c,
          PricebookEntryId
        FROM QuoteLineItem
        WHERE QuoteId = :idCotizacion
        ORDER BY LineNumber ASC
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception: ' +
        ex.getMessage() +
        '. Line: ' +
        ex.getLineNumber() +
        '. Type: ' +
        ex.getTypeName()
      );
    }

    for (QuoteLineItem qli : lotesCotizacion) {
      OpportunityLineItem loteOportunidad = new OpportunityLineItem();
      loteOportunidad.OpportunityID = idOportunidad;
      loteOportunidad.PriceBookEntryID = qli.PricebookEntryId;
      loteOportunidad.quantity = qli.Quantity;
      loteOportunidad.totalprice = qli.CEN_precio_venta_cotizado_lote__c;
      loteOportunidad.CEN_fld_precioVentaDscto__c = qli.CEN_fld_precioVentaDscto__c;
      lotesOportunidad.add(loteOportunidad);
    }
    return lotesOportunidad;
  }

  @AuraEnabled
  public static ResponseWrapper setCotizacionAoportunidad(String idCotizacion,String idOportunidad) {
    Quote objQuote = null;
    Opportunity oport = null;
    Quote clonCotizacion = null;
    List<QuoteLineItem> listaProductoCotizaciones = new List<QuoteLineItem>();
    List<QuoteLineItem> listaProductoCotizacionesClonados = new List<QuoteLineItem>();
    List<OpportunityLineItem> lotesDeOportunidad = new List<OpportunityLineItem>();
    List<Attachment> newFiles = new List<Attachment>();
    Attachment objAttachment = null;
    ResponseWrapper objResponseWrapper = new ResponseWrapper();
    objResponseWrapper.ok = false;

    System.Savepoint objSavepoint = Database.setSavepoint();

    try {
      //  mover cotizacion a Oportunidad
      objQuote = [
        SELECT
          OpportunityId,
          Name,
          QuoteNumber,
          Pricebook2Id,
          CEN_Area__c,
          CEN_Precio_por_mt2__c,
          CEN_Precio_de_venta__c,
          CEN_Inicial__c,
          CEN_Cuota_inicial__c,
          CEN_Inicial_porct__c,
          CEN_N_cuotas_de_inicial_de_precio__c,
          CEN_Monto_cuota_de_inicial_de_precio__c,
          CEN_Saldo_del_precio__c,
          CEN_Numero_de_cuotas_a_financiar__c,
          CEN_N_cuotas_del_saldo_de_precio__c,
          CEN_Tasa_de_Interes_compensatorio_anual__c,
          CEN_Monto_cuota_del_saldo_de_precio__c,
          CEN_Tipologia__c,
          CEN_Lote__c,
          CEN_Manzana__c,
          CEN_fld_Libre__c,
          CEN_Precio_de_venta_con_descuento__c,
          CEN_fld_anotaciones__c,
          CEN_fld_nombres__c,
          CEN_fld_apellidos__c,
          CEN_fld_tipoDocumento__c,
          CEN_fld_nroDocumento__c,
          CEN_fld_celular__c,
          CreatedDate,
          CreatedById,
          LastModifiedDate,
          LastModifiedById,
          SystemModstamp,
          LastViewedDate,
          LastReferencedDate,
          OwnerId,
          CEN_fld_Cotizacion_Original__c
        FROM Quote
        WHERE Id = :idCotizacion
        LIMIT 1
      ];
      listaProductoCotizaciones = [
        SELECT
          PricebookEntryId,
          Quantity,
          UnitPrice,
          QuoteId,
          CEN_area_del_lote__c,
          CEN_lote__c,
          CEN_manzana_del_lote__c,
          CEN_precio_m2_cotizado_lote__c,
          CEN_precio_venta_cotizado_lote__c,
          CEN_fld_precioVentaDscto__c,
          CEN_tipologia_del_lote__c,
          CEN_urbanizacion_proyecto__c,
          CEN_etapa__c
        FROM QuoteLineItem
        WHERE QuoteId = :idCotizacion
      ];
      clonCotizacion = objQuote.clone(false, true, true, true);
      clonCotizacion.OpportunityId = idOportunidad;
      clonCotizacion.CEN_fld_Libre__c = false;
      clonCotizacion.CEN_fld_Cotizacion_Original__c = objQuote.Id;
      insert clonCotizacion;

      listaProductoCotizacionesClonados = new List<QuoteLineItem>();
      for (QuoteLineItem obj : listaProductoCotizaciones) {
        QuoteLineItem clon = obj.clone(false, true, true, true);
        clon.QuoteId = clonCotizacion.Id;
        listaProductoCotizacionesClonados.add(clon);
      }
      insert listaProductoCotizacionesClonados;
      //  generar el pdf para la nueva cotizacion clonada
      CEN_cls_VisorLotes.generarPDF(clonCotizacion.Id, idOportunidad);   
    } catch (Exception e) {
      objResponseWrapper.ok = false;
      Database.rollback(objSavepoint);
      objResponseWrapper.detalle = ERROR_ASOCIANDO_COTIZACION_A_OPORTUNIDAD + e.getMessage();
      objResponseWrapper.mensaje = ERROR_ASOCIANDO_COTIZACION_A_OPORTUNIDAD;
      return objResponseWrapper;
    }

    //	Limpiando los lotes de oportunidad
    lotesDeOportunidad = [
      SELECT id
      FROM OpportunityLineItem
      WHERE OpportunityID = :idOportunidad
    ];
    try {
      delete lotesDeOportunidad;
    } catch (Exception ex) {
      objResponseWrapper.ok = false;
      Database.rollback(objSavepoint);
      System.debug(
        'Exception: ' +
        ex.getMessage() +
        '. Line: ' +
        ex.getLineNumber() +
        '. Type: ' +
        ex.getTypeName()
      );

      objResponseWrapper.ok = false;
      objResponseWrapper.mensaje = 'Error: No se pudo quitar los Lotes de la Oportunidad de la anterior Cotización.';
      objResponseWrapper.detalle = objResponseWrapper.mensaje + ex.getMessage();
      return objResponseWrapper;
    }

    //	Creando los nuevos lotes de oportunidad
    lotesDeOportunidad.clear();
    try {
      lotesDeOportunidad = convertLotesOportunidadFromLotesCotizacion(idCotizacion,idOportunidad);
      insert lotesDeOportunidad;
      lotesDeOportunidad = [
        SELECT Id, Product2Id, Product2.CEN_Proyecto__c
        FROM OpportunityLineItem
        WHERE Id = :lotesDeOportunidad
      ];
      //	Definiendo el tipo de venta de la oportunidad
      oport = [
        SELECT
          Id,
          CEN_Proyecto__c,
          CEN_Tipo_de_venta__c,
          CEN_con_lote_desde_visor__c,
          CEN_Inicial_de_precio__c,
          CEN_N_Cuotas_de_inicial_de_precio__c,
          CEN_Monto_cuota_de_inicial_de_precio__c,
          CEN_Saldo_del_precio__c,
          CEN_N_Cuotas_del_Saldo_del_precio__c,
          CEN_Monto_Cuota_del_Saldo_de_precio__c
        FROM Opportunity
        WHERE Id = :idOportunidad
        LIMIT 1
      ];
      if (!lotesDeOportunidad.isEmpty() && lotesDeOportunidad[0].Product2 != null) {oport.CEN_Proyecto__c = lotesDeOportunidad[0].Product2.CEN_Proyecto__c;}
      oport.CEN_Inicial_de_precio__c = objQuote.CEN_Cuota_inicial__c;
      oport.CEN_N_Cuotas_de_inicial_de_precio__c = objQuote.CEN_N_cuotas_de_inicial_de_precio__c;
      oport.CEN_Monto_cuota_de_inicial_de_precio__c = objQuote.CEN_Monto_cuota_de_inicial_de_precio__c;
      oport.CEN_Saldo_del_precio__c =  objQuote.CEN_Saldo_del_precio__c;
      oport.CEN_N_Cuotas_del_Saldo_del_precio__c = objQuote.CEN_N_cuotas_del_saldo_de_precio__c;
      oport.CEN_Monto_Cuota_del_Saldo_de_precio__c = objQuote.CEN_Monto_cuota_del_saldo_de_precio__c;
      oport.CEN_con_lote_desde_visor__c = false;
      if (objQuote.CEN_Inicial_porct__c == 100 && objQuote.CEN_N_cuotas_de_inicial_de_precio__c == 1) { oport.CEN_Tipo_de_venta__c = 'Contado';} 
        else { oport.CEN_Tipo_de_venta__c = 'Financiado';}
      update oport;
      objResponseWrapper.ok = true;
    } catch (Exception ex) {
      objResponseWrapper.ok = false;
      Database.rollback(objSavepoint);
      System.debug(
        'Exception: ' +
        ex.getMessage() +
        '. Line: ' +
        ex.getLineNumber() +
        '. Type: ' +
        ex.getTypeName()
      );
      objResponseWrapper.ok = false;
      objResponseWrapper.mensaje = 'Error: No se pudo crear los Lotes de oportunidad en Salesforce.';
      objResponseWrapper.detalle = objResponseWrapper.mensaje + ex.getMessage();
      return objResponseWrapper;
    }
    return objResponseWrapper;
  }
  //  ---

  //  clases wrapper
  public class ReponseLotesCotizacionWrapper extends ResponseWrapper {
    @AuraEnabled
    public List<CEN_cls_utilsQuote.LoteCotizacionWrapper> lotesCotizacion;
    public ReponseLotesCotizacionWrapper() {
      this.ok = false;
      this.lotesCotizacion = new List<CEN_cls_utilsQuote.LoteCotizacionWrapper>();
    }
  }

  public class ListaLotesLibresWrapper extends ResponseWrapper {
    @AuraEnabled
    public List<CotizacionLibreWrapper> cotizacionesLibres;
    public ListaLotesLibresWrapper() {
      this.cotizacionesLibres = new List<CotizacionLibreWrapper>();
      this.ok = false;
      this.mensaje = '';
      this.detalle = '';
    }
    public void setCotizacionesLibres(List<Quote> cotizaciones,Map<Id, Attachment> mapAttachments,Map<Id, Proyecto__c> mapProyectos,Map<Id, Id> mapCotizacionProyecto) {
      Map<String, String> mapTipoDocumento = CEN_cls_utilsQuote.getDiccionario_ValueLabel(Quote.CEN_fld_tipoDocumento__c.getDescribe());
      Map<String, String> mapTipoMoneda = CEN_cls_utilsQuote.getDiccionario_ValueLabel(Quote.CEN_Tipo_de_moneda__c.getDescribe());
      for (Quote obj : cotizaciones) {
        this.cotizacionesLibres.add(new CotizacionLibreWrapper(obj,mapTipoDocumento,mapTipoMoneda,mapAttachments.get(obj.Id),mapProyectos.get(mapCotizacionProyecto.get(obj.Id)) != null ? mapProyectos.get(mapCotizacionProyecto.get(obj.Id)).Name: null ));
      }
      this.ok = true;
    }
  }

  public class InputBuscadorWrapper {
    @AuraEnabled
    public String nroCotizacion;
    @AuraEnabled
    public Date fechaCotizacion;
    @AuraEnabled
    public String nombres;
    @AuraEnabled
    public String apellidos;
    @AuraEnabled
    public String tipoDocumento;
    @AuraEnabled
    public String nroDocumento;
  }
  public class CotizacionLibreWrapper {
    @AuraEnabled
    public String url;
    @AuraEnabled
    public Id idCotizacion;
    @AuraEnabled
    public String nroCotizacion;
    @AuraEnabled
    public Date fecha;
    @AuraEnabled
    public String proyecto;
    @AuraEnabled
    public String nombreCompletoPersona;
    @AuraEnabled
    public String tipoDocumentoPersona;
    @AuraEnabled
    public String tipoDocumentoPersonaAPIName;
    @AuraEnabled
    public String nroDocumentoPersona;
    @AuraEnabled
    public Double areaTotal;
    @AuraEnabled
    public Double precioTotal;
    @AuraEnabled
    public Double precioConDescuento;
    @AuraEnabled
    public String tipoMoneda;
    @AuraEnabled
    public String tipoMonedaAPIName;
    @AuraEnabled
    public String idPDF;

    public CotizacionLibreWrapper(Quote cotizacion,Map<String, String> mapTipoDocumento,Map<String, String> mapTipoMoneda,Attachment objAttachment,String proyecto) {
      this.url = System.URL.getSalesforceBaseUrl().ToExternalForm() + '/' + cotizacion.Id;
      this.idCotizacion = cotizacion.Id;
      this.nroCotizacion = cotizacion.QuoteNumber;
      this.fecha = cotizacion.CreatedDate.date();
      this.proyecto = proyecto;
      this.nombreCompletoPersona = (cotizacion.CEN_fld_nombres__c == null ? '' : cotizacion.CEN_fld_nombres__c) + ' ' + (cotizacion.CEN_fld_apellidos__c == null ? '' : cotizacion.CEN_fld_apellidos__c);
      this.tipoDocumentoPersona = cotizacion.CEN_fld_tipoDocumento__c;
      this.tipoDocumentoPersonaAPIName = mapTipoDocumento.get(cotizacion.CEN_fld_tipoDocumento__c);
      this.nroDocumentoPersona = cotizacion.CEN_fld_nroDocumento__c;
      this.areaTotal = cotizacion.CEN_Area__c;
      this.precioTotal = cotizacion.TotalPrice;
      this.precioConDescuento = cotizacion.CEN_Precio_de_venta_con_descuento__c;
      this.tipoMoneda = cotizacion.CEN_Tipo_de_moneda__c;
      this.tipoMonedaAPIName = mapTipoMoneda.get(cotizacion.CEN_Tipo_de_moneda__c);
      this.idPDF = objAttachment != null ? objAttachment.Id : null;
    }
  }
}