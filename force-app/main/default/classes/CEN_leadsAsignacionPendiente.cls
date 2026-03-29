/**
 * @name               : CEN_leadsAsignacionPendiente
 * @author             : Diego Bravo
 * @creation date      : 19-09-2024
 * @modification date  : 07-10-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   19-09-2024   Diego Bravo   Initial Version
**/
public with sharing class CEN_leadsAsignacionPendiente {

    static final Integer    TIEMPO_ESPERA   = 20;
    static final String     EMAIL_SUBJECT   = 'Centenario Salesforce - Lead sin asignar';
    static final String     TARGET_REPLACE  = '{leadDetail}';
    
    public static LeadWrapper getleadsPendientes(List<String> leadIdList){

        LeadWrapper leadWrapper = new LeadWrapper();
        try {
            Map<String,String> leadMap = omnichannelLeadStatus(leadIdList);
            List<String> filterLeadList = new List<String>(leadMap.keySet()); 
            Map<String,String> leadEmailBodyMap = obtenerLeadEmailBody(filterLeadList, leadMap);
        
            leadWrapper.filteredLeads = filterLeadList;
            leadWrapper.leadEmailMap = leadMap;
            leadWrapper.leadEmailBodyMap = leadEmailBodyMap;

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return leadWrapper;
    }

    private static Map<String,String> omnichannelLeadStatus(List<String> leadIds){
        Integer delayTime;
        Datetime fechaInicial;
        Datetime fechaActual;
        List<AgentWork> agentList = new List<AgentWork>();
        Map<String,String> leadMap = new Map<String,String>();

        agentList = [SELECT WorkItemId, OriginalQueueId, RequestDateTime FROM AgentWork WHERE WorkItemId IN: leadIds AND PendingServiceRoutingId <> '' AND (Status = 'Declined' OR Status = 'Assigned' OR Status = 'DeclinedOnPushTimeout') WITH SYSTEM_MODE ORDER BY CreatedDate DESC];
        List<String> queueId = new List<String>();
        
        if (!test.isRunningTest()){
            for (AgentWork varAgent : agentList) {
                queueId.add(varAgent.OriginalQueueId);
                System.debug('AgentWork OriginalQueueId: '+ varAgent.OriginalQueueId + 'AgentWork WorkItemId: '+varAgent.WorkItemId);
            }
        }
        else {
            List<Group> testGroup = [SELECT Id FROM Group WHERE DeveloperName = 'CEN_Lima_Norte' WITH SYSTEM_MODE];
            for (Group varGroup : testGroup) {
                queueId.add(varGroup.Id);
            }
        }

        Map<String, String> groupMemberMap = getGroupMember(queueId);
        Map<String,String> emailMap = getEmailSupervisor(groupMemberMap);

        for (AgentWork varAgent : agentList) {
            fechaInicial = varAgent.RequestDateTime;
            fechaActual = System.now();

            if (fechaInicial != null && fechaActual != null && fechaActual > fechaInicial) {
                delayTime = Integer.valueOf((fechaActual.getTime() - fechaInicial.getTime()) / (1000 * 60));
            }

            if (delayTime > TIEMPO_ESPERA) {
                leadMap.put(varAgent.WorkItemId, emailMap.get(varAgent.OriginalQueueId));
            }
            
        }
        
        System.debug('Leads: ' + leadIds.size());
        System.debug('Tamaño Leads: ' + agentList.size());
        System.debug('leadMap: ' + leadMap);
        System.debug('leadMap size: ' + leadMap.size());

        return leadMap;
    }

    private static Map<String,String> getGroupMember(List<String> queueId){

        Map<String, String> groupMemberMap = new Map<String, String>();
        List<GroupMember> groupMemberList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN: queueId WITH SYSTEM_MODE];
        List<String> memberGroupIdList = new List<String>();
        for (GroupMember varMember : groupMemberList) {
            memberGroupIdList.add(varMember.UserOrGroupId);
        }

        List<Group> groupList = [SELECT Id, RelatedId FROM Group WHERE Id IN: memberGroupIdList WITH SYSTEM_MODE];
        List<String> relatedList = new List<String>();
        for (Group varGroup : groupList) {
            relatedList.add(varGroup.RelatedId);
        }

        for (GroupMember varGroupMember : groupMemberList) {
            for (Group varGroup : groupList) {
                if (varGroupMember.UserOrGroupId == varGroup.Id) {
                        groupMemberMap.put(varGroupMember.GroupId, varGroup.RelatedId);
                }
            }
        }
        return groupMemberMap;

    }

    private static Map<String,String> getEmailSupervisor ( Map<String,String> groupMemberMap){
        
        Set<String> queueId = groupMemberMap.keySet();
        List<String> queueList = new List<String>(queueId);
        List<String> relatedList = new List<String>();
        for (Integer i = 0; i < queueList.size(); i++)  {
            relatedList.add(groupMemberMap.get(queueList[i]));
        }

        List<UserRole> userRoleList = [SELECT Id, ParentRoleId FROM UserRole WHERE Id IN: relatedList WITH SYSTEM_MODE];
        List<String> parentIdList = new List<String>();
        for (UserRole varRole : userRoleList) {
            parentIdList.add(varRole.ParentRoleId);
        }

        List<User> userList = [SELECT UserRoleId, Email FROM User WHERE UserRoleId IN: parentIdList WITH SYSTEM_MODE];
        Map<String,String> emailMap = new Map<String,String>();

        for (Integer i = 0; i < queueList.size(); i++)  {
            for (UserRole varUserRole : userRoleList) {
                for (User varUser : userList) {
                    if (groupMemberMap.get(queueList[i]) == varUserRole.Id && varUserRole.ParentRoleId == varUser.UserRoleId) {
                        emailMap.put(queueList[i], varUser.Email);
                    }
                }
            }
        }

        return emailMap;

    }

    private static Map<String,String> obtenerLeadEmailBody(List<String> filterLeadList, Map<String,String> leadMap){
        System.debug('obtenerLeadEmailBody filterLeadList:'+filterLeadList);
        System.debug('obtenerLeadEmailBody leadMap:'+leadMap);


        Set<String> emailSupervisorSet = new Set<String>();
        List<String> emailSupervisorList = new List<String>();




        String bodyEmailTemp = '';
        String bodyEmail;
        Map<String,String> leadBodyMap = new Map<String,String>();
        List<Lead> leadDetails = new List<Lead>();
        String emailTemplateBody = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CEN_emailNotificarSupervisorLead' WITH SYSTEM_MODE].HtmlValue;
        leadDetails = [SELECT Id, Name, Status, CEN_Typification__c, CreatedDate FROM Lead WHERE Id IN: filterLeadList WITH USER_MODE];

        // for (Lead varLead : leadDetails) {
            
        //     bodyEmailTemp = '<li>Nombre Lead: '     + varLead.Name                  + '</li>' +
        //                     '<li>Fecha Creación: '  + varLead.CreatedDate           + '</li>' +
        //                     '<li>Estado: '          + varLead.Status                + '</li>' + 
        //                     '<li>Tipificación: '    + varLead.CEN_Typification__c   + '</li>';

        //     bodyEmail = emailTemplateBody.replace(TARGET_REPLACE, bodyEmailTemp);
            
        //     leadBodyMap.put(varLead.Id, bodyEmail);
        // }

        for(Integer i = 0; i < filterLeadList.size(); i++){
            emailSupervisorSet.add(leadMap.get(filterLeadList[i]));
        }
        System.debug('obtenerLeadEmailBody emailSupervisorSet add:'+emailSupervisorSet);

        emailSupervisorList.addAll(emailSupervisorSet);
        System.debug('obtenerLeadEmailBody emailSupervisorList addAll:'+emailSupervisorList);


        for(Integer i = 0; i < emailSupervisorList.size(); i++){
            bodyEmail = '';
            bodyEmailTemp = '';
            for (Lead varLead : leadDetails) {
                if(emailSupervisorList[i] == leadMap.get(varLead.Id)){
                    bodyEmailTemp = bodyEmailTemp + '<li>Nombre Lead: '     + varLead.Name                  + '</li>' +
                    '<li>Fecha Creación: '  + varLead.CreatedDate.format()  + '</li>' +
                    '<li>Estado: '          + varLead.Status                + '</li>' + 
                    '<li>Tipificación: '    + varLead.CEN_Typification__c   + '</li>' +
                    '<li>URL: '             + URL.getOrgDomainURL().toExternalForm() + '/' + varLead.Id + '</li>' + '<br>';

                    
                }
            }
            bodyEmail = emailTemplateBody.replace(TARGET_REPLACE, bodyEmailTemp);
            leadBodyMap.put(emailSupervisorList[i], bodyEmail);
        }

        return leadBodyMap;
    }

    public class LeadWrapper{
        public List<String> filteredLeads;
        public Map<String,String> leadEmailMap;
        public Map<String,String> leadEmailBodyMap;
    }
}