/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 09-10-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   09-10-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_DebidaDiligenciaQueueable_ctr implements Queueable,Database.AllowsCallouts{

    private Partner[] partners;
    public CEN_DebidaDiligenciaQueueable_ctr(Partner[] partnerList) {
        //this.partners = [SELECT Id,AccountToId FROM Partner WHERE Id IN: partnerList];
        this.partners = partnerList;
    }

    public void execute(QueueableContext context) {
        if (partners!=null && partners.size()> 0){
            System.debug('partners: ' + partners);
            System.debug('Fecha: ' + Datetime.now());
            //Account acc = [SELECT Id, FirstName, LastName, CEN_N_mero_de_documento__pc FROM Account WHERE Id =: partners[0].AccountToId];
            //partners.remove(0);
            //CEN_DebidaDiligenciaQueueable_ctr esync = new CEN_DebidaDiligenciaQueueable_ctr(partners);
            //System.enqueueJob(esync,1);
            Set<Id> idsAccount = new Set<Id>();
            String idOpportunity = partners[0].OpportunityId;
            for(Partner p : partners){
                idsAccount.add(p.AccountToId);
            }

            List<Account> listAcc = [SELECT Id, FirstName, LastName, CEN_N_mero_de_documento__pc FROM Account WHERE Id =: idsAccount];
            //System.debug(acc.FirstName + '/' + acc.LastName + '/' + acc.CEN_N_mero_de_documento__pc + '/' + partners[0].OpportunityId);
            for(Account acc : listAcc){
                if(!TEST.isRunningTest()){
                    CEN_DebidaDiligencia_ctr.BusquedaGoogleDebidaDiligenciaAsinc(acc.FirstName, acc.LastName, acc.CEN_N_mero_de_documento__pc, idOpportunity);
                }
            }
        }
    }
}