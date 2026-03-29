/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 13-10-2023
 * @last modified by  : Luis Maldonado
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-10-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_PartnerHelper_ctr {

    @AuraEnabled(cacheable=true)
    public static List<PartnerRole> getPartnerRole(){
        try {
            List<PartnerRole> listPartnerRole = new List<PartnerRole>();
            listPartnerRole = [SELECT Id, MasterLabel FROM PartnerRole];
            return listPartnerRole;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=false)
    public static Partner[] savePartners(Partner[] partnerList){
            insert partnerList;
            ID jobID = System.enqueueJob(new CEN_DebidaDiligenciaQueueable_ctr(partnerList));
        return partnerList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getPartner(String oppId) {
    Opportunity oportunidad = null;
    Account cliente = null;
    List<Account> cuentas_socios_oportunidad = new List<Account>();
    List<OpportunityPartner> socios_de_oportunidad = new List<OpportunityPartner>();

        oportunidad = [
            SELECT
            Id,
            Type,
            AccountId
            FROM Opportunity
            WHERE Id = :oppId
            LIMIT 1
        ];

        if (
        oportunidad != null &&
        oportunidad.Type != null //&&
        //oportunidad.Type == 'Natural'
        ) {
        socios_de_oportunidad = [
            SELECT
            Id,
            OpportunityId,
            AccountToId,
            Role,
            IsPrimary,
            CreatedDate,
            CreatedById,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            IsDeleted,
            ReversePartnerId
            FROM OpportunityPartner
            WHERE
            OpportunityId = :oppId
            AND AccountToId != :oportunidad.AccountId
            AND IsDeleted = FALSE
        ];
        Set<Id> socios_id = new Set<Id>();
        if (socios_de_oportunidad != null && socios_de_oportunidad.size() > 0) {
            for (OpportunityPartner opt : socios_de_oportunidad) {
            socios_id.add(opt.AccountToId);
            }
        }
        cuentas_socios_oportunidad = [
            SELECT
            Id,
            Name,
            LastName,
            FirstName,
            CEN_N_mero_de_documento__pc,
            CEN_Numero_de_documento_del__c,
            Phone,
            PersonEmail,
            PersonMobilePhone,
            CEN_Lugar_de_nacimiento__pc,
            CEN_Distrito__c,
            CEN_Distrito__pc,
            CEN_Distrito__r.Name,
            CEN_Distrito__r.Departamento__c,
            CEN_Distrito__r.Provincia__c,
            CEN_Distrito__pr.Name,
            CEN_Distrito__pr.Departamento__c,
            CEN_Distrito__pr.Provincia__c,
            CEN_Direcci_n__c,
            CEN_Direccion__pc,
            toLabel(CEN_Nacionalidad__pc),
            CEN_Tel_fono_Trabajo__pc,
            CEN_Fecha_de_Nacimiento__c,
            CEN_Nro_deudor_SAP__pc,
            CEN_Tipo_de_documento__c,
            CEN_Tipo_de_documento__pc,
            CEN_Nro_deudor_SAP__c,
            RecordType.Name,
            PersonContactId,
            Moneda__pc,
            CEN_Estado_civil__pc,
            CEN_Tipo_de_relaci_n_laboral__pc,
            CEN_Jefe_Directo__pc,
            CEN_Profesion_u_oficio__pc,
            CEN_Cargo_que_ocupa__pc,
            CEN_Promedio_Mensual_Ingresos__pc,
            CEN_Centro_de_trabajo__c,
            CEN_Direcci_n_Centro_de_Trabajo__pc,
            CEN_Referencia_direccion__c,
            CEN_fld_Numero_de_partida_registral__c,
            CEN_fld_Detalle_de_actividad__c,
            CEN_fld_Tiene_apoderado__c,
            CEN_fld_Nombres_Apoderado__c,
            CEN_fld_Apellidos_apoderado__c,
            CEN_fld_Apellido_mat_apoderado__c,
            CEN_fld_Tipo_de_documento_de_apoderado__c,
            CEN_fld_Numero_de_documento_apoderado__c,
            toLabel(CEN_fld_Nacionalidad_apoderado__c),
            CEN_fld_Direccion_apoderado__c,
            CEN_fld_Correo_empresa__c,
            CEN_paisResidencia__pc
            FROM Account
            WHERE Id IN :socios_id
        ];
        }

    return cuentas_socios_oportunidad;
    }

    @AuraEnabled(cacheable=false)
    public static void deletePartner(String accountId) {
        Partner[] deletePartner=[SELECT Id, AccountToId  FROM Partner WHERE AccountToId=:accountId];
        try {
            delete deletePartner;
        } catch (DmlException e) {
            // Process exception here
        }

        CEN_SearchDueDiligence__c[] deleteDueDiligence=[SELECT Id, Name, AccountId__c FROM CEN_SearchDueDiligence__c WHERE AccountId__c=:accountId];
        try {
            delete deleteDueDiligence;
        } catch (DmlException e) {
            // Process exception here
        }
    }

}