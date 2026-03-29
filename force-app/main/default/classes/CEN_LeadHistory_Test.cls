/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 01-08-2023
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   01-08-2023   @nttdata.com   Initial Version
**/
@isTest
public with sharing class CEN_LeadHistory_Test {
    @testSetup
    public static void setup() {
        Lead oLead = new Lead();
        oLead.Salutation = 'Sr.';
        oLead.FirstName = 'Juan';
        oLead.LastName = 'Perez';
        oLead.CEN_N_mero_de_documento__c = '99988830';
        oLead.LeadSource = 'Digital';
        oLead.CEN_Medio__c = '0138';
        oLead.MobilePhone = '900000001';
        oLead.Email = 'juan.perez@test.abc';
        oLead.CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda';
        oLead.CEN_Tema_de_inter_s__c = 'Quiero comprar un lote';
        oLead.CEN_Donde_comprar__c = 'PROV_Ica_LU';
        oLead.CEN_Elige_donde_vivir__c = 'Urbanización El Oasis';
        oLead.CEN_T_rminos_y_condiciones__c = true;
        insert oLead;

        Event evt = new Event();
        evt.WhoId = oLead.Id;
        evt.CEN_Evento__c = 'Llamada';
        evt.Description = 'Llamar a las 9:00 pm';
        //evt.fecha = date.today();
        evt.CEN_Estado__c = 'Realizado';
        evt.CEN_Contacto__c = 'Cliente Contestó';
        evt.CEN_Valores_Contacto__c = 'Se agendó videollamada';
        evt.Subject = 'Primera Llamada';
        evt.DurationInMinutes = 60;
        evt.ActivityDateTime = datetime.now();
        insert evt;
    }

    @isTest
    public static void leadHistorySuccess(){
        Lead oLead = [SELECT Id FROM Lead LIMIT 1];
    	Test.startTest();
        List<CEN_LeadHistory_ctr.wrapperLead> lista = new List<CEN_LeadHistory_ctr.wrapperLead>();
        lista = CEN_LeadHistory_ctr.fetchLeads(oLead.Id);
        System.assertNotEquals(lista, null, 'Es nulo'); // not good
        Test.stopTest();
    }

    @isTest
    public static void leadHistoryReactivoSuccess(){
        Lead oldLead = [SELECT Id FROM Lead LIMIT 1];
        Test.setCreatedDate(oldLead.Id, Date.today().addDays(-30));
        Test.startTest();
        List<CEN_LeadHistory_ctr.wrapperLead> listaReactivo = new List<CEN_LeadHistory_ctr.wrapperLead>();
        Lead oLeadReactivo = new Lead();
        oLeadReactivo.Salutation = 'Sr.';
        oLeadReactivo.FirstName = 'Juan';
        oLeadReactivo.LastName = 'Perez';
        oLeadReactivo.CEN_N_mero_de_documento__c = '99988830';
        oLeadReactivo.LeadSource = 'Digital';
        oLeadReactivo.CEN_Medio__c = '0138';
        oLeadReactivo.MobilePhone = '900000001';
        oLeadReactivo.Email = 'juan.perez@test.abc';
        oLeadReactivo.CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda';
        oLeadReactivo.CEN_Tema_de_inter_s__c = 'Quiero comprar un lote';
        oLeadReactivo.CEN_Donde_comprar__c = 'PROV_Ica_LU';
        oLeadReactivo.CEN_Elige_donde_vivir__c = 'Urbanización El Oasis';
        oLeadReactivo.CEN_T_rminos_y_condiciones__c = true;
        insert oLeadReactivo;
        System.debug('oLeadReactivo: ' + oLeadReactivo);
        listaReactivo = CEN_LeadHistory_ctr.fetchLeads(oLeadReactivo.Id);
        System.assertNotEquals(listaReactivo, null, 'Es nulo'); // not good

        Test.stopTest();
    }
}