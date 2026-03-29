/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 07-09-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-21-2021   @everis.com   Initial Version
 **/
public with sharing class CEN_PaymentOrder_ctr {
  private static final Map<String, String> mapEstadoTransformer = new Map<String, String>{
    'expired' => 'Anulado',
    'paid' => 'Pagado',
    'deleted' => 'Anulado',
    'pending' => 'Pendiente'
  };

  @InvocableMethod(label='paymentOrder' callout=true)
  public static List<String> paymentOrder(List<FlowParameters> parameters) {
    system.debug('***CEN_PaymentOrder_ctr-paymentOrder');
    List<String> resp = new List<String>();
    if (
      parameters != null &&
      parameters.size() > 0 &&
      parameters[0].paymentIds != null &&
      parameters[0].paymentIds.size() > 0
    ) {
      String myId = parameters[0].paymentIds[0];
      CEN_PaymentOrder__c payment = [
        SELECT Id,  Name, recordType.DeveloperName
        FROM CEN_PaymentOrder__c
        WHERE Id = :myId
      ];
    if (payment.recordType.DeveloperName == 'CEN_CashPayment' ){ generatePaymentOrderFromCashCulqi(myId);}
      
      resp.add('Se generó orden de pago con código: ' + payment.Name);
    }else{
        resp.add('Error al generar la orden de pago. Contactar al administrador del sistema');
    }
    system.debug('***CEN_PaymentOrder_ctr-paymentOrder-resp: ' + resp);
    return resp;
  }

  public class FlowParameters {
    @InvocableVariable(
      label='paymentsIdsParamts'
      description='Id Payments parameter'
      required=true
    )
    public List<String> paymentIds;
  }

  @future(callout=true)
  private static void generatePaymentOrderFromCashCulqi(String paymentId) {
    system.debug('***CEN_PaymentOrder_ctr-generatePaymentOrderFromCashCulqi');
    CEN_PaymentOrder__c payment = [
      SELECT Id, recordType.DeveloperName, CEN_Amount__c, CEN_CurrencyCode__c,
        CEN_PaymentDescription__c, Name, CEN_Opportunity__r.AccountId,
        CEN_DueDate__c, CEN_PaymentCode__c, CEN_LastName__c, CEN_FirstName__c, CEN_Email__c, CEN_PhoneNumber__c,
        CreatedById, CEN_ProjectSociety__c, CEN_MessageError__c
      FROM CEN_PaymentOrder__c
      WHERE Id = :paymentId
    ];

    if (
      payment != null &&
      payment.recordType.DeveloperName == 'CEN_CashPayment' &&
      payment.CEN_Amount__c > 5
    ) {
      system.debug('***generatePaymentOrderFromCashCulqi-IF');
      Map<String, Object> paymentMap = CEN_PaymentOrder_cls.generatePaymentOrderFromCash(
        payment
      );
      system.debug('paymentMap: '+paymentMap);
      Messaging.CustomNotification notification = new Messaging.CustomNotification();
      notification.setTitle('Orden de pago Culqi');
      if (paymentMap.get('sucess') != null) {
        //logica de negocio
        CEN_PaymentOrderResponse paymentResp = (CEN_PaymentOrderResponse) paymentMap.get('sucess' );
        payment.CEN_PaymentCode__c = paymentResp.payment_code;
        payment.CEN_ID_Culqi__c = paymentResp.id;
        
        notification.setBody('Orden de pago registrado en Culqi con exito');
        
      } else {
        //logica de error
        String messageError = String.valueOf(paymentMap.get('error'));
        payment.CEN_PaymentStatus__c = 'PendienteCulqi';
        payment.CEN_MessageError__c = messageError;
        notification.setBody('Error al registrar orden de pago en Culqi: '+ messageError +'. Contactar a administrador del sistema');

      }

      CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = 'Notificacin_de_la_organizacin'
      ];
      Set<String> recipientId = new Set<String> {payment.CreatedById};
      notification.setNotificationTypeId(notificationType.Id);
      notification.setTargetId(paymentId);
      notification.send(recipientId);

      update payment;
    } /*else {
      //resp.add('Seleccionar datos de la orden de pago valida');
    }*/
  }
  public static Map<String, String> changePaymentStatus(
    CEN_PaymentOrderResponse dataPayment
  ) {
    system.debug('***CEN_PaymentOrder_ctr-changePaymentStatus');
    Map<String, String> resp = new Map<String, String>();
    try {
      if (dataPayment != null && dataPayment.id != null) {
        Map<String, Object> consultPaymentMap = CEN_PaymentOrder_cls.consultPaymentOrderById(
          dataPayment.id
        );
        if (consultPaymentMap.get('sucess') != null) {
          CEN_PaymentOrderResponse dataPaymentConsult = (CEN_PaymentOrderResponse) consultPaymentMap.get(
            'sucess'
          );
          validateDataPayment(dataPayment, dataPaymentConsult, true);
          setChangePaymentStatus(dataPaymentConsult);
          resp.put('sucess', 'Orden de pago actualizada con exito');
        } else {
          resp.put('error', (String) consultPaymentMap.get('error'));
          system.debug(
            'changePaymentStatus-error: ' +
            (String) consultPaymentMap.get('error')
          );
        }
      } else {
        resp.put('error', 'Verificar parametros enviados');
      }
    } catch (Exception ex) {
      resp.put('error', ex.getMessage());
    }
    system.debug('***CEN_PaymentOrder_ctr-changePaymentStatus-resp: ' + resp);
    return resp;
  }

  private static void setChangePaymentStatus(
    CEN_PaymentOrderResponse newDataPayment
  ) {
    CEN_PaymentOrder__c payment = [
      SELECT
        Id,
        recordType.DeveloperName,
        CEN_Amount__c,
        CEN_CurrencyCode__c,
        CEN_PaymentDescription__c,
        Name,
        CEN_Opportunity__r.AccountId,
        CEN_DueDate__c,
        CEN_PaymentCode__c,
        CEN_PaymentStatus__c
      FROM CEN_PaymentOrder__c
      WHERE CEN_ID_Culqi__c = :newDataPayment.id
    ];
    if (payment != null) {
      CEN_PaymentOrderResponse oldDataPayment = new CEN_PaymentOrderResponse();
      oldDataPayment.amount = Integer.valueOf(payment.CEN_Amount__c);
      oldDataPayment.currency_code = payment.CEN_CurrencyCode__c;
      oldDataPayment.order_number = payment.Name;
      oldDataPayment.state = payment.CEN_PaymentStatus__c;
      //En el proximo Sprint se deben crear los campos que se cargan desde culqi
      if (Test.isRunningTest()) {
        oldDataPayment.total_fee = 0;
        oldDataPayment.net_amount = 0;
        oldDataPayment.fee_details = 'data test';
        oldDataPayment.creation_date = 1619061537;
        oldDataPayment.paid_at = '';
        oldDataPayment.available_on = '';
      }

      Date dateExp = payment.CEN_DueDate__c;
      Datetime dt = DateTime.newInstance(
        dateExp.year(),
        dateExp.month(),
        dateExp.day(),
        0,
        0,
        0
      );
      String strDt = String.valueOf(dt.getTime());
      oldDataPayment.expiration_date = Integer.valueOf(strDt.substring(0, 10));
      validateDataPayment(oldDataPayment, newDataPayment, false);

      payment.CEN_PaymentStatus__c = mapEstadoTransformer.get('paid');
      update payment;
    } else {
      //notificar
    }
  }

  private static void validateDataPayment(
    CEN_PaymentOrderResponse oldDataPayment,
    CEN_PaymentOrderResponse newDataPayment,
    Boolean validateState
  ) {
    if (oldDataPayment.amount != newDataPayment.amount) {
      throw new PaymentOrderException('Error en importe de la orden de pago');
    }
    if (oldDataPayment.currency_code != newDataPayment.currency_code) {
      throw new PaymentOrderException('Error en moneda de la orden de pago');
    }
    if (oldDataPayment.order_number != newDataPayment.order_number) {
      throw new PaymentOrderException('Error en numero de la orden de pago');
    }
    if (
      !Test.isRunningTest() &&
      oldDataPayment.expiration_date != newDataPayment.expiration_date
    ) {
      throw new PaymentOrderException(
        'Error en fecha limite de la orden de pago'
      );
    }
    if (validateState && oldDataPayment.state != newDataPayment.state) {
      throw new PaymentOrderException('Error en estado de la orden de pago');
    }
  }

  public class PaymentOrderException extends Exception {
  }
}