public with sharing class CEN_BotEnhAssociateToMessagingSession {
@InvocableMethod(label='Asociar al messaging session por bot enh' description='Asociar al messaging session por bot enh')
    /**
    * @description Método encargado de asociar valores al messaging session
    * @param input datos que necesita el lead 
    */
    public static void associate(List<Request> input) {

        if(input == null || input.size() <> 1){
            return;  
        } 

        Request req = input[0];
        
        if (Schema.sObjectType.MessagingSession.isUpdateable()) {

            updateFieldsMessagingSession(req);
        
        } 
    }

    /**
     * @description Actualiza campos del objeto Messaging Session
     * @param req Request que viene del bot
    **/
    public static void updateFieldsMessagingSession(Request req){
        MessagingSession ms = getMessagingSession(req.MessagingSessionId);
        
        setValuesSales(ms,req);
        setValuesPostSales(ms,req);
        
        update ms;
        
        updateLeadAndOpportunityAsync(req.LeadId, req.MessagingSessionId, req.OpportunityId);
    }
    
     private static MessagingSession getMessagingSession(Id sessionId) {
        return [SELECT OpportunityId, CEN_Executive__c, LeadId, CaseId, CEN_Queue__c, CEN_CaseToken__c, CEN_MarcaFlujoLead__c
                FROM MessagingSession 
                WHERE Id = :sessionId LIMIT 1];
    }
    
    private static void setValuesSales(MessagingSession ms, Request req){
        ms.OpportunityId     	= String.isNotBlank(req.OpportunityId)? req.OpportunityId : ms.OpportunityId;
        ms.LeadId            	= String.isBlank(req.OpportunityId) && String.isNotBlank(req.LeadId)? req.LeadId : ms.LeadId;
        ms.CEN_MarcaFlujoLead__c = String.isNotBlank(req.OpportunityId) || String.isNotBlank(req.LeadId)?  obtainFlowMark(req.OpportunityId, req.LeadId, ms.CEN_MarcaFlujoLead__c) : ms.CEN_MarcaFlujoLead__c;
    }
    
    private static void setValuesPostSales(MessagingSession ms, Request req){
        ms.CEN_Executive__c   	= String.isNotBlank(req.ExecutiveId)? req.ExecutiveId : ms.CEN_Executive__c;	
        ms.CaseId 				= String.isNotBlank(req.CaseId) ? req.CaseId : (String.isBlank(req.CaseId) && String.isNotBlank(req.CaseToken) ? obtainCaseId(req.CaseToken) : ms.CaseId);
        ms.CEN_Queue__c       	= String.isNotBlank(req.QueueId)? req.QueueId : ms.CEN_Queue__c;
        ms.CEN_CaseToken__c   	= String.isNotBlank(req.CaseToken)? req.CaseToken : ms.CEN_CaseToken__c;
    }
    
    /**
     * @description Obtener marca flujo
     * @param opportunityId id de oportunidad
     * @param leadId id de lead
     * @param flowMark marca flujo
     * @return devuelve el marca flujo correspondiente
    **/
    public static String obtainFlowMark(String opportunityId, String leadId, String flowMark){
        if (String.isNotBlank(opportunityId)) {
            List<Opportunity> opportunityList = [SELECT CEN_MarcaFlujoDE__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];
            if (!opportunityList.isEmpty()) {
                return opportunityList[0].CEN_MarcaFlujoDE__c;
            }
        } else if (String.isNotBlank(leadId)) {
            List<Lead> leadList = [SELECT CEN_MarcaFlujoDE__c FROM Lead WHERE Id =: leadId WITH SECURITY_ENFORCED LIMIT 1];
            if (!leadList.isEmpty()) {
                return leadList[0].CEN_MarcaFlujoDE__c;
            }
        } 
        return flowMark;
    }
    
    /**
     * @description Método futuro actualizar lead y oportunidad
     * @param leadId id de lead
     * @param messagingSessionId id del messaging session
     * @param oppId id de oportunidad
    **/
    @future
    public static void updateLeadAndOpportunityAsync(String leadId, String messagingSessionId, String oppId) {
         if (String.isNotBlank(oppId) && Schema.sObjectType.Opportunity.isUpdateable()) {
            
            List<String> convertedStatusOpp = new List<String>();
            for (OpportunityStage os : [SELECT ApiName FROM OpportunityStage WHERE IsClosed = true WITH SECURITY_ENFORCED]) {
                convertedStatusOpp.add(os.ApiName);
            }
            Opportunity updateOpportunity = [SELECT CEN_IdConversacion__c, StageName
                                             FROM Opportunity
                                             WHERE Id =: oppId
                                             WITH SECURITY_ENFORCED
                                             LIMIT 1];
            
            if (!convertedStatusOpp.contains(updateOpportunity.StageName)) {
                updateOpportunity.CEN_IdConversacion__c = messagingSessionId;
            	update updateOpportunity;
            }
        } else if (String.isNotBlank(leadId) && Schema.sObjectType.Lead.isUpdateable()) {
            
            List<String> convertedStatusLead = new List<String>();
            for (LeadStatus ls : [SELECT ApiName FROM LeadStatus WHERE IsConverted = true OR ApiName IN ('Desestimado') WITH SECURITY_ENFORCED]) {
                convertedStatusLead.add(ls.ApiName);
            }
            
            Lead updateLead = [SELECT Id, CEN_IdConversacion__c, Status 
                               FROM Lead 
                               WHERE Id = :leadId 
                               WITH SECURITY_ENFORCED
                               LIMIT 1];
            
            if (!convertedStatusLead.contains(updateLead.Status)) {
                updateLead.CEN_IdConversacion__c = messagingSessionId;
                update updateLead;
            }
            

        }
    }

    /**
     * @description obtiene el id del caso mediante el token
     * @param token
     * @return devuelve el id del caso
    **/
    public static String obtainCaseId(String token){
        List<Case> listCases = new List<Case>([SELECT Id FROM Case 
                                               WHERE CEN_CaseToken__c =: token
                                               WITH SECURITY_ENFORCED
                                               ORDER BY CreatedDate DESC 
                                               LIMIT 1]);
        
        return listCases.size()>0? listCases[0].Id : null;
    }
    
    /**
    * @description datos que se obtiene del bot
    */
    public class Request {
        @InvocableVariable public String messagingSessionId;
        @InvocableVariable public String opportunityId;
        @InvocableVariable public String executiveId;
        @InvocableVariable public String leadId;
        @InvocableVariable public String caseId;
        @InvocableVariable public String queueId;
        @InvocableVariable public String channel;
        @InvocableVariable public String caseToken;
    }
}