trigger CEN_UpdateAccountSubscribeActive_tgr on Account (before update) {
    if (Trigger.isBefore) {
        for(Account acc: trigger.new){
            if(acc.Prospecto_acept_t_rminos_y_condiciones__c){
                if (acc.Prospecto_acept_t_rminos_y_condiciones__c != trigger.oldMap.get(acc.Id).Prospecto_acept_t_rminos_y_condiciones__c)
                {
                    CEN_UpdateSubscriberService_cls.executeSubscriberApi(acc.id);
                    System.debug('active-Subscribe: ' + acc.id);
                }
            }
        }
    }
}