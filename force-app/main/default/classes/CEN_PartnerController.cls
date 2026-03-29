/**
 * @description Controlador Apex para el LWC cen_partnerViewer.
 * Obtiene los registros de Partner (Socios) relacionados con la Oportunidad
 * que está vinculada a un Caso.
 *
 * MEJORA DE SEGURIDAD: Si un mismo Account es agregado como Partner varias veces,
 * esta clase solo devolverá el registro de Partner más reciente para ese Account,
 * evitando duplicados en la vista.
 */
public with sharing class CEN_PartnerController {

    /**
     * @description Clase wrapper para la información del Partner.
     * Se implementa la interfaz 'Comparable' para permitir re-ordenar la lista final
     * alfabéticamente por el nombre de la cuenta.
     */
    public class PartnerInfo implements Comparable {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public String role;
        @AuraEnabled public String mobile;
        @AuraEnabled public String email;

        // Método de la interfaz Comparable para ordenar por nombre.
        public Integer compareTo(Object compareTo) {
            PartnerInfo compareToPartner = (PartnerInfo)compareTo;
            if (this.accountName == null || compareToPartner.accountName == null) {
                return 0;
            }
            return this.accountName.compareTo(compareToPartner.accountName);
        }
    }

    // Clase wrapper para el resultado final que se envía al LWC.
    public class PartnerResult {
        @AuraEnabled public Id opportunityId;
        @AuraEnabled public List<PartnerInfo> partners;

        public PartnerResult() {
            this.partners = new List<PartnerInfo>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static PartnerResult getOpportunityPartners(Id caseId) {
        PartnerResult result = new PartnerResult();

        Case currentCase = [SELECT AccountId, Opportunity__c FROM Case WHERE Id = :caseId LIMIT 1];
        if (currentCase == null || currentCase.Opportunity__c == null) {
            return result;
        }

        result.opportunityId = currentCase.Opportunity__c;

        // 1. CONSULTA MODIFICADA: Ahora ordenamos por CreatedDate DESC.
        // Esto pone los partners más nuevos al principio de la lista.
        List<Partner> partnerRecords = [
            SELECT Role, AccountTo.Id, AccountTo.Name, AccountTo.Phone, AccountTo.PersonEmail
            FROM Partner
            WHERE OpportunityId = :currentCase.Opportunity__c
            AND AccountToId != :currentCase.AccountId
            ORDER BY CreatedDate DESC
        ];

        // 2. LÓGICA DE DE-DUPLICACIÓN
        Set<Id> processedAccountIds = new Set<Id>();
        List<PartnerInfo> uniquePartnerInfos = new List<PartnerInfo>();

        for (Partner p : partnerRecords) {
            // Verificamos si ya hemos procesado esta cuenta de partner.
            if (!processedAccountIds.contains(p.AccountToId)) {
                // Si no, es la primera vez que la vemos (y es la más nueva). La agregamos.
                PartnerInfo info = new PartnerInfo();
                info.accountId = p.AccountToId;
                info.accountName = p.AccountTo.Name;
                info.role = p.Role;
                info.mobile = p.AccountTo.Phone;
                info.email = p.AccountTo.PersonEmail;
                uniquePartnerInfos.add(info);

                // Agregamos el ID de la cuenta al set para no volver a procesarla.
                processedAccountIds.add(p.AccountToId);
            }
        }

        // 3. ASIGNACIÓN Y RE-ORDENACIÓN
        // Asignamos la lista ya de-duplicada.
        result.partners = uniquePartnerInfos;
        // Re-ordenamos alfabéticamente la lista final para una mejor experiencia de usuario.
        result.partners.sort();

        return result;
    }
}