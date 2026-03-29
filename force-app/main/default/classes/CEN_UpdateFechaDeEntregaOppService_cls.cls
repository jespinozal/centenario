/**
 * @name               : CEN_UpdateFechaDeEntregaOppService_cls
 * @author             : Felipe Bermudez
 * @creation date      : 09-05-2025
 * @description        : Servicio REST que actualiza fecha de entrega lote en la oportunidad
 * @versions           : 1.0 - Clase Apex inicial
 * @test class         : 
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   09-05-2025   Felipe Bermudez Initial Version
 * 1.0   21-05-2025   Felipe Bermudez se agregaron interlocutores1,2,3,4,5,6,7,8,9,10 (Validaciones de errores)
 * 1.0   25-09-2025   Felipe Bermudez se agregaron InterlocutoresEmail 1,2,3,4,5,6,7,8,9,10 y titular (Validaciones de errores)
 */
@RestResource(urlMapping='/updateFechaDeEntregaOpp/*')
global with sharing class CEN_UpdateFechaDeEntregaOppService_cls {
    @HttpPost
    global static void doPost() {
        List<ResponseWrap> listResp = new List<ResponseWrap>();
        String bodyRequestCsv = RestContext.request.requestBody.toString();

        try {
            // Validar CSV
            if (String.isBlank(bodyRequestCsv)) {
                listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('CSV vacío')}, 'Error: CSV vacío.', 'ERROR'));
                sendResponse(listResp, 200);
                return;
            }

            // Dividir en líneas
            List<String> lines = bodyRequestCsv.split('\r\n');
            if (lines.size() < 2) {
                listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('CSV sin datos')}, 'Error: CSV sin datos válidos.', 'ERROR'));
                sendResponse(listResp, 200);
                return;
            }

            // Validar encabezados
            String[] headers = lines[0].split(';');
            if (!validateHeaders(headers, listResp)) {
                sendResponse(listResp, 200);
                return;
            }

            // Procesar datos
            Map<String, UpdateWrapper> updates = processCsvData(lines, headers, listResp);
            if (updates == null) {
                sendResponse(listResp, 200);
                return;
            }

            // Buscar oportunidades (solo Oportunidad Ganada)
            List<Opportunity> oppsToUpdate = [
                SELECT Id, CEN_Proforma__c, StageName, CEN_Fecha_Entrega_Lote__c, 
                       CEN_Fecha_EntregaLote_Espejo__c, LastModifiedDate,
                       CEN_INTERLOCUTOR_1__c, CEN_INTERLOCUTOR_2__c, CEN_INTERLOCUTOR_3__c, 
                       CEN_INTERLOCUTOR_4__c, CEN_INTERLOCUTOR_5__c, CEN_INTERLOCUTOR_6__c, 
                       CEN_INTERLOCUTOR_7__c, CEN_INTERLOCUTOR_8__c, CEN_INTERLOCUTOR_9__c, 
                       CEN_INTERLOCUTOR_10__c, CEN_TITULAR__c, CEN_TITULAR_EMAIL__c,
                       CEN_INTERLOCUTOR_1_EMAIL__c, CEN_INTERLOCUTOR_2_EMAIL__c, 
                       CEN_INTERLOCUTOR_3_EMAIL__c, CEN_INTERLOCUTOR_4_EMAIL__c, 
                       CEN_INTERLOCUTOR_5_EMAIL__c, CEN_INTERLOCUTOR_6_EMAIL__c, 
                       CEN_INTERLOCUTOR_7_EMAIL__c, CEN_INTERLOCUTOR_8_EMAIL__c, 
                       CEN_INTERLOCUTOR_9_EMAIL__c, CEN_INTERLOCUTOR_10_EMAIL__c
                FROM Opportunity 
                WHERE CEN_Proforma__c IN :updates.keySet() 
                AND StageName = 'Oportunidad Ganada'
            ];

            // Depuración: Mostrar las oportunidades encontradas
            for (Opportunity opp : oppsToUpdate) {
                System.debug('Proforma: ' + opp.CEN_Proforma__c + ', StageName: ' + opp.StageName + ', Id: ' + opp.Id + ', LastModifiedDate: ' + opp.LastModifiedDate);
            }

            // Detectar duplicados
            Map<String, List<Opportunity>> proformaToOppsMap = new Map<String, List<Opportunity>>();
            for (Opportunity opp : oppsToUpdate) {
                if (!proformaToOppsMap.containsKey(opp.CEN_Proforma__c)) {
                    proformaToOppsMap.put(opp.CEN_Proforma__c, new List<Opportunity>());
                }
                proformaToOppsMap.get(opp.CEN_Proforma__c).add(opp);
            }

            // Mapa para traducir números de mes a nombres en español
            Map<Integer, String> monthTranslation = new Map<Integer, String>{
                1 => 'enero', 2 => 'febrero', 3 => 'marzo', 4 => 'abril', 5 => 'mayo', 
                6 => 'junio', 7 => 'julio', 8 => 'agosto', 9 => 'septiembre', 
                10 => 'octubre', 11 => 'noviembre', 12 => 'diciembre'
            };

            // Actualizar oportunidades existentes
            List<Opportunity> validOppsToUpdate = new List<Opportunity>();
            List<ProformaError> errorProformas = new List<ProformaError>();
            for (String proforma : updates.keySet()) {
                if (proformaToOppsMap.containsKey(proforma)) {
                    List<Opportunity> opps = proformaToOppsMap.get(proforma);
                    Opportunity oppToUpdate = null;
                    if (opps.size() > 1) {
                        // Seleccionar la oportunidad con LastModifiedDate más reciente
                        for (Opportunity opp : opps) {
                            if (oppToUpdate == null || opp.LastModifiedDate > oppToUpdate.LastModifiedDate) {
                                oppToUpdate = opp;
                            }
                        }
                        System.debug('Duplicados para ' + proforma + ', seleccionando Id: ' + oppToUpdate.Id + ', LastModifiedDate: ' + oppToUpdate.LastModifiedDate);
                    } else {
                        oppToUpdate = opps[0];
                    }
                    UpdateWrapper updateData = updates.get(proforma);
                    try {
                        if (!String.isBlank(updateData.fechaEntrega)) {
                            oppToUpdate.CEN_Fecha_Entrega_Lote__c = Date.valueOf(updateData.fechaEntrega);

                            // Actualizar campo espejo con formato en español
                            Date fecha = oppToUpdate.CEN_Fecha_Entrega_Lote__c;
                            String day = String.valueOf(fecha.day());
                            String month = monthTranslation.get(fecha.month());
                            String year = String.valueOf(fecha.year());
                            oppToUpdate.CEN_Fecha_EntregaLote_Espejo__c = day + ' de ' + month + ' de ' + year;
                        }

                        // Asignar los interlocutores y sus emails
                        oppToUpdate.CEN_INTERLOCUTOR_1__c = updateData.interlocutor1;
                        oppToUpdate.CEN_INTERLOCUTOR_2__c = updateData.interlocutor2;
                        oppToUpdate.CEN_INTERLOCUTOR_3__c = updateData.interlocutor3;
                        oppToUpdate.CEN_INTERLOCUTOR_4__c = updateData.interlocutor4;
                        oppToUpdate.CEN_INTERLOCUTOR_5__c = updateData.interlocutor5;
                        oppToUpdate.CEN_INTERLOCUTOR_6__c = updateData.interlocutor6;
                        oppToUpdate.CEN_INTERLOCUTOR_7__c = updateData.interlocutor7;
                        oppToUpdate.CEN_INTERLOCUTOR_8__c = updateData.interlocutor8;
                        oppToUpdate.CEN_INTERLOCUTOR_9__c = updateData.interlocutor9;
                        oppToUpdate.CEN_INTERLOCUTOR_10__c = updateData.interlocutor10;
                        oppToUpdate.CEN_TITULAR__c = updateData.titular;
                        oppToUpdate.CEN_TITULAR_EMAIL__c = updateData.titularEmail;
                        oppToUpdate.CEN_INTERLOCUTOR_1_EMAIL__c = updateData.interlocutor1Email;
                        oppToUpdate.CEN_INTERLOCUTOR_2_EMAIL__c = updateData.interlocutor2Email;
                        oppToUpdate.CEN_INTERLOCUTOR_3_EMAIL__c = updateData.interlocutor3Email;
                        oppToUpdate.CEN_INTERLOCUTOR_4_EMAIL__c = updateData.interlocutor4Email;
                        oppToUpdate.CEN_INTERLOCUTOR_5_EMAIL__c = updateData.interlocutor5Email;
                        oppToUpdate.CEN_INTERLOCUTOR_6_EMAIL__c = updateData.interlocutor6Email;
                        oppToUpdate.CEN_INTERLOCUTOR_7_EMAIL__c = updateData.interlocutor7Email;
                        oppToUpdate.CEN_INTERLOCUTOR_8_EMAIL__c = updateData.interlocutor8Email;
                        oppToUpdate.CEN_INTERLOCUTOR_9_EMAIL__c = updateData.interlocutor9Email;
                        oppToUpdate.CEN_INTERLOCUTOR_10_EMAIL__c = updateData.interlocutor10Email;
                        validOppsToUpdate.add(oppToUpdate);
                    } catch (Exception e) {
                        System.debug('Error procesando proforma ' + proforma + ': ' + e.getMessage());
                        errorProformas.add(new ProformaError(proforma + ' - Error: ' + e.getMessage()));
                    }
                }
            }

            // Validar proformas no encontradas o con StageName incorrecto
            Set<String> foundProformas = new Set<String>(proformaToOppsMap.keySet());
            for (String proforma : updates.keySet()) {
                if (!foundProformas.contains(proforma)) {
                    List<Opportunity> existingOpps = [
                        SELECT CEN_Proforma__c, StageName 
                        FROM Opportunity 
                        WHERE CEN_Proforma__c = :proforma 
                        LIMIT 1
                    ];
                    if (existingOpps.isEmpty()) {
                        errorProformas.add(new ProformaError(proforma + ' - No existe en Salesforce'));
                    } else {
                        errorProformas.add(new ProformaError(proforma + ' - StageName: ' + existingOpps[0].StageName));
                    }
                }
            }

            // Ejecutar actualizaciones
            Integer updatedCount = 0;
            if (!validOppsToUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(validOppsToUpdate, false);
                for (Database.SaveResult sr : updateResults) {
                    if (!sr.isSuccess()) {
                        String proforma = validOppsToUpdate[updateResults.indexOf(sr)].CEN_Proforma__c;
                        String errorMsg = 'Error al actualizar ' + proforma + ': ';
                        for (Database.Error err : sr.getErrors()) {
                            errorMsg += err.getMessage() + '; ';
                        }
                        errorProformas.add(new ProformaError(proforma + ' - ' + errorMsg));
                        listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError(proforma)}, errorMsg, 'ERROR'));
                    } else {
                        updatedCount++;
                    }
                }
            }

            // Respuesta
            String errorMsg = errorProformas.isEmpty() ? '' : 'No se actualizaron todas las proformas. Detalles en Proformas_con_error.';
            String estado = errorProformas.isEmpty() && updatedCount > 0 ? 'OK' : 'ERROR';
            listResp.add(new ResponseWrap(updatedCount, errorProformas, errorMsg, estado));
            sendResponse(listResp, 200);
        } catch (Exception e) {
            System.debug('Error general: ' + e.getMessage());
            listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Error general: ' + e.getMessage())}, 'Error: ' + e.getMessage(), 'ERROR'));
            sendResponse(listResp, 200);
        }
    }

    private static Map<String, UpdateWrapper> processCsvData(List<String> lines, String[] headers, List<ResponseWrap> listResp) {
        Map<String, UpdateWrapper> updates = new Map<String, UpdateWrapper>();
        for (Integer i = 1; i < lines.size(); i++) {
            String[] fields = lines[i].split(';', -1);
            if (fields.size() != 24) {
                listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Línea ' + i)}, 'Error: Línea ' + i + ' con formato incorrecto.', 'ERROR'));
                return null;
            }
            // Validar interlocutores (índices 2 a 11)
            for (Integer j = 2; j <= 11; j++) {
                String interlocutor = String.isBlank(fields[j]) ? null : fields[j];
                if (interlocutor != null && interlocutor.length() > 50) {
                    listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Línea ' + i)}, 
                        'Error: ' + headers[j] + ' en línea ' + i + ' excede 50 caracteres.', 'ERROR'));
                    return null;
                }
            }
            // Validar CEN_TITULAR__c (índice 12, max 255 caracteres)
            if (!String.isBlank(fields[12]) && fields[12].length() > 255) {
                listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Línea ' + i)}, 
                    'Error: CEN_TITULAR__c en línea ' + i + ' excede 255 caracteres.', 'ERROR'));
                return null;
            }
            // Validar emails (índices 13 y 14-23)
            for (Integer j = 13; j <= 23; j++) {
                String email = String.isBlank(fields[j]) ? null : fields[j];
                if (email != null) {
                    if (email.length() > 80) {
                        listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Línea ' + i)}, 
                            'Error: ' + headers[j] + ' en línea ' + i + ' excede 80 caracteres.', 'ERROR'));
                        return null;
                    }
                    if (!Pattern.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$', email)) {
                        listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Línea ' + i)}, 
                            'Error: ' + headers[j] + ' en línea ' + i + ' no es un email válido.', 'ERROR'));
                        return null;
                    }
                }
            }
            updates.put(fields[0], new UpdateWrapper(
                fields[1], 
                String.isBlank(fields[2]) ? null : fields[2],
                String.isBlank(fields[3]) ? null : fields[3],
                String.isBlank(fields[4]) ? null : fields[4],
                String.isBlank(fields[5]) ? null : fields[5],
                String.isBlank(fields[6]) ? null : fields[6],
                String.isBlank(fields[7]) ? null : fields[7],
                String.isBlank(fields[8]) ? null : fields[8],
                String.isBlank(fields[9]) ? null : fields[9],
                String.isBlank(fields[10]) ? null : fields[10],
                String.isBlank(fields[11]) ? null : fields[11],
                String.isBlank(fields[12]) ? null : fields[12],
                String.isBlank(fields[13]) ? null : fields[13],
                String.isBlank(fields[14]) ? null : fields[14],
                String.isBlank(fields[15]) ? null : fields[15],
                String.isBlank(fields[16]) ? null : fields[16],
                String.isBlank(fields[17]) ? null : fields[17],
                String.isBlank(fields[18]) ? null : fields[18],
                String.isBlank(fields[19]) ? null : fields[19],
                String.isBlank(fields[20]) ? null : fields[20],
                String.isBlank(fields[21]) ? null : fields[21],
                String.isBlank(fields[22]) ? null : fields[22],
                String.isBlank(fields[23]) ? null : fields[23]
            ));
        }
        return updates;
    }

    private static Boolean validateHeaders(String[] headers, List<ResponseWrap> listResp) {
        if (headers.size() != 24 || 
            headers[0] != 'CEN_Proforma__c' || 
            headers[1] != 'CEN_Fecha_Entrega_Lote__c' || 
            headers[2] != 'CEN_INTERLOCUTOR_1__c' ||
            headers[3] != 'CEN_INTERLOCUTOR_2__c' ||
            headers[4] != 'CEN_INTERLOCUTOR_3__c' ||
            headers[5] != 'CEN_INTERLOCUTOR_4__c' ||
            headers[6] != 'CEN_INTERLOCUTOR_5__c' ||
            headers[7] != 'CEN_INTERLOCUTOR_6__c' ||
            headers[8] != 'CEN_INTERLOCUTOR_7__c' ||
            headers[9] != 'CEN_INTERLOCUTOR_8__c' ||
            headers[10] != 'CEN_INTERLOCUTOR_9__c' ||
            headers[11] != 'CEN_INTERLOCUTOR_10__c' ||
            headers[12] != 'CEN_TITULAR__c' ||
            headers[13] != 'CEN_TITULAR_EMAIL__c' ||
            headers[14] != 'CEN_INTERLOCUTOR_1_EMAIL__c' ||
            headers[15] != 'CEN_INTERLOCUTOR_2_EMAIL__c' ||
            headers[16] != 'CEN_INTERLOCUTOR_3_EMAIL__c' ||
            headers[17] != 'CEN_INTERLOCUTOR_4_EMAIL__c' ||
            headers[18] != 'CEN_INTERLOCUTOR_5_EMAIL__c' ||
            headers[19] != 'CEN_INTERLOCUTOR_6_EMAIL__c' ||
            headers[20] != 'CEN_INTERLOCUTOR_7_EMAIL__c' ||
            headers[21] != 'CEN_INTERLOCUTOR_8_EMAIL__c' ||
            headers[22] != 'CEN_INTERLOCUTOR_9_EMAIL__c' ||
            headers[23] != 'CEN_INTERLOCUTOR_10_EMAIL__c') {
            listResp.add(new ResponseWrap(0, new List<ProformaError>{new ProformaError('Encabezados inválidos')}, 
                'Error: CSV debe tener CEN_Proforma__c, CEN_Fecha_Entrega_Lote__c, CEN_INTERLOCUTOR_1__c, CEN_INTERLOCUTOR_2__c, CEN_INTERLOCUTOR_3__c, CEN_INTERLOCUTOR_4__c, CEN_INTERLOCUTOR_5__c, CEN_INTERLOCUTOR_6__c, CEN_INTERLOCUTOR_7__c, CEN_INTERLOCUTOR_8__c, CEN_INTERLOCUTOR_9__c, CEN_INTERLOCUTOR_10__c, CEN_TITULAR__c, CEN_TITULAR_EMAIL__c, CEN_INTERLOCUTOR_1_EMAIL__c, CEN_INTERLOCUTOR_2_EMAIL__c, CEN_INTERLOCUTOR_3_EMAIL__c, CEN_INTERLOCUTOR_4_EMAIL__c, CEN_INTERLOCUTOR_5_EMAIL__c, CEN_INTERLOCUTOR_6_EMAIL__c, CEN_INTERLOCUTOR_7_EMAIL__c, CEN_INTERLOCUTOR_8_EMAIL__c, CEN_INTERLOCUTOR_9_EMAIL__c, CEN_INTERLOCUTOR_10_EMAIL__c.', 'ERROR'));
            return false;
        }
        return true;
    }

    private static void sendResponse(List<ResponseWrap> listResp, Integer statusCode) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(listResp));
        RestContext.response.headers.put('Content-Type', 'application/json');
    }

    global class ResponseWrap {
        public Integer Actualizados { get; set; }
        public List<ProformaError> Proformas_con_error { get; set; }
        public String Error { get; set; }
        public String Estado { get; set; }

        public ResponseWrap(Integer actualizados, List<ProformaError> proformasConError, String error, String estado) {
            this.Actualizados = actualizados;
            this.Proformas_con_error = proformasConError;
            this.Error = error;
            this.Estado = estado;
        }
    }

    global class ProformaError {
        public String proforma { get; set; }

        public ProformaError(String proforma) {
            this.proforma = proforma;
        }
    }

    private class UpdateWrapper {
        public String fechaEntrega { get; set; }
        public String interlocutor1 { get; set; }
        public String interlocutor2 { get; set; }
        public String interlocutor3 { get; set; }
        public String interlocutor4 { get; set; }
        public String interlocutor5 { get; set; }
        public String interlocutor6 { get; set; }
        public String interlocutor7 { get; set; }
        public String interlocutor8 { get; set; }
        public String interlocutor9 { get; set; }
        public String interlocutor10 { get; set; }
        public String titular { get; set; }
        public String titularEmail { get; set; }
        public String interlocutor1Email { get; set; }
        public String interlocutor2Email { get; set; }
        public String interlocutor3Email { get; set; }
        public String interlocutor4Email { get; set; }
        public String interlocutor5Email { get; set; }
        public String interlocutor6Email { get; set; }
        public String interlocutor7Email { get; set; }
        public String interlocutor8Email { get; set; }
        public String interlocutor9Email { get; set; }
        public String interlocutor10Email { get; set; }

        public UpdateWrapper(String fechaEntrega, String interlocutor1, String interlocutor2, 
                            String interlocutor3, String interlocutor4, String interlocutor5,
                            String interlocutor6, String interlocutor7, String interlocutor8,
                            String interlocutor9, String interlocutor10, String titular, 
                            String titularEmail, String interlocutor1Email, String interlocutor2Email,
                            String interlocutor3Email, String interlocutor4Email, String interlocutor5Email,
                            String interlocutor6Email, String interlocutor7Email, String interlocutor8Email,
                            String interlocutor9Email, String interlocutor10Email) {
            this.fechaEntrega = fechaEntrega;
            this.interlocutor1 = interlocutor1;
            this.interlocutor2 = interlocutor2;
            this.interlocutor3 = interlocutor3;
            this.interlocutor4 = interlocutor4;
            this.interlocutor5 = interlocutor5;
            this.interlocutor6 = interlocutor6;
            this.interlocutor7 = interlocutor7;
            this.interlocutor8 = interlocutor8;
            this.interlocutor9 = interlocutor9;
            this.interlocutor10 = interlocutor10;
            this.titular = titular;
            this.titularEmail = titularEmail;
            this.interlocutor1Email = interlocutor1Email;
            this.interlocutor2Email = interlocutor2Email;
            this.interlocutor3Email = interlocutor3Email;
            this.interlocutor4Email = interlocutor4Email;
            this.interlocutor5Email = interlocutor5Email;
            this.interlocutor6Email = interlocutor6Email;
            this.interlocutor7Email = interlocutor7Email;
            this.interlocutor8Email = interlocutor8Email;
            this.interlocutor9Email = interlocutor9Email;
            this.interlocutor10Email = interlocutor10Email;
        }
    }
}