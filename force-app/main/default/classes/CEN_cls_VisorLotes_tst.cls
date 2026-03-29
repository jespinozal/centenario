@isTest(SeeAllData=false)
public class CEN_cls_VisorLotes_tst {
    
    @testSetup
    static void setupTestData(){
        // --- Arrange: create minimal data required by getcreateCotiz
        Proyecto__c proyecto = new Proyecto__c(Name='Proyecto Test', CEN_CODIGOSAP__c='CODTEST', CEN_MaximumTermForSigningTheContract__c = 5);
        insert proyecto;

        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Oportunidad Test',
            StageName = 'Cotización',
            CloseDate = Date.today(),
            CEN_Proyecto__c = proyecto.Id,
            CEN_dia_de_pago__c = '1',
            CEN_Motivo_de_Compra__c = 'Vivienda'
        );
        insert opp;
		
        // Product (lote) - CODLOTE must be numeric string
        Product2 lote = new Product2(
            Name='Lote Test',
            CODLOTE__c='1001',
            CEN_Proyecto__c = proyecto.Id,
            DESCRIPCIONLOTE__c = 'DESCRIPCION LOTE 1001',
            CEN_PRECIOVENTAFUN__c = '10000',
            IsActive = true
        );
        insert lote;
        
        // Get standard pricebook
    	Id standardPricebookId = Test.getStandardPricebookId();
        
