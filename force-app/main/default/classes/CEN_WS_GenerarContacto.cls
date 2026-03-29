public class CEN_WS_GenerarContacto {
    public class MyException extends Exception {}
    
    @future(callout=true)
    public static void GenerarContactosSAPfromLead(String LeadId){
        Lead prospecto_a_convertir = [SELECT Id, IsDeleted, MasterRecordId, LastName, FirstName, Salutation, RecordTypeId, 
                                      Title, Company, Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, 
                                      Address, Phone, MobilePhone, Email, Website, PhotoUrl, LeadSource, Status, Industry, Rating, 
                                      NumberOfEmployees, OwnerId, IsConverted, ConvertedDate, ConvertedAccountId, ConvertedContactId, 
                                      ConvertedOpportunityId, IsUnreadByOwner, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                      SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Jigsaw, JigsawContactId, 
                                      EmailBouncedReason, EmailBouncedDate, IndividualId, CEN_Comentario__c, CEN_Departamento__c, 
                                      CEN_Direcci_n_Prospecto__c, CEN_Distrito__c, CEN_Divisi_n_de_inter_s__c, CEN_Donde_comprar__c, 
                                      CEN_Elige_donde_vivir__c, CEN_Estado_civil__c, CEN_Fecha_nacimiento__c, CEN_Formulario__c, CEN_Medio__c, 
                                      CEN_Medio_que_m_s_recuerda__c, CEN_Motivo__c, CEN_N_mero_de_documento__c, CEN_Nacionalidad__c, 
                                      CEN_No_brindo_datos__c, CEN_Oficina_de_venta__c, CEN_Probabilidad_de_venta__c, CEN_Provincia__c, 
                                      CEN_RUC__c, CEN_T_rminos_y_condiciones__c, CEN_Tel_fono_de_empresa__c, CEN_Tema_de_inter_s__c, 
                                      CEN_Tipo_de_documento__c, CEN_V_nculo__c, CEN_Web__c, CEN_Grado_de_instrucci_n__c, CEN_Distrito__r.Name,
                                      CEN_Fecha_de_emisi_n__c, CEN_Restricciones__c, CEN_Multas__c, CEN_Foto__c, CEN_Celular__c, CEN_Rubro__c, 
                                      CEN_Direcci_n_de_centro_de_trabajo__c, CEN_Distrito_Empresa__c, CEN_Distrito__r.CEN_Codigo_departamento__c,
                                      CEN_Distrito__r.CEN_Codigo_provincia__c, CEN_Distrito__r.CEN_Codigo_distrito__c, CEN_Distrito_Empresa__r.Name,
                                      CEN_Distrito_Empresa__r.CEN_Codigo_departamento__c, CEN_Distrito_Empresa__r.CEN_Codigo_provincia__c,
                                      CEN_Distrito_Empresa__r.CEN_Codigo_distrito__c FROM Lead WHERE Id=:LeadId];
        if(prospecto_a_convertir!=null){
            CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element response_persona = CrearContactoPersonaFromLead(prospecto_a_convertir);
            //	Reintento
            if(response_persona==null||String.isBlank(response_persona.ExContacto)){
                response_persona = CrearContactoPersonaFromLead(prospecto_a_convertir);
            }
            System.debug('Response persona desde SAP: '+response_persona);
            if(response_persona!=null){
                System.debug('Contact ID SAP Persona: '+response_persona.ExContacto);
                System.debug('Cuenta deudor: '+response_persona.ExKunnr);
                System.debug('Mensaje servicio: '+response_persona.ExMessageRetorn);
                
                Lead prospecto_convertido=[SELECT Id, ConvertedContactId, ConvertedAccountId FROM Lead WHERE Id=:LeadId LIMIT 1];
                
                           System.debug('prospecto_convertido: '+prospecto_convertido.Id);
                           System.debug('ConvertedContactId: '+prospecto_convertido.ConvertedContactId);
                           System.debug('ConvertedAccountId: '+prospecto_convertido.ConvertedAccountId);
                
                
                if(String.isNotBlank(prospecto_a_convertir.Company)&&String.isNotBlank(prospecto_a_convertir.CEN_RUC__c)){
                       CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element response_empresa = CrearContactoEmpresaFromLead(prospecto_a_convertir);
                       if(response_empresa==null||String.isBlank(response_empresa.ExContacto)){
                           response_empresa = CrearContactoEmpresaFromLead(prospecto_a_convertir);
                       }
                        System.debug('Response empresa desde SAP: '+response_empresa);
                        if(response_empresa!=null){
                            System.debug('Contact ID SAP Empresa: '+response_empresa.ExContacto);
                           System.debug('Cuenta deudor: '+response_empresa.ExKunnr);
                           System.debug('Mensaje servicio: '+response_empresa.ExMessageRetorn);                   
                           //	ACTUALIZAR CUENTA EMPRESA DESPUES QUE EL PROSPECTO SE ACTUALIZE
                           if(String.isNotBlank(response_empresa.ExContacto)){
                              if(prospecto_convertido!=null&&String.isNotBlank(prospecto_convertido.ConvertedAccountId)){
                                  try{
                                      Account contacto_to_update=[SELECT Id, Cod_Interno_SAP_Empresa__c, CEN_Nro_deudor_SAP__c
                                                                  FROM Account WHERE ID=:prospecto_convertido.ConvertedAccountId LIMIT 1];                         
                                      contacto_to_update.Cod_Interno_SAP_Empresa__c = response_empresa.ExContacto;
                                      contacto_to_update.CEN_Nro_deudor_SAP__c = response_empresa.ExKunnr;
                                      update contacto_to_update;
                                      System.debug('contacto_to_update Empresa Account: '+contacto_to_update.Id);
                                   }catch(Exception e){
                                       System.debug('contacto_to_update Empresa Account exception: '+e.getMessage());
                                   }
                               } 
                           }
                        }
                }else{
                     //	ACTUALIZAR CUENTA PERSONA DESPUES QUE EL PROSPECTO SE ACTUALIZE
                    if(String.isNotBlank(response_persona.ExContacto)){
                        if(prospecto_convertido!=null&&String.isNotBlank(prospecto_convertido.ConvertedAccountId)){
                            try{
                                Account contacto_to_update=[SELECT Id,  CEN_Cod_Interno_SAP__pc, CEN_Nro_deudor_SAP__pc
                                                              FROM Account WHERE ID=:prospecto_convertido.ConvertedAccountId LIMIT 1];   
                                contacto_to_update.CEN_Cod_Interno_SAP__pc = response_persona.ExContacto;
                                contacto_to_update.CEN_Nro_deudor_SAP__pc=response_persona.ExKunnr;
                                update contacto_to_update;
                                System.debug('contacto_to_update Persona Account: '+contacto_to_update.Id);
                            }catch(Exception e){
                                System.debug('contacto_to_update Persona Account exception: '+e.getMessage());
                            }
                        }
                    }
                }
    
                //	ACTUALIZAR CONTACTO PERSONA DESPUES QUE EL PROSPECTO SE ACTUALIZE
                if(response_persona!=null){
                    if(String.isNotBlank(response_persona.ExContacto)){
                        if(prospecto_convertido!=null&&String.isNotBlank(prospecto_convertido.ConvertedContactId)){
                            try{
                                Contact contacto_actualizar=[SELECT Id, CEN_Cod_Interno_SAP__c, CEN_Nro_deudor_SAP__c
                                                             FROM Contact WHERE Id=:prospecto_convertido.ConvertedContactId LIMIT 1];
                                contacto_actualizar.CEN_Cod_Interno_SAP__c=response_persona.ExContacto;
                                contacto_actualizar.CEN_Nro_deudor_SAP__c = response_persona.ExKunnr;
                                update contacto_actualizar;
                                System.debug('contacto_actualizar Persona Contacto: '+contacto_actualizar.Id);
                            }catch(Exception e){
                                System.debug('contacto_actualizar Persona Contacto exception: '+e.getMessage());
                            }
                        }
                    }
                }
            }
        }
    }

    private static CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element CrearContactoPersonaFromLead(Lead prospecto){
        
            Map<String, String> grupo_ctas_deudor = new Map<String, String>();
            grupo_ctas_deudor.put('DNI', 'ZVPN');
            grupo_ctas_deudor.put('RUC', 'ZVPJ');
            grupo_ctas_deudor.put('CARN.EXT', 'ZVPE');
            grupo_ctas_deudor.put('PASAPORTE', 'ZVPE');
            grupo_ctas_deudor.put('DNI.ESP', 'ZVES');
            grupo_ctas_deudor.put('P.T.P.', 'ZVPE');
                                                                                            
        //	Org de ventas
        String cc_org_ventas = '0100';	//	FALTA METADATA DE ORG ÁREA DE VENTAS PARA MAPEAR
		//	FIJOS
        	//	Canal de Distribución
        String cc_canal_distribucion = '10';	//	FALTA METADATA Y MAPEO
        	//	Sector
        String cc_sector = '10';	//	FALTA DEFINICION Y MAPEO
                                                                                            
        //	CREAR EL SERVICIO
        CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN service = new CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN();
        service.timeout_x = 120000;
        service.inputHttpHeaders_x = GetAuthorization();
        //	CREAR EL BODY DEL REQUEST
        CEN_WS_Contacto.ZsfrfcCrContac obj = new CEN_WS_Contacto.ZsfrfcCrContac();
        /*---OBLIGATORIOS---*/
        String tipo_documento = prospecto.CEN_Tipo_de_documento__c;
        tipo_documento=tipo_documento.toUpperCase();
        
        obj.BUKRS = '0010'; // COMO SACAR EL CODIGO SOCIEDAD
        obj.VKORG = '0100'; // COMO SACAR LA ORG DE VENTAS
        obj.VTWEG = cc_canal_distribucion;	//FIJOS
        obj.SPART = cc_sector;	//FIJOS
        if(tipo_documento.equals('CAREXTRAN')){
            tipo_documento='CARN.EXT';
        }
        obj.TipoIdentif = tipo_documento;
        obj.ApelContacto = prospecto.LastName;
        obj.DenomSocial = 'NO';
        obj.Nif = prospecto.CEN_N_mero_de_documento__c;
        if(obj.Nif.substring(0,1)=='0'&&tipo_documento.trim()=='DNI'){
            obj.Ktokd='ZVES';
            obj.TipoIdentif = 'DNI.ESP';
        }else{
            obj.Ktokd = grupo_ctas_deudor.get(tipo_documento);
        }
        obj.PersContacto = prospecto.FirstName;
        obj.Zzdepartamento = prospecto.CEN_Distrito__r.CEN_Codigo_departamento__c;	
        obj.Zzprovincia = prospecto.CEN_Distrito__r.CEN_Codigo_provincia__c;	
        obj.Zzdistrito = prospecto.CEN_Distrito__r.CEN_Codigo_distrito__c;
        if(String.isNotBlank(prospecto.CEN_Direcci_n_Prospecto__c)){
            obj.Direccion = prospecto.CEN_Direcci_n_Prospecto__c;
        }else{
            obj.Direccion = prospecto.CEN_Distrito__r.Name;
        }
        /*---OPCIONALES---*/
        obj.TelefFijo = FillNullValues(prospecto.Phone);
        obj.TelefMovil = FillNullValues(prospecto.MobilePhone);
        obj.Mail = FillNullValues(prospecto.Email);
        if(String.isNotBlank(prospecto.CEN_Medio__c)){            
            obj.Zzmedio = prospecto.CEN_Medio__c;//CEN_Helper_Metadata.GetCodigo_MedioPublicitario(prospecto.CEN_Medio__c);            
        }else if(String.isNotBlank(prospecto.CEN_Medio_que_m_s_recuerda__c)){
            obj.Zzmedio = prospecto.CEN_Medio__c;//CEN_Helper_Metadata.GetCodigo_MedioPublicitario(prospecto.CEN_Medio_que_m_s_recuerda__c);
        }       
        
        System.debug('Crear contacto:\r\n'+obj);
        //	CONSUMIR EL SERVCIO Y OBTENER EL RESPONSE
        CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element response = null;
		try{
            if(Test.isRunningTest()){                
                response = HttpMockFactory.CrearContacto('ok');
            }else{
                response = service.ZsfRfcCrearContacto(obj);
            }
        }catch(Exception e){
            System.debug('Hubó un problema en usar el Servicio de Crear Contacto en SAP. '+e.getMessage()+'. Line: '+e.getLineNumber());
        }                                                                                            
        return response;
    }
    private static CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element CrearContactoEmpresaFromLead(Lead prospecto){
        String tipo_documento = 'RUC';
        String KTOKD = 'ZVPJ';
                                                                                            
        //	Org de ventas
        String cc_org_ventas = '0100';	//	FALTA METADATA DE ORG ÁREA DE VENTAS PARA MAPEAR
		//	FIJOS
        	//	Canal de Distribución
        String cc_canal_distribucion = '10';	//	FALTA METADATA Y MAPEO
        	//	Sector
        String cc_sector = '10';	//	FALTA DEFINICION Y MAPEO
                                                                                            
        //	CREAR EL SERVICIO
        CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN service = new CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN();
        service.timeout_x = 120000;
        service.inputHttpHeaders_x = GetAuthorization();
        //	CREAR EL BODY DEL REQUEST
        CEN_WS_Contacto.ZsfrfcCrContac obj = new CEN_WS_Contacto.ZsfrfcCrContac();
        /*---OBLIGATORIOS---*/
        obj.Ktokd = KTOKD;
        obj.Bukrs = '0010'; // COMO SACAR EL CODIGO SOCIEDAD
        obj.Vkorg = '0100'; // COMO SACAR LA ORG DE VENTAS
        obj.Vtweg = cc_canal_distribucion;	//FIJOS
        obj.Spart = cc_sector;	//FIJOS
        obj.TipoIdentif = tipo_documento;
        obj.DenomSocial = prospecto.Company;
        obj.Nif = prospecto.CEN_RUC__c;
        obj.Zzdepartamento = prospecto.CEN_Distrito_Empresa__r.CEN_Codigo_departamento__c;
        obj.Zzprovincia = prospecto.CEN_Distrito_Empresa__r.CEN_Codigo_provincia__c;
        obj.Zzdistrito = prospecto.CEN_Distrito_Empresa__r.CEN_Codigo_distrito__c;
        if(String.isNotBlank(prospecto.CEN_Direcci_n_Prospecto__c)){
            obj.Direccion = prospecto.CEN_Direcci_n_de_centro_de_trabajo__c;
        }else{
            obj.Direccion = prospecto.CEN_Distrito_Empresa__r.Name;
        }
        /*---OPCIONALES---*/
        obj.TelefFijo = FillNullValues(prospecto.CEN_Tel_fono_de_empresa__c);
        if(String.isNotBlank(prospecto.CEN_Medio__c)){
            obj.Zzmedio = prospecto.CEN_Medio__c;//CEN_Helper_Metadata.GetCodigo_MedioPublicitario(prospecto.CEN_Medio__c);
        }
        
        System.debug('Crear contacto:\r\n'+obj);
        //	CONSUMIR EL SERVCIO Y OBTENER EL RESPONSE
        CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element response = null;
		try{
            if(Test.isRunningTest()){                
                response = HttpMockFactory.CrearContacto('ok');
            }else{
                response = service.ZsfRfcCrearContacto(obj);
            }
        }catch(Exception e){
            System.debug('Hubó un problema en usar el Servicio de Crear Contacto en SAP. '+e.getMessage()+'. Line: '+e.getLineNumber());
        }                                                                                            
        return response;
    }
    private static String FillNullValues(Object value){
        String val = String.valueOf(value);
        if(value==null || String.isBlank(val) || val.equals('null')){
            return '';
        }else{
            return val;
        }
    }
    private static Map<String, String> GetAuthorization(){
        String user = label.CEN_usersap;
        String pass = label.CEN_passSap;
        Blob sblob = Blob.valueOf(user + ':' + pass);
        String base64_auth = EncodingUtil.base64Encode(sblob);
        Map<String, String> header = new Map<String, String>();
        header.put('Authorization','Basic ' + base64_auth);
        return header;
    }
}