/*
 * Name: CEN_cls_logoProyecto_test
 * Version: 1.0
 * Descripción: test del controlador para carga de imagenes de logo de proyecto
 * Fecha: 30/10/2020
 * Class coverage: CEN_cls_logoProyecto_cc
*/
@isTest
public class CEN_cls_logoProyecto_test {
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
        
        Attachment attachment = new Attachment();
        attachment.parentId = proyectoDePrueba.Id;
        attachment.body = EncodingUtil.base64Decode(DATO_ATTACHMENT_BODY);
        attachment.name = DATO_ATTACHMENT_NAME;
        attachment.contentType = DATO_ATTACHMENT_CONTENT_TYPE;
        insert attachment;
    }
    /*
     * Validar que el proyecto tenga un logo => resultado sera != nulo y ok verdadero
     */
    @isTest
    public static void OK_getLogoPicture(){
        CEN_cls_logoProyecto_cc.Response resultado = null;
        Proyecto__c proyectoDePrueba = [SELECT Id FROM Proyecto__c LIMIT 1];
        Test.startTest();
        resultado = CEN_cls_logoProyecto_cc.getLogoPicture(proyectoDePrueba.Id);
        Test.stopTest();
        System.assert(resultado!=null);
        System.assert(resultado.ok);
    }
    /*
     * Validar que el proyecto NO tenga un logo => resultado sera != nulo y ok falso
     */
    @isTest
    public static void ERROR_getLogoPicture(){
        CEN_cls_logoProyecto_cc.Response resultado = null;
        Proyecto__c proyectoDePrueba = [SELECT Id FROM Proyecto__c LIMIT 1];
        Attachment oAttachment = [SELECT Id, Name, ContentType FROM Attachment 
                                  WHERE parentid=:proyectoDePrueba.Id AND ContentType=:DATO_ATTACHMENT_CONTENT_TYPE
                                  AND Name=:DATO_ATTACHMENT_NAME]; 
        delete oAttachment;
        Test.startTest();
        resultado = CEN_cls_logoProyecto_cc.getLogoPicture(proyectoDePrueba.Id);
        Test.stopTest();
        System.assert(resultado!=null);
        System.assert(!resultado.ok);
    }
}