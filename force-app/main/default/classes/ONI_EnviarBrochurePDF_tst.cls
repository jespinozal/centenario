@IsTest
private class ONI_EnviarBrochurePDF_tst {

    @TestSetup
    static void setupData() {
        // Obtener un RecordType real de Product2
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName='OFI_rt_Product2_Oficina'LIMIT 1];
		
        // Crear Lead
        Lead l = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Email = 'test@test.com',
            LeadSource = 'Presencial',
            CEN_medio__c = '0118',
            status = 'IND_Nuevo',
            MobilePhone='+51987654328'
        );
        insert l;
        
        Pricebook2 customPb = new Pricebook2(Name = 'Urbano',IsActive = true);
        insert customPb;
        
        Id pricebookId = Test.getStandardPricebookId(); 
        Pricebook2 standardPricebook =  new Pricebook2(Id = pricebookId,IsActive = true); 
        update standardPricebook;
        
		Proyecto__c proyecto = new Proyecto__c(Name='Proyecto Test', CEN_CODIGOSAP__c='CODTEST', CEN_MaximumTermForSigningTheContract__c = 5, CEN_Sociedad__c = '0019');
        insert proyecto;
        
        // Crear Productos
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<2; i++){
            products.add(new Product2(
                Name = 'Producto ' + i,
                Imagen_URL__c = 'https://test.com/img'+i+'.jpg',
                RecordTypeId = rt.Id,
                IDPROYECTO__c='CODTEST',
                MANZANA__c='F11', 
                CODESTADOLOTE__c='C',
                DESCRIPCIONCORTA__c='SM1F11014',
                CEN_USOINMUEBLE__c='CV', 
                AREA__c='126', 
                CODMONEDAFUNCIONAL__c='Soles', 
                CEN_TIPOINMUEBLE__c='LO', 
                CEN_TIPOLOTE__c='V', 
                CEN_MEDIDAFRENTE__c='8.4', 
                CEN_MEDIDAFONDO__c='8.4', 
                CEN_MEDIDAIZQUIERDA__c='15', 
                CEN_MEDIDADERECHA__c='15', 
                LINDERODERECHA__c='LOTE 13', 
                CEN_LINDEROIZQUIERDA__c='CALLE 22', 
                CEN_LINDEROFRENTE__c='CALLE 5', 
                CEN_LINDEROFONDO__c='PROP. TERCEROS', 
                CEN_Tipo_de_proyecto__c='Urbano', 
                ProductCode='10U1.020E', 
                CEN_IdLotSAP__c='00000001',
                CEN_PRECIOVENTAFUN__c='61878',
                DESCRIPCIONLOTE__c='SANTA MARÍA ETAPA 1 Mz.F11 Lt.14',
                CODLOTE__c='94010836'+i,
                IsActive = true
            ));
        }
        insert products;

        for(Integer i=0; i<2; i++){
            PricebookEntry customPbe1 = new PricebookEntry(
                Pricebook2Id = customPb.Id,
                Product2Id = products[i].Id,
                UnitPrice = 150,
                IsActive = true
        	);
        }
    }

    @IsTest
    static void testConstructorWithParams() {

        List<Product2> prods = [SELECT Id FROM Product2];

        // Simular página VF
        PageReference pageRef = new PageReference('/apex/ONI_vfp_BrochurePDF');
        pageRef.getParameters().put('idList', JSON.serialize(new List<Id>{prods[0].Id}));
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ONI_EnviarBrochurePDF_cls controller = new ONI_EnviarBrochurePDF_cls();
        Test.stopTest();

        System.assertNotEquals(null, controller.imagenesFiles);
    }

    @IsTest
    static void testGenerateAndAttachPdfEx() {

        Lead l = [SELECT Id FROM Lead LIMIT 1];
        List<Product2> prods = [SELECT Id FROM Product2];

        Test.startTest();

        // Necesario para que getContentAsPDF no falle
        Test.setCurrentPage(Page.ONI_vfp_BrochurePDF);

        String cvId = ONI_EnviarBrochurePDF_cls.generateAndAttachPdfEx(
            l.Id,
            new List<Id>{prods[0].Id}
        );

        Test.stopTest();

        System.assertNotEquals(null, cvId);

        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Id = :cvId];
        System.assertEquals(cvId, cv.Id);
    }

    @IsTest
    static void testSendEmailWithBrochure() {

        Lead l = [SELECT Id FROM Lead LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'H'
        );
        insert cv;

        Test.startTest();
        ONI_EnviarBrochurePDF_cls.sendEmailWithBrochure(l.Id, cv.Id);
        Test.stopTest();
        
    }

    @IsTest
    static void testGetResourceURL() {

        Test.startTest();
        List<String> urls = ONI_EnviarBrochurePDF_cls.getResourceURL('NON_EXISTING_RESOURCE%');
        Test.stopTest();

        System.assertNotEquals(null, urls);
    }
    
    @IsTest
    static void testGetListProducts() {
        
        // Obtener un RecordType real de Product2
        RecordType rt = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'Product2' 
            LIMIT 1
        ];
        
        // Crear producto con ese RecordType
        Product2 prod = new Product2(
            IsActive = true,
            RecordTypeId = rt.Id,
            IDPROYECTO__c= 'CODTEST',
            MANZANA__c= 'A1',
            CODESTADOLOTE__c= 'L',
            DESCRIPCIONCORTA__c= 'CDR01A1002',
            CEN_USOINMUEBLE__c= 'DP',
            CEN_PRECIOVENTAFUN__c= '87770',
            AREA__c= '93',
            CODMONEDAFUNCIONAL__c= 'PEN',
            DESCRIPCIONLOTE__c= 'CEDROS ETAPA 1 Mz.A1 Lt.02',
            CODLOTE__c= '840044517',
            CEN_TIPOINMUEBLE__c= 'V',
            CEN_TIPOLOTE__c= 'LO',
            CEN_MEDIDAFRENTE__c= '7.59',
            CEN_MEDIDAFONDO__c= '7.59',
            CEN_MEDIDAIZQUIERDA__c= '12.00',
            CEN_MEDIDADERECHA__c= '12.00',
            LINDERODERECHA__c= 'LOTE A03',
            CEN_LINDEROIZQUIERDA__c= 'TERRENO TERCEROS',
            CEN_LINDEROFRENTE__c= 'PASAJE 1',
            CEN_LINDEROFONDO__c= 'LOTE DE SERVICIO',
            CEN_Tipo_de_proyecto__c= 'Urbano',
            Name= 'CEDROS ETAPA 1 Mz.A1 Lt.02',
            ProductCode= '19U1.374E',
            CEN_IdLotSAP__c= '1'
        );
        insert prod;
        
        Test.startTest();
        List<Product2> result = ONI_EnviarBrochurePDF_cls.getListProducts(rt.Name);
        Test.stopTest();
        
        System.assert(!result.isEmpty(), 'Debe devolver al menos un producto');
    }
    
}