/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
public with sharing class CEN_CargaDocumentoOnbaseApi {
    //Response de Token
   @AuraEnabled public String Token;

    public static CEN_CargaDocumentoOnbaseApi parseToken(String json) {
        return (CEN_CargaDocumentoOnbaseApi) System.JSON.deserialize(json, CEN_CargaDocumentoOnbaseApi.class);
    }

    //Request de Envío de Documento
    public class documentoRequest{
        @AuraEnabled public String empresa_centenario;
        @AuraEnabled public String tipo_personeria;
        @AuraEnabled public String tipo_clausula;
        @AuraEnabled public String fecha_documento;
        @AuraEnabled public String urbanizacion;
        @AuraEnabled public String etapa;
        @AuraEnabled public String nro_finacimiento;
        @AuraEnabled public String clave_unica;
        @AuraEnabled public String tipo_documental;
        @AuraEnabled public List<PersonaJuridicaRequest> persona_juridica;
        @AuraEnabled public List<PersonaNaturalRequest>  persona_natural;
        @AuraEnabled public List<MzLoteRequest>          mz_lt;
        @AuraEnabled public String extension_archivo;
        @AuraEnabled public String docbase_64;
    }

    public class PersonaJuridicaRequest{
        @AuraEnabled public String razon_social     =   '';
        @AuraEnabled public String ruc              =   '';
    }

    public class PersonaNaturalRequest{
        @AuraEnabled public String nombre_apellido  =   '';
        @AuraEnabled public String tipo_documento   =   '';
        @AuraEnabled public String nro_documento    =   '';
    }
    
    public class MzLoteRequest{
        @AuraEnabled public String manzana;
        @AuraEnabled public String lote;
    }

    //Response de Envío de Documento
    public class documentoResponse{
        @AuraEnabled public String cod_respuesta;
        @AuraEnabled public String mensaje_error;
        @AuraEnabled public String idLog;

    }
    public static documentoResponse parseDocumento(String json) {
        return (documentoResponse) System.JSON.deserialize(json, documentoResponse.class);
    }
}