/**
 * @name               : CEN_massLeadEmailBatch_test
 * @author             : Diego Bravo
 * @creation date      : 23-09-2024
 * @modification date  : 26-09-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   23-09-2024   Diego Bravo   Initial Version
**/
@isTest 
public class CEN_massLeadEmailBatch_test {

    @isTest
    static void executeBatchSuccesfull(){      
        
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

        Test.startTest();
            CEN_massLeadEmailBatch obj = new CEN_massLeadEmailBatch();
            DataBase.executeBatch(obj);

            //Ejecutar scheduler  CEN_leadBatchScheduler
            CEN_leadBatchScheduler scheduler = new CEN_leadBatchScheduler();
            // Ejecutar el método 'execute' directamente
            scheduler.execute(null);
        Test.stopTest();
        
    }
}