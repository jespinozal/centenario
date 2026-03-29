@isTest
public with sharing class CEN_UpdateLeadSubscribeActive_tst {
    
    // Helper reutilizable para obtener RecordTypeId de forma segura
    private static Id rt(String developerName) {
        return Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }

    private static Id rtEvent(String developerName) {
        return Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }
    
    @IsTest
    static void testInsertLeadOficinaConCita_CreaEvento() {
        
        Lead leadOficina = new Lead(
            FirstName = 'Pepito',
            LastName = 'Juarez',
            Email = 'pjuarez@gmail.com.test',
            MobilePhone = '+51998183833',
            Company = 'Oficina Test',
            CEN_Ruc__c = '20123456789',
            CEN_T_rminos_y_condiciones__c = true,
            LeadSource = 'Digital',
            CEN_Web__c = 'Oficinas',
            CEN_Medio__c = '0084',
            CEN_Formulario__c = 'Citas',  // ← CORREGIDO: era 'Cita'
            CEN_fld_TipoNegocio__c = 'Oficina',
            Complejo_Empresarial__c = 'San Isidro: Centro Empresarial Real',
            OFI_fld_Lead_Producto__c = 'Oficinas',
            OFI_fld_Lead_QueEstaBuscando__c = 'Alquiler de oficina implementada',
            CEN_fld_Dia_Cita__c = Date.newInstance(2025, 12, 30),
            CEN_fld_HoraCita__c = 'De 12:00 PM a 1:00 PM'  // ← Formato real del formulario
        );

        Test.startTest();
        insert leadOficina;
        Test.stopTest();

        List<Event> eventos = [
            SELECT Id, WhoId, Subject, StartDateTime, EndDateTime, RecordTypeId, OwnerId
            FROM Event 
            WHERE WhoId = :leadOficina.Id
        ];

        System.assertEquals(1, eventos.size(), 'Debe crearse exactamente un evento para leads de Oficina con cita');

        Event ev = eventos[0];
        System.assertEquals(leadOficina.Id, ev.WhoId);
        //System.assert(ev.Subject.startsWith('Cita con Lead'));

        // Verificar hora: "De 12:00 PM a 1:00 PM" → toma "12:00 PM" → 12:00 (mediodía)
        DateTime expectedStart = DateTime.newInstance(2025, 12, 30, 12, 0, 0);
        System.assertEquals(expectedStart, ev.StartDateTime);
        System.assertEquals(expectedStart.addHours(1), ev.EndDateTime);
    }
    
    @IsTest
    static void testInsertLead_Industrial() {
        
        Lead leadIndustrial = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_Tipo_de_documento__c = 'RUC',
            CEN_N_mero_de_documento__c = '20123456799',
            CEN_Rubro__c = 'Bebidas',
            CEN_T_rminos_y_condiciones__c = false,
            LeadSource = 'Digital',
            CEN_Medio__c = '0111',
            CEN_Tema_de_inter_s__c='De 500 m2 a 999 m2',
            CEN_Divisi_n_de_inter_s__c = 'Lotes industriales',
            CEN_Web__c = 'Macropolis',
            CEN_fld_TipoNegocio__c='Industrial'
        );
        
        Test.startTest();
        insert leadIndustrial;
        Test.stopTest();
    }
    /*
    @IsTest
    static void testInsertLead_Industrial2() {   
        Id rtIndustrial = rt('IND_rt_Lead_Industrial');
        
        Lead leadIndustrial = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_Tipo_de_documento__c = 'RUC',
            CEN_N_mero_de_documento__c = '20123456799',
            CEN_Rubro__c = 'Bebidas',
            CEN_T_rminos_y_condiciones__c = false,
            LeadSource = 'Digital',
            CEN_Medio__c = '0111',
            CEN_Tema_de_inter_s__c='De 500 m2 a 999 m2',
       //     RecordTypeId = null,
            CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda',
            CEN_Web__c = 'Macropolis',
            CEN_fld_TipoNegocio__c='Industrial'
            
        );
        
        Test.startTest();
        insert leadIndustrial;
        Test.stopTest();
    }*/
	
	@IsTest
    static void testInsertLead_Urbano1() {        
        Lead leadUrbano1 = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_N_mero_de_documento__c = '',
            CEN_T_rminos_y_condiciones__c = true,
            CEN_Web__c = 'Terreno',
            LeadSource = 'BTL',
            CEN_Medio__c = '0111',
            CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda'
        );
        Test.startTest();
        insert leadUrbano1;
        Test.stopTest();
    }
    
    @IsTest
    static void testInsertLead_Urbano2() {        
        Lead leadUrbano1 = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_N_mero_de_documento__c = '12345678',
            CEN_T_rminos_y_condiciones__c = false,
            CEN_Web__c = 'Terreno',
            LeadSource = 'Referidos',
            CEN_Medio__c = '0111',
            CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda'
        );
        Test.startTest();
        insert leadUrbano1;
        Test.stopTest();
    }
    
    @IsTest
    static void testInsertLead_Urbano3() {        
        Lead leadUrbano1 = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_N_mero_de_documento__c = '12345678',
            CEN_T_rminos_y_condiciones__c = false,
            CEN_Web__c = 'Terreno',
            LeadSource = 'Referidos',
            CEN_Medio__c = '0111',
            CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda'
        );
        insert leadUrbano1;
        leadUrbano1.CEN_T_rminos_y_condiciones__c = true;
        Test.startTest();
        update leadUrbano1;
        Test.stopTest();
    }
    
    @IsTest
    static void testInsertLead_Urbano4() {        
        Lead leadUrbano1 = new Lead(
        	FirstName = 'carmen',
            LastName = 'glard',
            MobilePhone = '+51996673911',
            Email = 'cgla@gmail.test.ocm',
            CEN_N_mero_de_documento__c = '',
            CEN_T_rminos_y_condiciones__c = false,
            CEN_Web__c = 'Terreno',
            LeadSource = 'Presencial',
            CEN_Medio__c = '0111',
            CEN_Divisi_n_de_inter_s__c = 'Lotes de vivienda'
        );
        insert leadUrbano1;
        Test.startTest();
        update leadUrbano1;
        Test.stopTest();
    }
}