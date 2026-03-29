/*
 * Name: CEN_cls_buscarCotizacionLibre_test
 * Version: 1.0
 * Descripción: clase test para la controladora CEN_cls_buscarCotizacionLibre_cc
 * Fecha: 8/11/2020
 * Class: CEN_cls_buscarCotizacionLibre_cc
 */
@isTest
public class CEN_cls_buscarCotizacionLibre_test {
    @TestSetup
    public static void setup(){
        Proyecto__c proyecto = CEN_cls_buscarCotizacionLibre_DF.getProyecto();
        insert proyecto;

        List<Product2> lotes = CEN_cls_buscarCotizacionLibre_DF.getProductos();
        for(Product2 lote : lotes){
            lote.CEN_Proyecto__c = proyecto.Id;
        }
        insert lotes;

        List<PricebookEntry> precioLotes = CEN_cls_buscarCotizacionLibre_DF.getPricebookEntrys();
        for(Integer i=0;i<precioLotes.size();i++){
            precioLotes[i].Product2Id = lotes[i].Id;
        }
        insert precioLotes;

        List<Account> clientes = CEN_cls_buscarCotizacionLibre_DF.getClientes();
        insert clientes;

        List<Opportunity> oportunidades = CEN_cls_buscarCotizacionLibre_DF.getOportunidades();
        for(Integer i=0;i<oportunidades.size();i++){
            oportunidades[i].AccountId = clientes[i].Id;
        }
        insert oportunidades;

        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = 
            CEN_cls_buscarCotizacionLibre_DF.getAnotaciones();

        Quote cotizacion = CEN_cls_buscarCotizacionLibre_DF.getCotizacionLibre();
        cotizacion.OpportunityId = oportunidades[0].Id;
        cotizacion.CEN_fld_anotaciones__c = JSON.serialize(anotaciones);
        insert cotizacion;

        List<QuoteLineItem> productosCotizacion = 
            CEN_cls_buscarCotizacionLibre_DF.getProductosCotizacion();
        for(Integer i=0;i<productosCotizacion.size();i++){
            productosCotizacion[i].PricebookEntryId = precioLotes[i].Id;
            productosCotizacion[i].Product2Id = lotes[i].Id;
            productosCotizacion[i].QuoteId = cotizacion.Id;
        }
        insert productosCotizacion;
    }
    
    @IsTest
    static void validateStageNameOpp_tst(){
        Test.startTest();
        Opportunity oportunidad = [Select id, stagename from Opportunity limit 1];
        oportunidad.StageName = 'Cotización';
        Update oportunidad;
        Boolean resp = false;
        resp = CEN_cls_buscarCotizacionLibre_cc.validateStageNameOpp(oportunidad.Id);
        System.assertEquals(true, resp);
        Test.stopTest();
    }
    
