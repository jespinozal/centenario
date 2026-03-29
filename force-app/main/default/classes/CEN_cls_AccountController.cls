public class CEN_cls_AccountController {
   
    private final Account q;
   
    public CEN_cls_AccountController(ApexPages.StandardController stdController) {
         system.debug('Entro');
        this.q = (Account)stdController.getRecord();
    }

    public List<Account> getAccounts() {
       
        system.debug('getAccounts');
        List<Account> CAccount = [SELECT id,Name, CEN_N_mero_de_documento__pc, CEN_Distrito__c, CEN_Tipo_de_documento__pc, PersonEmail, CEN_Direcci_n__c, Phone FROM Account WHERE Id =:q.Id];        
        system.debug(CAccount);
        return CAccount; 
    }
}