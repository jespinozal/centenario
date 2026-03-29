/*
 * Name: CEN_cls_logoProyecto_cc
 * Version: 1.0
 * Descripción: controlador para carga de imagenes de logo de proyecto
 * Fecha: 30/10/2020
 * TestClass: CEN_cls_logoProyecto_test
*/
public with sharing class CEN_cls_logoProyecto_cc {
    private static final String ERROR_PROYECTO_NO_TIENE_LOGO = 'No se encontró una imagen adjunta, por favor arrastrar a la sección de Logo. Subir una imagen: .png o .jpg y no debe pesar más de 15MB, con el siguiente tamaño: height: 80px y width: 50px.';
    private static final List<String> ARCHIVOS_PERMITIDOS = new List<String>{'image/png', 'image/jpeg', 'image/gif'};
    @AuraEnabled
    public static Response getLogoPicture(Id parentId) {
        Response resultado = new Response();
        Attachment  oAttachment=new Attachment();
        try{
            oAttachment = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
                           WHERE parentid=:ParentId AND ContentType IN :ARCHIVOS_PERMITIDOS
                           ORDER BY LastModifiedDate DESC LIMIT 1];            
        }catch(Exception  e){
            oAttachment =null;
            resultado.ok = false;
            resultado.logo = null;
            resultado.mensaje = ERROR_PROYECTO_NO_TIENE_LOGO;
            resultado.detalle = resultado.mensaje + e.getMessage();
        }
        if(oAttachment!=null){
            resultado.ok = true;
            resultado.logo = oAttachment;
        }
        return resultado;
    }
    public class Response{
        @AuraEnabled public Boolean ok;
        @AuraEnabled public String mensaje;
        @AuraEnabled public String detalle;
        @AuraEnabled public Attachment logo;
        public Response(){
            this.ok = false;
            this.mensaje = '';
            this.detalle = '';
            this.logo = null;
        }
    }
}