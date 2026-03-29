/**
 * @name               : 
 * @author             : Felipe Bermudez
 * @creation date      : 
 * @modification date  : 14-11-2024
 * @last modified by   : Felipe Bermudez
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   13-11-2024   Felipe Bermudez   Initial Version
**/
public with sharing class CEN_SimulacionPrepago {
  // formato de soap xml
  private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';

  @AuraEnabled(cacheable=true)
  public static Map<Object, Object> getSimulacionPrepago(Map<String, String> prepagoCampos, String oppId, Boolean isSimulation) {
    // String nroProforma;
    Map<Object, Object> dataProcesada = new Map<Object, Object>();
    CEN_OperactionSafeObjectResponse resp = new CEN_OperactionSafeObjectResponse();
    try {
      // if (nroProforma != '') {
      // cuando la proforma existe
      // String oppId;
      Opportunity opp = new Opportunity();
      opp = getOppByOppId(oppId);
      //opp = getOppByOppId('006Ru00000B31NqIAJ');
      String nroProforma = opp.CEN_Proforma__c;
      prepagoCampos.put('nroProforma', nroProforma);
      System.debug('prepagoCampos');
      System.debug(prepagoCampos);
      System.debug('CAMPOS REQUESt');
      System.debug(opp);
      System.debug(isSimulation);
      System.debug(prepagoCampos);
      resp = CEN_OperactionSafe_cls.generateOperationByOppId(opp, isSimulation, prepagoCampos);
      dataProcesada = procesarResp(resp);
      System.debug('dataProcesada');
      System.debug(dataProcesada);
    } catch (Exception ex) {
      dataProcesada.put('errorMessage', resp.ET_RETURN.item[0].MESSAGE);
    }
    System.debug('dataProcesada resp -->');
    System.debug(dataProcesada);
    return dataProcesada;
  }

  public static Map<Object, Object> procesarResp(CEN_OperactionSafeObjectResponse myResp) {
    Map<Object, Object> datosToMap = new Map<Object, Object>();

    datosToMap.put('ahorro', myResp.ES_DATOS_PREPAGO.MONTO_AHORRO);
    datosToMap.put('ultimaCuotaSaldo', myResp.IT_CUOTAS_PREPAGO.item[myResp.IT_CUOTAS_PREPAGO.item.size() - 1].IMP_CUOTA);
    datosToMap.put('fechaUltimaCuotaSaldo', myResp.IT_CUOTAS_PREPAGO.item[myResp.IT_CUOTAS_PREPAGO.item.size() - 1].FECHA_VENCIMIENTO);
    datosToMap.put('nroCuotasNuevoFinanciamiento', myResp.IT_CUOTAS_PREPAGO.item.size() - 1);
    datosToMap.put('nroCuotasFinanciamientoInicial', myResp.ET_CUOTAS_PROFORMA_SF.item.size());
    if (myResp.E_CAB_PROFORMA_SF.FACILOTE_IND_CI == 'X') {
      datosToMap.put('cuotaFacilote', myResp.IT_CUOTAS_PREPAGO.item[0].IMP_CUOTA);
      datosToMap.put('cuotaInicNoCuotas', '3-' + String.valueOf(Integer.valueOf(myResp.E_CAB_PROFORMA_SF.CUOTA_INIC_NO_CUOTAS) + 1));
      datosToMap.put('cuotasInicialRestantes', myResp.IT_CUOTAS_PREPAGO.item[2].IMP_CUOTA);
    } else {
      datosToMap.put('cuotaFacilote', 'No aplica');
      datosToMap.put('cuotaInicNoCuotas', '1-' + myResp.E_CAB_PROFORMA_SF.CUOTA_INIC_NO_CUOTAS);
      datosToMap.put('cuotasInicialRestantes', myResp.IT_CUOTAS_PREPAGO.item[0].IMP_CUOTA);
    }
    datosToMap.put('divisa', myResp.E_CAB_PROFORMA_SF.WAERS);
    datosToMap.put('nroProforma', myResp.E_CAB_PROFORMA_SF.PROFORMA);

    Integer i = 0;
    while (myResp.IT_CUOTAS_PREPAGO.item[i].TIPO_CUOTA != 'CP001')
      i++;
    datosToMap.put('cuotaSaldoAnteriorAPrepago', myResp.IT_CUOTAS_PREPAGO.item[i + 1].IMP_CUOTA);
    if (myResp.IT_CUOTAS_PREPAGO.item[i - 1].TIPO_CUOTA.substring(0, 2) == 'CI') {
      datosToMap.put('cuotaSaldoAnteriorAPrepago', myResp.IT_CUOTAS_PREPAGO.item[i + 1].IMP_CUOTA);
      datosToMap.put('cuotaSaldoPosteriorAPrepago', myResp.IT_CUOTAS_PREPAGO.item[i + 1].IMP_CUOTA);
    } else {
      datosToMap.put('cuotaSaldoAnteriorAPrepago', myResp.IT_CUOTAS_PREPAGO.item[i - 1].IMP_CUOTA);
      datosToMap.put('cuotaSaldoPosteriorAPrepago', myResp.IT_CUOTAS_PREPAGO.item[i + 1].IMP_CUOTA);
    }
    System.debug('datosToMap resp -->');
    System.debug(datosToMap);
    return datosToMap;
  }

  public static Opportunity getOppByOppId(String oppId) {
    Opportunity oppData = [
      SELECT
        Id,
        Name,
        CEN_Proyecto__r.CEN_Sociedad__c,
        CEN_Proyecto__r.CEN_CODIGOSAP__c,
        CloseDate,
        CEN_Motivo_de_Compra__c,
        CEN_Medio_Publicitario__c,
        CEN_Oficina_de_Venta__c,
        CEN_Inicial_de_precio__c,
        Account.CEN_Numero_de_documento_del__c,
        Account.CEN_N_mero_de_documento__pc,
        Account.CEN_BankClient__c,
        Account.CEN_LocalAccountNumber__c,
        Account.CEN_InterbankAccountNumber__c,
        CEN_Tipo_de_venta__c,
        CEN_N_Cuotas_del_Saldo_del_precio__c,
        CEN_N_Cuotas_de_inicial_de_precio__c,
        CEN_ProformaVersion__c,
        CEN_NumberInstallmentsSI__c,
        CEN_fld_totalPrecioVentaDscto__c,
        Owner.EmployeeNumber,
        CEN_LotsRemoved__c,
        CEN_MaximumPaymentDate__c,
        CEN_Proforma__c,
        CEN_Cuota_Facilote__c,
        CEN_dia_de_pago__c,
        CEN_devolucion_saldo_Afavor__c,
        OwnerId,
        Owner.Manager.Email,
        Owner.Manager.DelegatedApproverId,
        CEN_MessageError__c,
        CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c,
        Amount,
        CEN_LastApiCall__c,
        CEN_AmountAdvanceFee__c,
        CEN_Monto_cuota_de_inicial_de_precio__c,
        CEN_Processing__c,
        CEN_FirstInstallmentAmount__c,
        CEN_Moneda__c,
        CEN_Simulator__c,
        LeadSource,
        CEN_HasPermission__c,CEN_OpcionDesembolso__c,CEN_FechaDesembolso__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
    System.debug('oppData resp -->');
    System.debug(oppData);
    return oppData;
  }

  @AuraEnabled(cacheable=true)
  public static String getCuotasRestantes(String fechaPrepago, String fechaUltimaCuotaSaldo) {
    Date fechaUltimaCuota = date.valueOf(fechaUltimaCuotaSaldo);
    Date fechaVencimiento = date.valueOf(fechaPrepago);
    if (fechaUltimaCuota.day() > fechaVencimiento.day()) {
      fechaVencimiento = (fechaVencimiento.toStartOfMonth()).addDays(fechaUltimaCuota.day()-1);
    } else {
      fechaVencimiento = ((fechaVencimiento.addMonths(1)).toStartOfMonth()).addDays(fechaUltimaCuota.day()-1);
    }
    String saldoNroCuotas = String.valueOf(fechaVencimiento.monthsBetween(fechaUltimaCuota)+1);
    System.debug('SaldoNroCuotas resp -->');
    System.debug(SaldoNroCuotas);
    return SaldoNroCuotas;
  }

  @AuraEnabled(cacheable=true)
  public static Map<Object, Object> getFechasSaldo(String oppId) {
    System.debug('recordId -> ' + oppId);
    Opportunity opp = [SELECT Id, CEN_ProformaVersion__c FROM Opportunity WHERE Id = :oppId];
    System.debug('opp -> ');
    System.debug(opp);
    List<Quote> lstQuote = [
      SELECT Id, CEN_DateBalanceInstallment__c, CEN_DateEndBalanceInstallment__c, CEN_Monto_cuota_del_saldo_de_precio__c
      FROM Quote
      WHERE OpportunityId = :oppId AND CEN_ProformaVersion__c = :opp.CEN_ProformaVersion__c
      ORDER BY CreatedDate DESC
    ];
    System.debug('lstQuote -> ');
    System.debug(lstQuote);
    Map<Object, Object> fechasMap = new Map<Object, Object>();
    fechasMap.put('fechaPrimeraCuotaSaldo', lstQuote[0].CEN_DateBalanceInstallment__c);
    fechasMap.put('fechaUltimaCuotaSaldo', lstQuote[0].CEN_DateEndBalanceInstallment__c);
    fechasMap.put('cuotaSaldoAnteriorAPrepago', lstQuote[0].CEN_Monto_cuota_del_saldo_de_precio__c);
    System.debug('fechasMap resp -->');
    System.debug(fechasMap);
    return fechasMap;
  }
}