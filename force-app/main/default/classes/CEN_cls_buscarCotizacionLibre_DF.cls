/*
 * Name: CEN_cls_buscarCotizacionLibre_DF
 * Version: 1.0
 * Descripción: clase para generar datos 
 * Fecha: 8/11/2020
 * Class: CEN_cls_buscarCotizacionLibre_test
 */
@isTest
public class CEN_cls_buscarCotizacionLibre_DF {
    public static Proyecto__c getProyecto(){
        Proyecto__c objProyecto = new Proyecto__c();
        objProyecto.Name = 'Finca Bonita';
        objProyecto.CEN_CODIGOSAP__c  = '102U1.11';
        objProyecto.CEN_Etapa__c = 'Etapa 1';
        return objProyecto;  
    }
    public static List<Product2> getProductos() {
        List<Product2> lotes = new List<Product2>();
        Product2 lote1 = new Product2();
        lote1.Name = 'lote1 1';
        lote1.CODLOTE__c = '840001250';
        lote1.IsActive =true;
        lote1.DESCRIPCIONLOTE__c='Las Palmeras Etapa 2 Mz.O Lt.10';
        lote1.CODCOMPANIA__c='0010';
        lote1.CEN_Tiene_Reserva__c='No';
        lote1.CODESTADOLOTE__c = 'L';
        lote1.MANZANA__c = 'MZ A1';
        lote1.CEN_Proyecto__c = null;
        lote1.CEN_PRECIOVENTAFUN__c='15000';
        lotes.add(lote1);

        Product2 lote2 = new Product2();
        lote2.Name = 'lote2 1';
        lote2.CODLOTE__c = '840001258';
        lote2.IsActive =true;
        lote2.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.11';
        lote2.CODCOMPANIA__c='0010';
        lote2.CEN_Tiene_Reserva__c='No';
        lote2.CODESTADOLOTE__c = 'L';
        lote2.MANZANA__c = 'MZ A2';
        lote2.CEN_Proyecto__c = null;
        lote2.CEN_PRECIOVENTAFUN__c='10000';
        lotes.add(lote2);

        return lotes;
    }
    public static List<PricebookEntry> getPricebookEntrys() {
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> precioLotes = new List<PricebookEntry>();
        PricebookEntry entrada1 = new PricebookEntry();
        entrada1.Pricebook2Id = pricebookId;
        entrada1.UnitPrice = 100000;
        entrada1.IsActive=true;
        precioLotes.add(entrada1);

        PricebookEntry entrada2 = new PricebookEntry();
        entrada2.Pricebook2Id = pricebookId;
        entrada2.UnitPrice = 150000;
        entrada2.IsActive=true;
        precioLotes.add(entrada2);

        return precioLotes;
    }
    public static List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> getAnotaciones(){
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
        CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
        anotacion.key = 1;
        anotacion.fecha = Date.today();
        anotacion.monto = 1000;
        anotacion.anotaciones = 'Texto prueba';
        anotaciones.add(anotacion);
        return anotaciones;
    }
    public static List<QuoteLineItem> getProductosCotizacion(){
        List<QuoteLineItem> productosCotizacion = new List<QuoteLineItem>();
        QuoteLineItem obj1 = new QuoteLineItem();
        obj1.Quantity = 1;
        obj1.UnitPrice= 10;
        obj1.CEN_area_del_lote__c = 1;
        obj1.CEN_precio_venta_cotizado_lote__c = 1000;
        obj1.CEN_fld_precioVentaDscto__c = 1000;
        productosCotizacion.add(obj1);

        QuoteLineItem obj2 = new QuoteLineItem();
        obj2.Quantity = 1;
        obj2.UnitPrice= 10;
        obj2.CEN_area_del_lote__c = 1;
        obj2.CEN_precio_venta_cotizado_lote__c = 1000;
        obj2.CEN_fld_precioVentaDscto__c = 2000;
        productosCotizacion.add(obj2);

        return productosCotizacion;
    }
    public static List<Account> getClientes(){
        List<Account> clientes = new List<Account>();
        Account cuenta1 = new Account();
        cuenta1.FirstName = 'Cliente Generico';
        cuenta1.LastName = 'Apellido Generico';
        cuenta1.CEN_Tipo_de_documento__pc = 'DNI';
        cuenta1.CEN_N_mero_de_documento__pc = '76543210';
        clientes.add(cuenta1);

        Account cuenta2 = new Account();
        cuenta2.FirstName = 'Cliente 1';
        cuenta2.LastName = 'Apellido 1';
        cuenta2.CEN_Tipo_de_documento__pc = 'DNI';
        cuenta2.CEN_N_mero_de_documento__pc = '74561230';
        clientes.add(cuenta2);

        return clientes;
    }
    public static List<Opportunity> getOportunidades(){
        Id RecOppTypeId= [
            SELECT Id 
            FROM RecordType 
            WHERE (Name='Urbano') AND (SobjectType='Opportunity')
        ].Id;

        List<Opportunity> oportunidades = new List<Opportunity>();
        Opportunity oportunidad1 = new Opportunity();
        oportunidad1.Name='Oportunidad Generica';
        oportunidad1.RecordTypeId= RecOppTypeId;        
        oportunidad1.StageName='Cotizacion';
        oportunidad1.CloseDate=System.today().addMonths(1);
        oportunidades.add(oportunidad1);

        Opportunity oportunidad2 = new Opportunity();
        oportunidad2.Name='Oportunidad de cliente 1';
        oportunidad2.RecordTypeId= RecOppTypeId;        
        oportunidad2.StageName='Cotizacion';
        oportunidad2.CloseDate=System.today().addMonths(1);
        oportunidades.add(oportunidad2);

        return oportunidades;
    }
    public static Quote getCotizacionLibre(){
        Quote cotizacion = new Quote();        
        cotizacion.OpportunityId = null;
        cotizacion.Name = 'Cotizacion original';
        cotizacion.Pricebook2Id = Test.getStandardPricebookId();
        cotizacion.CEN_Area__c = 100;
        cotizacion.CEN_Precio_por_mt2__c = 12000;
        cotizacion.CEN_Precio_de_venta__c = 120000;
        cotizacion.CEN_Inicial__c = 5000;
        cotizacion.CEN_Cuota_inicial__c = 12;
        cotizacion.CEN_Inicial_porct__c = 20;
        cotizacion.CEN_N_cuotas_de_inicial_de_precio__c = 12;
        cotizacion.CEN_Monto_cuota_de_inicial_de_precio__c = 500;
        cotizacion.CEN_Saldo_del_precio__c = 23;
        cotizacion.CEN_Numero_de_cuotas_a_financiar__c = 25;
        cotizacion.CEN_N_cuotas_del_saldo_de_precio__c = 25;
        cotizacion.CEN_Tasa_de_Interes_compensatorio_anual__c = 23;
        cotizacion.CEN_Monto_cuota_del_saldo_de_precio__c = 12;
        cotizacion.CEN_Tipologia__c = 'Frente calle';
        cotizacion.CEN_Lote__c = 'Lote 1, Lote 2';
        cotizacion.CEN_Manzana__c = 'Mz A1, Mz A2';
        cotizacion.CEN_fld_Libre__c = true;
        cotizacion.CEN_Precio_de_venta_con_descuento__c = 120000;
        cotizacion.CEN_fld_anotaciones__c = null;
        cotizacion.CEN_fld_nombres__c = 'Anonimo';
        cotizacion.CEN_fld_apellidos__c = 'Desconocido';
        cotizacion.CEN_fld_tipoDocumento__c = 'DNI';
        cotizacion.CEN_fld_nroDocumento__c = '76543210';
        cotizacion.CEN_fld_celular__c = '987654321';
        cotizacion.CEN_fld_Cotizacion_Original__c = null;
        return cotizacion;
    }

}