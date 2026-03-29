/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-04-16 
* @description: Clase Test que instancia clase Bacth de actualización de Oportunidad. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-04-16           Alan Alvarez            Creación 
*  
*********************************************************************/ 
@istest
public class CEN_Opportunity_tst {
    
    @testSetup
    public static void setup(){
        
        Proyecto__c pro = new Proyecto__c();
        pro.Name ='Proyecto 1';
        pro.CEN_CODIGOSAP__c ='10U.11Etest';
        insert pro;
        
        Proyecto__c pro2 = new Proyecto__c();
        pro2.Name ='Proyecto 2';
        pro2.CEN_CODIGOSAP__c ='10U.12Etest'; 
        pro2.CEN_StatusLots__c = 'Arras';
        insert pro2;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1A';
        opp.CloseDate = System.today();
        opp.StageName='Cotización';          
        opp.CEN_Tipo_de_solicitud__c='Solicitud';
        opp.CEN_Tiene_Reserva__c='No';
        opp.CEN_Con_sustento__c='No';
        opp.CEN_Medio_Publicitario__c='0117';
        opp.CEN_Tipo_de_venta__c='CD';
        opp.Amount=1000;
        opp.CEN_Proyecto__c = pro.Id;
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp2B';
        opp2.CloseDate = System.today();
        opp2.StageName='Cotización';          
        opp2.CEN_Tipo_de_solicitud__c='Solicitud';
        opp2.CEN_Tiene_Reserva__c='No';
        opp2.CEN_Con_sustento__c='No';
        opp2.CEN_Medio_Publicitario__c='0117';
        opp2.CEN_Tipo_de_venta__c='CD';
        opp2.Amount=1000;
        opp2.CEN_Proyecto__c = pro2.Id;
        insert opp2;
        
    }
    
    /********************************************************************* 
* @description: Método para actualizar Estatus de lotes a Arras. 
*********************************************************************/     
    @isTest
    public static void CEN_OpportunityUpdateArras(){
        
        List<Id> lstproId = new List<Id>();
        
        Proyecto__c pro = [
            SELECT Id, name, CEN_StatusLots__c, CEN_ChangeInLotsStatus__c
            FROM Proyecto__c WHERE Name ='Proyecto 1'
        ];
        pro.CEN_StatusLots__c = 'Arras';
        pro.CEN_ChangeInLotsStatus__c = false;
        update pro;
        lstproId.add(pro.Id);
        
        Id batchJobId = Database.executeBatch(new CEN_Opportunity_bch(lstproId), 2000);
        
    }
    
    /********************************************************************* 
* @description: Método para actualizar Estatus de lotes de Arras a CVG. 
*********************************************************************/ 
    @isTest
    public static void CEN_OpportunityUpdateArrastoCVG(){
        
        List<Id> lstproId = new List<Id>();
        
        Proyecto__c pro2 = [
            SELECT id, name, CEN_StatusLots__c, CEN_ChangeInLotsStatus__c
            FROM Proyecto__c WHERE Name ='Proyecto 2'
        ];
        pro2.CEN_StatusLots__c = 'CVG';
        pro2.CEN_ChangeInLotsStatus__c = false;
        update pro2;
        lstproId.add(pro2.Id);
        
        Id batchJobId = Database.executeBatch(new CEN_Opportunity_bch(lstproId), 2000);
        
    }
    
}