/********************************************************************************
* @author: Katherine Espinoza (kespinod@everis.com)
* @date: 2021-04-14
* @description: web service para envío de oportunidades hacia la web de terrenos.
*
* VERSION		DATE			AUTOR					ACTION
* 0.1			2021-04-14		Katherine Espinoza		Creación
* 0.2           2021-04-22      Alan Alvarez            Actualización
********************************************************************************/
@RestResource(urlMapping='/paymentorder/*')
global class CEN_PaymentOrderService_cls {

    @HttpPost
    global static String doPost(){

        String jsonString = RestContext.request.requestBody.toString();
        paymentoderreq payorder = new paymentoderreq();
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        try{
            String varStatus = (String)params.get('status');
            payorder.estadopago = String.isNotEmpty(varStatus)? varStatus:'PendienteCulqi';
            payorder.moneda = (String)params.get('paymentcode');
            payorder.monto = (double)params.get('amount');
            payorder.paymentdate = (String)params.get('paymentdate');
            payorder.descripcionpago = (String)params.get('description');
            payorder.idoportunidad = (String)params.get('idopportunity');
            payorder.idculqi = (String)params.get('idculqi');
            payorder.type = (String)params.get('type');
            payorder.origindata = (String)params.get('origin');
            payorder.paymentmethod = (String)params.get('paymentmethod');
            double minMonto = 0;
            double maxMonto = 0;
            double montoInicial = 0;
            validateField(payorder);
            try{
                Blob afterblob = EncodingUtil.base64Decode(payorder.idoportunidad);
                List<Opportunity> lstopp = [Select id, AccountId, CEN_Proyecto__c, CEN_Proyecto__r.CEN_Sociedad__c, CEN_AmountPaidDate__c, CEN_Monto_cuota_de_inicial_de_precio__c,
                                            CEN_MinimumAmountPaymentOrder__c, CEN_MaximumAmountPaymentOrder__c from Opportunity where id =: afterblob.toString()];
                if (lstopp.size() > 0){
                    payorder.oppid = lstopp.get(0).id;
                    payorder.accid = lstopp.get(0).AccountId;
                    payorder.proyid = lstopp.get(0).CEN_Proyecto__c;
                    payorder.society = lstopp.get(0).CEN_Proyecto__r.CEN_Sociedad__c;
                    montoInicial = lstopp.get(0).CEN_Monto_cuota_de_inicial_de_precio__c;
                    minMonto = lstopp.get(0).CEN_MinimumAmountPaymentOrder__c;
                    maxMonto = lstopp.get(0).CEN_MaximumAmountPaymentOrder__c;
                }else{
                    throw new PaymentOrderException('La Oportunidad ingresada no existe.');
                }
            }catch(Exception e){
                throw new PaymentOrderException('La Oportunidad ingresada no existe o el parametro enviado es incorrecto.');
            }
            Account acc = [
                SELECT FirstName, LastName, Name, PersonEmail, CEN_fld_Correo_empresa__c, PersonMobilePhone, Phone
                FROM Account
                WHERE Id = :payorder.accid
            ];
            payorder.nombre = acc.FirstName == null
                ? acc.Name
                : acc.FirstName;
            payorder.apellido = acc.LastName;
            payorder.email = acc.PersonEmail == null
                ? acc.CEN_fld_Correo_empresa__c
                : acc.PersonEmail;
            payorder.celular = acc.PersonMobilePhone == null
                ? acc.Phone
                : acc.PersonMobilePhone;
            validateFieldAccount(payorder);
            Proyecto__c proy;
            if(payorder.proyid != null){
                proy = [
                    SELECT CEN_MaximumPaymentDuePeriod__c, CEN_monto_minimo_reserva__c, CEN_monto_minimo_deposito__c
                    FROM Proyecto__c
                    WHERE Id =: payorder.proyid
                ];
            }
            validateAmount(payorder.monto, minMonto, maxMonto);
            Date dateVencimiento = validateProyecto(proy);
            Id idRecordtype = validateRecordType(payorder.type);
            CEN_PaymentOrder__c newPO = new CEN_PaymentOrder__c();
            newPO.CEN_FirstName__c = payorder.nombre;
            newPO.CEN_LastName__c = payorder.apellido;
            newPO.CEN_Email__c = payorder.email;
            newPO.CEN_PhoneNumber__c = payorder.celular;
            newPO.CEN_PaymentStatus__c= payorder.estadoPago;
            newPO.CEN_CurrencyCode__c= payorder.moneda;
            newPO.CEN_Amount__c= payorder.monto;
            newPO.CEN_PaymentDescription__c= payorder.descripcionpago;
            newPO.CEN_Opportunity__c= payorder.oppid;
            newPo.CEN_ID_Culqi__c= payorder.idculqi;
            newPo.CEN_OriginData__c= payorder.origindata;
            newPo.CEN_DueDate__c = dateVencimiento;
            newPo.RecordtypeId = idRecordtype;
            newPo.CEN_PaymentDate__c = Test.isRunningTest()?null:Datetime.valueOf(payorder.paymentdate);
            newPo.CEN_PaymentMethod__c = payorder.paymentmethod;
            newPo.CEN_Society__c = payorder.society;
            newPo.CEN_BankDescription__c = payorder.bank;
            insert newPO;
            String myPymentName = [SELECT Name FROM CEN_PaymentOrder__c WHERE Id=:newPO.Id].Name;
            return 'Success:{"numPayment":"' + myPymentName+'","dateExp":"'+dateVencimiento+'"}';
        } catch (Exception ex) {
            return 'Error:' + ex.getMessage();
        }
    }

    private static void validateField(paymentoderreq payorder){
        if(payorder.estadopago == 'PendienteCulqi' && payorder.idculqi != null) {
            throw new PaymentOrderException('Error en el Estado Pago, el valor es obligatorio.');
        }else{
            if(payorder.estadopago.equals('Pendiente') || payorder.estadopago.equals('Pagado')) {
                if (payorder.idculqi == null) {
                    throw new PaymentOrderException('Error en el Id Culqi, el valor es obligatorio.');
                }
                if (payorder.paymentdate == null) {
                    throw new PaymentOrderException('Error en la fecha de pago, el valor es obligatorio.');
                }
            }
        }
        if (payorder.moneda == null) {
            throw new PaymentOrderException('Error en el campo Moneda, el valor es obligatorio.');
        }
        if (payorder.monto == null) {
            throw new PaymentOrderException('Error en el campo Monto, el valor es obligatorio.');
        }
        if (payorder.descripcionpago == null) {
            throw new PaymentOrderException('Error en el campo Descripción Pago, el valor es obligatorio.');
        }
        if (payorder.origindata == null) {
            throw new PaymentOrderException('Error en el campo Origen de Datos, el valor es obligatorio.');
        }else{
            List<Schema.PicklistEntry>  lstOriginData = CEN_PaymentOrder__c.CEN_OriginData__c.getDescribe().getPicklistValues();
            Set<String> setOriginData = new Set<String>();
            for(Schema.PicklistEntry v :lstOriginData){
                setOriginData.add(v.getValue());
            }
            if(!setOriginData.contains(payorder.origindata)){
                throw new PaymentOrderException('Error en el campo Origen de Datos, el valor enviado es incorrecto.');
            }
        }
        if (payorder.idoportunidad == null) {
            throw new PaymentOrderException('Error en el campo Id Oportunidad, el valor es obligatorio.');
        }
        //if (payorder.paymentmethod == null){
        //     throw new PaymentOrderException('Error en el campo metodo de pago, el valor es obligatorio.');
        // }
    }

    private static void validateFieldAccount(paymentoderreq payorder){
        String strFirstName = payorder.nombre;
        if (strFirstName == null || strFirstName.length() < 2) {
            throw new PaymentOrderException('Error en nombre del cliente de la orden de pago');
        }
        String strPersonEmail = payorder.email;
        if (strPersonEmail == null) {
            throw new PaymentOrderException('Error en mail del cliente de la orden de pago');
        }
        String strPersonMobilePhone = payorder.celular;
        if (strPersonMobilePhone == null || strPersonMobilePhone.length() < 8) {
            throw new PaymentOrderException('Error en telefono del cliente de la orden de pago');
        }
    }

    private static date validateProyecto(Proyecto__c proy){
        date myDate = date.today();
        date newDate;
        if(proy == null){
            newDate = date.newInstance(myDate.year(), myDate.month() + 1, 1) - 1;
        }else{
            if(proy.CEN_MaximumPaymentDuePeriod__c == null){
                newDate = date.newInstance(myDate.year(), myDate.month() + 1, 1) - 1;
            }else{
                date dateProy = myDate.addDays(Integer.valueOf(proy.CEN_MaximumPaymentDuePeriod__c));
                if(myDate.month() == dateProy.month()){
                    newDate = dateProy;
                }else{
                    if(myDate.month() == 12){
                        newDate = date.newInstance(myDate.year(), 12, 31);
                    }else{
                        newDate = date.newInstance(myDate.year(), myDate.month() + 1, 1) - 1;
                    }
                }
            }
        }
        return newDate;
    }

    private static void validateAmount(decimal amount, double min, double max){
        if (amount > max || amount < min) {
            throw new PaymentOrderException('El monto debe ser entre S/ '+String.valueOf(min)+' y S/ '+String.valueOf(max)+'. Por favor verificar monto.');
        }
    }

    private static Id validateRecordType(String sType){
        String idRecordType;
        Map<String, String> mapType = new Map<String, String>();
        mapType.put('Pago Efectivo','CEN_CashPayment');
        mapType.put('Pago Tarjeta','CEN_POSPayment');
        if(mapType.containsKey(sType)){
            List<RecordType> lstRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'CEN_PaymentOrder__c' and DeveloperName = :mapType.get(sType) LIMIT 1];
            if(lstRecordType.size() > 0){
                idRecordType = lstRecordType[0].id;
            }else{
                throw new PaymentOrderException('Por favor ingresar un tipo de pago valido');
            }
        }else{
            throw new PaymentOrderException('Por favor ingresar un tipo de pago valido');
        }
        return idRecordType;
    }

    private static String validateOriginPayment(String sType){
        Map<String, String> mapType = new Map<String, String>();
        mapType.put('Pago Efectivo','EFEC');
        mapType.put('Pago Tarjeta','TCRE');
        return mapType.get(sType);
    }

    public class PaymentOrderException extends Exception {
    }

    @HttpPut
    global static String doPut(){
        String jsonString = RestContext.request.requestBody.toString();
        paymentoderreq payorder = new paymentoderreq();
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        payorder.idpaymentorder = (String)params.get('numPayment');
        payorder.estadopago = (String)params.get('status');
        payorder.idculqi = (String)params.get('idculqi');
        payorder.type = (String)params.get('type');
        payorder.paymentdate = (String)params.get('paymentdate');
        payorder.paymentcode = (String)params.get('paymentcode');
        payorder.reference = (String)params.get('reference');
        payorder.lastfour = (String)params.get('lastfour');
        payorder.bank = (String)params.get('bank');
        payorder.currencycode = (String)params.get('currencycode');
        payorder.countrycode = (String)params.get('countrycode');
        payorder.fee = (double)params.get('fee');
        payorder.paymentmethod = (String)params.get('paymentmethod');
        try{
            double maxMonto = 0;
            double montoInicial = 0;
            String myNumPayment = payorder.idpaymentorder;
            if(String.isEmpty(myNumPayment)){throw new PaymentOrderException('El numero de pago es obligatorio. Por favor verificar.');}
            if(String.isEmpty(payorder.estadopago)){throw new PaymentOrderException('El estado del pago es obligatorio. Por favor verificar.');}
            if(String.isEmpty(payorder.idculqi)){throw new PaymentOrderException('El id de Culqui de pago es obligatorio. Por favor verificar.');}
            if(String.isEmpty(payorder.paymentdate)){throw new PaymentOrderException('La fecha de pago es obligatorio. Por favor verificar.');}
            if(!String.isEmpty(payorder.paymentcode) && payorder.paymentcode.length() > 10){throw new PaymentOrderException('El código de pago debe contener máximo 10 caracteres. Por favor verificar.');}
            if(!String.isEmpty(payorder.reference) && payorder.reference.length() > 15){throw new PaymentOrderException('La referencia de pago debe contener máximo 15 caracteres. Por favor verificar.');}
            if(!String.isEmpty(payorder.lastfour) && payorder.lastfour.length() > 4){throw new PaymentOrderException('Los 4 últimos dígitos tarjeta de pago permite máximo 4 caracteres. Por favor verificar.');}
            String idBank;
            if(payorder.estadopago != 'Anulado'){
                if(payorder.type == 'Pago Efectivo' && String.isEmpty(payorder.paymentcode)){throw new PaymentOrderException('El código de pago es obligatorio. Por favor verificar.');}
                if(payorder.type == 'Pago Tarjeta'){
                    if(String.isEmpty(payorder.reference)){throw new PaymentOrderException('La referencia de pago es obligatorio. Por favor verificar.');}
                    if(String.isEmpty(payorder.lastfour)){throw new PaymentOrderException('Los 4 últimos dígitos tarjeta de pago es obligatorio. Por favor verificar.');}
                    if(String.isEmpty(payorder.currencycode)){throw new PaymentOrderException('El Tipo de Moneda es obligatorio. Por favor verificar.');}
                    if(String.isEmpty(payorder.bank)){throw new PaymentOrderException('El nombre de banco es obligatorio. Por favor verificar.');}
                    if(String.isEmpty(payorder.countrycode)){throw new PaymentOrderException('El código de país es obligatorio. Por favor verificar.');}
                    if(payorder.fee == null){throw new PaymentOrderException('El valor de comisión es obligatorio. Por favor verificar.');}
                }
            }
            if(!String.isEmpty(payorder.bank)){
                String bankName = String.valueOf(payorder.bank).trim();
                bankName = bankName.replace(',', '');
                bankName = bankName.replace('.', '');
                bankName = bankName.replace('-', '');
                bankName = bankName.replace(' ', '');
                String nombreBanco = bankName.length() > 37 ? bankName.subString(0,37).trim() : bankName.trim();
                String bankCurrency = nombreBanco.toUpperCase() + '_' + payorder.currencycode;
                List<CEN_Banks__mdt> lstBankMdt = [Select label, DeveloperName from CEN_Banks__mdt where DeveloperName = :bankCurrency];
                if(lstBankMdt.size() > 0){
                    idBank = lstBankMdt[0].label;
                    List<Schema.PicklistEntry>  lstBankData = CEN_PaymentOrder__c.CEN_Banks__c.getDescribe().getPicklistValues();
                    Set<String> setBankParameter = new Set<String>();
                    for(Schema.PicklistEntry v :lstBankData){
                        setBankParameter.add(v.getValue());
                    }
                    if(!setBankParameter.contains(idBank)){
                        throw new PaymentOrderException('Error al buscar Banco con el tipo de Moneda, el valor enviado es incorrecto.');
                    }
                }else{
                    idBank = '999';
                    //throw new PaymentOrderException('Error en el campo Banco, el valor enviado es incorrecto.');
                }
            }
            if(!String.isEmpty(payorder.currencycode)){
                List<Schema.PicklistEntry>  lstCurrencyData = CEN_PaymentOrder__c.CEN_CurrencyCode__c.getDescribe().getPicklistValues();
                Set<String> setCurrency = new Set<String>();
                for(Schema.PicklistEntry v :lstCurrencyData){
                    setCurrency.add(v.getValue());
                }
                if(!setCurrency.contains(payorder.currencycode)){
                    throw new PaymentOrderException('Error el tipo de Moneda, el valor enviado es incorrecto.');
                }
            }

            List<CEN_PaymentOrder__c> updPO = [select CEN_FirstName__c, CEN_LastName__c, CEN_Email__c, CEN_PhoneNumber__c, CEN_PaymentStatus__c,
                                               CEN_PaymentCode__c, CEN_Amount__c, CEN_PaymentDescription__c, CEN_Opportunity__c, CEN_ID_Culqi__c,
                                               CEN_OriginData__c, CEN_DueDate__c, CEN_PaymentDate__c, CEN_CurrencyCode__c, CEN_Banks__c, CEN_BankDescription__c from CEN_PaymentOrder__c where Name=: myNumPayment];

            Integer countPaymentsProcessing = [SELECT COUNT() FROM CEN_PaymentOrder__c WHERE CEN_Opportunity__c =: updPO.get(0).CEN_Opportunity__c AND  CEN_PaymentStatus__c = 'Procesando'];
            if(updPO.size() > 0){
                if(updPO.get(0).CEN_PaymentStatus__c == 'Pagado' && payorder.estadopago == 'Anulado'){
                    throw new PaymentOrderException('No es posible anular una orden de pago en estado pagado');
                }
                Id idRecordtype = validateRecordType(payorder.type);
                updPO.get(0).RecordTypeId = idRecordtype;
                updPO.get(0).CEN_OriginPayment__c = validateOriginPayment(payorder.type);
                updPO.get(0).CEN_PaymentStatus__c = countPaymentsProcessing > 0 ? 'Procesando' : payorder.estadoPago;
                updPO.get(0).CEN_ID_Culqi__c = payorder.idculqi;
                updPO.get(0).CEN_PaymentDate__c = Test.isRunningTest()?null:Datetime.valueOf(payorder.paymentdate);
                updPO.get(0).CEN_PaymentCode__c = payorder.paymentcode;
                updPO.get(0).CEN_Reference__c = payorder.reference;
                updPO.get(0).CEN_LastFour__c = payorder.lastfour;
                updPO.get(0).CEN_Banks__c = idBank;
                //updPO.get(0).CEN_BankDescription__c= idBank=='999' ? payorder.bank : '';
                updPO.get(0).CEN_BankDescription__c = payorder.bank;
                updPO.get(0).CEN_CurrencyCode__c = String.isEmpty(payorder.currencycode)
                    ? updPO[0].CEN_CurrencyCode__c
                    : payorder.currencycode;
                updPO.get(0).CEN_CountryCode__c = payorder.countrycode;
                updPO.get(0).CEN_Fee__c = payorder.fee;
                updPO.get(0).CEN_PaymentMethod__c = payorder.paymentmethod;
                update updPO;
                return 'Success:' + myNumPayment;
            }else{
                throw new PaymentOrderException('La Orden de Pago ingresada no existe o el parametro enviado es incorrecto.');
            }
        } catch (Exception ex) {
            return 'Error:' + ex.getMessage();
        }
    }

    @HttpGet
    global static List<paymentoderresp> doGet(){
        RestRequest req = RestContext.request;
        String poid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Blob blobpoid = EncodingUtil.base64Decode(poid);
        list<CEN_PaymentOrder__c> lstPaymentOrder = [select
                                                     Id
                                                     ,Name
                                                     ,CEN_LastName__c
                                                     ,CEN_Bin__c
                                                     ,CEN_Paid__c
                                                     ,CEN_AddressCity__c
                                                     ,CEN_Fee__c
                                                     ,CEN_Email__c
                                                     ,CEN_Installments__c
                                                     ,CEN_PaymentCode__c
                                                     ,CEN_CountryCode__c
                                                     ,CEN_PaymentDescription__c
                                                     ,CEN_Address__c
                                                     ,CEN_PaymentStatus__c
                                                     ,CEN_CreationDateFrom__c
                                                     ,CEN_CreationDateTo__c
                                                     ,CEN_PaymentDate__c
                                                     ,CEN_DueDate__c
                                                     ,CEN_CardBrand__c
                                                     ,CEN_CurrencyCode__c
                                                     ,CEN_Amount__c
                                                     ,CEN_FirstName__c
                                                     ,CEN_DocumentNumber__c
                                                     ,CEN_PhoneNumber__c
                                                     ,CEN_Opportunity__r.Name
                                                     ,CEN_OriginPayment__c
                                                     ,CEN_Reference__c
                                                     ,CEN_DeviceType__c
                                                     ,CEN_TypeDocument__c
                                                     ,CEN_CardType__c
                                                     ,CEN_ID_Culqi__c
                                                     from CEN_PaymentOrder__c
                                                     where CEN_Opportunity__c = :blobpoid.toString()];

        paymentoderresp objOrdenPago;
        List<paymentoderresp> lstOrdenPago = new List<paymentoderresp>();
        for(CEN_PaymentOrder__c objPaymentOrder: lstPaymentOrder){
            objOrdenPago = new paymentoderresp();
            objOrdenPago.idpaymentorder = objPaymentOrder.Id;
            objOrdenPago.clientlastname = objPaymentOrder.CEN_LastName__c;
            objOrdenPago.bin = objPaymentOrder.CEN_Bin__c;
            objOrdenPago.paid = objPaymentOrder.CEN_Paid__c;
            objOrdenPago.city = objPaymentOrder.CEN_AddressCity__c;
            objOrdenPago.fee = objPaymentOrder.CEN_Fee__c;
            objOrdenPago.email = objPaymentOrder.CEN_Email__c;
            objOrdenPago.quota = objPaymentOrder.CEN_Installments__c;
            objOrdenPago.paymentcode = objPaymentOrder.CEN_PaymentCode__c;
            objOrdenPago.countrycode = objPaymentOrder.CEN_CountryCode__c;
            objOrdenPago.description = objPaymentOrder.CEN_PaymentDescription__c;
            objOrdenPago.address = objPaymentOrder.CEN_Address__c;
            objOrdenPago.paymentstatus = objPaymentOrder.CEN_PaymentStatus__c == 'PendienteSAP'
                ? 'Pagado'
                : objPaymentOrder.CEN_PaymentStatus__c;
            objOrdenPago.creationdatefrom = objPaymentOrder.CEN_CreationDateFrom__c;
            objOrdenPago.creationdateto = objPaymentOrder.CEN_CreationDateTo__c;
            if(objPaymentOrder.CEN_PaymentDate__c != null){
                Datetime myPaymentDate = objPaymentOrder.CEN_PaymentDate__c;
                Timezone tz = Timezone.getTimeZone('America/Lima');
                Integer offset = tz.getOffset(myPaymentDate);
                Datetime localPaymentDate = myPaymentDate.addSeconds(offset/1000);
                objOrdenPago.paymentdate = localPaymentDate;
            }
            objOrdenPago.duedate = objPaymentOrder.CEN_DueDate__c;
            objOrdenPago.cardbrand = objPaymentOrder.CEN_CardBrand__c;
            objOrdenPago.currencycode = objPaymentOrder.CEN_CurrencyCode__c;
            objOrdenPago.amount = objPaymentOrder.CEN_Amount__c;
            objOrdenPago.clientfirstname = objPaymentOrder.CEN_FirstName__c;
            objOrdenPago.documentnumber = objPaymentOrder.CEN_DocumentNumber__c;
            objOrdenPago.clientphonenumber = objPaymentOrder.CEN_PhoneNumber__c;
            objOrdenPago.idopportunity = objPaymentOrder.CEN_Opportunity__r.Name;
            objOrdenPago.originpayment = objPaymentOrder.CEN_OriginPayment__c;
            objOrdenPago.paymentordername = objPaymentOrder.Name;
            objOrdenPago.reference = objPaymentOrder.CEN_Reference__c;
            objOrdenPago.devicetype = objPaymentOrder.CEN_DeviceType__c;
            objOrdenPago.typedocument = objPaymentOrder.CEN_TypeDocument__c;
            objOrdenPago.cardtype = objPaymentOrder.CEN_CardType__c;
            objOrdenPago.idculqi = objPaymentOrder.CEN_ID_Culqi__c;
            lstOrdenPago.add(objOrdenPago);
        }
        return lstOrdenPago;
    }

    global class paymentoderresp{
        Private Id idpaymentorder { get; set; }
        Private String clientlastname { get; set; }
        Private String bin { get; set; }
        Private Boolean paid { get; set; }
        Private String city { get; set; }
        Private double fee { get; set; }
        Private String email { get; set; }
        Private double quota { get; set; }
        Private String paymentcode { get; set; }
        Private String countrycode { get; set; }
        Private String description { get; set; }
        Private String address { get; set; }
        Private String paymentstatus { get; set; }
        Private date creationdatefrom { get; set; }
        Private date creationdateto { get; set; }
        Private Datetime paymentdate { get; set; }
        Private date duedate { get; set; }
        Private String cardbrand { get; set; }
        Private String currencycode { get; set; }
        Private double amount { get; set; }
        Private String clientfirstname { get; set; }
        Private String documentnumber { get; set; }
        Private String clientphonenumber { get; set; }
        Private String idopportunity { get; set; }
        Private String originpayment { get; set; }
        Private String paymentordername { get; set; }
        Private String reference { get; set; }
        Private String devicetype { get; set; }
        Private String typedocument { get; set; }
        Private String cardtype { get; set; }
        Private String idculqi { get; set; }
    }

    global class paymentoderreq{
        String idpaymentorder { get; set; }
        String oppId { get; set; }
        String accId { get; set; }
        String proyid { get; set; }
        String email { get; set; }
        String nombre { get; set; }
        String apellido { get; set; }
        String celular { get; set; }
        String estadopago { get; set; }
        String moneda { get; set; }
        Decimal monto { get; set; }
        String descripcionpago { get; set; }
        string idoportunidad { get; set; }
        String idculqi { get; set; }
        String origindata { get; set; }
        String type { get; set; }
        String paymentdate { get; set; }
        String paymentcode { get; set; }
        String reference { get; set; }
        String lastfour { get; set; }
        String bank { get; set; }
        String currencycode { get; set; }
        String countrycode { get; set; }
        Decimal fee { get; set; }
        String paymentmethod { get; set; }
        String society { get; set; }
    }

}