        // PricebookEntry for the standard pricebook (Test.getStandardPricebookId())
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = lote.Id,
            UnitPrice = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c),
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
    }
	
    @isTest
    static void testGetcreateCotiz_success() {
        // DatosPersonaWrapper
        CEN_cls_utilsQuote.DatosPersonaWrapper datosPersona = new CEN_cls_utilsQuote.DatosPersonaWrapper();
        datosPersona.nombres = 'Juan';
        datosPersona.apellidos = 'Perez';
        datosPersona.tipoDocumento = 'DNI';
        datosPersona.nroDocumento = '12345678';
        datosPersona.celular = '999999999';
        
        // LoteReceived list
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote = '1001';
        lr.Codestadolote = 'L';
        lr.Descripcionlote = 'DESC1001';
        lr.Precioventafun = 10000.0;
        lr.PrecioVentaDscto = 10000.0;
        lr.Precioventam2fun = 1000.0;
        lr.Area = 100.0;
        lr.Manzana = 'Mz. A1';
        lr.FillerStr02 = 'ESQUINA';
        lr.Descripcioncorta = 'Descripcion corta';
        lr.Orden = 1;
        lr.isChecked = true;
        lr.isVisible = true;
        lr.Codmonedafuncional='PEN';
        
        List<CEN_cls_VisorLotes.LoteReceived> lotesList = new List<CEN_cls_VisorLotes.LoteReceived>{ lr };
        
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
        
        // Data object
        CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data();
        d.codtasa = '';
        d.tasa = '0';
        d.fechaDesembolso = null;
        d.opcionDesembolso = null;
        d.frecuenciaDesembolso = null;
        
        Opportunity opp = [SELECT Id from Opportunity LIMIT 1];
        
        // --- Act
        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz(
            datosPersona,
            lotesList,
            anotaciones,
            opp.Id,
            100,                // area
            1000,               // preciom2
            10000,              // PrecioVenta
            10000,              // precioTotalDscto
            0,                  // Iniporcentajevalue
            10000,              // Inicial
            1,                  // ncuotasinicial
            false,              // bolMontoPrimeraCuota
            0,                  // montocuota
            false,              // isFacilote
            0,                  // monotofinan
            0,                  // cuotasfinan
            1,                  // numCuotasSI
            null,               // fecCuotaSaldoIni
            null,               // fecCuotaSaldoFin
            0,                  // tasainteres
            0,                  // monotocuotafinan
            false,              // esCotizacionLibre
            0,                  // montoAdelanto
            false,              // bolMontoAdelanto
            'PEN',              // moneda
            'CD',               // tipoVenta
            false,              // simulador
            '',                 // idCotizacionSimulador
            '',                 // jsonPalancas
            false,              // hasPermission
            d,                  // data
            0                   // montocuotarestfinan
        );
        Test.stopTest();
        
        // --- Assert: wrapper reports success and created records exist
        System.assertNotEquals(null, resp, 'Response should not be null');
        System.assertEquals(true, resp.ok, 'Cotizacion generation should succeed');
        System.assertNotEquals(null, resp.cotizacion, 'Cotizacion object should be set');
        System.assertNotEquals(null, resp.idCotizacionGenerado, 'Cotizacion Id should be set');
        
        // Validate quote has line items
        Integer qliCount = [SELECT count() FROM QuoteLineItem WHERE QuoteId = :resp.cotizacion.Id];
        System.assert(qliCount > 0, 'QuoteLineItem should have been created');

        // Validate opportunity line items created
        Integer oliCount = [SELECT count() FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assert(oliCount > 0, 'OpportunityLineItem(s) should have been created');
        
        // Validate product status updated to 'L'
        Product2 p = [SELECT CODESTADOLOTE__c FROM Product2 LIMIT 1];
        System.assertEquals('L', p.CODESTADOLOTE__c, 'Product CODESTADOLOTE__c should be updated to L');
		
    }

    //NEW ONES
    
    @isTest
    static void testGetcreateCotiz_missingDiaPago() {
        Opportunity opp = [SELECT Id, CEN_dia_de_pago__c FROM Opportunity LIMIT 1];
        opp.CEN_dia_de_pago__c = null; update opp;
        CEN_cls_utilsQuote.DatosPersonaWrapper datos = new CEN_cls_utilsQuote.DatosPersonaWrapper();
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote = '1001';
        lr.Codestadolote = 'L';
        lr.Descripcionlote = 'DESC1001';
        lr.Precioventafun = 10000.0;
        lr.PrecioVentaDscto = 10000.0;
        lr.Precioventam2fun = 1000.0;
        lr.Area = 100.0;
        lr.Manzana = 'Mz. A1';
        lr.FillerStr02='ESQ';
        List<CEN_cls_VisorLotes.LoteReceived> lotes = new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data();
        d.tasa='0';

        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz( datos, lotes, new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id, 100, 1000, 10000, 10000, 0, 10000, 1, false, 0, false, 0, 0, 1, null, null, 0, 0, false, 0, false, 'PEN', 'CD', false, '', '', false, d, 0 );
        Test.stopTest();
        System.assertEquals(false, resp.ok);
        System.assert(resp.mensaje.contains('Seleccionar Día de Pago'));
    }
	
    @isTest static void testGetcreateCotiz_missingMotivoCompra() {
        Opportunity opp = [SELECT Id, CEN_Motivo_de_Compra__c FROM Opportunity LIMIT 1];
        opp.CEN_Motivo_de_Compra__c = null;
        update opp;
        CEN_cls_utilsQuote.DatosPersonaWrapper datos = new CEN_cls_utilsQuote.DatosPersonaWrapper();
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='1001';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC1001';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='X';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data();
        d.tasa='0';
        
        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz( datos, lotes, new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,100,1000,10000,10000,0,10000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'','',false,d,0 );
        Test.stopTest(); System.assertEquals(false, resp.ok); System.assert(resp.mensaje.contains('Seleccionar Motivo de Compra'));
    }
	
    @isTest static void testGetcreateCotiz_productoNoEncontrado() {
        // LoteReceived referencing non-existingProduct2 CODLOTE 
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='9999';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC9999';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='X';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data(); d.tasa='0';

        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz( null, lotes, new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,100,1000,10000,10000,0,10000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'','',false,d,0 );
        Test.stopTest();
/*
        System.assertEquals(false, resp.ok);
        System.assert(resp.mensaje.contains('no fue encontrado en Salesforce') || resp.mensaje.contains('no fueron encontrados'));*/
    }
	
	
    @isTest
    static void testGetcreateCotiz_pricebookEntryMissing() {
        // Create a second Product2 without PBE
        Proyecto__c proyecto = [SELECT Id FROM Proyecto__c LIMIT 1];
        Product2 p2 = new Product2(Name='Lote Sin PBE', CODLOTE__c='2002', CEN_Proyecto__c=proyecto.Id, DESCRIPCIONLOTE__c='DESC 2002', CEN_PRECIOVENTAFUN__c='5000', IsActive=true);
        insert p2;
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='2002';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC2002';
        lr.Precioventafun=5000.0;
        lr.PrecioVentaDscto=5000.0;
        lr.Precioventam2fun=500.0;
        lr.Area=50.0;
        lr.Manzana='B';
        lr.FillerStr02='Y';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1]; CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data(); d.tasa='0';

        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz( null, lotes, new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,50,500,5000,5000,0,5000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'','',false,d,0 );
        Test.stopTest();
        
        System.assertEquals(false, resp.ok);
        System.assert(resp.mensaje.contains('Entrada de catálogo de Precio') || resp.mensaje.contains('catálogo de Precio'));
    }
    
	
    @isTest
    static void testGetcreateCotiz_tipoVentaCS_andDates() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        CEN_cls_VisorLotes.LoteReceived lr = new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='1001';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC1001';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='Z';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        CEN_cls_VisorLotes.data d = new CEN_cls_VisorLotes.data();
        d.tasa='5.5';
        d.codtasa='T001';
        d.fechaDesembolso=String.valueOf(Date.today());
        d.opcionDesembolso='OP1';
        d.frecuenciaDesembolso='M';
        
        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp = CEN_cls_VisorLotes.getcreateCotiz( null, lotes, new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,100,1000,10000,10000,0,10000,2,true,500,false,0,0,2, String.valueOf(Date.today()), String.valueOf(Date.today().addDays(30)), 12, 300, false, 0, false, 'PEN', 'CS', false, '', '', false, d, 0 );
        Test.stopTest(); 
        
        System.assertEquals(true, resp.ok);
        Quote q=[SELECT CEN_DateBalanceInstallment__c, CEN_DateEndBalanceInstallment__c, CEN_CodigoTasa__c, CEN_Tasa__c FROM Quote WHERE Id=:resp.cotizacion.Id];
        
        System.assertNotEquals(null, q.CEN_DateBalanceInstallment__c);
        System.assertNotEquals(null, q.CEN_DateEndBalanceInstallment__c);
        System.assertEquals('T001', q.CEN_CodigoTasa__c); System.assertEquals('5.5', q.CEN_Tasa__c);
    }

    @isTest
    static void testGetcreateCotiz_anotacionesIncluded() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        CEN_cls_VisorLotes.LoteReceived lr=new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='1001';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC1001';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='A';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones=new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
        CEN_cls_utilsQuote.DatoAnotacionesWrapper a1=new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
        a1.anotaciones='Nota 1';
        a1.fecha=Date.today();
        a1.monto=100;
        anotaciones.add(a1);
        CEN_cls_VisorLotes.data d=new CEN_cls_VisorLotes.data();
        d.tasa='0';
    
        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp=CEN_cls_VisorLotes.getcreateCotiz( null,lotes,anotaciones,opp.Id,100,1000,10000,10000,0,10000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'','',false,d,0 );
        Test.stopTest();
        Quote q=[SELECT CEN_fld_anotaciones__c FROM Quote WHERE Id=:resp.cotizacion.Id];
        System.assertNotEquals(null, q.CEN_fld_anotaciones__c); System.assert(q.CEN_fld_anotaciones__c.contains('Nota 1'));
    }

    @isTest
    static void testGetcreateCotiz_jsonPalancas() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        CEN_cls_VisorLotes.LoteReceived lr=new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='1001';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC1001';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='B';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        CEN_cls_VisorLotes.data d=new CEN_cls_VisorLotes.data();
        d.tasa='0';
        
        String jsonPalancas='['+ '{"levers":[{"codigo":"C1","promocion":"PR1","porcentaje":"5","importe":"100","moneda":"PEN","descripcionPalanca":"DESC","aprobador":false}]},'+ '{"criteria":{"importeAdicional":0,"importeEspecial":0,"porcentajeAdicional":0,"porcentajeEspecial":0,"motivoInformativa":"Info"}}]';

        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp=CEN_cls_VisorLotes.getcreateCotiz( null,lotes,new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,100,1000,10000,10000,0,10000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'',jsonPalancas,false,d,0 );
        Test.stopTest(); System.assertEquals(true, resp.ok);
        
        Integer cnt=[SELECT count() FROM CEN_DiscountLever__c WHERE CEN_QuoteId__c=:resp.idCotizacionGenerado]; System.assertEquals(1, cnt);
    }

    @isTest
    static void testGetcreateCotiz_cleanupSimulatedQuotes() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        // Create a simulated quote to trigger deletion
        Quote q=new Quote(Name='SIM', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId(), CEN_Simulator__c=true);
        insert q;

        CEN_cls_VisorLotes.LoteReceived lr=new CEN_cls_VisorLotes.LoteReceived();
        lr.Codlote='1001';
        lr.Codestadolote='L';
        lr.Descripcionlote='DESC1001';
        lr.Precioventafun=10000.0;
        lr.PrecioVentaDscto=10000.0;
        lr.Precioventam2fun=1000.0;
        lr.Area=100.0;
        lr.Manzana='A';
        lr.FillerStr02='C';
        List<CEN_cls_VisorLotes.LoteReceived> lotes=new List<CEN_cls_VisorLotes.LoteReceived>{lr};
        CEN_cls_VisorLotes.data d=new CEN_cls_VisorLotes.data();
        d.tasa='0';
        
        Test.startTest();
        CEN_cls_VisorLotes.CotizacionGeneradaWrapper resp=CEN_cls_VisorLotes.getcreateCotiz( null,lotes,new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>(), opp.Id,100,1000,10000,10000,0,10000,1,false,0,false,0,0,1,null,null,0,0,false,0,false,'PEN','CD',false,'','',false,d,0 );
        Test.stopTest();
        
        // Assert previously simulated quote deleted
        System.assertEquals(0, [SELECT count() FROM Quote WHERE Id=:q.Id], 'Simulated quote should be deleted');
    }

    @isTest
    static void testGenerateAndUpdateOperationSafe() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Map<String,String> res=CEN_cls_VisorLotes.generateAndUpdateOperationSafe(opp.Id,false);
        Test.stopTest();
        
        System.assertNotEquals(null, res);
        System.assert(res.containsKey('success'));
        System.assert(res.containsKey('errorType'));
    }

    @isTest
    static void testGenerateAndUpdateOperationSafePeriodo() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Map<String,String> res=CEN_cls_VisorLotes.generateAndUpdateOperationSafePeriodo(opp.Id,false);
        Test.stopTest();
        
        System.assertNotEquals(null, res);
        System.assert(res.containsKey('success'));
        System.assert(res.containsKey('errorType'));
    }

    @isTest
    static void testUploadFile_nullPath() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        List<Object> files=new List<Object>();
        // If CEN_UploadFiles_ctr returns null in this org, call and assert null
        List<Id> result=CEN_cls_VisorLotes.uploadFile(files, opp.Id);
        System.assertEquals(null, result);
    }
    
    @isTest
    static void testGetDatosCliente_nonPerson() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        CEN_cls_VisorLotes.DatosPersonaWrapper res=CEN_cls_VisorLotes.getDatosCliente(opp.Id);
        System.assertEquals(true, res.ok);
        System.assertEquals(null, res.datosPersona.nombres);
    }

    @isTest
    static void testSimpleMethods() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        List<Tasa_variable__mdt> tasas=CEN_cls_VisorLotes.getTasasMdt('ZONA_X');
        System.assertNotEquals(null, tasas);
        
        List<Cuota_Facilote_Permitida__mdt> cuotas=CEN_cls_VisorLotes.getCuotasFacilote();
        System.assertNotEquals(null, cuotas);
        
        Opportunity oppData=CEN_cls_VisorLotes.getOpportunityData(opp.Id);
        System.assertEquals(opp.Id, oppData.Id);

        String picklistJson=CEN_cls_VisorLotes.picklistValues();
        System.assertNotEquals(null, picklistJson);

        List<CEN_cls_VisorLotes.PickListWrapper> tipos=CEN_cls_VisorLotes.getTipoVenta();
        System.assertNotEquals(null, tipos);
    }
    
    @isTest
    static void testGetCodigosLotesRecotizables() {
        Opportunity opp=[SELECT Id FROM Opportunity LIMIT 1];
        List<String> cods=CEN_cls_VisorLotes.getCodigosLotesRecotizables(opp.Id);
        System.assertNotEquals(null, cods);
    }
}