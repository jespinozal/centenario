/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-25-2021
 * @last modified by  : Felipe Bermudez
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
 * 1.1   26-01-2026   Felipe Bermudez Se agrego el nuevo bloque a la respuesta del servicio ET_CUOTAS_SIMU_PROF
 **/
public with sharing class CEN_OperactionSafe_cls {
  private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';

    private static CEN_OperactionSafeObjectRequest.ANTICIPOS setAnticipos() {
      CEN_OperactionSafeObjectRequest.ANTICIPOS anticipos = new CEN_OperactionSafeObjectRequest.ANTICIPOS();
      CEN_OperactionSafeObjectRequest.ANTICIPOS_ITEM anticiposItems = new CEN_OperactionSafeObjectRequest.ANTICIPOS_ITEM();
      anticipos.item = new List<CEN_OperactionSafeObjectRequest.ANTICIPOS_ITEM>{
        anticiposItems
      };
      return anticipos;
    }

  //Escenarios de Financiamiento
  private static CEN_OperactionSafeObjectRequest.PERIODOS setPeriodos() {

    String valores = System.Label.CEN_lbl_periodoAniosCotizador;    // ejemplo: '5,10,15'
    CEN_OperactionSafeObjectRequest.PERIODOS periodos = new CEN_OperactionSafeObjectRequest.PERIODOS();
    List<CEN_OperactionSafeObjectRequest.PERIODOS_ITEM> lista =new List<CEN_OperactionSafeObjectRequest.PERIODOS_ITEM>();
    // Convertir la cadena en arreglo
    List<String> valoresList = valores.split(',');

    for (String val : valoresList) {
        if (String.isNotBlank(val)) {
            CEN_OperactionSafeObjectRequest.PERIODOS_ITEM item = new CEN_OperactionSafeObjectRequest.PERIODOS_ITEM();
            item.SALDO_NO_CUOTAS = val.trim(); // limpia espacios
            lista.add(item);
        }
    }
    periodos.item = lista;
    return periodos;
  }

  private static CEN_OperactionSafeObjectRequest.INTERLOCUTORES setInterlocutore() {
    CEN_OperactionSafeObjectRequest.INTERLOCUTORES interlocutore = new CEN_OperactionSafeObjectRequest.INTERLOCUTORES();
    CEN_OperactionSafeObjectRequest.INTERLOCUTORES_ITEM interlocutoreItems = new CEN_OperactionSafeObjectRequest.INTERLOCUTORES_ITEM();
    interlocutore.item = new List<CEN_OperactionSafeObjectRequest.INTERLOCUTORES_ITEM>{
      interlocutoreItems
    };
    return interlocutore;
  }

  private static CEN_OperactionSafeObjectRequest.PREPAGO_CAMPOS setPrepagoCampos(Map<String, String> paramPrepagoCampos) {
    CEN_OperactionSafeObjectRequest.PREPAGO_CAMPOS prepagoCampos = new CEN_OperactionSafeObjectRequest.PREPAGO_CAMPOS();
    if(paramPrepagoCampos != null){
      prepagoCampos.MANTENER_CUOTA = paramPrepagoCampos.get('reducirTiempo');
      prepagoCampos.DISMINUIR_CUOTA = paramPrepagoCampos.get('disminuirCuota');
      prepagoCampos.SALDO_INICIAL_PREPAGO = paramPrepagoCampos.get('monto');
      if(paramPrepagoCampos.get('saldoNroCuotas') != ''){
        prepagoCampos.SALDO_NO_CUOTAS_PREPAGO = Integer.valueOf(paramPrepagoCampos.get('saldoNroCuotas'));
      }
      prepagoCampos.FECHA_PREPAGO = paramPrepagoCampos.get('fecha');
      prepagoCampos.PROFORMA = paramPrepagoCampos.get('nroProforma');
    }
    return prepagoCampos;
  }

  private static CEN_OperactionSafeObjectRequest.PALANCAS_FINALES setPalancas(Opportunity opp, String financingMethod) {
    CEN_OperactionSafeObjectRequest.PALANCAS_FINALES palancas = new CEN_OperactionSafeObjectRequest.PALANCAS_FINALES();
    
    Id idQuote = [SELECT Id FROM Quote WHERE OpportunityId =: opp.Id AND CEN_ProformaVersion__c = null order by CreatedDate desc LIMIT 1].Id;
    
    String myString = 'PROC|MODI|CVIA|SMODI|SCVIA|SIMU|SIMUP';
    Boolean result = myString.contains(financingMethod);

    if (String.isNotBlank(idQuote) && result) {
      List<CEN_OperactionSafeObjectRequest.PALANCAS_FINALES_ITEM> listaPalancas = new List<CEN_OperactionSafeObjectRequest.PALANCAS_FINALES_ITEM>();
      DateTime dToday = DateTime.now();
      String dateToday = dToday.format('yyyy-MM-dd');
      String timeToday = dToday.format('HH:mm:ss');
      List<CEN_DiscountLever__c> lstDescuentos = [
                                                  SELECT Id,
                                                  CEN_CodigoPalanca__c,
                                                  CEN_Promocion__c,
                                                  CEN_DiscountPercentage__c,
                                                  CEN_ImporteDiscount__c,
                                                  CEN_Moneda__c,
                                                  CEN_ApprovalDiscountAdditional__r.Name
                                                  FROM CEN_DiscountLever__c
                                                  WHERE CEN_QuoteId__c =: idQuote
                                                  ];
      for (CEN_DiscountLever__c objDescuento : lstDescuentos) {
        CEN_OperactionSafeObjectRequest.PALANCAS_FINALES_ITEM palanca = new CEN_OperactionSafeObjectRequest.PALANCAS_FINALES_ITEM();
        palanca.COD_PALANCA = objDescuento.CEN_CodigoPalanca__c;
        palanca.COD_PROMOCION = objDescuento.CEN_Promocion__c;
        palanca.PORCENTAJE = String.valueOf(objDescuento.CEN_DiscountPercentage__c);
        palanca.IMPORTE = String.valueOf(objDescuento.CEN_ImporteDiscount__c);
        palanca.MONEDA = objDescuento.CEN_Moneda__c;
        palanca.APROBADOR = objDescuento.CEN_ApprovalDiscountAdditional__r.Name;
        palanca.FECHA = dateToday;
        palanca.HORA = timeToday;
        listaPalancas.add(palanca);
      }
      palancas.item = listaPalancas;
    }else{
      System.debug('idQuote en blanco');
    }
    return palancas;
  }

  // private static CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL setTasas(Opportunity opp) {
  //   CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL reqTasas = new CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL();
  //   Quote q = [SELECT Id, CEN_CodigoTasa__c, CEN_Tasa__c, Opportunity.Owner.Name FROM Quote WHERE OpportunityId =: opp.Id AND CEN_ProformaVersion__c = null order by CreatedDate desc LIMIT 1];
  //   //String myString = 'PROC|MODI|CVIA|SMODI|SCVIA|SIMU';
  //   //Boolean result = myString.contains(financingMethod);

  //   if (q.CEN_CodigoTasa__c != null && q.CEN_Tasa__c != null) {
  //     List<CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM> listaTasas = new List<CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM>();
  //     DateTime dToday = DateTime.now();
  //     String dateToday = dToday.format('yyyy-MM-dd');
  //     String timeToday = dToday.format('HH:mm:ss');
  //     //for (String key : tasas.keySet()) {
  //       CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM reqTasa = new CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM();
  //       reqTasa.COD_TASA = q.CEN_CodigoTasa__c;
  //       reqTasa.TASA = q.CEN_Tasa__c;
  //       reqTasa.USUARIO = opp.Owner.Name;
  //       reqTasa.FECHA = dateToday;
  //       reqTasa.HORA = timeToday;
  //       listaTasas.add(reqTasa);
  //     //}
  //     reqTasas.item = listaTasas;
  //   }
  //   return reqTasas;
  // }
  private static CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL setTasas(Opportunity opp) {
    CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL reqTasas = new CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL();
    
    // Consulta la Quote asociada a la Opportunity
    Quote q = [SELECT Id, CEN_CodigoTasa__c, CEN_Tasa__c, Opportunity.OwnerId 
               FROM Quote 
               WHERE OpportunityId = :opp.Id AND CEN_ProformaVersion__c = null 
               ORDER BY CreatedDate DESC LIMIT 1];
    
    if (q.CEN_CodigoTasa__c != null && q.CEN_Tasa__c != null) {
        List<CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM> listaTasas = new List<CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM>();
        
        DateTime dToday = DateTime.now();
        String dateToday = dToday.format('yyyy-MM-dd');
        String timeToday = dToday.format('HH:mm:ss');
        
        CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM reqTasa = new CEN_OperactionSafeObjectRequest.TASAS_POLITVEN_FINAL_ITEM();
        reqTasa.COD_TASA = q.CEN_CodigoTasa__c;
        reqTasa.TASA = q.CEN_Tasa__c;
        
        // Obtener el OwnerId de la Opportunity asociada a la Quote
        Id ownerId = q.Opportunity.OwnerId;
        
        // Consulta el nombre del Owner usando el OwnerId
        User owner = [SELECT Name FROM User WHERE Id = :ownerId LIMIT 1];
        
        // Asigna el nombre del Owner al campo USUARIO
        reqTasa.USUARIO = owner.Name;
        
        reqTasa.FECHA = dateToday;
        reqTasa.HORA = timeToday;
        
        listaTasas.add(reqTasa);
        reqTasas.item = listaTasas;
    }
    
    return reqTasas;
}

  private static CEN_OperactionSafeObjectRequest.FILA setFilas(
    Opportunity oppData
  ) {
    CEN_OperactionSafeObjectRequest.FILA filas = new CEN_OperactionSafeObjectRequest.FILA();

    String myLots='';
    String deleteLots='';

    Map<String,Decimal> mapAmountDiscountLote= new Map<String,Decimal>();
    Map<String,Decimal> mapAmountLote= new Map<String,Decimal>();

    list<OpportunityLineItem> oppProdItems = [
      SELECT Product2Id, CEN_fld_precioVentaDscto__c, TotalPrice
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppData.Id
    ];

    List<Quote> qsProforma = [SELECT Id, CEN_ProformaVersion__c, CreatedDate FROM Quote WHERE OpportunityId = :oppData.Id order by CreatedDate desc LIMIT 1];

    Set<String> prod2Ids = new Set<String>();
    for (OpportunityLineItem oppProd : oppProdItems) {
      prod2Ids.add(oppProd.Product2Id);
      myLots+=oppProd.Product2Id+'-';
      mapAmountLote.put(oppProd.Product2Id, oppProd.TotalPrice);

      if(oppProd.CEN_fld_precioVentaDscto__c != null || oppProd.CEN_fld_precioVentaDscto__c > 0){
        Decimal dscto = 0;
        if(oppData.CEN_ProformaVersion__c == null || (oppData.CEN_ProformaVersion__c != qsProforma[0].CEN_ProformaVersion__c)){
          dscto = oppProd.TotalPrice - oppProd.CEN_fld_precioVentaDscto__c;
        }
        mapAmountDiscountLote.put(oppProd.Product2Id, dscto);
      }else{
        mapAmountDiscountLote.put(oppProd.Product2Id, 0);
      }
    }
    String setLostsRemoved = oppData.CEN_LotsRemoved__c;
    if (setLostsRemoved !=null && String.isNotEmpty(setLostsRemoved)) {
      if (setLostsRemoved.contains(',')) {
        prod2Ids.addAll(setLostsRemoved.split(','));
      } else {
        prod2Ids.add(setLostsRemoved);
      }
    }

    if(oppData.CEN_Proforma__c != null){
      List<Quote> qs = [SELECT Id, CreatedDate FROM Quote WHERE OpportunityId = :oppData.Id
      order by CreatedDate desc LIMIT 2];
      if(qs.size() > 1){
        List<QuoteLineItem> qlis = [SELECT  Product2Id, CEN_fld_precioVentaDscto__c, TotalPrice FROM QuoteLineItem WHERE QuoteId = :qs[1].Id];
        for(QuoteLineItem qli: qlis){
          if(!myLots.contains(qli.Product2Id)){
              prod2Ids.add(qli.Product2Id);
              deleteLots+=qli.Product2Id+'-';
              mapAmountLote.put(qli.Product2Id, qli.TotalPrice);
              if(mapAmountDiscountLote.get(qli.Product2Id) == null){
                if(qli.CEN_fld_precioVentaDscto__c != null || qli.CEN_fld_precioVentaDscto__c > 0){
                  Decimal dscto = qli.TotalPrice - qli.CEN_fld_precioVentaDscto__c;
                  mapAmountDiscountLote.put(qli.Product2Id, dscto);
                }else{
                  mapAmountDiscountLote.put(qli.Product2Id, 0);
                }
              }
          }
        }
      }
    }

    List<Product2> prod2s = [
      SELECT
        Id,
        CEN_IdLotSAP__c,
        CODLOTE__c,
        CODESTADOLOTE__c,
        CEN_Proyecto__r.CEN_Sociedad__c,
        CEN_Proyecto__r.CEN_CODIGOSAP__c,
        CODMONEDAFUNCIONAL__c
      FROM Product2
      WHERE Id IN:prod2Ids
    ];
    List<CEN_OperactionSafeObjectRequest.FILA_ITEM> operItems = new List<CEN_OperactionSafeObjectRequest.FILA_ITEM>();
    for (Product2 prod2 : prod2s) {
      CEN_OperactionSafeObjectRequest.FILA_ITEM operItem = new CEN_OperactionSafeObjectRequest.FILA_ITEM();
      if(prod2.CEN_Proyecto__r.CEN_Sociedad__c==null || prod2.CEN_Proyecto__r.CEN_CODIGOSAP__c==null || prod2.CEN_IdLotSAP__c==null ){throw new OperactionSafeException('Debe completar los datos de los lotes a procesar');}
      operItem.BUKRS = prod2.CEN_Proyecto__r.CEN_Sociedad__c;
      operItem.PROCESSO = prod2.CEN_Proyecto__r.CEN_CODIGOSAP__c;
      operItem.COD_PROPIEDAD = prod2.CEN_IdLotSAP__c;
      if ((prod2.CODESTADOLOTE__c != 'L' && !myLots.contains(prod2.Id)) || (deleteLots!='' && deleteLots.contains(prod2.Id))) {
        operItem.IND_ELIMINAR_PROD = 'X';
      }
      operItem.DESCUENTO_OPS = oppData.CEN_HasPermission__c ? '0.00' : String.valueOf(mapAmountDiscountLote.get(prod2.Id));
      //operItem.DESCUENTO_OPS = '0.00'; //VALIDAR CON UN CAMPO BOLEANO QUE SI TIENE DESCUENTO PONERLE EL VALOR DE 0 SINO LO QUE TENEMOS ARRIBA COMENTADO
      operItem.MONEDA_DESCUENTO = prod2.CODMONEDAFUNCIONAL__c == 'Soles' ? 'PEN' : prod2.CODMONEDAFUNCIONAL__c;
      operItem.PRECIO_VENTA = String.valueOf(mapAmountLote.get(prod2.Id));
      operItems.add(operItem);
    }

    CEN_OperactionSafeObjectRequest.FILA_ITEM filasItems = new CEN_OperactionSafeObjectRequest.FILA_ITEM();
    filas.item = operItems;
    return filas;
  }

  private static CEN_OperactionSafeObjectRequest.PROFORMA setProforma(
    Opportunity oppData
  ) {
    CEN_OperactionSafeObjectRequest.PROFORMA proformaData = new CEN_OperactionSafeObjectRequest.PROFORMA();
    String codProf = oppData.CEN_Proforma__c;
    String valores = System.Label.CEN_lbl_tipoPeriodo; 
    
    if (String.isEmpty(codProf)) {

        proformaData.TIPO_PERIODO=valores;//Felipe

        proformaData.BUKRS = oppData.CEN_Proyecto__r.CEN_Sociedad__c;
        proformaData.PROCESSO = oppData.CEN_Proyecto__r.CEN_CODIGOSAP__c;
        proformaData.DIAS_PAGO = oppData.CEN_dia_de_pago__c; // VALIDAR SI SE QUEDA ESTE CAMPO O CREAR UNO DE DIAS
        String motivo = oppData.CEN_Motivo_de_Compra__c; // Validar si se puede modificar
        String medio = oppData.CEN_Medio_Publicitario__c;
        String canal = oppData.LeadSource;
        if(String.isEmpty(motivo)){throw new OperactionSafeException('Debe colocar motivo de compra');}
        if(String.isEmpty(medio)){throw new OperactionSafeException('Debe seleccionar un medio');}
        if(String.isEmpty(canal)){throw new OperactionSafeException('Debe seleccionar un canal');}
        proformaData.MOTIVO_COMPRA = motivo.substring(0, 1);
        proformaData.PROMOTOR = oppData.Owner.EmployeeNumber;
        proformaData.MEDIO = oppData.CEN_Medio_Publicitario__c; // *MOD
        proformaData.ZONA_VENTA = oppData.CEN_Oficina_de_Venta__c; //*MOD (Finalizar modificacion)
        proformaData.CONVERSION_ARRAS = 'NO'; // FALTA (Se convierto el proyecto o la oportunidad ???)
        proformaData.STCD1 = oppData.Account.CEN_N_mero_de_documento__pc != null
        ? oppData.Account.CEN_N_mero_de_documento__pc
        : oppData.Account.CEN_Numero_de_documento_del__c;
        proformaData.VIA_FINANCIAMIENTO = oppData.CEN_Tipo_de_venta__c;
        Decimal amountDscto = oppData.Amount - oppData.CEN_fld_totalPrecioVentaDscto__c;
        User u = new User();

        if (oppData.Owner.Manager.DelegatedApproverId != null) {
          u = [SELECT Email FROM User WHERE id = :oppData.Owner.Manager.DelegatedApproverId];
        }

        proformaData.SUPERV_VENTA = oppData.Owner.Manager.Email;
        proformaData.SUPERV_ASIGNADO = (u.Email != null) ? u.Email : '';

        switch on oppData.CEN_Tipo_de_venta__c {
        when 'CO' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c)>1?Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c)-1:Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c);
          proformaData.CUOTA_INIC_NO_CUOTAS = 1;
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.FACILOTE_IND_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CD' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_del_Saldo_del_precio__c);
          Integer installmentIni = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c );
          Integer facilote = oppData.CEN_Cuota_Facilote__c==true?1:0;
          proformaData.CUOTA_INIC_NO_CUOTAS = installmentIni - facilote;
          String financ = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'X':'';
          String strInt = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'SI':'';
          proformaData.IND_FINAN_CI = financ;
          proformaData.INTERESES_CI = strInt;
          proformaData.FACILOTE_IND_CI = facilote==1?'X':'';// FALTA CAMPO DE ORIGEN
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CS' {
          proformaData.CUOTA_INIC_NO_CUOTAS = null;
          proformaData.SALDO_NO_CUOTAS = null;
          proformaData.NO_CUOTAS_TOT_SI =  Integer.valueOf(oppData.CEN_NumberInstallmentsSI__c);
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
        }
      }

      proformaData.IMPORTE_OCD = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
      proformaData.IMP_CUOTA_LIBRE_INICIAL = String.valueOf(oppData.CEN_FirstInstallmentAmount__c);
      proformaData.IND_IMP_CUOTA_LIBRE = oppData.CEN_FirstInstallmentAmount__c > 0 ? 'X' : '';
      proformaData.MONEDA_PROFORMA = oppData.CEN_Moneda__c;
      System.debug(oppData.CEN_OpcionDesembolso__c);
      System.debug(oppData.CEN_FechaDesembolso__c);
      if(oppData.CEN_OpcionDesembolso__c != null && oppData.CEN_FechaDesembolso__c != null){
        proformaData.OPCION_FECHA = oppData.CEN_OpcionDesembolso__c;
        String dateStr = oppData.CEN_FechaDesembolso__c.year() + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.month()).leftPad(2, '0') + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.day()).leftPad(2, '0');
        proformaData.FECHA_VENC_CS = dateStr;
      }

    }

    return proformaData;
  }

  private static CEN_OperactionSafeObjectRequest.MODIFICAR_PROFORMA setProformaUpdate(
    Opportunity oppData, String FinancingMethod
  ) {
    CEN_OperactionSafeObjectRequest.MODIFICAR_PROFORMA proformaData = new CEN_OperactionSafeObjectRequest.MODIFICAR_PROFORMA();
    String codProf = oppData.CEN_Proforma__c;
    if (String.isNotEmpty(codProf) && (FinancingMethod == 'MODI' || FinancingMethod == 'SMODI')) {
      proformaData.PROFORMA = Integer.valueOf(codProf);
      proformaData.IND_MODF_PROFORMA = 'X';
      proformaData.DIAS_PAGO = oppData.CEN_dia_de_pago__c;
      String motivo = oppData.CEN_Motivo_de_Compra__c; // Validar si se puede modificar
      proformaData.MOTIVO_COMPRA = motivo.substring(0, 1);
      proformaData.MEDIO = oppData.CEN_Medio_Publicitario__c; // *MOD
      proformaData.ZONA_VENTA = oppData.CEN_Oficina_de_Venta__c; //*MOD (Finalizar modificacion)
      proformaData.CONVERSION_ARRAS = 'NO'; // FALTA (Se convierto el proyecto o la oportunidad ???)
      Decimal amountDscto =
        oppData.Amount -
        oppData.CEN_fld_totalPrecioVentaDscto__c;

      switch on oppData.CEN_Tipo_de_venta__c {
        when 'CO' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c) > 1 ? Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c) - 1 : Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c);
          proformaData.CUOTA_INIC_NO_CUOTAS = 1;
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.FACILOTE_IND_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CD' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_del_Saldo_del_precio__c);
          Integer installmentIni = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c );
          Integer facilote = oppData.CEN_Cuota_Facilote__c==true?1:0;
          proformaData.CUOTA_INIC_NO_CUOTAS = installmentIni - facilote;
          String financ = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'X':'';
          String strInt = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'SI':'';
          proformaData.IND_FINAN_CI = financ;
          proformaData.INTERESES_CI = strInt;
          proformaData.FACILOTE_IND_CI = oppData.CEN_Cuota_Facilote__c==true?'X':'';// FALTA CAMPO DE ORIGEN
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CS' {
          proformaData.CUOTA_INIC_NO_CUOTAS = null;
          proformaData.SALDO_NO_CUOTAS = null;
          proformaData.NO_CUOTAS_TOT_SI = Integer.valueOf(oppData.CEN_NumberInstallmentsSI__c);
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
        }
      }

      proformaData.PROMOTOR = oppData.Owner.EmployeeNumber; // VALIDAR SI SERA ESTE CAMPO Y SE DEBE CREAR OTRO ....
      //proformaData.FECHA_VEN_OPS = String.valueOf(oppData.CEN_MaximumPaymentDate__c); // CONFIRMAR SI QUEDA
      proformaData.GUARDAR_MONTO  = oppData.CEN_devolucion_saldo_Afavor__c?'X':''; // CONFIRMAR SI QUEDA DESACTIVADO
      proformaData.IMPORTE_OCD = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
      proformaData.IMP_CUOTA_LIBRE_INICIAL = String.valueOf(oppData.CEN_FirstInstallmentAmount__c);
      proformaData.IND_IMP_CUOTA_LIBRE = oppData.CEN_FirstInstallmentAmount__c > 0 ? 'X' : '';
      proformaData.MONEDA_PROFORMA = oppData.CEN_Moneda__c;
      if(oppData.CEN_OpcionDesembolso__c != null && oppData.CEN_FechaDesembolso__c != null){
        proformaData.OPCION_FECHA = oppData.CEN_OpcionDesembolso__c;
        String dateStr = oppData.CEN_FechaDesembolso__c.year() + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.month()).leftPad(2, '0') + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.day()).leftPad(2, '0');
        proformaData.FECHA_VENC_CS = dateStr;
      }
    }
    return proformaData;
  }

  private static CEN_OperactionSafeObjectRequest.DEVOLUCION setRefund(Opportunity oppData){
    CEN_OperactionSafeObjectRequest.DEVOLUCION devAmount = new CEN_OperactionSafeObjectRequest.DEVOLUCION();
    return devAmount;
  }

  private static CEN_OperactionSafeObjectRequest.VIA_FINANCIAMIENTO setProformaUpdateCVIA(
    Opportunity oppData, String FinancingMethod
  ) {
    System.debug('entro');
    CEN_OperactionSafeObjectRequest.VIA_FINANCIAMIENTO proformaData = new CEN_OperactionSafeObjectRequest.VIA_FINANCIAMIENTO();
    String codProf = oppData.CEN_Proforma__c;
    if (String.isNotEmpty(codProf) && (FinancingMethod == 'CVIA' || FinancingMethod == 'SCVIA')) {
      proformaData.IND_MODF_PROFORMA = 'X';
      proformaData.IND_ADMINISTRAR_PRODUCTOS = 'X';
      proformaData.PROFORMA = Integer.valueOf(codProf);
      proformaData.BUKRS = oppData.CEN_Proyecto__r.CEN_Sociedad__c;
      proformaData.PROCESSO = oppData.CEN_Proyecto__r.CEN_CODIGOSAP__c;
      proformaData.DIAS_PAGO = oppData.CEN_dia_de_pago__c;
      String motivo = oppData.CEN_Motivo_de_Compra__c;
      proformaData.MOTIVO_COMPRA = motivo.substring(0, 1);
      proformaData.APODERADO_CENTENARIO1 = '';
      proformaData.APODERADO_CENTENARIO2 = '';
      proformaData.MEDIO = oppData.CEN_Medio_Publicitario__c;
      proformaData.ZONA_VENTA = oppData.CEN_Oficina_de_Venta__c;
      proformaData.CONVERSION_ARRAS = 'NO';
      Decimal amountDscto =
        oppData.Amount -
        oppData.CEN_fld_totalPrecioVentaDscto__c;

      switch on oppData.CEN_Tipo_de_venta__c {
        when 'CO' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c) > 1 ? Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c) - 1 : Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c);
          proformaData.CUOTA_INIC_NO_CUOTAS = 1;
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.FACILOTE_IND_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CD' {
          proformaData.SALDO_NO_CUOTAS = Integer.valueOf(oppData.CEN_N_Cuotas_del_Saldo_del_precio__c); //cs - co - cd sin facilote
          Integer installmentIni = Integer.valueOf(oppData.CEN_N_Cuotas_de_inicial_de_precio__c );
          Integer facilote = oppData.CEN_Cuota_Facilote__c==true?1:0;
          proformaData.CUOTA_INIC_NO_CUOTAS = installmentIni - facilote;
          String financ = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'X':'';
          String strInt = oppData.CEN_N_Cuotas_de_inicial_de_precio__c > 1?'SI':'';
          proformaData.IND_FINAN_CI = financ;
          proformaData.INTERESES_CI = strInt;
          proformaData.FACILOTE_IND_CI = oppData.CEN_Cuota_Facilote__c==true?'X':'';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Inicial_de_precio__c);
        }
        when 'CS' {
          proformaData.CUOTA_INIC_NO_CUOTAS = null;
          proformaData.SALDO_NO_CUOTAS = null;
          proformaData.NO_CUOTAS_TOT_SI = Integer.valueOf(oppData.CEN_NumberInstallmentsSI__c);
          proformaData.IND_FINAN_CI = '';
          proformaData.INTERESES_CI = '';
          proformaData.IMPORTE_CI_CHAR = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
        }
      }

      proformaData.STCD1 = oppData.Account.CEN_N_mero_de_documento__pc != null
        ? oppData.Account.CEN_N_mero_de_documento__pc
        : oppData.Account.CEN_Numero_de_documento_del__c;
      proformaData.VIA_FINANCIAMIENTO = oppData.CEN_Tipo_de_venta__c;
      proformaData.PROMOTOR = oppData.Owner.EmployeeNumber;
      proformaData.IMPORTE_OCD = String.valueOf(oppData.CEN_Monto_cuota_de_inicial_de_precio__c);
      proformaData.MONEDA_PROFORMA = oppData.CEN_Moneda__c;
      if(oppData.CEN_OpcionDesembolso__c != null && oppData.CEN_FechaDesembolso__c != null){
        proformaData.OPCION_FECHA = oppData.CEN_OpcionDesembolso__c;
        String dateStr = oppData.CEN_FechaDesembolso__c.year() + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.month()).leftPad(2, '0') + '-' + String.valueOf(oppData.CEN_FechaDesembolso__c.day()).leftPad(2, '0');
        proformaData.FECHA_VENC_CS = dateStr;
      }
    }
    return proformaData;
  }

  // Escenarios de finaciamiento
  public static CEN_OperactionSafeObjectResponse generateOperationByOppIdPeriodos(Opportunity opp, Boolean simuladorPrepago, Map<String,String> paramPrepagoCampos) {
    system.debug('***IN CEN_OperactionSafe_cls.generateOperationByOppId***');
    system.debug('generateOperationByOppId-opp: ' + opp);
    CEN_OperactionSafeObjectResponse resp;
    CEN_OperactionSafeObjectRequest myObjectReq = new CEN_OperactionSafeObjectRequest();
    try {
      CEN_OperactionSafeObjectRequest.FINANCIAMIENTO myFinan = new CEN_OperactionSafeObjectRequest.FINANCIAMIENTO();

      String financingMethod = 'SIMUP';

      myFinan.IT_PERIODO = setPeriodos();
      //---- ANTICIPOS -----
      myFinan.IT_ANTICIPOS = setAnticipos();

      //---- INTERLOCUTORES -----
      myFinan.IT_INTERLOCUTORES = setInterlocutore();

      //---- PREPAGO CAMPOS -----
      myFinan.IS_PREPAGO_CAMPOS = setPrepagoCampos(paramPrepagoCampos);

      //---- FILA -----
      myFinan.IT_FILA = setFilas(opp);

      //---- PROCESO -----
      myFinan.I_PROCESO = financingMethod;

      //---- PROFORMA -----
      myFinan.IS_CREAR_PROFORMA = setProforma(opp);
      system.debug('generateOperationByOppId-opp: ');
      system.debug(opp);
      system.debug('generateOperationByOppId-opp: ');
      system.debug(financingMethod);
      //---- MODIFICAR_PROFORMA MODI -----
      myFinan.IS_MODIFICAR_PROFORMA = setProformaUpdate(opp, financingMethod);

      //---- MODIFICAR_PROFORMA CVIA -----
      myFinan.IS_CAMBIAR_VIA_FINANCIAMIENTO = setProformaUpdateCVIA(opp, financingMethod);

      //---- DEVOLUCION -----
      myFinan.IS_REALIZAR_DEVOLUCION = setRefund(opp);

      //---- PALANCAS -----
      myFinan.IT_PALANCAS_FINALES = setPalancas(opp, financingMethod);
      System.debug('$$$$');
      System.debug(myFinan.IT_PALANCAS_FINALES);

      //---- TASAS -----
      myFinan.IT_TASAS_POLITVEN_FINAL = setTasas(opp);
      System.debug('##');
      myObjectReq.ZRFC_OTC_FINANCIAMIENTO_SF_WS = myFinan;
      system.debug('generateOperationByOppId-myObjectReq' + myObjectReq);

    } catch (Exception ex) {
      resp = new CEN_OperactionSafeObjectResponse();
      CEN_OperactionSafeObjectResponse.BAPIRET2_T respError = new CEN_OperactionSafeObjectResponse.BAPIRET2_T();
      List<CEN_OperactionSafeObjectResponse.BAPIRET2> respErrorList = new List<CEN_OperactionSafeObjectResponse.BAPIRET2>();
      CEN_OperactionSafeObjectResponse.BAPIRET2 respErrorDetails = new CEN_OperactionSafeObjectResponse.BAPIRET2();
      respErrorDetails.TYPE_x ='dataErrorCatch';
      respErrorDetails.MESSAGE = ex.getMessage();
      respErrorDetails.MESSAGE_V1 = ex.getMessage()+', en la linea: '+ex.getLineNumber();
      respErrorList.add(respErrorDetails);
      respError.item = respErrorList;
      resp.ET_RETURN = respError;
    }

    if(resp == null ){
      resp = new CEN_OperactionSafeObjectResponse();
      resp = callOperactionSafeApi(myObjectReq);
    }

    return resp;
  }

  public static CEN_OperactionSafeObjectResponse generateOperationByOppId(Opportunity opp, Boolean simuladorPrepago, Map<String,String> paramPrepagoCampos) {
    system.debug('***IN CEN_OperactionSafe_cls.generateOperationByOppId***');
    system.debug('generateOperationByOppId-opp: ' + opp);
    CEN_OperactionSafeObjectResponse resp;
    CEN_OperactionSafeObjectRequest myObjectReq = new CEN_OperactionSafeObjectRequest();
    try {
      CEN_OperactionSafeObjectRequest.FINANCIAMIENTO myFinan = new CEN_OperactionSafeObjectRequest.FINANCIAMIENTO();

      String financingMethod = FinancingMethod(opp, simuladorPrepago);

      //---- ANTICIPOS -----
      myFinan.IT_ANTICIPOS = setAnticipos();

      //---- INTERLOCUTORES -----
      myFinan.IT_INTERLOCUTORES = setInterlocutore();

      //---- PREPAGO CAMPOS -----
      myFinan.IS_PREPAGO_CAMPOS = setPrepagoCampos(paramPrepagoCampos);

      //---- FILA -----
      myFinan.IT_FILA = setFilas(opp);

      //---- PROCESO -----
      myFinan.I_PROCESO = financingMethod;

      //---- PROFORMA -----
      myFinan.IS_CREAR_PROFORMA = setProforma(opp);
      system.debug('generateOperationByOppId-opp: ');
      system.debug(opp);
      system.debug('generateOperationByOppId-opp: ');
      system.debug(financingMethod);
      //---- MODIFICAR_PROFORMA MODI -----
      myFinan.IS_MODIFICAR_PROFORMA = setProformaUpdate(opp, financingMethod);

      //---- MODIFICAR_PROFORMA CVIA -----
      myFinan.IS_CAMBIAR_VIA_FINANCIAMIENTO = setProformaUpdateCVIA(opp, financingMethod);

      //---- DEVOLUCION -----
      myFinan.IS_REALIZAR_DEVOLUCION = setRefund(opp);

      //---- PALANCAS -----
      myFinan.IT_PALANCAS_FINALES = setPalancas(opp, financingMethod);
      System.debug('$$$$');
      System.debug(myFinan.IT_PALANCAS_FINALES);

      //---- TASAS -----
      myFinan.IT_TASAS_POLITVEN_FINAL = setTasas(opp);
      System.debug('##');
      myObjectReq.ZRFC_OTC_FINANCIAMIENTO_SF_WS = myFinan;
      system.debug('generateOperationByOppId-myObjectReq' + myObjectReq);

    } catch (Exception ex) {
      resp = new CEN_OperactionSafeObjectResponse();
      CEN_OperactionSafeObjectResponse.BAPIRET2_T respError = new CEN_OperactionSafeObjectResponse.BAPIRET2_T();
      List<CEN_OperactionSafeObjectResponse.BAPIRET2> respErrorList = new List<CEN_OperactionSafeObjectResponse.BAPIRET2>();
      CEN_OperactionSafeObjectResponse.BAPIRET2 respErrorDetails = new CEN_OperactionSafeObjectResponse.BAPIRET2();
      respErrorDetails.TYPE_x ='dataErrorCatch';
      respErrorDetails.MESSAGE = ex.getMessage();
      respErrorDetails.MESSAGE_V1 = ex.getMessage()+', en la linea: '+ex.getLineNumber();
      respErrorList.add(respErrorDetails);
      respError.item = respErrorList;
      resp.ET_RETURN = respError;
    }

    if(resp == null ){
      resp = new CEN_OperactionSafeObjectResponse();
      resp = callOperactionSafeApi(myObjectReq);
      //generateOperationPeriodos(myObjectReq);//terminas de hacer tu llamado y llenas tu request con SIMU
    }

    return resp;
  }

  private static CEN_OperactionSafeObjectResponse callOperactionSafeApi(
    CEN_OperactionSafeObjectRequest reqProcess
  ) {
    system.debug('IN callOperactionSafeApi');
    String customReqBody;
    CEN_OperactionSafeObjectResponse resp = new CEN_OperactionSafeObjectResponse();
    XMLSerializer serializerXML = new XMLSerializer();
    customReqBody = serializerXML.serialize(reqProcess);
    customReqBody = customReqBody.replace(
      'ZRFC_OTC_FINANCIAMIENTO_SF_WS',
      'urn:ZRFC_OTC_FINANCIAMIENTO_SF_WS'
    );

    try {
      CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_OperacionSegura');
      Dom.Document docReq = new Dom.Document();
      String setReq = customReq.replace('myBody', customReqBody);
      system.debug('callOperactionSafeApi-setReq: ' + setReq);
      docReq.load(setReq);
      callApi.setRequestBody(docReq);
        if(!Test.isRunningTest()){
        callApi.setTimeout(60000);
        }
      resp = (CEN_OperactionSafeObjectResponse) callApi.makeCallout().getParsedResponse();
      system.debug('callOperactionSafeApi-resp: ' + resp.ET_CUOTAS_SIMU_PROF);
    } catch (Exception ex) {
      System.debug('callOperactionSafeApi-Error: ' + ex.getMessage());
      CEN_OperactionSafeObjectResponse.BAPIRET2_T respError = new CEN_OperactionSafeObjectResponse.BAPIRET2_T();
      List<CEN_OperactionSafeObjectResponse.BAPIRET2> respErrorList = new List<CEN_OperactionSafeObjectResponse.BAPIRET2>();
      CEN_OperactionSafeObjectResponse.BAPIRET2 respErrorDetails = new CEN_OperactionSafeObjectResponse.BAPIRET2();
      respErrorDetails.MESSAGE = ex.getMessage()+', en la linea: '+ex.getLineNumber();
      respErrorDetails.TYPE_x ='apiErrorCatch';
      respErrorList.add(respErrorDetails);
      respError.item = respErrorList;
      resp.ET_RETURN = respError;
    }

    return resp;
  }

  private static String FinancingMethod(Opportunity opp, Boolean simuladorPrepago){
    String myFinan;
    String codProf = opp.CEN_Proforma__c;

    if(simuladorPrepago){
      myFinan = 'SIMU'; //Felipe
    }else{
      if(String.isNotEmpty(codProf)){

        List<Quote> qs = [SELECT Id, CEN_TypeOfSale__c, CEN_N_cuotas_de_inicial_de_precio__c, CEN_N_cuotas_del_saldo_de_precio__c, CreatedDate FROM Quote WHERE OpportunityId = :opp.Id AND CEN_ProformaVersion__c =: opp.CEN_ProformaVersion__c order by CreatedDate desc LIMIT 1];
        if(qs.size() > 0){
          String typeSaleOld = qs[0].CEN_TypeOfSale__c;
          String typeSaleNew = opp.CEN_Tipo_de_venta__c;

          if(opp.CEN_Simulator__c){
            myFinan = typeSaleOld == typeSaleNew ? 'SMODI':'SCVIA';
          }else{
            myFinan = typeSaleOld == typeSaleNew ? 'MODI':'CVIA';
          }
        }
      }else{
        myFinan = opp.CEN_Simulator__c ? 'SIMU' : 'PROC'; //Felipe
      }
    }

    return myFinan;
  }

  public class OperactionSafeException extends Exception {
  }
}