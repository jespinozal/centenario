/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-24-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-13-2021   @everis.com   Initial Version
 **/
public without sharing class CEN_OperactionSafe_ctr {
  public static Map<String, String> generateAndUpdateOperation(String oppId) {
    String titleNotification='Operacion Segura en SAP';
    String bodyNotification;
    String targetNotification = oppId;
    Decimal versionProforma = 0;
    String codigoMinuta = '';
    Map<String, String> generatedMapResp = new Map<String, String>();

    Opportunity oppData = [SELECT Id,Name,CEN_Proyecto__r.CEN_Sociedad__c,CEN_Proyecto__r.CEN_CODIGOSAP__c,CloseDate,CEN_Motivo_de_Compra__c, LeadSource,
                            CEN_Medio_Publicitario__c,CEN_Oficina_de_Venta__c,CEN_Inicial_de_precio__c,Account.CEN_Numero_de_documento_del__c,
                            Account.CEN_N_mero_de_documento__pc,Account.CEN_BankClient__c,Account.CEN_LocalAccountNumber__c,Account.CEN_InterbankAccountNumber__c,
                            CEN_Tipo_de_venta__c,CEN_N_Cuotas_del_Saldo_del_precio__c,CEN_N_Cuotas_de_inicial_de_precio__c,CEN_ProformaVersion__c,CEN_NumberInstallmentsSI__c,
                            CEN_fld_totalPrecioVentaDscto__c,Owner.EmployeeNumber,CEN_LotsRemoved__c,CEN_MaximumPaymentDate__c,CEN_Proforma__c,CEN_Cuota_Facilote__c,
                            CEN_dia_de_pago__c,CEN_devolucion_saldo_Afavor__c,OwnerId,Owner.Manager.Email,Owner.Manager.DelegatedApproverId, CEN_MessageError__c,CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c,
                            Amount,CEN_LastApiCall__c,CEN_AmountAdvanceFee__c, CEN_Monto_cuota_de_inicial_de_precio__c, CEN_Processing__c, CEN_FirstInstallmentAmount__c,
                            CEN_Moneda__c, CEN_Simulator__c, Owner.Name, CEN_Discount__c, CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__r.Name, CEN_HasPermission__c, CEN_CodigoMinuta__c,
                            CEN_OpcionDesembolso__c,CEN_FechaDesembolso__c
                          FROM Opportunity
                          WHERE Id = :oppId];

    if(oppData.CEN_MessageError__c != null){
      generatedMapResp.put('error', oppData.CEN_MessageError__c);
    }
    else{
      String oldProforma = oppData.CEN_Proforma__c;

      if(oldProforma!=null){oppData.CEN_devolucion_saldo_Afavor__c=true;}

      Set<String> recipientId = new Set<String> {oppData.OwnerId};

      if(!String.isBlank(oppData.Owner.EmployeeNumber)){
        CEN_OperactionSafeObjectResponse resp = CEN_OperactionSafe_cls.generateOperationByOppId(oppData, false, null);
        String codProf = resp.E_CAB_PROFORMA_SF != null ? resp.E_CAB_PROFORMA_SF.PROFORMA : '';

        if (String.isNotEmpty(codProf) && Integer.valueOf(codProf) > 0 && resp.ET_RETURN.item[0].TYPE_x != 'E') {
          oppData.CEN_Proforma__c = codProf;
          codigoMinuta = resp.E_CAB_PROFORMA_SF.COD_MINUTA;
          oppData.CEN_CodigoMinuta__c = codigoMinuta;
          versionProforma = Decimal.valueOf(resp.E_CAB_PROFORMA_SF.VERSION);
          oppData.CEN_ProformaVersion__c = versionProforma;
          oppData.CEN_MessageError__c = null;

          Decimal diasMaximoPago = oppData.CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c;
          Date periodoMaximoPago = date.TODAY() +  Integer.valueOf(diasMaximoPago);
          // Date fechaMaximaPago = date.TODAY();
          // if(periodoMaximoPago.month() == fechaMaximaPago.month()){ oppData.CEN_MaximumPaymentDate__c = periodoMaximoPago;}
          // else{
          //   Date firstDayOfMonth = fechaMaximaPago.toStartOfMonth();
          //   Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
          //   oppData.CEN_MaximumPaymentDate__c = lastDayOfMonth;
          // }
          oppData.CEN_MaximumPaymentDate__c = periodoMaximoPago;
          oppData.CEN_SystemExecute__c = true;
          if (versionProforma == 1) oppData.CEN_FirstMaximumPaymentDate__c = periodoMaximoPago;

          bodyNotification='Se ha procesado la Operacion Segura: ' + oppData.CEN_Proforma__c;
          generatedMapResp.put('sucess', 'Se ha procesado la Operacion Segura ' + oppData.CEN_Proforma__c);
		      ID jobID = System.enqueueJob(new CEN_PaymentOrderProcess_ctr(oppData.Id),1);
          CEN_AnnulmentOppSameLot_ctr.updateOppSameLot(oppData.Id); //Anular oportunidades con el mismo lote.

        } else if (resp.ET_RETURN.item[0].TYPE_x != 'apiErrorCatch') {
          titleNotification = 'Error de datos para procesar la operacion segura';
          bodyNotification = resp.ET_RETURN.item[0].MESSAGE;
          oppData.CEN_MessageError__c = resp.ET_RETURN.item[0].MESSAGE;
          generatedMapResp.put('error', resp.ET_RETURN.item[0].MESSAGE);
        }else {
          String messaError = resp.ET_RETURN.item[0].MESSAGE;
          titleNotification = 'Error tecnico en la operacion segura';
          bodyNotification = 'Error: '+messaError+' ,contactar al administrador del sistema...';
          oppData.CEN_MessageError__c = messaError;
          generatedMapResp.put('error', messaError);
        }
        oppData.CEN_LastApiCall__c = System.now();
        oppData.CEN_Processing__c = false;
        update oppData;
        myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
        List<Quote> qs = [SELECT Id, CEN_ProformaVersion__c, CreatedDate FROM Quote WHERE OpportunityId = :oppId order by CreatedDate desc];
        if(qs.size() > 0 && versionProforma > 0){
            qs[0].CEN_ProformaVersion__c = versionProforma;
            update qs[0];
        }
      }else{
        String messaError = 'El propietario de la oportunidad no tiene número de empleado.';
        bodyNotification = messaError;
        myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
        oppData.CEN_MessageError__c = messaError;
        oppData.CEN_Processing__c = false;
        update oppData;
        generatedMapResp.put('error', messaError);
      }
    }
    return generatedMapResp;
  }

  private static void myNotification (String notiTitle, String notiBody, String notiTarget, Set<String> notiRecipients ){
    String notiId = [SELECT Id, DeveloperName
                      FROM CustomNotificationType
                      WHERE DeveloperName = 'Notificacin_de_la_organizacin' ].Id;

    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle(notiTitle);
    notification.setBody(notiBody);
    notification.setNotificationTypeId(notiId);
    notification.setTargetId(notiTarget);
    notification.send(notiRecipients);
  }

  @future(callout=true)
  public static void generateAndUpdateOperationSafeAsinc(String oppIds) {
    try {
      Map<String, String> mapResp = generateAndUpdateOperation(oppIds);
    } catch (Exception ex) {
      Set<String> recipientId = new Set<String> {System.UserInfo.getUserId()};
      Opportunity opp = new Opportunity();
      opp.Id = oppIds;
      opp.CEN_Processing__c = false;
      update opp;
      myNotification ('Error Tecnico', 'Error: '+ex.getMessage()+'. Linea: '+ex.getLineNumber(), oppIds, recipientId );
    }
  }

  @InvocableMethod(label='processOperactionSafe')
  public static List<String> processOperactionSafe(List<FlowParameters> parameters){
    List<String> resp = new List<String>();
    if(parameters!=null && parameters.size()>0 && parameters[0].oppIds!=null && parameters[0].oppIds.size()>0 ){
      generateAndUpdateOperationSafeAsinc(parameters[0].oppIds[0]);
      resp.add(parameters[0].oppIds[0]+'inProccess');
    }else{
      resp.add('empty');
    }

  return resp;
  }

  public class FlowParameters {
		@InvocableVariable(label='oppIdsParamt' description='Ids Opportunities parameter' required=true)
		public List<String> oppIds;
  }

  @AuraEnabled(cacheable = true)
  public static Map<String, String> getSimulacionPrepago(Map<String,String> prepagoCampos) {
    Map<String, String> respPrepagoCampos = new Map<String, String>();
    respPrepagoCampos.put('cuotaFacilote',prepagoCampos.get('saldoInicial'));
    respPrepagoCampos.put('cuotasRestantes',prepagoCampos.get('saldoNroCuotas'));
    respPrepagoCampos.put('cuotaSaldo',prepagoCampos.get('fecha'));
    respPrepagoCampos.put('cantidadCuotaSaldo','sin proforma');
    return respPrepagoCampos;
  }

  @AuraEnabled(cacheable = true)
  public static Map<String,String> getSaldoInicialNroCuotas(String proforma) {

    Map<String,String> mapOppData = new Map<String,String>();
    Opportunity oppData = [SELECT Id,Name,CEN_Proforma__c,CEN_MontoCuotaInicialPrecioEspejo__c,CEN_N_Cuotas_del_Saldo_del_precio__c
        FROM Opportunity
        WHERE CEN_Proforma__c = :proforma];
    mapOppData.put('saldoInicial',oppData.CEN_MontoCuotaInicialPrecioEspejo__c.toPlainString());
    mapOppData.put('saldoNroCuotas',oppData.CEN_N_Cuotas_del_Saldo_del_precio__c.toPlainString());
    return mapOppData;
  }

}