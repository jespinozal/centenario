/**
 * @name               : CEN_SendLeadSegmentation
 * @author             : Luis Maldonado
 * @creation date      : 13-01-2025
 * @modification date  : 20-03-2025
 * @description        : Clase que envía datos de Leads a Tannua, actualiza el estado del envío y controla la lógica del botón manual.
 * @versions           : 1.0 - Versión inicial
 *                       1.1 - Agrega manejo de CEN_Estado_Envio_Tannua__c
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   13-01-2025   Luis Maldonado   Initial Version
 * 1.1   20-03-2025   Jesus Jaime      Added CEN_Estado_Envio_Tannua__c handling
 * 1.2   31-10-2025   Ayleen Salcedo   Se actualizó el client secret (IH48Q~_zWVOUDqlREVtuKyKvNVUjtj4ZT3LHlb7K)
 */
public class CEN_SendLeadSegmentation {
	
    @TestVisible private static CEN_SegmentacionLeadApi tokenOverride;
    @TestVisible private static String responseOverride;
    @TestVisible private static String tokenResponseOverride;
    
    // Método AuraEnabled para enviar un Lead a Tannua
    @AuraEnabled
    public static CEN_SegmentacionLeadApi.SegmetacionResponse SegmentacionLeadApi(String leadId) {
        CEN_SegmentacionLeadApi token = new CEN_SegmentacionLeadApi(); // Objeto para el token
        CEN_SegmentacionLeadApi.SegmentacionRequest request = new CEN_SegmentacionLeadApi.SegmentacionRequest(); // Objeto para la solicitud
        
        // Consulta los datos del Lead necesarios para enviar a Tannua
        Lead lead = [SELECT Id, CEN_Tipo_de_documento__c, CEN_N_mero_de_documento__c, CEN_Longitud_de_documento__c,
                            CEN_LeadReactive__c, HasOptedOutOfEmail, CEN_Donde_comprar__c, CEN_Elige_donde_vivir__c,
                            CEN_Nacionalidad__c, CEN_Formulario__c, CEN_Medio__c, CEN_utm_source__c,
                            CEN_OrderOfPriority__c, CEN_AceptoEnvioPublicidad__c, CEN_AceptoPerfilamiento__c,
                            CEN_T_rminos_y_condiciones__c, CEN_fecha_hora_de_creacion__c, Status, CreatedBy.Username
                     FROM Lead WHERE Id = :leadId];

        // Prepara los datos en un mapa para serializarlos a JSON
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('idLead', lead.Id);
        requestMap.put('CEN_Tipo_de_documento__c', lead.CEN_Tipo_de_documento__c);
        requestMap.put('CEN_N_mero_de_documento__c', lead.CEN_N_mero_de_documento__c);
        requestMap.put('CEN_Longitud_de_documento__c', lead.CEN_Longitud_de_documento__c);
        requestMap.put('CEN_LeadReactive__c', lead.CEN_LeadReactive__c);
        requestMap.put('HasOptedOutOfEmail', lead.HasOptedOutOfEmail);
        requestMap.put('CEN_Donde_comprar__c', lead.CEN_Donde_comprar__c);
        requestMap.put('CEN_Elige_donde_vivir__c', lead.CEN_Elige_donde_vivir__c);
        requestMap.put('CEN_Nacionalidad__c', lead.CEN_Nacionalidad__c);
        requestMap.put('CEN_Formulario__c', lead.CEN_Formulario__c);
        requestMap.put('CEN_Medio__c', lead.CEN_Medio__c);
        requestMap.put('CEN_utm_source__c', lead.CEN_utm_source__c);
        requestMap.put('CEN_OrderOfPriority__c', lead.CEN_OrderOfPriority__c);
        requestMap.put('CEN_AceptoEnvioPublicidad__c', lead.CEN_AceptoEnvioPublicidad__c);
        requestMap.put('CEN_AceptoPerfilamiento__c', lead.CEN_AceptoPerfilamiento__c);
        requestMap.put('CEN_T_rminos_y_condiciones__c', lead.CEN_T_rminos_y_condiciones__c);
        requestMap.put('CEN_fecha_hora_de_creacion__c', lead.CEN_fecha_hora_de_creacion__c);
        requestMap.put('Status', lead.Status);
        requestMap.put('Username', lead.CreatedBy.Username);

        // Convierte el mapa a JSON para enviarlo a Tannua
        String jsonRequest = JSON.serialize(requestMap);
        System.debug('jsonRequest: ' + jsonRequest); // Depuración: muestra el JSON enviado
        
        // Obtiene el token de autenticación para la llamada a Tannua
        token = getToken();
        if (token == null || token.access_token == null) {
            // Si no se obtiene el token, devuelve un error
            CEN_SegmentacionLeadApi.SegmetacionResponse resp = new CEN_SegmentacionLeadApi.SegmetacionResponse();
            resp.glosaOperacion = 'No se pudo obtener el token.';
            resp.codigoOperacion = '01';
            updateLeadStatus(leadId, 'Fallido'); // Actualiza el estado a "Fallido"
            return resp;
        }

        // Prepara el encabezado con el token Bearer
        Map<String, String> mapaHeaderToken = new Map<String, String>();
        mapaHeaderToken.put('Authorization', 'Bearer ' + token.access_token);

        CEN_SegmentacionLeadApi.SegmetacionResponse resp = new CEN_SegmentacionLeadApi.SegmetacionResponse(); // Objeto para la respuesta
        String respuesta; // Variable para almacenar la respuesta de Tannua

        try {
            // Configura y realiza la llamada HTTP a Tannua usando una clase auxiliar (CEN_Callout_cls)
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_SegLeadService');
            callApi.setRequestBody(jsonRequest); // Establece el cuerpo de la solicitud
            callApi.setTimeout(120000); // Tiempo máximo de espera (120 segundos)
            callApi.setHeaders(mapaHeaderToken); // Agrega el token al encabezado

            // Realiza la llamada solo si no es una prueba
            if (!Test.isRunningTest()) {
    			respuesta = (String) callApi.makeCallout().getParsedResponse();
            } else {
                respuesta = (responseOverride != null) ? responseOverride : '{"codigoOperacion":"01","glosaOperacion":"No se realizo la conexion"}';
            }
			
            // Deserializa la respuesta de Tannua
            resp = CEN_SegmentacionLeadApi.parseSegmentacion(respuesta);
            
            // Actualiza el estado del Lead según el resultado
            if (resp.codigoOperacion == '00') {
                updateLeadStatus(leadId, 'Exitoso'); // Éxito en el envío
            } else {
                updateLeadStatus(leadId, 'Fallido'); // Fallo en el envío
                System.debug('Error en Tannua: ' + resp.glosaOperacion);
            }
        } catch (Exception e) {
            // Maneja excepciones durante la llamada
            System.debug('Error en la llamada a Tannua: ' + e.getMessage());
            resp.glosaOperacion = 'Error en la conexión: ' + e.getMessage();
            resp.codigoOperacion = '01';
            updateLeadStatus(leadId, 'Fallido');
        }

        // Verifica si la respuesta es válida
        if (resp == null || resp.glosaOperacion == null) {
            resp.glosaOperacion = 'No se recibió respuesta válida del servicio.';
            updateLeadStatus(leadId, 'Fallido');
        }

        // Depuración: muestra la respuesta y el resultado
        System.debug('Respuesta del servicio: ' + respuesta);
        System.debug('Resultado del servicio: ' + resp);

        return resp; // Devuelve la respuesta al llamador
    }

