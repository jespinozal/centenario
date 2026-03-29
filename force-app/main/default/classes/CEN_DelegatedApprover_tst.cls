/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-04-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-04-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_DelegatedApprover_tst {
    @testSetup
    public static void setup() {
   
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        List<User> usuarios = new List<User>();
        System.runAs(thisUser){
        Id perfil = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_de_ventas_urbano'].Id;
        for(Integer i=1;i<=3; i++){
            User u = new User(
                ProfileId = perfil,
                LastName = 'A000' + i + ' Supervisor',
                Email = 'puser000@amamama.com',
                Username = 'pbuser000'+i+'@amamama.com',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Caseta_de_Venta__c = 'ZV023',
                LocaleSidKey = 'en_US',
                CorreoAD__c='ASESOR1@TEST.TEST',
                CEN_UserNameAD__c ='ASESOR1'
            ); 
        	usuarios.add(u);	    
        }
        System.debug('usuarios: '+usuarios);
        insert usuarios;
    }
        
        List<CEN_DelegatedApprover__c> ApproverList = new List<CEN_DelegatedApprover__c>();
        CEN_DelegatedApprover__c oApprover1= new CEN_DelegatedApprover__c();
        oApprover1.CEN_Supervisor__c = usuarios[0].Id;
        oApprover1.CEN_Project__c='Test Project1';
        ApproverList.add(oApprover1);
            
        CEN_DelegatedApprover__c oApprover2= new CEN_DelegatedApprover__c();
        oApprover2.CEN_Supervisor__c = usuarios[1].Id;
        oApprover2.CEN_Project__c='Test Project2';
        ApproverList.add(oApprover2);
        
        /*CEN_DelegatedApprover__c oApproverN= new CEN_DelegatedApprover__c();
        oApproverN.CEN_Supervisor__c = usuarios[0].Id;
        oApproverN.CEN_Project__c='Test ProjectN';
        ApproverList.add(oApproverN);*/
            
        insert ApproverList;
       
    } 
    
    @isTest
    public static void DelegatedApproverExistingUpdate(){
    	Test.startTest();
        CEN_DelegatedApprover__c approverExisting = [Select CEN_Supervisor__c From CEN_DelegatedApprover__c Where CEN_Project__c = 'Test Project2' Limit 1];
        Id usuario = [Select Id From User Where LastName = 'A0003 Supervisor' Limit 1].Id;
        approverExisting.CEN_Supervisor__c = usuario; 	 
        update approverExisting;
        Test.stopTest();
        System.assertEquals(approverExisting.CEN_Supervisor__c,usuario);
    }
  
    @isTest
    public static void DelegatedApproverExistingUpdateDuplicate(){
        
        CEN_DelegatedApprover__c approverExisting = [Select CEN_Supervisor__c From CEN_DelegatedApprover__c Where CEN_Project__c = 'Test Project2' Limit 1];
        Id usuario = [Select Id From User Where LastName = 'A0001 Supervisor' Limit 1].Id;
        
        try{
           Test.startTest(); 
           approverExisting.CEN_Supervisor__c = usuario; 	 
           update approverExisting;
           Test.stopTest();
        }catch(DmlException ex){
            System.assertNotEquals(ex.getMessage(),null);
            System.Debug(ex);
        } 
    }
    
    @isTest
    public static void DelegatedApproverExistingInsertDuplicate(){
        
        CEN_DelegatedApprover__c oApprover1= new CEN_DelegatedApprover__c();
        try{
            Test.startTest();
            Id usuario = [Select Id From User Where LastName = 'A0001 Supervisor' Limit 1].Id;
            oApprover1.CEN_Supervisor__c = usuario;
            oApprover1.CEN_Project__c='Test Project3';
            insert oApprover1;
            Test.stopTest();
        }catch(DmlException ex){
            System.assertEquals(oApprover1.Id,null); 
            System.Debug(ex);
        } 
    }
}