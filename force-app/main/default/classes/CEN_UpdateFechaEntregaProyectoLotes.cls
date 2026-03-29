/**
 * @name               : CEN_UpdateFechaEntregaProyectoLotes
 * @author             : Felipe Bermudez
 * @creation date      : 10-07-2025
 * @modification date  : 10-07-2025
 * @last modified by   : 
 * Clase test          :
 * @description        : Flujo cambio de fecha de entrega en vista PROYECTO SF(Journey5)
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-07-2025   Felipe Bermudez  Initial Version
 * 1.2   07-09-2025   Felipe Bermudez  Se ajusto el campo FECHA ENTRA ESPEJO
**/
public class CEN_UpdateFechaEntregaProyectoLotes {
    @AuraEnabled
    public static String updateOpByProyectoId(String idProyecto) {
    try {
        // Validar que idProyecto no sea nulo o vacío
        if (String.isBlank(idProyecto)) {
            return 'ID de proyecto no válido';
        }

        // Consulta el proyecto con los campos necesarios
        Proyecto__c proyectoRecord = [SELECT Id, CEN_CODIGOSAP__c, CEN_Fecha_entrega__c, CEN_NumVecesUpdateOpp__c 
                                     FROM Proyecto__c 
                                     WHERE Id = :idProyecto 
                                     LIMIT 1];
        System.debug('Fecha de entrega: ' + proyectoRecord.CEN_Fecha_entrega__c);
        
        // Validar si CEN_Fecha_entrega__c es null antes de llamar a listarLotesUpdate
        if (proyectoRecord.CEN_Fecha_entrega__c == null) {
            return 'Proyecto no cuenta con fecha de entrega lote';
        }
        
        // Ejecutar listarLotesUpdate si la fecha no es null
        String resultadoLotes = listarLotesUpdate(proyectoRecord.CEN_Fecha_entrega__c, proyectoRecord.CEN_CODIGOSAP__c, idProyecto);
        
        // Actualizar CEN_NumVecesUpdateOpp__c a 1
        proyectoRecord.CEN_NumVecesUpdateOpp__c = 1;
        update proyectoRecord;
        
        return 'Se actualizaron las oportunidades';
        } catch (Exception e) {
            System.debug('Error en updateOpByProyectoId: ' + e.getMessage());
            return 'Proyecto no cuenta con fecha de entrega';
        }
    }

    @AuraEnabled
    public static Boolean validarEstadoProyecto(String idProyecto) {
        try {
        // Validar que idProyecto no sea nulo o vacío
        if (String.isBlank(idProyecto)) {
            return false;
        }

        // Consulta el estado del proyecto y el campo CEN_NumVecesUpdateOpp__c
        Proyecto__c proyectoRecord = [SELECT Id, CEN_Estado_proyecto__c, CEN_NumVecesUpdateOpp__c 
                                     FROM Proyecto__c 
                                     WHERE Id = :idProyecto 
                                     LIMIT 1];

        // Retornar true si el estado es 'Entregado' y CEN_NumVecesUpdateOpp__c es 0 o null
        return proyectoRecord.CEN_Estado_proyecto__c == 'Entregado' && 
               (proyectoRecord.CEN_NumVecesUpdateOpp__c == null || proyectoRecord.CEN_NumVecesUpdateOpp__c == 0);
        } catch (Exception e) {
            System.debug('Error en validarEstadoProyecto: ' + e.getMessage());
            return false; // Retornar false en caso de error (por ejemplo, si el registro no existe)
        }
    }

