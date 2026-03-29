//Developer: Jose Miguel Espinoza Mestanza
//Email: josemiguel.espinozamestanza@emeal.nttdata.com
public with sharing class CEN_AdjuntosRelacionadosController {
    @AuraEnabled(cacheable=true)
    public static List<CEN_AdjuntoRelacionado__c> obtenerAdjuntosPorCaso(Id caseId) {
        if (caseId == null) return new List<CEN_AdjuntoRelacionado__c>();
        return [
            SELECT Id, Name, CEN_CaseID__c, CEN_NombreArchivo__c, CEN_TipoDocumentoCaso__c, CEN_EstadoDocumento__c, CEN_Archivado__c, CEN_Migrado__c, CEN_IdDocumento__c, CEN_LinkDocumento__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_CaseID__c = :caseId
            ORDER BY CEN_TipoDocumentoCaso__c, CEN_NombreArchivo__c ASC
            LIMIT 10000
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<CEN_AdjuntoRelacionado__c> obtenerAdjuntosPorCasoYTipo(Id caseId, String tipoDocumento) {
        if (caseId == null || String.isBlank(tipoDocumento)) return new List<CEN_AdjuntoRelacionado__c>();
        return [
            SELECT Id, Name, CEN_CaseID__c, CEN_NombreArchivo__c, CEN_TipoDocumentoCaso__c, CEN_EstadoDocumento__c, CEN_Archivado__c, CEN_Migrado__c, CEN_IdDocumento__c, CEN_LinkDocumento__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_CaseID__c = :caseId
              AND CEN_TipoDocumentoCaso__c = :tipoDocumento
            ORDER BY CEN_TipoDocumentoCaso__c, CEN_NombreArchivo__c ASC
            LIMIT 10000
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<CEN_AdjuntoRelacionado__c> obtenerAdjuntosPorCasoYSeccion(
        Id caseId,String seccion,Boolean esArchivado
    ){
        Boolean flag = (esArchivado == null) ? false : esArchivado;
        return [
            SELECT Id,Name,CEN_CaseID__c, CEN_Documento__c,CEN_Seccion__c,CEN_TipoDocumentoCaso__c,CEN_EstadoDocumento__c,CEN_NombreArchivo__c,CEN_LinkDocumento__c,CEN_Archivado__c,CEN_Migrado__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE CEN_CaseID__c = :caseId
            AND CEN_Seccion__c = :seccion
            AND CEN_Archivado__c = :flag
            ORDER BY Name
        ];
    }
}