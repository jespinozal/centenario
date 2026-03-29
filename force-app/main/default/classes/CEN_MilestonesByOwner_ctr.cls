/**
 * @description 
 * @version 8.0 - 
 * @author      juancarlos.medinaorihuela@emeal.nttdata.com
 * @date        0
 * @see       
 */
public with sharing class CEN_MilestonesByOwner_ctr {
    
    @AuraEnabled
    public static List<CaseHistory> getHistory(Id caseId){
        try {

            List<CaseHistory> chList = [SELECT Id, IsDeleted, CaseId, CreatedById, CreatedDate, Field, DataType, OldValue, NewValue from CaseHistory  WHERE field in ('Status','Owner') AND CaseId =:caseId WITH USER_MODE ORDER BY CreatedDate DESC];
            return chList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
 
    }

    @AuraEnabled
    public static List<CEN_CaseTracking__c> getHistory2(Id caseId){
        try {

            List<CEN_CaseTracking__c> chList = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CEN_Status__c,CEN_Status_Old__c, CEN_Owner__c, CEN_CaseId__c, CEN_Owner_Old__c FROM CEN_CaseTracking__c  WHERE CEN_CaseId__c =:caseId AND CEN_Owner__c != null  WITH USER_MODE ORDER BY CreatedDate DESC];
            return chList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
 
    }

    @AuraEnabled
    public static Case getCase(Id caseId){
        try {

            Case c = [SELECT Id,CreatedDate,Owner.Name FROM Case WHERE Id =:caseId WITH USER_MODE ORDER BY CreatedDate DESC];
            return c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
 
    }
}