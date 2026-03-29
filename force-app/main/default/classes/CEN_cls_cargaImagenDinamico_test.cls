/*
 * Name: CEN_cls_cargaImagenDinamico_test
 * Version: 1.0
 * Descripción: test del controlador para cargar imagenes
 * Fecha: 30/10/2020
 * Class coverage: CEN_cls_cargaImagenDinamico_cc
*/
@isTest
public class CEN_cls_cargaImagenDinamico_test {
    public static final String DATO_PROYECTO_AREA = '10000m2';
    public static final String DATO_PROYECTO_COD_INTERNO = '10U1.E12';
    public static final String DATO_PROYECTO_NAME = 'Urbanizaciones Centenario';
    public static final String DATO_ATTACHMENT_BODY = 'Imagen Centenario';
    public static final String DATO_ATTACHMENT_NAME = '2020-30-10-LogoCentenarioV1';
    public static final String DATO_ATTACHMENT_CONTENT_TYPE = 'image/jpeg';
    @testSetup
    public static void setup(){
        Proyecto__c proyectoDePrueba = new Proyecto__c();
        proyectoDePrueba.CEN_Area__c = DATO_PROYECTO_AREA;
        proyectoDePrueba.CEN_Cod_Interno_SAP__c = DATO_PROYECTO_COD_INTERNO;
        proyectoDePrueba.Name = DATO_PROYECTO_NAME;
        insert proyectoDePrueba;
    }
    /*
     * Validar que se pueda cargar una archivo => resultado sera != nulo y ok verdadero
     */
    @isTest
    public static void OK_saveAttachment(){
        CEN_cls_cargaImagenDinamico_cc.Response resultado = null;
        Proyecto__c proyectoDePrueba = [SELECT Id FROM Proyecto__c LIMIT 1];
        Test.startTest();
        resultado = CEN_cls_cargaImagenDinamico_cc.saveAttachment(proyectoDePrueba.Id, DATO_ATTACHMENT_NAME, DATO_ATTACHMENT_BODY, DATO_ATTACHMENT_CONTENT_TYPE);
        Test.stopTest();
        System.assert(resultado!=null);
        System.assert(resultado.ok);
    }
    /*
     * Validar que NO se pueda cargar un archivo => resultado sera != nulo y ok falso
     */
    @isTest
    public static void ERROR_saveAttachment(){
        CEN_cls_cargaImagenDinamico_cc.Response resultado = null;
        Test.startTest();
        resultado = CEN_cls_cargaImagenDinamico_cc.saveAttachment(null, DATO_ATTACHMENT_NAME, DATO_ATTACHMENT_BODY, DATO_ATTACHMENT_CONTENT_TYPE);
        Test.stopTest();
        System.assert(resultado!=null);
        System.assert(!resultado.ok);
    }
}