/**
 * @description Clase handler que contiene la lógica para gestionar la finalización de hitos (Milestones)
 * basada en la transición de estados de un Caso. Es invocada por el CaseTrigger.
 * @author      jesusjaime.pocosalvador@emeal.nttdata.com
 * @date        06/09/2025
 * @see         CaseTrigger
 */
public class CEN_CaseEventoClaveTriggerHandler {

    // Constante privada para mapear el estado que un Caso está *dejando* con el nombre
    // del Hito (Milestone) que debe ser completado. Esta centralización facilita el mantenimiento.
    // Si se añade un nuevo estado al proceso, solo es necesario actualizar este mapa.
    private static final Map<String, String> STATUS_TO_MILESTONE_MAP = new Map<String, String>{
        'Registrado'         => 'Registrado',
        'En Revisión'        => 'En Revisión',
        'Revisión Contrato'  => 'Revisión Contrato',
        'Pendiente Finalizar'=> 'Pendiente Finalizar'
    };

    // Constante privada para almacenar el ID del Record Type específico.
    // Usar 'final' asegura que no sea modificado después de su inicialización.
    private static final Id INTERACCION_CONTRATO_RECORDTYPE_ID;

    // Bloque de inicialización estático. Este código se ejecuta solo una vez cuando la clase es
    // cargada por primera vez en una transacción. Es la forma más eficiente de obtener
    // información de metadatos (como un Record Type ID) que no cambia.
    static {
        try {
            // Se obtiene el ID del Record Type por su nombre de desarrollador (DeveloperName),
            // lo que es más robusto que usar el nombre de la etiqueta (Label).
            INTERACCION_CONTRATO_RECORDTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('CEN_InteraccionContrato').getRecordTypeId();
        } catch (Exception e) {
            // Si el Record Type no existe o hay un problema de permisos, se registra un mensaje
            // y la variable se queda nula. La lógica principal no se ejecutará.
            System.debug('ADVERTENCIA: No se encontró el Record Type de Caso "CEN_InteraccionContrato". El handler de hitos será omitido.');
        }
    }
    
    /**
     * @description Método principal invocado por el trigger en un evento 'after update'.
     * @param newCases Lista de Casos en su nueva versión (después de la actualización).
     * @param oldCaseMap Mapa de los IDs de los Casos a su versión antigua (antes de la actualización).
     */
    public static void handleAfterUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        
        // Cláusula de guarda: Si el ID del Record Type no se pudo cargar, se detiene la ejecución
        // para prevenir errores inesperados.
        if (INTERACCION_CONTRATO_RECORDTYPE_ID == null) {
            return;
        }

        // Mapa para recolectar los Casos que necesitan una actualización de hito y qué hito cerrar.
        // Formato: Map<Id del Caso, Nombre del Hito a cerrar>
        Map<Id, String> caseIdToMilestoneNameToClose = new Map<Id, String>();
        
        // ==========================================================================================
        // PASO 1: RECOLECCIÓN Y FILTRADO
        // Se recorren todos los casos actualizados para identificar cuáles cumplen las condiciones.
        // ==========================================================================================
        for (Case currentCase : newCases) {
            
            // FILTRO 1: Se procesan únicamente los casos que pertenecen al Record Type correcto.
            // Si no coincide, 'continue' salta a la siguiente iteración del bucle.
            if (currentCase.RecordTypeId != INTERACCION_CONTRATO_RECORDTYPE_ID) {
                continue;
            }

            // Se obtienen los valores del estado, antes y después del cambio.
            String oldStatus = oldCaseMap.get(currentCase.Id).Status;
            String newStatus = currentCase.Status;

            // FILTRO 2: La lógica se aplica solo si el estado ha cambiado y si el estado
            // anterior es uno de los que gestionamos en nuestro mapa de hitos.
            if (oldStatus != newStatus && STATUS_TO_MILESTONE_MAP.containsKey(oldStatus)) {
                // Si cumple, se añade el caso y el nombre del hito a cerrar al mapa de recolección.
                caseIdToMilestoneNameToClose.put(currentCase.Id, STATUS_TO_MILESTONE_MAP.get(oldStatus));
            }
        }

        // Si después de recorrer todos los casos, ninguno necesita una acción, se termina la ejecución.
        if (caseIdToMilestoneNameToClose.isEmpty()) {
            return;
        }

        // ==========================================================================================
        // PASO 2: CONSULTA MASIVA DE HITOS (SOQL)
        // Se buscan todos los hitos relevantes en una única consulta para optimizar el rendimiento.
        // ==========================================================================================
        List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
        
        // Se consultan los hitos que están abiertos (CompletionDate = NULL) y que pertenecen
        // a los casos que hemos identificado en el paso anterior.
        for (CaseMilestone milestone : [
            SELECT Id, CaseId, MilestoneType.Name
            FROM CaseMilestone
            WHERE CaseId IN :caseIdToMilestoneNameToClose.keySet()
            AND CompletionDate = NULL
        ]) {
            // Se obtiene el nombre del hito que esperábamos cerrar para este caso específico.
            String expectedMilestoneName = caseIdToMilestoneNameToClose.get(milestone.CaseId);

            // Se verifica que el hito encontrado sea efectivamente el que corresponde al estado anterior.
            if (milestone.MilestoneType.Name == expectedMilestoneName) {
                // Si coincide, se establece la fecha de finalización y se añade a la lista de actualización.
                milestone.CompletionDate = System.now();
                milestonesToUpdate.add(milestone);
            }
        }
        
        // ==========================================================================================
        // PASO 3: ACTUALIZACIÓN MASIVA DE DATOS (DML)
        // Se guardan todos los cambios en la base de datos en una sola operación.
        // ==========================================================================================
        if (!milestonesToUpdate.isEmpty()) {
            // Se utiliza un bloque try-catch como buena práctica para manejar posibles errores
            // durante la operación de guardado (DML).
            try {
                update milestonesToUpdate;
            } catch (DmlException e) {
                // En un escenario real, aquí se podría implementar un sistema de logging de errores.
                System.debug('Error al actualizar los hitos: ' + e.getMessage());
            }
        }
    }
}