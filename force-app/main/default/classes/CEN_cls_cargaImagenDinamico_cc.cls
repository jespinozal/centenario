/*
 * Name: CEN_cls_cargaImagenDinamico_cc
 * Version: 1.0
 * Descripción: controlador para cargar imagenes
 * Fecha: 30/10/2020
 * TestClass: CEN_cls_cargaImagenDinamico_test
*/
public with sharing class CEN_cls_cargaImagenDinamico_cc {
    public static final String ERROR_TITULO = 'Error carga archivo. ';
    public static final String ERROR_EXCEPCION_OCURRIDA = 'Ocurrió una excepción. ';    
    @AuraEnabled
    public static Response saveAttachment(Id parentId, String fileName, String base64Data, String contentType) {
        Response respuesta = new Response();
        try{
            Attachment attachment = new Attachment();
            attachment.parentId = parentId;
            attachment.body = EncodingUtil.base64Decode(base64Data);
            attachment.name = fileName;
            attachment.contentType = contentType;
            insert attachment;
            respuesta.ok = true;
        }
        catch(Exception e){
            respuesta.ok = false;
            respuesta.mensaje = ERROR_TITULO + ERROR_EXCEPCION_OCURRIDA;
            respuesta.detalle = respuesta.mensaje + e.getMessage();
        }
        return respuesta;
    }
    public class Response{
        @AuraEnabled public Boolean ok;
        @AuraEnabled public String mensaje;
        @AuraEnabled public String detalle;
        public Response(){
            this.ok = false;
            this.mensaje = '';
            this.detalle = '';
        }
    }
}