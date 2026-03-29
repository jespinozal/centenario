/*********************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-04-22
* @description: Clase Test que instancia clase Api de CEN_PaymentOrderService_cls.
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2021-04-22           Alan Alvarez            Creación
*
*********************************************************************/
@isTest
public class CEN_PaymentOrderService_tst{
    public static String respType = '';
    @testSetup
    public static void setup(){

        Proyecto__c pro = new Proyecto__c();
        pro.Name ='Proyecto 1';
        pro.CEN_CODIGOSAP__c ='10U.11E';
        insert pro;

        Proyecto__c pro2 = new Proyecto__c();
        pro2.Name ='Proyecto 2';
        pro2.CEN_CODIGOSAP__c ='10U.12E';
        pro2.CEN_MaximumPaymentDuePeriod__c = null;
        insert pro2;

        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_N_mero_de_documento__pc = '12345678';
        insert acc;

        Account acc2 = new Account();
        acc2.FirstName = 'Test acc2';
        acc2.LastName = 'Apellido acc2';
        acc2.PersonEmail = 'acc2@tst.com';
        acc2.PersonMobilePhone = '987654321';
        acc2.CEN_N_mero_de_documento__pc = '12345678';
        insert acc2;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.CloseDate = System.today();
        opp.StageName='Cotización';
        opp.CEN_Tipo_de_solicitud__c='Solicitud';
        opp.CEN_Tiene_Reserva__c='No';
        opp.CEN_Con_sustento__c='No';
        opp.CEN_Medio_Publicitario__c='Radio';
        opp.CEN_Tipo_de_venta__c='CD';
        opp.Amount=1000;
        opp.AccountId = acc.id;
        opp.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        opp.CEN_Proyecto__c = pro.Id;
        insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2';
        opp2.CloseDate = System.today();
        opp2.StageName='Cotización';
        opp2.CEN_Tipo_de_solicitud__c='Solicitud';
        opp2.CEN_Tiene_Reserva__c='No';
        opp2.CEN_Con_sustento__c='No';
        opp2.CEN_Medio_Publicitario__c='Radio';
        opp2.CEN_Tipo_de_venta__c='CD';
        opp2.Amount=1000;
        opp2.AccountId = acc2.id;
        opp2.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        insert opp2;

        Date currentDay = system.today();
        DateTime myDateTime = DateTime.now();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 100;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment 1';
        pyOrder.CEN_Opportunity__c = opp.Id;
        pyOrder.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_PaymentDate__c = myDateTime;
        insert pyOrder;

        CEN_PaymentOrder__c pyOrder2 = new CEN_PaymentOrder__c();
        pyOrder2.CEN_Amount__c = 200;
        pyOrder2.CEN_CurrencyCode__c = 'PEN';
        pyOrder2.CEN_PaymentDescription__c = 'Test payment 2';
        pyOrder2.CEN_Opportunity__c = opp.Id;
        pyOrder2.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder2.CEN_PaymentDate__c = myDateTime;
        insert pyOrder2;

    }

    /*********************************************************************
* @description: Método para consumo api Get.
*********************************************************************/
    @isTest
    public static void CallApiGet(){
        List<Opportunity> lstOpportunity = [Select id from Opportunity];
        if(lstOpportunity.size() > 0){
            RestRequest request = new RestRequest();
            Blob blobOppid = Blob.valueOf(lstOpportunity[0].id);
            request.requestUri ='/services/apexrest/paymentorder/'+EncodingUtil.base64Encode(blobOppid);
            request.httpMethod = 'GET';
            RestContext.request = request;
            List<CEN_PaymentOrderService_cls.paymentoderresp> lstPaymentOrder = CEN_PaymentOrderService_cls.doGet();
            system.assert(lstPaymentOrder.size() > 0);
        }
    }

