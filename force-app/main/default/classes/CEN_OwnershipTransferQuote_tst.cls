/**
 * @description       : Clase test de CEN_OwnershipTransferQuote_ctr
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             :
 * @last modified on  : 06-13-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_OwnershipTransferQuote_tst {
    @TestSetup
    static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        insert projs;

        //---- PRODUCT2
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        //insert prod2s ;

        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 2);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        insert opps;

        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
           //PricebookEntryId = pbEntry.Id,
        oppItem.TotalPrice = 1000;
        insert oppItem;
        // SELECT Product2Id FROM OpportunityLineItem WHERE Product2.CODESTADOLOTE__c = 'L' AND OpportunityId=:oppData.Id
        //---- PaymentOrder
        List<CEN_PaymentOrder__c> paymentOrderList = new List<CEN_PaymentOrder__c>();
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder);

        CEN_PaymentOrder__c oPaymentOrder1 = new CEN_PaymentOrder__c();
        oPaymentOrder1.CEN_FirstName__c = 'test_FirstName1';
        oPaymentOrder1.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder1.CEN_Opportunity__c = opps[1].Id;
        oPaymentOrder1.CEN_Amount__c = 5000;
        oPaymentOrder1.CEN_PaymentStatus__c = 'Pendiente';
        oPaymentOrder1.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder1);
        insert paymentOrderList;

        Quote cotizacion = new Quote();
        cotizacion.Name='Coti';
        cotizacion.OpportunityId=opps[0].Id;
        cotizacion.Pricebook2Id = Test.getStandardPricebookId();
        insert cotizacion;
    }
    @IsTest static void CEN_OwnershipTransfer_ctrSucess_test(){
        Test.startTest();
        Opportunity opp = [Select id,stagename,CEN_Onbase_documento_id_arras__c,CEN_Onbase_documento_id__c FROM Opportunity LIMIT 1];
        Quote coti = [Select id FROM Quote where OpportunityId =: opp.id LIMIT 1]; // Opp
        update opp;
        update coti;
        List<Opportunity> opps = new List<Opportunity>{opp};
        List<String> quoteList = new List<String>();
        List<String> oppList = new List<String>();
        oppList.add(opp.Id);
        quoteList.add(coti.Id);
        List<CEN_OwnershipTransferQuote_ctr.FlowParameters> parameterList = new List<CEN_OwnershipTransferQuote_ctr.FlowParameters>();
        CEN_OwnershipTransferQuote_ctr.FlowParameters parameter = new CEN_OwnershipTransferQuote_ctr.FlowParameters();
        parameter.opQuote = quoteList;
        parameter.opIdsNew = oppList;
        parameterList.add(parameter);

        //CEN_CloseOppsDropPaymentsAction_tst.respType = 'ok';
        CEN_OwnershipTransferQuote_ctr.GeneratePDF(parameterList);
        Test.stopTest();
    }

    //
    @isTest static void CEN_OwnershipTransferQuotePDF_ControllerCD(){
        //CEN_cls_VisorLotes.DatosPersonaWrapper objPersona = null;

            Tabla_maestra__c distrito = new Tabla_maestra__c();
            distrito.Name='Lima';
            distrito.Departamento__c='Lima';
            distrito.Provincia__c='Lima';
            distrito.CEN_Codigo_departamento__c='15';
            distrito.CEN_Codigo_provincia__c='1501';
            distrito.CEN_Codigo_distrito__c='150105';
            insert distrito;

            Account cuenta = new Account();
            cuenta.CEN_Numero_de_documento_del__c ='10100010002';
            cuenta.Name='Maximule SAC';
            cuenta.Phone='6543245';
            cuenta.CEN_Direcci_n__c='av siempre viva';
            cuenta.CEN_Estado__c='Cuenta Potencial';
            cuenta.RecordTypeId='0124T0000000qqbQAA';
            cuenta.CEN_Distrito__c =distrito.Id;
            insert cuenta;

            //objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);

            Proyecto__c proyecto= new Proyecto__c();
            proyecto.Name='Proyecto 1';
            proyecto.CEN_CODIGOSAP__c='10U1.011E';
            proyecto.CEN_Etapa__c='Etapa 1';
            insert proyecto;

        	Opportunity oportunidad=new Opportunity();
            oportunidad.AccountId=cuenta.Id;
            oportunidad.StageName='Operación';
            oportunidad.CEN_Sub_Estado__c='Segura';
            oportunidad.Name='Opo 1';
            oportunidad.CloseDate=Date.today();
            oportunidad.CEN_Tipo_de_venta__c = 'CD';
        	oportunidad.CEN_Proyecto__c = proyecto.id;
        	oportunidad.CEN_Monto_Cuota_del_Saldo_de_precio__c = 2882.41;
            oportunidad.CEN_Monto_cuota_de_inicial_de_precio__c = 3750;
            oportunidad.CEN_N_Cuotas_de_inicial_de_precio__c = 13;
            oportunidad.CEN_N_Cuotas_del_Saldo_del_precio__c = 60;
            insert oportunidad;

            Product2 lote = new Product2();
            lote.Name='Lote prueba1';
            lote.CEN_Proyecto__c=proyecto.Id;
            lote.CODLOTE__c='123123123';
            lote.CODCOMPANIA__c='0010';
            lote.CEN_Tiene_Reserva__c='No';
            lote.CODESTADOLOTE__c='L';
            lote.CEN_PRECIOVENTAFUN__c='10000';
            lote.IsActive=true;
            lote.MANZANA__c = 'Mz. A1';
            lote.AREA__c = '100';
            lote.CEN_TIPOLOGIA__c= 'ESQUINA';
            insert lote;

            PricebookEntry precio2= new PricebookEntry();
            precio2.UseStandardPrice=false;
            precio2.IsActive=true;
            precio2.Pricebook2Id=Test.getStandardPricebookId();
            precio2.Product2Id=lote.Id;
            precio2.UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            insert precio2;

            Proyecto__c proyecto2 = CEN_cls_VisorLote_2.buscarProyectobyId(proyecto.Id);
            System.assertEquals(proyecto.id, proyecto2.Id);
            Id[]searchResultsIds=new Id[]{proyecto.Id};
            Test.setFixedSearchResults(searchResultsIds);
            Test.startTest();
            Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);

            List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);

            System.assertEquals(1, proyectos_encontrados.size());
            System.assertEquals(proyecto.id, proyectos_encontrados[0].Id);
            //System.assertNotEquals(null, objPersona);

            CEN_cls_VisorLote_2.ListWrapper wraper = CEN_cls_VisorLote_2.fetchAccountWrapper(proyecto.CEN_CODIGOSAP__c);
            System.assertEquals('ok', wraper.estado);
            //System.assertEquals(1, wraper.getlotes.size());
            System.assertEquals('todo ok', wraper.mensaje);
            System.assertEquals(108440.0, wraper.precioMax);
            //System.assertEquals(108430.0, wraper.precioMin);
            System.assertEquals(150.0, wraper.tamanioMax);
            System.assertEquals(140.0, wraper.tamanioMin);

            Quote cotizacion = new Quote();
            cotizacion.Name='Coti';
            cotizacion.OpportunityId=oportunidad.Id;
            cotizacion.Pricebook2Id = Test.getStandardPricebookId();
            insert cotizacion;

            QuoteLineItem objQuoteLineItem = new QuoteLineItem();
            objQuoteLineItem.Product2Id = lote.Id;
            objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
            objQuoteLineItem.PricebookEntryId = precio2.Id;
            objQuoteLineItem.Quantity = 1;
            objQuoteLineItem.UnitPrice = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.QuoteId = cotizacion.Id;
            objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
            objQuoteLineItem.CEN_lote__c = lote.DESCRIPCIONCORTA__c;
            objQuoteLineItem.CEN_manzana_del_lote__c = lote.MANZANA__c.capitalize();
            objQuoteLineItem.CEN_precio_m2_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c)/objQuoteLineItem.CEN_area_del_lote__c;
            objQuoteLineItem.CEN_precio_venta_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.CEN_fld_precioVentaDscto__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.CEN_tipologia_del_lote__c = lote.CEN_TIPOLOGIA__c;
            objQuoteLineItem.CEN_urbanizacion_proyecto__c = proyecto.Name;
            objQuoteLineItem.CEN_etapa__c = proyecto.CEN_Etapa__c;
            insert objQuoteLineItem;

            PageReference pageref = Page.CEN_OwnershipTransferQuotePDF_vf;
            pageref.getParameters().put('id',cotizacion.Id);

            Test.setCurrentPage(pageref);

            ApexPages.StandardController scontr = new ApexPages.StandardController(cotizacion);
            //  Controlador de visualforce
            CEN_OwnershipTransferQuotePDF_ctr controller = new CEN_OwnershipTransferQuotePDF_ctr(scontr);
            Attachment objAttachment = controller.getLogoProyecto();
            Proyecto__c objProyecto = controller.getProyecto();
            Account objCliente = controller.getCliente();
            String telefono = controller.getTelefono();
            String documento = controller.getDocumento();
            String tipoDocumento = controller.getTipoDocumento();
            Quote objQuote = controller.getCotizacion();
            List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
            List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
            List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
            List<CEN_OwnershipTransferQuotePDF_ctr.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
            Opportunity oportunidads = controller.getOportunidads();
            Opportunity oportunidadsd = controller.getOportunidadsd();
            String montoFinanciar = controller.getMontoFinanciar();
            String numCuotas = controller.getNumCuotas();
            String montoCuotas = controller.getMontoCuotas();
            Integer diaMaxPago = controller.getDiaMaxPago();
            Integer diaMaxFirma = controller.getDiaMaxFirma();
            String fechaCierre = controller.getFechaCierre();
            String writeToday = controller.getWriteToday();
            String writeTodayB = controller.getWriteTodayB();
            Decimal initial = controller.getinicial();
            Decimal inicialPorcentage = controller.getinicialPorcentage();
            Double numeroCuotaInicial = controller.getNumeroCuotaInicial();
            Decimal montoCuotaInicial = controller.getMontoCuotaInicial();
            Decimal montoFraccionar = controller.getMontoFraccionar();
            Double numeroCuota = controller.getNumeroCuota();
            Decimal tasaInteresCompensatorio = controller.getTasaInteresCompensatorio();
            Decimal montoCuota = controller.getMontoCuota();
            Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];
            String urlPageVF = pageref.getUrl();
            CEN_OwnershipTransferQuote_ctr.generarPDF(cotizacion.id, Oportunidad.id);
            Test.stopTest();
    }

        @isTest static void CEN_OwnershipTransferQuotePDF_ControllerCO(){
        Tabla_maestra__c distrito = new Tabla_maestra__c();
            distrito.Name='Lima';
            distrito.Departamento__c='Lima';
            distrito.Provincia__c='Lima';
            distrito.CEN_Codigo_departamento__c='15';
            distrito.CEN_Codigo_provincia__c='1501';
            distrito.CEN_Codigo_distrito__c='150105';
            insert distrito;

            Account cuenta = new Account();
            cuenta.CEN_Numero_de_documento_del__c ='10100010002';
            cuenta.Name='Maximule SAC';
            cuenta.Phone='6543245';
            cuenta.CEN_Direcci_n__c='av siempre viva';
            cuenta.CEN_Estado__c='Cuenta Potencial';
            cuenta.RecordTypeId='0124T0000000qqbQAA';
            cuenta.CEN_Distrito__c =distrito.Id;
            insert cuenta;

            //objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);

            Proyecto__c proyecto= new Proyecto__c();
            proyecto.Name='Proyecto 1';
            proyecto.CEN_CODIGOSAP__c='10U1.011E';
            proyecto.CEN_Etapa__c='Etapa 1';
            insert proyecto;

        	Opportunity oportunidad=new Opportunity();
            oportunidad.AccountId=cuenta.Id;
            oportunidad.StageName='Operación';
            oportunidad.CEN_Sub_Estado__c='Segura';
            oportunidad.Name='Opo 1';
            oportunidad.CloseDate=Date.today();
            oportunidad.CEN_Tipo_de_venta__c = 'CO';
        	oportunidad.CEN_Proyecto__c = proyecto.id;
            oportunidad.CEN_Monto_Cuota_del_Saldo_de_precio__c = 0;
            oportunidad.CEN_Monto_cuota_de_inicial_de_precio__c = 150000;
            oportunidad.CEN_N_Cuotas_de_inicial_de_precio__c = 1;
            oportunidad.CEN_N_Cuotas_del_Saldo_del_precio__c = 0;
            insert oportunidad;

            Product2 lote = new Product2();
            lote.Name='Lote prueba1';
            lote.CEN_Proyecto__c=proyecto.Id;
            lote.CODLOTE__c='123123123';
            lote.CODCOMPANIA__c='0010';
            lote.CEN_Tiene_Reserva__c='No';
            lote.CODESTADOLOTE__c='L';
            lote.CEN_PRECIOVENTAFUN__c='10000';
            lote.IsActive=true;
            lote.MANZANA__c = 'Mz. A1';
            lote.AREA__c = '100';
            lote.CEN_TIPOLOGIA__c= 'ESQUINA';
            insert lote;

            PricebookEntry precio2= new PricebookEntry();
            precio2.UseStandardPrice=false;
            precio2.IsActive=true;
            precio2.Pricebook2Id=Test.getStandardPricebookId();
            precio2.Product2Id=lote.Id;
            precio2.UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            insert precio2;

            Proyecto__c proyecto2 = CEN_cls_VisorLote_2.buscarProyectobyId(proyecto.Id);
            System.assertEquals(proyecto.id, proyecto2.Id);
            Id[]searchResultsIds=new Id[]{proyecto.Id};
            Test.setFixedSearchResults(searchResultsIds);
            Test.startTest();
            Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);

            List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);

            System.assertEquals(1, proyectos_encontrados.size());
            System.assertEquals(proyecto.id, proyectos_encontrados[0].Id);
            //System.assertNotEquals(null, objPersona);

            CEN_cls_VisorLote_2.ListWrapper wraper = CEN_cls_VisorLote_2.fetchAccountWrapper(proyecto.CEN_CODIGOSAP__c);
            System.assertEquals('ok', wraper.estado);
            //System.assertEquals(1, wraper.getlotes.size());
            System.assertEquals('todo ok', wraper.mensaje);
            System.assertEquals(108440.0, wraper.precioMax);
            //System.assertEquals(108430.0, wraper.precioMin);
            System.assertEquals(150.0, wraper.tamanioMax);
            System.assertEquals(140.0, wraper.tamanioMin);

            Quote cotizacion = new Quote();
            cotizacion.Name='Coti';
            cotizacion.OpportunityId=oportunidad.Id;
            cotizacion.Pricebook2Id = Test.getStandardPricebookId();
            insert cotizacion;

            QuoteLineItem objQuoteLineItem = new QuoteLineItem();
            objQuoteLineItem.Product2Id = lote.Id;
            objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
            objQuoteLineItem.PricebookEntryId = precio2.Id;
            objQuoteLineItem.Quantity = 1;
            objQuoteLineItem.UnitPrice = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.QuoteId = cotizacion.Id;
            objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
            objQuoteLineItem.CEN_lote__c = lote.DESCRIPCIONCORTA__c;
            objQuoteLineItem.CEN_manzana_del_lote__c = lote.MANZANA__c.capitalize();
            objQuoteLineItem.CEN_precio_m2_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c)/objQuoteLineItem.CEN_area_del_lote__c;
            objQuoteLineItem.CEN_precio_venta_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.CEN_fld_precioVentaDscto__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
            objQuoteLineItem.CEN_tipologia_del_lote__c = lote.CEN_TIPOLOGIA__c;
            objQuoteLineItem.CEN_urbanizacion_proyecto__c = proyecto.Name;
            objQuoteLineItem.CEN_etapa__c = proyecto.CEN_Etapa__c;
            insert objQuoteLineItem;

            PageReference pageref = Page.CEN_OwnershipTransferQuotePDF_vf;
            pageref.getParameters().put('id',cotizacion.Id);

            Test.setCurrentPage(pageref);

            ApexPages.StandardController scontr = new ApexPages.StandardController(cotizacion);
            //  Controlador de visualforce
            CEN_OwnershipTransferQuotePDF_ctr controller = new CEN_OwnershipTransferQuotePDF_ctr(scontr);
            Attachment objAttachment = controller.getLogoProyecto();
            Proyecto__c objProyecto = controller.getProyecto();
            Account objCliente = controller.getCliente();
            String telefono = controller.getTelefono();
            String documento = controller.getDocumento();
            String tipoDocumento = controller.getTipoDocumento();
            Quote objQuote = controller.getCotizacion();
            List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
            List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
            List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
            List<CEN_OwnershipTransferQuotePDF_ctr.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
            Opportunity oportunidads = controller.getOportunidads();
            Opportunity oportunidadsd = controller.getOportunidadsd();
            String montoFinanciar = controller.getMontoFinanciar();
            String numCuotas = controller.getNumCuotas();
            String montoCuotas = controller.getMontoCuotas();
            Integer diaMaxPago = controller.getDiaMaxPago();
            Integer diaMaxFirma = controller.getDiaMaxFirma();
            String fechaCierre = controller.getFechaCierre();
            String writeToday = controller.getWriteToday();
            String writeTodayB = controller.getWriteTodayB();
            Decimal initial = controller.getinicial();
            Decimal inicialPorcentage = controller.getinicialPorcentage();
            Double numeroCuotaInicial = controller.getNumeroCuotaInicial();
            Decimal montoCuotaInicial = controller.getMontoCuotaInicial();
            Decimal montoFraccionar = controller.getMontoFraccionar();
            Double numeroCuota = controller.getNumeroCuota();
            Decimal tasaInteresCompensatorio = controller.getTasaInteresCompensatorio();
            Decimal montoCuota = controller.getMontoCuota();
            Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];
            String urlPageVF = pageref.getUrl();
            CEN_OwnershipTransferQuote_ctr.generarPDF(cotizacion.id, Oportunidad.id);
            Test.stopTest();
    }
}