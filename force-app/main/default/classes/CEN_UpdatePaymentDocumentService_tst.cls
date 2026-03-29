@isTest
public with sharing class CEN_UpdatePaymentDocumentService_tst {

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
        //acc.CEN_Numero_de_documento_del__c = '12345678';
        acc.CEN_N_mero_de_documento__pc = '45558710';
        insert acc;

        Account acc2 = new Account();
        acc2.FirstName = 'Test acc2';
        acc2.LastName = 'Apellido acc2';
        acc2.PersonEmail = 'acc2@tst.com';
        acc2.PersonMobilePhone = '987654321';
        //acc2.CEN_Numero_de_documento_del__c = '12345678';
        acc2.CEN_N_mero_de_documento__pc = '45558711';
        insert acc2;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.CloseDate = System.today();
        opp.StageName='Operación';
        opp.CEN_Proforma__c='0000050187';
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
        opp2.CEN_Proforma__c='';
        opp2.CEN_Tipo_de_solicitud__c='Solicitud';
        opp2.CEN_Tiene_Reserva__c='No';
        opp2.CEN_Con_sustento__c='No';
        opp2.CEN_Medio_Publicitario__c='Radio';
        opp2.CEN_Tipo_de_venta__c='CD';
        opp2.CEN_Proforma__c='0000050190';
        opp2.Amount=1000;
        opp2.CEN_AmountPaidDate__c=90;
        opp2.AccountId = acc2.id;
        opp2.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        insert opp2;

        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp3';
        opp3.CloseDate = System.today();
        opp3.StageName='Cotización';
        opp3.CEN_Proforma__c='0000050188';
        opp3.CEN_Tipo_de_solicitud__c='Solicitud';
        opp3.CEN_Tiene_Reserva__c='No';
        opp3.CEN_Con_sustento__c='No';
        opp3.CEN_Medio_Publicitario__c='Radio';
        opp3.CEN_Tipo_de_venta__c='CD';
        opp3.Amount=1000;
        opp3.CEN_AmountPaidDate__c=100;
        opp3.AccountId = acc2.id;
        opp3.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        insert opp3;

        Date currentDay = system.today();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 100;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment 1';
        pyOrder.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder.CEN_Opportunity__c = opp.Id;
        pyOrder.CEN_DocumentNumberSAP__c = '0123456789';
        pyOrder.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        DateTime myDateTime = DateTime.now();
        pyOrder.CEN_PaymentDate__c = myDateTime;
        insert pyOrder;

        CEN_PaymentOrder__c pyOrder2 = new CEN_PaymentOrder__c();
        pyOrder2.CEN_Amount__c = 200;
        pyOrder2.CEN_CurrencyCode__c = 'PEN';
        pyOrder2.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder2.CEN_PaymentDescription__c = 'Test payment 2';
        pyOrder2.CEN_Opportunity__c = opp.Id;
        pyOrder2.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder2.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder2;

        CEN_PaymentOrder__c pyOrder3 = new CEN_PaymentOrder__c();
        pyOrder3.CEN_Amount__c = 200;
        pyOrder3.CEN_CurrencyCode__c = 'PEN';
        pyOrder3.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder3.CEN_PaymentDescription__c = 'Test payment 3';
        pyOrder3.CEN_Opportunity__c = opp.Id;
        pyOrder3.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder3.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder3;

        CEN_PaymentOrder__c pyOrder4 = new CEN_PaymentOrder__c();
        pyOrder4.CEN_Amount__c = 100;
        pyOrder4.CEN_CurrencyCode__c = 'PEN';
        pyOrder4.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder4.CEN_PaymentDescription__c = 'Test payment 4';
        pyOrder4.CEN_Opportunity__c = opp3.Id;
        pyOrder4.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder4.CEN_DocumentNumberSAP__c = '0123456789';
        pyOrder4.CEN_OriginPayment__c = 'ABCU';
        pyOrder4.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder4;

        CEN_PaymentOrder__c pyOrder5 = new CEN_PaymentOrder__c();
        pyOrder5.CEN_Amount__c = 50;
        pyOrder5.CEN_CurrencyCode__c = 'PEN';
        pyOrder5.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder5.CEN_PaymentDescription__c = 'Test payment 5';
        pyOrder5.CEN_Opportunity__c = opp2.Id;
        pyOrder5.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder5.CEN_DocumentNumberSAP__c = '9876543210';
        pyOrder5.CEN_OriginPayment__c = 'ABCU';
        pyOrder5.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder5;
    }

    @isTest
    public static void TestCuandoNoSobrepasaMontoAAnular(){

        CEN_UpdatePaymentDocumentService_cls.ResponseWrap resp= new CEN_UpdatePaymentDocumentService_cls.ResponseWrap();

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/Opportunity/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf('{"payments": ['+
                                                '{"anulados":'+
                                                    '[{"PROFORMA": "50190","BELNR": "9876543210","GJAHR": 2022}]'+
                                                '},'+
                                                '{"nuevos":'+
                                                    '['+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000020",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 10,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "TCRE",'+
                                                            '"OPE_NUMERO": "OPETEST0020",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 20",'+
                                                            '"REFERENCIA": "325641",'+
                                                            '"PAIS_BANCO": "65",'+
                                                            '"CLAVE_BANC": "020",'+
                                                            '"COMIS_CULQI": 2.3,'+
                                                            '"FECHA_CULQI": "2022-03-30 00:00:00",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '},'+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000021",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 10,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "ABCU",'+
                                                            '"OPE_NUMERO": "OPETEST0021",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 21",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '}'+
                                                    ']'+ 
                                                '}'+ 
                                            ']}');
        RestContext.request = request;

        Test.startTest();
        resp = CEN_UpdatePaymentDocumentService_cls.upsertPaymentOrder();
        Test.stopTest();
        system.debug(resp);
        System.assertEquals('En la proforma 0000050190 los nuevos pagos suman un importe de PEN30.00 menos en comparación al monto de los pagos a anular', resp.error);
    }

    @isTest
    public static void TestCuandoSObrepasaMontoAAnular(){

        CEN_UpdatePaymentDocumentService_cls.ResponseWrap resp= new CEN_UpdatePaymentDocumentService_cls.ResponseWrap();

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/Opportunity/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf('{"payments": ['+
                                                '{"anulados":'+
                                                    '[{"PROFORMA": "50190","BELNR": "9876543210","GJAHR": 2022}]'+
                                                '},'+
                                                '{"nuevos":'+
                                                    '['+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000020",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 30,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "TCRE",'+
                                                            '"OPE_NUMERO": "OPETEST0020",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 20",'+
                                                            '"REFERENCIA": "325641",'+
                                                            '"PAIS_BANCO": "65",'+
                                                            '"CLAVE_BANC": "020",'+
                                                            '"COMIS_CULQI": 2.3,'+
                                                            '"FECHA_CULQI": "2022-03-30 00:00:00",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '},'+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000021",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 30,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "ABCU",'+
                                                            '"OPE_NUMERO": "OPETEST0021",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 21",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '}'+
                                                    ']'+
                                                '}'+
                                            ']}');
        RestContext.request = request;

        Test.startTest();
        resp = CEN_UpdatePaymentDocumentService_cls.upsertPaymentOrder();
        Test.stopTest();
        system.debug(resp);
        System.assertEquals('En la proforma 0000050190 los nuevos pagos suman un importe de PEN10.00 más en comparación al monto de los pagos a anular', resp.error);
    }

    @isTest
    public static void TestCuandoPagoNoTieneProforma(){

        CEN_UpdatePaymentDocumentService_cls.ResponseWrap resp= new CEN_UpdatePaymentDocumentService_cls.ResponseWrap();

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/Opportunity/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf('{"payments": ['+
                                                '{"anulados":'+
                                                    '[{"BELNR": "9876543210","GJAHR": 2022}]'+
                                                '},'+
                                                '{"nuevos":'+
                                                    '['+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000020",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 30,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "TCRE",'+
                                                            '"OPE_NUMERO": "OPETEST0020",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 20",'+
                                                            '"REFERENCIA": "325641",'+
                                                            '"PAIS_BANCO": "65",'+
                                                            '"CLAVE_BANC": "020",'+
                                                            '"COMIS_CULQI": 2.3,'+
                                                            '"FECHA_CULQI": "2022-03-30 00:00:00",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '},'+
                                                        '{"PROFORMA": "50190",'+
                                                            '"BELNR": "0000000021",'+
                                                            '"GJAHR": 2022,'+
                                                            '"OPE_IMPORTE": 30,'+
                                                            '"WAERS": "PEN",'+
                                                            '"VIA_PAGO": "ABCU",'+
                                                            '"OPE_NUMERO": "OPETEST0021",'+
                                                            '"NRO_CTA_BANCO": "01234567890123456789",'+
                                                            '"FEC_CONTAB": "2022-03-30 00:00:00",'+
                                                            '"DESCRIPCION": "PAGO NUEVO 21",'+
                                                            '"PAGO_EXTRANJERO": false'+
                                                        '}'+
                                                    ']'+
                                                '}'+
                                            ']}');
        RestContext.request = request;

        Test.startTest();
        resp = CEN_UpdatePaymentDocumentService_cls.upsertPaymentOrder();
        Test.stopTest();
        system.debug(resp);
        System.assertEquals('La proforma es obligatoria. Por favor verificar. (Doc SAP: )9876543210', resp.error);
    }
}