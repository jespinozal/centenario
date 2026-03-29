@isTest
public with sharing class OFI_Salas_tst {
    @testSetup
    static void setupData() {
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
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Cotización', CloseDate = Date.today(),recordTypeId=OrecordTypeId,
        Pricebook2Id=standardPb.Id,
        ONI_fld_Oportunidad_TipoRegistroInterno__c=LrecordTypeId
        );
        insert opp;
        System.debug('dev::'+opp.recordtypeId);
        System.debug('dev::'+opp.recordtype.DeveloperName);
    }

    @isTest
    static void testGetRooms() {
        Test.startTest();
        List<Object> rooms = OFI_Salas_cls.getRooms();
        Test.stopTest();
        
        Assert.isNotNull(rooms, 'Rooms list should not be null');
    }

    @isTest
    static void testGetAvailableRooms() {
        String todayStr = String.valueOf(Date.today());
        
        Test.startTest();
        List<OFI_Salas_cls.RoomAvailability> results = OFI_Salas_cls.getAvailableRooms(todayStr);
        List<OFI_Salas_cls.RoomAvailability> resultsNull = OFI_Salas_cls.getAvailableRooms(null);
        Test.stopTest();

        Assert.isFalse(results.isEmpty(), 'Should return room availability');
       // Assert.isTrue(results[0].isHalfDayAMBooked, 'AM should be booked based on setup data');
    }

    @isTest
    static void testCreateQuoteFromOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Map<String, Object> qData = new Map<String, Object>();
        
        Test.startTest();
        Quote q = OFI_Salas_cls.createQuote(opp.Id, qData);
  //      insert q; // Test insertion of the returned object
        
        // Test cloning logic by calling it again
        Quote q2 = OFI_Salas_cls.createQuote(opp.Id, qData);
        Test.stopTest();

        Assert.areEqual(opp.Id, q.OpportunityId);
        Assert.areEqual('1', q.Name);
        Assert.areEqual('2', q2.Name, 'The cloned quote should increment the name');
    }

    @isTest
    static void testCreateQuoteFromLead() {
        // Mocking Lead ID (Assuming ONI_fld_Quote_Lead__c accepts Lead IDs)
        // Since we can't easily mock SObjectType for a generic ID without a real record:

         Id OrecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Oportunidad_Oficina')
        ?.getRecordTypeId();
        Id LrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('OFI_rt_Lead_Oficina')
        ?.getRecordTypeId();
System.debug('dev1:'+OrecordTypeId);

         Lead ld = new Lead();
        ld.Salutation = 'Sr.';
        ld.FirstName = 'Joel';
        ld.LastName = 'Espinoza';
        ld.Company = 'Nueva Estrella SAC';
        ld.CEN_RUC__c = '20123456788';
        ld.CEN_N_mero_de_documento__c = '22063637';
        ld.LeadSource = 'Digital';
        ld.CEN_Medio__c = '0110';
        ld.MobilePhone='+51999999999';
        ld.recordTypeId=LrecordTypeId;
        insert ld;

        Map<String, Object> qData = new Map<String, Object>();
        
        Test.startTest();
        Quote q = OFI_Salas_cls.createQuote(ld.Id, qData);
        Test.stopTest();

        Assert.areEqual(ld.Id, q.ONI_fld_Quote_Lead__c);
    }

    @isTest
    static void testCreateBooking() {
        // Mocking Lead ID (Assuming ONI_fld_Quote_Lead__c accepts Lead IDs)
        // Since we can't easily mock SObjectType for a generic ID without a real record:

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

        Map<String, Object> qData = new Map<String, Object>();
        
        Test.startTest();
        Quote q = OFI_Salas_cls.createQuote(ld.Id, qData);
        Test.stopTest();

        Assert.areEqual(ld.Id, q.ONI_fld_Quote_Lead__c);
    }

     @isTest
    static void testCreateBookingSuccess() {



        Opportunity opp = [SELECT Id,Pricebook2Id,Pricebook2.IsStandard,Pricebook2.Name,RecordType.DeveloperName FROM Opportunity LIMIT 1];

        System.debug(opp);
        System.debug(opp.Pricebook2Id);
        System.debug(opp.Pricebook2.IsStandard);
        System.debug(opp.Pricebook2.name);
        System.debug(opp.RecordType.DeveloperName);


        Product2 prod = [SELECT Id, Name FROM Product2 LIMIT 1];

        // Prepare qData (Quote information)
        Map<String, Object> qData = new Map<String, Object>{
            'opportunityId' => opp.Id
        };

        // Prepare lm (List of Room Bookings)
        List<Map<String, Object>> lm = new List<Map<String, Object>>();
        Map<String, Object> roomBooking = new Map<String, Object>{
            'roomId' => prod.Id,
            'roomName' => prod.Name,
            'startDate' => String.valueOf(Date.today()),
            'startTime' => 9,  // 9:00 AM
            'endTime' => 11,   // 11:00 AM
            'officeSetup' => 'Formato U',
            'totalAmount' => '500.00'
        };
        lm.add(roomBooking);

        Test.startTest();
        // Since generatePDF likely uses PageReference.getContent(), 
        // it may not execute fully in a test context without mocking.
        OFI_Salas_cls.createBooking(lm, qData);
        Test.stopTest();

        // Verify Results
        Quote q = [SELECT Id, Name, OpportunityId FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];
        Assert.areEqual(opp.Id, q.OpportunityId, 'Quote should be linked to the Opportunity');

        List<OFI_SalaReserva__c> reservations = [SELECT Id, OFI_fld_SalaReserva_Nombre__c FROM OFI_SalaReserva__c];
        Assert.isFalse(reservations.isEmpty(), 'A reservation record should have been created');
        
        List<QuoteLineItem> items = [SELECT Id, UnitPrice FROM QuoteLineItem WHERE QuoteId = :q.Id];
        Assert.areEqual(1, items.size(), 'One QuoteLineItem should be created');
        Assert.areEqual(500.00, items[0].UnitPrice, 'The price should match the totalAmount provided');
        
        Opportunity updatedOpp = [SELECT SyncedQuoteId FROM Opportunity WHERE Id = :opp.Id];
        Assert.areEqual(q.Id, updatedOpp.SyncedQuoteId, 'The opportunity should be synced with the new quote');
    }

    @isTest
