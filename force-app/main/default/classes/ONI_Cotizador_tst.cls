@isTest
public with sharing class ONI_Cotizador_tst {


    @testSetup
    static void setup() {
        OFI_obj_MaestroPrecioEdificio__c maestroPrecio = new OFI_obj_MaestroPrecioEdificio__c (
            Name='Torre El Pilar',
            OFI_fld_MtroPrecioEdif_PrecioCascoGris__c=10,
            OFI_fld_MtroPrecioEdif_PrecioImplCen__c=10,
            OFI_fld_MtroPrecioEdif_PrecioImplExCli__c=10
        );
        insert maestroPrecio;
        
        Proyecto__c pro = new Proyecto__c(Name = 'MacrOpolis', CEN_CODIGOSAP__c = 'P001');
        insert pro;
         Pricebook2 pbIndustrial = new Pricebook2(Name = 'MacrOpolis', IsActive = true);
        Pricebook2 pbOficina = new Pricebook2(Name = 'Oficinas', IsActive = true);
        insert new List<Pricebook2>{pbIndustrial, pbOficina};
       // Create Pricebook
        Pricebook2 standardPb = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPb;

        Pricebook2 customPb = new Pricebook2(Name = 'Oficinas', IsActive = true);
        insert customPb;

        // Create Product with specific criteria for getRooms()
        Product2 prod = new Product2(
            Name = 'Sala de Juntas',
            IsActive = true,
            OFI_fld_Product2_Clase__c = 19, // Ensure this matches your field type (String/Decimal)
            OFI_fld_Product2_Estado__c = 'L'
        );
        // Set Record Type via DeveloperName if possible, otherwise use Id
        Id rtId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OFI_rt_Product2_Oficina').getRecordTypeId();
        prod.RecordTypeId = rtId;
        insert prod;

        // Create Pricebook Entry
        insert new PricebookEntry(
            Pricebook2Id = standardPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        insert new PricebookEntry(
            Pricebook2Id = customPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );

        // Create OFI_Sala__c for availability testing
        OFI_Sala__c sala = new OFI_Sala__c();
        insert sala;

        // Create a Booking
        OFI_SalaReserva__c booking = new OFI_SalaReserva__c(
            OFI_fld_SalaReserva_Producto__c = sala.Id,
            OFI_fld_SalaReserva_Inicio__c = DateTime.now(),
            OFI_fld_SalaReserva_Fin__c = DateTime.now().addHours(2),
            OFI_fld_SalaReserva_Tipo__c = 'Half AM'
        );
        insert booking;


        Id OrecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Oportunidad_Oficina')
        ?.getRecordTypeId();
        Id LrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Lead_Oficina')
        ?.getRecordTypeId();
System.debug('dev1:'+OrecordTypeId);
        // Create Opportunity

        
         Lead ld = new Lead();
        ld.Salutation = 'Sr.';
        ld.FirstName = 'Joel';
        ld.LastName = 'Espinoza';
        ld.CEN_N_mero_de_documento__c = '22063637';
        ld.LeadSource = 'Digital';
        ld.CEN_Medio__c = '0110';
        ld.recordTypeId=LrecordTypeId;
        ld.Company='ooo';
        ld.MobilePhone='+51999999999';
        insert ld;



        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Cotización', CloseDate = Date.today(),recordTypeId=OrecordTypeId,
        Pricebook2Id=standardPb.Id,
        ONI_fld_Oportunidad_TipoRegistroInterno__c=LrecordTypeId
        );
        insert opp;
        System.debug('dev::'+opp.recordtypeId);
        System.debug('dev::'+opp.recordtype.DeveloperName);
    }

    @isTest
    static void testGetLotesFromEndpoint() {
        Test.setMock(HttpCalloutMock.class, new ONI_Cotizador_Mock());
        
        Test.startTest();
        List<ONI_Cotizador_cls.LoteWrapper> result = ONI_Cotizador_cls.getLotesFromEndpoint('P001');
        Test.stopTest();

        Assert.isFalse(result.isEmpty(), 'La lista de lotes no debería estar vacía');
        Assert.areEqual('row1', result[0].codLote);
    }

    @isTest
    static void testSaveProcess() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Preparar Datos de Entrada
        List<String> lotList = new List<String>{'row_new_123'};
        
        Map<String, String> qData = new Map<String, String>{
            'typeSale' => 'CD',
            'directPayment' => '1000',
            'totalArea' => '150.5',
            'installmentPayment' => '500',
            'installmentNumber' => '12',
            'chunkPayment' => '2000',
            'chunkNumber' => '24',
            'chunkTEA' => '10',
            'milestoneList'=>'[]'
        };

        Map<String, List<String>> qliPrice = new Map<String, List<String>>{
            'row_new_123' => new List<String>{'10', '1500', '150', 'Lote de Prueba','false'}
        };

        Test.setMock(HttpCalloutMock.class, new ONI_Cotizador_Mock());

        Test.startTest();
        // Probar guardado para Industrial
        Boolean success = ONI_Cotizador_cls.save(opp.Id, lotList, qData, qliPrice, true);
        Test.stopTest();

        Assert.isTrue(success, 'El método save debería retornar true');
        
        // Verificar creación de Quote
        Quote q = [SELECT Id, Name, Pricebook2.Name FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];
        Assert.areEqual('MacrOpolis', q.Pricebook2.Name);
        
        // Verificar creación de Producto
        Product2 p = [SELECT Id, Name, CODLOTE__c FROM Product2 WHERE CODLOTE__c = 'row_new_123' LIMIT 1];
        Assert.areEqual('Lote de Prueba', p.Name);
    }

    @isTest
    static void testSaveProcessLead() {
        Lead opp = [SELECT Id FROM Lead LIMIT 1];
        
        // Preparar Datos de Entrada
        List<String> lotList = new List<String>{'row_new_123'};
        
        Map<String, String> qData = new Map<String, String>{
            'typeSale' => 'CD',
            'directPayment' => '1000',
            'totalArea' => '150.5',
            'installmentPayment' => '500',
            'installmentNumber' => '12',
            'chunkPayment' => '2000',
            'chunkNumber' => '24',
            'chunkTEA' => '10',
            'milestoneList'=>'[]'
        };

        Map<String, List<String>> qliPrice = new Map<String, List<String>>{
            'row_new_123' => new List<String>{'10', '1500', '150', 'Lote de Prueba','false'}
        };

        Test.setMock(HttpCalloutMock.class, new ONI_Cotizador_Mock());

        Test.startTest();
        // Probar guardado para Industrial
        Boolean success = ONI_Cotizador_cls.save(opp.Id, lotList, qData, qliPrice, true);
        String gettingOpportunity = ONI_Cotizador_cls.getRecordTypeName(opp.Id);
        Test.stopTest();

        Assert.isTrue(success, 'El método save debería retornar true');
        
        // Verificar creación de Quote
        Quote q = [SELECT Id, Name, Pricebook2.Name FROM Quote WHERE ONI_fld_Quote_Lead__c = :opp.Id LIMIT 1];
        Assert.areEqual('MacrOpolis', q.Pricebook2.Name);
        
        // Verificar creación de Producto
        Product2 p = [SELECT Id, Name, CODLOTE__c FROM Product2 WHERE CODLOTE__c = 'row_new_123' LIMIT 1];
        Assert.areEqual('Lote de Prueba', p.Name);
    }

    @isTest
    static void testIsNumber() {
        Assert.isTrue(ONI_Cotizador_cls.isNumber('100.50'));
        Assert.isFalse(ONI_Cotizador_cls.isNumber('ABC'));
        Assert.isFalse(ONI_Cotizador_cls.isNumber(null));
    }

    public class ONI_Cotizador_Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"idLote": 123, "codLote": "row1", "descripcionLote": "Lote Test", "precioVenta": 1000.0}]');
        res.setStatusCode(200);
        return res;
    }
}

    @isTest
