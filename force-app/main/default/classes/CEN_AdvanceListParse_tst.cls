/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-05-09
* @description: Clase Test de evento call Api SAP - Listado de Anticipos.
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-05-09           Alan Alvarez            Creación 
*  
*********************************************************************/

@isTest
public class CEN_AdvanceListParse_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        projs[0].CEN_Sociedad__c = '0019';
        insert projs;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '0016728109';
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        mapOpp.put('Urbano', 2);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].CEN_Proyecto__c = projs[0].id;
        opps[0].AccountId = accs[0].id;
        opps[0].CEN_AmountPaidDate__c = 100;
        opps[0].CEN_Monto_cuota_de_inicial_de_precio__c = 500;
        opps[1].CEN_Proyecto__c = projs[0].id;
        opps[1].AccountId = accs[0].id;
        opps[1].CEN_AmountPaidDate__c = 100;
        opps[1].CEN_Monto_cuota_de_inicial_de_precio__c = 500;
        opps[1].Stagename = 'Oportunidad Perdida';
        insert opps;

        //---- ORDEN PAGO
        Date currentDay = system.today();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 100;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment 1';
        pyOrder.CEN_Opportunity__c = opps[1].Id;
        pyOrder.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder.CEN_DocumentNumberSAP__c = '8700002619';
        pyOrder.CEN_PaymentStatus__c = 'Suelto';
        pyOrder.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder;

        CEN_PaymentOrder__c pyOrder2 = new CEN_PaymentOrder__c();
        pyOrder2.CEN_Amount__c = 200;
        pyOrder2.CEN_CurrencyCode__c = 'PEN';
        pyOrder2.CEN_PaymentDescription__c = 'Test payment 2';
        pyOrder2.CEN_Opportunity__c = opps[0].Id;
        pyOrder2.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder2.CEN_DocumentNumberSAP__c = '8700002620';
        pyOrder2.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder2.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder2;

        CEN_PaymentOrder__c pyOrder3 = new CEN_PaymentOrder__c();
        pyOrder3.CEN_Amount__c = 200;
        pyOrder3.CEN_CurrencyCode__c = 'PEN';
        pyOrder3.CEN_PaymentDescription__c = 'Test payment 3';
        pyOrder3.CEN_Opportunity__c = opps[1].Id;
        pyOrder3.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder3.CEN_DocumentNumberSAP__c = '8700001326';
        pyOrder3.CEN_PaymentStatus__c = 'Pendiente';
        pyOrder3.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder3;

        CEN_PaymentOrder__c pyOrder4 = new CEN_PaymentOrder__c();
        pyOrder4.CEN_Amount__c = 200;
        pyOrder4.CEN_CurrencyCode__c = 'PEN';
        pyOrder4.CEN_PaymentDescription__c = 'Test payment 4';
        pyOrder4.CEN_Opportunity__c = opps[0].Id;
        pyOrder4.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        pyOrder4.CEN_AdvanceNumber__c = '8700002622';
        pyOrder4.CEN_PaymentStatus__c = 'Suelto';
        pyOrder4.CEN_PaymentDate__c = Datetime.now();
        insert pyOrder4;

    }

    @IsTest static void getAdvanceList_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_cls.getAdvanceListbyClient(oppId);
        Test.stopTest();
    }

    @IsTest static void getAdvanceListError_test(){
        String oppId = null;
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'error';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_cls.getAdvanceListbyClient(oppId);
        Test.stopTest();
    }

    @IsTest
    static void getAdvanceListController_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_ctr.getAdvanceList(oppId);
        Test.stopTest();
    }

    @IsTest
    static void getAdvanceListBloqueadoController_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String rspt = '[{"BELNR":"8700002620","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043578","WAERS":"PEN","WRBTR":"50.0"}]';
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_ctr.getAdvanceList(oppId);
        Test.stopTest();
    }

    @IsTest
    static void updateChangeController_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_ctr.updateChangeQuoteOperation(oppId);
        Test.stopTest();
    }

    @IsTest
    static void updateChangeErrorController_test(){
        String oppId = null;
        Test.startTest();
        CEN_AdvanceListParse_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_ctr.updateChangeQuoteOperation(oppId);
        Test.stopTest();
    }

    @IsTest
    static void generatePaymentOrderControllers_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String rspt = '[{"BELNR":"8700002621","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043579","WAERS":"PEN","WRBTR":"50.0"}]';
        Test.startTest();
        CEN_AdvanceList_ctr.generatePaymentOrder(oppId, rspt);
        Test.stopTest();
    }

    @IsTest
    static void generatePaymentOrderControllerError_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String rspt = null;
        Test.startTest();
        CEN_AdvanceList_ctr.generatePaymentOrder(oppId, rspt);
        Test.stopTest();
    }

    @IsTest
    static void generatePaymentOrderBloqueadoControllers_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String rspt = '[{"BELNR":"8700002620","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043578","WAERS":"PEN","WRBTR":"50.0"}]';
        Test.startTest();
        CEN_AdvanceList_ctr.generatePaymentOrder(oppId, rspt);
        Test.stopTest();
    }

    // @IsTest
    // static void generatePaymentOrderSueltoControllers_test(){
    //     String oppId = [SELECT Id FROM Opportunity WHERE StageName = 'Oportunidad Perdida' LIMIT 1].Id;
    //     String rspt = '[{"BELNR":"8700002619","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043556","WAERS":"PEN","WRBTR":"50.0"}]';
    //     Test.startTest();
    //     CEN_AdvanceList_ctr.generatePaymentOrder(oppId, rspt);
    //     Test.stopTest();
    // }

    @IsTest
    static void generatePaymentOrderSueltoBloqueadoControllers_test(){
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        String rspt = '[{"BELNR":"8700002622","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043580","WAERS":"PEN","WRBTR":"50.0"}]';
        Test.startTest();
        CEN_AdvanceList_ctr.generatePaymentOrder(oppId, rspt);
        Test.stopTest();
    }

    @IsTest
    static void callOperactionSafeController_test(){
        Test.startTest();
        Opportunity opp = [SELECT Id, CEN_Proforma__c FROM Opportunity LIMIT 1];
        opp.CEN_Proforma__c = '00010';
        update opp;
        CEN_AdvanceListParse_tst.respType = 'Safe';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AdvanceList_ctr.callOperactionSafe(opp.id);
        Test.stopTest();
    }

    @IsTest
    static void callOperactionSafeErrorController_test(){
        String oppId = null;
        Test.startTest();
        CEN_AdvanceList_ctr.callOperactionSafe(oppId);
        Test.stopTest();
    }

    @IsTest
    static void sendEmailControllers_test(){
        String rsptBloqueado = '{"BELNR":"8700002621","BLART":"Z5","BLDAT":"2021-04-29","BUDAT":"2021-04-29","BUKRS":"0019","DMBTR":"50.0","GJAHR":"2021","KUNNR":"0016728109","LTEXT":"Anticipo @Cons","PROFORMA":"0000043579","WAERS":"PEN","WRBTR":"50.0"}';
        rsptBloqueado += ',"showClass": "Error", "status": "Error", "detail": "El anticipo se encuentra asociado a la orden de pago PO-000327 con un estado diferente a suelto."}';
        Test.startTest();
        CEN_AdvanceList_ctr.sendEmailReportAdmin(rsptBloqueado);
        Test.stopTest();
    }

    @IsTest
    static void sendEmailControllersError_test(){
        String rsptBloqueado = null;
        Test.startTest();
        CEN_AdvanceList_ctr.sendEmailReportAdmin(rsptBloqueado);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_AdvanceListParse_tst.respType.equals('ok')) {
                String strBody = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_LISTA_ANTICIPOS_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_ANTICIPOS>';
                strBody = strBody + '<item><BUKRS>0019</BUKRS><BELNR>8700001326</BELNR><GJAHR>2018</GJAHR><WRBTR>718.0</WRBTR><WAERS>PEN</WAERS><DMBTR>718.0</DMBTR><BLDAT>2018-09-18</BLDAT><BUDAT>2018-09-18</BUDAT><BLART>Z5</BLART><LTEXT>Anticipo @Cons</LTEXT><KUNNR>0016728109</KUNNR><PROFORMA>0000033828</PROFORMA><RESERVA/></item>';
                strBody = strBody + '<item><BUKRS>0019</BUKRS><BELNR>8700001552</BELNR><GJAHR>2019</GJAHR><WRBTR>32.83</WRBTR><WAERS>PEN</WAERS><DMBTR>32.83</DMBTR><BLDAT>2019-01-22</BLDAT><BUDAT>2019-01-22</BUDAT><BLART>Z5</BLART><LTEXT>Anticipo @Cons</LTEXT><KUNNR>0016728109</KUNNR><PROFORMA>0000033828</PROFORMA><RESERVA/></item>';
                strBody = strBody + '</ET_ANTICIPOS></n0:ZRFC_OTC_LISTA_ANTICIPOS_WSResponse></soap-env:Body></soap-env:Envelope>';
                res.setBody(strBody);
                res.setStatusCode(200);
            } else if(CEN_AdvanceListParse_tst.respType.equals('Safe')){
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header /><soap-env:Body><n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_ANTICIPOS><item><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item></ET_ANTICIPOS><ET_CUOTAS_PROFORMA_SF><item><TIPO_CUOTA>CI001</TIPO_CUOTA><CUOTA>1</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>27</NO_DIAS_ACU><SALDO_INICIAL>20000.0</SALDO_INICIAL><AMORTIZACION>1800.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1800.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>18200.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-05-05</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS>0019</BUKRS><BELNR>8400000641</BELNR><GJAHR>2021</GJAHR></item><item><TIPO_CUOTA>CI002</TIPO_CUOTA><CUOTA>2</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>54</NO_DIAS_ACU><SALDO_INICIAL>18200.0</SALDO_INICIAL><AMORTIZACION>1800.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1800.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>16400.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI003</TIPO_CUOTA><CUOTA>3</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>81</NO_DIAS_ACU><SALDO_INICIAL>16400.0</SALDO_INICIAL><AMORTIZACION>3600.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>3600.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>12800.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI004</TIPO_CUOTA><CUOTA>4</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>108</NO_DIAS_ACU><SALDO_INICIAL>12800.0</SALDO_INICIAL><AMORTIZACION>3600.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>3600.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>9200.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI005</TIPO_CUOTA><CUOTA>5</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>135</NO_DIAS_ACU><SALDO_INICIAL>9200.0</SALDO_INICIAL><AMORTIZACION>3600.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>3600.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>5600.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI006</TIPO_CUOTA><CUOTA>6</CUOTA><NO_DIAS>27</NO_DIAS><NO_DIAS_ACU>162</NO_DIAS_ACU><SALDO_INICIAL>5600.0</SALDO_INICIAL><AMORTIZACION>3600.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>3600.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>2000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS001</TIPO_CUOTA><CUOTA>7</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>193</NO_DIAS_ACU><SALDO_INICIAL>2000.0</SALDO_INICIAL><AMORTIZACION>184.54</AMORTIZACION><INTERESES>35.49</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>35.49</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>1815.46</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS002</TIPO_CUOTA><CUOTA>8</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>224</NO_DIAS_ACU><SALDO_INICIAL>1815.46</SALDO_INICIAL><AMORTIZACION>187.81</AMORTIZACION><INTERESES>32.22</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>32.22</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>1627.65</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS003</TIPO_CUOTA><CUOTA>9</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>255</NO_DIAS_ACU><SALDO_INICIAL>1627.65</SALDO_INICIAL><AMORTIZACION>191.15</AMORTIZACION><INTERESES>28.88</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>28.88</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>1436.5</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS004</TIPO_CUOTA><CUOTA>10</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>286</NO_DIAS_ACU><SALDO_INICIAL>1436.5</SALDO_INICIAL><AMORTIZACION>194.54</AMORTIZACION><INTERESES>25.49</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>25.49</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>1241.96</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS005</TIPO_CUOTA><CUOTA>11</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>317</NO_DIAS_ACU><SALDO_INICIAL>1241.96</SALDO_INICIAL><AMORTIZACION>197.99</AMORTIZACION><INTERESES>22.04</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>22.04</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>1043.97</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS006</TIPO_CUOTA><CUOTA>12</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>348</NO_DIAS_ACU><SALDO_INICIAL>1043.97</SALDO_INICIAL><AMORTIZACION>201.5</AMORTIZACION><INTERESES>18.53</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>18.53</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>842.47</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS007</TIPO_CUOTA><CUOTA>13</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>379</NO_DIAS_ACU><SALDO_INICIAL>842.47</SALDO_INICIAL><AMORTIZACION>205.08</AMORTIZACION><INTERESES>14.95</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>14.95</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>637.39</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS008</TIPO_CUOTA><CUOTA>14</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>410</NO_DIAS_ACU><SALDO_INICIAL>637.39</SALDO_INICIAL><AMORTIZACION>208.72</AMORTIZACION><INTERESES>11.31</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>11.31</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>428.67</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS009</TIPO_CUOTA><CUOTA>15</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>441</NO_DIAS_ACU><SALDO_INICIAL>428.67</SALDO_INICIAL><AMORTIZACION>212.42</AMORTIZACION><INTERESES>7.61</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>7.61</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>216.25</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS010</TIPO_CUOTA><CUOTA>16</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>472</NO_DIAS_ACU><SALDO_INICIAL>216.25</SALDO_INICIAL><AMORTIZACION>216.25</AMORTIZACION><INTERESES>3.78</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>3.78</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>220.03</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD /><SALDO_FINAL>0.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-30</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN /><BUKRS /><BELNR /><GJAHR>0000</GJAHR></item></ET_CUOTAS_PROFORMA_SF><ET_INTERLOCUTORES><item><IND_INTERLOCUTOR /><INTERLOCUTOR1 /><INTERLOCUTOR2 /><INTERLOCUTOR3 /><INTERLOCUTOR4 /><INTERLOCUTOR5 /><INTERLOCUTOR6 /><INTERLOCUTOR7 /><INTERLOCUTOR8 /><INTERLOCUTOR9 /><INTERLOCUTOR10 /></item></ET_INTERLOCUTORES><ET_RETURN><item><TYPE>S</TYPE><ID>ZAC_B14</ID><NUMBER>126</NUMBER><MESSAGE>Se creó la Operación Segura 43588</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>Se creó la Operación Segura</MESSAGE_V1><MESSAGE_V2>43588</MESSAGE_V2><MESSAGE_V3 /><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_CAB_PROFORMA_SF><PROFORMA>0000043588</PROFORMA><VERSION>01</VERSION><PROFORMA_ANT>0000000001</PROFORMA_ANT><PROCESSO>19U1.120E</PROCESSO><COD_PROPIEDAD>00000001</COD_PROPIEDAD><COD_MINUTA>A001</COD_MINUTA><PROPIEDADES>1/</PROPIEDADES><BUKRS>0019</BUKRS><TIPO_PROFORMA>1</TIPO_PROFORMA><VBELN /><POSID>19U1120EI51VL0001</POSID><POSNR>00107221</POSNR><WAERS>PEN</WAERS><PRECIO>20000.0</PRECIO><KUNNR>0016728109</KUNNR><TIP_CLI_CONT>B</TIP_CLI_CONT><CUOTA_MINIMA>18000.0</CUOTA_MINIMA><CUOTA_INIC_IMP>18000.0</CUOTA_INIC_IMP><CUOTA_INIC_POR>0.0</CUOTA_INIC_POR><CUOTA_INIC_NO_CUOTAS>5</CUOTA_INIC_NO_CUOTAS><CUOTA_INIC_MIN>0.0</CUOTA_INIC_MIN><CUOTA_INIC_MAX>0.0</CUOTA_INIC_MAX><CUOTA_INIC_INTERES>0.0</CUOTA_INIC_INTERES><CUOTA_INIC_INTGAS>0.0</CUOTA_INIC_INTGAS><CUOTA_INIC_NO_CUOTAS_MIN>0</CUOTA_INIC_NO_CUOTAS_MIN><CUOTA_INIC_NO_CUOTAS_MAX>0</CUOTA_INIC_NO_CUOTAS_MAX><SALDO_NO_CUOTAS>10</SALDO_NO_CUOTAS><SALDO_NO_CUOTAS_MAX>0</SALDO_NO_CUOTAS_MAX><SALDO_INTERESES>0.0</SALDO_INTERESES><SALDO_INTGAS>0.0</SALDO_INTGAS><CUOTA_INIC_IMP_R>18000.0</CUOTA_INIC_IMP_R><PROMOTOR /><FECHA_INICIO>2021-05-05</FECHA_INICIO><VIA_FINANCIAMIENTO>CD</VIA_FINANCIAMIENTO><CASH>0.0</CASH><CASH_BLDAT>0000-00-00</CASH_BLDAT><CHECK_ENTREGA /><TELEMARKETING /><FIRMA_MECANIZ /><STATUS_INICIAL>01</STATUS_INICIAL><BFH>0.0</BFH><FECHA_ENT_PROY>0000-00-00</FECHA_ENT_PROY><IND_FINAN_CI>X</IND_FINAN_CI><FACILOTE_IND_CI>X</FACILOTE_IND_CI><COTIZACION_PROFORMA>O</COTIZACION_PROFORMA><DIAS_PAGO>10</DIAS_PAGO><INTERESES_CI>SI</INTERESES_CI><IMPORTE_RESERVA>0.0</IMPORTE_RESERVA><ZZZONAVENTA>ZV022</ZZZONAVENTA><MEDIO>0110</MEDIO><CANAL /><ETI_CLI_CONTA /><ETI_MEDIO /><ETI_ZONA /><ETI_PROMOTOR /><ETI_APO1 /><ETI_APO2 /><IMPORTE_SALDO_PRECIO>0.0</IMPORTE_SALDO_PRECIO><TASA_MANUAL_IND /><TASA_ANUAL_INTERES_FINAN>23.5</TASA_ANUAL_INTERES_FINAN><TASA_ANUAL_GASTOS_ADMIN>0.0</TASA_ANUAL_GASTOS_ADMIN><TASA_MENSUAL_INTERES_FINAN>0.0</TASA_MENSUAL_INTERES_FINAN><TASA_MENSUAL_GASTOS_ADMIN>0.0</TASA_MENSUAL_GASTOS_ADMIN><COSTO_TOTAL_MENSUAL>0.0</COSTO_TOTAL_MENSUAL><COSTO_TOTAL_ANUAL>0.0</COSTO_TOTAL_ANUAL><PERFIL_COBRAN>A01</PERFIL_COBRAN><PERIODO_DIAS>0</PERIODO_DIAS><IMPORTE_CUOTA>0.0</IMPORTE_CUOTA><CANTIDAD_LOTES>0001</CANTIDAD_LOTES><AREA_VENDIBLE>100.0</AREA_VENDIBLE><APODERADO_CENTENARIO1 /><APODERADO_CENTENARIO2 /><DIAS_ADICIONALES>3</DIAS_ADICIONALES><PRECIO_ORIGINAL>20000.0</PRECIO_ORIGINAL><TIPO_CAMBIO>0.0</TIPO_CAMBIO><INTERLOCUTOR1 /><INTERLOCUTOR2 /><INTERLOCUTOR3 /><INTERLOCUTOR4 /><INTERLOCUTOR5 /><INTERLOCUTOR6 /><INTERLOCUTOR7 /><INTERLOCUTOR8 /><INTERLOCUTOR9 /><INTERLOCUTOR10 /><APODERADO1 /><APODERADO2 /><MOTIVO_COMPRA>V</MOTIVO_COMPRA><IMPORTE_CI_CHAR>18000.00</IMPORTE_CI_CHAR><IND_PORCENTAJE /><ENTREGA /><FECHA_ENTREGA>0000-00-00</FECHA_ENTREGA><CONVERSION_ARRAS>NO</CONVERSION_ARRAS></E_CAB_PROFORMA_SF></n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(500);
            }
            return res;
        }
    }
}