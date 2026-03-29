/**
 * @description       : Visualizar Historial de Leads Reactivos LWC (wcCEN_ReactiveLeadHistory)
 * @author            : @nttdata.com
 * @last modified on  : 24-07-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author           Modification
 * 2.0   24-07-2023   @nttdata.com     initial
**/
public without sharing class CEN_LeadHistory_ctr {
    @AuraEnabled(cacheable=true)
    public static list<wrapperLead> fetchLeads(String recordId){
        List<Lead> lstLead = new List<Lead>();
        List<Event> lstEvent = new List<Event>();
        Set<Id> idsLead = new Set<Id>();
        List<wrapperLead> lstLeadFormat = new List<wrapperLead>();
        List<wrapperLead> lstLeadFormatNew = new List<wrapperLead>();
        String parent = [SELECT CEN_LeadParent__c FROM Lead WHERE Id =: recordId]?.CEN_LeadParent__c;
        if(parent != null){
            lstLead = [SELECT Id,
                    Name,
                    LeadSource,
                    tolabel(CEN_Medio__c),
                    CreatedDate,
                    Owner.Name,
                    CEN_Elige_donde_vivir__c,
                    CEN_LeadParent__c,
                    CEN_Typification__c,
                    CEN_NumberRetries__c,
                    MobilePhone,
                    Status
                    FROM Lead
                    WHERE CEN_LeadParent__c =: parent
                    OR Id =: parent
                    ORDER BY CEN_Elige_donde_vivir__c ASC,
                    CreatedDate DESC];
        }else{
            lstLead = [SELECT Id,
                    Name,
                    LeadSource,
                    tolabel(CEN_Medio__c),
                    CreatedDate,
                    Owner.Name,
                    CEN_Elige_donde_vivir__c,
                    CEN_LeadParent__c,
                    CEN_Typification__c,
                    CEN_NumberRetries__c,
                    MobilePhone,
                    Status
                    FROM Lead
                    WHERE CEN_LeadParent__c =: recordId
                    OR Id =: recordId
                    ORDER BY CEN_Elige_donde_vivir__c ASC,
                    CreatedDate DESC];
        }

        for(Lead ld : lstLead){
            idsLead.add(ld.Id);
        }

        lstEvent = [SELECT Id,
                    WhoId,
                    Subject,
                    CreatedDate,
                    StartDateTime,
                    EndDateTime,
                    CEN_Tipo__c,
                    CEN_Canal__c,
                    CEN_Medio__c,
                    CEN_Oficina__c,
                    Description,
                    Owner.Name,
                    CEN_Estado__c,
                    CEN_Contacto__c,
                    CEN_Evento__c,
                    CEN_Valores_Contacto__c,
                    CreatedBy.Name
                    FROM Event
                    WHERE WhoId IN: idsLead
                    AND CEN_Estado__c = 'Realizado'
                    ORDER BY CreatedDate DESC];

        for(Lead ld : lstLead){
            WrapperLead newLead = new WrapperLead();
            newLead.id = ld.Id;
            newLead.name = ld.Name;
            newLead.medio = ld.CEN_Medio__c;
            newLead.canal = ld.LeadSource;
            newLead.fechaHora = ld.CreatedDate;
            newLead.fecha = ld.CreatedDate.date(); //Formatear fecha aqui
            newLead.hora = ld.CreatedDate.time();
            newLead.propietario = ld.Owner.Name;
            newLead.proyecto = ld.CEN_Elige_donde_vivir__c;
            newLead.leadPadre = ld.CEN_LeadParent__c;
            newLead.tipologia = ld.CEN_Typification__c;
            newLead.intento = ld.CEN_NumberRetries__c;
            newLead.celular = ld.MobilePhone;
            newLead.estado = ld.Status;
            List<WrapperEvent> lstEventNew = new List<WrapperEvent>();
            for(Event evt : lstEvent){
                if(evt.WhoId == ld.id){
                    WrapperEvent evtWrapper = new WrapperEvent();
                    evtWrapper.id = evt.Id;
                    evtWrapper.evento = evt.CEN_Evento__c;
                    evtWrapper.descripcion = evt.Description;
                    evtWrapper.fecha = evt.CreatedDate;
                    evtWrapper.estado = evt.CEN_Estado__c;
                    evtWrapper.contacto = evt.CEN_Contacto__c;
                    evtWrapper.valorContacto = evt.CEN_Valores_Contacto__c;
                    evtWrapper.asunto = evt.Subject;
                    evtWrapper.active = true;
                    lstEventNew.add(evtWrapper);
                    newLead.eventos = lstEventNew;
                }
            }
            lstLeadFormat.add(newLead);
        }

        System.debug('Add Eventos');
        System.debug(lstLeadFormat);

        return lstLeadFormat;
    }

    public class WrapperLead{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String medio {get;set;}
        @AuraEnabled
        public String canal {get;set;}
        @AuraEnabled
        public DateTime fechaHora {get;set;}
        @AuraEnabled
        public Date fecha {get;set;}
        @AuraEnabled
        public Time hora {get;set;}
        @AuraEnabled
        public String propietario {get;set;}
        @AuraEnabled
        public String proyecto {get;set;}
        @AuraEnabled
        public String leadPadre {get;set;}
        @AuraEnabled
        public String tipologia {get;set;}
        @AuraEnabled
        public Decimal intento {get;set;}
        @AuraEnabled
        public String celular {get;set;}
        @AuraEnabled
        public String estado {get;set;}
        @AuraEnabled
        public List<WrapperEvent> eventos {get;set;}
    }

    public class WrapperEvent{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String evento {get;set;}
        @AuraEnabled
        public String descripcion {get;set;}
        @AuraEnabled
        public DateTime fecha {get;set;}
        @AuraEnabled
        public String estado {get;set;}
        @AuraEnabled
        public String contacto {get;set;}
        @AuraEnabled
        public String valorContacto {get;set;}
        @AuraEnabled
        public String asunto {get;set;}
        @AuraEnabled
        public Boolean active {get;set;}
    }
}