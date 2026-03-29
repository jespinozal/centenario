/**
 * @name               : CEN_LeadSegmentationTrigger
 * @author             : Jesus Jaime Poco Salvador
 * @creation date      : 10-03-2025
 * @modification date  : 30-03-2025
 * @modification date  : 07-07-2025 (Felipe Bermudez) Ver 1.3
 * @description        : Trigger que se ejecuta al crear un Lead para iniciar la segmentación automática. 
 *                       Establece un estado inicial y decide si clona una segmentación existente o envía datos a Tannua,
 *                       dependiendo de un Custom Label (CEN_ActivarSegmentacionAutomatica).
 * @versions           : 1.0 - Versión inicial
 *                       1.1 - Agrega CEN_Estado_Envio_Tannua__c como Pendiente
 *                       1.2 - Agrega control con Custom Label CEN_ActivarSegmentacionAutomatica
 +                       1.3 - Se agrego validacion para Leads tipo Urbano y BTL para que solo sean segmentados
 */                      
trigger CEN_LeadSegmentationTrigger on Lead (before insert, after insert) {
    // Antes de insertar el Lead (fase "before insert")
    if (Trigger.isBefore && Trigger.isInsert) {
        // Recorre todos los Leads nuevos que se están insertando
        for (Lead lead : Trigger.new) {
            // Establece el estado inicial del envío a Tannua como "Pendiente"
            // Esto indica que el Lead aún no ha sido procesado
            lead.CEN_Estado_Envio_Tannua__c = 'Pendiente';
        }
    }

    // Después de insertar el Lead (fase "after insert")
    if (Trigger.isAfter && Trigger.isInsert) {
        // Consulta el Custom Label que actúa como interruptor para el flujo automático
        // Convierte el valor del Label (texto "true" o "false") a un booleano
        Boolean activarSegmentacion = Boolean.valueOf(System.Label.CEN_ActivarSegmentacionAutomatica);
        
        // Si el interruptor está en false, termina la ejecución del Trigger
        // Esto desactiva todo el proceso automático de clonado y envío a Tannua
        if (!activarSegmentacion) {
            return; // Sale del Trigger sin hacer nada más
        }

        // Mapa para vincular DNIs con IDs de Leads
        // Esto ayuda a identificar qué Leads necesitan segmentación
        Map<String, Id> dniToLeadIdMap = new Map<String, Id>();
        
        // Recorre los Leads nuevos y recolecta sus números de documento (DNI)
        for (Lead lead : Trigger.new) {
            if (String.isNotBlank(lead.CEN_N_mero_de_documento__c)) {
                // Si el DNI no está vacío, lo agrega al mapa con el ID del Lead
                dniToLeadIdMap.put(lead.CEN_N_mero_de_documento__c, lead.Id);
            }
        }
        
        // Si hay DNIs para procesar, continúa con la lógica
        if (!dniToLeadIdMap.isEmpty()) {
            // Busca segmentaciones existentes en CEN_Lead_Data_Segmentation__c
            // Solo considera las originales (sin padre) y las ordena por fecha descendente
            List<CEN_Lead_Data_Segmentation__c> originalSegmentations = [
                SELECT Id, CEN_LDS_numero_documento__c, CEN_IdLead__c, CEN_LDS_Tipo_de_documento__c,
                       CEN_LDS_Prediccion_ponderada__c, CEN_LDS_Puntuacion_ponderada__c, CEN_LDS_Resultado_segmentacion__c,
                       CEN_LDS_Variable_42__c,CEN_LDS_Variable_202__c,CEN_LDS_Variable_287__c,CEN_LDS_Variable_315__c,
                       CEN_LDS_Variable_370__c,CEN_LDS_Variable_749__c,CEN_LDS_Variable_46__c,CEN_LDS_Variable_50__c,CEN_LDS_Variable_51__c,
                       CEN_LDS_Variable_53__c,CEN_LDS_Variable_55__c,CEN_LDS_Variable_59__c,CEN_LDS_Variable_60__c,
                       CEN_LDS_Variable_63__c,CEN_LDS_Variable_67__c,CEN_LDS_Variable_68__c,CEN_LDS_Variable_70__c,
                       CEN_LDS_Variable_76__c,CEN_LDS_Variable_80__c,CEN_LDS_Variable_86__c,CEN_LDS_Variable_88__c,
                       CEN_LDS_Variable_97__c,CEN_LDS_Variable_104__c,
                       CreatedDate
                FROM CEN_Lead_Data_Segmentation__c
                WHERE CEN_LDS_numero_documento__c IN :dniToLeadIdMap.keySet()
                AND CEN_LDS_Parent_Segmentation__c = NULL // Segmentaciones originales, no clonadas
                ORDER BY CreatedDate DESC
            ];
            
            // Mapa para almacenar la segmentación más reciente por DNI
            Map<String, CEN_Lead_Data_Segmentation__c> dniToOriginalSegmentationMap = new Map<String, CEN_Lead_Data_Segmentation__c>();
            for (CEN_Lead_Data_Segmentation__c seg : originalSegmentations) {
                // Solo guarda la primera (más reciente) segmentación para cada DNI
                if (!dniToOriginalSegmentationMap.containsKey(seg.CEN_LDS_numero_documento__c)) {
                    dniToOriginalSegmentationMap.put(seg.CEN_LDS_numero_documento__c, seg);
                }
            }
            
            // Conjunto de IDs de Leads que se enviarán a Tannua
            Set<Id> leadsToProcessWithService = new Set<Id>();
            // Lista de nuevas segmentaciones clonadas que se insertarán
            List<CEN_Lead_Data_Segmentation__c> newSegmentationsToInsert = new List<CEN_Lead_Data_Segmentation__c>();
            
            // Obtiene la fecha actual para comparar con las segmentaciones existentes
            Date currentDate = Date.today();
            // Consulta el límite de días para considerar una segmentación "reciente" desde un Custom Label
            Integer maxDays = Integer.valueOf(System.Label.CEN_lbl_DiasRegistroSeg);
            
            // Clasifica cada Lead según su DNI
            for (String dni : dniToLeadIdMap.keySet()) {
                Id leadId = dniToLeadIdMap.get(dni);
                Lead currentLead = Trigger.newMap.get(leadId);
                // Si existe una segmentación previa para este DNI
                if (dniToOriginalSegmentationMap.containsKey(dni)) {
                    CEN_Lead_Data_Segmentation__c originalSeg = dniToOriginalSegmentationMap.get(dni);
                    // Calcula cuántos días han pasado desde la creación de la segmentación
                    Integer daysDifference = originalSeg.CreatedDate.date().daysBetween(currentDate);
                    
                    if (daysDifference <= maxDays) {
                        // Si está dentro del límite de días, clona la segmentación
                        CEN_Lead_Data_Segmentation__c newSeg = new CEN_Lead_Data_Segmentation__c();
                        newSeg.CEN_IdLead__c = leadId; // Vincula la nueva segmentación al Lead actual
                        newSeg.CEN_LDS_numero_documento__c = dni;
                        newSeg.CEN_LDS_Tipo_de_documento__c = originalSeg.CEN_LDS_Tipo_de_documento__c;
                        newSeg.CEN_LDS_Prediccion_ponderada__c = originalSeg.CEN_LDS_Prediccion_ponderada__c;
                        newSeg.CEN_LDS_Puntuacion_ponderada__c = originalSeg.CEN_LDS_Puntuacion_ponderada__c;
                        newSeg.CEN_LDS_Resultado_segmentacion__c = originalSeg.CEN_LDS_Resultado_segmentacion__c;
                        newSeg.CEN_LDS_Variable_42__c = originalSeg.CEN_LDS_Variable_42__c;
                        newSeg.CEN_LDS_Variable_202__c = originalSeg.CEN_LDS_Variable_202__c;
                        newSeg.CEN_LDS_Variable_287__c = originalSeg.CEN_LDS_Variable_287__c;
                        newSeg.CEN_LDS_Variable_315__c = originalSeg.CEN_LDS_Variable_315__c;
                        newSeg.CEN_LDS_Variable_370__c = originalSeg.CEN_LDS_Variable_370__c;
                        newSeg.CEN_LDS_Variable_749__c = originalSeg.CEN_LDS_Variable_749__c;
                        newSeg.CEN_LDS_Variable_46__c = originalSeg.CEN_LDS_Variable_46__c;
                        newSeg.CEN_LDS_Variable_50__c = originalSeg.CEN_LDS_Variable_50__c;
                        newSeg.CEN_LDS_Variable_51__c = originalSeg.CEN_LDS_Variable_51__c;
                        newSeg.CEN_LDS_Variable_53__c = originalSeg.CEN_LDS_Variable_53__c;
                        newSeg.CEN_LDS_Variable_55__c = originalSeg.CEN_LDS_Variable_55__c;
                        newSeg.CEN_LDS_Variable_59__c = originalSeg.CEN_LDS_Variable_59__c;
                        newSeg.CEN_LDS_Variable_60__c = originalSeg.CEN_LDS_Variable_60__c;
                        newSeg.CEN_LDS_Variable_63__c = originalSeg.CEN_LDS_Variable_63__c;
                        newSeg.CEN_LDS_Variable_67__c = originalSeg.CEN_LDS_Variable_67__c;
                        newSeg.CEN_LDS_Variable_68__c = originalSeg.CEN_LDS_Variable_68__c;
                        newSeg.CEN_LDS_Variable_70__c = originalSeg.CEN_LDS_Variable_70__c;
                        newSeg.CEN_LDS_Variable_76__c = originalSeg.CEN_LDS_Variable_76__c;
                        newSeg.CEN_LDS_Variable_80__c = originalSeg.CEN_LDS_Variable_80__c;
                        newSeg.CEN_LDS_Variable_86__c = originalSeg.CEN_LDS_Variable_86__c;
                        newSeg.CEN_LDS_Variable_88__c = originalSeg.CEN_LDS_Variable_88__c;
                        newSeg.CEN_LDS_Variable_97__c = originalSeg.CEN_LDS_Variable_97__c;
                        newSeg.CEN_LDS_Variable_104__c = originalSeg.CEN_LDS_Variable_104__c;
                        
                        newSeg.CEN_LDS_Parent_Segmentation__c = originalSeg.Id; // Marca como clonada de la original
                        newSegmentationsToInsert.add(newSeg);
                    } else {
                        // Si excede el límite de días, valida que sea RecordType "Urbano" o "012Qh000001msGvIAI" y tipo de documento "DNI"
                        if ((currentLead.RecordTypeId == '0124T0000000qryQAA' && currentLead.CEN_Tipo_de_documento__c == 'DNI') ||
                            (currentLead.RecordTypeId == '012Qh000001msGvIAI' && currentLead.CEN_Tipo_de_documento__c == 'DNI' && 
                             String.isNotBlank(currentLead.CEN_N_mero_de_documento__c) && currentLead.CEN_N_mero_de_documento__c.length() == 8)) {
                            leadsToProcessWithService.add(leadId);
                        }
                    }
                } else {
                    // Si no hay segmentación previa, valida que sea RecordType "Urbano" o "012Qh000001msGvIAI" y tipo de documento "DNI"
                    if ((currentLead.RecordTypeId == '0124T0000000qryQAA' && currentLead.CEN_Tipo_de_documento__c == 'DNI') ||
                        (currentLead.RecordTypeId == '012Qh000001msGvIAI' && currentLead.CEN_Tipo_de_documento__c == 'DNI' && 
                         String.isNotBlank(currentLead.CEN_N_mero_de_documento__c) && currentLead.CEN_N_mero_de_documento__c.length() == 8)) {
                        leadsToProcessWithService.add(leadId);
                    }
                }
            }
            
            // Inserta las segmentaciones clonadas si las hay
            if (!newSegmentationsToInsert.isEmpty()) {
                try {
                    insert newSegmentationsToInsert;
                    // Actualiza el estado de los Leads clonados a "Exitoso"
                    List<Lead> leadsToUpdate = new List<Lead>();
                    for (CEN_Lead_Data_Segmentation__c seg : newSegmentationsToInsert) {
                        leadsToUpdate.add(new Lead(Id = seg.CEN_IdLead__c, CEN_Estado_Envio_Tannua__c = 'Exitoso'));
                    }
                    update leadsToUpdate;
                } catch (DmlException e) {
                    // Registra cualquier error al insertar las segmentaciones clonadas
                    System.debug('Error al insertar segmentaciones clonadas: ' + e.getMessage());
                }
            }
            
            // Envía los Leads a Tannua asíncronamente si hay alguno pendiente
            if (!leadsToProcessWithService.isEmpty() && !System.isFuture() && !System.isBatch()) {
                // Llama al método asíncrono en CEN_SendLeadSegmentation
                CEN_SendLeadSegmentation.processLeadSegmentationAsync(leadsToProcessWithService);
            }
        }
    }
}