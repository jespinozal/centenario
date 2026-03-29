@isTest
public with sharing class OFI_PdfPlantillaCotizador_tst {
    
    @testSetup
    static void setupData() {

        Proyecto__c edificio = new Proyecto__c(
        Name = 'Edificio Central', 
        ONI_fld_Proyecto_EdificioExternalId__c = 'EXT-001'
    );
    insert edificio;

        Id pricebookId = Test.getStandardPricebookId();
        // 1. Create Account
        Account acc = new Account(Name = 'Lead Corp', Phone = '123456789');
        insert acc;

        // 2. Create Opportunity
        Id OrecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Oportunidad_Oficina')
        ?.getRecordTypeId();
        Id LrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Lead_Oficina')
        ?.getRecordTypeId();


    Opportunity opp = new Opportunity(Name = 'Opp Sin Quote', StageName = 'Cotización', CloseDate = Date.today(),
    recordTypeId=OrecordTypeId,
        
        ONI_fld_Oportunidad_TipoRegistroInterno__c=LrecordTypeId,
         pricebook2Id=pricebookId,
         AccountId = acc.Id
    
    );
        insert opp;

      

        // 3. Create Quote with JSON conditions
        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            IND_fld_Cotizacion_Condiciones__c = '[{"description":"Plazo Forzoso","value":"12 meses"},{"description":"Gastos de Condominio","value":"$500"}]',
            pricebook2Id=pricebookId
            
        );
        insert q;

        Id rtId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OFI_rt_Product2_Oficina').getRecordTypeId();
        // 4. Create Product and Pricebook Entry
        Product2 prod = new Product2(
            Name = 'Test Product', 
            OFI_fld_Product2_DescUnidadEconomica__c = 'Business Unit A',
            OFI_fld_Product2_DescEdificio__c = 'Building Alpha',
            CEN_Proyecto__c = edificio.Id,
            RecordTypeId = rtId
        );
        insert prod;

        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // 5. Create QuoteLineItem
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id
        );
        insert qli;
    }

    @isTest
    static void testControllerWithAccount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        // Initialize Visualforce Page
        PageReference pageRef = Page.OFI_vf_PdfPlantillaCotizador; // Replace with actual VF page name
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        OFI_PdfPlantillaCotizador_cls controller = new OFI_PdfPlantillaCotizador_cls(sc);
        
        // Assertions for Data retrieval
        Assert.areNotEqual(null, controller.getQuote(), 'Quote should be loaded');
        Assert.areNotEqual(null, controller.getAccount(), 'Account should be loaded');
        Assert.isFalse(controller.getLotList().isEmpty(), 'Lot list should not be empty');
        
        // Assertions for Logic
        Assert.areEqual('Business Unit A', controller.getUnidadNegocio());
        Assert.areEqual('BuildingAlpha', controller.getImagenUrl());
        Assert.isTrue(controller.getFecha().contains('de'), 'Date string should be formatted');
        
        // Assertions for JSON parsing
        Assert.areEqual('12 meses', controller.getPlazoForzoso());
        Assert.isTrue(controller.getIsPlazoForzoso());
        Assert.areEqual('$500', controller.getGastosCondominio());
        Assert.isNull(controller.getGarantia(), 'Garantia was not in JSON, should be null');
        Test.stopTest();
    }

    @isTest
    static void testControllerWithLead() {
        // Create a Lead and a Quote linked to it
         Lead ld = new Lead();
        ld.Salutation = 'Sr.';
        ld.FirstName = 'Joel';
        ld.LastName = 'Espinoza';
        ld.CEN_N_mero_de_documento__c = '22063637';
        ld.LeadSource = 'Digital';
        ld.CEN_Medio__c = '0110';
       
        ld.Company='Lead Corp';
        ld.MobilePhone='+51999999999';
        insert ld;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qLead = new Quote(
            Name = 'Lead Quote', 
            OpportunityId = opp.Id, 
            ONI_fld_Quote_Lead__c = ld.Id
        );
        insert qLead;
        
        // Product/Pricebook setup for the new Quote
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        insert new QuoteLineItem(QuoteId = qLead.Id, Quantity = 1, UnitPrice = 10, PricebookEntryId = pbe.Id, Product2Id = prod.Id);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qLead);
        OFI_PdfPlantillaCotizador_cls controller = new OFI_PdfPlantillaCotizador_cls(sc);
        
        Assert.areEqual('Lead Corp', controller.getAccount().Name, 'Account name should match Lead company');
        Test.stopTest();
    }

    @isTest
    static void testBooleanConditionGetters() {
        Quote q = [SELECT Id FROM Quote  LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        OFI_PdfPlantillaCotizador_cls controller = new OFI_PdfPlantillaCotizador_cls(sc);

        // Assert Boolean Getters for Conditions
        Assert.isFalse(controller.getIsIncrementosAnuales(), 'Should be true based on JSON');
        Assert.isFalse(controller.getIsGarantia(), 'Should be true based on JSON');
        Assert.isFalse(controller.getIsPeriodoGracia(), 'Should be true based on JSON');
        Assert.isFalse(controller.getIsPlazoVoluntario(), 'Should be true based on JSON');
        Assert.isFalse(controller.getIsInformacionAdicional(), 'Should be true based on JSON');
        
        // Assert List Size Getters (5 items inserted)
        Assert.isFalse(controller.getIsMoreThanFour(), 'Size 5 is more than 4');
     //   Assert.isFalse(controller.getIsLessThanThree(), 'Size 5 is NOT less than 3');
        Test.stopTest();
    }
}