    @AuraEnabled
    public static String listarLotesUpdate(Date fechaEntregaProyecto, String codProyecto, String idProyecto) {
        try {
            // Simular o llamar servicio según contexto
            List<CEN_ResponseContentVisorLotes> lotes;
            if (Test.isRunningTest()) {
                // Simulación de respuesta del servicio durante test
                CEN_ResponseContentVisorLotes lote1 = new CEN_ResponseContentVisorLotes();
                lote1.proforma = '12345'; // Debe coincidir con una Opportunity en tu test
                CEN_ResponseContentVisorLotes lote2 = new CEN_ResponseContentVisorLotes();
                lote2.proforma = '67890'; // Otra proforma válida

                lotes = new List<CEN_ResponseContentVisorLotes>{lote1, lote2};
            } else {
                // Llamada real en ejecución normal
                lotes = CEN_ConsultVisorLotes.ByProyect(codProyecto);
            }
            
            // Lista para almacenar las proformas del servicio
            List<String> proformasServicio = new List<String>();
            
            // Iterar sobre los ítems y extraer las proformas
            for (CEN_ResponseContentVisorLotes item : lotes) {
                // Asumiendo que CEN_ResponseContentVisorLotes tiene un campo 'proforma'
                // Ajusta el nombre del campo según la estructura real
                if (item.proforma != null && item.proforma != '0000000000') {
                    proformasServicio.add(item.proforma);
                }
            }
            System.debug('proformas servicio: ' + proformasServicio.size());

            // Consultar proformas de Salesforce desde Opportunity
            List<Opportunity> oportunidades = [SELECT Id, CEN_Proforma__c, CEN_Fecha_Entrega_Lote__c 
                                              FROM Opportunity 
                                              WHERE CEN_Proyecto__c = :idProyecto 
                                              AND CEN_Proforma__c != null
                                              AND StageName = 'Oportunidad Ganada'];
            
            // Extraer proformas de las oportunidades
            Set<String> proformasSF = new Set<String>();
            for (Opportunity opp : oportunidades) {
                proformasSF.add(opp.CEN_Proforma__c);
            }
            System.debug('proformas de Opportunity: ' + proformasSF.size());
            
            // Comparar proformas del servicio con las de Salesforce
            List<String> proformasCoincidentes = new List<String>();
            for (String proforma : proformasServicio) {
                if (proformasSF.contains(proforma)) {
                    proformasCoincidentes.add(proforma);
                }
            }
            System.debug('proformas que Coinciden: ' + proformasCoincidentes.size());
            
            // Mapa para traducir números de mes a nombres en español
            Map<Integer, String> monthTranslation = new Map<Integer, String>{
                1 => 'enero', 2 => 'febrero', 3 => 'marzo', 4 => 'abril', 5 => 'mayo', 
                6 => 'junio', 7 => 'julio', 8 => 'agosto', 9 => 'septiembre', 
                10 => 'octubre', 11 => 'noviembre', 12 => 'diciembre'
            };

            // Actualizar el campo CEN_Fecha_entrega__c en las oportunidades coincidentes
            List<Opportunity> oportunidadesParaActualizar = new List<Opportunity>();
            for (Opportunity opp : oportunidades) {
                if (proformasCoincidentes.contains(opp.CEN_Proforma__c)) {
                    opp.CEN_Fecha_Entrega_Lote__c = fechaEntregaProyecto;
                    Date fecha = opp.CEN_Fecha_Entrega_Lote__c;
                    String day = String.valueOf(fecha.day());
                    String month = monthTranslation.get(fecha.month());
                    String year = String.valueOf(fecha.year());
                    opp.CEN_Fecha_EntregaLote_Espejo__c = day + ' de ' + month + ' de ' + year;
                    oportunidadesParaActualizar.add(opp);
                }
            }
            
            // Ejecutar la actualización si hay oportunidades para actualizar
            if (!oportunidadesParaActualizar.isEmpty()) {
                update oportunidadesParaActualizar;
                System.debug('Oportunidades actualizadas: ' + oportunidadesParaActualizar.size());
            }
            
            // Retornar respuesta estructurada con las proformas coincidentes
            String message = proformasCoincidentes.isEmpty() ? 'No se encontraron proformas coincidentes' : 'Proformas coincidentes procesadas y oportunidades actualizadas correctamente';
            return JSON.serialize(new ResponseWrapper(proformasCoincidentes, message, true));
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return JSON.serialize(new ResponseWrapper(null, 'Error al consultar lotes o actualizar oportunidades: ' + e.getMessage(), false));
        }
    }
    
    // Clase interna para estructurar la respuesta
    public class ResponseWrapper {
        public List<String> proformas;
        public String message;
        public Boolean success;
        
        public ResponseWrapper(List<String> proformas, String message, Boolean success) {
            this.proformas = proformas;
            this.message = message;
            this.success = success;
        }
    }
}