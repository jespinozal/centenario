public class CEN_cls_LeadController {
   
    private final Lead q;
   
    public CEN_cls_LeadController(ApexPages.StandardController stdController) {
         system.debug('Entro');
        this.q = (Lead)stdController.getRecord();
    }

    public List<Lead> getLeads() {
       
        List<Lead> CLead = [SELECT id,Name,CEN_N_mero_de_documento__c,Phone,Email,CEN_Direcci_n_Prospecto__c, CEN_Tipo_de_documento__c FROM Lead WHERE Id =:q.Id];
        /*List<Lead> CLead = [SELECT id,Name,CEN_N_mero_de_documento__c,Phone,Email,CEN_Direcci_n_Prospecto__c,CEN_Distrito__c,Distrito__c,MobilePhone,CEN_Medio__c,CEN_Tipo_de_documento__c FROM Lead WHERE Id ='00Q1k000002sy3pEAA']; */
        system.debug(Clead);
        return CLead; 
    }
    
}