static void testGetIndustrial() {
    // 1. Obtener datos del setup
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Pricebook2 pbIndustrial = [SELECT Id FROM Pricebook2 WHERE Name = 'MacrOpolis' LIMIT 1];
    Id standardPbId = Test.getStandardPricebookId();
    
    List<RecordType> rtProduct = [SELECT Id, Name FROM RecordType WHERE SobjectType ='Product2' AND Name LIKE '%Industrial%' LIMIT 1];

    // 2. Crear Producto que cumpla los filtros (Estado 'L' y sin oportunidad asignada)
    Product2 prod = new Product2(
        Name = 'Lote Industrial 01',
        OFI_fld_Product2_Estado__c = 'L',
        CEN_PRECIOVENTAFUN__c = '50000',
        RecordTypeId = rtProduct[0].Id,
        IsActive = true
    );
    insert prod;

    // 3. Crear Entradas de Lista de Precios (Standard y MacrOpolis)
    PricebookEntry standardPbe = new PricebookEntry(
        Pricebook2Id = standardPbId,
        Product2Id = prod.Id,
        UnitPrice = 50000,
        IsActive = true
    );
    insert standardPbe;

    PricebookEntry customPbe = new PricebookEntry(
        Pricebook2Id = pbIndustrial.Id,
        Product2Id = prod.Id,
        UnitPrice = 50000,
        IsActive = true
    );
    insert customPbe;

    Test.startTest();
    // Ejecutar el método (projectId y typeProduct no se usan en tu lógica actual pero se pasan por firma)
    List<PricebookEntry> results = ONI_Cotizador_cls.getIndustrial(null, 'Industrial', opp.Id);
    Test.stopTest();

    // 4. Verificaciones (Assertions)
    Assert.isFalse(results.isEmpty(), 'Debería retornar al menos una entrada de precio');
    Assert.areEqual('Lote Industrial 01', results[0].Product2.Name, 'El nombre del producto no coincide');
    
    // Verificación de toLabel (en tests devuelve el valor de la API a menos que se defina traducción)
    Assert.areEqual('Libre', results[0].Product2.OFI_fld_Product2_Estado__c);
}    

    @isTest