    // Método auxiliar para actualizar el estado del Lead
    private static void updateLeadStatus(String leadId, String status) {
        Lead leadToUpdate = new Lead(Id = leadId, CEN_Estado_Envio_Tannua__c = status);
        try {
            update leadToUpdate; // Actualiza el campo CEN_Estado_Envio_Tannua__c
        } catch (DmlException e) {
            System.debug('Error al actualizar estado del Lead ' + leadId + ': ' + e.getMessage());
        }
    }

    // Método AuraEnabled para obtener el token de autenticación
    @AuraEnabled
    public static CEN_SegmentacionLeadApi getToken() {
        Map<String, String> body = new Map<String, String>(); // Mapa para el cuerpo (no usado aquí)
        // Consulta la configuración del servicio desde Custom Metadata
        CEN_AvailableWebservices__mdt mc = CEN_AvailableWebservices__mdt.getInstance('CEN_Segmentacion_Lead_Token');
        // Cuerpo de la solicitud con credenciales hardcodeadas (debería parametrizarse en producción)
        //String jsonRequest = 'grant_type=client_credentials&client_id=43f3b921-7ebf-402e-8478-9de170b9162e&client_secret=zeO8Q~IvdssDBuo-D~d-vywi3TL.reYNHn4qBa6Z&scope=api://43f3b921-7ebf-402e-8478-9de170b9162e/.default';
        String jsonRequest = 'grant_type=client_credentials&client_id=ae86f512-ac47-4816-825d-d90e160550e9&client_secret=IH48Q~_zWVOUDqlREVtuKyKvNVUjtj4ZT3LHlb7K&scope=api://ae86f512-ac47-4816-825d-d90e160550e9/.default';
        String respuesta;
        CEN_SegmentacionLeadApi resp;

        try {
            // Configura y realiza la llamada para obtener el token
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Segmentacion_Lead_Token');
            callApi.setRequestBody(jsonRequest);
            callApi.setTimeout(120000);

            if (!Test.isRunningTest()) {
                respuesta = (String) callApi.makeCallout().getParsedResponse();
            } else {
                // Respuesta simulada para pruebas
                respuesta = '{"access_token":"test-access-token-123","token_type":"Bearer","expires_in":3600,"ext_expires_in":3600}';
            }
            resp = CEN_SegmentacionLeadApi.parseToken(respuesta); // Deserializa el token
        } catch (Exception e) {
            // Maneja errores en la obtención del token
            System.debug('Error al obtener token: ' + e.getMessage());
            resp = new CEN_SegmentacionLeadApi();
            resp.token_type = 'Error';
            resp.access_token = 'No se pudo obtener el token';
        }

        // Depuración: muestra la respuesta y el token
        System.debug('Respuesta del token: ' + respuesta);
        System.debug('Token obtenido: ' + resp);
        return resp;
    }
    
