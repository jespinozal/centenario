/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 04-27-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   04-05-2021   @everis.com   Initial Version
 **/
public virtual without sharing class CEN_Callout_cls {
  @testVisible
  private String customEndpoint;
  @testVisible
  private CEN_AvailableWebservices__mdt config;
  private Map<String, String> headers;
  private Map<String, String> params;
  @testVisible
  private HttpRequest req { get; private set; }
  @testVisible
  private HttpResponse res { get; private set; }
  /**
   * @description Constructor
   * @param  config CMT con configuración base
   */
  public CEN_Callout_cls(CEN_AvailableWebservices__mdt config) {
    if (config == null) {
      String errorMessage = 'Error en configuración de Callout';
      this.throwCalloutException(errorMessage);
    }
    this.config = config;
    this.headers = new Map<String, String>();
    this.params = new Map<String, String>();
    this.req = new HttpRequest();
  }
  /**
   * @description Constructor
   * @param  endpoint Etiqueta de CMT
   */
  public CEN_Callout_cls(String endpoint) {
    this(CEN_AvailableWebservices__mdt.getInstance(endpoint));
  }
  /**
   * @description Respuesta parseada (según CMT o Content-Type)
   * @return   Respuesta de servicio parseada
   */
  public virtual Object getParsedResponse() {
    Object parsedResponse;
    String parserClass = this.config?.CEN_ParserClass__c;
    Integer statusCode = this.res?.getStatusCode() != null? this.res?.getStatusCode(): 0;
    String contentType = this.res?.getHeader('Content-Type');

    Boolean isStatusCodeNotOk = statusCode < 200 || statusCode >= 300;

    if (isStatusCodeNotOk) {
      String errorMessage = String.format(
        'Error de llamado: {0} ({1} - {2})',
        new List<String>{
          this.config.Label,
          String.valueOf(this.res?.getStatusCode()),
          this.res?.getStatus()
        }
      );
      this.throwCalloutException(errorMessage);
    }

    Boolean isParserClassDefined = parserClass != null;
    Boolean isContentTypeDefined = !isParserClassDefined && contentType != null;
    Boolean isBlobContentType = isContentTypeDefined && contentType.contains('multipart/form-data');
    Boolean isXmlContentType = isContentTypeDefined && contentType.contains('text/xml');

    parsedResponse = this.res.getBody();
    if (isParserClassDefined) {
      CEN_CalloutParser parser = (CEN_CalloutParser) Type.forName(parserClass)
        .newInstance();
      parsedResponse = parser.parseResponse(this.res.getBody());
    }
    if (isBlobContentType) {
      parsedResponse = this.res.getBodyAsBlob();
    }
    if (isXmlContentType) {
      parsedResponse = this.res.getBodyDocument();
    }
    return parsedResponse;
  }
  /**
   * @description Retorna el HTTPRequest del framework
   * @return   HTTPRequest
   */
  public virtual HttpRequest getRequest() {
    return this.req;
  }
  /**
   * @description Retorna el HTTPResponse del framework
   * @return   HTTPResponse
   */
  public virtual HttpResponse getResponse() {
    return this.res;
  }
  /**
   * @description Configura el certificado de cliente requerido para configurar el llamado
   * @param  clientCertificateName Nombre del certificado
   * @return                       Instancia
   */
  public CEN_Callout_cls setClientCertificateName(
    String clientCertificateName
  ) {
    try {
      this.req.setClientCertificateName(clientCertificateName);
    } catch (Exception ex) {
      String errorMessage = String.format(
        'Error en carga de certificado: {0} ({1})',
        new List<String>{ this.config.Label, clientCertificateName }
      );
      this.throwCalloutException(errorMessage);
    }
    return this;
  }
  /**
   * @description Configura los encabezados del callout
   * @param  headers Encabezados para la transacción
   * @return         Instancia
   */
  public CEN_Callout_cls setHeaders(Map<String, String> headers) {
    this.headers.putAll(headers);
    return this;
  }
  /**
   * @description Configura los parámetros del callout
   * @param  params Parámetros del callout
   * @return        Instancia
   */
  public CEN_Callout_cls setParams(Map<String, String> params) {
    this.params.putAll(params);
    return this;
  }
  /**
   * @description COnfigura el cuerpo de la solicitud
   * @param  body Cuerpo de la solicitud
   * @return      Instancia
   */
  public CEN_Callout_cls setRequestBody(Object body) {
    System.debug('apiProcessPaymentBODY - ' + body);
    String contentType = '';
    if (body instanceof Blob) {
      this.req.setBodyAsBlob((Blob) body);
      contentType = 'multipart/form-data; charset=utf-8';
    } else if (body instanceof Dom.Document) {
      this.req.setBodyDocument((Dom.Document) body);
      contentType = 'text/xml; charset=utf-8';
      System.debug('Estoy en el document');
    } else if (body instanceof String) {
      this.req.setBody((String) body);
      contentType = 'application/json; charset=utf-8';
    } else {
      this.req.setBody(Json.serialize(body));
      contentType = 'application/json; charset=utf-8';
    }
    if (!this.headers.containsKey('Content-Type')) {
      this.headers.put('Content-Type', contentType);
    }
    return this;
  }
  /**
   * @description Configura el tiempo de espera del callout
   * @param  timeout Tiempo de espera
   * @return         Instancia
   */
  public CEN_Callout_cls setTimeout(Integer timeout) {
    this.req.setTimeout(timeout);
    return this;
  }
  /**
   * @description Ejecuta la secuencia de pasos para completar el llamado al callout
   * @return   Instancia
   */
  public virtual CEN_Callout_cls makeCallout() {
    try {
      this.req.setMethod(this.config.CEN_Method__c);
      this.setAdditionalHeaders();
      this.setHeaders();
      this.setEndpoint();
      this.setParams();
      
      this.res = new Http().send(this.req);
      
      this.logCallout();
    } catch (Exception ex) {
      String errorMessage = String.format(
        'Error de ejecución: {0} ({1} - {2} | {3}:{4}:{5})',
        new List<String>{
          this.config.Label,
          String.valueOf(this.res?.getStatusCode()),
          this.res?.getStatus(),
          ex.getTypeName(),
          ex.getMessage(),
          ex.getStackTraceString()
        }
      );
      throwCalloutException(errorMessage);
    }
    return this;
  }
  /**
   * @description Registra un Log del CAllout (Se alineará con el frameworj)
   * @param  ex Excepción, en caso de tener un fallo
   */
  private void logCallout(CalloutException ex) {
    //  TODO: Alinear con el framework de Logs
    String type;
    if (ex != null) {
      type = 'Excepción';
    } else if (this.res?.getStatusCode() != 200) {
      type = 'Error';
    } else {
      type = 'Correcto';
    }
    
    String strReqXML = this.req.getBodyDocument()!=null?this.req.getBodyDocument().toXmlString():null;
    CEN_AvailableWebservices__mdt cadena = this.config;
    List<String> url = this.req.getEndpoint().split(':');
    List<String> ruta = url[1].split('/', 2);
    CEN_LogEvent__e logEvent = new CEN_LogEvent__e(
      CEN_RequestId__c = Request.getCurrent().getRequestId(),
      CEN_OwnerId__c = UserInfo.getUserId(),
      CEN_Request__c = strReqXML!=null?strReqXML:this.req?.getBody()!= ''?this.req?.getBody():ruta[1],
      CEN_Response__c = ex != null ? ex.getMessage() : this.res?.getBody(),
      CEN_LogType__c = 'Callout',
      CEN_ResponseType__c = type,
      CEN_ServiceType__c = this.config.Label
    );
    Eventbus.publish(logEvent);
  }
  /**
   * @description Registra un Log del CAllout (Se alineará con el frameworj)
   */
  private void logCallout() {
    //  TODO: Alinear con el framework de Logs
    logCallout(null);
  }
  /**
   * @description Fijar los encabezados para realizar el callout
   */
  private void setHeaders() {
    for (String headerKey : this.headers.keySet()) {
      this.req.setHeader(headerKey, this.headers.get(headerKey));
    }
  }
  /**
   * @description Fija los encabezados configurados en la CMT
   */
  private void setAdditionalHeaders() {
    if (String.isNotBlank(this.config.CEN_AdditionalHeaders__c)) {
      try {
        this.headers.putAll(
          (Map<String, String>) JSON.deserializeStrict(
            this.config.CEN_AdditionalHeaders__c,
            Map<String, String>.class
          )
        );
      } catch (Exception ex) {
        String errorMessage = String.format(
          'Error de encabezados adicionales: {0} ({1} | {2}:{3}:{4})',
          new List<String>{
            this.config.Label,
            ex.getMessage(),
            ex.getTypeName(),
            ex.getMessage(),
            ex.getStackTraceString()
          }
        );
        this.throwCalloutException(errorMessage);
      }
    }
  }
  /**
   * @description Fija el endpoint de la llamada
   */
  private void setEndpoint() {
    String callout =
      'callout:' +
      this.config.CEN_NamedCredential__c +
      this.config.CEN_Endpoint__c;
    this.req.setEndpoint(
      String.isNotBlank(this.customEndpoint) ? this.customEndpoint: callout
    );
  }
  /**
   * @description Agrega los parámetros al endpoint del callout
   */
  private void setParams() {
    List<String> params = new List<String>();
    String currentEndpoint = this.req.getEndpoint();
    for (String key : this.params.keySet()) {
      if(currentEndpoint.contains(key)){
        currentEndpoint = currentEndpoint.replace(key, this.params.get(key));
        this.req.setEndpoint(currentEndpoint);
      }else{
        params.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' +EncodingUtil.urlEncode(this.params.get(key), 'UTF-8'));
      }
      
    }
    if (!params.isEmpty()) {
      String paramsString = '?' + String.join(params, '&');
      this.req.setEndpoint(this.req.getEndpoint() + paramsString);
    }
  }
  /**
   * @description Gestiona el lanzamiento de las excepciones
   * @param  errorMessage Mensaje de error para construir la excepción
   */
  private void throwCalloutException(String errorMessage) {
    CalloutException ex = new CalloutException(
      errorMessage,
      this.res?.getStatusCode(),
      this.res?.getStatus()
    );
    this.logCallout(ex);
    throw ex;
  }
  /**
   * @description Implementación de excepción
   */
  public class CalloutException extends Exception {
    /**
     * @description Código de estado interno
     */
    public Integer statusCode { get; private set; }
    /**
     * @description Estado interno
     */
    public String status { get; private set; }
    /**
     * @description Constructor
     * @param  errorMessage mensaje de error de la excepción
     * @param  statusCode   código de estado de la respuesta
     * @param  status       estado de la respuesta
     */
    public CalloutException(
      String errorMessage,
      Integer statusCode,
      String status
    ) {
      this(errorMessage);
      this.statusCode = statusCode;
      this.status = status;
    }
  }
}