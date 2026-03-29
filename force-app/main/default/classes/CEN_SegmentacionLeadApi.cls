/**
 * @name               : CEN_SegmentacionLeadApi
 * @author             : Luis Maldonado
 * @creation date      : 13-01-2025
 * @description        : Clase que define las estructuras de datos para enviar solicitudes a Tannua y recibir respuestas.
 *                       Incluye métodos para deserializar tokens y respuestas.
 */
public with sharing class CEN_SegmentacionLeadApi {
    
    // Propiedad para el token Bearer (usada en pruebas o depuración)
    @AuraEnabled public String Bearer { get; set; }
    @TestVisible private static String tokenResponseOverride;
    public static Boolean isTestMode = false; // Bandera para tests

    // Método para deserializar un token de autenticación recibido de Tannua
    public static CEN_SegmentacionLeadApi parseToken(String json) {
        System.debug('Tamaño de JSON recibido: ' + json.length()); // Depuración: tamaño del JSON
        System.debug('Contenido del JSON: ' + json); // Depuración: contenido completo
        if (isTestMode) {
            // Retornar token simulado para tests
            CEN_SegmentacionLeadApi token = new CEN_SegmentacionLeadApi();
            token.access_token = 'test-access-token-123';
            token.Bearer = 'Bearer';
            token.token_type = 'Bearer';
            token.expires_in = 3600;
            token.ext_expires_in = 3600;
            System.debug('Token simulado para test: ' + token);
            return token;
        }
        
        
        
        // Convierte el JSON en un objeto CEN_SegmentacionLeadApi
        CEN_SegmentacionLeadApi token = (CEN_SegmentacionLeadApi) System.JSON.deserialize(json, CEN_SegmentacionLeadApi.class);
        
        // Verifica si el token se deserializó correctamente
        if (token != null && token.access_token != null) {
            System.debug('Token deserializado: ' + token.access_token.length());
        } else {
            System.debug('El token no se deserializó correctamente.');
        }
        
        return token; // Devuelve el objeto con el token
    }

    // Clase interna que define los campos enviados a Tannua en la solicitud
    public class SegmentacionRequest {
        // Campos del Lead que se envían a Tannua
        public Id idLead;                       // ID del Lead en Salesforce
        public String CEN_Tipo_de_documento;    // Tipo de documento (ej. DNI)
        public String CEN_N_mero_de_documento;  // Número de documento
        public Integer CEN_Longitud_de_documento; // Longitud del número de documento
        public Boolean CEN_LeadReactive;        // Indica si es un Lead reactivado
        public Boolean HasOptedOutOfEmail;      // Preferencia de no recibir emails
        public String CEN_Donde_comprar;        // Lugar de compra preferido
        public String CEN_Elige_donde_vivir;    // Preferencia de lugar de residencia
        public String CEN_Nacionalidad;         // Nacionalidad del Lead
        public String CEN_Formulario;           // Formulario de origen
        public String CEN_Medio;                // Medio de captación
        public String CEN_utm_source;           // Fuente UTM de marketing
        public String CEN_OrderOfPriority;      // Prioridad del Lead
        public Boolean CEN_AceptoEnvioPublicidad; // Consentimiento para publicidad
        public Boolean CEN_AceptoPerfilamiento;   // Consentimiento para perfilamiento
        public Boolean CEN_T_rminos_y_condiciones;// Aceptación de términos
        public String CEN_fecha_hora_de_creacion; // Fecha y hora de creación
        public String Status;                   // Estado del Lead
        public String Username;                 // Nombre del usuario que creó el Lead
    }

    // Clase interna que define la estructura de la respuesta de Tannua
    public class SegmetacionResponse {
        @AuraEnabled public String codigoOperacion; // Código de resultado (00 = éxito, otros = error)
        @AuraEnabled public String glosaOperacion;  // Descripción del resultado
    }

    // Método para deserializar la respuesta de segmentación de Tannua
    public static SegmetacionResponse parseSegmentacion(String json) {
        // Convierte el JSON en un objeto SegmetacionResponse
        return (SegmetacionResponse) System.JSON.deserialize(json, SegmetacionResponse.class);
    }

    // Propiedades para almacenar el token de autenticación recibido de Tannua
    public String token_type { get; set; }      // Tipo de token (ej. Bearer)
    public Integer expires_in { get; set; }     // Tiempo de expiración en segundos
    public Integer ext_expires_in { get; set; } // Tiempo de expiración extendido
    public String access_token { get; set; }    // Token de acceso para las solicitudes
}