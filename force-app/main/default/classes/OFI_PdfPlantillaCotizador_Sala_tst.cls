@isTest
public class OFI_PdfPlantillaCotizador_Sala_tst {
    
    @testSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test@test.com',
            LeadSource = 'Digital',
            MobilePhone = '+51987654321',
            CEN_Medio__c = '0084'
        );
        insert testLead;
        
        // Create Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Cotización',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Create Product2
        Product2 testProduct = new Product2(
            Name = 'Test Sala',
            IsActive = true
        );
        insert testProduct;
        
        // Get standard pricebook
    	Id standardPricebookId = Test.getStandardPricebookId();
        
        // Create PricebookEntry for standard pricebook
        PricebookEntry standardPbe = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPbe;
        
        /*// Create Pricebook2
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        // Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;*/
        
        // Create Quote with Lead
        Quote testQuoteWithLead = new Quote(
            Name = 'Test Quote With Lead',
            OpportunityId = testOpp.Id,
            Pricebook2Id = standardPricebookId,  // Add this line
            Status = 'Draft',
            ONI_fld_Quote_Lead__c = testLead.Id,
            IND_fld_Cotizacion_Condiciones__c = '[{"name":"Proyector","rDate":"2026-01-08","qty":"1","unitAmount":"123","totalAmount":"123.00"}]',
            CEN_Precio_de_venta__c = 1000,
            CEN_Precio_de_venta_con_descuento__c = 900
        );
        insert testQuoteWithLead;
        
        // Create Quote without Lead
        Quote testQuoteWithoutLead = new Quote(
            Name = 'Test Quote Without Lead',
            OpportunityId = testOpp.Id,
            Pricebook2Id = standardPricebookId,  // Add this line
            Status = 'Draft',
            IND_fld_Cotizacion_Condiciones__c = '[]',
            CEN_Precio_de_venta__c = 500,
            CEN_Precio_de_venta_con_descuento__c = 450
        );
        insert testQuoteWithoutLead;
        
        DateTime ahora = System.now();       
        // Create QuoteLineItem
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = testQuoteWithLead.Id,
            Product2Id = testProduct.Id,
            PricebookEntryId = standardPbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            CEN_TotalPriceEspejo__c = 100,
            OFI_fld_QLI_Asistentes__c = 20,
            OFI_fld_QLI_FechaHoraEvento__c = ahora,
            OFI_fld_QLI_FechaHoraFinEvento__c = ahora.addHours(2),
            OFI_fld_QLI_Montaje__c = 'Escuela'
        );
        insert qli;
    }
    
    @isTest
    static void testConstructorWithLead() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithoutLead() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c = null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCondicionesWithData() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        List<Map<String,Object>> condiciones = controller.getCondiciones();
        Test.stopTest();
    }
    
    @isTest
    static void testGetCondicionesEmpty() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c = null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        List<Map<String,Object>> condiciones = controller.getCondiciones();
        Test.stopTest();
    }
    
    @isTest
    static void testGetTotalAmount() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Decimal total = controller.getTotalAmount();
        Test.stopTest();
    }
    
    @isTest
    static void testGetTotalSalas() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Decimal total = controller.getTotalSalas();
        Test.stopTest();
    }
    
    @isTest
    static void testGetTotalItemsCount() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Integer count = controller.getTotalItemsCount();
        Test.stopTest();
    }
    
    @isTest
    static void testBooleanMethods() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        Test.stopTest();
    }
    
    //EXTRA TESTS
    @isTest
    static void testConstructorWithLead2() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        
        // Call getter methods to cover uncovered lines
        Quote q = controller.getQuote();
        Account acc = controller.getAccount();
        List<QuoteLineItem> salas = controller.getSalas();
        
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithoutLead2() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c = null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        
        // Call getter methods
        Quote q = controller.getQuote();
        Account acc = controller.getAccount();
        List<QuoteLineItem> salas = controller.getSalas();
        
        Test.stopTest();
    }
    
    @isTest
    static void testBooleanMethods2() {
        Quote testQuote = [SELECT Id FROM Quote WHERE ONI_fld_Quote_Lead__c != null LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OFI_PdfPlantillaCotizador_Sala_cls controller = new OFI_PdfPlantillaCotizador_Sala_cls(sc);
        
        // Call all boolean methods to cover uncovered lines
        Boolean isOne = controller.getIsOne();
        Boolean isTwo = controller.getIsTwo();
        Boolean isThree = controller.getIsThree();
        Boolean isMoreThanThree = controller.getIsMoreThanThree();
        
        Test.stopTest();
    }
}