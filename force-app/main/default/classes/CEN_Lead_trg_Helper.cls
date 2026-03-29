/**
 * @description       : Clase helper para el trigger de prospectos
 * @author            : Adolfo Crispin
 * @group             : Protiviti
 * @last modified on  : 10-17-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Modifications Log
 * Ver   Date         Author           Modification
 * 2.0   29-01-2021   Adolfo Crispin   Asignar supervisor
**/
public class CEN_Lead_trg_Helper {
    /**
    * @description: analiza si los nuevos prospectos son duplicados con registrados
    * @author Adolfo Crispin | 29-01-2021
    * @param List<Lead> newleads
    * @return Map<String, Id>
    * @last modified by  : Richard Villafana - NTT DATA
    * Descripción: Se modificó el orden de los registros coincidentes, previamente se ordenaban de mayor a menor obteniendo el más antiguo.
    Actualmente toma al registro coincidente más actual para evaluar la fecha de creación en el método crearReactivo
    **/
    public static Map<String, Id> getCoincidentes(List<Lead> newleads){
        Map<String, Id> coincidentes= new Map<String, Id>();
        List<String> ndocs = new List<String>();
        List<String> sines = new List<String>();
        List<String> nlids = new List<String>();
        //List<String> nproyectos = new List<String>();
        String leads_n ='';
        String name='';
        for(Lead ld:newleads){
            // if(ld.CEN_N_mero_de_documento__c=='000000000'||ld.CEN_Tipo_de_documento__c=='Sin especificar'){
            //     name = ld.FirstName+' '+ld.LastName;
            //     sines.add(name.toUpperCase().trim());
            // }else{
                ndocs.add(ld.CEN_N_mero_de_documento__c);
            //}
            if(ld.Id!=null){
                nlids.add(ld.Id);
                //nproyectos.add(ld.CEN_Elige_donde_vivir__c);
                leads_n += ld.Id+', ';
            }
        }
        System.debug('sines' + sines);
        System.debug('ndocs' + ndocs);
        List<Lead> leads_coincidentes_ndocs = [SELECT Id, CEN_N_mero_de_documento__c, CEN_Tipo_de_documento__c,
                                               IsDeleted, FirstName, LastName, IsConverted, CEN_Elige_donde_vivir__c  FROM Lead
                                               WHERE CEN_N_mero_de_documento__c IN :ndocs
                                               AND Id NOT IN :nlids ORDER BY CreatedDate DESC
                                               LIMIT 50000];
        //Mapa de leads coincidentes. 
        //Key = Documento, Valor = Lista de Leads que tienen el mismo numero de documento.
        Map <String, List<Lead>> mapDocumentoLead = new Map <String, List<Lead>>();
        for(Lead l : leads_coincidentes_ndocs){
            // Si el número de documento ya existe en el mapa, agregamos el lead a la lista existente
            if(mapDocumentoLead.containsKey(l.CEN_N_mero_de_documento__c)){
                mapDocumentoLead.get(l.CEN_N_mero_de_documento__c).add(l);
            } else {
                // Si el número de documento no existe en el mapa, creamos una nueva lista con el lead actual
                mapDocumentoLead.put(l.CEN_N_mero_de_documento__c, new List<Lead>{l});
            }
        }
        //Recorrer nuevos leads y encontrar coincidentes
        Integer i=0;
        for(Lead l: newleads){
            //Validar que el lead tiene duplicados
            if(mapDocumentoLead.containsKey(l.CEN_N_mero_de_documento__c)){
                //Si tiene duplicados, se debe obtener el primer registro, que es el último insertado en Salesforce para comparar fechas de creación.}
                //El método se invoca en before y after insert, aún no existe el id, por lo tanto se setea el número de posición.
                coincidentes.put(l.Id==null?String.valueOf(i):l.Id, mapDocumentoLead.get(l.CEN_N_mero_de_documento__c)[0].Id);
            }
            i++;
        }
        /*List<Lead> leads_coincidentes_ndocs = [SELECT Id, CEN_N_mero_de_documento__c, CEN_Tipo_de_documento__c,
                                               IsDeleted, FirstName, LastName, IsConverted, CEN_Elige_donde_vivir__c  FROM Lead
                                               WHERE CEN_N_mero_de_documento__c IN :ndocs
                                               AND Id NOT IN :nlids ORDER BY CreatedDate ASC
                                               LIMIT 50000];*/

        // List<Lead> leads_coincidentes_sines = [SELECT Id, CEN_N_mero_de_documento__c, CEN_Tipo_de_documento__c,
        //                                        IsDeleted, FirstName, LastName, IsConverted, CEN_Elige_donde_vivir__c FROM Lead
        //                                        WHERE Name IN :sines
        //                                        AND Id NOT IN :nlids ORDER BY CreatedDate ASC LIMIT 50000];

        //System.debug('leads_coincidentes_sines' + leads_coincidentes_sines);
        /*Integer position = -1;
        for(Integer i=0;i<newleads.size();i++){
            position = -1;
            //if(newleads[i].CEN_N_mero_de_documento__c=='000000000'||newleads[i].CEN_Tipo_de_documento__c=='Sin especificar'){
            //    position = searchLeadBySines(newleads[i], leads_coincidentes_sines);
            //    if(position>-1){
            //        coincidentes.put(newleads[i].Id==null?String.valueOf(i):newleads[i].Id, leads_coincidentes_sines[position].Id);
            //    }
            //}else{
                position = searchLeadByNdoc(newleads[i], leads_coincidentes_ndocs);
                if(position>-1){
                    coincidentes.put(newleads[i].Id==null?String.valueOf(i):newleads[i].Id, leads_coincidentes_ndocs[position].Id);
                }
                // if(leads_coincidentes_ndocs.size()>0){
                //     coincidentes.put(newleads[i].Id==null?String.valueOf(i):newleads[i].Id, leads_coincidentes_ndocs[0].Id);
                // }
            //}
        }*/
        return coincidentes;
    }

