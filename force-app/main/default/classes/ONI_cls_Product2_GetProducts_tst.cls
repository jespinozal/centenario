@IsTest
private class ONI_cls_Product2_GetProducts_tst {

    @IsTest
    static void testGetProductsSuccess() {
        // 1. Obtener los IDs de los Record Types (Deben existir en tu Org)
        Id rtOficina = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OFI_rt_Product2_Oficina').getRecordTypeId();
        Id rtIndustrial = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OFI_rt_Product2_Industrial').getRecordTypeId();
        
        // 2. Crear datos de prueba
        List<Product2> prodsToInsert = new List<Product2>();
        Pricebook2 customPb = new Pricebook2(Name = 'Urbano',IsActive = true);
        insert customPb;
        
        Id pricebookId = Test.getStandardPricebookId(); 
        Pricebook2 standardPricebook =  new Pricebook2(Id = pricebookId,IsActive = true); 
        update standardPricebook;
        
		Proyecto__c proyecto = new Proyecto__c(Name='Proyecto Test', CEN_CODIGOSAP__c='CODTEST', CEN_MaximumTermForSigningTheContract__c = 5, CEN_Sociedad__c = '0019');
        insert proyecto;
        
        prodsToInsert.add(new Product2(Name = 'Prod Oficina', RecordTypeId = rtOficina, IsActive = true));
        prodsToInsert.add(new Product2(Name = 'Prod Industrial', RecordTypeId = rtIndustrial, IsActive = true));
        prodsToInsert.add(new Product2(
            Name = 'Prod Otros', 
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
                CODLOTE__c='94010836',
                IsActive = true
            )); // Sin RT específico para probar el filtro

        insert prodsToInsert;

        // 3. Ejecución del método
        Test.startTest();
        List<Product2> result = ONI_cls_Product2_GetProducts.ONI_cls_Product2_GetProducts();
        Test.stopTest();

        // 4. Validaciones
        System.assertNotEquals(0, result.size(), 'La lista no debería estar vacía');
        System.assertEquals(2, result.size(), 'Debería haber retornado exactamente 2 productos (Oficina e Industrial)');
        
        // Validar que los nombres coincidan con los esperados
        Set<String> validNames = new Set<String>{'Prod Oficina', 'Prod Industrial'};
        for(Product2 p : result) {
            System.assert(validNames.contains(p.Name), 'El producto retornado no pertenece a los Record Types filtrados');
        }
    }

    @IsTest
    static void testGetProductsEmpty() {
        // Escenario donde no hay productos que coincidan con el filtro
        Test.startTest();
        List<Product2> result = ONI_cls_Product2_GetProducts.ONI_cls_Product2_GetProducts();
        Test.stopTest();

        System.assertEquals(0, result.size(), 'La lista debería estar vacía si no hay registros con esos Record Types');
    }
}