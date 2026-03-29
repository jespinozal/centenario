/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 30-06-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2021   @everis.com   Initial Version
 **/
@isTest
public with sharing class CEN_InformativePayments_test {
    
    @TestSetup
	static void SetUp(){

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

        Opportunity oportunidad=new Opportunity();
        oportunidad.AccountId=cuenta.Id;
        oportunidad.StageName='Operación';
        oportunidad.CEN_Sub_Estado__c='Segura';
        oportunidad.Name='Opo 1';
        oportunidad.CloseDate=Date.today();
        oportunidad.CEN_Tipo_de_venta__c = 'CO';        
        oportunidad.CEN_Monto_Cuota_del_Saldo_de_precio__c = 0;
        oportunidad.CEN_Monto_cuota_de_inicial_de_precio__c = 150000;
        oportunidad.CEN_N_Cuotas_de_inicial_de_precio__c = 1;
        oportunidad.CEN_N_Cuotas_del_Saldo_del_precio__c = 0;
        //oportunidad.CEN_AmountFeeFacilitate__c = 200;

        //objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);

        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U1.011E';
        proyecto.CEN_Etapa__c='Etapa 1';
        insert proyecto;
        oportunidad.CEN_Proyecto__c = proyecto.id;
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
        
        //Proyecto__c proyecto2 = CEN_cls_VisorLote_2.buscarProyectobyId(proyecto.Id);
        //System.assertEquals(proyecto.id, proyecto2.Id);
        //Id[]searchResultsIds=new Id[]{proyecto.Id};
        //Test.setFixedSearchResults(searchResultsIds);
        //Test.startTest();
        //Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);

        //List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);

        //CEN_cls_VisorLote_2.ListWrapper wraper = CEN_cls_VisorLote_2.fetchAccountWrapper(proyecto.CEN_CODIGOSAP__c);
        
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
        
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
         pyOrder.CEN_Amount__c = 1000;
         pyOrder.CEN_CurrencyCode__c = 'PEN';
         pyOrder.CEN_PaymentDescription__c = 'Test payment';
         //pyOrder.Name = 'PO00001';
         pyOrder.CEN_PaymentStatus__c = 'PendienteSAP';
         pyOrder.CEN_ID_Culqi__c = 'ord_test_nLJsG4ZLYmjxGewm';
         //pyOrder.CEN_Opportunity__c = opps[0].Id;
         pyOrder.CEN_Opportunity__c = oportunidad.Id;
         Date currentDay = system.today();
         pyOrder.CEN_DueDate__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
         pyOrder.CEN_PaymentDate__c = Datetime.now();
         insert pyOrder; 
    }

    @IsTest static void informativeParcialPayment_testCD(){

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId, CEN_Opportunity__c FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        Opportunity oportunidad = new Opportunity();
        oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        oportunidad.CEN_Tipo_de_venta__c = 'CD';
        update oportunidad;
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        String paymentIds = paymentData.Id;
        // List<CEN_InformativeParcialPayment_ctr.FlowParameters> parameterList = new List<CEN_InformativeParcialPayment_ctr.FlowParameters>();
        // CEN_InformativeParcialPayment_ctr.FlowParameters parameter = new CEN_InformativeParcialPayment_ctr.FlowParameters();
        //parameter.opIds = new List<String>{paymentIds};
        //parameterList.add(parameter);
        Test.startTest();
        CEN_InformativeParcialPayment_ctr.generarPDF(paymentIds);
        //List<String> response = CEN_InformativeParcialPayment_ctr.processInformativeParcialPayment(parameterList);
        //system.debug('response: '+ resp);

        PageReference pageref = Page.CEN_vf_pdfInformativeParcialPayment;
        pageref.getParameters().put('id',paymentData.CEN_Opportunity__c);

        Test.setCurrentPage(pageref);
        ApexPages.StandardController scontr = new ApexPages.StandardController(oportunidad);
        //  Controlador de visualforce
        CEN_cls_pdfInformativeParcialPayment_vf controller = new CEN_cls_pdfInformativeParcialPayment_vf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_PaymentOrder__c> payments = controller.getPayments();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        Opportunity oportunidads = controller.getOportunidads();
        Opportunity oportunidadsd = controller.getOportunidadsd();
        Decimal cuotaFacilote = controller.getCuotaFacilote();
        Decimal montoPagarContrato = controller.getMontoPagarContrato();
        String montoFinanciar = controller.getMontoFinanciar();
        String numCuotas = controller.getNumCuotas();
        String montoCuotas = controller.getMontoCuotas();
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
        
        Test.stopTest();
    }
    
    @IsTest static void informativeTotalPayment_testCD(){

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId, CEN_Opportunity__c FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        Opportunity oportunidad = new Opportunity();
        oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        oportunidad.CEN_Tipo_de_venta__c = 'CD';
        update oportunidad;
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        //String paymentIds = paymentData.Id;
        // List<CEN_InformativeTotalPayment_ctr.FlowParameters> parameterList = new List<CEN_InformativeTotalPayment_ctr.FlowParameters>();
        // CEN_InformativeTotalPayment_ctr.FlowParameters parameter = new CEN_InformativeTotalPayment_ctr.FlowParameters();
        // parameter.oppIds = new List<String>{oportunidad.Id};
        // parameterList.add(parameter);
        Test.startTest();
        CEN_InformativeTotalPayment_ctr.generarPDF(oportunidad.Id);
        //List<String> response = CEN_InformativeTotalPayment_ctr.processInformativeTotalPayment(parameterList);
        //system.debug('response: '+ resp);

        PageReference pageref = Page.CEN_vf_pdfInformativeTotalPayment;
        pageref.getParameters().put('id',oportunidad.Id);

        Test.setCurrentPage(pageref);
        ApexPages.StandardController scontr = new ApexPages.StandardController(oportunidad);
        //  Controlador de visualforce
        CEN_cls_pdfInformativeTotalPayment_vf controller = new CEN_cls_pdfInformativeTotalPayment_vf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_PaymentOrder__c> payments = controller.getPayments();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        Opportunity oportunidads = controller.getOportunidads();
        Opportunity oportunidadsd = controller.getOportunidadsd();
        Decimal cuotaFacilote = controller.getCuotaFacilote();
        Decimal montoPagarContrato = controller.getMontoPagarContrato();
        String montoFinanciar = controller.getMontoFinanciar();
        String numCuotas = controller.getNumCuotas();
        String montoCuotas = controller.getMontoCuotas();
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
        
        Test.stopTest();
    }
    
    @IsTest static void informativeParcialPayment_testCO(){

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId, CEN_Opportunity__c FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        Opportunity oportunidad = new Opportunity();
        oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        String paymentIds = paymentData.Id;
        // List<CEN_InformativeParcialPayment_ctr.FlowParameters> parameterList = new List<CEN_InformativeParcialPayment_ctr.FlowParameters>();
        // CEN_InformativeParcialPayment_ctr.FlowParameters parameter = new CEN_InformativeParcialPayment_ctr.FlowParameters();
        // parameter.opIds = new List<String>{paymentIds};
        // parameterList.add(parameter);
        Test.startTest();
        CEN_InformativeParcialPayment_ctr.generarPDF(paymentIds);
        //List<String> response = CEN_InformativeParcialPayment_ctr.processInformativeParcialPayment(parameterList);
        //system.debug('response: '+ resp);

        PageReference pageref = Page.CEN_vf_pdfInformativeParcialPayment;
        pageref.getParameters().put('id',paymentData.CEN_Opportunity__c);

        Test.setCurrentPage(pageref);
        ApexPages.StandardController scontr = new ApexPages.StandardController(oportunidad);
        //  Controlador de visualforce
        CEN_cls_pdfInformativeParcialPayment_vf controller = new CEN_cls_pdfInformativeParcialPayment_vf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_PaymentOrder__c> payments = controller.getPayments();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        Opportunity oportunidads = controller.getOportunidads();
        Opportunity oportunidadsd = controller.getOportunidadsd();
        Decimal cuotaFacilote = controller.getCuotaFacilote();
        Decimal montoPagarContrato = controller.getMontoPagarContrato();
        String montoFinanciar = controller.getMontoFinanciar();
        String numCuotas = controller.getNumCuotas();
        String montoCuotas = controller.getMontoCuotas();
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
        
        Test.stopTest();
    }
    
    @IsTest static void informativeTotalPayment_testCO(){

        CEN_PaymentOrder__c paymentData = [SELECT Id, recordTypeId, CEN_Opportunity__c FROM CEN_PaymentOrder__c LIMIT 1]; // Opp
        Opportunity oportunidad = new Opportunity();
        oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        paymentData.recordTypeId = Schema.SObjectType.CEN_PaymentOrder__c.getRecordTypeInfosByDeveloperName().get('CEN_CashPayment').getRecordTypeId();
        update paymentData;
        //String paymentIds = paymentData.Id;
        // List<CEN_InformativeTotalPayment_ctr.FlowParameters> parameterList = new List<CEN_InformativeTotalPayment_ctr.FlowParameters>();
        // CEN_InformativeTotalPayment_ctr.FlowParameters parameter = new CEN_InformativeTotalPayment_ctr.FlowParameters();
        // parameter.oppIds = new List<String>{oportunidad.Id};
        // parameterList.add(parameter);
        Test.startTest();
        CEN_InformativeTotalPayment_ctr.generarPDF(oportunidad.Id);
        //List<String> response = CEN_InformativeTotalPayment_ctr.processInformativeTotalPayment(parameterList);
        //system.debug('response: '+ resp);

        PageReference pageref = Page.CEN_vf_pdfInformativeTotalPayment;
        pageref.getParameters().put('id',oportunidad.Id);

        Test.setCurrentPage(pageref);
        ApexPages.StandardController scontr = new ApexPages.StandardController(oportunidad);
        //  Controlador de visualforce
        CEN_cls_pdfInformativeTotalPayment_vf controller = new CEN_cls_pdfInformativeTotalPayment_vf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_PaymentOrder__c> payments = controller.getPayments();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        Opportunity oportunidads = controller.getOportunidads();
        Opportunity oportunidadsd = controller.getOportunidadsd();
        Decimal cuotaFacilote = controller.getCuotaFacilote();
        Decimal montoPagarContrato = controller.getMontoPagarContrato();
        String montoFinanciar = controller.getMontoFinanciar();
        String numCuotas = controller.getNumCuotas();
        String montoCuotas = controller.getMontoCuotas();
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
        
        Test.stopTest();
    }
    
}