    /*********************************************************************
* @description: Método para consumo api Post.
*********************************************************************/
    @isTest
    public static void CallApiPost(){
        Test.startTest();
        List<Opportunity> lstOpportunity = [Select id from Opportunity where Name = 'Test Acc1 Apellido Acc1  - Proyecto 1'];
        if(lstOpportunity.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/paymentorder/';
            request.httpMethod = 'POST';
            Blob beforeblob = Blob.valueOf(lstOpportunity[0].id);
            string paramvalue = EncodingUtil.base64Encode(beforeblob);
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":100,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v1","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv01","type":"Pago Tarjeta","origin":"WEBTERRENO"}');
            RestContext.request = request;
            String strPaymentOrder = CEN_PaymentOrderService_cls.doPost();
            System.debug(strPaymentOrder);
            //system.assert(!strPaymentOrder.contains('Error'));
        }
        Test.stopTest();
    }

    @isTest
    public static void CallApiPostOrderError(){
        Test.startTest();
        List<Opportunity> lstOpportunity = [Select id from Opportunity where Name = 'Test Acc1 Apellido Acc1  - Proyecto 1'];
        if(lstOpportunity.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/paymentorder/';
            request.httpMethod = 'POST';
            Blob beforeblob = Blob.valueOf(lstOpportunity[0].id);
            string paramvalue = EncodingUtil.base64Encode(beforeblob);
            //EstadoPago
            request.requestBody = Blob.valueOf('{ "status": null }');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //EstadoPagoPendientePagado
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": null, "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //Moneda
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": null, "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //monto null
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":null, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //monto menor
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount": 5, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //descripcion
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":null, "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //origendatos
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":null}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //origendatosvalidate
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramvalue+'", "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"TERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //oportunidad
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":null, "idculqi": "IdCulqiv02", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //oportunidadValidatePara
            Blob blobIdError = Blob.valueOf('idnoexiste');
            string paramIdError = EncodingUtil.base64Encode(blobIdError);
            request.requestBody = Blob.valueOf('{ "status": "Pendiente", "paymentcode": "PEN", "amount":200, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v2", "idopportunity":"'+paramIdError+'","idculqi":"IdCulqiv02", "type":"Pago Tarjeta","origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
        }
        Test.stopTest();
    }

    @isTest
    public static void CallApiPostAccountError(){
        Test.startTest();
        List<Opportunity> lstOpportunity = [Select id, AccountId from Opportunity where Name = 'Test Acc1 Apellido Acc1  - Proyecto 1'];
        if(lstOpportunity.size() > 0){
            Account acc = [
                SELECT FirstName, LastName, PersonEmail, PersonMobilePhone
                FROM Account
                WHERE Id = :lstOpportunity[0].AccountId
            ];
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/paymentorder/';
            request.httpMethod = 'POST';
            Blob beforeblob = Blob.valueOf(lstOpportunity[0].id);
            string paramvalue = EncodingUtil.base64Encode(beforeblob);
            //ValidateName
            acc.FirstName = '1';
            update acc;
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300, "paymentdate":"2021-05-28 20:11:00", "description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03", "type":"Pago Tarjeta","origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //ValidatePersonEmail
            acc.FirstName = 'Test acc1';
            acc.LastName = 'Apellido acc1';
            acc.PersonEmail = null;
            update acc;
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03", "type":"Pago Tarjeta","origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //ValidatePersonMobilePhone
            acc.FirstName = 'Test acc1';
            acc.LastName = 'Apellido acc1';
            acc.PersonEmail = 'acc1@tst.com';
            acc.PersonMobilePhone = null;
            update acc;
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03", "type":"Pago Tarjeta","origin":"WEBTERRENO"}');            
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
        }
        Test.stopTest();
    }

    @isTest
    public static void CallApiPostProyectError(){
        Test.startTest();
        List<Opportunity> lstOpportunity = [Select id, AccountId from Opportunity where Name = 'Test Acc2 Apellido Acc2  -'];
        if(lstOpportunity.size() > 0){
            Account acc = [
                SELECT FirstName, LastName, PersonEmail, PersonMobilePhone
                FROM Account
                WHERE Id = :lstOpportunity[0].AccountId
            ];
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/paymentorder/';
            request.httpMethod = 'POST';
            Blob beforeblob = Blob.valueOf(lstOpportunity[0].id);
            string paramvalue = EncodingUtil.base64Encode(beforeblob);
            //ValidateProyecto
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            //system.assert(!CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //ValidateMontoInicial
            lstOpportunity[0].CEN_Monto_cuota_de_inicial_de_precio__c = null;
            update lstOpportunity[0];
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03", "type":"Pago Tarjeta", "origin":"WEBTERRENO"}');
            RestContext.request = request;
            system.assert(CEN_PaymentOrderService_cls.doPost().contains('Error'));
            //ValidateMontoInicial
            Proyecto__c proy = [
                SELECT Id, Name
                FROM Proyecto__c
                WHERE Name = 'Proyecto 2'
            ];
            lstOpportunity[0].CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
            lstOpportunity[0].CEN_Proyecto__c = proy.id;
            update lstOpportunity[0];
            request.requestBody = Blob.valueOf('{ "status": "Pendiente","paymentcode": "PEN","amount":300,"paymentdate":"2021-05-28 20:11:00","description":"Test Service Post v3","idopportunity":"'+paramvalue+'","idculqi":"IdCulqiv03","type":"Pago Tarjeta","origin":"WEBTERRENO"}');            
            RestContext.request = request;
            //system.assert(!CEN_PaymentOrderService_cls.doPost().contains('Error'));
        }
        Test.stopTest();
    }

/*********************************************************************
* @description: Método para consumo api Put.
*********************************************************************/
    @isTest
    public static void CallApiPut(){
        Test.startTest();
        List<CEN_PaymentOrder__c> lstPaymentOrder = [Select Id, Name from CEN_PaymentOrder__c where CEN_PaymentDescription__c = 'Test payment 1'];
        if(lstPaymentOrder.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/paymentorder/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf('{ "numPayment":"'+lstPaymentOrder[0].Name+'","status": "Pendiente","idculqi":"IdCulqiv01","type":"Pago Tarjeta","paymentdate":"2021-05-30 20:20:00","paymentcode": "Efectivo","reference": "reference", "lastfour":"1234", "bank":"BBVA", "currencycode":"PEN", "countrycode":"PE", "fee":1}');
            RestContext.request = request;
            String strPaymentOrder = CEN_PaymentOrderService_cls.doPut();
            System.debug('debe ser correcto');
            System.debug(strPaymentOrder);
            //system.assert(!strPaymentOrder.contains('Error'));
        }
        Test.stopTest();
    }

    @isTest
    public static void CallApiPutError(){
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/paymentorder/';
        request.httpMethod = 'POST';
        //PaymentOrder
        request.requestBody = Blob.valueOf('{ "numPayment":"PO00-5","status": "Pendiente","idculqi":"IdCulqiv01","type":"Pago Tarjeta","paymentdate":"2021-05-30 20:20:00","paymentcode": "Efectivo","reference": "reference", "lastfour":"1234", "bank":"BBVA", "currencycode":"PEN", "countrycode":"PE", "fee":1}');
        RestContext.request = request;
        system.assert(CEN_PaymentOrderService_cls.doPut().contains('Error'));
        Test.stopTest();
    }

}