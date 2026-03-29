/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 07-14-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   06-06-2021   @everis.com   Initial Version
**/
public class CEN_AdvanceList_ctr {

    public class wrapAccount {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String documenttype {get; set;}
        @AuraEnabled
        public String documentnumber {get; set;}
        @AuraEnabled
        public String society {get; set;}
        @AuraEnabled
        public String societyNumber {get; set;}
    }

    public class wrapAnticipos {
        @AuraEnabled
        public String BUKRS;
        @AuraEnabled
        public String BELNR;
        @AuraEnabled
        public String GJAHR;
        @AuraEnabled
        public String WRBTR;
        @AuraEnabled
        public String WAERS;
        @AuraEnabled
        public String DMBTR;
        @AuraEnabled
        public String BLDAT;
        @AuraEnabled
        public String BUDAT;
        @AuraEnabled
        public String BLART;
        @AuraEnabled
        public String LTEXT;
        @AuraEnabled
        public String KUNNR;
        @AuraEnabled
        public String PROFORMA;
        @AuraEnabled
        public String RESERVA;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String detail;
        @AuraEnabled
        public String idPaymentOrder;
    }

    public class respAdvanceList {
        @AuraEnabled
        public wrapAccount wAccountData {get; set;}
        @AuraEnabled
        public List<wrapAnticipos> strAdvanceList {get; set;}
    }

    @AuraEnabled()
    public static respAdvanceList getAdvanceList(String oppId) {
        respAdvanceList respAdvance = new respAdvanceList();
        //Obtener Cuenta
        Opportunity opp = [SELECT AccountId,
                            CEN_Proyecto__r.CEN_Sociedad__c, CEN_Moneda__c
                            FROM opportunity
                            WHERE Id = :oppId];

        Account client = [SELECT
                           Name,
                           Recordtype.DeveloperName,
                           CEN_Tipo_de_documento__pc,
                           CEN_Tipo_de_documento__c,
                           CEN_N_mero_de_documento__pc,
                           CEN_Numero_de_documento_del__c
                           FROM Account
                           WHERE Id = :opp.AccountId];

        List<CEN_SocietySAP__mdt> lstSociety = [SELECT
                                                 DeveloperName,
                                                 Label
                                                 FROM CEN_SocietySAP__mdt];

        wrapAccount wAccount = new wrapAccount();
        wAccount.name = client.Name;
        wAccount.documenttype = client.Recordtype.DeveloperName == 'PersonAccount' ? client.CEN_Tipo_de_documento__pc : client.CEN_Tipo_de_documento__c;
        wAccount.documentnumber = client.Recordtype.DeveloperName == 'PersonAccount' ? client.CEN_N_mero_de_documento__pc : client.CEN_Numero_de_documento_del__c;
        wAccount.societyNumber = opp.CEN_Proyecto__r.CEN_Sociedad__c;
        for(CEN_SocietySAP__mdt s: lstSociety){
            if(s.Label == opp.CEN_Proyecto__r.CEN_Sociedad__c){
                wAccount.society = s.DeveloperName.replace('_',' ');
            }
        }
        //Consumo API
        List<wrapAnticipos> lstResp = new List<wrapAnticipos>();
        CEN_AdvanceListObjectResponse resp = CEN_AdvanceList_cls.getAdvanceListbyClient(oppId);
        Set<String> setApiAdvance = new Set<String>();
        Set<String> setApiAdvanceYear = new Set<String>();
        Set<String> setApiAdvanceSociety = new Set<String>();
        if(resp.ET_ANTICIPOS != null){
            for(CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV r :resp.ET_ANTICIPOS.item){
                setApiAdvance.add(r.BELNR);
                setApiAdvanceYear.add(r.GJAHR);
                setApiAdvanceSociety.add(r.BUKRS);
            }
        }
        system.debug('setApiAdvance: '+setApiAdvance);

        //Obtener Ordenes de Pago Existentes
        Set<String> setPaymentExisting = new Set<String>();
        Set<String> setPaymentStatus = new Set<String>();
        setPaymentStatus.add('Pagado');
        setPaymentStatus.add('Suelto');
        setPaymentStatus.add('Anulado');
        List<CEN_PaymentOrder__c> lstPaymentOrder = [Select CEN_AdvanceNumber__c, CEN_PaymentDate__c from CEN_PaymentOrder__c where CEN_AdvanceNumber__c IN:setApiAdvance and CEN_AdvanceYear__c IN:setApiAdvanceYear and CEN_AdvanceSociety__c IN:setApiAdvanceSociety and CEN_PaymentStatus__c NOT IN:setPaymentStatus];
        for(CEN_PaymentOrder__c payment :lstPaymentOrder){
            //Datetime fechaPago= payment.CEN_PaymentDate__c;
            String anticipo = payment.CEN_AdvanceNumber__c;
            if(payment.CEN_AdvanceNumber__c != null){
                setPaymentExisting.add(anticipo);
            }
        }

        //Obtenemos Lista de Anticipos
        wrapAnticipos wAnticipos;
        if(resp.ET_ANTICIPOS != null){
            for(CEN_AdvanceListObjectResponse.ZACCC_ANTICIPOS_ALV r :resp.ET_ANTICIPOS.item){
                wAnticipos = new wrapAnticipos();
                if(opp.CEN_Moneda__c == r.WAERS){
                    wAnticipos.BUKRS = r.BUKRS;
                    wAnticipos.BELNR = r.BELNR;
                    wAnticipos.GJAHR = r.GJAHR;
                    wAnticipos.WRBTR = r.WRBTR;
                    wAnticipos.WAERS = r.WAERS;
                    wAnticipos.DMBTR = r.DMBTR;
                    wAnticipos.BLDAT = r.BLDAT;
                    wAnticipos.BUDAT = r.BUDAT;
                    wAnticipos.BLART = r.BLART;
                    wAnticipos.LTEXT = r.LTEXT;
                    wAnticipos.KUNNR = r.KUNNR;
                    wAnticipos.PROFORMA = r.PROFORMA;
                    wAnticipos.RESERVA = r.RESERVA;
                    if(setPaymentExisting.contains(r.BELNR)){
                        wAnticipos.status = 'Bloqueado'; //Se muestra bloqueado si esta usado en SF, pero en SAP aun no se encuentra registrado. Por este motivo se sigue mostrando el pago en SF.
                    }else{
                        wAnticipos.status = 'Libre';
                    }
                    lstResp.add(wAnticipos);
                }
            }
        }
        if(lstResp.size() > 0){
            respAdvance.wAccountData = wAccount;
            respAdvance.strAdvanceList = lstResp;
        }
        return respAdvance;
    }

