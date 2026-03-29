public with sharing class CEN_Prospectoempresa {

    @AuraEnabled
    public static string getProspectoEmpresa (string rsocial, string ruc, string id)
    {
        string resultado='ok';
        
        String idrt = [select Id from RecordType where sObjectType='Lead' and Name='Industrial'].id;
        List <Lead> lead = [select Id, Company, CEN_RUC__c,recordtypeId from lead where id=:Id];
        
        lead[0].Company=rsocial;
        lead[0].CEN_RUC__c=ruc;
        lead[0].recordtypeId=idrt;
       	system.debug('Información del lead'+ lead);
        update lead;
        system.debug('Información del lead2'+ lead);

        return resultado;
    }
}