public with sharing class ONI_class_Opportunity_LeftDocuments {
    @AuraEnabled(cacheable=true)
    public static List<Boolean> ONI_class_Opportunity_LeftDocuments_find(Id opportunityId, String documentName) {
        System.debug('opportunityId: ' + opportunityId);
        System.debug('documentName: ' + documentName);
        List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                          FROM ContentDocumentLink 
                                          WHERE LinkedEntityId = :opportunityId 
                                          LIMIT 1000];
        
        if (links.isEmpty()) return new List<Boolean>{false};
        
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            documentIds.add(link.ContentDocumentId);
        }
        
        List<ContentDocument> docs = [SELECT Title FROM ContentDocument 
                                     WHERE Id IN :documentIds 
                                     AND Title LIKE :('%' + documentName + '%')];

        // Normalize search term: remove accents and convert to lowercase
        String normalizedSearchTerm = normalizeString(documentName);

        for (ContentDocument doc : docs) {
            String normalizedTitle = normalizeString(doc.Title);
            if (normalizedTitle.contains(normalizedSearchTerm)) {
                return new List<Boolean>{true};
            }
        }

        return new List<Boolean>{false};
    }

    private static String normalizeString(String input) {
        if (String.isBlank(input)) return '';
        
        return input.toLowerCase()
                    .replace('á', 'a').replace('é', 'e').replace('í', 'i').replace('ó', 'o').replace('ú', 'u')
                    .replace('ñ', 'n').replace('ü', 'u');
    }
}