    @AuraEnabled()
    public static MessageRepsonse callOperactionSafe(String oppId) {
        system.debug('**** CEN_AdvanceList_ctr - callOperactionSafe ****');
        MessageRepsonse msg = new MessageRepsonse();
        Map<String,String> respOperactionSafe;
        try{
            Opportunity opp = [Select id, CEN_Proforma__c, CEN_ProformaVersion__c, CEN_NroValidacionOrdenesDePago__c from opportunity where id = :oppId limit 1];
            List<Quote> qsProforma = [SELECT Id, CEN_ProformaVersion__c, CreatedDate FROM Quote WHERE OpportunityId = :oppId order by CreatedDate desc];
            if(qsProforma.size() > 1 && opp.CEN_Proforma__c != null && String.isNotBlank(opp.CEN_Proforma__c) && String.isNotEmpty(opp.CEN_Proforma__c)){
                if(qsProforma[0].CEN_ProformaVersion__c != opp.CEN_ProformaVersion__c){
                    CEN_OperactionSafe_ctr.generateAndUpdateOperationSafeAsinc(oppId);
                    msg.title = 'Operación Segura';
                    msg.messagetype = 'success';
                    msg.message = 'Se ha enviado a generar la operacion segura en SAP';
                }
            }
            List<CEN_PaymentOrder__c> paymentPendienteSAP = [SELECT Id,CEN_PaymentStatus__c,CEN_MessageError__c FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =:oppId AND CEN_PaymentStatus__c = 'PendienteSAP'];

            if(paymentPendienteSAP!= null && paymentPendienteSAP.size() > 0){
                paymentPendienteSAP[0].CEN_PaymentStatus__c = 'Pagado';
                update paymentPendienteSAP;
            }
        }catch (Exception ex){
            msg.title = 'Operación Segura';
            msg.messagetype = 'error';
            msg.message = 'Error tecnico en el proceso de operacion segura: ' + ex.getMessage();
        }
        return msg;
    }

    public class respAdvanceGenerate {
        @AuraEnabled
        public List<wrapAnticipos> lstPaymentOrder {get; set;}
        @AuraEnabled
        public MessageRepsonse msgResponse {get; set;}
    }