    @isTest
    public static void getListaTipoDocumentos() {
        CEN_cls_utilsQuote.ListatipoDocumentoWrapper response = null;
        Test.startTest();
        response = CEN_cls_buscarCotizacionLibre_cc.getListaTipoDocumentos();
        Test.stopTest();
        System.assertNotEquals(NULL, response);
    }
    @isTest
    public static void getDatosPersonaOportunidad() {
        CEN_cls_buscarCotizacionLibre_cc.InputBuscadorWrapper response = null;
        Account clientNoGenerico = [
            SELECT Id
            FROM Account
            WHERE CEN_Tipo_de_documento__pc = 'DNI' 
            AND CEN_N_mero_de_documento__pc = '74561230'
            LIMIT 1
        ];
        Opportunity oportunidad = [
            SELECT Id 
            FROM Opportunity 
            WHERE AccountId = :clientNoGenerico.Id
            LIMIT 1
        ];
        Test.startTest();
        response = CEN_cls_buscarCotizacionLibre_cc.getDatosPersonaOportunidad(oportunidad.Id);
        Test.stopTest();
        System.assertNotEquals(NULL, response);
    }
    @isTest
    public static void buscarRegistrosCotizacionesLibres() {
        CEN_cls_buscarCotizacionLibre_cc.ListaLotesLibresWrapper response = null;
        CEN_cls_buscarCotizacionLibre_cc.InputBuscadorWrapper objInputBuscadorWrapper = 
            new CEN_cls_buscarCotizacionLibre_cc.InputBuscadorWrapper();
        objInputBuscadorWrapper.nombres = 'Anonimo';
        objInputBuscadorWrapper.apellidos = 'Desconocido';
        objInputBuscadorWrapper.tipoDocumento = 'DNI';
        objInputBuscadorWrapper.nroDocumento = '76543210';
        objInputBuscadorWrapper.fechaCotizacion = Date.today();        
        String objInputBuscadorJSON = JSON.serialize(objInputBuscadorWrapper);
        Test.startTest();
        response = CEN_cls_buscarCotizacionLibre_cc.buscarRegistrosCotizacionesLibres(objInputBuscadorJSON);
        Test.stopTest();
        System.assertNotEquals(NULL, response);
    }
    @isTest
    public static void getLotesCotizacion() {
        CEN_cls_buscarCotizacionLibre_cc.ReponseLotesCotizacionWrapper response = null;
        String idCotizacion = [
            SELECT Id 
            FROM Quote 
            WHERE CEN_fld_Libre__c = true 
            LIMIT 1
        ].Id;
        Test.startTest();
        response = CEN_cls_buscarCotizacionLibre_cc.getLotesCotizacion(idCotizacion);
        Test.stopTest();
        System.assertNotEquals(NULL, response);
    }
    @isTest
    public static void validarLoteLibre() {
        List<CEN_cls_buscarCotizacionLibre_cc.ReponseLotesCotizacionWrapper> responses = 
            new List<CEN_cls_buscarCotizacionLibre_cc.ReponseLotesCotizacionWrapper>();
        List<Product2> lotes = [
            SELECT
              Id,
              Name,
              CODLOTE__c,
              CODESTADOLOTE__c,
              MANZANA__c,
              CEN_Proyecto__c,
              CEN_Proyecto__r.CEN_CODIGOSAP__c
            FROM Product2
        ];
        //  no requiere mock callout, usa HttpMockFactory class
        Test.startTest();
        for(Product2 lote : lotes){
            CEN_cls_buscarCotizacionLibre_cc.ReponseLotesCotizacionWrapper wrapper = 
                CEN_cls_buscarCotizacionLibre_cc.validarLoteLibre(
                    lote.Id, 
                    lote.CODLOTE__c, 
                    lote.CEN_Proyecto__r.CEN_CODIGOSAP__c, 
                    lote.MANZANA__c
                );
            responses.add(wrapper);
        }        
        Test.stopTest();
        System.assert(!responses.isEmpty());
    }
    @isTest
    public static void setCotizacionAoportunidad() {
        ResponseWrapper response = null;
        Account clientNoGenerico = [
            SELECT Id
            FROM Account
            WHERE CEN_Tipo_de_documento__pc = 'DNI' 
            AND CEN_N_mero_de_documento__pc = '74561230'
            LIMIT 1
        ];
        Opportunity oportunidad = [
            SELECT Id 
            FROM Opportunity 
            WHERE AccountId = :clientNoGenerico.Id
            LIMIT 1
        ];
        Quote cotizacion = [
            SELECT Id 
            FROM Quote 
            WHERE CEN_fld_Libre__c = true 
            LIMIT 1
        ];
        Test.startTest();
        response = CEN_cls_buscarCotizacionLibre_cc.setCotizacionAoportunidad(cotizacion.Id, oportunidad.Id);
        Test.stopTest();
        System.assertNotEquals(NULL, response);
    }
    
    @isTest
    public static void wrappers() {
        ResponseWrapper wrapper = new ResponseWrapper();
        Test.startTest();        
        wrapper.mensaje = 'Mensaje de prueba';
        wrapper.detalle = wrapper.mensaje;
        wrapper.ok = true;
        Test.stopTest();
        System.assert(wrapper.ok);
    }
}