static void testGetOffice() {
    // 1. Obtener el Record Type Id para Oficina
    Id ofiRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
                        .get('OFI_rt_Product2_Oficina').getRecordTypeId();
    
    // 2. Crear un Edificio (Proyecto) - Usando Proyecto__c como referencia según tu código
    Proyecto__c edificio = new Proyecto__c(
        Name = 'Edificio Central', 
        ONI_fld_Proyecto_EdificioExternalId__c = 'EXT-001'
    );
    insert edificio;
    
    // 3. Crear Producto de Oficina
    Product2 prodOfi = new Product2(
        Name = 'Oficina 101',
        RecordTypeId = ofiRecordTypeId,
        OFI_fld_Producto_NombreEdificio__c = edificio.Id,
        OFI_fld_Product2_Estado__c = 'L',
        OFI_fld_Product2_Clase__c = 10, // Clase ejemplo
        CEN_PRECIOVENTAFUN__c = '200000',
        OFI_fld_Product2_DescEdificio__c = 'Torre El Pilar',
        IsActive = true
    );
    insert prodOfi;

    // 4. Crear PricebookEntry (Requerido para la consulta SOQL)
    Id standardPbId = Test.getStandardPricebookId();
    insert new PricebookEntry(
        Pricebook2Id = standardPbId,
        Product2Id = prodOfi.Id,
        UnitPrice = 200000,
        IsActive = true
    );

    Test.startTest();
    // Caso A: Filtrando por clase específica
    List<Object> resultWithClass = ONI_Cotizador_cls.getOffice(edificio.Id, '1');
    
    // Caso B: Sin filtro de clase (trae todos excepto clase 19)
    List<Object> resultNoClass = ONI_Cotizador_cls.getOffice(edificio.Id, '');
    Test.stopTest();

    // 5. Validaciones
    //Assert.isFalse(resultWithClass.isEmpty(), 'Debería encontrar la oficina por clase');
    //List<PricebookEntry> pbeList = (List<PricebookEntry>)resultWithClass[0];
    //Assert.areEqual('Oficina 101', pbeList[0].Product2.Name);
    
    //Assert.isFalse(resultNoClass.isEmpty(), 'Debería encontrar la oficina sin filtro de clase');
}