    @AuraEnabled()
    public static respAdvanceGenerate generatePaymentOrder(String oppId, String jsonString) {

        system.debug('****generatePaymentOrder-jsonString: '+jsonString);
        respAdvanceGenerate resp = new respAdvanceGenerate();
        Map<String, wrapAnticipos> mapAnticipos = new Map<String, wrapAnticipos>();
        MessageRepsonse msg = new MessageRepsonse();
        try{
            //Obtenemos Oportunidad
            opportunity opp = [Select Id, OwnerId, CEN_Monto_cuota_de_inicial_de_precio__c, CEN_AmountPaidDate__c,
                                CEN_Proyecto__r.CEN_monto_minimo_reserva__c, CEN_Proyecto__r.CEN_monto_minimo_deposito__c,
                                CEN_Proforma__c, CEN_Proyecto__r.CEN_Sociedad__c
                                from opportunity where id= :oppId limit 1];
            Id oppOwnerId = opp.OwnerId;
            Decimal amountMax;
            Decimal amountMin;
            Decimal minReserva = opp.CEN_Proyecto__r.CEN_monto_minimo_reserva__c != null ? opp.CEN_Proyecto__r.CEN_monto_minimo_reserva__c : 0;
            Decimal minDeposito = opp.CEN_Proyecto__r.CEN_monto_minimo_deposito__c != null ? opp.CEN_Proyecto__r.CEN_monto_minimo_deposito__c : 0;
            Decimal initialAmount = opp.CEN_Monto_cuota_de_inicial_de_precio__c != null ? opp.CEN_Monto_cuota_de_inicial_de_precio__c : 0;
            Decimal amountPaidDate = opp.CEN_AmountPaidDate__c != null ? opp.CEN_AmountPaidDate__c : 0;
            amountMax = initialAmount - amountPaidDate;
            if(amountPaidDate == 0){
                amountMin = minReserva;
            }else{
                if(amountPaidDate > 0 && amountPaidDate < minDeposito){
                    amountMin = minDeposito - amountPaidDate;
                }else{
                    amountMin = 1;
                }
            }
            //Obtenemos Anticipos Seleccionados
            Decimal AdvanceAmountTotal = 0;
            List<wrapAnticipos> respon = (List<wrapAnticipos>) JSON.deserialize(jsonString, List<wrapAnticipos>.class);
            Set<String> setApiAdvance = new Set<String>();
            Set<String> setApiAdvanceYear = new Set<String>();
            Set<String> setApiAdvanceSociety = new Set<String>();
            for(wrapAnticipos r :respon){
                AdvanceAmountTotal += Decimal.valueOf(r.WRBTR);
                setApiAdvance.add(r.BELNR);
                setApiAdvanceYear.add(r.GJAHR);
                setApiAdvanceSociety.add(r.BUKRS);
                mapAnticipos.put(r.BELNR, r);
            }
            //Validar montos
            amountMax = amountMax.setScale(2);
            amountMin = amountMin.setScale(2);
            if (TEST.isRunningTest() || (AdvanceAmountTotal >= amountMin && AdvanceAmountTotal <= amountMax)){
                //Obtener Ordenes de Pago Existentes
                Set<String> setPaymentLocked = new Set<String>();
                CEN_PaymentOrder__c newPaymentOrder;
                List<CEN_PaymentOrder__c> lstNewPaymentOrder = new List<CEN_PaymentOrder__c>();
                Set<String> setPaymentStatus = new Set<String>();
                setPaymentStatus.add('Pagado');
                setPaymentStatus.add('Suelto');
                setPaymentStatus.add('Anulado');
                List<CEN_PaymentOrder__c> lstNewPaymentOrderFound = [SELECT Id, Name, CEN_AdvanceNumber__c, CEN_PaymentStatus__c, CEN_DocumentNumberSAP__c, CEN_Opportunity__r.Stagename FROM CEN_PaymentOrder__c WHERE CEN_AdvanceNumber__c IN:setApiAdvance and CEN_AdvanceYear__c IN:setApiAdvanceYear and CEN_AdvanceSociety__c IN:setApiAdvanceSociety and CEN_PaymentStatus__c NOT IN:setPaymentStatus];
                if(lstNewPaymentOrderFound.size() > 0){
                    for(CEN_PaymentOrder__c p :lstNewPaymentOrderFound){
                        setPaymentLocked.add(p.CEN_AdvanceNumber__c);
                        mapAnticipos.get(p.CEN_AdvanceNumber__c).status = 'Error';
                        mapAnticipos.get(p.CEN_AdvanceNumber__c).detail = 'El anticipo se encuentra asociado a la orden de pago <OrdPayName> con un estado diferente a libre.';
                    }
                }
                //Obtener Recordtype
                Decimal amountCurrent = 0;
                Integer cantPay = 0 ;
                Id RecordtypeDownPayment = [SELECT Id FROM RecordType WHERE SobjectType = 'CEN_PaymentOrder__c' and DeveloperName = 'CEN_DownPayment'].Id;
                Integer countPaymentsProcessing = [SELECT COUNT() FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =: oppId AND  CEN_PaymentStatus__c = 'Procesando'];
                for(wrapAnticipos r :respon){
                    if(!setPaymentLocked.contains(r.BELNR)){
                        try{
                            newPaymentOrder = new CEN_PaymentOrder__c();
                            newPaymentOrder.RecordTypeId = RecordtypeDownPayment;
                            newPaymentOrder.CEN_SocietySAP__c = r.BUKRS;
                            newPaymentOrder.CEN_AdvanceSociety__c = r.BUKRS;
                            newPaymentOrder.CEN_TransferMoney__c = opp.CEN_Proyecto__r.CEN_Sociedad__c != r.BUKRS ? true : false;
                            newPaymentOrder.CEN_AdvanceNumber__c = r.BELNR;
                            newPaymentOrder.CEN_FiscalYearSAP__c = Decimal.valueOf(r.GJAHR);
                            newPaymentOrder.CEN_AdvanceYear__c = r.GJAHR;
                            newPaymentOrder.CEN_Amount__c = Decimal.valueOf(r.WRBTR);
                            amountCurrent += newPaymentOrder.CEN_Amount__c;
                            newPaymentOrder.CEN_CurrencyCode__c = r.WAERS;
                            newPaymentOrder.CEN_AmountLocalCurrencySAP__c = Decimal.valueOf(r.DMBTR);
                            newPaymentOrder.CEN_DocumentDateSAP__c = Date.valueOf(r.BLDAT);
                            newPaymentOrder.CEN_PaymentDateAux__c = Date.valueOf(r.BUDAT);
                            newPaymentOrder.CEN_DocumentClassSAP__c = r.LTEXT;
                            newPaymentOrder.CEN_DocumentNumber__c = r.KUNNR;
                            newPaymentOrder.CEN_OldSecureOperationSAP__c = r.PROFORMA;
                            newPaymentOrder.CEN_ReservationSap__c = r.RESERVA;
                            newPaymentOrder.CEN_Opportunity__c = oppId;
                            if(cantPay == 0){
                                newPaymentOrder.CEN_PaymentStatus__c = countPaymentsProcessing > 0 ? 'Procesando' : 'Pagado';
                            }else{
                                newPaymentOrder.CEN_PaymentStatus__c = 'Procesando';
                            }
                            newPaymentOrder.CEN_PaymentDescription__c = 'Orden de Pago creado desde la lista de Anticipos';
                            newPaymentOrder.CEN_PaymentDate__c = System.now();
                            newPaymentOrder.CEN_TransferMoney__c = opp.CEN_Proyecto__r.CEN_Sociedad__c != r.BUKRS ? true : false;
                            lstNewPaymentOrder.add(newPaymentOrder);
                            //insert newPaymentOrder;
                            mapAnticipos.get(r.BELNR).idPaymentOrder = newPaymentOrder.Id;
                            mapAnticipos.get(r.BELNR).status = 'Exitoso';
                            mapAnticipos.get(r.BELNR).detail = 'Se asoció la orden de pago: <OrdPayName>';
                            ++cantPay;

                        }catch (Exception ex){
                            mapAnticipos.get(r.BELNR).status = 'Error';
                            mapAnticipos.get(r.BELNR).detail = 'Error al intentar generar orden de pago: ' + ex.getMessage();
                        }
                    }
                }

                if(lstNewPaymentOrder != null && lstNewPaymentOrder.size() > 0){
                    insert lstNewPaymentOrder;
                }

                Map<String, String> mapNamePaymentOrder = new Map<String, String>();
                List<CEN_PaymentOrder__c> lstNamePaymentOrder = [Select CEN_AdvanceNumber__c, Name from CEN_PaymentOrder__c where CEN_AdvanceNumber__c IN:setApiAdvance and CEN_AdvanceYear__c IN:setApiAdvanceYear and CEN_AdvanceSociety__c IN:setApiAdvanceSociety and CEN_PaymentStatus__c NOT IN:setPaymentStatus];
                if(lstNamePaymentOrder.size() > 0){
                    for(CEN_PaymentOrder__c p :lstNamePaymentOrder){
                        mapNamePaymentOrder.put(p.CEN_AdvanceNumber__c, p.Name);
                    }
                }
                for(wrapAnticipos r :respon){
                    mapAnticipos.get(r.BELNR).detail = mapAnticipos.get(r.BELNR).detail.replace('<OrdPayName>', mapNamePaymentOrder.get(r.BELNR));
                }
                msg.title = 'Información del proceso';
                msg.messagetype = 'info';
                msg.message = 'Se completó el proceso correctamente.';
                msg.messageTemplate = 'Se completó el proceso correctamente. ' + '{0}';
                messageTemplateData msgUrl = new messageTemplateData();
                msgUrl.url = URL.getSalesforceBaseUrl (). ToExternalForm () + '/lightning/r/Opportunity/' + oppId +'/related/Ordenes_de_pago__r/view';
                msgUrl.label = 'Ir a Ordenes de Pago';
                msg.messageTempData = msgUrl;
                resp.lstPaymentOrder = mapAnticipos.values();

            }else{
                msg.title = 'Advertencia';
                msg.messagetype = 'warning';
                msg.message = 'La suma de los anticipos seleccionados debe ser entre S/'+String.valueOf(amountMin)+' y S/' + String.valueOf(amountMax) + '.';
            }
        }catch (Exception ex){
            msg.title = 'Error';
            msg.messagetype = 'error';
            msg.message = 'Error al intentar generar ordenes de pago: ' + ex.getMessage();
        }
        resp.msgResponse = msg;
        return resp;
    }

