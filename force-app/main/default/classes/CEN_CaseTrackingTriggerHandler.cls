/**
 * @description Handler class for the CEN_CaseTracking__c trigger.
 * Contains the business logic to calculate the duration of a case stage.
 * Jesus Poco
 * jpocosal@emeal.nttdata.com
 */
public with sharing class CEN_CaseTrackingTriggerHandler {

    public static void handleBeforeInsert(List<CEN_CaseTracking__c> newRecords) {
        Set<Id> caseIds = new Set<Id>();
        for (CEN_CaseTracking__c tracking : newRecords) {
            if (tracking.CEN_CaseId__c != null) {
                caseIds.add(tracking.CEN_CaseId__c);
            }
        }

        if (caseIds.isEmpty()) return;

        // Consultamos el caso padre para obtener su CreatedDate y el estado del check
        Map<Id, Case> parentCases = new Map<Id, Case>([
            SELECT Id, CreatedDate, CEN_Observado__c FROM Case WHERE Id IN :caseIds
        ]);

        // Buscamos el último tracking existente para cada caso, incluyendo su "snapshot"
        Map<Id, CEN_CaseTracking__c> latestTrackingPerCase = new Map<Id, CEN_CaseTracking__c>();
        for (CEN_CaseTracking__c tracking : [
            SELECT Id, CreatedDate, CEN_CaseId__c, CEN_Observado_al_Finalizar__c
            FROM CEN_CaseTracking__c
            WHERE CEN_CaseId__c IN :caseIds
            ORDER BY CreatedDate DESC
        ]) {
            if (!latestTrackingPerCase.containsKey(tracking.CEN_CaseId__c)) {
                latestTrackingPerCase.put(tracking.CEN_CaseId__c, tracking);
            }
        }

        for (CEN_CaseTracking__c newRecord : newRecords) {
            Case parentCase = parentCases.get(newRecord.CEN_CaseId__c);
            if (parentCase == null) continue;

            // --- NUEVA LÓGICA PARA EL ESTADO OBSERVADO ---

            // 1. Siempre tomamos un snapshot del estado actual del check al finalizar esta etapa.
            newRecord.CEN_Observado_al_Finalizar__c = parentCase.CEN_Observado__c;

            Datetime startTime;
            
            // 2. Determinamos si ESTA etapa estuvo en observación
            CEN_CaseTracking__c previousRecord = latestTrackingPerCase.get(newRecord.CEN_CaseId__c);
            
            if (previousRecord != null) {
                // Si hay un registro previo, el estado de nuestra etapa es el snapshot de ese registro previo.
                newRecord.CEN_Etapa_Estuvo_en_Observacion__c = previousRecord.CEN_Observado_al_Finalizar__c;
                startTime = previousRecord.CreatedDate;
            } else {
                // Si es la primera etapa, asumimos que no comenzó en estado "Observado".
                newRecord.CEN_Etapa_Estuvo_en_Observacion__c = false; 
                startTime = parentCase.CreatedDate;
            }

            // --- LÓGICA DE CÁLCULO DE TIEMPO (Sin cambios) ---
            Datetime endTime = System.now();
            newRecord.CEN_Fecha_Inicio__c = startTime;
            newRecord.CEN_Fecha_Fin__c = endTime;

            Long diffMillis = endTime.getTime() - startTime.getTime();
            Decimal minutesElapsed = (Decimal)diffMillis / (1000 * 60);
            newRecord.CEN_Tiempo_Transcurrido_Minutos__c = minutesElapsed;
        }
    }
}