/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-15-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-04-2021   @everis.com   Initial Version
**/
public class CEN_WS_GenerarReserva {
    public class MyException extends Exception {}
        
    public static String CEN_ReservarLote(String oportunidad_id, String lote_id){
        String result = '';
        try{
            result= CEN_ReservarLotedeOportunidadLote(oportunidad_id, lote_id);
        }catch(Exception ex){
            result = 'Error: ' + ex.getMessage();
            System.debug('Exception:' + ex.getMessage() + '. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName()+' .Cause: '+ex.getCause());
        }
        return result;
    }
    
    public static String CEN_ReservarLotedeOportunidadLote(String oportunidad_id, String lote_id){
        List<String> requeridos_list = new List<String>();
        Map<String, String> grupo_ctas_deudor = new Map<String, String>();
        grupo_ctas_deudor.put('DNI', 'ZVPN');
        grupo_ctas_deudor.put('RUC', 'ZVPJ');
        grupo_ctas_deudor.put('CARN.EXT', 'ZVPE');
        grupo_ctas_deudor.put('PASAPORTE', 'ZVPE');
        grupo_ctas_deudor.put('DNI.ESP', 'ZVES');
        grupo_ctas_deudor.put('P.T.P.', 'ZVPE');
    
        Boolean exito_de_crear_reserva = false;
        Boolean exito_de_crear_contacto = false;
        Boolean error_de_reserva = false;
        String response_function = '';
    
        /*  OBJETOS SALESFORCE */
        CEN_Reserva__c reserva_salesforce = new CEN_Reserva__c();
        Opportunity oportunidad=null;
        Account cuenta = null;
        Product2 lote = null;
        Proyecto__c proyecto_de_lote = null;
        /*  - */
    
        CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element reserva_sap;
        CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element contacto_sap;
    
        String tipo_de_cuenta='';
        String nro_id_cliente_contacto = '';
        String message;
        
        //	OBTENER LA DATA DESDE SALESFORCE
        try{
            lote = [SELECT ID, CEN_Proyecto__c, CODLOTE__c, CODCOMPANIA__c, 
                    CEN_Tiene_Reserva__c, CODESTADOLOTE__c FROM Product2 WHERE ID=:lote_id LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception obteniendo lote: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        
        if(lote==null){
            throw new MyException('No se encontró el Lote con Id('+lote_id+').');
        }else{
            if(String.isBlank(lote.CEN_Proyecto__c)){requeridos_list.add('Proyecto');}
            if(String.isBlank(lote.CODCOMPANIA__c)){requeridos_list.add('Código de Compañia');}
            if(String.isBlank(lote.CODLOTE__c)){requeridos_list.add('Código de Lote');}
            
            System.debug(lote.CODESTADOLOTE__c.toUpperCase());
            String estado_lote = 'R';
            if(String.isNotBlank(lote.CODESTADOLOTE__c)){
                estado_lote = lote.CODESTADOLOTE__c;
                estado_lote = estado_lote.trim().toUpperCase();
                if(estado_lote=='LIBRE'){
                    estado_lote = 'L';
                }
            }
            if(estado_lote!='L'){
                throw new MyException('Este lote no está libre. Estado del lote: '+estado_lote);
            }
        }
        
        try{
            oportunidad = [SELECT ID, AccountId, StageName, CEN_Sub_Estado__c, Type, CEN_AmountPaidDate__c
                           FROM Opportunity WHERE ID=:oportunidad_id LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception obteniendo oportunidad: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(oportunidad==null){
            throw new MyException('No se encontró la Oportunidad con Id('+oportunidad_id+').');
        }
        else{
            if(String.isBlank(oportunidad.AccountId)){
                requeridos_list.add('Nombre de la cuenta');
            }
        }
        
        try{
            cuenta = [SELECT Id, IsDeleted, MasterRecordId, Name, LastName, FirstName, Salutation, 
                      Type, RecordTypeId, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                      BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                      ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, 
                      ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Website, PhotoUrl, Industry, 
                      NumberOfEmployees, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                      SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, PersonContactId, IsPersonAccount, 
                      PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry, 
                      PersonMailingLatitude, PersonMailingLongitude, PersonMailingGeocodeAccuracy, PersonMailingAddress, 
                      PersonMobilePhone, PersonEmail, PersonTitle, PersonDepartment, PersonLeadSource, PersonBirthdate, 
                      PersonLastCURequestDate, PersonLastCUUpdateDate, PersonEmailBouncedReason, PersonEmailBouncedDate, 
                      PersonIndividualId, Jigsaw, JigsawCompanyId, AccountSource, SicDesc, CEN_Centro_de_trabajo__c, 
                      CEN_Departamento__c, CEN_Direcci_n__c, CEN_Distrito__c, CEN_Estado__c, CEN_Fecha_de_Nacimiento__c, 
                      CEN_Medio__c, CEN_Numero_de_documento_del__c, CEN_Oficina_de_venta__c, CEN_Tipo_de_documento__c,
                      CEN_Vinculo__c, Prospecto_acept_t_rminos_y_condiciones__c, Provincia__c, Comentario__c, CEN_Origen__c, 
                      CEN_Rubro__c, Cod_Interno_SAP_Empresa__c, CEN_Cargo_que_ocupa__pc, CEN_Direcci_n_Centro_de_Trabajo__pc, 
                      CEN_Estado_civil__pc, CEN_Jefe_Directo__pc, CEN_Lugar_de_nacimiento__pc, CEN_N_mero_de_documento__pc, 
                      CEN_Nacionalidad__pc, CEN_Profesion_u_oficio__pc, CEN_Promedio_Mensual_Ingresos__pc, CEN_Tel_fono_Trabajo__pc, 
                      CEN_Tipo_de_documento__pc, CEN_Tipo_de_relaci_n_laboral__pc, CEN_Vinculo__pc, Moneda__pc, 
                      N_Partida_Vigencia_de_poder__pc, CEN_Foto__pc, CEN_Grado_de_instrucci_n__pc, CEN_Fecha_de_emisi_n__pc, 
                      CEN_Restricciones__pc, CEN_Multas__pc, CEN_Cod_Interno_SAP__pc, CEN_Direccion__pc, CEN_Distrito__pc, CEN_Distrito__r.Name,
                      CEN_Distrito__r.CEN_Codigo_departamento__c, CEN_Distrito__r.CEN_Codigo_provincia__c, CEN_Distrito__pr.Name, 
                      CEN_Distrito__r.CEN_Codigo_distrito__c, CEN_Distrito__pr.CEN_Codigo_departamento__c, CEN_Distrito__pr.CEN_Codigo_provincia__c, 
                      CEN_Distrito__pr.CEN_Codigo_distrito__c, CEN_Sexo__pc, CEN_Nro_deudor_SAP__pc, CEN_Nro_deudor_SAP__c 
                      FROM Account WHERE ID=:oportunidad.AccountId LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception obteniendo cuenta: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(cuenta==null){
            throw new MyException('No se encontró la Cuenta de la oportunidad.');
        }else{
            if(String.isBlank(cuenta.RecordType.Name)){
                requeridos_list.add('"Tipo de registro" de la Cuenta');
            }
        }
        try{
        	proyecto_de_lote = [SELECT ID, CEN_CODIGOSAP__c FROM Proyecto__c WHERE ID=:lote.CEN_Proyecto__c LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception obteniendo proyecto del lote: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(proyecto_de_lote==null){
            throw new MyException('No se encontró el Proyecto con Id('+lote.CEN_Proyecto__c+').');
        }else{
            if(String.isBlank(proyecto_de_lote.CEN_CODIGOSAP__c)){
                requeridos_list.add('"Código SAP" del proyecto');
            }
        }
        
        validarDatos(requeridos_list);
        
        tipo_de_cuenta = cuenta.RecordType.Name;        
        System.debug(tipo_de_cuenta);
        if((tipo_de_cuenta.equals('Cuenta Natural')&&(String.isBlank(cuenta.CEN_Cod_Interno_SAP__pc)||String.isBlank(cuenta.CEN_Nro_deudor_SAP__pc)))||
            (tipo_de_cuenta.equals('Cuenta Jurídica')&&(String.isBlank(cuenta.Cod_Interno_SAP_Empresa__c)||String.isBlank(cuenta.CEN_Nro_deudor_SAP__c)))){
                contacto_sap = CrearContacto(cuenta, tipo_de_cuenta, proyecto_de_lote, lote, grupo_ctas_deudor);
                if(contacto_sap==null||String.isBlank(contacto_sap.ExContacto)||String.isBlank(contacto_sap.ExKunnr)){
                    contacto_sap = CrearContacto(cuenta, tipo_de_cuenta, proyecto_de_lote, lote, grupo_ctas_deudor);
                }
                message = FillNullValues(contacto_sap.ExMessageRetorn);
                message = message.toLowerCase();
                if(message.contains('error')){
                    throw new MyException('No se pudo crear el contacto en sap. ' + contacto_sap.ExMessageRetorn + '. ');
                }else{
                    exito_de_crear_contacto= true;
                    System.debug('Se creó el contacto en sap con código ('+contacto_sap.ExContacto+'), pero no se actualizó Salesforce. ');
                    if(tipo_de_cuenta.equals('Cuenta Jurídica')){
                        cuenta.Cod_Interno_SAP_Empresa__c = contacto_sap.ExContacto;
                        cuenta.CEN_Nro_deudor_SAP__c = contacto_sap.ExKunnr;
                    }
                    else if(tipo_de_cuenta.equals('Cuenta Natural')){
                        cuenta.CEN_Cod_Interno_SAP__pc = contacto_sap.ExContacto;
                        cuenta.CEN_Nro_deudor_SAP__pc = contacto_sap.ExKunnr;
                    }
                }
            }
        if(tipo_de_cuenta.equals('Cuenta Natural')){
            System.debug('La cuenta tiene Código Interno SAP: '+cuenta.CEN_Cod_Interno_SAP__pc);
            System.debug('La cuenta tiene Número de deudor SAP: '+cuenta.CEN_Nro_deudor_SAP__pc);
        }else{
            System.debug('La cuenta tiene Código Interno SAP: '+cuenta.Cod_Interno_SAP_Empresa__c);
            System.debug('La cuenta tiene Número de deudor SAP: '+cuenta.CEN_Nro_deudor_SAP__c);
        }
        Boolean error = false;
        try{
        if(cuenta.CEN_Estado__c.equals('Cuenta Centenario')){
            System.debug('Crear reserva para CUENTA CENTENARIO');
            if(tipo_de_cuenta.equals('Cuenta Natural')){
                nro_id_cliente_contacto = cuenta.CEN_Nro_deudor_SAP__pc;
            }else{
                nro_id_cliente_contacto = cuenta.CEN_Nro_deudor_SAP__c;       
            }
            reserva_sap = CrearReserva('B', nro_id_cliente_contacto, lote, proyecto_de_lote, oportunidad.Id);
            if(reserva_sap==null||String.isBlank(reserva_sap.ExBelnr)){
                reserva_sap = CrearReserva('B', nro_id_cliente_contacto, lote, proyecto_de_lote, oportunidad.Id);
            }
            message = FillNullValues(reserva_sap.ExMessageRetorn);
            message = message.toLowerCase();
            if(message.contains('error')||String.isBlank(reserva_sap.ExBelnr)){
                throw new MyException('No se pudo crear la reserva en sap. ' + reserva_sap.ExMessageRetorn + '........ ');
            }else{
                System.debug('Se creó la reserva ('+reserva_sap.ExBelnr+') en sap, pero no se actualizó Salesforce. ');
                exito_de_crear_reserva = true;
                reserva_salesforce.Contacto_Cliente__c = 'Cliente';
            }
        }
        else if(cuenta.CEN_Estado__c.equals('Cuenta Potencial')){
            System.debug('Crear reserva para CUENTA POTENCIAL');
            if(tipo_de_cuenta.equals('Cuenta Natural')){
                nro_id_cliente_contacto = cuenta.CEN_Cod_Interno_SAP__pc;
            }else{
                nro_id_cliente_contacto = cuenta.Cod_Interno_SAP_Empresa__c;       
            }
            try{
                reserva_sap = CrearReserva('A',nro_id_cliente_contacto, lote, proyecto_de_lote, oportunidad.Id);
                if(reserva_sap==null||String.isBlank(reserva_sap.ExBelnr)){
                    reserva_sap = CrearReserva('A', nro_id_cliente_contacto, lote, proyecto_de_lote, oportunidad.Id);
                }
                message = FillNullValues(reserva_sap.ExMessageRetorn);
                message = message.toLowerCase();
                if(message.contains('error')||String.isBlank(reserva_sap.ExBelnr)){
                    System.debug('Error: No se pudo crear la Reserva en SAP. ' + reserva_sap.ExMessageRetorn + '. ');
                    throw new MyException('No se creó la Reserva en SAP. '+reserva_sap.ExMessageRetorn);
                }else{
                    exito_de_crear_reserva = true;
                    reserva_salesforce.Contacto_Cliente__c = 'Contacto';
                    if(exito_de_crear_contacto){
                        System.debug('Se creó la reserva ('+reserva_sap.ExBelnr+') en sap, pero no se actualizó Salesforce.');
                    }
                }
            }catch(Exception e){
                System.debug(e.getMessage());
                response_function = response_function + e.getMessage();
                error_de_reserva = true;
            }finally{
                if(error_de_reserva){
                    throw new MyException(response_function);
                }
            }
        }
        }catch(Exception ex){
            response_function = ex.getMessage();
            error = true;
            System.debug('Exception:' + ex.getMessage() + '. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName()+' .Cause: '+ex.getCause());
        }
        if(exito_de_crear_contacto){
            ActualizarContactoYDatosSalesforce(cuenta.Id, contacto_sap.ExContacto, contacto_sap.ExKunnr, tipo_de_cuenta);
        }
        //  Continuar con el registro y actualización de las relaciones en Salesforce
        if(exito_de_crear_reserva){
            String upd_salesforce = ActualizarReservaYDatosSalesforce(reserva_salesforce, oportunidad, lote, proyecto_de_lote,reserva_sap);
            response_function = response_function + upd_salesforce;
            return 'Se creó la reserva exitosamente.';
        }
        if(error){
            throw new MyException(response_function);
        }
        return response_function;
    }
    
    public static void ActualizarContactoYDatosSalesforce(String cuenta_id,String ExContacto,String ExKunnr, String tipo_de_cuenta){
        if(tipo_de_cuenta.equals('Cuenta Jurídica')){
                Account contacto_to_update=[SELECT ID, Cod_Interno_SAP_Empresa__c, CEN_Nro_deudor_SAP__c 
                                            FROM Account WHERE ID=:cuenta_id LIMIT 1];
                contacto_to_update.Cod_Interno_SAP_Empresa__c = ExContacto;
	            contacto_to_update.CEN_Nro_deudor_SAP__c = ExKunnr;
                update contacto_to_update;
        }
        else if(tipo_de_cuenta.equals('Cuenta Natural')){
            Account cuenta_to_update=[SELECT ID, CEN_Cod_Interno_SAP__pc, CEN_Nro_deudor_SAP__pc
                                      FROM Account WHERE ID=:cuenta_id LIMIT 1];
            cuenta_to_update.CEN_Cod_Interno_SAP__pc = ExContacto;
            cuenta_to_update.CEN_Nro_deudor_SAP__pc = ExKunnr;
            update cuenta_to_update;
        }
    }
    
    public static String ActualizarReservaYDatosSalesforce(CEN_Reserva__c reserva_salesforce, Opportunity oportunidad, Product2 lote, Proyecto__c proyecto_de_lote, CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element reserva_sap){
        //	continuar con los datos de la reserva
        String response = '';
        reserva_salesforce.CEN_Cod_Interno_SAP__c = reserva_sap.ExBelnr;
        reserva_salesforce.Proyecto__c = proyecto_de_lote.Id;
        reserva_salesforce.CEN_Producto__c = lote.Id;
        reserva_salesforce.CEN_Oportunidad__c = oportunidad.Id;            
        reserva_salesforce.CEN_D_as_de_vencimiento__c = 3;
        reserva_salesforce.CEN_Importe__c=oportunidad.CEN_AmountPaidDate__c;//20.0;
        reserva_salesforce.CEN_Moneda__c='S/.';
        
        insert reserva_salesforce;  //  Guardar la reserva en Salesforce
            
            //	Validar las inserciones y actualizaciones de los datos de Salesforce
            //System.debug('Nueva Reserva para salesforce:\r' + reserva_salesforce);
            CEN_Reserva__c reserva_inserted=[SELECT ID FROM CEN_Reserva__c WHERE ID=:reserva_salesforce.Id LIMIT 1];
            if(reserva_inserted==null){
                response = response + 'LA RESERVA NO PUDO REGISTRARSE EN SALESFORCE. ';
            }else{
                response = response + 'Se registró la Reserva ('+reserva_inserted.Id+') en Salesforce. ';
                
                oportunidad.StageName = 'Operación';
                //oportunidad.CEN_Sub_Estado__c ='OPERACION DE RESERVA'; //CON DEPOSITO
                update oportunidad; //  Actualizar la oportunidad en Salesforce
            }
            lote.CEN_Tiene_Reserva__c = 'Si';
            lote.CODESTADOLOTE__c = 'Reservado';
            update lote;                 
        return response;
    }
    
    public static CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element CrearContacto(Account cuenta, String tipo_de_cuenta, Proyecto__c proyecto_lote, Product2 lote, Map<String, String> grupo_ctas_deudor){
        List<String> requeridos_list = new List<String>();
        //	Org de ventas
        Integer cc_org_ventas=10;
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
        if(String.isBlank(proyecto_lote.CEN_CODIGOSAP__c)){requeridos_list.add('"Código SAP" del Proyecto');}
        if(String.isBlank(lote.CODCOMPANIA__c)){requeridos_list.add('"Código de Compañia" del Lote');}
        
        if(tipo_de_cuenta.equals('Cuenta Jurídica') || String.isBlank(tipo_de_cuenta)){
            
                //	VALIDAR LA EMPRESA
        if(String.isBlank(cuenta.Name)){requeridos_list.add('"Nombre" de la Cuenta');}
        if(String.isBlank(cuenta.CEN_Tipo_de_documento__c)){requeridos_list.add('"Tipo de documento" de la Cuenta');}
        if(String.isBlank(cuenta.CEN_Numero_de_documento_del__c)){requeridos_list.add('"Número de documento" de la Cuenta');}
        if(String.isBlank(cuenta.Phone)){requeridos_list.add('"Teléfono" de la Cuenta');}
                validarDatos(requeridos_list);
            
                obj.TipoIdentif = FillNullValues(cuenta.CEN_Tipo_de_documento__c.toUpperCase());
                obj.Nif = FillNullValues(cuenta.CEN_Numero_de_documento_del__c.toUpperCase());
                obj.DenomSocial = FillNullValues(cuenta.Name.toUpperCase());
                obj.TelefFijo = FillNullValues(cuenta.Phone);
            if(String.isNotBlank(cuenta.CEN_Direccion__pc)){
                obj.Direccion = FillNullValues(cuenta.CEN_Direcci_n__c);
            }else{
                obj.Direccion = FillNullValues(cuenta.CEN_Distrito__r.Name);
            }
                
                obj.Ktokd = FillNullValues(grupo_ctas_deudor.get(cuenta.CEN_Tipo_de_documento__c));            
            
            obj.Zzdepartamento = FillNullValues(cuenta.CEN_Distrito__r.CEN_Codigo_departamento__c);	
            obj.Zzprovincia = FillNullValues(cuenta.CEN_Distrito__r.CEN_Codigo_provincia__c);	
            obj.Zzdistrito = FillNullValues(cuenta.CEN_Distrito__r.CEN_Codigo_distrito__c);
            
        }
        else if(tipo_de_cuenta.equals('Cuenta Natural')){
            
                if(String.isBlank(cuenta.CEN_Tipo_de_documento__pc)){requeridos_list.add('"Tipo de documento" de la cuenta');}
                if(String.isBlank(cuenta.CEN_N_mero_de_documento__pc)){requeridos_list.add('"Número de documento" de la cuenta');}
                if(String.isBlank(cuenta.LastName)){requeridos_list.add('"Apellido" de la cuenta');}
                if(String.isBlank(cuenta.FirstName)){requeridos_list.add('"Nombre" dde la cuenta');}            
                if(String.isBlank(cuenta.CEN_Distrito__pc)){requeridos_list.add('"Distrito" de la cuenta');}
                else{
                if(String.isBlank(cuenta.CEN_Distrito__pr.CEN_Codigo_departamento__c)){requeridos_list.add('"Código de departamento" del distrito');}
                if(String.isBlank(cuenta.CEN_Distrito__pr.CEN_Codigo_provincia__c)){requeridos_list.add('"Código de provincia"  del distrito');}
                if(String.isBlank(cuenta.CEN_Distrito__pr.CEN_Codigo_distrito__c)){requeridos_list.add('"Código de distrito" del distrito');}  
                }
                if(String.isBlank(lote.CODCOMPANIA__c)){requeridos_list.add('"Código de compañia"');}
                if(String.isBlank(proyecto_lote.CEN_CODIGOSAP__c)){requeridos_list.add('"Código SAP"');}

                validarDatos(requeridos_list);
            
            if(cuenta.CEN_Tipo_de_documento__pc.toUpperCase()=='CAREXTRAN'){
                obj.TipoIdentif = 'CARN.EXT';
            }else{
                obj.TipoIdentif = FillNullValues(cuenta.CEN_Tipo_de_documento__pc.toUpperCase());
            }            
            obj.Nif = FillNullValues(cuenta.CEN_N_mero_de_documento__pc);
            obj.ApelContacto = FillNullValues(cuenta.LastName.toUpperCase());
            obj.PersContacto = FillNullValues(cuenta.FirstName.toUpperCase());
            obj.DenomSocial = 'NO';
            
            obj.Mail = FillNullValues(cuenta.PersonEmail);
            obj.TelefFijo = FillNullValues(cuenta.CEN_Tel_fono_Trabajo__pc);
            obj.TelefMovil = FillNullValues(cuenta.Phone);
            if(String.isNotBlank(cuenta.CEN_Direccion__pc)){
                obj.Direccion = FillNullValues(cuenta.CEN_Direccion__pc);
            }else{
                obj.Direccion = FillNullValues(cuenta.CEN_Distrito__pr.Name);
            }
            if(obj.Nif.substring(0,1)=='0'&&cuenta.CEN_Tipo_de_documento__pc.trim()=='DNI'){
                obj.Ktokd='ZVES';
                obj.TipoIdentif = 'DNI.ESP';
            }else{
                obj.Ktokd = FillNullValues(grupo_ctas_deudor.get(obj.TipoIdentif.trim()));
            }
           
            obj.Zzdepartamento = FillNullValues(cuenta.CEN_Distrito__pr.CEN_Codigo_departamento__c);	
            obj.Zzprovincia = FillNullValues(cuenta.CEN_Distrito__pr.CEN_Codigo_provincia__c);	
            obj.Zzdistrito = FillNullValues(cuenta.CEN_Distrito__pr.CEN_Codigo_distrito__c);
        }
        obj.Bukrs = lote.CODCOMPANIA__c;
        cc_org_ventas = Integer.valueOf(lote.CODCOMPANIA__c);
        obj.Vkorg = '0'+String.valueOf(cc_org_ventas*10);
        obj.Vtweg = cc_canal_distribucion;
        obj.Spart = cc_sector;
        if(String.isNotBlank(cuenta.CEN_Medio__c)){
            obj.Zzmedio = CEN_Helper_Metadata.GetCodigo_MedioPublicitario(cuenta.CEN_Medio__c);
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
            System.debug('Hubó un problema en usar el Servicio de Crear Contacto en SAP. '+e.getMessage());
            throw new MyException(e.getMessage());
        }                                                                                            
        return response;
    }
    
    public static CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element CrearReserva(String tipox, String cod_cliente_contacto, Product2 lote, Proyecto__c proyecto_de_lote, String oportunidad_id){
        List<String> requeridos_list = new List<String>();
        if(tipox.equals('B')){
           if(String.isBlank(cod_cliente_contacto)){requeridos_list.add('"Número de cuenta de deudor SAP"');}
        }else{
           if(String.isBlank(cod_cliente_contacto)){requeridos_list.add('"Cod de Contacto SAP"');}
        }
        if(String.isBlank(lote.CODLOTE__c)){requeridos_list.add('"Código de Lote" del Lote');}
        if(String.isBlank(lote.CODCOMPANIA__c)){requeridos_list.add('"Código de compañia" del Lote');}
        if(String.isBlank(proyecto_de_lote.CEN_CODIGOSAP__c)){requeridos_list.add('"Código SAP" del Proyecto');}
                validarDatos(requeridos_list);
                
        //	CREAR EL SERVICIO
        CEN_WS_Reserva.ZWS_CREAR_RESERVA_BIND service = new CEN_WS_Reserva.ZWS_CREAR_RESERVA_BIND();
        service.inputHttpHeaders_x = GetAuthorization();
        service.timeout_x = 120000;
        //	CREAR EL BODY DEL REQUEST
        CEN_WS_Reserva.ZsfrfcCrReserva obj = new CEN_WS_Reserva.ZsfrfcCrReserva();
        obj.Tipox = tipox;
        if(tipox.equals('A')){
            obj.Conta = cod_cliente_contacto;
        }else if(tipox.equals('B')){
            obj.Clien = cod_cliente_contacto;
        }
        obj.Bukrs = lote.CODCOMPANIA__c;
        obj.IdMaterial = lote.CODLOTE__c;
        obj.Pspnr = proyecto_de_lote.CEN_CODIGOSAP__c; 
        obj.Foper = String.valueOf(Date.today());
        obj.Imprimir = 'X';

        //obj.Impor = '20';	//	IMPORTE DE RESERVA FIJO    
        obj.Waers = 'PEN'; // CLAVE DE MONEDA FIJO
        obj.Cuotas = 1; // CUOTAS FIJO 1
        try{
            User usuario = [SELECT Id, CEN_ZZVENDEDOR__c FROM User WHERE Id=:System.UserInfo.getUserId() LIMIT 1];
            if(String.isNotBlank(usuario.CEN_ZZVENDEDOR__c)){
                obj.Lifnr = usuario.CEN_ZZVENDEDOR__c;
            }
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        try{
            Quote cotizacion = [SELECT Id, CEN_N_cuotas_del_saldo_de_precio__c, CEN_Cuota_inicial__c, OpportunityId, 
                                CreatedDate, Opportunity.CEN_AmountPaidDate__c  FROM Quote WHERE OpportunityId=:oportunidad_id AND IsDeleted=false 
                                ORDER BY CreatedDate DESC LIMIT 1];
            if(cotizacion.CEN_Cuota_inicial__c!=null){
                obj.ImpCi = String.valueOf(cotizacion.CEN_Cuota_inicial__c);
            }

            obj.Impor = String.ValueOf(cotizacion.Opportunity.CEN_AmountPaidDate__c);
            /*if(cotizacion.CEN_N_cuotas_del_saldo_de_precio__c!=null){
                obj.Cuotas = Integer.valueOf(cotizacion.CEN_N_cuotas_del_saldo_de_precio__c);
            }*/
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        
        System.debug('Crear reserva:\r\n'+obj);
        //	CONSUMIR EL SERVICIO Y OBTENER EL RESPONSE
        CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element response = null;
		try{
            if(Test.isRunningTest()){                
                response = HttpMockFactory.CrearReserva('ok');
            }else{
                 response = service.ZsfRfcCrearReserva(obj);
            }
        }catch(Exception e){
            System.debug('Hubó un problema en usar el Servicio de Crear Reserva en SAP. '+e.getMessage());
            throw new MyException(e.getMessage());
        }
        System.debug('Crear reserva response:\r\n'+response);
        return response;
    }
    public static String FillNullValues(Object value){
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
    private static void validarDatos(List<String> requeridos_list){
         Integer sizeoflist=0;
        if(requeridos_list!=null){
            sizeoflist=requeridos_list.size();
        }
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
                            throw new MyException(requeridos);
                        }
    }
}