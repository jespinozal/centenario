@RestResource(urlMapping='/annulmentPaymentOrder/*')
global class CEN_UpdatePaymentDocumentService_cls {

    @HttpPut
    global static ResponseWrap upsertPaymentOrder() {
        ResponseWrap paymentOrdersResp = new ResponseWrap();
        try {

            Map<String, Object> paymentMeta = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            List<Object> paymentObjectsMeta = (List<Object>)paymentMeta.get('payments');

            List<Object> paymentObjects = new List<Object>();

            Map<String, Object> anuladosMeta = (Map<String, Object>)paymentObjectsMeta[0];
            Map<String, Object> nuevosMeta = (Map<String, Object>)paymentObjectsMeta[1];
            If((Map<String, Object>)paymentObjectsMeta[1] == null){throw new PaymentException('Error de Bad Request, por favor revisar.');}

            List<Object> anulados = (List<Object>)anuladosMeta.get('anulados');
            List<Object> nuevos = (List<Object>)nuevosMeta.get('nuevos');

            If(anulados.size() == 0){throw new PaymentException('No se encontraron pagos a anular, por favor revisar.');}
            If(nuevos.size() == 0){throw new PaymentException('No se encontraron pagos nuevos, por favor revisar.');}

            paymentObjects.addAll(anulados);
            paymentObjects.addAll(nuevos);

            List<PaymentOrder> paymentOrders = new List<PaymentOrder>();
            List<String> documentNumberList = new List<String>();
            Set<String> proformasSet = new Set<String>();

            for (Object paymentObj : paymentObjects) {

                Map<String,Object> payment = (Map<String,Object>)paymentObj;

                PaymentOrder por = new PaymentOrder();

                String proforma = (String)payment.get('PROFORMA');
                if (proforma != null) {
                    por.PROFORMA = proforma.leftPad(10, '0');
                }
                por.BELNR = (String)payment.get('BELNR');

                String opeFecha = (String)payment.get('OPE_FECHA');
                if (opeFecha != null) {
                    por.OPE_FECHA = Datetime.valueOf(opeFecha);
                }

                por.BUKRS = (String)payment.get('BUKRS');
                por.GJAHR = (Decimal)payment.get('GJAHR');
                por.OPE_IMPORTE = (Decimal)payment.get('OPE_IMPORTE');
                por.WAERS = (String)payment.get('WAERS');
                por.VIA_PAGO = (String)payment.get('VIA_PAGO');
                por.PAGO_EXTRANJERO = (boolean)payment.get('PAGO_EXTRANJERO');
                por.DESCRIPCION = 'Pago con Doc SAP: '+(String)payment.get('BELNR');
                // Campos Transferencia
                por.OPE_NUMERO = (String)payment.get('OPE_NUMERO');
                por.NRO_CTA_BANCO = (String)payment.get('NRO_CTA_BANCO');
                String fecContab = (String)payment.get('FEC_CONTAB');
                if (fecContab != null) {
                    por.FEC_CONTAB = Datetime.valueOf(fecContab);
                }
                // Fin Campos Transferencia

                // Campos POS
                String nroTarjeta = (String)payment.get('NRO_TARJETA');
                if (nroTarjeta != null) {
                    por.NRO_TARJETA = nroTarjeta.right(4);
                }
                por.REFERENCIA = (String)payment.get('REFERENCIA');
                por.PAIS_BANCO = (String)payment.get('PAIS_BANCO');
                por.CLAVE_BANC = (String)payment.get('CLAVE_BANC');
                por.COMIS_CULQI = (Decimal)payment.get('COMIS_CULQI');
                String fechaCulqi = (String)payment.get('FECHA_CULQI');
                if (fechaCulqi != null) {
                    por.FECHA_CULQI = Datetime.valueOf(fechaCulqi);
                }
                // Fin Campos POS

                paymentOrders.add(por);

                proformasSet.add(por.PROFORMA);
                documentNumberList.add(por.BELNR);
            }

            Map<String, Map<String,CEN_PaymentOrder__c>> poByProforma = new Map<String, Map<String,CEN_PaymentOrder__c>>();

            Map<String, Opportunity> oppByProforma = new Map<String, Opportunity>();
            for (CEN_PaymentOrder__c poQueried :  [SELECT Id,
                                            CEN_Opportunity__c,
                                            CEN_Opportunity__r.CEN_Proforma__c,
                                            CEN_DocumentNumberSAP__c,
                                            CEN_Reference__c,
                                            CEN_PaymentCode__c,
                                            CEN_PaymentStatus__c,
                                            CEN_Opportunity__r.CEN_AmountPaidDate__c,
                                            CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c,
                                            CEN_Opportunity__r.CEN_Moneda__c,
                                            CEN_Amount__c,
                                            CEN_PaymentDescription__c,
                                            CEN_OriginPayment__c
                                    FROM CEN_PaymentOrder__c
                                    WHERE CEN_Opportunity__r.CEN_Proforma__c IN :proformasSet
                                    AND CEN_DocumentNumberSAP__c IN :documentNumberList
                                    AND CEN_PaymentStatus__c != 'Anulado'
                                    ]) {

                if (!poByProforma.containsKey(poQueried.CEN_Opportunity__r.CEN_Proforma__c)) {
                    Map<String,CEN_PaymentOrder__c> po = new Map<String,CEN_PaymentOrder__c>();
                    po.put(poQueried.CEN_DocumentNumberSAP__c,poQueried);
                    poByProforma.put(poQueried.CEN_Opportunity__r.CEN_Proforma__c,po);
                } else {
                    poByProforma.get(poQueried.CEN_Opportunity__r.CEN_Proforma__c).put(poQueried.CEN_DocumentNumberSAP__c,poQueried);
                }

                Opportunity oppQueried = new Opportunity();
                oppQueried.Id = poQueried.CEN_Opportunity__c;
                oppQueried.CEN_Monto_cuota_de_inicial_de_precio__c = poQueried.CEN_Opportunity__r.CEN_Monto_cuota_de_inicial_de_precio__c;
                oppQueried.CEN_AmountPaidDate__c = poQueried.CEN_Opportunity__r.CEN_AmountPaidDate__c;
                oppQueried.CEN_Moneda__c = poQueried.CEN_Opportunity__r.CEN_Moneda__c;

                oppByProforma.put(poQueried.CEN_Opportunity__r.CEN_Proforma__c, oppQueried);
            }

            if(poByProforma.size() == 0){throw new PaymentException('No se han encontrado pagos a anular. Por favor verificar');}
            if(paymentOrders.size() == 0){throw new PaymentException('No se han encontrado pagos a insertar, o estos no tienen el formato necesario. Por favor verificar');}

            Map<String, List<PaymentOrder>> paymentOrdersByProforma = new Map<String, List<PaymentOrder>>();
            for (String proforma : proformasSet) {
                List<PaymentOrder> poList = new List<PaymentOrder>();
                Integer numNuevos = 0;
                for (PaymentOrder paymentOrder : paymentOrders) {
                    if (paymentOrder.PROFORMA == proforma) {
                        if(!String.isBlank(paymentOrder.VIA_PAGO)){
                            numNuevos++;
                            paymentOrder.TIPO_OPERACION = 'Nuevo';
                        }else if(poByProforma.containsKey(proforma)){
                            if (poByProforma.get(proforma).get(paymentOrder.BELNR) != null) {
                                paymentOrder.TIPO_OPERACION = 'Anulacion';
                                paymentOrder.IDENT = poByProforma.get(proforma).get(paymentOrder.BELNR).Id;
                                paymentOrder.OPE_IMPORTE = poByProforma.get(proforma).get(paymentOrder.BELNR).CEN_Amount__c;
                                paymentOrder.DESCRIPCION = poByProforma.get(proforma).get(paymentOrder.BELNR).CEN_PaymentDescription__c;
                                paymentOrder.VIA_PAGO = poByProforma.get(proforma).get(paymentOrder.BELNR).CEN_OriginPayment__c;
                            } else {
                                If(!poByProforma.get(proforma).containsKey(paymentOrder.BELNR)){throw new PaymentException('No se encontraron pagos a anular para la proforma '+proforma+' y Código SAP: '+paymentOrder.BELNR);}
                            }

                        }

                        if(!isPaymentDataValid(paymentOrder)){throw new PaymentException('El pago perteneciente a '+paymentOrder.PROFORMA+' tienen un dato errado. Por favor verificar');}
                        poList.add(paymentOrder);
                    }
                }

                If( numNuevos == 0 ){throw new PaymentException('No se encontraron nuevos pagos para la proforma '+proforma);}

                paymentOrdersByProforma.put(proforma,poList);
            }
            system.debug(paymentOrdersByProforma);
            system.debug(oppByProforma);
            paymentOrdersResp = processPaymentOrders(paymentOrdersByProforma, oppByProforma);

            return paymentOrdersResp;

        } catch (PaymentException ex) {
            system.debug(ex);
            paymentOrdersResp.error = ex.getMessage();

            return paymentOrdersResp;
        }
    }

    public static ResponseWrap processPaymentOrders(Map<String, List<PaymentOrder>> paymentOrdersByProforma, Map<String, Opportunity> oppByProforma){

        ResponseWrap rw = new ResponseWrap();
        Map<String, CEN_PaymentOrder__c> anulados = new Map<String,CEN_PaymentOrder__c>();
        Map<String, CEN_PaymentOrder__c> ingresados = new Map<String, CEN_PaymentOrder__c>();
        List<Opportunity> oppsEditadas = new List<Opportunity>();
        List<String> mensajes = new List<String>();

        for (String proforma : paymentOrdersByProforma.keySet()) {
            If(!oppByProforma.containsKey(proforma)){throw new PaymentException('Los pagos a procesar con proforma '+proforma+' no están enlazados a una Oportunidad');}

            Decimal montoAnulado =0;
            Decimal nuevoMonto =0;
            Decimal diferencia =0;

            Integer numeroAnulados =0;
            Integer numeroNuevos =0;

            for (PaymentOrder po : paymentOrdersByProforma.get(proforma)) {
                System.debug('payment: ' + po);
                if (po.TIPO_OPERACION == 'Anulacion') {
                    numeroAnulados++;
                    montoAnulado = montoAnulado + po.OPE_IMPORTE;

                    CEN_PaymentOrder__c updatePayment = new CEN_PaymentOrder__c();
                    updatePayment.Id = po.IDENT;
                    updatePayment.CEN_PaymentStatus__c = 'Anulado';
                    anulados.put(po.BELNR, updatePayment);

                } else {
                    numeroNuevos++;
                    nuevoMonto = nuevoMonto + po.OPE_IMPORTE;

                    CEN_PaymentOrder__c createPayment = new CEN_PaymentOrder__c();
                    createPayment.CEN_Amount__c = po.OPE_IMPORTE;
                    createPayment.CEN_Opportunity__c = oppByProforma.get(proforma).Id;
                    createPayment.CEN_PaymentStatus__c = 'Pagado';
                    createPayment.CEN_DocumentNumberSAP__c = po.BELNR;
                    createPayment.CEN_FiscalYearSAP__c = po.GJAHR;
                    createPayment.CEN_CurrencyCode__c = po.WAERS;
                    createPayment.CEN_Pago_Extranjero__c = po.PAGO_EXTRANJERO;
                    createPayment.CEN_OriginPayment__c = po.VIA_PAGO;
                    createPayment.CEN_PaymentDescription__c = po.DESCRIPCION;
                    if (po.VIA_PAGO == 'TCRE') {
                        createPayment.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_POSPayment').getRecordTypeId();
                        createPayment.CEN_LastFour__c = po.NRO_TARJETA;
                        createPayment.CEN_ID_Culqi__c = po.REFERENCIA;
                        createPayment.CEN_CountryCode__c = po.PAIS_BANCO;
                        createPayment.CEN_Banks__c = po.CLAVE_BANC;
                        createPayment.CEN_Fee__c = po.COMIS_CULQI;
                        createPayment.CEN_PaymentDate__c = po.FECHA_CULQI;

                    } else if (po.VIA_PAGO == 'ABCU'){
                        createPayment.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_TransferPayment').getRecordTypeId();
                        createPayment.CEN_PaymentCode__c = po.OPE_NUMERO;
                        createPayment.CEN_AccountNumberBank__c = po.NRO_CTA_BANCO;
                        createPayment.CEN_PaymentDate__c = po.FEC_CONTAB; 
                    }
                    ingresados.put(po.BELNR, createPayment);
                }
            }
            Decimal saldo = (oppByProforma.get(proforma).CEN_AmountPaidDate__c - montoAnulado + nuevoMonto) - oppByProforma.get(proforma).CEN_Monto_cuota_de_inicial_de_precio__c;
            If( numeroAnulados == 0 ){throw new PaymentException('No se encontraron pagos a anular para la proforma '+proforma);}
            If( numeroNuevos == 0 ){throw new PaymentException('No se encontraron nuevos pagos para la proforma '+proforma);}
            If( (oppByProforma.get(proforma).CEN_AmountPaidDate__c - montoAnulado + nuevoMonto) > oppByProforma.get(proforma).CEN_Monto_cuota_de_inicial_de_precio__c  ){throw new PaymentException('Los nuevos pagos en la proforma '+proforma+' suman un monto mayor al Monto a Pagar (+S/'+saldo+')');}

            if (nuevoMonto > montoAnulado) {
                Decimal montoMensaje = nuevoMonto - montoAnulado;
                throw new PaymentException('En la proforma '+proforma+' los nuevos pagos suman un importe de '+oppByProforma.get(proforma).CEN_Moneda__c+montoMensaje+' más en comparación al monto de los pagos a anular');
            } else if(montoAnulado > nuevoMonto){
                Decimal montoMensaje = montoAnulado - nuevoMonto;
                throw new PaymentException('En la proforma '+proforma+' los nuevos pagos suman un importe de '+oppByProforma.get(proforma).CEN_Moneda__c+montoMensaje+' menos en comparación al monto de los pagos a anular');
            }

            Opportunity updateOpp = new Opportunity();
            Decimal decMontoPagadoFechaActualizado =  ((oppByProforma.get(proforma).CEN_AmountPaidDate__c + nuevoMonto) - montoAnulado);
            updateOpp.Id = oppByProforma.get(proforma).Id;
            updateOpp.CEN_AmountPaidDate__c = decMontoPagadoFechaActualizado;
            updateOpp.CEN_Proforma__c = proforma;
            oppsEditadas.add(updateOpp);

        }

        Savepoint sp = Database.setSavepoint();
        try {
            update anulados.values();
            insert ingresados.values();
            update oppsEditadas;

            rw.anulados = String.valueOf('Se anularon los siguientes pagos con Código SAP: '+anulados.keySet());
            rw.ingresados = String.valueOf('Se ingresaron los siguientes pagos con Código SAP: '+ingresados.keySet());
            rw.mensajes = 'Se actualuzaron todos los pagos.';

            return rw;
        } catch (Exception ex) {
            Database.rollback(sp);
            rw.error = ex.getMessage();
            return rw;
        }
    }

    public static boolean isPaymentDataValid(PaymentOrder payment){
        if(String.isBlank(payment.PROFORMA)){throw new PaymentException('La proforma es obligatoria. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
        if(String.isBlank(payment.BELNR)){throw new PaymentException('El número de documento SAP es obligatorio. Por favor verificar.');}
        if((payment.DESCRIPCION == null) || (payment.DESCRIPCION == '')){throw new PaymentException('El campo descripcion debe tener al menos 5 caracteres. Por favor verificar (Doc SAP: )'+payment.BELNR);}
        if(payment.PROFORMA.length() != 10 ){throw new PaymentException('El número de caracteres de la proforma debe ser de 10 dígitos. Por favor verificar.');}
        if(payment.BELNR.length() != 10){throw new PaymentException('El número de caracteres de número documento SAP debe ser de 10 dígitos. Por favor verificar (Doc SAP: )'+payment.BELNR);}

        if ((payment.TIPO_OPERACION == 'Nuevo')) {
            if(String.isBlank(payment.VIA_PAGO)){throw new PaymentException('El pago no cuenta con una Via de pago asignada. Por favor verificar (Doc SAP: )'+payment.BELNR);}
            if(String.isBlank(payment.WAERS)){throw new PaymentException('El tipo de moneda es obligatorio. Por favor verificar (Doc SAP: )'+payment.BELNR);}
            if(payment.GJAHR == null){throw new PaymentException('El año en curso es obligatorio. Por favor verificar (Doc SAP: )'+payment.BELNR);}
            if(payment.OPE_IMPORTE == null){throw new PaymentException('El monto de operación es obligatorio. Por favor verificar (Doc SAP: )'+payment.BELNR);}
            if(payment.PAGO_EXTRANJERO == null){throw new PaymentException('El flag de pago extranjero es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
            if (payment.VIA_PAGO == 'TCRE') {
                if(String.isBlank(payment.REFERENCIA)){throw new PaymentException('La referencia es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(String.isBlank(payment.PAIS_BANCO)){throw new PaymentException('El código de país del banco es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(String.isBlank(payment.CLAVE_BANC)){throw new PaymentException('El código del banco es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(payment.COMIS_CULQI == null){throw new PaymentException('El monto de comisión de Culqi es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(payment.FECHA_CULQI == null){throw new PaymentException('La fecha de pago de Culqi es obligatoria. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
            } else {
                if(String.isBlank(payment.OPE_NUMERO)){throw new PaymentException('El número de operación es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(String.isBlank(payment.NRO_CTA_BANCO)){throw new PaymentException('El número de cuenta es obligatorio. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
                if(payment.FEC_CONTAB == null){throw new PaymentException('La fecha del abono es obligatoria. Por favor verificar. (Doc SAP: )'+payment.BELNR);}
            }
        }

        return true;
    }

    global class ResponseWrap{
        Public String anulados { get; set; }
        Public String ingresados { get; set; }
        Public String mensajes { get; set; }
        Public String error { get; set; }
    }

    public class PaymentException extends Exception {}
}