    // Método AuraEnabled para determinar si el botón manual debe estar habilitado
    @AuraEnabled
    public static Boolean validarDni(String idLead) {
        Boolean respuesta = false;
        
        // Consulta el Lead para verificar su estado y DNI
        Lead leadRecord = [SELECT CEN_N_mero_de_documento__c, CEN_Estado_Envio_Tannua__c 
                          FROM Lead 
                          WHERE Id = :idLead 
                          LIMIT 1];
        
        // Si el DNI no está vacío, evalúa las condiciones
        if (String.isNotBlank(leadRecord.CEN_N_mero_de_documento__c)) {
            if (leadRecord.CEN_Estado_Envio_Tannua__c == 'Fallido') {
                // Habilita el botón si el envío a Tannua falló
                respuesta = true;
            } else if (leadRecord.CEN_Estado_Envio_Tannua__c == 'Exitoso') {
                // Si el envío fue exitoso, verifica el estado de la segmentación más reciente
                List<CEN_Lead_Data_Segmentation__c> segmentations = [SELECT Id, CEN_LDS_estado__c 
                                                                    FROM CEN_Lead_Data_Segmentation__c 
                                                                    WHERE CEN_IdLead__c = :idLead 
                                                                    ORDER BY CreatedDate DESC 
                                                                    LIMIT 1];
                if (!segmentations.isEmpty()) {
                    // Habilita el botón si la segmentación tiene un error
                    respuesta = (segmentations[0].CEN_LDS_estado__c == 'ERROR');
                }
            }
            // Si está en "Pendiente", no habilita el botón
        }
        
        return respuesta; // Devuelve true si el botón debe habilitarse
    }

    // Método asíncrono para procesar Leads enviados a Tannua
    @future(callout=true)
    public static void processLeadSegmentationAsync(Set<Id> leadIds) {
        // Recorre los IDs de Leads y envía cada uno a Tannua
        for (Id leadId : leadIds) {
            CEN_SegmentacionLeadApi.SegmetacionResponse response = SegmentacionLeadApi(leadId);
            // El estado se actualiza dentro de SegmentacionLeadApi
            if (response.codigoOperacion != '00') {
                System.debug('Error al segmentar Lead ' + leadId + ': ' + response.glosaOperacion);
            }
        }
    }
}