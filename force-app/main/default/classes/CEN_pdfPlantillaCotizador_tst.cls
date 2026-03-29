@isTest
public class CEN_pdfPlantillaCotizador_tst {
    @TestSetup static void dataCotizador(){
        CEN_cls_VisorLotes.DatosPersonaWrapper objPersona = null;

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
        oportunidad.CEN_Monto_Cuota_del_Saldo_de_precio__c = 2882.41;
        oportunidad.CEN_Monto_cuota_de_inicial_de_precio__c = 3750;
        oportunidad.CEN_N_Cuotas_de_inicial_de_precio__c = 13;
        oportunidad.CEN_N_Cuotas_del_Saldo_del_precio__c = 60;  
        oportunidad.CEN_Proyecto__c = proyecto.Id;
        insert oportunidad;

        objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);
        
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
        //Test.startTest();
        Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);

        List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);
        
        
        System.assertEquals(1, proyectos_encontrados.size());
        System.assertEquals(proyecto.id, proyectos_encontrados[0].Id);
        System.assertNotEquals(null, objPersona);
        
        CEN_cls_VisorLote_2.ListWrapper wraper = CEN_cls_VisorLote_2.fetchAccountWrapper(proyecto.CEN_CODIGOSAP__c);
        Quote cotizacion = new Quote();
        cotizacion.Name='Coti';
        cotizacion.OpportunityId=oportunidad.Id;
        cotizacion.Pricebook2Id = Test.getStandardPricebookId();      
        cotizacion.CEN_Monto_cuota_de_inicial_de_precio__c = 100;
        cotizacion.CEN_TypeOfSale__c = 'CD';
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
        System.assertEquals('ok', wraper.estado);
        //System.assertEquals(1, wraper.getlotes.size());
        System.assertEquals('todo ok', wraper.mensaje);
        System.assertEquals(108440.0, wraper.precioMax);
        //System.assertEquals(108430.0, wraper.precioMin);
        System.assertEquals(150.0, wraper.tamanioMax);
        System.assertEquals(140.0, wraper.tamanioMin);
        
        
    }
    @isTest static void CEN_cls_CotizacionControllerCD(){
        Opportunity opp = [Select id from Opportunity limit 1];
        Quote coti = [Select id from Quote limit 1];
		Test.startTest();        
        ApexPages.StandardController scontr = new ApexPages.StandardController(coti);
        //  Controlador de visualforce
        CEN_cls_pdfPlantillaCotizador_ccvf controller = new CEN_cls_pdfPlantillaCotizador_ccvf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> listAnotaciones = controller.getAnotaciones();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
        List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
        List<CEN_cls_pdfPlantillaCotizador_ccvf.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
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
        //Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];                
        //String urlPageVF = pageref.getUrl();

        CEN_cls_VisorLotes.generarPDF(coti.Id, opp.Id);
        Test.stopTest();            
    }
    
    @isTest static void CEN_cls_CotizacionControllerCO(){       
        Opportunity opp = [Select id from Opportunity limit 1];
        Quote coti = [Select id from Quote limit 1];
        coti.CEN_TypeOfSale__c = 'CO';
        update coti;
        opp.CEN_Tipo_de_venta__c = 'CO';
        opp.CEN_Monto_Cuota_del_Saldo_de_precio__c = 0;
        opp.CEN_Monto_cuota_de_inicial_de_precio__c = 150000;
        opp.CEN_N_Cuotas_de_inicial_de_precio__c = 1;
        opp.CEN_N_Cuotas_del_Saldo_del_precio__c = 0;     
        update opp;
		Test.startTest();        
        ApexPages.StandardController scontr = new ApexPages.StandardController(coti);
        //  Controlador de visualforce
        CEN_cls_pdfPlantillaCotizador_ccvf controller = new CEN_cls_pdfPlantillaCotizador_ccvf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> listAnotaciones = controller.getAnotaciones();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
        List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
        List<CEN_cls_pdfPlantillaCotizador_ccvf.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
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
        //Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];                
        //String urlPageVF = pageref.getUrl();

        CEN_cls_VisorLotes.generarPDF(coti.Id, opp.Id);
        Test.stopTest();       
    }
    
    @isTest static void CEN_cls_CotizacionControllerCS(){       
        Opportunity opp = [Select id from Opportunity limit 1];
        Quote coti = [Select id from Quote limit 1];
        coti.CEN_TypeOfSale__c = 'CS';
        update coti;
        opp.CEN_Tipo_de_venta__c = 'CS';
        opp.CEN_Monto_Cuota_del_Saldo_de_precio__c = 6250;
        opp.CEN_Monto_cuota_de_inicial_de_precio__c = 150000;
        opp.CEN_N_Cuotas_de_inicial_de_precio__c = 1;
        opp.CEN_N_Cuotas_del_Saldo_del_precio__c = 23;     
        update opp;
		Test.startTest();        
        ApexPages.StandardController scontr = new ApexPages.StandardController(coti);
        //  Controlador de visualforce
        CEN_cls_pdfPlantillaCotizador_ccvf controller = new CEN_cls_pdfPlantillaCotizador_ccvf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Account objCliente = controller.getCliente();
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        Quote objQuote = controller.getCotizacion();
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> listAnotaciones = controller.getAnotaciones();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
        List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
        List<CEN_cls_pdfPlantillaCotizador_ccvf.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
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
        //Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];                
        //String urlPageVF = pageref.getUrl();

        CEN_cls_VisorLotes.generarPDF(coti.Id, opp.Id);
        Test.stopTest();       
    }
}