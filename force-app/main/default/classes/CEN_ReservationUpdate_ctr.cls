/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-26
* @description: Clase de controladora para la generación de PDF del informe
*               de solicitud de modificación de reserva.
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-26           Alan Alvarez            Creación 
*  
*********************************************************************/
public with sharing class CEN_ReservationUpdate_ctr {
    
    public String writeToday;

    public List<CEN_SocietySAP__mdt> lstSociety;
    public String societyName;

    public Proyecto__c proyecto;
    public Attachment logoProyecto;
    
    public Opportunity oportunidads;
    public Account cliente;
    public String nroDocument;
    
    public List<CEN_PaymentOrder__c> lstPaymentOrder;
    public Double totalAmount = 0;

    public Quote cotizacion;
    public List<QuoteLineItem> lotesCotizados;

    public CEN_ReservationUpdate_ctr(
        ApexPages.StandardController controller
    ) {
        Id proyectoId = null;
        lstSociety = new List<CEN_SocietySAP__mdt>();
        proyecto = new Proyecto__c();
        logoProyecto = new Attachment();
        oportunidads = new Opportunity();
        cliente = new Account();
        lstPaymentOrder = new List<CEN_PaymentOrder__c>();
        cotizacion = new Quote();
        lotesCotizados = new List<QuoteLineItem>();

        //Fecha de HOY
        DateTime dt = Datetime.now();
        Integer day = dt.day();
        Integer month = dt.month();
        Integer year =dt.year();
        Map<Integer, String> spanishDates = new Map<Integer, String>();
        spanishDates.put(1, 'Enero');
        spanishDates.put(2, 'Febrero');
        spanishDates.put(3, 'Marzo');
        spanishDates.put(4, 'Abril');
        spanishDates.put(5, 'Mayo');
        spanishDates.put(6, 'Junio');
        spanishDates.put(7, 'Julio');
        spanishDates.put(8, 'Agosto');
        spanishDates.put(9, 'Septiembre');
        spanishDates.put(10, 'Octubre');
        spanishDates.put(11, 'Noviembre');
        spanishDates.put(12, 'Diciembre');
        writeToday = String.valueOf(day)+' de ' +spanishDates.get(month)+' de '+String.valueOf(year);
        
        //Get recordId
        Id recordId = controller.getRecord().Id;
        System.debug(LoggingLevel.INFO, recordId);

        lstSociety = [
            SELECT 
            DeveloperName, 
            Label 
            FROM CEN_SocietySAP__mdt
        ];
        System.debug(LoggingLevel.INFO, lstSociety);
         
        cotizacion = [
            SELECT
            Id,
            QuoteNumber,
            CreatedDate,
            toLabel(CEN_Moneda__c)
            FROM Quote
            WHERE OpportunityId = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.debug(LoggingLevel.INFO, cotizacion);
        
        oportunidads = [
            SELECT
            toLabel(CEN_Tipo_de_venta__c),
            CEN_Monto_Cuota_del_Saldo_de_precio__c,
            AccountId,
            toLabel(CEN_Moneda__c)
            FROM Opportunity
            WHERE Id = :recordId
        ];
        System.debug(LoggingLevel.INFO, oportunidads);

        cliente = [
            SELECT
            Name,
            Recordtype.DeveloperName,
            CEN_Tipo_de_documento__pc,
            CEN_Tipo_de_documento__c,
            CEN_N_mero_de_documento__pc,
            CEN_Numero_de_documento_del__c
            FROM Account
            WHERE Id = :oportunidads.AccountId
        ];
        System.debug(LoggingLevel.INFO, cliente);
        
        if(cliente.Recordtype.DeveloperName == 'PersonAccount'){
            nroDocument = cliente.CEN_Tipo_de_documento__pc + ' N° ' + cliente.CEN_N_mero_de_documento__pc; 
        }else{
            nroDocument = cliente.CEN_Tipo_de_documento__c + ' N° ' + cliente.CEN_Numero_de_documento_del__c; 
        }
        System.debug(LoggingLevel.INFO, nroDocument);

        lstPaymentOrder = [
            SELECT
            CEN_Amount__c, 
            CEN_Opportunity__c, 
            CEN_PaymentDate__c,
            CreatedDate,
            CEN_CurrencyCode__c
            FROM CEN_PaymentOrder__c
            WHERE CEN_Opportunity__c = :recordId
            AND (CEN_PaymentStatus__c = 'Pagado' OR CEN_PaymentStatus__c = 'PendienteSAP') 
            ORDER BY CEN_PaymentDate__c DESC
        ];
        System.debug(LoggingLevel.INFO, lstPaymentOrder);
        
        for(CEN_PaymentOrder__c p: lstPaymentOrder){
            totalAmount = totalAmount + p.CEN_Amount__c;
        }
        
        lotesCotizados = [
            SELECT
            Id,
            Product2Id,
            Product2.CEN_Proyecto__c,
            CEN_manzana_del_lote__c,
            CEN_lote__c,
            CEN_tipologia_del_lote__c,
            CEN_area_del_lote__c,
            CEN_fld_precioVentaDscto__c,
            CEN_precio_venta_cotizado_lote__c
            FROM QuoteLineItem
            WHERE QuoteId = :cotizacion.Id
            ORDER BY LineNumber ASC
        ];
        System.debug(LoggingLevel.INFO, lotesCotizados);
        for (QuoteLineItem qli : lotesCotizados) {
            if (qli.Product2Id != null && qli.Product2.CEN_Proyecto__c != null) {
                proyectoId = qli.Product2.CEN_Proyecto__c;
                break;
            }
        }

        proyecto = [
            SELECT Id, Name, CEN_Sociedad__c
            FROM Proyecto__c
            WHERE Id = :proyectoId
            LIMIT 1
        ];
        System.debug(LoggingLevel.INFO, proyecto);

        try {
            logoProyecto = [
                SELECT Id, Name, ParentId
                FROM Attachment
                WHERE ParentId = :proyectoId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
        } catch (Exception ex) {
            System.debug(
                LoggingLevel.ERROR,
                ex.getMessage() +
                '. ' +
                ex.getLineNumber()
            );
        }
        System.debug(LoggingLevel.INFO, logoProyecto);

        //GetSocietyName
        for(CEN_SocietySAP__mdt s: lstSociety){
            if(s.Label == proyecto.CEN_Sociedad__c){
                societyName = s.DeveloperName.replace('_',' ');
            }
        }
        System.debug(LoggingLevel.INFO, societyName);
    }

    public List<CEN_SocietySAP__mdt> getLstSociety(){
        System.debug(LoggingLevel.INFO, lstSociety);
        return this.lstSociety;
    }

    public String getSocietyName(){
        System.debug(LoggingLevel.INFO, societyName);
        return this.societyName;
    }
    
    public Double getTotalAmount(){
        System.debug(LoggingLevel.INFO, totalAmount);
        return this.totalAmount;
    }
    
    public String getWriteToday(){
        System.debug(LoggingLevel.INFO, writeToday);
        return this.writeToday;
    }
    
    public Attachment getLogoProyecto() {
        System.debug(LoggingLevel.INFO, logoProyecto);
        return this.logoProyecto;
    }
    public Proyecto__c getProyecto() {
        System.debug(LoggingLevel.INFO, proyecto);
        return this.proyecto;
    }
    
    public Opportunity getOportunidads() {
        System.debug(LoggingLevel.INFO, oportunidads);
        return this.oportunidads;
    }

    public Account getCliente() {
        System.debug(LoggingLevel.INFO, cliente);
        return this.cliente;
    }
    
    public String getNroDocument(){
        System.debug(LoggingLevel.INFO, nroDocument);
        return this.nroDocument;
    }
    
    public List<CEN_PaymentOrder__c> getLstPaymentOrder() {
        System.debug(LoggingLevel.INFO, lstPaymentOrder);
        return this.lstPaymentOrder;
    }
    
    public Quote getCotizacion() {
        System.debug(LoggingLevel.INFO, cotizacion);
        return this.cotizacion;
    }

    public List<QuoteLineItem> getLotesCotizados() {
        System.debug(LoggingLevel.INFO, lotesCotizados);
        return this.lotesCotizados;
    }
    
}