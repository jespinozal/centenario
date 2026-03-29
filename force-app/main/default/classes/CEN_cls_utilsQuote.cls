/*
 * Name: CEN_cls_utilsQuote
 * Version: 1.0
 * Descripción: clase utils para cotizacion
 * Fecha: 8/11/2020
 * TestClass:
 *    - CEN_cls_utilsQuote_test
 *    - TestClass
 */
public with sharing class CEN_cls_utilsQuote {

  private static final Map<String, String> mapEstados = new Map<String,String>{
    'E'=>'Entregado', 
    'B'=>'Borrado',
    'L'=>'Libre',
    'Q'=>'Bloqueado',
    'C'=>'Vendido',
    'R'=>'Reservado'
  };

  private static final String LABEL_TIPO_DOCUMENTO_NINGUNO = '--Ninguno--';
  private static final String VALUE_TIPO_DOCUMENTO_NINGUNO = '';
  private static final String LABEL_TIPO_DOCUMENTO_TODOS = 'Todos';
  private static final String VALUE_TIPO_DOCUMENTO_TODOS = 'todos';

  public static Map<String, String> getDiccionario_LabelValue(
    Schema.DescribeFieldResult describefield
  ) {
    List<Schema.PicklistEntry> listPicklist = describefield.getPicklistValues();
    Map<String, String> diccionario = new Map<String, String>();
    for (Schema.PicklistEntry pe : listPicklist) {
      diccionario.put(pe.getLabel(), pe.getValue());
    }
    return diccionario;
  }

  public static Map<String, String> getDiccionario_ValueLabel(
    Schema.DescribeFieldResult describefield
  ) {
    List<Schema.PicklistEntry> listPicklist = describefield.getPicklistValues();
    Map<String, String> diccionario = new Map<String, String>();
    for (Schema.PicklistEntry pe : listPicklist) {
      diccionario.put(pe.getValue(), pe.getLabel());
    }
    return diccionario;
  }
  public static ListatipoDocumentoWrapper getListaTipoDocumentos() {
    ListatipoDocumentoWrapper objListatipoDocumento = new ListatipoDocumentoWrapper();

    Map<String, String> mapaTipoDocumentos = getDiccionario_LabelValue(
      Quote.CEN_fld_tipoDocumento__c.getDescribe()
    );
    //  el defecto
    OptionWrapper objOptionWrapper2 = new OptionWrapper();
    objOptionWrapper2.label = LABEL_TIPO_DOCUMENTO_NINGUNO;
    objOptionWrapper2.value = VALUE_TIPO_DOCUMENTO_NINGUNO;
    objOptionWrapper2.selected = false;
    objListatipoDocumento.tipoDocumentos.add(objOptionWrapper2);
    //  del mapa
    for (String key : mapaTipoDocumentos.keySet()) {
      OptionWrapper obj = new OptionWrapper();
      obj.label = key;
      obj.value = mapaTipoDocumentos.get(key);
      objListatipoDocumento.tipoDocumentos.add(obj);
    }
    objListatipoDocumento.ok = true;
    return objListatipoDocumento;
  }

  /* para tipos de documento */
  public class ListatipoDocumentoWrapper extends ResponseWrapper {
    @AuraEnabled
    public List<OptionWrapper> tipoDocumentos;
    public ListatipoDocumentoWrapper() {
      this.tipoDocumentos = new List<OptionWrapper>();
      this.ok = false;
      this.mensaje = '';
      this.detalle = '';
    }
  }
  public class OptionWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public Boolean selected;
    public OptionWrapper() {
      this.selected = false;
    }
  }
  /* para datos de la persona */
  public class DatosPersonaWrapper {
    @AuraEnabled
    public String nombres { get; set; }
    @AuraEnabled
    public String apellidos { get; set; }
    @AuraEnabled
    public String tipoDocumento { get; set; }
    @AuraEnabled
    public String nroDocumento { get; set; }
    @AuraEnabled
    public String celular { get; set; }
  }
  /* para anotaciones */
  public class DatoAnotacionesWrapper {
    @AuraEnabled
    public Integer key { get; set; }
    @AuraEnabled
    public Date fecha { get; set; }
    @AuraEnabled
    public Double monto { get; set; }
    @AuraEnabled
    public String anotaciones { get; set; }
  }
  /* para traducir estado lote de sap a label */
  public static String cambiarEstadoLote(String estadoLote) {
    estadoLote = estadoLote.toUpperCase();
    if(mapEstados.containsKey(estadoLote)){
      return mapEstados.get(estadoLote.toUpperCase());
    }
    else{
      return estadoLote;
    }
  }

  /**
  * @description 
  ** Obtiene los codigos de los lotes que estan relacionados a la oportunidad
  * @lastModifiedDate 20-07-2021 
  * @param Id idRecord 
  * @return Set<String> 
  **/
  public static Set<String> getCodLotesRelacionadosAoportunidad(Id idRecord){
    Set<String> codigosDeLotesRelacionados = new Set<String>();
    List<OpportunityLineItem> productosDeLaOportunidad = new List<OpportunityLineItem>(); 
    List<QuoteLineItem> productosDeLasCotizaciones = new List<QuoteLineItem>();

    productosDeLaOportunidad = [
      SELECT Id, IsDeleted, Product2Id, Product2.CODLOTE__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :idRecord 
      AND IsDeleted = false
    ];
    System.debug(LoggingLevel.INFO, 'Lotes de Oportunidad para ' + idRecord + ': ' + String.valueOf(productosDeLaOportunidad.size()));
    
    productosDeLasCotizaciones = [
      SELECT Id, IsDeleted, Product2Id, Product2.CODLOTE__c
      FROM QuoteLineItem
      WHERE Quote.OpportunityId = :idRecord 
      AND IsDeleted = false
    ];
    System.debug(LoggingLevel.INFO, 'Lotes de Cotizaciones para ' + idRecord + ': ' + String.valueOf(productosDeLasCotizaciones.size()));

    for(OpportunityLineItem  obj : productosDeLaOportunidad)
    {
      codigosDeLotesRelacionados = addCodigoLoteToSet(codigosDeLotesRelacionados, obj.Product2Id!=null ? obj.Product2 : null);
    }

    for(QuoteLineItem  obj : productosDeLasCotizaciones)
    {
      codigosDeLotesRelacionados = addCodigoLoteToSet(codigosDeLotesRelacionados, obj.Product2Id!=null ? obj.Product2 : null);
    }

    return codigosDeLotesRelacionados;
    
  }

  /**
  * @description 
  ** Agrega el codigo del lote al set
  * @lastModifiedDate 20-07-2021 
  * @param Set<String> setCodigosLote 
  * @param Product2 producto 
  * @return Set<String> 
  **/
  private static Set<String> addCodigoLoteToSet(Set<String> setCodigosLote, Product2 producto){
    if(producto!=null && String.isNotBlank(producto.CODLOTE__c)){
      String auxCodeLote = String.valueOf(Long.valueOf(producto.CODLOTE__c));
      setCodigosLote.add(producto.CODLOTE__c);
    }
    return setCodigosLote;
  }


  // -------------------------------------------------------------
  public class LoteCotizacionWrapper {
    @AuraEnabled
    public String idLote;
    @AuraEnabled
    public String nombreLote;
    @AuraEnabled
    public String manzana;
    @AuraEnabled
    public String codLote;
    @AuraEnabled
    public String codProyecto;
    @AuraEnabled
    public String estado;
    @AuraEnabled
    public Boolean estaLibre;
    @AuraEnabled
    public Boolean validado;
    @AuraEnabled
    public Boolean procesado;
    public LoteCotizacionWrapper(Product2 lote) {
      this.idLote = lote.Id;
      this.codLote = lote.CODLOTE__c;
      this.nombreLote = lote.Name;
      this.manzana = lote.MANZANA__c;
      if (String.isNotBlank(lote.CODESTADOLOTE__c)) {
        this.estado = cambiarEstadoLote(lote.CODESTADOLOTE__c);
      }
      if (this.estado == 'Libre' || this.estado == 'L') {
        this.estaLibre = true;
      } else {
        this.estaLibre = false;
      }
      this.codProyecto = lote.CEN_Proyecto__c != null
        ? lote.CEN_Proyecto__r.CEN_CODIGOSAP__c
        : null;
      this.validado = false;
      this.procesado = false;
    }
    public LoteCotizacionWrapper(
      CEN_ResponseContentVisorLotes loteSap,
      String idLote
    ) {
      this.idLote = idLote;
      this.nombreLote = loteSap.Descripcionlote;
      this.manzana = loteSap.Manzana;
      this.codLote = loteSap.Codlote;
      this.codProyecto = loteSap.Idproyecto;
      this.estado = cambiarEstadoLote(loteSAP.Codestadolote);
      if (this.estado == 'Libre' || this.estado == 'L') {
        this.estaLibre = true;
      } else {
        this.estaLibre = false;
      }
      this.validado = true;
      this.procesado = true;
    }
  }
}