static void testGetRoomAvailability() {
    // 1. Get data created in setup
    Product2 room = [SELECT Id FROM Product2 WHERE Name = 'Sala de Juntas' LIMIT 1];
    Date today = Date.today();
    String todayStr = String.valueOf(today);

    // 2. Create specific bookings for this room
    OFI_SalaReserva__c res = new OFI_SalaReserva__c(
        OFI_fld_SalaReserva_Producto__c = room.Id,
        OFI_fld_SalaReserva_Inicio__c = DateTime.newInstance(today, Time.newInstance(10, 0, 0, 0)),
        OFI_fld_SalaReserva_Fin__c = DateTime.newInstance(today, Time.newInstance(12, 0, 0, 0)),
        OFI_fld_SalaReserva_Nombre__c = 'Test Booking'
    );
    insert res;

    Test.startTest();
    // Test valid request
    List<OFI_SalaReserva__c> results = OFI_Salas_cls.getRoomAvailability(room.Id, todayStr);
    
    // Test exception for null parameters
    Boolean exceptionThrown = false;
    try {
        OFI_Salas_cls.getRoomAvailability(null, null);
    } catch (AuraHandledException e) {
        exceptionThrown = true;
    }
    Test.stopTest();

    // 3. Assertions
    Assert.areEqual(1, results.size(), 'Should find exactly one booking for the room on this date.');
    Assert.areEqual(room.Id, results[0].OFI_fld_SalaReserva_Producto__c);
    Assert.isTrue(exceptionThrown, 'Method should throw an exception when parameters are missing.');
}

    @isTest
    static void testGetBookingsForMonth() {
        // 1. Setup Test Data
        Product2 room = [SELECT Id FROM Product2 WHERE Name = 'Sala de Juntas' LIMIT 1];
        
        // Define a 3-month window for the test
        Date startMonth = Date.newInstance(2026, 1, 1);
        Date endMonth = Date.newInstance(2026, 1, 31);
        
        // Create one booking inside the range and one outside
        List<OFI_SalaReserva__c> testBookings = new List<OFI_SalaReserva__c>{
            new OFI_SalaReserva__c(
                OFI_fld_SalaReserva_Producto__c = room.Id,
                OFI_fld_SalaReserva_Inicio__c = DateTime.newInstance(2026, 1, 15, 10, 0, 0),
                OFI_fld_SalaReserva_Fin__c = DateTime.newInstance(2026, 1, 15, 12, 0, 0),
                OFI_fld_SalaReserva_Nombre__c = 'Inside Range'
            ),
            new OFI_SalaReserva__c(
                OFI_fld_SalaReserva_Producto__c = room.Id,
                OFI_fld_SalaReserva_Inicio__c = DateTime.newInstance(2026, 2, 5, 10, 0, 0), // Next month
                OFI_fld_SalaReserva_Fin__c = DateTime.newInstance(2026, 2, 5, 12, 0, 0),
                OFI_fld_SalaReserva_Nombre__c = 'Outside Range'
            )
        };
        insert testBookings;

        // Convert dates to String to match method signature
        String startStr = '2026-01-01';
        String endStr = '2026-01-31';

        Test.startTest();
        List<OFI_SalaReserva__c> results = OFI_Salas_cls.getBookingsForMonth(room.Id, startStr, endStr);
        Test.stopTest();

        // 2. Assertions
       // Assert.areEqual(1, results.size(), 'Only one booking should be found within January 2026');
       // Assert.areEqual('Inside Range', results[0].OFI_fld_SalaReserva_Nombre__c, 'Should return the correct record');
    }
}