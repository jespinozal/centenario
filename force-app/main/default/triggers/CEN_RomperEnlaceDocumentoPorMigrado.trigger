/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
Actualización Trigger
Developer: Axel Cruz Loarte
Email: kevinaxel.cruzloarte@emeal.nttdata.com
*/
trigger CEN_RomperEnlaceDocumentoPorMigrado on CEN_AdjuntoRelacionado__c (after update) {

    Set<Id> docIds  = new Set<Id>();
    Map<Id, Id> docCaseMap = new Map<Id, Id>(); // docId -> caseId
    Map<Id, Id> docOpportunityMap = new Map<Id, Id>(); // docId -> oppotunityId

    System.debug('==== INICIO TRIGGER CEN_RomperEnlaceDocumentoPorMigrado ====');

    // Detectar documentos a procesar
    for (CEN_AdjuntoRelacionado__c ar : Trigger.new) {

        CEN_AdjuntoRelacionado__c oldAr = Trigger.oldMap.get(ar.Id);

        // Solo cuando Migrado cambia de false -> true
        if (!ar.CEN_Migrado__c || oldAr.CEN_Migrado__c) {
            System.debug('migrado: ' + ar.CEN_Migrado__c);
            continue;
        }

        if (ar.CEN_OpportunityID__c == null && ar.CEN_CaseID__c == null || String.isBlank(ar.CEN_IdDocumento__c)) {
            System.debug('opp: ' + ar.CEN_OpportunityID__c);
            System.debug('case: ' + ar.CEN_CaseID__c);
            continue;
        }

        System.debug('ar.CEN_IdDocumento__c: ' + ar.CEN_IdDocumento__c); 
        if (ar.CEN_IdDocumento__c.length() == 15 || ar.CEN_IdDocumento__c.length() == 18) {

            Id docId = (Id) ar.CEN_IdDocumento__c;
            docIds.add(docId);
            docCaseMap.put(docId, ar.CEN_CaseID__c);
            docOpportunityMap.put(docId, ar.CEN_OpportunityID__c);

            System.debug('Documento detectado para evaluación: ' + docId + ' asociado a Case: ' + ar.CEN_CaseID__c + ' o a Oportunidad: ' + ar.CEN_OpportunityID__c);
        }
    }

    if (docIds.isEmpty()) {
        System.debug('No hay documentos para procesar.');
        return;
    }

    //Obtener todos los ContentDocumentLink de esos documentos
    List<ContentDocumentLink> allLinks = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId IN :docIds
    ];

    System.debug('Total ContentDocumentLink encontrados: ' + allLinks.size());

    //Agrupar por documento
    Map<Id, List<ContentDocumentLink>> linksPorDocumento = new Map<Id, List<ContentDocumentLink>>();
    for (ContentDocumentLink cdl : allLinks) {
        if (!linksPorDocumento.containsKey(cdl.ContentDocumentId)) {
            linksPorDocumento.put(cdl.ContentDocumentId, new List<ContentDocumentLink>());
        }
        linksPorDocumento.get(cdl.ContentDocumentId).add(cdl);
    }

    List<ContentDocumentLink> linksAEliminar = new List<ContentDocumentLink>();
    List<ContentDocument> documentosAEliminar = new List<ContentDocument>();

    //Evaluar cada documento
    for (Id docId : linksPorDocumento.keySet()) {

        List<ContentDocumentLink> links = linksPorDocumento.get(docId);

        // Ignorar links hacia User
        List<ContentDocumentLink> linksReales = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : links) {
            System.debug('User.SObjectType: ' + User.SObjectType);
            System.debug('cdl.LinkedEntityId.getSObjectType(): ' + cdl.LinkedEntityId.getSObjectType());
            if (cdl.LinkedEntityId.getSObjectType() != User.SObjectType) {
                linksReales.add(cdl);
            }
        }

        System.debug('Evaluando documento: ' + docId + ' con cantidad de links reales (no User): ' + linksReales.size());

        // Más de un link real -> eliminación parcial
        if (linksReales.size() > 1) {
            for (ContentDocumentLink cdl : linksReales) {
                if (cdl.LinkedEntityId == docCaseMap.get(docId) || cdl.LinkedEntityId == docOpportunityMap.get(docId)) {
                    linksAEliminar.add(cdl);
                    System.debug('Eliminación PARCIAL (solo link). DocId: ' + docId + ' - LinkId: ' + cdl.Id);
                }
            }
        }
        // Solo un link real
        else if (linksReales.size() == 1) {
            ContentDocumentLink unicoLink = linksReales[0];
            if (unicoLink.LinkedEntityId.getSObjectType() == Case.SObjectType || unicoLink.LinkedEntityId.getSObjectType() == Opportunity.SObjectType) {
                documentosAEliminar.add(new ContentDocument(Id = docId));
                System.debug('Eliminación TOTAL del documento. DocId: ' + docId);
            } else {
                // Seguridad extra: eliminar solo link
                linksAEliminar.add(unicoLink);
                System.debug('Solo tiene un link real pero no es Case o Opportunity. Se elimina solo el link. DocId: ' + docId);
            }
        }
        // Ningún link real
        else {
            System.debug('Documento solo tiene links hacia User. No se hace nada. DocId: ' + docId);
        }
    }

    // Ejecutar DML
    if (!linksAEliminar.isEmpty()) {
        System.debug('Total links a eliminar (PARCIAL): ' + linksAEliminar.size());
        delete linksAEliminar;
    }

    if (!documentosAEliminar.isEmpty()) {
        System.debug('Total documentos a eliminar (TOTAL): ' + documentosAEliminar.size());
        delete documentosAEliminar;
    }

    System.debug('==== FIN TRIGGER CEN_RomperEnlaceDocumentoPorMigrado ====');
}