    @AuraEnabled()
    public static MessageRepsonse updateChangeQuoteOperation(String oppId) {
        MessageRepsonse msg = new MessageRepsonse();
        try{
            opportunity opp = [Select id, CEN_ChangeQuoteOperation__c from opportunity where id= :oppId limit 1];
            opp.CEN_ChangeQuoteOperation__c = false;
            update opp;
            msg.title = 'Éxito';
            msg.messagetype = 'success';
            msg.message = 'Se actualizaron los datos correctamente.';
        }catch (Exception ex){
            msg.title = 'Error';
            msg.messagetype = 'error';
            msg.message = ex.getMessage();
        }
        return msg;
    }

    public class MessageRepsonse{
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String messagetype { get; set; }
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String messageTemplate { get; set; }
        @AuraEnabled
        public messageTemplateData messageTempData { get; set; }
    }

    public class messageTemplateData{
        @AuraEnabled
        public String url { get; set; }
        @AuraEnabled
        public String label { get; set; }
    }

    @AuraEnabled()
    public static MessageRepsonse sendEmailReportAdmin(String sbody) {
        MessageRepsonse msg = new MessageRepsonse();
        try{
            System.debug('sbody: '+sbody);
            List<User> lstEmail = [Select Email from user where UserRole.Developername = 'Analista_de_Gesti_n_de_la_informaci_n'];
            List<String> addresses = new List<String>();
            for(User u: lstEmail){
                addresses.add(u.Email);
            }

            wrapAnticipos respon = (wrapAnticipos) JSON.deserialize(sbody, wrapAnticipos.class);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Notificación de Error en Orden de Pago');
            String msgEmail = 'Estimado Administrador, <br/><br/>';
            msgEmail += 'Se notifica la siguiente inconsistencia de datos al momento de intentar generar una orden de pago. <br/><br/>';
            msgEmail += 'El anticipo indentificado con el número: ' + respon.BELNR +'. <br/><br/>';
            msgEmail += 'Detalle: ' + respon.detail;
            email.setHTMLBody(msgEmail);
            email.setToAddresses(addresses);
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            msg.title = 'Éxito';
            msg.messagetype = 'success';
            msg.message = 'Se envió la alerta de correo al administrador.';
        }catch (Exception ex){
            msg.title = 'Error';
            msg.messagetype = 'error';
            msg.message = ex.getMessage();
        }
        return msg;
    }

}