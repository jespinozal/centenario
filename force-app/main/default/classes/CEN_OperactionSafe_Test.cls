/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 04-22-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_OperactionSafe_Test {
    public static String respType = '';
    @TestSetup
	static void SetUp(){
        List<User> usuarios = CEN_cls_Test_Ventas_DF.getUsers();
        insert usuarios;

        // //---- PROJECTS
        // Map<String,Integer> mapProj = new Map<String,Integer>();
        // mapProj.put('myProj', 1);
        // List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        // for(Proyecto__c p: projs){
        //     p.CEN_Sociedad__c = '0019';
        //     p.CEN_MaximumPaymentDuePeriod__c = 3;
        // }
        // insert projs;

        // //---- LOTE
        // Product2 prod2 = new Product2();
        // prod2.Name='Lote prueba1';
        // prod2.CEN_Proyecto__c=projs[0].Id;
        // prod2.CODLOTE__c='123123123';
        // prod2.CODCOMPANIA__c='0010';
        // prod2.CEN_Tiene_Reserva__c='No';
        // prod2.CODESTADOLOTE__c='L';
        // prod2.CEN_PRECIOVENTAFUN__c='10000';
        // prod2.IsActive=true;
        // prod2.MANZANA__c = 'Mz. A1';
        // prod2.AREA__c = '100';
        // prod2.CEN_TIPOLOGIA__c= 'ESQUINA';
        // prod2.CEN_IdLotSAP__c = '00000073';
        // insert prod2;

        // PricebookEntry precio2= new PricebookEntry();
        // precio2.UseStandardPrice=false;
        // precio2.IsActive=true;
        // precio2.Pricebook2Id=Test.getStandardPricebookId();
        // precio2.Product2Id=prod2.Id;
        // precio2.UnitPrice=Decimal.valueOf(prod2.CEN_PRECIOVENTAFUN__c);
        // insert precio2;

        System.runAs(usuarios[0]){

            //---- PROJECTS
            Map<String,Integer> mapProj = new Map<String,Integer>();
            mapProj.put('myProj', 1);
            List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
            for(Proyecto__c p: projs){
                p.CEN_Sociedad__c = '0019';
                p.CEN_MaximumPaymentDuePeriod__c = 3;
            }
            insert projs;

            //---- LOTE
            Product2 prod2 = new Product2();
            prod2.Name='Lote prueba1';
            prod2.CEN_Proyecto__c=projs[0].Id;
            prod2.CODLOTE__c='123123123';
            prod2.CODCOMPANIA__c='0010';
            prod2.CEN_Tiene_Reserva__c='No';
            prod2.CODESTADOLOTE__c='L';
            prod2.CEN_PRECIOVENTAFUN__c='10000';
            prod2.IsActive=true;
            prod2.MANZANA__c = 'Mz. A1';
            prod2.AREA__c = '100';
            prod2.CEN_TIPOLOGIA__c= 'ESQUINA';
            prod2.CEN_IdLotSAP__c = '00000073';
            insert prod2;

            PricebookEntry precio2= new PricebookEntry();
            precio2.UseStandardPrice=false;
            precio2.IsActive=true;
            precio2.Pricebook2Id=Test.getStandardPricebookId();
            precio2.Product2Id=prod2.Id;
            precio2.UnitPrice=Decimal.valueOf(prod2.CEN_PRECIOVENTAFUN__c);
            insert precio2;
            //---- ACCOUNTS
            Map<String,Integer> mapAcc = new Map<String,Integer>();
            mapAcc.put('PersonAccount', 1);
            List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
            insert accs;

            //---- OPPORTUNITY
            Map<String,Integer> mapOpp = new Map<String,Integer>();
            mapOpp.put('Urbano', 1);
            List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
            opps[0].Pricebook2Id = Test.getStandardPricebookId();
            opps[0].CEN_Proyecto__c = projs[0].Id;
            opps[0].CEN_N_Cuotas_de_inicial_de_precio__c= 12;
            opps[0].CEN_N_Cuotas_del_Saldo_del_precio__c= 60;
            opps[0].CEN_Cuota_Facilote__c = false;
            opps[0].CEN_Tipo_de_venta__c = 'CD';
            opps[0].CEN_ProformaVersion__c = 1;
            opps[0].CEN_OpcionDesembolso__c = 'OPCION A';
            opps[0].CEN_FechaDesembolso__c = date.today();
            insert opps;

            OpportunityLineItem oppItem = new OpportunityLineItem();
            oppItem.Product2Id = prod2.Id;
            oppItem.OpportunityId = opps[0].Id;
            oppItem.Quantity = 1;
            oppItem.CEN_fld_precioVentaDscto__c = 800;
            oppItem.TotalPrice = 1000;
            insert oppItem;

            DateTime todaysDate = System.today();
            Quote qt1 = new Quote();
            qt1.OpportunityId = opps[0].Id;
            qt1.CEN_N_Cuotas_de_inicial_de_precio__c =12;
            qt1.CEN_N_cuotas_del_saldo_de_precio__c=60;
            qt1.Name = 'quote1';
            qt1.CEN_TypeOfSale__c = 'CD';
            qt1.CreatedDate = todaysDate;
            qt1.CEN_ProformaVersion__c = 1;
            qt1.CEN_CodigoTasa__c = 'TASA1';
            qt1.CEN_Tasa__c = '26';
            insert qt1;

            Quote qt2 = new Quote();
            qt2.OpportunityId = opps[0].Id;
            qt2.CEN_N_Cuotas_de_inicial_de_precio__c =1;
            qt2.CEN_N_cuotas_del_saldo_de_precio__c=0;
            qt2.Name = 'quote2';
            qt2.CEN_TypeOfSale__c = 'CD';
            qt2.CreatedDate = todaysDate;
            qt2.CEN_ProformaVersion__c = 2;
            qt2.CEN_CodigoTasa__c = 'TASA1';
            qt2.CEN_Tasa__c = '26';
            insert qt2;

            Quote qt3 = new Quote();
            qt3.OpportunityId = opps[0].Id;
            qt3.CEN_N_Cuotas_de_inicial_de_precio__c =1;
            qt3.CEN_N_cuotas_del_saldo_de_precio__c=0;
            qt3.Name = 'quote2';
            qt3.CEN_TypeOfSale__c = 'CD';
            qt3.CreatedDate = todaysDate;
            qt3.CEN_CodigoTasa__c = 'TASA1';
            qt3.CEN_Tasa__c = '26';
            insert qt3;

            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = qt1.Id;
            qli.Product2Id = prod2.Id;
            qli.CEN_fld_precioVentaDscto__c = 800;
            qli.Quantity = 1;
            qli.UnitPrice = 1000;
            qli.PricebookEntryId = precio2.Id;
            insert qli;
        }

    }
    public static testMethod void generateAndUpdateOperationSucessPRO_CO_test(){
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];

            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CO');
            update oportunidad;

            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessPRO_CD_test(){
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];

            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CD');
            oportunidad.CEN_Tipo_de_venta__c = 'CD';
            update oportunidad;

            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessPRO_CS_test(){
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];

            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CS');
            oportunidad.CEN_Tipo_de_venta__c = 'CS';
            update oportunidad;

            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessCVIA_CO_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CD');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            oportunidad.CEN_Tipo_de_venta__c = 'CO';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);
                
            CEN_OperactionSafe_Test.respType = 'CVIA';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessCVIA_CD_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CO');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            oportunidad.CEN_Tipo_de_venta__c = 'CD';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'CVIA';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessCVIA_CS_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CO');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            oportunidad.CEN_Tipo_de_venta__c = 'CS';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'CVIA';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessMODI_CO_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CO');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessMODI_CD_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CD');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessMODI_CS_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CS');
            oportunidad.Ownerid  = userinfo.getuserid();
            oportunidad.CEN_Proforma__c = '0000050840';
            update oportunidad;
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void getSimulacionPrepago_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];

        System.runAs(us1) {
            Opportunity opp = [SELECT Id,Owner.EmployeeNumber,CEN_Proforma__c,CEN_Inicial_de_precio__c,CEN_fld_totalPrecioVentaDscto__c FROM Opportunity LIMIT 1]; // Opp
            opp.Ownerid  = userinfo.getuserid();
            opp.CEN_Proforma__c = '0000050840';
            opp.CEN_Inicial_de_precio__c = 800;
            update opp;

            Map<String, String> respPrepagoCampos = new Map<String, String>();
            respPrepagoCampos = CEN_OperactionSafe_ctr.getSaldoInicialNroCuotas(opp.CEN_Proforma__c);
            respPrepagoCampos.put('cuotaSaldo', '13/06/2023');
            respPrepagoCampos.put('cantidadCuotaSaldo','sin proforma');

            CEN_OperactionSafe_ctr.getSimulacionPrepago(respPrepagoCampos);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationSucessRunAsNoEmployeeNumber_test() {

        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        us1.EmployeeNumber = '';
        update us1;
        System.runAs(us1) {
            Opportunity opp = [SELECT Id,Owner.EmployeeNumber FROM Opportunity LIMIT 1]; // Opp
            opp.Ownerid  = userinfo.getuserid();
            update opp;

            String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id; // Opp
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oppId};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'PROC';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationApiErrorCatch_test(){
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CD');
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'apiErrorCatch';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    public static testMethod void generateAndUpdateOperationError_test(){
        Test.startTest();
        User us1 = [SELECT Id, Name FROM User WHERE LastName='A0001 Anfitriona'];
        System.runAs(us1){
            String RecTypeId= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
            Account cuenta = [
                SELECT Id, IsPersonAccount, CEN_Referencia_direccion__c, CEN_Direccion__pc,
                CEN_Distrito__pc, CEN_Direcci_n__c, CEN_Distrito__c
                FROM Account WHERE RecordTypeId = :RecTypeId
            ];
            Opportunity oportunidad = generarOportunidad('Natural', cuenta, 'CD');
            List<CEN_OperactionSafe_ctr.FlowParameters> parameterList = new List<CEN_OperactionSafe_ctr.FlowParameters>();
            CEN_OperactionSafe_ctr.FlowParameters parameter = new CEN_OperactionSafe_ctr.FlowParameters();
            parameter.oppIds = new List<String>{oportunidad.Id};
            parameterList.add(parameter);

            CEN_OperactionSafe_Test.respType = 'error';
            Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            List<String> response = CEN_OperactionSafe_ctr.processOperactionSafe(parameterList);
        }
        Test.stopTest();
    }

    private static Opportunity generarOportunidad(String type, Account cuenta, String TypeOfSale){

        List<QuoteLineItem> qlitems = [
            SELECT Id, CEN_urbanizacion_proyecto__c, CEN_etapa__c,
            CEN_manzana_del_lote__c, CEN_area_del_lote__c,
            CEN_lote__c,  CEN_fld_precioVentaDscto__c
            FROM QuoteLineItem
        ];

        List<Quote> qitems = [
            SELECT Id, CEN_N_Cuotas_de_inicial_de_precio__c, CEN_N_cuotas_del_saldo_de_precio__c,
            Name, CEN_TypeOfSale__c,
            CreatedDate,  CEN_ProformaVersion__c
            FROM Quote
        ];

        List<Tabla_maestra__c> distritos = [SELECT Id FROM Tabla_maestra__c];
        List<Opportunity> oportunidades = [
            SELECT Id, Type, CEN_Sub_estado__c, CEN_Tipo_de_solicitud__c, CEN_Tiene_Reserva__c,
            CEN_Motivo_de_Compra__c, CEN_Con_sustento__c, CEN_Moneda__c, LeadSource, CEN_Medio_Publicitario__c,
            CEN_Oficina_de_Venta__c, CEN_Tipo_de_venta__c, Amount, StageName, Description, AccountId,
            OwnerId, Owner.Name, CEN_Fecha_de_pago__c, CEN_Direcci_n_Legal_Contrato__c, CEN_Distrito__c,
            CEN_Referencia_Direcci_n__c, CEN_fld_totalPrecioVentaDscto__c
            FROM Opportunity
        ];
        if(cuenta!=null){
            oportunidades[0].AccountId = cuenta.Id;
            oportunidades[0].CEN_Referencia_Direcci_n__c = cuenta.CEN_Referencia_direccion__c;
            if(cuenta.IsPersonAccount){
                oportunidades[0].CEN_Direcci_n_Legal_Contrato__c = cuenta.CEN_Direccion__pc;
                oportunidades[0].CEN_Distrito_opp__c = cuenta.CEN_Distrito__pc;
            }else{
                oportunidades[0].CEN_Direcci_n_Legal_Contrato__c = cuenta.CEN_Direcci_n__c;
                oportunidades[0].CEN_Distrito_opp__c = cuenta.CEN_Distrito__c;
            }
        }

        oportunidades[0].StageName='Cotización';
        oportunidades[0].Type = type;
        oportunidades[0].CEN_Sub_estado__c ='';
        oportunidades[0].CEN_Tipo_de_solicitud__c='Solicitud';
        oportunidades[0].CEN_Tiene_Reserva__c='No';
        oportunidades[0].CEN_Motivo_de_Compra__c='Vivienda';
        oportunidades[0].CEN_Con_sustento__c='No';
        oportunidades[0].CEN_Moneda__c='PEN';
        oportunidades[0].CEN_Medio_Publicitario__c='0118';
        oportunidades[0].LeadSource='Call Center';
        oportunidades[0].CEN_Oficina_de_Venta__c='ZV022';
        oportunidades[0].CEN_Tipo_de_venta__c=TypeOfSale;
        oportunidades[0].Amount=1000;
        oportunidades[0].CEN_Motivo_de_Compra__c='Vivienda';
        oportunidades[0].CEN_Con_sustento__c ='No';
        oportunidades[0].CEN_DiscountRate__c ='Descuento táctico';
        oportunidades[0].CEN_Fecha_de_pago__c = Date.today().addDays(10);
        update oportunidades[0];

        qitems[0].CEN_TypeOfSale__c = TypeOfSale;
        update qitems[0];

        qlitems[0].CEN_urbanizacion_proyecto__c = 'Urbanizacion';
        qlitems[0].CEN_etapa__c = 'Etapa Prueba';
        qlitems[0].CEN_manzana_del_lote__c = 'A1';
        qlitems[0].CEN_area_del_lote__c = 100.00;
        qlitems[0].CEN_lote__c = 'Lt.1';
        qlitems[0].CEN_fld_precioVentaDscto__c = 10000;
        update qlitems[0];
        return oportunidades[0];
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'text/xml');
            if (CEN_OperactionSafe_Test.respType.equals('PROC')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ES_DATOS_PREPAGO><MONTO_AHORRO>0.0</MONTO_AHORRO></ES_DATOS_PREPAGO><ET_CUOTAS_PROFORMA_SF/><ET_DETALLE_DSCTO_ADICIONAL><item><COD_PALANCA>PALANCA5</COD_PALANCA><DESC_PALANCA>ADICIONAL</DESC_PALANCA><COD_PROMOCION>PROMO0015</COD_PROMOCION><DESC_DESCUENTO>PALANCA 5 WORKFLOW</DESC_DESCUENTO><NIVEL_LIBERACION>1</NIVEL_LIBERACION><PORCEN_MAX_DESCUENTO>3.0</PORCEN_MAX_DESCUENTO><IMPORTE_MAX_DESCUENTO>3774.39</IMPORTE_MAX_DESCUENTO><MONEDA>PEN</MONEDA><APROBADOR>APROBADOR JEFE COMERCIAL</APROBADOR></item><item><COD_PALANCA>PALANCA5</COD_PALANCA><DESC_PALANCA>ADICIONAL</DESC_PALANCA><COD_PROMOCION>PROMO0015</COD_PROMOCION><DESC_DESCUENTO>PALANCA 5 WORKFLOW</DESC_DESCUENTO><NIVEL_LIBERACION>2</NIVEL_LIBERACION><PORCEN_MAX_DESCUENTO>10.0</PORCEN_MAX_DESCUENTO><IMPORTE_MAX_DESCUENTO>12581.31</IMPORTE_MAX_DESCUENTO><MONEDA>PEN</MONEDA><APROBADOR>APROBADOR GERENTE COMERCIAL</APROBADOR></item></ET_DETALLE_DSCTO_ADICIONAL><ET_DETALLE_PALANCAS><item><COD_PALANCA>PALANCA3</COD_PALANCA><DESC_PALANCA>TIEMPO</DESC_PALANCA><COD_PROMOCION>PROMO0013</COD_PROMOCION><DESC_DESCUENTO>MENOS TIEMPO MÁS DESCUENTO</DESC_DESCUENTO><PORCEN_DESCUENTO>3.0</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>3774.39</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA><OBLIGATORIO>NO</OBLIGATORIO><SUSTENTO>NO</SUSTENTO><PRIORIDAD/><APLICA>X</APLICA><MOTIVO>60 MESES O MENOS</MOTIVO></item></ET_DETALLE_PALANCAS><ET_MENSAJE_DSCTO_PALANCAS><item><COD_MENSAJE>MAX01</COD_MENSAJE><DETALLE>100% CASH</DETALLE><PALANCA>PALANCA2</PALANCA><PORCEN_DESCUENTO>35.0</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>44034.59</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA></item></ET_MENSAJE_DSCTO_PALANCAS><ET_RETURN><item><TYPE>E</TYPE><ID>ZACCC_RECA</ID><NUMBER>022</NUMBER><MESSAGE>No existe tipo de cambio para el dia de hoy : 21.03.2023</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>21.03.2023</MESSAGE_V1><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_CAB_PROFORMA_SF><PROFORMA>0000000000</PROFORMA><VERSION>00</VERSION><PROFORMA_ANT>0000000000</PROFORMA_ANT><PROCESSO/><COD_PROPIEDAD>00000000</COD_PROPIEDAD><COD_MINUTA/><PROPIEDADES/><BUKRS/><TIPO_PROFORMA>0</TIPO_PROFORMA><VBELN/><POSID/><POSNR>00000000</POSNR><WAERS/><PRECIO>0.0</PRECIO><KUNNR/><TIP_CLI_CONT/><CUOTA_MINIMA>0.0</CUOTA_MINIMA><CUOTA_INIC_IMP>0.0</CUOTA_INIC_IMP><CUOTA_INIC_POR>0.0</CUOTA_INIC_POR><CUOTA_INIC_NO_CUOTAS>0</CUOTA_INIC_NO_CUOTAS><CUOTA_INIC_MIN>0.0</CUOTA_INIC_MIN><CUOTA_INIC_MAX>0.0</CUOTA_INIC_MAX><CUOTA_INIC_INTERES>0.0</CUOTA_INIC_INTERES><CUOTA_INIC_INTGAS>0.0</CUOTA_INIC_INTGAS><CUOTA_INIC_NO_CUOTAS_MIN>0</CUOTA_INIC_NO_CUOTAS_MIN><CUOTA_INIC_NO_CUOTAS_MAX>0</CUOTA_INIC_NO_CUOTAS_MAX><SALDO_NO_CUOTAS>0</SALDO_NO_CUOTAS><SALDO_NO_CUOTAS_MAX>0</SALDO_NO_CUOTAS_MAX><SALDO_INTERESES>0.0</SALDO_INTERESES><SALDO_INTGAS>0.0</SALDO_INTGAS><CUOTA_INIC_IMP_R>0.0</CUOTA_INIC_IMP_R><PROMOTOR/><FECHA_INICIO>0000-00-00</FECHA_INICIO><VIA_FINANCIAMIENTO/><CASH>0.0</CASH><CASH_BLDAT>0000-00-00</CASH_BLDAT><CHECK_ENTREGA/><TELEMARKETING/><FIRMA_MECANIZ/><STATUS_INICIAL/><BFH>0.0</BFH><FECHA_ENT_PROY>0000-00-00</FECHA_ENT_PROY><IND_FINAN_CI/><FACILOTE_IND_CI/><COTIZACION_PROFORMA/><DIAS_PAGO/><INTERESES_CI/><IMPORTE_RESERVA>0.0</IMPORTE_RESERVA><ZZZONAVENTA/><MEDIO/><CANAL/><ETI_CLI_CONTA/><ETI_MEDIO/><ETI_ZONA/><ETI_PROMOTOR/><ETI_APO1/><ETI_APO2/><IMPORTE_SALDO_PRECIO>0.0</IMPORTE_SALDO_PRECIO><TASA_MANUAL_IND/><TASA_ANUAL_INTERES_FINAN>0.0</TASA_ANUAL_INTERES_FINAN><TASA_ANUAL_GASTOS_ADMIN>0.0</TASA_ANUAL_GASTOS_ADMIN><TASA_MENSUAL_INTERES_FINAN>0.0</TASA_MENSUAL_INTERES_FINAN><TASA_MENSUAL_GASTOS_ADMIN>0.0</TASA_MENSUAL_GASTOS_ADMIN><COSTO_TOTAL_MENSUAL>0.0</COSTO_TOTAL_MENSUAL><COSTO_TOTAL_ANUAL>0.0</COSTO_TOTAL_ANUAL><PERFIL_COBRAN/><PERIODO_DIAS>0</PERIODO_DIAS><IMPORTE_CUOTA>0.0</IMPORTE_CUOTA><CANTIDAD_LOTES>0000</CANTIDAD_LOTES><AREA_VENDIBLE>0.0</AREA_VENDIBLE><APODERADO_CENTENARIO1/><APODERADO_CENTENARIO2/><DIAS_ADICIONALES>0</DIAS_ADICIONALES><PRECIO_ORIGINAL>0.0</PRECIO_ORIGINAL><TIPO_CAMBIO>0.0</TIPO_CAMBIO><INTERLOCUTOR1/><INTERLOCUTOR2/><INTERLOCUTOR3/><INTERLOCUTOR4/><INTERLOCUTOR5/><INTERLOCUTOR6/><INTERLOCUTOR7/><INTERLOCUTOR8/><INTERLOCUTOR9/><INTERLOCUTOR10/><APODERADO1/><APODERADO2/><MOTIVO_COMPRA/><IMPORTE_CI_CHAR/><IND_PORCENTAJE/><ENTREGA/><FECHA_ENTREGA>0000-00-00</FECHA_ENTREGA><CONVERSION_ARRAS/></E_CAB_PROFORMA_SF><E_OPERACION_SEGURA>0000000000</E_OPERACION_SEGURA><IT_CUOTAS_PREPAGO/></n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_OperactionSafe_Test.respType.equals('CVIA')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ES_DATOS_PREPAGO><MONTO_AHORRO>0.0</MONTO_AHORRO></ES_DATOS_PREPAGO><ET_CUOTAS_PROFORMA_SF><item><TIPO_CUOTA>CI001</TIPO_CUOTA><CUOTA>1</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>31</NO_DIAS_ACU><SALDO_INICIAL>219055.2</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>210840.63</SALDO_FINAL><FECHA_VENCIMIENTO>2023-02-23</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS>0013</BUKRS><BELNR>8400000468</BELNR><GJAHR>2023</GJAHR></item><item><TIPO_CUOTA>CI002</TIPO_CUOTA><CUOTA>2</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>62</NO_DIAS_ACU><SALDO_INICIAL>210840.63</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>202626.06</SALDO_FINAL><FECHA_VENCIMIENTO>2023-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI003</TIPO_CUOTA><CUOTA>3</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>92</NO_DIAS_ACU><SALDO_INICIAL>202626.06</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>194411.49</SALDO_FINAL><FECHA_VENCIMIENTO>2023-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI004</TIPO_CUOTA><CUOTA>4</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>123</NO_DIAS_ACU><SALDO_INICIAL>194411.49</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>186196.92</SALDO_FINAL><FECHA_VENCIMIENTO>2023-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI005</TIPO_CUOTA><CUOTA>5</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>153</NO_DIAS_ACU><SALDO_INICIAL>186196.92</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>177982.35</SALDO_FINAL><FECHA_VENCIMIENTO>2023-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI006</TIPO_CUOTA><CUOTA>6</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>184</NO_DIAS_ACU><SALDO_INICIAL>177982.35</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>169767.78</SALDO_FINAL><FECHA_VENCIMIENTO>2023-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI007</TIPO_CUOTA><CUOTA>7</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>215</NO_DIAS_ACU><SALDO_INICIAL>169767.78</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>161553.21</SALDO_FINAL><FECHA_VENCIMIENTO>2023-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI008</TIPO_CUOTA><CUOTA>8</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>245</NO_DIAS_ACU><SALDO_INICIAL>161553.21</SALDO_INICIAL><AMORTIZACION>8214.57</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>8214.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>153338.64</SALDO_FINAL><FECHA_VENCIMIENTO>2023-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS001</TIPO_CUOTA><CUOTA>9</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>276</NO_DIAS_ACU><SALDO_INICIAL>153338.64</SALDO_INICIAL><AMORTIZACION>1373.73</AMORTIZACION><INTERESES>2866.83</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2866.83</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>151964.91</SALDO_FINAL><FECHA_VENCIMIENTO>2023-11-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS002</TIPO_CUOTA><CUOTA>10</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>306</NO_DIAS_ACU><SALDO_INICIAL>151964.91</SALDO_INICIAL><AMORTIZACION>1491.88</AMORTIZACION><INTERESES>2748.68</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2748.68</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>150473.03</SALDO_FINAL><FECHA_VENCIMIENTO>2023-12-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS003</TIPO_CUOTA><CUOTA>11</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>337</NO_DIAS_ACU><SALDO_INICIAL>150473.03</SALDO_INICIAL><AMORTIZACION>1427.3</AMORTIZACION><INTERESES>2813.26</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2813.26</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>149045.73</SALDO_FINAL><FECHA_VENCIMIENTO>2024-01-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS004</TIPO_CUOTA><CUOTA>12</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>368</NO_DIAS_ACU><SALDO_INICIAL>149045.73</SALDO_INICIAL><AMORTIZACION>1453.99</AMORTIZACION><INTERESES>2786.57</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2786.57</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>147591.74</SALDO_FINAL><FECHA_VENCIMIENTO>2024-02-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS005</TIPO_CUOTA><CUOTA>13</CUOTA><NO_DIAS>29</NO_DIAS><NO_DIAS_ACU>397</NO_DIAS_ACU><SALDO_INICIAL>147591.74</SALDO_INICIAL><AMORTIZACION>1660.74</AMORTIZACION><INTERESES>2579.82</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2579.82</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>145931.0</SALDO_FINAL><FECHA_VENCIMIENTO>2024-03-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS006</TIPO_CUOTA><CUOTA>14</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>428</NO_DIAS_ACU><SALDO_INICIAL>145931.0</SALDO_INICIAL><AMORTIZACION>1512.22</AMORTIZACION><INTERESES>2728.34</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2728.34</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>144418.78</SALDO_FINAL><FECHA_VENCIMIENTO>2024-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS007</TIPO_CUOTA><CUOTA>15</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>458</NO_DIAS_ACU><SALDO_INICIAL>144418.78</SALDO_INICIAL><AMORTIZACION>1628.37</AMORTIZACION><INTERESES>2612.19</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2612.19</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>142790.41</SALDO_FINAL><FECHA_VENCIMIENTO>2024-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS008</TIPO_CUOTA><CUOTA>16</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>489</NO_DIAS_ACU><SALDO_INICIAL>142790.41</SALDO_INICIAL><AMORTIZACION>1570.94</AMORTIZACION><INTERESES>2669.62</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2669.62</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>141219.47</SALDO_FINAL><FECHA_VENCIMIENTO>2024-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS009</TIPO_CUOTA><CUOTA>17</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>519</NO_DIAS_ACU><SALDO_INICIAL>141219.47</SALDO_INICIAL><AMORTIZACION>1686.24</AMORTIZACION><INTERESES>2554.32</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2554.32</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>139533.23</SALDO_FINAL><FECHA_VENCIMIENTO>2024-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS010</TIPO_CUOTA><CUOTA>18</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>550</NO_DIAS_ACU><SALDO_INICIAL>139533.23</SALDO_INICIAL><AMORTIZACION>1631.83</AMORTIZACION><INTERESES>2608.73</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2608.73</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>137901.4</SALDO_FINAL><FECHA_VENCIMIENTO>2024-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS011</TIPO_CUOTA><CUOTA>19</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>581</NO_DIAS_ACU><SALDO_INICIAL>137901.4</SALDO_INICIAL><AMORTIZACION>1662.34</AMORTIZACION><INTERESES>2578.22</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2578.22</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>136239.06</SALDO_FINAL><FECHA_VENCIMIENTO>2024-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS012</TIPO_CUOTA><CUOTA>20</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>611</NO_DIAS_ACU><SALDO_INICIAL>136239.06</SALDO_INICIAL><AMORTIZACION>1776.33</AMORTIZACION><INTERESES>2464.23</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2464.23</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>134462.73</SALDO_FINAL><FECHA_VENCIMIENTO>2024-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS013</TIPO_CUOTA><CUOTA>21</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>642</NO_DIAS_ACU><SALDO_INICIAL>134462.73</SALDO_INICIAL><AMORTIZACION>1726.63</AMORTIZACION><INTERESES>2513.93</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2513.93</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>132736.1</SALDO_FINAL><FECHA_VENCIMIENTO>2024-11-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS014</TIPO_CUOTA><CUOTA>22</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>672</NO_DIAS_ACU><SALDO_INICIAL>132736.1</SALDO_INICIAL><AMORTIZACION>1839.69</AMORTIZACION><INTERESES>2400.87</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2400.87</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>130896.41</SALDO_FINAL><FECHA_VENCIMIENTO>2024-12-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS015</TIPO_CUOTA><CUOTA>23</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>703</NO_DIAS_ACU><SALDO_INICIAL>130896.41</SALDO_INICIAL><AMORTIZACION>1793.31</AMORTIZACION><INTERESES>2447.25</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2447.25</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>129103.1</SALDO_FINAL><FECHA_VENCIMIENTO>2025-01-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS016</TIPO_CUOTA><CUOTA>24</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>734</NO_DIAS_ACU><SALDO_INICIAL>129103.1</SALDO_INICIAL><AMORTIZACION>1826.84</AMORTIZACION><INTERESES>2413.72</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2413.72</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>127276.26</SALDO_FINAL><FECHA_VENCIMIENTO>2025-02-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS017</TIPO_CUOTA><CUOTA>25</CUOTA><NO_DIAS>28</NO_DIAS><NO_DIAS_ACU>762</NO_DIAS_ACU><SALDO_INICIAL>127276.26</SALDO_INICIAL><AMORTIZACION>2093.2</AMORTIZACION><INTERESES>2147.36</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2147.36</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>125183.06</SALDO_FINAL><FECHA_VENCIMIENTO>2025-03-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS018</TIPO_CUOTA><CUOTA>26</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>793</NO_DIAS_ACU><SALDO_INICIAL>125183.06</SALDO_INICIAL><AMORTIZACION>1900.13</AMORTIZACION><INTERESES>2340.43</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2340.43</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>123282.93</SALDO_FINAL><FECHA_VENCIMIENTO>2025-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS019</TIPO_CUOTA><CUOTA>27</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>823</NO_DIAS_ACU><SALDO_INICIAL>123282.93</SALDO_INICIAL><AMORTIZACION>2010.67</AMORTIZACION><INTERESES>2229.89</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2229.89</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>121272.26</SALDO_FINAL><FECHA_VENCIMIENTO>2025-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS020</TIPO_CUOTA><CUOTA>28</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>854</NO_DIAS_ACU><SALDO_INICIAL>121272.26</SALDO_INICIAL><AMORTIZACION>1973.24</AMORTIZACION><INTERESES>2267.32</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2267.32</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>119299.02</SALDO_FINAL><FECHA_VENCIMIENTO>2025-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS021</TIPO_CUOTA><CUOTA>29</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>884</NO_DIAS_ACU><SALDO_INICIAL>119299.02</SALDO_INICIAL><AMORTIZACION>2082.73</AMORTIZACION><INTERESES>2157.83</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2157.83</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>117216.29</SALDO_FINAL><FECHA_VENCIMIENTO>2025-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS022</TIPO_CUOTA><CUOTA>30</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>915</NO_DIAS_ACU><SALDO_INICIAL>117216.29</SALDO_INICIAL><AMORTIZACION>2049.07</AMORTIZACION><INTERESES>2191.49</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2191.49</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>115167.22</SALDO_FINAL><FECHA_VENCIMIENTO>2025-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS023</TIPO_CUOTA><CUOTA>31</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>946</NO_DIAS_ACU><SALDO_INICIAL>115167.22</SALDO_INICIAL><AMORTIZACION>2087.38</AMORTIZACION><INTERESES>2153.18</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2153.18</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>113079.84</SALDO_FINAL><FECHA_VENCIMIENTO>2025-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS024</TIPO_CUOTA><CUOTA>32</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>976</NO_DIAS_ACU><SALDO_INICIAL>113079.84</SALDO_INICIAL><AMORTIZACION>2195.22</AMORTIZACION><INTERESES>2045.34</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2045.34</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>110884.62</SALDO_FINAL><FECHA_VENCIMIENTO>2025-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS025</TIPO_CUOTA><CUOTA>33</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1007</NO_DIAS_ACU><SALDO_INICIAL>110884.62</SALDO_INICIAL><AMORTIZACION>2167.45</AMORTIZACION><INTERESES>2073.11</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>2073.11</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>108717.17</SALDO_FINAL><FECHA_VENCIMIENTO>2025-11-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS026</TIPO_CUOTA><CUOTA>34</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1037</NO_DIAS_ACU><SALDO_INICIAL>108717.17</SALDO_INICIAL><AMORTIZACION>2274.13</AMORTIZACION><INTERESES>1966.43</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1966.43</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>106443.04</SALDO_FINAL><FECHA_VENCIMIENTO>2025-12-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS027</TIPO_CUOTA><CUOTA>35</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1068</NO_DIAS_ACU><SALDO_INICIAL>106443.04</SALDO_INICIAL><AMORTIZACION>2250.49</AMORTIZACION><INTERESES>1990.07</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1990.07</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>104192.55</SALDO_FINAL><FECHA_VENCIMIENTO>2026-01-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS028</TIPO_CUOTA><CUOTA>36</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1099</NO_DIAS_ACU><SALDO_INICIAL>104192.55</SALDO_INICIAL><AMORTIZACION>2292.57</AMORTIZACION><INTERESES>1947.99</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1947.99</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>101899.98</SALDO_FINAL><FECHA_VENCIMIENTO>2026-02-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS029</TIPO_CUOTA><CUOTA>37</CUOTA><NO_DIAS>28</NO_DIAS><NO_DIAS_ACU>1127</NO_DIAS_ACU><SALDO_INICIAL>101899.98</SALDO_INICIAL><AMORTIZACION>2521.34</AMORTIZACION><INTERESES>1719.22</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1719.22</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>99378.64</SALDO_FINAL><FECHA_VENCIMIENTO>2026-03-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS030</TIPO_CUOTA><CUOTA>38</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1158</NO_DIAS_ACU><SALDO_INICIAL>99378.64</SALDO_INICIAL><AMORTIZACION>2382.57</AMORTIZACION><INTERESES>1857.99</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1857.99</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>96996.07</SALDO_FINAL><FECHA_VENCIMIENTO>2026-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS031</TIPO_CUOTA><CUOTA>39</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1188</NO_DIAS_ACU><SALDO_INICIAL>96996.07</SALDO_INICIAL><AMORTIZACION>2486.14</AMORTIZACION><INTERESES>1754.42</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1754.42</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>94509.93</SALDO_FINAL><FECHA_VENCIMIENTO>2026-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS032</TIPO_CUOTA><CUOTA>40</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1219</NO_DIAS_ACU><SALDO_INICIAL>94509.93</SALDO_INICIAL><AMORTIZACION>2473.59</AMORTIZACION><INTERESES>1766.97</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1766.97</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>92036.34</SALDO_FINAL><FECHA_VENCIMIENTO>2026-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS033</TIPO_CUOTA><CUOTA>41</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1249</NO_DIAS_ACU><SALDO_INICIAL>92036.34</SALDO_INICIAL><AMORTIZACION>2575.85</AMORTIZACION><INTERESES>1664.71</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1664.71</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>89460.49</SALDO_FINAL><FECHA_VENCIMIENTO>2026-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS034</TIPO_CUOTA><CUOTA>42</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1280</NO_DIAS_ACU><SALDO_INICIAL>89460.49</SALDO_INICIAL><AMORTIZACION>2568.0</AMORTIZACION><INTERESES>1672.56</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1672.56</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>86892.49</SALDO_FINAL><FECHA_VENCIMIENTO>2026-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS035</TIPO_CUOTA><CUOTA>43</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1311</NO_DIAS_ACU><SALDO_INICIAL>86892.49</SALDO_INICIAL><AMORTIZACION>2616.01</AMORTIZACION><INTERESES>1624.55</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1624.55</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>84276.48</SALDO_FINAL><FECHA_VENCIMIENTO>2026-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS036</TIPO_CUOTA><CUOTA>44</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1341</NO_DIAS_ACU><SALDO_INICIAL>84276.48</SALDO_INICIAL><AMORTIZACION>2716.2</AMORTIZACION><INTERESES>1524.36</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1524.36</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>81560.28</SALDO_FINAL><FECHA_VENCIMIENTO>2026-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS037</TIPO_CUOTA><CUOTA>45</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1372</NO_DIAS_ACU><SALDO_INICIAL>81560.28</SALDO_INICIAL><AMORTIZACION>2715.7</AMORTIZACION><INTERESES>1524.86</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1524.86</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>78844.58</SALDO_FINAL><FECHA_VENCIMIENTO>2026-11-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS038</TIPO_CUOTA><CUOTA>46</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1402</NO_DIAS_ACU><SALDO_INICIAL>78844.58</SALDO_INICIAL><AMORTIZACION>2814.45</AMORTIZACION><INTERESES>1426.11</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1426.11</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>76030.13</SALDO_FINAL><FECHA_VENCIMIENTO>2026-12-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS039</TIPO_CUOTA><CUOTA>47</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1433</NO_DIAS_ACU><SALDO_INICIAL>76030.13</SALDO_INICIAL><AMORTIZACION>2819.09</AMORTIZACION><INTERESES>1421.47</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1421.47</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>73211.04</SALDO_FINAL><FECHA_VENCIMIENTO>2027-01-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS040</TIPO_CUOTA><CUOTA>48</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1464</NO_DIAS_ACU><SALDO_INICIAL>73211.04</SALDO_INICIAL><AMORTIZACION>2871.8</AMORTIZACION><INTERESES>1368.76</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1368.76</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>70339.24</SALDO_FINAL><FECHA_VENCIMIENTO>2027-02-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS041</TIPO_CUOTA><CUOTA>49</CUOTA><NO_DIAS>28</NO_DIAS><NO_DIAS_ACU>1492</NO_DIAS_ACU><SALDO_INICIAL>70339.24</SALDO_INICIAL><AMORTIZACION>3053.82</AMORTIZACION><INTERESES>1186.74</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1186.74</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>67285.42</SALDO_FINAL><FECHA_VENCIMIENTO>2027-03-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS042</TIPO_CUOTA><CUOTA>50</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1523</NO_DIAS_ACU><SALDO_INICIAL>67285.42</SALDO_INICIAL><AMORTIZACION>2982.59</AMORTIZACION><INTERESES>1257.97</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1257.97</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>64302.83</SALDO_FINAL><FECHA_VENCIMIENTO>2027-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS043</TIPO_CUOTA><CUOTA>51</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1553</NO_DIAS_ACU><SALDO_INICIAL>64302.83</SALDO_INICIAL><AMORTIZACION>3077.48</AMORTIZACION><INTERESES>1163.08</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1163.08</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>61225.35</SALDO_FINAL><FECHA_VENCIMIENTO>2027-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS044</TIPO_CUOTA><CUOTA>52</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1584</NO_DIAS_ACU><SALDO_INICIAL>61225.35</SALDO_INICIAL><AMORTIZACION>3095.88</AMORTIZACION><INTERESES>1144.68</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1144.68</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>58129.47</SALDO_FINAL><FECHA_VENCIMIENTO>2027-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS045</TIPO_CUOTA><CUOTA>53</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1614</NO_DIAS_ACU><SALDO_INICIAL>58129.47</SALDO_INICIAL><AMORTIZACION>3189.14</AMORTIZACION><INTERESES>1051.42</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1051.42</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>54940.33</SALDO_FINAL><FECHA_VENCIMIENTO>2027-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS046</TIPO_CUOTA><CUOTA>54</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1645</NO_DIAS_ACU><SALDO_INICIAL>54940.33</SALDO_INICIAL><AMORTIZACION>3213.39</AMORTIZACION><INTERESES>1027.17</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>1027.17</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>51726.94</SALDO_FINAL><FECHA_VENCIMIENTO>2027-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS047</TIPO_CUOTA><CUOTA>55</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1676</NO_DIAS_ACU><SALDO_INICIAL>51726.94</SALDO_INICIAL><AMORTIZACION>3273.47</AMORTIZACION><INTERESES>967.09</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>967.09</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>48453.47</SALDO_FINAL><FECHA_VENCIMIENTO>2027-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS048</TIPO_CUOTA><CUOTA>56</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1706</NO_DIAS_ACU><SALDO_INICIAL>48453.47</SALDO_INICIAL><AMORTIZACION>3364.15</AMORTIZACION><INTERESES>876.41</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>876.41</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>45089.32</SALDO_FINAL><FECHA_VENCIMIENTO>2027-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS049</TIPO_CUOTA><CUOTA>57</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1737</NO_DIAS_ACU><SALDO_INICIAL>45089.32</SALDO_INICIAL><AMORTIZACION>3397.57</AMORTIZACION><INTERESES>842.99</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>842.99</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>41691.75</SALDO_FINAL><FECHA_VENCIMIENTO>2027-11-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS050</TIPO_CUOTA><CUOTA>58</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1767</NO_DIAS_ACU><SALDO_INICIAL>41691.75</SALDO_INICIAL><AMORTIZACION>3486.46</AMORTIZACION><INTERESES>754.1</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>754.1</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>38205.29</SALDO_FINAL><FECHA_VENCIMIENTO>2027-12-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS051</TIPO_CUOTA><CUOTA>59</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1798</NO_DIAS_ACU><SALDO_INICIAL>38205.29</SALDO_INICIAL><AMORTIZACION>3526.27</AMORTIZACION><INTERESES>714.29</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>714.29</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>34679.02</SALDO_FINAL><FECHA_VENCIMIENTO>2028-01-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS052</TIPO_CUOTA><CUOTA>60</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1829</NO_DIAS_ACU><SALDO_INICIAL>34679.02</SALDO_INICIAL><AMORTIZACION>3592.2</AMORTIZACION><INTERESES>648.36</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>648.36</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>31086.82</SALDO_FINAL><FECHA_VENCIMIENTO>2028-02-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS053</TIPO_CUOTA><CUOTA>61</CUOTA><NO_DIAS>29</NO_DIAS><NO_DIAS_ACU>1858</NO_DIAS_ACU><SALDO_INICIAL>31086.82</SALDO_INICIAL><AMORTIZACION>3697.18</AMORTIZACION><INTERESES>543.38</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>543.38</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>27389.64</SALDO_FINAL><FECHA_VENCIMIENTO>2028-03-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS054</TIPO_CUOTA><CUOTA>62</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1889</NO_DIAS_ACU><SALDO_INICIAL>27389.64</SALDO_INICIAL><AMORTIZACION>3728.48</AMORTIZACION><INTERESES>512.08</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>512.08</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>23661.16</SALDO_FINAL><FECHA_VENCIMIENTO>2028-04-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS055</TIPO_CUOTA><CUOTA>63</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1919</NO_DIAS_ACU><SALDO_INICIAL>23661.16</SALDO_INICIAL><AMORTIZACION>3812.59</AMORTIZACION><INTERESES>427.97</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>427.97</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>19848.57</SALDO_FINAL><FECHA_VENCIMIENTO>2028-05-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS056</TIPO_CUOTA><CUOTA>64</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>1950</NO_DIAS_ACU><SALDO_INICIAL>19848.57</SALDO_INICIAL><AMORTIZACION>3869.47</AMORTIZACION><INTERESES>371.09</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>371.09</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>15979.1</SALDO_FINAL><FECHA_VENCIMIENTO>2028-06-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS057</TIPO_CUOTA><CUOTA>65</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>1980</NO_DIAS_ACU><SALDO_INICIAL>15979.1</SALDO_INICIAL><AMORTIZACION>3951.54</AMORTIZACION><INTERESES>289.02</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>289.02</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>12027.56</SALDO_FINAL><FECHA_VENCIMIENTO>2028-07-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS058</TIPO_CUOTA><CUOTA>66</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>2011</NO_DIAS_ACU><SALDO_INICIAL>12027.56</SALDO_INICIAL><AMORTIZACION>4015.69</AMORTIZACION><INTERESES>224.87</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>224.87</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>8011.87</SALDO_FINAL><FECHA_VENCIMIENTO>2028-08-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS059</TIPO_CUOTA><CUOTA>67</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>2042</NO_DIAS_ACU><SALDO_INICIAL>8011.87</SALDO_INICIAL><AMORTIZACION>4090.77</AMORTIZACION><INTERESES>149.79</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>149.79</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>4240.56</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>3921.1</SALDO_FINAL><FECHA_VENCIMIENTO>2028-09-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS060</TIPO_CUOTA><CUOTA>68</CUOTA><NO_DIAS>30</NO_DIAS><NO_DIAS_ACU>2072</NO_DIAS_ACU><SALDO_INICIAL>3921.1</SALDO_INICIAL><AMORTIZACION>3921.1</AMORTIZACION><INTERESES>70.92</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>70.92</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>3992.02</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>0.0</SALDO_FINAL><FECHA_VENCIMIENTO>2028-10-01</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item></ET_CUOTAS_PROFORMA_SF><ET_DETALLE_DSCTO_ADICIONAL><item><COD_PALANCA>PALANCA5</COD_PALANCA><DESC_PALANCA>Adicional</DESC_PALANCA><COD_PROMOCION>PROMO0015</COD_PROMOCION><DESC_DESCUENTO>PALANCA 5 WORKFLOW</DESC_DESCUENTO><NIVEL_LIBERACION>1</NIVEL_LIBERACION><PORCEN_MAX_DESCUENTO>3.0</PORCEN_MAX_DESCUENTO><IMPORTE_MAX_DESCUENTO>6571.66</IMPORTE_MAX_DESCUENTO><MONEDA>PEN</MONEDA><APROBADOR>APROBADOR JEFE COMERCIAL</APROBADOR></item><item><COD_PALANCA>PALANCA5</COD_PALANCA><DESC_PALANCA>Adicional</DESC_PALANCA><COD_PROMOCION>PROMO0015</COD_PROMOCION><DESC_DESCUENTO>PALANCA 5 WORKFLOW</DESC_DESCUENTO><NIVEL_LIBERACION>2</NIVEL_LIBERACION><PORCEN_MAX_DESCUENTO>10.0</PORCEN_MAX_DESCUENTO><IMPORTE_MAX_DESCUENTO>21905.52</IMPORTE_MAX_DESCUENTO><MONEDA>PEN</MONEDA><APROBADOR>APROBADOR GERENTE COMERCIAL</APROBADOR></item></ET_DETALLE_DSCTO_ADICIONAL><ET_DETALLE_PALANCAS><item><COD_PALANCA>PALANCA1</COD_PALANCA><DESC_PALANCA>Táctico</DESC_PALANCA><COD_PROMOCION>PROMO0010</COD_PROMOCION><DESC_DESCUENTO>VALLE LAS HIGUERAS - TACTICO</DESC_DESCUENTO><PORCEN_DESCUENTO>13.7</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>30000.0</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA><OBLIGATORIO>NO</OBLIGATORIO><SUSTENTO>NO</SUSTENTO><PRIORIDAD/><APLICA>X</APLICA><MOTIVO>DESCUENTO TACTICO APLICADO A TODOS LOS PEPS/DESCUENTO TACTICO APLICADO A TODOS LOS PEPS</MOTIVO></item><item><COD_PALANCA>PALANCA3</COD_PALANCA><DESC_PALANCA>Tiempo</DESC_PALANCA><COD_PROMOCION>PROMO0013</COD_PROMOCION><DESC_DESCUENTO>MENOS TIEMPO MÁS DESCUENTO</DESC_DESCUENTO><PORCEN_DESCUENTO>3.0</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>6571.66</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA><OBLIGATORIO>NO</OBLIGATORIO><SUSTENTO>NO</SUSTENTO><PRIORIDAD/><APLICA>X</APLICA><MOTIVO>60 MESES O MENOS</MOTIVO></item><item><COD_PALANCA>PALANCA4</COD_PALANCA><DESC_PALANCA>Especial</DESC_PALANCA><COD_PROMOCION>PROMO0014</COD_PROMOCION><DESC_DESCUENTO>BENEFICIOS CENTENARIO</DESC_DESCUENTO><PORCEN_DESCUENTO>10.0</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>21905.52</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA><OBLIGATORIO>NO</OBLIGATORIO><SUSTENTO>SI</SUSTENTO><PRIORIDAD/><APLICA/><MOTIVO>DEBE PRESENTAR EL FOTOCHECK DE CENTENARIO</MOTIVO></item></ET_DETALLE_PALANCAS><ET_MENSAJE_DSCTO_PALANCAS><item><COD_MENSAJE>MAX01</COD_MENSAJE><DETALLE>CONTADO</DETALLE><PALANCA>PALANCA2</PALANCA><PORCEN_DESCUENTO>25.0</PORCEN_DESCUENTO><IMPORTE_DESCUENTO>54763.8</IMPORTE_DESCUENTO><MONEDA>PEN</MONEDA></item></ET_MENSAJE_DSCTO_PALANCAS><ET_RETURN><item><TYPE>S</TYPE><ID>ZAC_OTC</ID><NUMBER>021</NUMBER><MESSAGE>Se modificó la Operación con Depósito 57638</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>57638</MESSAGE_V1><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_CAB_PROFORMA_SF><PROFORMA>0000057638</PROFORMA><VERSION>07</VERSION><PROFORMA_ANT>0000000007</PROFORMA_ANT><PROCESSO>13U1.209E</PROCESSO><COD_PROPIEDAD>00000035</COD_PROPIEDAD><COD_MINUTA>A034-035</COD_MINUTA><PROPIEDADES>35/34/</PROPIEDADES><BUKRS>0013</BUKRS><TIPO_PROFORMA>1</TIPO_PROFORMA><VBELN/><POSID>13U1209EI51VL0034</POSID><POSNR>00086719</POSNR><WAERS>PEN</WAERS><PRECIO>219055.2</PRECIO><KUNNR>0045558712</KUNNR><TIP_CLI_CONT>B</TIP_CLI_CONT><CUOTA_MINIMA>65716.56</CUOTA_MINIMA><CUOTA_INIC_IMP>65716.56</CUOTA_INIC_IMP><CUOTA_INIC_POR>0.0</CUOTA_INIC_POR><CUOTA_INIC_NO_CUOTAS>8</CUOTA_INIC_NO_CUOTAS><CUOTA_INIC_MIN>0.0</CUOTA_INIC_MIN><CUOTA_INIC_MAX>0.0</CUOTA_INIC_MAX><CUOTA_INIC_INTERES>0.0</CUOTA_INIC_INTERES><CUOTA_INIC_INTGAS>0.0</CUOTA_INIC_INTGAS><CUOTA_INIC_NO_CUOTAS_MIN>0</CUOTA_INIC_NO_CUOTAS_MIN><CUOTA_INIC_NO_CUOTAS_MAX>0</CUOTA_INIC_NO_CUOTAS_MAX><SALDO_NO_CUOTAS>60</SALDO_NO_CUOTAS><SALDO_NO_CUOTAS_MAX>0</SALDO_NO_CUOTAS_MAX><SALDO_INTERESES>0.0</SALDO_INTERESES><SALDO_INTGAS>0.0</SALDO_INTGAS><CUOTA_INIC_IMP_R>65716.56</CUOTA_INIC_IMP_R><PROMOTOR>V00759</PROMOTOR><FECHA_INICIO>2023-02-23</FECHA_INICIO><VIA_FINANCIAMIENTO>CD</VIA_FINANCIAMIENTO><CASH>0.0</CASH><CASH_BLDAT>0000-00-00</CASH_BLDAT><CHECK_ENTREGA/><TELEMARKETING/><FIRMA_MECANIZ/><STATUS_INICIAL>01</STATUS_INICIAL><BFH>0.0</BFH><FECHA_ENT_PROY>0000-00-00</FECHA_ENT_PROY><IND_FINAN_CI>X</IND_FINAN_CI><FACILOTE_IND_CI/><COTIZACION_PROFORMA>O</COTIZACION_PROFORMA><DIAS_PAGO>01</DIAS_PAGO><INTERESES_CI>SI</INTERESES_CI><IMPORTE_RESERVA>0.0</IMPORTE_RESERVA><ZZZONAVENTA>ZV031</ZZZONAVENTA><MEDIO>0110</MEDIO><CANAL/><ETI_CLI_CONTA/><ETI_MEDIO/><ETI_ZONA/><ETI_PROMOTOR/><ETI_APO1/><ETI_APO2/><IMPORTE_SALDO_PRECIO>153338.64</IMPORTE_SALDO_PRECIO><TASA_MANUAL_IND/><TASA_ANUAL_INTERES_FINAN>24.0</TASA_ANUAL_INTERES_FINAN><TASA_ANUAL_GASTOS_ADMIN>0.0</TASA_ANUAL_GASTOS_ADMIN><TASA_MENSUAL_INTERES_FINAN>1.80875825</TASA_MENSUAL_INTERES_FINAN><TASA_MENSUAL_GASTOS_ADMIN>0.0</TASA_MENSUAL_GASTOS_ADMIN><COSTO_TOTAL_MENSUAL>1.80875825</COSTO_TOTAL_MENSUAL><COSTO_TOTAL_ANUAL>0.0</COSTO_TOTAL_ANUAL><PERFIL_COBRAN>A01</PERFIL_COBRAN><PERIODO_DIAS>30</PERIODO_DIAS><IMPORTE_CUOTA>0.0</IMPORTE_CUOTA><CANTIDAD_LOTES>0002</CANTIDAD_LOTES><AREA_VENDIBLE>118.0</AREA_VENDIBLE><APODERADO_CENTENARIO1/><APODERADO_CENTENARIO2/><DIAS_ADICIONALES>3</DIAS_ADICIONALES><PRECIO_ORIGINAL>219055.2</PRECIO_ORIGINAL><TIPO_CAMBIO>0.0</TIPO_CAMBIO><INTERLOCUTOR1/><INTERLOCUTOR2/><INTERLOCUTOR3/><INTERLOCUTOR4/><INTERLOCUTOR5/><INTERLOCUTOR6/><INTERLOCUTOR7/><INTERLOCUTOR8/><INTERLOCUTOR9/><INTERLOCUTOR10/><APODERADO1/><APODERADO2/><MOTIVO_COMPRA>I</MOTIVO_COMPRA><IMPORTE_CI_CHAR>65716.56</IMPORTE_CI_CHAR><IND_PORCENTAJE/><ENTREGA/><FECHA_ENTREGA>0000-00-00</FECHA_ENTREGA><CONVERSION_ARRAS>NO</CONVERSION_ARRAS></E_CAB_PROFORMA_SF><E_OPERACION_SEGURA>0000057638</E_OPERACION_SEGURA><IT_CUOTAS_PREPAGO/></n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }
            else if (CEN_OperactionSafe_Test.respType.equals('apiErrorCatch'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_CUOTAS_PROFORMA_SF><item><TIPO_CUOTA>CI001</TIPO_CUOTA><CUOTA>1</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>22</NO_DIAS_ACU><SALDO_INICIAL>20000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>19000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-09</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS>0019</BUKRS><BELNR>8400001608</BELNR><GJAHR>2021</GJAHR></item><item><TIPO_CUOTA>CI002</TIPO_CUOTA><CUOTA>2</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>44</NO_DIAS_ACU><SALDO_INICIAL>19000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>18000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI003</TIPO_CUOTA><CUOTA>3</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>66</NO_DIAS_ACU><SALDO_INICIAL>18000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>17000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI004</TIPO_CUOTA><CUOTA>4</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>88</NO_DIAS_ACU><SALDO_INICIAL>17000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>16000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI005</TIPO_CUOTA><CUOTA>5</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>110</NO_DIAS_ACU><SALDO_INICIAL>16000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>15000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI006</TIPO_CUOTA><CUOTA>6</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>132</NO_DIAS_ACU><SALDO_INICIAL>15000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>14000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS001</TIPO_CUOTA><CUOTA>7</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>163</NO_DIAS_ACU><SALDO_INICIAL>14000.0</SALDO_INICIAL><AMORTIZACION>1057.14</AMORTIZACION><INTERESES>248.43</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>248.43</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>12942.86</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS002</TIPO_CUOTA><CUOTA>8</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>194</NO_DIAS_ACU><SALDO_INICIAL>12942.86</SALDO_INICIAL><AMORTIZACION>1075.9</AMORTIZACION><INTERESES>229.67</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>229.67</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>11866.96</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS003</TIPO_CUOTA><CUOTA>9</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>225</NO_DIAS_ACU><SALDO_INICIAL>11866.96</SALDO_INICIAL><AMORTIZACION>1094.99</AMORTIZACION><INTERESES>210.58</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>210.58</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>10771.97</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS004</TIPO_CUOTA><CUOTA>10</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>256</NO_DIAS_ACU><SALDO_INICIAL>10771.97</SALDO_INICIAL><AMORTIZACION>1114.42</AMORTIZACION><INTERESES>191.15</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>191.15</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>9657.55</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS005</TIPO_CUOTA><CUOTA>11</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>287</NO_DIAS_ACU><SALDO_INICIAL>9657.55</SALDO_INICIAL><AMORTIZACION>1134.2</AMORTIZACION><INTERESES>171.37</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>171.37</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>8523.35</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS006</TIPO_CUOTA><CUOTA>12</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>318</NO_DIAS_ACU><SALDO_INICIAL>8523.35</SALDO_INICIAL><AMORTIZACION>1154.32</AMORTIZACION><INTERESES>151.25</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>151.25</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>7369.03</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS007</TIPO_CUOTA><CUOTA>13</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>349</NO_DIAS_ACU><SALDO_INICIAL>7369.03</SALDO_INICIAL><AMORTIZACION>1174.81</AMORTIZACION><INTERESES>130.76</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>130.76</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>6194.22</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS008</TIPO_CUOTA><CUOTA>14</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>380</NO_DIAS_ACU><SALDO_INICIAL>6194.22</SALDO_INICIAL><AMORTIZACION>1195.65</AMORTIZACION><INTERESES>109.92</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>109.92</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>4998.57</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS009</TIPO_CUOTA><CUOTA>15</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>411</NO_DIAS_ACU><SALDO_INICIAL>4998.57</SALDO_INICIAL><AMORTIZACION>1216.87</AMORTIZACION><INTERESES>88.7</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>88.7</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>3781.7</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS010</TIPO_CUOTA><CUOTA>16</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>442</NO_DIAS_ACU><SALDO_INICIAL>3781.7</SALDO_INICIAL><AMORTIZACION>1238.46</AMORTIZACION><INTERESES>67.11</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>67.11</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>2543.24</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS011</TIPO_CUOTA><CUOTA>17</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>473</NO_DIAS_ACU><SALDO_INICIAL>2543.24</SALDO_INICIAL><AMORTIZACION>1260.44</AMORTIZACION><INTERESES>45.13</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>45.13</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>1282.8</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS012</TIPO_CUOTA><CUOTA>18</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>504</NO_DIAS_ACU><SALDO_INICIAL>1282.8</SALDO_INICIAL><AMORTIZACION>1282.8</AMORTIZACION><INTERESES>22.77</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>22.77</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>0.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item></ET_CUOTAS_PROFORMA_SF><ET_RETURN><item><TYPE_x>apiErrorCatch</TYPE_x><ID>ZAC_OTC</ID><NUMBER>022</NUMBER><MESSAGE>Se creó la Operación Segura 43893</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>43893</MESSAGE_V1><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_CAB_PROFORMA_SF><PROFORMA></PROFORMA><VERSION>01</VERSION><PROFORMA_ANT>0000000001</PROFORMA_ANT><PROCESSO>19U1.120E</PROCESSO><COD_PROPIEDAD>00000073</COD_PROPIEDAD><COD_MINUTA>A073</COD_MINUTA><PROPIEDADES>73/</PROPIEDADES><BUKRS>0019</BUKRS><TIPO_PROFORMA>1</TIPO_PROFORMA><VBELN/><POSID>19U1120EI51VL0073</POSID><POSNR>00107610</POSNR><WAERS>PEN</WAERS><PRECIO>20000.0</PRECIO><KUNNR>0080305321</KUNNR><TIP_CLI_CONT>B</TIP_CLI_CONT><CUOTA_MINIMA>6000.0</CUOTA_MINIMA><CUOTA_INIC_IMP>6000.0</CUOTA_INIC_IMP><CUOTA_INIC_POR>0.0</CUOTA_INIC_POR><CUOTA_INIC_NO_CUOTAS>6</CUOTA_INIC_NO_CUOTAS><CUOTA_INIC_MIN>0.0</CUOTA_INIC_MIN><CUOTA_INIC_MAX>0.0</CUOTA_INIC_MAX><CUOTA_INIC_INTERES>0.0</CUOTA_INIC_INTERES><CUOTA_INIC_INTGAS>0.0</CUOTA_INIC_INTGAS><CUOTA_INIC_NO_CUOTAS_MIN>0</CUOTA_INIC_NO_CUOTAS_MIN><CUOTA_INIC_NO_CUOTAS_MAX>0</CUOTA_INIC_NO_CUOTAS_MAX><SALDO_NO_CUOTAS>12</SALDO_NO_CUOTAS><SALDO_NO_CUOTAS_MAX>0</SALDO_NO_CUOTAS_MAX><SALDO_INTERESES>0.0</SALDO_INTERESES><SALDO_INTGAS>0.0</SALDO_INTGAS><CUOTA_INIC_IMP_R>6000.0</CUOTA_INIC_IMP_R><PROMOTOR/><FECHA_INICIO>2021-06-09</FECHA_INICIO><VIA_FINANCIAMIENTO>CD</VIA_FINANCIAMIENTO><CASH>0.0</CASH><CASH_BLDAT>0000-00-00</CASH_BLDAT><CHECK_ENTREGA/><TELEMARKETING/><FIRMA_MECANIZ/><STATUS_INICIAL>01</STATUS_INICIAL><BFH>0.0</BFH><FECHA_ENT_PROY>0000-00-00</FECHA_ENT_PROY><IND_FINAN_CI>X</IND_FINAN_CI><FACILOTE_IND_CI/><COTIZACION_PROFORMA>O</COTIZACION_PROFORMA><DIAS_PAGO>1</DIAS_PAGO><INTERESES_CI>SI</INTERESES_CI><IMPORTE_RESERVA>0.0</IMPORTE_RESERVA><ZZZONAVENTA>ZV022</ZZZONAVENTA><MEDIO>0132</MEDIO><CANAL/><ETI_CLI_CONTA/><ETI_MEDIO/><ETI_ZONA/><ETI_PROMOTOR/><ETI_APO1/><ETI_APO2/><IMPORTE_SALDO_PRECIO>0.0</IMPORTE_SALDO_PRECIO><TASA_MANUAL_IND/><TASA_ANUAL_INTERES_FINAN>23.5</TASA_ANUAL_INTERES_FINAN><TASA_ANUAL_GASTOS_ADMIN>0.0</TASA_ANUAL_GASTOS_ADMIN><TASA_MENSUAL_INTERES_FINAN>0.0</TASA_MENSUAL_INTERES_FINAN><TASA_MENSUAL_GASTOS_ADMIN>0.0</TASA_MENSUAL_GASTOS_ADMIN><COSTO_TOTAL_MENSUAL>0.0</COSTO_TOTAL_MENSUAL><COSTO_TOTAL_ANUAL>0.0</COSTO_TOTAL_ANUAL><PERFIL_COBRAN>A01</PERFIL_COBRAN><PERIODO_DIAS>0</PERIODO_DIAS><IMPORTE_CUOTA>0.0</IMPORTE_CUOTA><CANTIDAD_LOTES>0001</CANTIDAD_LOTES><AREA_VENDIBLE>100.0</AREA_VENDIBLE><APODERADO_CENTENARIO1/><APODERADO_CENTENARIO2/><DIAS_ADICIONALES>3</DIAS_ADICIONALES><PRECIO_ORIGINAL>20000.0</PRECIO_ORIGINAL><TIPO_CAMBIO>0.0</TIPO_CAMBIO><INTERLOCUTOR1/><INTERLOCUTOR2/><INTERLOCUTOR3/><INTERLOCUTOR4/><INTERLOCUTOR5/><INTERLOCUTOR6/><INTERLOCUTOR7/><INTERLOCUTOR8/><INTERLOCUTOR9/><INTERLOCUTOR10/><APODERADO1/><APODERADO2/><MOTIVO_COMPRA>I</MOTIVO_COMPRA><IMPORTE_CI_CHAR>6000.00</IMPORTE_CI_CHAR><IND_PORCENTAJE/><ENTREGA/><FECHA_ENTREGA>0000-00-00</FECHA_ENTREGA><CONVERSION_ARRAS>NO</CONVERSION_ARRAS></E_CAB_PROFORMA_SF><E_OPERACION_SEGURA>0000043893</E_OPERACION_SEGURA></n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_OperactionSafe_Test.respType.equals('error'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_CUOTAS_PROFORMA_SF><item><TIPO_CUOTA>CI001</TIPO_CUOTA><CUOTA>1</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>22</NO_DIAS_ACU><SALDO_INICIAL>20000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>19000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-06-09</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS>0019</BUKRS><BELNR>8400001608</BELNR><GJAHR>2021</GJAHR></item><item><TIPO_CUOTA>CI002</TIPO_CUOTA><CUOTA>2</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>44</NO_DIAS_ACU><SALDO_INICIAL>19000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>18000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI003</TIPO_CUOTA><CUOTA>3</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>66</NO_DIAS_ACU><SALDO_INICIAL>18000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>17000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI004</TIPO_CUOTA><CUOTA>4</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>88</NO_DIAS_ACU><SALDO_INICIAL>17000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>16000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI005</TIPO_CUOTA><CUOTA>5</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>110</NO_DIAS_ACU><SALDO_INICIAL>16000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>15000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CI006</TIPO_CUOTA><CUOTA>6</CUOTA><NO_DIAS>22</NO_DIAS><NO_DIAS_ACU>132</NO_DIAS_ACU><SALDO_INICIAL>15000.0</SALDO_INICIAL><AMORTIZACION>1000.0</AMORTIZACION><INTERESES>0.0</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>0.0</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1000.0</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>14000.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS001</TIPO_CUOTA><CUOTA>7</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>163</NO_DIAS_ACU><SALDO_INICIAL>14000.0</SALDO_INICIAL><AMORTIZACION>1057.14</AMORTIZACION><INTERESES>248.43</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>248.43</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>12942.86</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS002</TIPO_CUOTA><CUOTA>8</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>194</NO_DIAS_ACU><SALDO_INICIAL>12942.86</SALDO_INICIAL><AMORTIZACION>1075.9</AMORTIZACION><INTERESES>229.67</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>229.67</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>11866.96</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS003</TIPO_CUOTA><CUOTA>9</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>225</NO_DIAS_ACU><SALDO_INICIAL>11866.96</SALDO_INICIAL><AMORTIZACION>1094.99</AMORTIZACION><INTERESES>210.58</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>210.58</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>10771.97</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS004</TIPO_CUOTA><CUOTA>10</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>256</NO_DIAS_ACU><SALDO_INICIAL>10771.97</SALDO_INICIAL><AMORTIZACION>1114.42</AMORTIZACION><INTERESES>191.15</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>191.15</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>9657.55</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS005</TIPO_CUOTA><CUOTA>11</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>287</NO_DIAS_ACU><SALDO_INICIAL>9657.55</SALDO_INICIAL><AMORTIZACION>1134.2</AMORTIZACION><INTERESES>171.37</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>171.37</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>8523.35</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS006</TIPO_CUOTA><CUOTA>12</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>318</NO_DIAS_ACU><SALDO_INICIAL>8523.35</SALDO_INICIAL><AMORTIZACION>1154.32</AMORTIZACION><INTERESES>151.25</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>151.25</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>7369.03</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS007</TIPO_CUOTA><CUOTA>13</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>349</NO_DIAS_ACU><SALDO_INICIAL>7369.03</SALDO_INICIAL><AMORTIZACION>1174.81</AMORTIZACION><INTERESES>130.76</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>130.76</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>6194.22</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS008</TIPO_CUOTA><CUOTA>14</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>380</NO_DIAS_ACU><SALDO_INICIAL>6194.22</SALDO_INICIAL><AMORTIZACION>1195.65</AMORTIZACION><INTERESES>109.92</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>109.92</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>4998.57</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS009</TIPO_CUOTA><CUOTA>15</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>411</NO_DIAS_ACU><SALDO_INICIAL>4998.57</SALDO_INICIAL><AMORTIZACION>1216.87</AMORTIZACION><INTERESES>88.7</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>88.7</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>3781.7</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS010</TIPO_CUOTA><CUOTA>16</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>442</NO_DIAS_ACU><SALDO_INICIAL>3781.7</SALDO_INICIAL><AMORTIZACION>1238.46</AMORTIZACION><INTERESES>67.11</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>67.11</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>2543.24</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS011</TIPO_CUOTA><CUOTA>17</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>473</NO_DIAS_ACU><SALDO_INICIAL>2543.24</SALDO_INICIAL><AMORTIZACION>1260.44</AMORTIZACION><INTERESES>45.13</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>45.13</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>1282.8</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item><item><TIPO_CUOTA>CS012</TIPO_CUOTA><CUOTA>18</CUOTA><NO_DIAS>31</NO_DIAS><NO_DIAS_ACU>504</NO_DIAS_ACU><SALDO_INICIAL>1282.8</SALDO_INICIAL><AMORTIZACION>1282.8</AMORTIZACION><INTERESES>22.77</INTERESES><GASTOS>0.0</GASTOS><INTERES_GASTOS>22.77</INTERES_GASTOS><DESEMPLEO>0.0</DESEMPLEO><SEGURO_VIDA>0.0</SEGURO_VIDA><IMP_CUOTA>1305.57</IMP_CUOTA><WAERS>PEN</WAERS><NO_MOD/><SALDO_FINAL>0.0</SALDO_FINAL><FECHA_VENCIMIENTO>2021-07-31</FECHA_VENCIMIENTO><PORCENTAJE>000</PORCENTAJE><MLSTN/><BUKRS/><BELNR/><GJAHR>0000</GJAHR></item></ET_CUOTAS_PROFORMA_SF><ET_RETURN><item><TYPE_x>E</TYPE_x><ID>ZAC_OTC</ID><NUMBER>022</NUMBER><MESSAGE>Se creó la Operación Segura 43893</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>43893</MESSAGE_V1><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_CAB_PROFORMA_SF><PROFORMA>0000043893</PROFORMA><VERSION>01</VERSION><PROFORMA_ANT>0000000001</PROFORMA_ANT><PROCESSO>19U1.120E</PROCESSO><COD_PROPIEDAD>00000073</COD_PROPIEDAD><COD_MINUTA>A073</COD_MINUTA><PROPIEDADES>73/</PROPIEDADES><BUKRS>0019</BUKRS><TIPO_PROFORMA>1</TIPO_PROFORMA><VBELN/><POSID>19U1120EI51VL0073</POSID><POSNR>00107610</POSNR><WAERS>PEN</WAERS><PRECIO>20000.0</PRECIO><KUNNR>0080305321</KUNNR><TIP_CLI_CONT>B</TIP_CLI_CONT><CUOTA_MINIMA>6000.0</CUOTA_MINIMA><CUOTA_INIC_IMP>6000.0</CUOTA_INIC_IMP><CUOTA_INIC_POR>0.0</CUOTA_INIC_POR><CUOTA_INIC_NO_CUOTAS>6</CUOTA_INIC_NO_CUOTAS><CUOTA_INIC_MIN>0.0</CUOTA_INIC_MIN><CUOTA_INIC_MAX>0.0</CUOTA_INIC_MAX><CUOTA_INIC_INTERES>0.0</CUOTA_INIC_INTERES><CUOTA_INIC_INTGAS>0.0</CUOTA_INIC_INTGAS><CUOTA_INIC_NO_CUOTAS_MIN>0</CUOTA_INIC_NO_CUOTAS_MIN><CUOTA_INIC_NO_CUOTAS_MAX>0</CUOTA_INIC_NO_CUOTAS_MAX><SALDO_NO_CUOTAS>12</SALDO_NO_CUOTAS><SALDO_NO_CUOTAS_MAX>0</SALDO_NO_CUOTAS_MAX><SALDO_INTERESES>0.0</SALDO_INTERESES><SALDO_INTGAS>0.0</SALDO_INTGAS><CUOTA_INIC_IMP_R>6000.0</CUOTA_INIC_IMP_R><PROMOTOR/><FECHA_INICIO>2021-06-09</FECHA_INICIO><VIA_FINANCIAMIENTO>CD</VIA_FINANCIAMIENTO><CASH>0.0</CASH><CASH_BLDAT>0000-00-00</CASH_BLDAT><CHECK_ENTREGA/><TELEMARKETING/><FIRMA_MECANIZ/><STATUS_INICIAL>01</STATUS_INICIAL><BFH>0.0</BFH><FECHA_ENT_PROY>0000-00-00</FECHA_ENT_PROY><IND_FINAN_CI>X</IND_FINAN_CI><FACILOTE_IND_CI/><COTIZACION_PROFORMA>O</COTIZACION_PROFORMA><DIAS_PAGO>1</DIAS_PAGO><INTERESES_CI>SI</INTERESES_CI><IMPORTE_RESERVA>0.0</IMPORTE_RESERVA><ZZZONAVENTA>ZV022</ZZZONAVENTA><MEDIO>0132</MEDIO><CANAL/><ETI_CLI_CONTA/><ETI_MEDIO/><ETI_ZONA/><ETI_PROMOTOR/><ETI_APO1/><ETI_APO2/><IMPORTE_SALDO_PRECIO>0.0</IMPORTE_SALDO_PRECIO><TASA_MANUAL_IND/><TASA_ANUAL_INTERES_FINAN>23.5</TASA_ANUAL_INTERES_FINAN><TASA_ANUAL_GASTOS_ADMIN>0.0</TASA_ANUAL_GASTOS_ADMIN><TASA_MENSUAL_INTERES_FINAN>0.0</TASA_MENSUAL_INTERES_FINAN><TASA_MENSUAL_GASTOS_ADMIN>0.0</TASA_MENSUAL_GASTOS_ADMIN><COSTO_TOTAL_MENSUAL>0.0</COSTO_TOTAL_MENSUAL><COSTO_TOTAL_ANUAL>0.0</COSTO_TOTAL_ANUAL><PERFIL_COBRAN>A01</PERFIL_COBRAN><PERIODO_DIAS>0</PERIODO_DIAS><IMPORTE_CUOTA>0.0</IMPORTE_CUOTA><CANTIDAD_LOTES>0001</CANTIDAD_LOTES><AREA_VENDIBLE>100.0</AREA_VENDIBLE><APODERADO_CENTENARIO1/><APODERADO_CENTENARIO2/><DIAS_ADICIONALES>3</DIAS_ADICIONALES><PRECIO_ORIGINAL>20000.0</PRECIO_ORIGINAL><TIPO_CAMBIO>0.0</TIPO_CAMBIO><INTERLOCUTOR1/><INTERLOCUTOR2/><INTERLOCUTOR3/><INTERLOCUTOR4/><INTERLOCUTOR5/><INTERLOCUTOR6/><INTERLOCUTOR7/><INTERLOCUTOR8/><INTERLOCUTOR9/><INTERLOCUTOR10/><APODERADO1/><APODERADO2/><MOTIVO_COMPRA>I</MOTIVO_COMPRA><IMPORTE_CI_CHAR>6000.00</IMPORTE_CI_CHAR><IND_PORCENTAJE/><ENTREGA/><FECHA_ENTREGA>0000-00-00</FECHA_ENTREGA><CONVERSION_ARRAS>NO</CONVERSION_ARRAS></E_CAB_PROFORMA_SF><E_OPERACION_SEGURA>0000043893</E_OPERACION_SEGURA></n0:ZRFC_OTC_FINANCIAMIENTO_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_OperactionSafe_Test.respType.equals('warning'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><soap-env:Fault><faultcode>soap-env:Server</faultcode><faultstring xml:lang="en">Error en el tratamiento de servicio web; Más detalles en log de error de servicio web en la página de proveedor (Cronomarcador UTC 20210528183635; ID de transacción A0E3BFEBDDFAF1D280E600505698382C)</faultstring><detail/></soap-env:Fault></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
    
            return res;
        }
    }
    
}