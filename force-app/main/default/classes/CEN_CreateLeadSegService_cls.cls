/**
 * @name               : CEN_CreateLeadSegService_cls
 * @author             : Felipe Bermudez
 * @creation date      : 03-01-2025
 * @description        : Servicio REST que recibe datos segmentados de Tannua y crea registros en CEN_Lead_Data_Segmentation__c.
 * @versions           : 1.0 - Clase Apex inicial
 * @test class         : 
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-10-2024   Felipe Bermudez Initial Version
 */
@RestResource(urlMapping='/createLeadSegmentado/*')
global class CEN_CreateLeadSegService_cls {

    // Método HTTP POST para procesar las solicitudes de Tannua
    @HttpPost
    global static void doPost() {
        List<ResponseWrap> listResp = new List<ResponseWrap>(); // Lista de respuestas a enviar
        // Obtiene el cuerpo de la solicitud como texto JSON
        String jsonString = RestContext.request.requestBody.toString();
        // Deserializa el JSON en una lista de registros CEN_Lead_Data_Segmentation__c
        List<CEN_Lead_Data_Segmentation__c> prospectos = (List<CEN_Lead_Data_Segmentation__c>)JSON.deserialize(jsonString, List<CEN_Lead_Data_Segmentation__c>.class);
        
        try {
            // Valida cada registro recibido
            for (CEN_Lead_Data_Segmentation__c prospecto : prospectos) {
                // Verifica campos requeridos
                ResponseWrap resp = validateRequiredFields(prospecto);
                if (resp != null) {
                    listResp.add(resp);
                    sendResponse(listResp, 400); // Responde con error 400 si falla la validación
                    return;
                }

                // Verifica si el DNI ya existe (actualmente no hace nada con duplicados)
                resp = validateDniExistence(prospecto);
                if (resp != null) {
                    listResp.add(resp);
                    sendResponse(listResp, 400);
                    return;
                }
            }

            // Inserta los registros si todas las validaciones pasan
            insertLeads(prospectos, listResp);
        } catch (Exception e) {
            // Maneja errores inesperados
            ResponseWrap resp = new ResponseWrap('01', 'Error inesperado: ' + e.getMessage());
            listResp.add(resp);
            sendResponse(listResp, 400); // Responde con error 400
        }
    }

    // Método para validar campos requeridos en los registros recibidos
    private static ResponseWrap validateRequiredFields(CEN_Lead_Data_Segmentation__c prospecto) {
        if (String.isEmpty(prospecto.CEN_IdLead__c)) {
            return new ResponseWrap('01', 'requerido: CEN_IdLead__c');
        }
        if (String.isEmpty(prospecto.CEN_LDS_Tipo_de_documento__c)) {
            return new ResponseWrap('01', 'requerido: CEN_LDS_Tipo_de_documento__c');
        }
        if (String.isEmpty(prospecto.CEN_LDS_numero_documento__c)) {
            return new ResponseWrap('01', 'requerido: CEN_LDS_numero_documento__c');
        }
        return null; // Devuelve null si todos los campos requeridos están presentes
    }

    // Método para verificar si el DNI ya existe en el sistema
    private static ResponseWrap validateDniExistence(CEN_Lead_Data_Segmentation__c prospecto) {
        List<CEN_Lead_Data_Segmentation__c> existingLeads = [SELECT Id FROM CEN_Lead_Data_Segmentation__c 
                                                             WHERE CEN_LDS_numero_documento__c = :prospecto.CEN_LDS_numero_documento__c 
                                                             LIMIT 1];
        if (!existingLeads.isEmpty()) {
            return null; // No rechaza duplicados por ahora (podría ajustarse)
        }
        return null;
    }

    // Método para insertar los registros y preparar la respuesta
    private static void insertLeads(List<CEN_Lead_Data_Segmentation__c> prospectos, List<ResponseWrap> listResp) {
        // Inserta los registros, permitiendo fallos parciales
        List<Database.SaveResult> saveResults = Database.insert(prospectos, false);
        
        // Procesa los resultados de la inserción
        for (Database.SaveResult sr : saveResults) {
            Id idLead = sr.getId();
            ResponseWrap resp;
            if (sr.isSuccess()) {
                // Si la inserción es exitosa, responde con código 00
                resp = new ResponseWrap('00', 'OK', idLead);
                listResp.add(resp);
                sendResponse(listResp, 200); // Responde con éxito (200 OK)
            } else {
                // Si falla, incluye detalles del error
                resp = new ResponseWrap('01', 'Error al registrar en SF', idLead);
                for (Database.Error error : sr.getErrors()) {
                    resp.glosaOperacion += ' ' + error.getStatusCode() + ' - ' + error.getMessage();
                }
                listResp.add(resp);
                sendResponse(listResp, 400); // Responde con error (400 Bad Request)
            }
        }
    }

    // Método para enviar la respuesta HTTP en formato JSON
    private static void sendResponse(List<ResponseWrap> listResp, Integer statusCode) {
        RestContext.response.statusCode = statusCode; // Establece el código de estado HTTP
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(listResp)); // Serializa la respuesta
        RestContext.response.headers.put('Content-Type', 'application/json'); // Define el tipo de contenido
    }

    // Clase interna para estructurar las respuestas enviadas a Tannua
    global class ResponseWrap {
        public String codigoOperacion { get; set; } // Código de resultado (00 = éxito, 01 = error)
        public String glosaOperacion { get; set; }  // Mensaje descriptivo
        public String id { get; set; }              // ID del registro creado (si aplica)

        // Constructor para respuestas exitosas
        public ResponseWrap(String codigo, String glosa, String id) {
            this.codigoOperacion = codigo;
            this.glosaOperacion = glosa;
            this.id = id;
        }

        // Constructor para respuestas de error
        public ResponseWrap(String codigo, String glosa) {
            this.codigoOperacion = codigo;
            this.glosaOperacion = glosa;
        }
    }
}