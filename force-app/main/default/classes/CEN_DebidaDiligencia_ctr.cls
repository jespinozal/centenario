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
public with sharing class CEN_DebidaDiligencia_ctr {
    public static Map<String, Object> BusquedaGoogleDebidaDiligencia(String firstName, String lastName, String numberDocument, String idOpportunity) {
        CEN_DebidaDiligenciaRequest mapReq = new CEN_DebidaDiligenciaRequest();
        Map<String, Object> mapResp = new Map<String, Object>();
        CEN_DebidaDiligenciaRequest mapResult = new CEN_DebidaDiligenciaRequest();

        try {

            String usuario = [SELECT Owner.Name FROM Opportunity WHERE Id =: idOpportunity]?.Owner.Name;
            mapReq.first_name = firstName;
            mapReq.last_name = lastName;
            mapReq.dni_ce = numberDocument;
            mapReq.opportunity = idOpportunity;
            mapReq.wSystem = 'SF01';
            mapReq.user = usuario;
            mapReq.entity_type = 'N';

            mapResult = validarFiltros(mapReq);
            mapResp = CEN_DebidaDiligencia_cls.DebidaDiligencia(mapResult);
            System.debug('mapResp: ' + mapResp);

            List<CEN_SearchDueDiligence__c> listSearchDueDiligence = new List<CEN_SearchDueDiligence__c>();
            List<CEN_DebidaDiligenciaResponse>  respList = (List<CEN_DebidaDiligenciaResponse>)mapResp.get('success');
            List<CEN_SearchDueDiligence__c> listSearchDueDiligenceDelete = new List<CEN_SearchDueDiligence__c>();
            if(respList != null && respList.size() > 0){
                String idAccount = [SELECT Id FROM Account WHERE CEN_N_mero_de_documento__pc =: numberDocument LIMIT 1]?.Id;
                for(CEN_DebidaDiligenciaResponse resp : respList){
                    CEN_SearchDueDiligence__c searchDueDiligence = new CEN_SearchDueDiligence__c();
                    String primeraLLave = resp.first_keyword;
                    String segundaLlave = resp.second_keyword != '' ? resp.second_keyword : 'general';
                    String template = '{0} - {1}';
                    List<Object> parameters = new List<Object> {primeraLLave, segundaLlave};
                    searchDueDiligence.Name = String.format(template, parameters);
                    searchDueDiligence.CEN_FirstKeyword__c = primeraLLave;
                    searchDueDiligence.CEN_SecondKeyword__c = segundaLlave;
                    searchDueDiligence.CEN_ExistsResults__c = resp.exists_results;
                    String StringTime = resp.wDatetime;
                    List<String> DateAndTimeList = StringTime.split(' ');
                    List<String> dayList = DateAndTimeList[0].split('/');
                    List<string> timeList = DateAndTimeList[1].split(':');
                    DateTime dt = DateTime.newInstance(Integer.valueOf(dayList[2]), Integer.valueOf(dayList[1]), Integer.valueOf(dayList[0]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2].split('\\.')[0]));
                    searchDueDiligence.CEN_SearchDateTime__c =  dt;
                    searchDueDiligence.CEN_SystemRequest__c = resp.wSystem;
                    searchDueDiligence.OpportunityId__c = resp.opportunity;
                    searchDueDiligence.AccountId__c = idAccount;
                    searchDueDiligence.CEN_DniCe__c = resp.dni_ce;
                    List<String> resultado = new List<String>();
                    for(CEN_DebidaDiligenciaResponse.results result : resp.results){
                        String titulo = 'Título: ' + result.title + '<br/>';
                        String enlace = 'Enlace: ' + result.link + '<br/>';
                        String descripcion = 'Descripción: ' + result.description + '<br/><br/>';
                        resultado.add(titulo + enlace + descripcion);
                    }
                    searchDueDiligence.CEN_Results__c = String.join(resultado,',');
                    listSearchDueDiligence.add(searchDueDiligence);
                }
                listSearchDueDiligenceDelete = [SELECT Id FROM CEN_SearchDueDiligence__c WHERE AccountId__c =:idAccount AND OpportunityId__c =: idOpportunity];
            }

            System.debug('listSearchDueDiligenceDelete: ' + listSearchDueDiligenceDelete);
            if(listSearchDueDiligenceDelete.size() > 0){
                delete listSearchDueDiligenceDelete;
            }

            if(listSearchDueDiligence!= null && listSearchDueDiligence.size()>0){
                insert listSearchDueDiligence;
            }

        } catch (Exception ex) {
            mapResp.put('error', ex.getMessage());
        }
        return mapResp;
    }

    private static CEN_DebidaDiligenciaRequest validarFiltros(CEN_DebidaDiligenciaRequest mapData) {
        CEN_DebidaDiligenciaRequest mapResult = new CEN_DebidaDiligenciaRequest();
        Set <String> dataSet = new Set<String>();
        return mapData;
    }

    @future(callout=true)
    public static void BusquedaGoogleDebidaDiligenciaAsinc(String firstName, String lastName, String numberDocument, String idOpportunity) {
        Map<String, Object> mapResp = BusquedaGoogleDebidaDiligencia(firstName, lastName, numberDocument, idOpportunity);
    }

    @InvocableMethod(label='procesoDebidaDiligencia')
    public static List<String> procesoDebidaDiligencia(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].idOpportunity!=null){
            for(Integer i=0; i < parameters.size(); i++){
                if(i==0){
                    BusquedaGoogleDebidaDiligenciaAsinc(parameters[0].firstName, parameters[0].lastName, parameters[0].numberDocument, parameters[0].idOpportunity);
                    resp.add(parameters[0].idOpportunity+'procesado');
                }else{
                    resp.add(parameters[0].idOpportunity+'noProcesado');
                }
            }
        }else{
            resp.add('vacio');
        }
        return resp;
    }

    @AuraEnabled(cacheable=true)
    public static String getBannerDetail(String idOpportunity) {
        Set<Id> idAccounts = new Set<Id>();
        List<CEN_SearchDueDiligence__c> listDueDiligence = [SELECT AccountId__c FROM CEN_SearchDueDiligence__c WHERE OpportunityId__c =:idOpportunity];
        for(CEN_SearchDueDiligence__c dueDiligence : listDueDiligence){
            idAccounts.add(dueDiligence.AccountId__c);
        }
        List<Account> listAccount = [SELECT FirstName, LastName FROM Account WHERE Id IN:idAccounts];
        List<String> nombres = new List<String>();
        for(Account acc : listAccount){
            nombres.add(acc.FirstName + ' ' + acc.LastName);
        }
        return String.join(nombres, ' - ');
    }

    public class FlowParameters {
        @InvocableVariable(label='idOpportunity' description='Id de la Oportunidad' required=true)
        public String idOpportunity;
        @InvocableVariable(label='firstName' description='Nombres' required=true)
        public String firstName;
        @InvocableVariable(label='lastName' description='Apellidos' required=true)
        public String lastName;
        @InvocableVariable(label='numberDocument' description='Numero de documento' required=true)
        public String numberDocument;
    }

    public class DebidaDiligenciaException extends Exception {
    }
}