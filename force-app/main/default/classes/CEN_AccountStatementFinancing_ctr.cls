/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 18-02-2022
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   18-02-2022   @everis.com   Initial Version
**/
public with sharing class CEN_AccountStatementFinancing_ctr {

    @future(callout=true)
    public static void updateAccountStatementFinancingAsync(){

        CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element myObjectElement = new CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element();

        Date dt = date.today();

        //dt = dt.addDays(14);  //COMENTAR PRUEBAS
        if(TEST.isRunningTest()){
            Integer numberOfDays = Date.daysInMonth(dt.year(), dt.month());
            dt = Date.newInstance(dt.year(), dt.month(), numberOfDays);
        }

        Date date16th = Date.newInstance(dt.year(), dt.month(), 16);
        Integer numberOfDays = Date.daysInMonth(dt.year(), dt.month());
        Date lastDayOfMonth = Date.newInstance(dt.year(), dt.month(), numberOfDays);

        if(dt == date16th || dt == lastDayOfMonth){

            Date dateStartDate = dt == date16th ? Date.newInstance(dt.year(), dt.month(), 1) : Date.newInstance(dt.year(), dt.month(), 17); //DESCOMENTAR

            String myStartDate = String.valueOfGmt(dateStartDate); //DESCOMENTAR
            String myEndDate =String.valueOfGmt(dt); //DESCOMENTAR

            // Time myStarttime = Time.newInstance(dt.hourGmt(),dt.minute(),dt.second(),0); //COMENTAR
            // Time myEndtime = Time.newInstance(dt.hourGmt(),dt.minute(),dt.second(),0); //COMENTAR

            //COMENTAR PRUEBAS - INICIO
            //String fechaCuotasaldo = '2022-03-10';
            // Date dateStartDate = Date.valueOf(fechaCuotasaldo);
            // String myStartDate = String.valueOfGmt(dateStartDate);
            // String myEndDate = String.valueOfGmt(dateStartDate);
            //COMENTAR PRUEBAS - FIN

            myObjectElement.I_FECHA_INI = myStartDate.substring(0, 10);
            myObjectElement.I_FECHA_FIN = myEndDate.substring(0, 10);
            myObjectElement.I_HORA_INI = '';
            myObjectElement.I_HORA_FIN = '';

            System.debug('myObjectElement: ' + myObjectElement);
            updateAccountStatementFinancing(myObjectElement);

        }

    }

    @InvocableMethod(label='invokeAccountStatementFinancing')
    public static void invokeAccountStatementFinancing(){
        updateAccountStatementFinancingAsync();
    }

    public static void updateAccountStatementFinancing(CEN_AccountStatementFinancingRequest.ZWS_CONSULTA_ENVIO_EC_element myObjectElement){

        System.debug('******updateAccountStatementFinancing');
        CEN_AccountStatementFinancingResponse resp = new CEN_AccountStatementFinancingResponse();

        try{
            List<CEN_AccountStatement__c> listAccSt = new List<CEN_AccountStatement__c>();
            List<String> listAccError = new List<String>();
            resp = CEN_AccountStatementFinancing_cls.getAccountStatementFinancing(myObjectElement);
            for(CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC r :resp.ET_LOG_ENVIO.item){
                //r.FECHA_ENVIO = '2022-12-01'; //BORRAR ESTA FILA
                Id  accId = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc =: r.CLIENTE_DOC_NRO or CEN_Numero_de_documento_del__c =: r.CLIENTE_DOC_NRO Limit 1].Id;
                //if(validateChanges(accId)){
                if(accId != null){
                    CEN_AccountStatement__c accSt = new CEN_AccountStatement__c();
                    accSt.CEN_Account__c = accId;
                    accSt.CEN_Client__c = r.CLIENTE_DOC_NRO;
                    accSt.CEN_Email__c = r.CORREO;
                    accSt.CEN_Status__c = r.ESTADO == '01' ? 'Enviado' : 'No enviado';
                    Datetime dt = DateTime.valueOfGmt(r.FECHA_ENVIO + ' ' + r.HORA_ENVIO);
                    Date myDate =date.newinstance(dt.year(), dt.month(), dt.day());
                    Time timeChange = Time.newInstance(dt.hourGmt(),dt.minute(),dt.second(),0);
                    accSt.CEN_ShippingDate__c = myDate;
                    accSt.CEN_ShippingTime__c = timeChange;
                    accSt.CEN_Proforma__c = r.PROFORMA;

                    listAccSt.add(accSt);
                }else{
                    listAccError.add(r.CLIENTE_DOC_NRO);
                }

                //}
            }

            if(listAccError.size() > 0){
                String msgEmail = 'Estimado Administrador, <br/><br/>';
                msgEmail += 'No se pudieron agregar los estados de cuentas de los siguientes clientes: <br/><br/>';
                msgEmail += listAccError;
                enviarEmailSoporteSF(msgEmail);
            }

            if(listAccSt.size() > 0){
                insert listAccSt;
                //upsert listAccSt CEN_AccountStatement__c.fields.CEN_Proforma__c;
            }

        } catch (Exception e) {
            System.debug('updateAccountStatementFinancing-error ' + e.getMessage());
            String msgEmail = 'Estimado Administrador, <br/><br/>';
            msgEmail += 'Hubo un error try catch: ' + e.getMessage() + '.Type: ' + e.getTypeName() + '.Line:' + e.getLineNumber() + '<br/><br/>';
            enviarEmailSoporteSF(msgEmail);
        }

    }

    public static void enviarEmailSoporteSF(String message){
        List<String> addresses = new List<String>();
        addresses.add('soportesf@nttdata.com');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();            
        email.setSubject('Notificación de Error en Envio de Estado de Cuenta');
        email.setHTMLBody(message);
        email.setToAddresses(addresses);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    // public static Boolean validateChanges(String accId, CEN_AccountStatementFinancingResponse.ZST_LOG_ENVIO_EC item){
    //     Boolean change = false;
    //     Account  acc = [SELECT CEN_Account__c,CEN_Client__c,CEN_Email__c,CEN_Status__c,CEN_ShippingDate__c,CEN_ShippingTime__c,CEN_Proforma__c
    //                       FROM CEN_AccountStatement__c
    //                       WHERE CEN_Account__c =: accId];

    //     if(acc != null && item.CLIENTE != acc.CEN_Client__c &&
    //        item.CORREO != CEN_Email__c &&
    //        item.ESTADO != CEN_Status__c &&
    //        item.FECHA_ENVIO != CEN_ShippingDate__c &&
    //        item.HORA_ENVIO != CEN_ShippingTime__c &&
    //        item.PROFORMA != CEN_Proforma__c){
    //         change = true;
    //     }else{
    //         change = false;
    //     }

    //     return change;
    // }

    // public class FlowParameters {
    //     @InvocableVariable(label = 'OPIdsParamts' description = 'Ids Ops parameters' required = true)
    //     public List<String> opIds;
    // }
}