    public static Integer searchLeadByNdoc(Lead ld, List<Lead>leads){
        Integer min=0;
        Integer max=leads.size()-1;
        Integer middle = null;
        Integer res = null;
        String name1='';
        String name2='';
        while(min<=max){
            middle = min + (max - min) / 2;
            name1 = (ld.CEN_N_mero_de_documento__c+ld.CEN_Tipo_de_documento__c);
            name2 = (leads[middle].CEN_N_mero_de_documento__c+leads[middle].CEN_Tipo_de_documento__c);
            res = name1.compareTo(name2);
            if (res == 0) { return middle;
            }
            if (res > 0){ min = middle + 1;
            }
            else{
                max = middle - 1;
            }
        }
        return -1;
    }

    public static Integer searchLeadBySines(Lead ld, List<Lead>leads){
        Integer min=0;
        Integer max=leads.size()-1;
        Integer middle = null;
        Integer res = null;
        String name1='';
        String name2='';
        while(min<=max){
            middle = min + (max - min) / 2;
            name1 = (ld.FirstName+' '+ld.LastName).toUpperCase().trim();
            name2 = (leads[middle].FirstName+' '+leads[middle].LastName).toUpperCase().trim();
            res = name1.compareTo(name2);
            if (res == 0) {
                //System.debug('name1: '+name1+'= name2: '+name2);
                return middle;
            }
            if (res > 0){
                min = middle + 1;
            }
            else{
                max = middle - 1;
            }
        }
        return -1;
    }
    private static String VALUE_NINGUNO = 'Ninguno';
    /**
    * @description: creara tareas y se asignara a los supervisores
                    segun la lista de registros de enrutamientos
    * @author Adolfo Crispin | 29-01-2021
    * @param Map<String Id> coincidentes
    * @param List<Lead> newleads
    **/
    public static void crearTareas(Map<String, Id> coincidentes, List<Lead> newleads){
        System.debug(coincidentes);
        System.debug(newleads);
        Map<String,Set<Id>> mapEligeDondeVivir_x_Supervisores = getMapEnrutadores(newleads);
        List<Task> tareas = new List<Task>();
        //List<Lead> lstLeads = new List<Lead>();
        List<Cookies__c> Cookies = new List<Cookies__c>();
        Map<Id,Lead> originales = new Map<Id,Lead>([
            SELECT Id, Name, FirstName, OwnerId, CEN_N_mero_de_documento__c, CEN_Tipo_de_documento__c, MobilePhone, Email, CEN_LeadReactive__c, CEN_StatusMobilePhone__c, CEN_StatusEmail__c,
            LastName, IsConverted, ConvertedContactId, ConvertedAccountId, CreatedById, CEN_ClientID__c,CEN_campaign_id__c,CEN_utm_campaign__c,CEN_utm_content__c,CEN_utm_medium__c,CEN_utm_source__c,
            CEN_StartDateContact__c, CEN_EndDateContact__c, CEN_StartTimeContact__c, CEN_EndTimeContact__c
            FROM Lead WHERE Id IN :coincidentes.values() LIMIT 50000
        ]);
        List<String> converted_acounts = new List<String>();
        List<String> owners = new List<String>();

        for(Lead ld:originales.values()){
            if(ld.IsConverted){
                converted_acounts.add(ld.ConvertedAccountId);
            }
            owners.add(ld.OwnerId);
        }
        Map<Id, Account> cuentas_prospectos = new Map<Id, Account>([
            SELECT Id, IsPersonAccount, RecordTypeId, RecordType.Name
            FROM Account
            WHERE ID IN :converted_acounts
        ]);
        Map<Id, Group> grupos = new Map<Id, Group>([
            SELECT Id
            FROM Group
            WHERE Id IN :owners LIMIT 50000
        ]);

        Group grupo = null;
        String ownerid='';
        String proyecto = '';
        String canalpros = '';
        String mediopros = '';
        String medioprosLabel = '';
        String selectedOAC = null;
        String task_subject = '';
        String task_description = '';
        List<String> task_owners = new List<String>();
        User admin = null;
        Account cuenta=null;
        try{
            admin = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'Administrador del sistema' LIMIT 1];
        }catch(Exception ex){
            System.debug('No se encontro usuario admin');
        }
        Schema.DescribeFieldResult objFieldDescribe = Lead.CEN_Medio__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for(String str:coincidentes.keySet()){
            Id id_lead_r = coincidentes.get(str);
            Lead prospecto = originales.get(id_lead_r);
            Lead ld = newleads[Integer.valueOf(str)];
            selectedOAC = ld.CEN_Oficina_de_Venta2__c;

            if(prospecto!=null&&prospecto.IsConverted){
                cuenta = cuentas_prospectos.get(prospecto.ConvertedAccountId);
            }else{
                cuenta = null;
            }
            if(String.isBlank(ld.CEN_Elige_donde_vivir__c)){
                proyecto = VALUE_NINGUNO;
            }else{
                proyecto = ld.CEN_Elige_donde_vivir__c;
            }
            if(String.isBlank(ld.LeadSource)){
                canalpros = 'Presencial';
            }else{
                canalpros = ld.LeadSource;
            }
            if(String.isNotBlank(ld.CEN_Medio__c)){
                for (Schema.PicklistEntry objPickList : lstPickListValues) {
                    if(objPickList.getValue()==ld.CEN_Medio__c){
                        medioprosLabel = objPickList.getLabel();
                        break;
                    }
                }
            }else{
                medioprosLabel = VALUE_NINGUNO;
            }
            if(String.isNotBlank(ld.CEN_Medio__c)){
                 mediopros = ld.CEN_Medio__c;
            }else{
                mediopros = VALUE_NINGUNO;
            }
            try{
                grupo = grupos.get(prospecto.OwnerId);
            }catch(Exception ex){
                System.debug('No se encontro grupo');
            }
            if(grupo!=null){
                if(String.isNotBlank(System.UserInfo.getUserId())){
                    ownerid=System.UserInfo.getUserId();
                }else{
                    ownerid=admin.Id;
                }
            }else{
                ownerid = prospecto.OwnerId;
            }
            Datetime createdtm = Datetime.now();
            Date createdt = Date.today();
            try{
                if(ld.CreatedDate!=null){
                    createdtm = ld.CreatedDate;
                    createdt = Date.newInstance(ld.CreatedDate.year() , ld.CreatedDate.month(), ld.CreatedDate.day());
                }
            }catch(Exception ex){
                System.debug('Execution: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            }

            task_subject = 'Prospecto ' + prospecto.name + ' se registro por el canal: ' + canalpros + ', medio: '+mediopros+', proyecto interesado: ' + proyecto;

            task_description = 'Hacer seguimiento al prospecto interesado en el proyecto: ' + proyecto;
            task_description =  ld.MobilePhone != null && prospecto.MobilePhone != ld.MobilePhone && ld.CEN_StatusMobilePhone__c != 'Confirmado' ?
                                task_description +
                                '\n El número telefónico es nuevo: ' + ld.MobilePhone +
                                '\n El número telefónico aún no ha sido validado' :
                                '';

            task_description =  ld.Email != null && prospecto.Email != ld.Email && ld.CEN_StatusEmail__c != 'Existe' ?
                                task_description +
                                '\n El email es nuevo: ' + ld.Email +
                                '\n El email aún no ha sido validado' :
                                '';
                                System.debug('mapEligeDondeVivir_x_Supervisores: ' + mapEligeDondeVivir_x_Supervisores);
                                System.debug('proyecto: ' + proyecto);
            if(mapEligeDondeVivir_x_Supervisores.keySet().contains(proyecto)){
                for(Id supervisor : mapEligeDondeVivir_x_Supervisores.get(proyecto)){
                    // si los owners para la nueva tarea esta vacia, entonces agregar una sola vez
                    // comentar o quitar esta condicional para que se agregue todos supervisores y crea tareas para cada uno de ellos
                    if(task_owners.isEmpty()){
                        task_owners.add(supervisor);
                    }
                }
            }else{
                task_owners.add(ownerid);
            }

            Lead objLead;

            for(String task_owner : task_owners){
                if(prospecto.IsConverted){
                    // tareas.add(new Task (Subject = task_subject,  Description = task_description, CEN_Medio__c = mediopros, CEN_MobilePhone__c = ld.MobilePhone,
                    //                     CEN_Canal__c = canalpros, OwnerId = task_owner, ActivityDate = createdt, CEN_Email__c = ld.Email,
                    //                     CEN_Motivo__c = ld.CEN_Motivo__c, CEN_Proyecto__c = proyecto, CEN_Reactivo__c = 'true',
                    //                     CEN_StatusMobilePhone__c = ld.CEN_StatusMobilePhone__c, CEN_StatusEmail__c = ld.CEN_StatusEmail__c,
                    //                     CEN_StartDateContact__c = ld.CEN_StartDateContact__c, CEN_EndDateContact__c = ld.CEN_EndDateContact__c, CEN_StartTimeContact__c = ld.CEN_StartTimeContact__c,
                    //                     CEN_EndTimeContact__c = ld.CEN_EndTimeContact__c, WhoId = prospecto.ConvertedContactId, CreatedDate=createdtm, CEN_Oficina_de_Venta_Aux__c = selectedOAC));
                    // if(String.isNotBlank(ld.Company)){
                    //     if(String.isNotBlank(cuenta.RecordTypeId)&&cuenta.RecordType.Name=='Cuenta Jurídica'){
                    //         tareas.add(new Task (Subject = task_subject,  Description = task_description, CEN_Medio__c = mediopros, CEN_MobilePhone__c = ld.MobilePhone,
                    //                             CEN_Canal__c = canalpros, OwnerId = task_owner, ActivityDate = createdt, CEN_Email__c = ld.Email,
                    //                             CEN_Motivo__c = ld.CEN_Motivo__c, CEN_Proyecto__c = proyecto, CEN_Reactivo__c = 'true',
                    //                             CEN_StatusMobilePhone__c = ld.CEN_StatusMobilePhone__c, CEN_StatusEmail__c = ld.CEN_StatusEmail__c,
                    //                             CEN_StartDateContact__c = ld.CEN_StartDateContact__c, CEN_EndDateContact__c = ld.CEN_EndDateContact__c, CEN_StartTimeContact__c = ld.CEN_StartTimeContact__c,
                    //                             CEN_EndTimeContact__c = ld.CEN_EndTimeContact__c, WhatId = prospecto.ConvertedAccountId, CreatedDate=createdtm, CEN_Oficina_de_Venta_Aux__c = selectedOAC));
                    //     }
                    // }
                }else{
                    // tareas.add(new Task (Subject = task_subject,  Description = task_description, CEN_Medio__c = mediopros, CEN_MobilePhone__c = ld.MobilePhone,
                    //                     CEN_Canal__c = canalpros, OwnerId = task_owner, ActivityDate = createdt, CEN_Email__c = ld.Email,
                    //                     CEN_Motivo__c = ld.CEN_Motivo__c, CEN_Proyecto__c = proyecto, CEN_Reactivo__c = 'true',
                    //                     CEN_StatusMobilePhone__c = ld.CEN_StatusMobilePhone__c, CEN_StatusEmail__c = ld.CEN_StatusEmail__c,
                    //                     CEN_StartDateContact__c = ld.CEN_StartDateContact__c, CEN_EndDateContact__c = ld.CEN_EndDateContact__c, CEN_StartTimeContact__c = ld.CEN_StartTimeContact__c,
                    //                     CEN_EndTimeContact__c = ld.CEN_EndTimeContact__c, WhoId = prospecto.id, CreatedDate=createdtm, CEN_Oficina_de_Venta_Aux__c = selectedOAC ));
                    if(ld.CEN_utm_source__c!=null){
                        Cookies.add(new Cookies__c (OwnerId = prospecto.CreatedById,CEN_Lead__c = prospecto.Id, CEN_Medio__c = medioprosLabel,CEN_Web__c=ld.CEN_Web__c,CEN_Formulario__c=ld.CEN_Formulario__c,CEN_Lead_Source__c = ld.LeadSource, CEN_ClientID__c = ld.CEN_ClientID__c,CEN_campaign_id__c=ld.CEN_campaign_id__c,CEN_utm_source__c=ld.CEN_utm_source__c,CEN_utm_medium__c=ld.CEN_utm_medium__c,CEN_utm_content__c=ld.CEN_utm_content__c,CEN_utm_campaign__c=ld.CEN_utm_campaign__c));
                    }
                }

            }
            task_owners.clear();
            task_subject = '';
            task_description = '';
            grupo = null;
            ownerid='';
            proyecto = '';
            canalpros = '';
            cuenta=null;
            selectedOAC=null;
            mediopros = '';
        }

        if(Cookies.size()>0 || Cookies != null){insert Cookies;}
        //if(tareas.size()>0 || tareas != null){insert tareas;}
    }

    /**
    * @description: asignara los supervisores segun la lista de registros de enrutamientos
                    supervisor a zona de elige donde vivir
    * @author Adolfo Crispin | 29-01-2021
    * @param List<Lead> nuevoProspectos: lista de nuevos prospectos a registrarse en la BD
    **/
    private static Map<String,Set<Id>> getMapEnrutadores(List<Lead> nuevoProspectos){
        Map<String,Set<Id>> mapEligeDondeVivir_x_Supervisores = new Map<String,Set<Id>>();
        List<Enrutamiento_Reactivos__c> enrutadores = new List<Enrutamiento_Reactivos__c>();
        Set<String> eleccionesDondeVivir = new Set<String>();
        eleccionesDondeVivir.add(VALUE_NINGUNO);
        //  colecciona las elecciones
        for(Lead prospecto : nuevoProspectos){
            if(String.isNotBlank(prospecto.CEN_Elige_donde_vivir__c)){
                eleccionesDondeVivir.add(prospecto.CEN_Elige_donde_vivir__c);
            }
        }
        //  busca los enrutadores segun las elecciones
        enrutadores = [
            SELECT CEN_Elige_Donde_Vivir__c, Supervisor_Asignado__c
            FROM Enrutamiento_Reactivos__c
            WHERE CEN_Elige_Donde_Vivir__c IN :eleccionesDondeVivir
        ];
        //  mapea eleccion x id de supervisor
        for(Enrutamiento_Reactivos__c enrutador : enrutadores){
            Set<Id> supervisores = new Set<Id>();
            if(enrutador.CEN_Elige_Donde_Vivir__c!=null && mapEligeDondeVivir_x_Supervisores.keySet().contains(enrutador.CEN_Elige_Donde_Vivir__c)){
                supervisores = mapEligeDondeVivir_x_Supervisores.get(enrutador.CEN_Elige_Donde_Vivir__c);
            }
            supervisores.add(enrutador.Supervisor_Asignado__c);
            mapEligeDondeVivir_x_Supervisores.put(enrutador.CEN_Elige_Donde_Vivir__c,supervisores);
        }
        //  limpiar memoria
        eleccionesDondeVivir.clear();
        eleccionesDondeVivir = null;
        enrutadores.clear();
        enrutadores = null;
        return mapEligeDondeVivir_x_Supervisores;
    }

    // private static List<Lead> getListCoincidentes(List<Lead> newleads){
    //     Map<String, Id> coincidentes= new Map<String, Id>();
    //     List<String> ndocs = new List<String>();
    //     List<String> sines = new List<String>();
    //     List<String> nlids = new List<String>();
    //     String name='';
    //     for(Lead ld:newleads){
    //         if(ld.CEN_N_mero_de_documento__c=='0000000000'||ld.CEN_Tipo_de_documento__c=='Sin especificar'){
    //             name = ld.FirstName+' '+ld.LastName;
    //             sines.add(name.toUpperCase().trim());
    //         }else{
    //             ndocs.add(ld.CEN_N_mero_de_documento__c);
    //         }
    //         if(ld.Id!=null){
    //             nlids.add(ld.Id);
    //         }
    //     }
    //     List<Lead> leads_coincidentes_ndocs = [SELECT Id, CEN_Elige_donde_vivir__c, CEN_NumberRetries__c, CreatedDate, CEN_N_mero_de_documento__c
    //                                            FROM Lead
    //                                            WHERE CEN_N_mero_de_documento__c IN :ndocs
    //                                            AND Id NOT IN :nlids ORDER BY CreatedDate ASC
    //                                            LIMIT 50000];

    //     List<Lead> leads_coincidentes_sines = [SELECT Id, CEN_Elige_donde_vivir__c, CEN_NumberRetries__c, CreatedDate, CEN_N_mero_de_documento__c
    //                                            FROM Lead
    //                                            WHERE Name IN :sines
    //                                            AND Id NOT IN :nlids ORDER BY CreatedDate ASC LIMIT 50000];

    //     List<Lead> result=new List<Lead>();
    //     result.addAll(leads_coincidentes_ndocs);
    //     result.addAll(leads_coincidentes_sines);

    //     return result;
    // }

    public static List<String> crearReactivo(Map<String, Id> coincidentes, List<Lead> newleads){

        List<String> idsDelete = new List<String>();
        List<Lead> listLead = new List<Lead>();
        Map<String, Lead> mapLead = new Map<String, Lead>();
        Map<String, Lead> proyectoMap = new Map<String, Lead>();
        Map<String, Lead> proyectoMap2 = new Map<String, Lead>();

        Map<Id,Lead> originales = new Map<Id,Lead>([
            SELECT Id, Name, FirstName, OwnerId, CEN_N_mero_de_documento__c, CEN_Tipo_de_documento__c, MobilePhone, Email, CEN_LeadReactive__c, CEN_StatusMobilePhone__c, CEN_StatusEmail__c,
            LastName, IsConverted, ConvertedContactId, ConvertedAccountId, CreatedById, CEN_ClientID__c,CEN_campaign_id__c,CEN_utm_campaign__c,CEN_utm_content__c,CEN_utm_medium__c,CEN_utm_source__c,
            CEN_StartDateContact__c, CEN_EndDateContact__c, CEN_StartTimeContact__c, CEN_EndTimeContact__c,CEN_Elige_donde_vivir__c, CreatedDate, CEN_NumberRetries__c
            FROM Lead WHERE Id IN :coincidentes.values() ORDER BY CreatedDate ASC LIMIT 50000
        ]);

        for (Id key : originales.keySet()) {
            proyectoMap.put(originales.get(key).CEN_Elige_donde_vivir__c + originales.get(key).CEN_N_mero_de_documento__c, originales.get(key)); //PROYECTO Y DOCUMENTO MAS RECIENTE
            proyectoMap2.put(originales.get(key).CEN_N_mero_de_documento__c, originales.get(key)); //DOCUMENTO MAS RECIENTE
            System.debug('Listas:');
            System.debug(proyectoMap);
            System.debug(proyectoMap2);
        }

        for(Lead ld : newleads){
            if(ld.CEN_N_mero_de_documento__c != null){
                if(proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c)?.CEN_Elige_donde_vivir__c!= null){
                    Long dt1Long = proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).CreatedDate.getTime();
                    //Long dt1Long2 = proyectoMap2.get(ld.CEN_N_mero_de_documento__c).CreatedDate.getTime();
                    Long dt2Long = ld.CreatedDate.getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    Long hours = minutes / 60;
                    Long days = hours / 24;

                    Decimal oneday = Decimal.valueOf(Label.CEN_oneDay);
                    Decimal thirtyday = Decimal.valueOf(Label.CEN_thirtyDays);

                    if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && hours <= oneday){
                    //if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && minutes <= 1.0){ //PRUEBA
                        Lead updateLead = new Lead();
                        System.debug('Caso 1.1');
                        updateLead.Id = proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).Id;
                        System.debug('Caso 1.2');
                        updateLead.CEN_NumberRetries__c = proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).CEN_NumberRetries__c == null ? 0 : proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).CEN_NumberRetries__c + 1;
                        System.debug('Caso 1.3');
                        //listLead.add(updateLead);
                        //mapLead.put(ld.Id, updateLead);
                        mapLead.put(proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).Id, updateLead);
                        System.debug('Caso 1.4');
                        idsDelete.add(ld.Id);
                        System.debug('Caso 1.5');
                    }else if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && (hours > oneday && hours <=thirtyday)){
                        System.debug('Caso 2.1');
                    //}else if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && (minutes > 0.5 && hours <= 720.0)){ //PRUEBA
                        Lead updateLead = new Lead();
                        System.debug('Caso 2.2');
                        updateLead.Id = ld.Id;
                        System.debug('Caso 2.3');
                        updateLead.CEN_Typification__c = 'Reactivo';
                        System.debug('Caso 2.4');
                        updateLead.CEN_LeadReactive__c = true;
                        System.debug('Caso 2.5');
                        updateLead.CEN_DiasTranscurridos__c = days;
                        System.debug('Caso 2.6');
                        mapLead.put(ld.Id, updateLead);
                        System.debug('Caso 2.7');
                    }else if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && hours > thirtyday){
                        System.debug('Caso 3.1');
                    //}else if(proyectoMap.containsKey(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c) && (hours > 720.0)){ //PRUEBA
                        Lead updateLead = new Lead();
                        System.debug('Caso 3.1');
                        updateLead.Id = ld.Id;      System.debug('Caso 3.2');   updateLead.CEN_Typification__c = 'Nuevo Interes';
                        System.debug('Caso 3.3');
                        updateLead.CEN_LeadReactive__c = true; System.debug('Caso 3.4'); updateLead.CEN_DiasTranscurridos__c = days;
                        System.debug('Caso 3.5'); mapLead.put(ld.Id, updateLead);
                        System.debug('Caso 3.6');
                    }
                }else{
                    System.debug('Errorrrrrr:');
                    System.debug(proyectoMap2);
                    if(proyectoMap2.get(ld.CEN_N_mero_de_documento__c) != null){
                        //Long dt1Long = proyectoMap.get(ld.CEN_Elige_donde_vivir__c + ld.CEN_N_mero_de_documento__c).CreatedDate.getTime();
                        Long dt1Long = proyectoMap2.get(ld.CEN_N_mero_de_documento__c).CreatedDate.getTime();
                        Long dt2Long = ld.CreatedDate.getTime();
                        Long milliseconds = dt2Long - dt1Long;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        Long days = hours / 24;

                        Lead updateLead = new Lead();
                        updateLead.Id = ld.Id;      updateLead.CEN_Typification__c = 'Nuevo Interes';
                        updateLead.CEN_LeadReactive__c = true;  updateLead.CEN_DiasTranscurridos__c = days;
                        mapLead.put(ld.Id, updateLead);
                    }
                }
            }
        }

        update mapLead.values();

        //List<Lead> tbdLeads = [Select ID FROM Lead WHERE ID IN: idsDelete];
        //System.debug('tbdleads1');
        //System.debug(tbdLeads);
        //delete tbdLeads;
        //System.debug('tbdleads2');
        //System.debug(tbdLeads);

        return idsDelete;
    }

    // public static void updateOppCase(List<Lead> newleads){
    //     List<Case> updateListCase = new List<Case>();
    //     for(Lead ld : newleads){
    //         Id caseId = [SELECT Id FROM Case WHERE Origin = 'Referidos' AND Status != 'No Válido' AND N_mero_de_documento__c =: ld.CEN_N_mero_de_documento__c]?.Id;
    //         if(ld.IsConverted && caseId!=null){
    //             Case c = new Case();
    //             c.Opportunity__c = ld.ConvertedOpportunityId;
    //             //c.Account__c = ld.ConvertedAccountId;
    //             c.Id = caseId;
    //             updateListCase.add(c);
    //         }
    //     }

    //     System.debug('updateListCase: ' + updateListCase);

    //     if(updateListCase.size()>0){
    //         update updateListCase;
    //     }
    // }

}