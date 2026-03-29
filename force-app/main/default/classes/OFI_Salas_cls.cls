public with sharing class OFI_Salas_cls {


    @AuraEnabled(cacheable=true)
    public static List<Object> getRooms(){

        List<PricebookEntry> pbe2List= new List<PricebookEntry>();
       
        
         pbe2List = [SELECT 
        Product2.Id,
        Product2.Name,
        Product2.CEN_IdLotSAP__c,
        Product2.CODLOTE__c,
        Product2.ONI_fld_Product_TipoObjetoAlquiler__c,
        Product2.ONI_fld_Producto_PrecioM2__c,
        Product2.CEN_PRECIOVENTAFUN__c,
        Product2.AREA__c,
        Product2.OFI_fld_Product2_BaseMedida__c,
        Product2.OFI_fld_Product2_IdSociedad__c,
        Product2.OFI_fld_Producto_NombreEdificio__r.ONI_fld_Proyecto_EdificioExternalId__c,
        Product2.OFI_fld_Product2_IdSAP__c,
        tolabel(Product2.OFI_fld_Product2_Estado__c)
        FROM PricebookEntry 
        WHERE  Product2.RecordType.DeveloperName='OFI_rt_Product2_Oficina' 
        AND isActive=true
        AND Product2.OFI_fld_Product2_Clase__c=19
        AND Product2.OFI_fld_Product2_Estado__c in ('L','Libre')
        WITH USER_MODE];




        

        return pbe2List;

    }

    /**
     * Retrieves available rooms and their booking status for a specific date.
     * @param selectedDateString The date selected by the user in the LWC (ISO 8601 format).
     * @return A list of RoomAvailability objects.
     */
    @AuraEnabled(cacheable=true)
    public static List<RoomAvailability> getAvailableRooms(String selectedDateString) {
        Date selectedDate;
        if(selectedDateString==null){
            selectedDate = Date.today();
        }else{
            selectedDate = Date.valueOf(selectedDateString);
        }
        
        DateTime startOfDay = DateTime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
        DateTime endOfDay = DateTime.newInstance(selectedDate.addDays(1), Time.newInstance(0, 0, 0, 0)).addSeconds(-1);

        // Fetch existing bookings for the selected date
        List<OFI_SalaReserva__c> existingBookings = [
            SELECT Id, OFI_fld_SalaReserva_Producto__c, OFI_fld_SalaReserva_Inicio__c, OFI_fld_SalaReserva_Fin__c, OFI_fld_SalaReserva_Tipo__c
            FROM OFI_SalaReserva__c
            WHERE OFI_fld_SalaReserva_Inicio__c >= :startOfDay AND OFI_fld_SalaReserva_Fin__c <= :endOfDay
        ];

        // Map to store room bookings by Room Id
        Map<Id, List<OFI_SalaReserva__c>> bookingsByRoomId = new Map<Id, List<OFI_SalaReserva__c>>();
        for (OFI_SalaReserva__c booking : existingBookings) {
            if (!bookingsByRoomId.containsKey(booking.OFI_fld_SalaReserva_Producto__c)) {
                bookingsByRoomId.put(booking.OFI_fld_SalaReserva_Producto__c, new List<OFI_SalaReserva__c>());
            }
            bookingsByRoomId.get(booking.OFI_fld_SalaReserva_Producto__c).add(booking);
        }

        // Fetch all available rooms (assuming a custom object 'OFI_Sala__c')
        List<OFI_Sala__c> allRooms = [SELECT Id, Name FROM OFI_Sala__c];
        List<RoomAvailability> results = new List<RoomAvailability>();

        // Check availability for each room
        for (OFI_Sala__c room : allRooms) {
            RoomAvailability ra = new RoomAvailability();
            ra.roomId = room.Id;
            ra.roomName = room.Name;
            ra.isFullDayBooked = false;
            ra.isHalfDayAMBooked = false;
            ra.isHalfDayPMBooked = false;

            if (bookingsByRoomId.containsKey(room.Id)) {
                for (OFI_SalaReserva__c booking : bookingsByRoomId.get(room.Id)) {
                    if (booking.OFI_fld_SalaReserva_Tipo__c == 'Full Day') {
                        ra.isFullDayBooked = true;
                        ra.isHalfDayAMBooked = true; // Full day covers both halves
                        ra.isHalfDayPMBooked = true;
                        break; // No need to check other bookings for this room if full day is booked
                    } else if (booking.OFI_fld_SalaReserva_Tipo__c == 'Half Day AM') {
                        ra.isHalfDayAMBooked = true;
                    } else if (booking.OFI_fld_SalaReserva_Tipo__c == 'Half Day PM') {
                        ra.isHalfDayPMBooked = true;
                    }
                }
            }
            results.add(ra);
        }

        return results;
    }

    /**
     * Inner class to represent the availability status of a room.
     */
    public class RoomAvailability {
        @AuraEnabled public Id roomId;
        @AuraEnabled public String roomName;
        @AuraEnabled public Boolean isFullDayBooked;
        @AuraEnabled public Boolean isHalfDayAMBooked;
        @AuraEnabled public Boolean isHalfDayPMBooked;
    }


    public static Quote createQuote(Id opportunityId,Map<String,Object> qData){
        Boolean opportunityRoot = false;
       if(opportunityId.getSObjectType() == Opportunity.SObjectType){
            
            opportunityRoot=true;
        }else{
            opportunityRoot=false;
        }
        System.debug(opportunityId);
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get('ONI_rt_Cotizacion_Sala')
        ?.getRecordTypeId();
        Pricebook2 pb2 ;
        pb2 = [SELECT Id FROM Pricebook2 WHERE Name='Oficinas' WITH USER_MODE LIMIT 1];
        List<Quote> qList; 
        if(opportunityRoot){
            qList = [SELECT Id,Name,OpportunityId,ONI_fld_Quote_Lead__c FROM Quote  WHERE OpportunityId=:opportunityId WITH USER_MODE ORDER BY Createddate DESC];
        }else{
            qList = [SELECT Id,Name,OpportunityId,ONI_fld_Quote_Lead__c FROM Quote  WHERE ONI_fld_Quote_Lead__c=:opportunityId WITH USER_MODE ORDER BY Createddate DESC];
        }

        Quote qn = null;
        if(qList.size()>0){
            qn=qList[0];
        }

       
        
        Quote q=null;
        if(qn==null){
        q = new Quote();
            q.Name='1';
            if(opportunityRoot){
            q.OpportunityId=opportunityId;
            }else{
                q.ONI_fld_Quote_Lead__c=opportunityId;
            }
            q.Pricebook2Id=pb2.Id;
            q.recordTypeId=recordTypeId;
            // q.ONI_fld_Quote_FormaPago__c=qData.get('typeSale');
            // q.IND_fld_Quote_MontoPagadoFirma__c=Decimal.valueOf(qData.get('directPayment'));
            // q.ONI_fld_Quote_FormaPago__c=qData.get('paymentMethod');
            // q.CEN_Area__c=Decimal.valueOf(qData.get('totalArea'));
            // q.IND_fld_Quote_MontoFraccionado__c=Decimal.valueOf(qData.get('installmentPayment'));
            // q.IND_fld_Quote_CantidadCuotasFraccionadas__c=Integer.valueOf(qData.get('installmentNumber'));
            // q.CEN_Saldo_del_precio__c=Integer.valueOf(qData.get('chunkPayment'));
            // q.CEN_N_cuotas_del_saldo_de_precio__c=qData.get('chunkNumber')!=null?Integer.valueOf(qData.get('chunkNumber')):null;
            // q.IND_fld_Quote_Tea__c=qData.get('chunkTEA')!=null?Integer.valueOf(qData.get('chunkTEA')):null;
            // q.CEN_Fecha_de_vencimiento__c=qData.get('chunkDate')!=null?Date.valueOf(qData.get('chunkDate')):null;
            // q.IND_fld_Cotizacion_Condiciones__c      =qData.get('conditions');
        }
        else{
            q = qn.clone(false, true, false, false);
            q.Name=String.valueOf(Integer.valueOf(q.Name)+1);
            if(opportunityRoot){
            q.OpportunityId=opportunityId;
            }else{
                q.ONI_fld_Quote_Lead__c=opportunityId;
            }

            q.Pricebook2Id=pb2.Id;
            q.recordTypeId=recordTypeId;
            // q.ONI_fld_Quote_FormaPago__c=qData.get('typeSale');
            // q.IND_fld_Quote_MontoPagadoFirma__c=qData.get('directPayment')!=null?Decimal.valueOf(qData.get('directPayment')):null;
            // q.ONI_fld_Quote_FormaPago__c=qData.get('paymentMethod');
            // q.CEN_Area__c=qData.get('totalArea')!=null?Decimal.valueOf(qData.get('totalArea')):null;
            // q.IND_fld_Quote_MontoFraccionado__c=qData.get('installmentPayment')!=null?Decimal.valueOf(qData.get('installmentPayment')):null;
            // q.IND_fld_Quote_CantidadCuotasFraccionadas__c=qData.get('installmentNumber')!=null?Integer.valueOf(qData.get('installmentNumber')):null;
            // q.CEN_Saldo_del_precio__c=qData.get('chunkPayment')!=null?Decimal.valueOf(qData.get('chunkPayment')):null;
            // q.CEN_N_cuotas_del_saldo_de_precio__c=qData.get('chunkNumber')!=null?Integer.valueOf(qData.get('chunkNumber')):null;
            // q.IND_fld_Quote_Tea__c=qData.get('chunkTEA')!=null?Integer.valueOf(qData.get('chunkTEA')):null;
            // q.CEN_Fecha_de_vencimiento__c=qData.get('chunkDate')!=null?Date.valueOf(qData.get('chunkDate')):null;
            // q.IND_fld_Cotizacion_Condiciones__c      =qData.get('conditions');
            
        }
        q.status='Accepted';
        
        //q.CEN_TypeOfSale__c=qData.get('typeSale');
        //if(q.CEN_TypeOfSale__c=='CO'){
        //    q.CEN_Monto_cuota_de_inicial_de_precio__c=Decimal.valueOf(qData.get('totalPayment'));
        //}
        q.IND_fld_Cotizacion_Condiciones__c=(String)qData.get('equipment');
        
        System.debug(q);
        Database.insert(q,AccessLevel.USER_MODE);
        return q;
    }

    /**
     * Creates a new room booking record.
     * @param roomId The ID of the room to book.
     * @param dateString The date of the booking.
     * @param bookingType The type of booking ('Full Day', 'Half Day AM', 'Half Day PM').
     */
    @AuraEnabled
    // public static void createBooking(Id roomId, String dateString,String startTime,String endTime) {
    public static void createBooking(List<Map<String,Object>> lm,Map<String,Object> qData) {
        System.debug(qData);
        Quote q = OFI_Salas_cls.createQuote((Id)qData.get('opportunityId'),qData);
        List<OFI_SalaReserva__c> srList = new List<OFI_SalaReserva__c>();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();

        List<Id> p2IdList =new List<Id>();
        for(Map<String,Object> l : lm){
            p2IdList.add((Id)l.get('roomId'));
        }

        List<PricebookEntry> pbeList = [SELECT Id,Product2.Id FROM PricebookEntry WHERE Product2.Id in :p2IdList WITH USER_MODE];
        Map<Id,Id> pbeMap = new Map<Id,Id>();
        for(PricebookEntry pbe:pbeList){
            pbeMap.put(pbe.Product2.Id,pbe.Id);
        }

        for(Map<String,Object> l : lm){
            System.debug(l);
            Date startDate = Date.valueOf((String)l.get('startDate'));
            Time startTime = Time.newInstance(Integer.valueOf(l.get('startTime')), 0, 0, 0);

            Time endTime = Time.newInstance(Integer.valueOf(l.get('endTime')), 0, 0, 0);
            OFI_SalaReserva__c sr = new OFI_SalaReserva__c(
                OFI_fld_SalaReserva_Producto__c = (String)l.get('roomId'),
                OFI_fld_SalaReserva_Inicio__c = DateTime.newInstance(startDate,startTime),
                OFI_fld_SalaReserva_Fin__c = DateTime.newInstance(startDate,endTime),
                ONI_fld_SalaReserva_Cotizacion__c = q.Id,
                OFI_fld_SalaReserva_Nombre__c = 'Reserva ' + l.get('roomName') +' '+ l.get('startDate') +' '+ l.get('startTime') +' '+ l.get('endTime') // Adjust 'Name' as needed
            );
            srList.add(sr);
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = q.Id;
            qli.Product2Id = (Id)l.get('roomId');
            qli.OFI_fld_QLI_Montaje__c=(String)l.get('officeSetup');
            qli.CEN_TotalPriceEspejo__c=Decimal.valueOf((String)l.get('totalAmount'));
            qli.UnitPrice = Decimal.valueOf((String)l.get('totalAmount'));
            qli.Quantity=1;
            qli.PricebookEntryId=pbeMap.get((Id)l.get('roomId'));
            qli.OFI_fld_QLI_FechaHoraEvento__c = DateTime.newInstance(startDate,startTime);
            qli.OFI_fld_QLI_FechaHoraFinEvento__c = DateTime.newInstance(startDate,endTime);
            // aquí faltarían los asistentes
            qliList.add(qli);
           
        }
        // Date selectedDate = Date.valueOf(dateString);
        // DateTime startTime;
        // DateTime endTime;
        // System.debug('Full:::'+bookingType);
        // System.debug('Half AM:::'+bookingType);
        // System.debug('Half PM:::'+bookingType);

        // // Define standard operating hours (e.g., 9 AM to 5 PM)
        // Time morningStart = Time.newInstance(9, 0, 0, 0);
        // Time morningEnd = Time.newInstance(12, 30, 0, 0);
        // Time afternoonStart = Time.newInstance(12, 30, 0, 0);
        // Time afternoonEnd = Time.newInstance(17, 0, 0, 0);

        // // if (bookingType == 'Full') {
        //     startTime = DateTime.newInstance(selectedDate, morningStart);
        //     endTime = DateTime.newInstance(selectedDate, afternoonEnd);
        // } else if (bookingType == 'Half AM') {
        //     startTime = DateTime.newInstance(selectedDate, morningStart);
        //     endTime = DateTime.newInstance(selectedDate, morningEnd);
        // } else if (bookingType == 'Half PM') {
        //     startTime = DateTime.newInstance(selectedDate, afternoonStart);
        //     endTime = DateTime.newInstance(selectedDate, afternoonEnd);
        // } else {
        //     throw new AuraHandledException('Invalid booking type specified.');
        // }

        // Check for conflicts (a full implementation would add robust conflict checking here)
        // List<OFI_SalaReserva__c> conflicts = [
        //     SELECT Id FROM OFI_SalaReserva__c
        //     WHERE OFI_fld_SalaReserva_Producto__c = :roomId
        //     AND (
        //         (OFI_fld_SalaReserva_Inicio__c >= :startTime AND OFI_fld_SalaReserva_Inicio__c < :endTime)
        //         OR (OFI_fld_SalaReserva_Fin__c > :startTime AND OFI_fld_SalaReserva_Fin__c <= :endTime)
        //         OR (OFI_fld_SalaReserva_Inicio__c < :startTime AND OFI_fld_SalaReserva_Fin__c > :endTime)
        //     )
        // ];

        // if (!conflicts.isEmpty()) {
        //     throw new AuraHandledException('The selected slot is already booked. Please refresh and check availability.');
        // }

        // // Create the new booking record
        // OFI_SalaReserva__c newBooking = new OFI_SalaReserva__c(
        //     OFI_fld_SalaReserva_Producto__c = roomId,
        //     OFI_fld_SalaReserva_Inicio__c = startTime,
        //     OFI_fld_SalaReserva_Fin__c = endTime,
        //     OFI_fld_SalaReserva_Tipo__c = bookingType,
        //     OFI_fld_SalaReserva_Nombre__c = 'Booking for ' + bookingType + ' on ' + dateString // Adjust 'Name' as needed
        // );

        Database.insert(srList,AccessLevel.USER_MODE);
        System.debug(qliList);
        Database.insert(qliList,AccessLevel.USER_MODE);
        Id opportunityId = (Id)qData.get('opportunityId');
        Boolean opportunityRoot = false;
       if(opportunityId.getSObjectType() == Opportunity.SObjectType){
            
            opportunityRoot=true;
        }else{
            opportunityRoot=false;
        }
        System.debug(opportunityId);


         if(opportunityRoot){
        Opportunity o = [SELECT Id,SyncedQuoteId FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        o.SyncedQuoteId=q.Id;
        //o.OFI_fld_Opportunity_Edificio__c=
        Database.update(o,AccessLevel.USER_MODE);
        }


        generatePDF(q.Id,opportunityId);
    }

    @AuraEnabled(cacheable=true)
    public static List<OFI_SalaReserva__c> getBookingsForMonth(String roomId, String startOfMonthString, String endOfMonthString) {
        Date startOfMonth = Date.valueOf(startOfMonthString);
        Date endOfMonth = Date.valueOf(endOfMonthString);

        List<OFI_SalaReserva__c> existingBookings = [
            SELECT Id, OFI_fld_SalaReserva_Producto__c, OFI_fld_SalaReserva_Inicio__c, OFI_fld_SalaReserva_Fin__c, OFI_fld_SalaReserva_Tipo__c, Name
            FROM OFI_SalaReserva__c
            WHERE OFI_fld_SalaReserva_Producto__c = :roomId
            AND OFI_fld_SalaReserva_Inicio__c >= :startOfMonth 
            AND OFI_fld_SalaReserva_Fin__c <= :endOfMonth
            ORDER BY OFI_fld_SalaReserva_Inicio__c ASC
        ];

        return existingBookings;
    }

    @AuraEnabled(cacheable=true)
    public static List<OFI_SalaReserva__c> getRoomAvailability(Id roomId, String selectedDateString) {
        if (roomId == null || selectedDateString == null) {
            throw new AuraHandledException('Room ID and Date must be provided.');
        }
        
        Date selectedDate = Date.valueOf(selectedDateString);
        DateTime startOfDay = DateTime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0));
        DateTime endOfDay = DateTime.newInstance(selectedDate.addDays(1), Time.newInstance(0, 0, 0, 0)).addSeconds(-1);

        // Fetch existing bookings for the selected room and date
        List<OFI_SalaReserva__c> existingBookings = [
            SELECT 
            Id, 
            OFI_fld_SalaReserva_Producto__c, 
            OFI_fld_SalaReserva_Inicio__c, 
            OFI_fld_SalaReserva_Fin__c, 
            OFI_fld_SalaReserva_Tipo__c
            FROM OFI_SalaReserva__c
            WHERE OFI_fld_SalaReserva_Producto__c = :roomId
            AND OFI_fld_SalaReserva_Inicio__c >= :startOfDay 
            AND OFI_fld_SalaReserva_Fin__c <= :endOfDay
        ];

        

        return existingBookings;

        // Fetch the room name (optional, but useful for the LWC display)
        //OFI_Sala__c room = [SELECT Id, Name FROM OFI_Sala__c WHERE Id = :roomId LIMIT 1];
        // Product2 room = [SELECT Id, Name FROM Product2 WHERE Id = :roomId LIMIT 1];

        // RoomAvailability ra = new RoomAvailability();
        // ra.roomId = room.Id;
        // ra.roomName = room.Name;
        // ra.isFullDayBooked = false;
        // ra.isHalfDayAMBooked = false;
        // ra.isHalfDayPMBooked = false;

        // // Check availability slots based on existing bookings
        // for (OFI_SalaReserva__c booking : existingBookings) {
        //     if (booking.OFI_fld_SalaReserva_Tipo__c == 'Full') {
        //         ra.isFullDayBooked = true;
        //         ra.isHalfDayAMBooked = true; 
        //         ra.isHalfDayPMBooked = true;
        //         break; // Room is fully booked, no need to check further
        //     } else if (booking.OFI_fld_SalaReserva_Tipo__c == 'Half AM') {
        //         ra.isHalfDayAMBooked = true;
        //     } else if (booking.OFI_fld_SalaReserva_Tipo__c == 'Half PM') {
        //         ra.isHalfDayPMBooked = true;
        //     }
        // }
        
        // // If both half-day slots are booked individually, mark full day as well
        // if (ra.isHalfDayAMBooked && ra.isHalfDayPMBooked) {
        //     ra.isFullDayBooked = true;
        // }

        // return ra;
    }

    @future(callout=true)
    public static void generatePDF(String idCotizacion, String idOportunidad) {
         //Requeridos para el trycatch
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        List<Attachment> listAttachments = new List<Attachment>();
        Blob pdfGenerado = null;

        PageReference pdfPage = (PageReference) Page.OFI_vf_PdfPlantillaCotizador_Sala;
        System.debug('Id');
        System.debug(idCotizacion);
        pdfPage.getParameters().put('Id', idCotizacion);

        System.debug('ql');
        List<Quote> ql = [SELECT Id, CreatedDate, AccountId, IND_fld_Cotizacion_Condiciones__c, CEN_Precio_de_venta__c, CEN_Precio_de_venta_con_descuento__c FROM Quote ORDER BY CreatedDate DESC LIMIT 2];
        System.debug(ql);
       
        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');}
            else {
                System.debug('togenerate');
                pdfGenerado = pdfPage.getContentAsPDF(); 
            }
            System.debug(pdfGenerado);
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idCotizacion;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }

            insert listAttachments;
        } catch (Exception e) {
            System.debug('No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' +e.getTypeName() + '. Line: ' +e.getLineNumber());
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' +e.getTypeName() + '. Line: ' +e.getLineNumber());
        }
    
    }
}