@isTest
static void testGetCustomSetting() {
    // 1. Configurar el Custom Setting (Jerárquico) a nivel de Organización
    ONI_cs_Cotizador__c setting = new ONI_cs_Cotizador__c(
        SetupOwnerId = UserInfo.getOrganizationId()
        // Añade aquí los campos específicos de tu Custom Setting si son necesarios
    );
    insert setting;

    Test.startTest();
    ONI_cs_Cotizador__c result = ONI_Cotizador_cls.getCustomSetting();
    Test.stopTest();

    Assert.areNotEqual(null, result, 'El Custom Setting no debería ser nulo');
}

@isTest
static void testGetConfiguration() {
    // 1. Crear registro de configuración personalizada
    ONI_obj_Configuracion__c config = new ONI_obj_Configuracion__c(
        ONI_fld_Configuracion_DescuentoMaximoIND__c = 10.5,
        ONI_fld_Configuracion_DescuentoMaximoOFI__c = 5.0,
        ONI_fld_Configuracion_EstPrecio__c = 175
    );
    insert config;

    Test.startTest();
    ONI_obj_Configuracion__c result = ONI_Cotizador_cls.getConfiguration();
    Test.stopTest();

    // 2. Validar que se recupere el registro más reciente
    Assert.areNotEqual(null, result, 'El registro de configuración no debería ser nulo');
    Assert.areEqual(10.5, result.ONI_fld_Configuracion_DescuentoMaximoIND__c);
}

@isTest
static void testGetConfigurationEmpty() {
    // Escenario donde no existen registros
    Test.startTest();
    ONI_obj_Configuracion__c result = ONI_Cotizador_cls.getConfiguration();
    Test.stopTest();

    Assert.areEqual(null, result, 'Debería retornar null si no hay registros configurados');
}

@isTest
static void testGetQuote() {
    // 1. Obtener datos de configuración previa (Oportunidad y Pricebook)
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Id standardPbId = Test.getStandardPricebookId();

    List<RecordType> rtProduct = [SELECT Id, Name FROM RecordType WHERE SobjectType ='Product2' AND Name LIKE '%Industrial%' LIMIT 1];
    
    // 2. Crear Producto y PricebookEntry
    Product2 prod = new Product2(
        Name = 'Lote Test QLI',
        CODLOTE__c = 'LOTE-001',
        RecordTypeId = rtProduct[0].Id,
        IsActive = true
    );
    insert prod;

    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = standardPbId,
        Product2Id = prod.Id,
        UnitPrice = 1000,
        IsActive = true
    );
    insert pbe;

    // 3. Crear Quote (Cotización)
    Quote qt = new Quote(
        Name = 'Cotizacion Test',
        OpportunityId = opp.Id,
        Pricebook2Id = standardPbId
    );
    insert qt;

    // 4. Crear QuoteLineItem (Partida de Cotización)
    QuoteLineItem qli = new QuoteLineItem(
        QuoteId = qt.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 1000,
        Product2Id = prod.Id
    );
    insert qli;

    Test.startTest();
    // Ejecutar el método para la oportunidad creada
    List<QuoteLineItem> results = ONI_Cotizador_cls.getQuote(opp.Id);
    
    // Caso de prueba para una oportunidad sin cotizaciones
    Id OrecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Oportunidad_Oficina')
        ?.getRecordTypeId();
        Id LrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Lead_Oficina')
        ?.getRecordTypeId();


    Opportunity oppSinQuote = new Opportunity(Name = 'Opp Sin Quote', StageName = 'Cotización', CloseDate = Date.today(),
    recordTypeId=OrecordTypeId,
        
        ONI_fld_Oportunidad_TipoRegistroInterno__c=LrecordTypeId
    
    );
    insert oppSinQuote;
    List<QuoteLineItem> resultsNull = ONI_Cotizador_cls.getQuote(oppSinQuote.Id);
    Test.stopTest();

    // 5. Verificaciones
    Assert.isNotNull(results, 'La lista no debería ser nula');
    Assert.isFalse(results.isEmpty(), 'Debería retornar al menos un QuoteLineItem');
    Assert.areEqual('LOTE-001', results[0].Product2.CODLOTE__c, 'El código de lote no coincide');
    Assert.isNull(resultsNull, 'Debería retornar null si la oportunidad no tiene cotizaciones');
}

}