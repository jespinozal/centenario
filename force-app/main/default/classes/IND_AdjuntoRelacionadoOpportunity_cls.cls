public with sharing class IND_AdjuntoRelacionadoOpportunity_cls {

    public static final String PREFIJO_OPPORTUNITY = Opportunity.SObjectType.getDescribe().getKeyPrefix();
    
    public static void validarYCrearAdjuntoRelacionado(List<ContentDocumentLink> documentsLink) {
        //Filtra los CDL recién creados que apuntan a un Case o Opportunity y extrae IDs
        Map<Id, Id> opportunityByDoc = new Map<Id, Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> entityIds = new Set<Id>();
        System.debug('documentsLink: ' + documentsLink);
        for (ContentDocumentLink cdl : documentsLink) {
            if (cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).startsWith(PREFIJO_OPPORTUNITY)) {
                opportunityByDoc.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                contentDocumentIds.add(cdl.ContentDocumentId);
                entityIds.add(cdl.LinkedEntityId);
            }
        }

        //Si no hay documentos relacionados a Opportunities, termina
        if (opportunityByDoc.isEmpty()) {return;}

        Boolean isValidRecordType = validateRecordType(entityIds);

        if(isValidRecordType) {
            System.debug('ENTRA');
            Set<Id> existingDocuments = getAlreadyExistingDocuments(entityIds);

            Set<Id> documentsToCreate = filterDocumentsToCreate(contentDocumentIds, existingDocuments);
            
            //Si no hay documentos nuevos para crear, termina
            if (documentsToCreate.isEmpty()) {return;}

            Map<Id, ContentDocument> docs = getDocumentsById(documentsToCreate);

            newAdjuntoRelacionado(opportunityByDoc,documentsToCreate, docs);
            System.debug('INSERTA');
        }
    }

    public static Set<Id> getAlreadyExistingDocuments(Set<Id> entityIds) {
        //Busca los Cases que están en la lista de entityIds y obtiene sus adjuntos relacionados
        Set<Id> existingDocuments = new Set<Id>();
        if (CEN_AdjuntoRelacionado__c.SObjectType.getDescribe().isAccessible()) {
            List<CEN_AdjuntoRelacionado__c> existingAdjuntoRelacionado = [
                SELECT Id, CEN_IdDocumento__c, CEN_OpportunityID__c
                FROM CEN_AdjuntoRelacionado__c 
                WHERE CEN_OpportunityID__c IN :entityIds
            ];

            //Crea un Set con los ContentDocument IDs que ya existen en los adjuntos relacionados
            for (CEN_AdjuntoRelacionado__c adjunto : existingAdjuntoRelacionado) {
                if (adjunto.CEN_IdDocumento__c != null) {
                    existingDocuments.add(adjunto.CEN_IdDocumento__c);
                }
            }
        }
        return existingDocuments;
    }

    public static Set<Id> filterDocumentsToCreate(Set<Id> contentDocumentIds, Set<Id> existingDocuments) {
        //Filtra los documentos que NO están ya creados
        Set<Id> documentsToCreate = new Set<Id>();
        for (Id docId : contentDocumentIds) {
            if (!existingDocuments.contains(docId)) {
                documentsToCreate.add(docId);
            }
        }
        return documentsToCreate;
    }

    public static Map<Id, ContentDocument> getDocumentsById(Set<Id> documentIds) {
        //Trae los títulos de los documentos que sí se van a crear
        Map<Id, ContentDocument> docs = new Map<Id, ContentDocument>();
        if (ContentDocument.SObjectType.getDescribe().isAccessible()) {
            docs = new Map<Id, ContentDocument>(
                [SELECT Id, Title FROM ContentDocument WHERE Id IN :documentIds]
            );
        }
        return docs;
    }

    public static void newAdjuntoRelacionado(Map<Id, Id> opportunityByDoc,Set<Id> documentsToCreate, Map<Id, ContentDocument> docs){
        //Crea solo los adjuntos que no existen
        List<CEN_AdjuntoRelacionado__c> newAdjuntos = new List<CEN_AdjuntoRelacionado__c>();
        for (Id docId : documentsToCreate) {
            if (opportunityByDoc.containsKey(docId)) {
                CEN_AdjuntoRelacionado__c adjuntoRelacionado = new CEN_AdjuntoRelacionado__c();
                adjuntoRelacionado.Name = 'Link al Archivo';
                adjuntoRelacionado.CEN_NombreArchivo__c= docs.get(docId).Title;
                adjuntoRelacionado.CEN_IdDocumento__c= docId;
                adjuntoRelacionado.CEN_OpportunityID__c = opportunityByDoc.get(docId);
                adjuntoRelacionado.CEN_LinkDocumento__c = 'https://centenario--devsp2.sandbox.lightning.force.com/lightning/r/ContentDocument/'+docId+'/view'; //change path
                newAdjuntos.add(adjuntoRelacionado);
            }
        }
        
        //Inserta solo los nuevos adjuntos
        if (!newAdjuntos.isEmpty()) {
            if (CEN_AdjuntoRelacionado__c.SObjectType.getDescribe().isCreateable()) {
                insert newAdjuntos;
            }
        }
    }

    public static Boolean validateRecordType(Set<Id> entityIds) {
        if (Opportunity.SObjectType.getDescribe().isAccessible()) {
            List<Opportunity> opps = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id IN :entityIds LIMIT 1];
            for (Opportunity opp : opps) {
                System.debug('opp.RecordType.DeveloperName: ' + opp.RecordType.DeveloperName);
                Set<String> validTypes = new Set<String>{'IND_rt_Oportunidad_Industrial','Industrial','OFI_rt_Oportunidad_Oficina'};//change for a custom setting if more record types are expected in the future
                System.debug('validTypes: ' + validTypes);
                if (validTypes.contains(opp.RecordType.DeveloperName)) {return true;}
            }
        }
        return false;
    }
}