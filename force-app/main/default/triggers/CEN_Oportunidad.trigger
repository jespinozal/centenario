trigger CEN_Oportunidad on Opportunity(before update, before insert) {
  private static Map<String, String> bandejas = new Map<String, String>();
  bandejas.put(label.CEN_onbase_id_bandeja_asesor, 'Asesor Inmobiliario');
  bandejas.put(label.CEN_onbase_id_bandeja_supervisor, 'Supervisor de Ventas');
  bandejas.put(
    label.CEN_onbase_id_bandeja_admin_ventas,
    'Administrador de Ventas'
  );
  bandejas.put(
    label.CEN_onbase_id_bandeja_sup_admin_ventas,
    'Supervisor de Admin. Ventas'
  );
  bandejas.put(
    label.CEN_onbase_id_bandeja_gerencia_comercial,
    'Gerencia Comercial'
  );
  bandejas.put('0', 'Concluídos');
  Map<Id, Account> cuentas = null;
  try {
    List<Id> accounts_id = new List<Id>();
    for (Opportunity op : Trigger.new) {
      if (String.isNotBlank(op.AccountId)) {
        accounts_id.add(op.AccountId);
      }
    }
    if (RecursiveTriggerHandler.isFirstTime) {
        // RecursiveTriggerHandler.isFirstTime = false;
    cuentas = new Map<Id, Account>(
      [
        SELECT Id, IsPersonAccount
        FROM Account
        WHERE Id IN :accounts_id
        LIMIT 50000
      ]
    );
    }
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
  if (Trigger.isBefore) {
       if (RecursiveTriggerHandler.isFirstTime) {
            RecursiveTriggerHandler.isFirstTime = false;
    if (Trigger.isInsert) {
             
      for (Integer i = 0; i < Trigger.new.size(); i++) {
        System.debug('Opportunity input: ' + Trigger.new[i]);
        if (
          cuentas.size() > 0 &&
          String.isNotBlank(Trigger.new[i].AccountId) &&
          cuentas.get(Trigger.new[i].AccountId) != null
        ) {
          if (cuentas.get(Trigger.new[i].AccountId).IsPersonAccount) {
            Trigger.new[i].Type = 'Natural';
          } else {
            Trigger.new[i].Type = 'Jurídica';
          }
        } else {
          Trigger.new[i].Type = null;
        }
      }
        //}
    }
    if (Trigger.isUpdate) {
    //if (RecursiveTriggerHandler.isFirstTime) {
      //  RecursiveTriggerHandler.isFirstTime = false;      
      for (Integer i = 0; i < Trigger.new.size(); i++) {
        System.debug('Opportunity input: ' + Trigger.new[i]);
        //System.debug(LoggingLevel.WARN, JSON.serialize(trigger.new[i]).replace(',', ',\n'));
        if (Trigger.new[i].CEN_onbase_id_bandeja__c != null) {
          String id_bandeja = String.valueOf(
            Trigger.new[i].CEN_onbase_id_bandeja__c.setScale(0)
          );
          Trigger.new[i].CEN_Bandeja_onbase_de_solicitud__c = bandejas.get(
            id_bandeja
          );
        }
        String link_solicitud_onbase = '';
        if (Trigger.new[i].CEN_Sub_estado__c == 'FINALIZADO') {
          //trigger.new[i].StageName='Oportunidad Ganada';
          //trigger.new[i].CEN_Sub_estado__c=null;
          Trigger.new[i].CEN_Bandeja_onbase_de_solicitud__c = bandejas.get('0');
          if (
            String.isNotBlank(Trigger.new[i].CEN_Nro_solicitud_presolicitud__c)
          ) {
            link_solicitud_onbase =
              label.CEN_url_bandeja_onbase +
              label.CEN_lbl_rutaAppOnbase +
              label.CEN_Onbase_DP_solicitud;
            if (String.isNotBlank(link_solicitud_onbase)) {
              link_solicitud_onbase = link_solicitud_onbase.replace(
                'ZZZZZ',
                Trigger.new[i].CEN_Nro_solicitud_presolicitud__c
              );
              Trigger.new[i].CEN_Link_Solicitud__c = link_solicitud_onbase;
            }
          }
        } else {
          if (
            String.isNotBlank(
              Trigger.new[i].CEN_Nro_solicitud_presolicitud__c
            ) && Trigger.new[i].CEN_onbase_id_bandeja__c != null
          ) {
            Trigger.new[i].CEN_Link_Solicitud__c =
              label.CEN_url_bandeja_onbase +
              label.CEN_lbl_rutaAppOnbase +
              '/Workflow/WFLogin.aspx?LifeCycleID=' +
              label.CEN_onbase_Id_ciclovida +
              '&QueueID=' +
              String.valueOf(
                Trigger.new[i].CEN_onbase_id_bandeja__c.setScale(0)
              ) +
              '&DocID=' +
              Trigger.new[i].CEN_Onbase_documento_id__c;
          }
        }
        if (
          cuentas.size() > 0 &&
          String.isNotBlank(Trigger.new[i].AccountId) &&
          cuentas.get(Trigger.new[i].AccountId) != null
        ) {
          if (cuentas.get(Trigger.new[i].AccountId).IsPersonAccount) {
            Trigger.new[i].Type = 'Natural';
          } else {
            Trigger.new[i].Type = 'Jurídica';
          }
        } else {
          Trigger.new[i].Type = null;
        }
        //System.debug(LoggingLevel.WARN, JSON.serialize(trigger.new[i]).replace(',', ',\n'));
        System.debug('Opportunity output: ' + Trigger.new[i]);
      }
       // }
    }
       }
  }
}