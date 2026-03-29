/**
 * @name               : CEN_LeadDataSegmentationTrigger
 * @author             : Jesus Poco
 * @creation date      : 20-03-2025
 * @modification date  : 27-03-2025
 * @description        : Trigger que se ejecuta después de insertar un registro en CEN_Lead_Data_Segmentation__c.
 *                       Actualiza el Lead vinculado con la puntuación ponderada y variables específicas recibidas de Tannua.
 * @versions           : 1.0 - Versión inicial
 *                       1.1 - Agrega actualización de campos CEN_LDS_Variable_X__c a campos específicos en Lead
 */
trigger CEN_LeadDataSegmentationTrigger on CEN_Lead_Data_Segmentation__c (after insert) {
    // Mapa para almacenar los Leads que se actualizarán
    // La clave es el ID del Lead, y el valor es el objeto Lead con los campos actualizados
    Map<Id, Lead> leadIdToDataMap = new Map<Id, Lead>();
    
    // Recorre todos los registros nuevos de segmentación insertados
    for (CEN_Lead_Data_Segmentation__c seg : Trigger.new) {
        // Verifica que el campo CEN_IdLead__c no esté vacío (vincula la segmentación al Lead)
        if (seg.CEN_IdLead__c != null) {
            // Crea un objeto Lead con el ID correspondiente
            Lead leadToUpdate = new Lead(Id = seg.CEN_IdLead__c);
            
            // Actualiza CEN_Puntuacion_ponderada__c si el valor no está vacío
            if (String.isNotBlank(seg.CEN_LDS_Puntuacion_ponderada__c)) {
                try {
                    // Convierte el valor de texto a Decimal con 2 decimales
                    leadToUpdate.CEN_Puntuacion_ponderada__c = Decimal.valueOf(seg.CEN_LDS_Puntuacion_ponderada__c).setScale(2);
                } catch (Exception e) {
                    // Registra errores de conversión para depuración
                    System.debug('Error al convertir CEN_LDS_Puntuacion_ponderada__c para Lead ' + seg.CEN_IdLead__c + ': ' + e.getMessage());
                }
            }
            
            // Asigna los valores de las variables de segmentación a los campos correspondientes en el Lead
            // Estos campos mapean datos específicos recibidos de Tannua
            leadToUpdate.CEN_Estudio_Superior__c = seg.CEN_LDS_Variable_42__c;      // Nivel de educación
            leadToUpdate.CEN_Sector_Economico__c = seg.CEN_LDS_Variable_202__c;    // Industria o sector laboral
            leadToUpdate.CEN_Segmento_Riqueza__c = seg.CEN_LDS_Variable_287__c;    // Nivel de riqueza estimado
            leadToUpdate.CEN_Estilo_de_Vida__c = seg.CEN_LDS_Variable_315__c;      // Tipo de estilo de vida
            leadToUpdate.CEN_Numero_de_Vehiculos__c = seg.CEN_LDS_Variable_370__c; // Cantidad de vehículos
            leadToUpdate.CEN_Score_Crediticio__c = seg.CEN_LDS_Variable_749__c;    // Puntuación crediticia
            
            // Agrega el Lead actualizado al mapa
            leadIdToDataMap.put(seg.CEN_IdLead__c, leadToUpdate);
        }
    }
    
    // Si hay Leads para actualizar, realiza la operación
    if (!leadIdToDataMap.isEmpty()) {
        try {
            // Actualiza todos los Leads en una sola operación DML
            update leadIdToDataMap.values();
        } catch (DmlException e) {
            // Registra errores de actualización para depuración
            System.debug('Error al actualizar Leads: ' + e.getMessage());
        }
    }
}