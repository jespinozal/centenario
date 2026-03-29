/*
 * Name: CEN_cls_utilsQuote_test
 * Version: 1.0
 * Descripción: clase test para el utils de cotizacion
 * Fecha: 8/11/2020
 * Class: CEN_cls_utilsQuote
 */
@isTest
public class CEN_cls_utilsQuote_test {
    @isTest
    public static void getDiccionario_LabelValue() {
        Map<String, String> diccionario = new Map<String, String>();
        Test.startTest();
        diccionario = CEN_cls_utilsQuote.getDiccionario_LabelValue(Quote.CEN_fld_tipoDocumento__c.getDescribe());
        Test.stopTest();
        System.assert(!diccionario.isEmpty());
    }
    @isTest
    public static void getDiccionario_ValueLabel() {
        Map<String, String> diccionario = new Map<String, String>();
        Test.startTest();
        diccionario = CEN_cls_utilsQuote.getDiccionario_ValueLabel(Quote.CEN_fld_tipoDocumento__c.getDescribe());
        Test.stopTest();
        System.assert(!diccionario.isEmpty());
    }
    @isTest
    public static void getListaTipoDocumentos() {
        CEN_cls_utilsQuote.ListatipoDocumentoWrapper listaDocumento = null;
        Test.startTest();
        listaDocumento = CEN_cls_utilsQuote.getListaTipoDocumentos();
        Test.stopTest();
        System.assert(!listaDocumento.tipoDocumentos.isEmpty());
    }
    @isTest
    public static void cambiarEstadoLote() {
        String estado = null;
        List<String> estados = new List<String>{'E','B','L','Q','C','R','F'};
        Test.startTest();
        for(String str : estados){
            estado = CEN_cls_utilsQuote.cambiarEstadoLote(str);
        }        
        Test.stopTest();
        System.assertNotEquals(NULL, estado);
    }
    @isTest
    public static void wrappers() {
        CEN_cls_utilsQuote.LoteCotizacionWrapper wrapper1 = null;
        CEN_cls_utilsQuote.LoteCotizacionWrapper wrapper2 = null;
        CEN_cls_utilsQuote.DatosPersonaWrapper personaWrapper = null;
        CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacionWrapper = null;

        Test.startTest();
        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U.11E';
        insert proyecto;

        Product2 producto = new Product2();
        producto.CODLOTE__c = '1818181';
        producto.Name = 'Lote 1';
        producto.MANZANA__c = 'Mz A1';
        producto.CODESTADOLOTE__c = 'L';
        producto.CEN_Proyecto__c = proyecto.Id;
        insert producto;

        CEN_ResponseContentVisorLotes contentLote = new CEN_ResponseContentVisorLotes();
        contentLote.Descripcionlote = producto.Name;
        contentLote.Manzana = producto.MANZANA__c;
        contentLote.Codlote = producto.CODLOTE__c;
        contentLote.Idproyecto = proyecto.CEN_CODIGOSAP__c;
        contentLote.Codestadolote = producto.CODESTADOLOTE__c;

        personaWrapper = new CEN_cls_utilsQuote.DatosPersonaWrapper();
        personaWrapper.nombres = 'Prueba';
        personaWrapper.apellidos = 'Prueba apellidos';
        personaWrapper.tipoDocumento = 'DNI';
        personaWrapper.nroDocumento = '76543210';
        personaWrapper.celular = '987654321';

        anotacionWrapper = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
        anotacionWrapper.key = 1;
        anotacionWrapper.fecha = Date.today();
        anotacionWrapper.monto = 100;
        anotacionWrapper.anotaciones = 'Probando anotacion';
        
        wrapper1 = new CEN_cls_utilsQuote.LoteCotizacionWrapper(producto);
        wrapper2 = new CEN_cls_utilsQuote.LoteCotizacionWrapper(contentLote, producto.Id);
        
        Test.stopTest();
        System.assertNotEquals(NULL, wrapper1);
        System.assertNotEquals(NULL, wrapper2);
        System.assertNotEquals(NULL, personaWrapper);
        System.assertNotEquals(NULL, anotacionWrapper);
    }
}