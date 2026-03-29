/********************************************************************************
* @author       : Joel Espinoza (jespilud@nttdata.com)
* @date         : 2021-04-14
* @description  : Servicio para actualizar terminos y servicios.
*
* VERSION       DATE            AUTOR                   ACTION
* 0.1           2021-04-14      Joel Espinoza           Creación
* 0.2           2024-02-22      Joel Espinoza           Actualizar recordtype
* 0.3			2026-02-09		Elvis Quintanilla		Optimización de consultas por transacción
********************************************************************************/
trigger CEN_UpdateLeadSubscribeActive_tgr on Lead (before update, before insert, after insert) {
    // Record Types
    /*Id recordIdLeadUrbano             = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano']?.Id;
    Id recordIdLeadUrbanoProspeccion  = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano_Prospeccion_Campo']?.Id;
    Id recordIdLeadIndustrialNuevo    = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'IND_rt_Lead_Industrial']?.Id; // Elvis
    Id recordIdLeadOficina            = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'OFI_rt_Lead_Oficina']?.Id; // Elvis
    Id recordIdLeadIndustrial         = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Industrial']?.Id;*/
    
    // BEFORE
    if (Trigger.isBefore) {
        System.debug('this is before');
        // BEFORE update
        if(Trigger.isUpdate){
            System.debug('this is update');
            for(Lead ld: trigger.new){
                /* Por si se cambia a Keep the existing Record Type */
                if(ld.CEN_Divisi_n_de_inter_s__c == 'Lotes industriales'){
                    if(!String.isBlank(ld.CEN_Rubro__c)){
                        ld.Industry = ld.CEN_Rubro__c;
                    }
                    if(!String.isBlank(ld.CEN_Tema_de_inter_s__c)){
                        ld.IND_fld_Lead_AreaInteres__c =ld.CEN_Tema_de_inter_s__c;
                    }
                }
				
                // BEFORE update [URBANO]
                if(ld.CEN_T_rminos_y_condiciones__c){
                    if (ld.CEN_T_rminos_y_condiciones__c != trigger.oldMap.get(ld.Id).CEN_T_rminos_y_condiciones__c){
                        CEN_UpdateSubscriberService_cls.executeSubscriberApi(ld.id);
                        System.debug('active-Subscribe: ' + ld.id);
                    }
                }
                
                if (ld.LeadSource == 'BTL') {
                    Id recordIdLeadUrbanoProspeccion  = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano_Prospeccion_Campo']?.Id;
                    System.debug('ld.LeadSource' + ld.LeadSource);
                    ld.RecordTypeId = recordIdLeadUrbanoProspeccion;
                }/* else if (ld.LeadSource == 'Referidos') {
                    System.debug('ld.LeadSource' + ld.LeadSource);
                    ld.RecordTypeId = recordIdLeadUrbano;
                } else if(ld.recordTypeId != recordIdLeadUrbanoProspeccion){
                    if(ld.CEN_Divisi_n_de_inter_s__c == 'Lotes de vivienda'){
                        System.debug('recordIdLeadUrbano: ' + recordIdLeadUrbano);
                        ld.RecordTypeId = recordIdLeadUrbano;
                    } 
                }*/
            }
        }
        // BEFORE insert
        if(Trigger.isInsert){
            System.debug('this is insert');
            for(Lead ld: trigger.new){
                System.debug('name y record type: '+ld.Name + ' '+ ld.RecordTypeId);
                
                Id recordIdLeadIndustrialNuevo    = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'IND_rt_Lead_Industrial']?.Id; // Elvis
                Id recordIdLeadOficina            = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'OFI_rt_Lead_Oficina']?.Id; // Elvis
                
                if(ld.CEN_fld_TipoNegocio__c=='Oficina' || ld.CEN_fld_TipoNegocio__c=='Industrial'){
                    if(!String.isBlank(ld.CEN_Rubro__c)){
                        ld.Industry = ld.CEN_Rubro__c;
                    }
                    ld.Status='IND_Nuevo';
                    ld.ONI_fld_Lead_FechaMuestraInteresCliente__c=Date.today();
                    if(ld.CEN_Formulario__c=='Salas' && ld.LeadSource=='Digital'){
                        ld.OFI_fld_Lead_QueEstaBuscando__c = 'Salas';
                    }
                }
                if(ld.CEN_fld_TipoNegocio__c=='Oficina' && ld.LeadSource=='Digital' && ld.CEN_Formulario__c!='Salas'){
                    ld.OFI_fld_Lead_QueEstaBuscando__c = 'Oficinas';
                }
                if(ld.CEN_fld_TipoNegocio__c=='Industrial'){
                    if(ld.CEN_Tipo_de_documento__c=='RUC'){
                        ld.CEN_Tipo_de_documento__c='';
                    	ld.CEN_RUC__c=ld.CEN_N_mero_de_documento__c;
                        ld.CEN_N_mero_de_documento__c='';
                    }
                    if(!String.isBlank(ld.CEN_Tema_de_inter_s__c)){
                        ld.IND_fld_Lead_AreaInteres__c =ld.CEN_Tema_de_inter_s__c;
                    }
                }
                
                if(ld.RecordTypeId==recordIdLeadIndustrialNuevo || ld.RecordTypeId==recordIdLeadOficina){
                    continue;
                }
                
                // Record Types
                Id recordIdLeadUrbanoProspeccion  = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano_Prospeccion_Campo']?.Id;
                
                // BEFORE insert [URBANO]
                if (ld.LeadSource == 'BTL' && ld.CEN_Divisi_n_de_inter_s__c == 'Lotes de vivienda') {
                    System.debug('ld.LeadSource' + ld.LeadSource);
                    ld.RecordTypeId = recordIdLeadUrbanoProspeccion;
                } else if (ld.LeadSource == 'Referidos' && ld.CEN_Divisi_n_de_inter_s__c == 'Lotes de vivienda') {
                    System.debug('ld.LeadSource' + ld.LeadSource);
                    Id recordIdLeadUrbano = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano']?.Id;
                    ld.RecordTypeId = recordIdLeadUrbano;
                } else if(ld.recordTypeId != recordIdLeadUrbanoProspeccion){
                    if(ld.CEN_Divisi_n_de_inter_s__c == 'Lotes de vivienda'){
                        Id recordIdLeadUrbano = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'CEN_Urbano']?.Id;
                        System.debug('recordIdLeadUrbano: ' + recordIdLeadUrbano);
                        ld.RecordTypeId = recordIdLeadUrbano;
                    }
                }
            }
        }
    }
    // AFTER
    if(Trigger.isAfter){
        System.debug('this is after ABC0504');
        Id recordIdEventCita = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND DeveloperName = 'OFI_rt_Event_Visita']?.Id;
        List<Event> eventosToInsert = new List<Event>();
        Set<Id> leadsConCita = new Set<Id>();

        //Validar RecordType Oficina y Campos Cita
        for(Lead ld : Trigger.new){
            if (ld.CEN_fld_Dia_Cita__c==null || ld.CEN_fld_HoraCita__c==null || ld.CEN_Formulario__c != 'Citas') { //Trigger.isUpdate || ld.RecordTypeId!=recordIdLeadOficina || 
                continue ;
            }
            leadsConCita.add(ld.Id);
        }

        if(!leadsConCita.isEmpty()){
            // Traer Name y campos necesarios
            Map<Id, Lead> leadsMap = new Map<Id, Lead>(
                [SELECT Id, Name, CEN_fld_Dia_Cita__c, CEN_fld_HoraCita__c, OwnerId
                 FROM Lead WHERE Id IN :leadsConCita]
            );

            for(Lead ld : leadsMap.values()){
                try {
                    Date dia = ld.CEN_fld_Dia_Cita__c;
                    String horaInicioStr = ld.CEN_fld_HoraCita__c;

                    String[] partes = horaInicioStr != null ? horaInicioStr.split(' ') : new String[]{};
                    if (partes.size() >= 3){
                        String timePart = partes[1] + ' ' + partes[2]; // "11:00 AM"
                        String[] horaMin = timePart.split(':');
                        Integer horaNum = Integer.valueOf(horaMin[0]);
                        Integer minutoNum = Integer.valueOf(horaMin[1].substring(0,2));
                        if (timePart.contains('PM') && horaNum != 12) horaNum += 12;
                        if (timePart.contains('AM') && horaNum == 12) horaNum = 0;

                        Time hora = Time.newInstance(horaNum, minutoNum, 0, 0);
                        System.debug('Hora parseada desde "' + horaInicioStr + '": ' + hora);

                        DateTime startDT = DateTime.newInstance(dia, hora);
                        DateTime endDT = startDT.addHours(1);
                        
                        Id idDeUsuarioDefault='0054T000000Gvs5QAC';
                        Id OwnerId = ld.OwnerId.getSObjectType() == User.SObjectType ? ld.OwnerId : idDeUsuarioDefault;

                        Event ev = new Event(
                            WhoId = ld.Id,
                            Subject = 'Visita',//'Cita con Lead ' + ld.Name,
                            StartDateTime = startDT,
                            OwnerId =OwnerId,//ld.OwnerId,
                            EndDateTime = endDT,
                            RecordTypeId = recordIdEventCita // Oficina: Visita
                        );
                        eventosToInsert.add(ev);
                        System.debug('Evento preparado: Lead ' + ld.Id + ' - Inicio: ' + startDT + ' Fin: ' + endDT);
                    } else {
                        System.debug('Formato de hora inválido en Lead ' + ld.Id + ': ' + horaInicioStr);
                    }
                } catch(Exception e){
                    System.debug('Error creando evento para Lead ' + ld.Id + ': ' + e.getMessage());
                }
            }
        }

        if(!eventosToInsert.isEmpty()){
            try {
                insert eventosToInsert;
                System.debug('Eventos insertados: ' + eventosToInsert.size());
                for(Event ev : eventosToInsert){
                    System.debug('Evento creado Id: ' + ev.Id + ' - Lead relacionado (WhoId): ' + ev.WhoId);
                }
            } catch(Exception e){
                System.debug('Error al insertar eventos: ' + e.getMessage());
            }
        }
    }
}