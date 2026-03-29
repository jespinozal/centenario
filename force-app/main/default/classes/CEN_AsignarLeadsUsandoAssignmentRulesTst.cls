/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-08-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
@isTest
public with sharing class CEN_AsignarLeadsUsandoAssignmentRulesTst {
    @TestSetup
    static void makeData(){
         // Crear datos de prueba: un Lead de prueba
         user u = new user();
        u.Id = UserInfo.getUserId();

        //Crear Distrito
        Tabla_maestra__c varDistrito = new Tabla_maestra__c();
        varDistrito.Name = 'San Juan de Lurigancho';
        Insert varDistrito;

        //Consultar RecordType
        String recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'CEN_Urbano' WITH SYSTEM_MODE].Id;

        //Crear Lead
        Lead varLead = new Lead();
        varLead.FirstName                   = 'Margarita';
        varLead.LastName                    = 'Ugarte';
        varLead.RecordTypeId                = recordTypeId;
        varLead.MobilePhone                 = '+51123456789';
        varLead.CEN_Tipo_de_documento__c    = 'DNI';
        varLead.CEN_N_mero_de_documento__c  = '43423123';
        varLead.Status                      = 'No gestionado';
        varLead.CEN_Typification__c         = 'Lead Nuevo';
        varLead.CEN_Estado_civil__c         = 'Soltero';
        varLead.CEN_sexo__c                 = 'Femenino';
        varLead.CEN_Divisi_n_de_inter_s__c  = 'Lotes de vivienda';
        varLead.CEN_Donde_comprar__c        = 'LIMA_Lima_Norte_LU';
        varLead.CEN_Tema_de_inter_s__c      = 'Quiero comprar un lote';
        varLead.LeadSource                  = 'Presencial';
        varLead.CEN_Medio__c                = '0148';
        varLead.CEN_Distrito__c             = varDistrito.Id;
        varLead.OwnerId                     = u.Id;

        Insert varLead;
    }
    /**
    * @description Test de clase CEN_AsignarLeadsUsandoAssignmentRules
    * @author Richard Villafana - NTT DATA | 10-08-2024 
    **/
    @isTest
    public static void LeadAssign_test() {
        List<Lead> lLeads=[SELECT Id FROM Lead ];
        List<Id> lIds= new List<Id>();
        for(Lead l : lLeads){
            lIds.add(l.Id);
        }
        Test.startTest();
        CEN_AsignarLeadsUsandoAssignmentRules.LeadAssign(lIds);
        Test.stopTest();

    }
}