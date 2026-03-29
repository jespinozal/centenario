trigger CEN_Lead_a_Contacto on Lead (before update) {
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            String status = '';
            String division_de_interes = '';
            for(Lead prospecto:Trigger.new){
                if(String.isNotBlank(prospecto.CEN_Divisi_n_de_inter_s__c)){
                    division_de_interes = prospecto.CEN_Divisi_n_de_inter_s__c;
                    division_de_interes = division_de_interes.toUpperCase();
                }
                if(String.isNotBlank(division_de_interes)&&division_de_interes.equals('LOTES DE VIVIENDA')){
                    if(String.isNotBlank(prospecto.Status)){
                        status = prospecto.Status;
                        status = status.toUpperCase();
                        status = status.trim();
                        System.debug('Estado del prospecto: '+status);
                        if(status.equals('CONVERTIDO')){
                            System.debug('prospecto: '+prospecto.Id);
                            List<String> requeridos_list = new List<String>();
                            //Validar campos
                            if(String.isBlank(prospecto.CEN_Divisi_n_de_inter_s__c)){
                                requeridos_list.add('División de interés');
                            }else{
                                division_de_interes = prospecto.CEN_Divisi_n_de_inter_s__c;
                                division_de_interes = division_de_interes.toUpperCase();
                            }
                            if(String.isBlank(prospecto.CEN_Tipo_de_documento__c)){
                                requeridos_list.add('Tipo de documento');
                            }
                            if(String.isBlank(prospecto.LastName)){
                                requeridos_list.add('Apellidos');
                            }
                            if(String.isBlank(prospecto.CEN_N_mero_de_documento__c)){
                                requeridos_list.add('Número de documento');
                            }
                            if(String.isBlank(prospecto.FirstName)){
                                requeridos_list.add('Nombre');
                            }
                            if(String.isBlank(prospecto.CEN_Distrito__c)){
                                requeridos_list.add('Distrito');
                            }else{
                                Lead prospecto_to_update=[SELECT Id, CEN_Distrito__r.CEN_Codigo_departamento__c, 
                                                          CEN_Distrito__r.CEN_Codigo_provincia__c, 
                                                          CEN_Distrito__r.CEN_Codigo_distrito__c FROM Lead WHERE Id=:prospecto.Id LIMIT 1];
                                if(String.isBlank(prospecto_to_update.CEN_Distrito__r.CEN_Codigo_departamento__c)){
                                    requeridos_list.add('Código ubigeo del Departamento');
                                }
                                if(String.isBlank(prospecto_to_update.CEN_Distrito__r.CEN_Codigo_provincia__c)){
                                    requeridos_list.add('Código ubigeo de la Provincia');
                                }
                                if(String.isBlank(prospecto_to_update.CEN_Distrito__r.CEN_Codigo_distrito__c)){
                                    requeridos_list.add('Código ubigeo del Distrito');
                                }
                            }
                            //Para empresa
                            if(String.isNotBlank(prospecto.CEN_RUC__c)||String.isNotBlank(prospecto.Company)||
                              String.isNotBlank(prospecto.CEN_Distrito_Empresa__c)){
                                  if(String.isBlank(prospecto.CEN_RUC__c)){
                                      requeridos_list.add('RUC de la Compañia Interesada');
                                  }
                                  if(String.isBlank(prospecto.Company)){
                                      requeridos_list.add('Nombre de la Compañia Interesada');
                                  }
                                  if(String.isBlank(prospecto.CEN_Distrito_Empresa__c)){
                                      requeridos_list.add('Distrito de la Compañia Interesada');
                                  }else{
                                      Lead prospecto_to_update=[SELECT Id, CEN_Distrito_Empresa__r.CEN_Codigo_departamento__c, 
                                                          CEN_Distrito_Empresa__r.CEN_Codigo_provincia__c, 
                                                          CEN_Distrito_Empresa__r.CEN_Codigo_distrito__c FROM Lead WHERE Id=:prospecto.Id LIMIT 1];
                                      if(String.isBlank(prospecto_to_update.CEN_Distrito_Empresa__r.CEN_Codigo_departamento__c)){
                                          requeridos_list.add('Código ubigeo del Departamento de la Compañia');
                                      }
                                      if(String.isBlank(prospecto_to_update.CEN_Distrito_Empresa__r.CEN_Codigo_provincia__c)){
                                          requeridos_list.add('Código ubigeo de la Provincia de la Compañia');
                                      }
                                      if(String.isBlank(prospecto_to_update.CEN_Distrito_Empresa__r.CEN_Codigo_distrito__c)){
                                          requeridos_list.add('Código ubigeo del Distrito de la Compañia');
                                      }
                                  }                              
                            }
                            
                            //¿Continuar al WS?
                            Integer sizeoflist=requeridos_list.size();
                            if(sizeoflist>0){
                                String requeridos='';
                                requeridos = requeridos_list.get(0);
                                for(Integer j=1;j<sizeoflist;j++){
                                    if(j+1==sizeoflist){
                                        requeridos = requeridos + ' y '+requeridos_list.get(j);
                                    }else{
                                        requeridos = requeridos + ', '+requeridos_list.get(j);
                                    }
                                }
                                if(sizeoflist>1){
                                    requeridos=requeridos+' son obligatorios.';
                                }else{
                                    requeridos=requeridos+' es obligatorio.'; 
                                }
                                System.debug(requeridos);
                                Trigger.newMap.get(prospecto.Id).addError(requeridos);
                            }else{
                                //	QUITAR ESTO EN CASO DE QUE SE GENERE CONTACTOS DE LOTES INDUSTRIALES
                                if(division_de_interes.equals('LOTES DE VIVIENDA')){
                                    CEN_WS_GenerarContacto.GenerarContactosSAPfromLead(prospecto.Id);
                                }
                            }
                    }
                }
                      
                }
            }
        }
    }

}