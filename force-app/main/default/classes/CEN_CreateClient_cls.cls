/*********************************************************************
* @author: Alan Alvarez (aalvarpe@everis.com)
* @date: 2021-06-22
* @description: Clase de evento call Api SAP - Crear Cliente.
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2021-06-22           Alan Alvarez            Creación
*
*********************************************************************/
public with sharing class CEN_CreateClient_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    public static CEN_CreateClientResponse createClientByOppId(
        Id oppId
    ) {
        system.debug('***IN CEN_CreateClient_cls.createClientByOppId***');
        system.debug('createClientByOppId-oppId: ' + oppId);
        CEN_CreateClientResponse resp;
        try {
            List<Opportunity> lstOpportunity = [Select AccountId, CEN_Oficina_de_Venta__c, CEN_Medio_Publicitario__c,
                                                CEN_Proyecto__r.CEN_Sociedad__c, Owner.EmployeeNumber
                                                From Opportunity Where Id = :oppId];

            if (!Test.isRunningTest()) {
            	if(lstOpportunity[0].Owner.EmployeeNumber == null){throw new CreateClientException('Su usuario no cuenta con código de empleado');}
            }

            List<OpportunityPartner> lstOpportunityPartner = [  SELECT Id, OpportunityId, AccountToId,Role,IsPrimary,CreatedDate,CreatedById,
                                                                LastModifiedDate,LastModifiedById,SystemModstamp,IsDeleted,ReversePartnerId
                                                                FROM OpportunityPartner
                                                                WHERE OpportunityId = :oppId
                                                                AND AccountToId != :lstOpportunity[0].AccountId
                                                                AND IsDeleted = FALSE];

            // Id's de los partners encontrados incluyendo el titular
            Set<Id> accountIds = new Set<Id>();

            accountIds.add(lstOpportunity[0].AccountId);

            for (OpportunityPartner partner : lstOpportunityPartner) {
                if (partner.AccountToId != null) {
                    accountIds.add(partner.AccountToId);
                }
            }

            // Obtener todas las cuentas asociadas a esos AccountToId
            List<Account> lstAccount = new List<Account>();

            if (!accountIds.isEmpty()) {
                lstAccount = [ SELECT  Id, Name, LastName, FirstName,
                                CEN_Tipo_de_documento__pc, CEN_N_mero_de_documento__pc, CEN_Distrito__pc, CEN_Direccion__pc, PersonMobilePhone, CEN_Tel_fono_Trabajo__pc, PersonEmail,
                                CEN_Tipo_de_documento__c, CEN_Numero_de_documento_del__c, CEN_Distrito__c, CEN_Direcci_n__c, CEN_Referencia_direccion__c, Phone, CEN_fld_Correo_empresa__c,
                                Recordtype.DeveloperName,Comentario__c,CEN_Nacionalidad__pc,CEN_Lugar_de_nacimiento__pc,CEN_paisResidencia__pc,
                                CEN_Tipo_de_relaci_n_laboral__pc, CEN_Departamento__c,Provincia__c,Moneda__pc,
                                CEN_Promedio_Mensual_Ingresos__pc,CEN_fld_Apellidos_apoderado__c, CEN_fld_Apellido_mat_apoderado__c, CEN_fld_Tipo_de_documento_de_apoderado__c,
                                CEN_fld_Numero_de_documento_apoderado__c,CEN_fld_Nacionalidad_apoderado__c,CEN_fld_Numero_de_partida_registral__c,
                                CEN_Tipo_poder__c,CEN_fld_Direccion_apoderado__c, CEN_fld_Tiene_apoderado__c,
                                CEN_Estado_civil__pc,CEN_Profesion_u_oficio__pc,CEN_Centro_de_trabajo__c,CEN_Jefe_Directo__pc,
                                CEN_Cargo_que_ocupa__pc,CEN_fld_Detalle_de_actividad__c,CEN_Direcci_n_Centro_de_Trabajo__pc,
                                CEN_Fecha_de_Nacimiento__c,CEN_Telefono_Trabajo_Empresa__c,CEN_fld_Nombres_Apoderado__c
                                FROM Account 
                                WHERE Id IN :accountIds];
            }

            System.debug('lstAccount luis: ' + lstAccount);
            
            String idTablaMaestra;
            String idTablaMaestraInfLab;
            Integer reqIntento = 1;

            for (Account acc : lstAccount) {
                CEN_CreateClientRequest req = new CEN_CreateClientRequest();
                CEN_CreateClientRequest.ZRFC_OTC_CREAR_CLIENTES_WS_element reqCrearClientes = new CEN_CreateClientRequest.ZRFC_OTC_CREAR_CLIENTES_WS_element();
                CEN_CreateClientRequest.ZTT_CREAR_CLIENTE reqDatosCliente = new CEN_CreateClientRequest.ZTT_CREAR_CLIENTE();
                List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE> lstItem = new List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE>();
                List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE> lstItemApo = new List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE>();
                CEN_CreateClientRequest.ZWS_CREAR_CLIENTE item = new CEN_CreateClientRequest.ZWS_CREAR_CLIENTE();
                if(acc.Recordtype.DeveloperName == 'PersonAccount'){
                    System.debug(':::Entro:PersonAccount');
                    //Validate LastName
                    String lastName = acc.LastName.length()>50? acc.LastName.substring(0, 48):acc.LastName;
                    if(lastName.indexOf(' ') == -1){lastName = lastName + ' .';}
                    idTablaMaestra = acc.CEN_Distrito__pc;
                    idTablaMaestraInfLab = acc.CEN_Distrito__pc;
                    //Integer documentNumber = Integer.valueOf(lstAccount[0].CEN_N_mero_de_documento__pc);
                    //Integer lengthDocument = String.valueOf(documentNumber).length();
                    String numberDocumentRemoveCero = acc.CEN_N_mero_de_documento__pc.replaceFirst('^0+','');
                    Integer lengthDocument = numberDocumentRemoveCero.length();
                    String strDocumentType = acc.CEN_Tipo_de_documento__pc;
                    if(acc.CEN_Tipo_de_documento__pc == 'DNI' && lengthDocument < 8){
                        strDocumentType = 'DNI.ESP';
                    }
                    if(acc.CEN_Tipo_de_documento__pc == 'CAREXTRAN'){
                        strDocumentType = 'CARN.EXT';
                    }
                    item.TIPO_IDENTIF = strDocumentType.toUpperCase();
                	item.NIF = acc.CEN_N_mero_de_documento__pc;
                    item.APEL_CONTACTO = lastName;
                    String strFirstName = acc.FirstName != null? acc.FirstName: '';
                    item.PERS_CONTACTO = strFirstName.length()>50? strFirstName.substring(0, 50):strFirstName;
                    String direccionFull = acc.CEN_Direccion__pc != null ? acc.CEN_Direccion__pc : '';
                    // DIRECCION: primeros 60 caracteres
                    item.DIRECCION = (direccionFull.length() > 60) ? direccionFull.substring(0, 60) : direccionFull;
                    // DIRECCION1: siguientes 40 caracteres (del 60 al 100)
                    item.DIRECCION1 = (direccionFull.length() > 60) ? 
                        (direccionFull.length() > 100 ? direccionFull.substring(60, 100) : direccionFull.substring(60)) : '';
                    // DIRECCION2: siguientes 40 caracteres (del 100 al 140)
                    item.DIRECCION2 = (direccionFull.length() > 100) ? 
                        (direccionFull.length() > 140 ? direccionFull.substring(100, 140) : direccionFull.substring(100)) : '';
                    item.TELEF_FIJO = acc.CEN_Tel_fono_Trabajo__pc;
                    item.TELEF_MOVIL = acc.PersonMobilePhone;
                    item.MAIL = acc.PersonEmail;

                    item.NACIONALIDAD = homologacionPais(acc.CEN_Nacionalidad__pc);
                    item.LUGARNACIM=acc.CEN_Lugar_de_nacimiento__pc;
                    item.PAISRESIDENCIA= homologacionPais(acc.CEN_paisResidencia__pc);

                    If (acc.CEN_Tipo_de_relaci_n_laboral__pc == 'Dependiente'){
                        item.DEPENDIENTE = 'X';
                        item.INDEPENDIENTE = '';
                    }else if(acc.CEN_Tipo_de_relaci_n_laboral__pc == 'Independiente'){
                        item.DEPENDIENTE = '';
                        item.INDEPENDIENTE= 'X';
                    }

                    if (acc.CEN_fld_Tiene_apoderado__c){
                        item.NOMBREAPO = acc.CEN_fld_Nombres_Apoderado__c;
                        item.APEPATAPO = acc.CEN_fld_Apellidos_apoderado__c;
                        item.APEMATAPO = acc.CEN_fld_Apellido_mat_apoderado__c;
                        item.TIPODOCAPO = homologacionTipoDocApoderado(acc.CEN_fld_Tipo_de_documento_de_apoderado__c);
                        item.NUMDOCAPO = acc.CEN_fld_Numero_de_documento_apoderado__c;
                        item.NACAPO = homologacionPais(acc.CEN_fld_Nacionalidad_apoderado__c);
                        item.NRO_PARTIDA_REGISTRAL = acc.CEN_fld_Numero_de_partida_registral__c;
                        item.DIRECCAPO = acc.CEN_fld_Direccion_apoderado__c;
                        item.TIPOPODER = acc.CEN_Tipo_poder__c;
                    }

                    item.ESTADO_CIVIL = homologacionEstadoCivil(acc.CEN_Estado_civil__pc);
                    item.PROFESION = (acc.CEN_Profesion_u_oficio__pc != null && acc.CEN_Profesion_u_oficio__pc.length() > 50) 
                                        ? acc.CEN_Profesion_u_oficio__pc.substring(0, 50) 
                                        : acc.CEN_Profesion_u_oficio__pc;
                    item.CENTRO_TRABAJO = (acc.CEN_Centro_de_trabajo__c != null && acc.CEN_Centro_de_trabajo__c.length() > 40) 
                                        ? acc.CEN_Centro_de_trabajo__c.substring(0, 40) 
                                        : acc.CEN_Centro_de_trabajo__c;
                    item.JEFE_DIRECTO = acc.CEN_Jefe_Directo__pc;
                    item.CARGO_ACTUAL = (acc.CEN_Cargo_que_ocupa__pc != null && acc.CEN_Cargo_que_ocupa__pc.length() > 20) 
                                        ? acc.CEN_Cargo_que_ocupa__pc.substring(0, 20) 
                                        : acc.CEN_Cargo_que_ocupa__pc;
                    item.DETALLE_ACT = (acc.CEN_fld_Detalle_de_actividad__c != null && acc.CEN_fld_Detalle_de_actividad__c.length() > 50) 
                                        ? acc.CEN_fld_Detalle_de_actividad__c.substring(0, 50) 
                                        : acc.CEN_fld_Detalle_de_actividad__c;
                    item.DIREC_CTRABAJO = (acc.CEN_Direcci_n_Centro_de_Trabajo__pc != null && acc.CEN_Direcci_n_Centro_de_Trabajo__pc.length() > 50) 
                                        ? acc.CEN_Direcci_n_Centro_de_Trabajo__pc.substring(0, 50) 
                                        : acc.CEN_Direcci_n_Centro_de_Trabajo__pc;
                    // Obtener la fecha como String en formato predeterminado
                    String fechaNacimientoRaw = String.valueOf(acc.CEN_Fecha_de_Nacimiento__c);

                    // Dividir la fecha en componentes (asume que viene en formato yyyy-MM-dd)
                    List<String> dateParts = fechaNacimientoRaw.split('-');

                    // Reorganizar los componentes al formato dd-MM-yyyy
                    String fechaNacimientoFormatted = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];

                    // Mostrar el resultado
                    System.debug('Fecha de nacimiento formateada: ' + fechaNacimientoFormatted);

			    	//String formattedDate = String.valueOf(fechaNacimiento.day()).padLeft(2, '0') + '-' + String.valueOf(fechaNacimiento.month()).padLeft(2, '0') + '-' + String.valueOf(fechaNacimiento.year());		
                   item.FECH_NACIMIENTO = fechaNacimientoFormatted;
                   
                    item.TELEF_CTRABAJO = (acc.CEN_Tel_fono_Trabajo__pc != null && acc.CEN_Tel_fono_Trabajo__pc.length() > 10) 
                                            ? acc.CEN_Tel_fono_Trabajo__pc.substring(0, 10) 
                                            : acc.CEN_Tel_fono_Trabajo__pc;
                    item.INGRESO_SOLICITANTE = String.valueOf(acc.CEN_Promedio_Mensual_Ingresos__pc);
                }else{
                    System.debug(':::Entro:Juridca');
                    idTablaMaestra = acc.CEN_Distrito__c;
                    idTablaMaestraInfLab = acc.CEN_Distrito__c;
                    item.TIPO_IDENTIF = acc.CEN_Tipo_de_documento__c.toUpperCase();
                	item.NIF = acc.CEN_Numero_de_documento_del__c;
                    String strName = acc.Name != null? acc.Name: '';
                    item.APEL_CONTACTO = strName.length()>50? strName.substring(0, 50): strName;
                    String myStringJuri = acc.CEN_Direcci_n__c != null? acc.CEN_Direcci_n__c: '';
                    item.DIRECCION = myStringJuri.length()>50?myStringJuri.substring(0, 50):myStringJuri;
                    item.TELEF_MOVIL = acc.Phone;
                    item.MAIL = acc.CEN_fld_Correo_empresa__c;
                    item.TELEF_CTRABAJO = (acc.CEN_Telefono_Trabajo_Empresa__c != null && acc.CEN_Telefono_Trabajo_Empresa__c.length() > 10) 
                                            ? acc.CEN_Telefono_Trabajo_Empresa__c.substring(0, 10) 
                                            : acc.CEN_Telefono_Trabajo_Empresa__c;

                    item.NOMBREAPO = acc.CEN_fld_Nombres_Apoderado__c;
                                    
                    item.APEPATAPO = acc.CEN_fld_Apellidos_apoderado__c;
                    item.APEMATAPO = acc.CEN_fld_Apellido_mat_apoderado__c;
                    item.TIPODOCAPO = homologacionTipoDocApoderado(acc.CEN_fld_Tipo_de_documento_de_apoderado__c);
                    item.NUMDOCAPO = acc.CEN_fld_Numero_de_documento_apoderado__c;
                    item.NACAPO = homologacionPais(acc.CEN_fld_Nacionalidad_apoderado__c);
                    item.NRO_PARTIDA_REGISTRAL = acc.CEN_fld_Numero_de_partida_registral__c;
                    item.DIRECCAPO = acc.CEN_fld_Direccion_apoderado__c;
                    item.TIPOPODER = acc.CEN_Tipo_poder__c;
                }

                item.COMENTARIOS = (acc.CEN_Referencia_direccion__c != null && acc.CEN_Referencia_direccion__c.length() > 50) 
                                    ? acc.CEN_Referencia_direccion__c.substring(0, 50) 
                                    : acc.CEN_Referencia_direccion__c;
                item.DEPARTAMENTO = acc.CEN_Departamento__c;
                item.PROVINCIA = acc.Provincia__c;
                item.DISTRITO = acc.CEN_Distrito__c;
                item.WAERS = homologacionMoneda(acc.Moneda__pc);

                item.ZZPAIS = 'PE';
                item.SOCIEDAD = lstOpportunity[0].CEN_Proyecto__r.CEN_Sociedad__c;
                item.ZZVENDEDOR = lstOpportunity[0].Owner.EmployeeNumber;
                item.ZZMEDIO = lstOpportunity[0].CEN_Medio_Publicitario__c;
                item.ZZZONAVENTA = lstOpportunity[0].CEN_Oficina_de_Venta__c;
                //Direccion
                List<Tabla_maestra__c> lstTablaMaestra = [Select CEN_Codigo_departamento__c, CEN_Codigo_provincia__c, CEN_Codigo_distrito__c
                                                          From Tabla_maestra__c Where Id = :idTablaMaestra];
                if (!Test.isRunningTest()) {
                    if(lstTablaMaestra.size() < 1){throw new CreateClientException('El cliente no cuenta con Distrito');}
                }
                item.ZZDEPARTAMENTO = lstTablaMaestra[0].CEN_Codigo_departamento__c;
                item.ZZPROVINCIA = lstTablaMaestra[0].CEN_Codigo_provincia__c;
                item.ZZDISTRITO = lstTablaMaestra[0].CEN_Codigo_distrito__c;
                lstItem.add(item);

                List<Tabla_maestra__c> lstTablaMaestraApo = [Select CEN_Codigo_departamento__c, CEN_Codigo_provincia__c, CEN_Codigo_distrito__c
                                                          From Tabla_maestra__c Where Id = :idTablaMaestraInfLab];

                /* item.DEPARTAMENTO = lstTablaMaestraApo[0].CEN_Codigo_departamento__c;
                item.PROVINCIA = lstTablaMaestraApo[0].CEN_Codigo_provincia__c;
                item.DISTRITO = lstTablaMaestraApo[0].CEN_Codigo_distrito__c; */

                item.DEPARTAMENTO = lstTablaMaestraApo.isEmpty() ? null : lstTablaMaestraApo[0].CEN_Codigo_departamento__c;
                item.PROVINCIA = lstTablaMaestraApo.isEmpty() ? null :lstTablaMaestraApo[0].CEN_Codigo_provincia__c;
                item.DISTRITO = lstTablaMaestraApo.isEmpty() ? null: lstTablaMaestraApo[0].CEN_Codigo_distrito__c;
                
                lstItemApo.add(item);

                reqDatosCliente.item = lstItem;
                reqCrearClientes.IT_DATOS_CLIENTE = reqDatosCliente;
                req.ZMF_CREAR_CLIENTE = reqCrearClientes;
                resp = callCreateClientApi(req);
                system.debug('reqL:' + reqIntento + req);
                reqIntento++;
            }
        } catch (Exception ex) {
            System.debug('createClientByOppId-msgError: ' + ex.getMessage());
            resp = new CEN_CreateClientResponse();
            CEN_CreateClientResponse.BAPIRET2_T respError = new CEN_CreateClientResponse.BAPIRET2_T();
            List<CEN_CreateClientResponse.BAPIRET2> respErrorList = new List<CEN_CreateClientResponse.BAPIRET2>();
            CEN_CreateClientResponse.BAPIRET2 respErrorDetails = new CEN_CreateClientResponse.BAPIRET2();
            respErrorDetails.TYPE_x ='E';
            respErrorDetails.MESSAGE = ex.getMessage();
            respErrorList.add(respErrorDetails);
            respError.item = respErrorList;
            resp.ET_RETURN = respError;
            CEN_CreateClientResponse.ZTT_CLIENTE_DOCSAP respErrorClient = new CEN_CreateClientResponse.ZTT_CLIENTE_DOCSAP();
            List<CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP> respErrorClientList = new List<CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP>();
            CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP respErrorClientDetails = new CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP();
            respErrorClientDetails.KUNNR = NULL;
            respErrorClientList.add(respErrorClientDetails);
            respErrorClient.item = respErrorClientList;
            resp.ET_CLIENTE = respErrorClient;
        }
        return resp;
    }

    private static String homologacionTipoDocApoderado(String tipoDocApoderado){
        String tipoDocApoHomologado;

        if(tipoDocApoderado == 'DNI'){
            tipoDocApoHomologado = '96';
        }else if(tipoDocApoderado == 'Carnet de extranjería'){
            tipoDocApoHomologado = '91';
        }else if(tipoDocApoderado == 'Pasaporte'){
            tipoDocApoHomologado = '94';
        }else if(tipoDocApoderado == 'PTP'){
            tipoDocApoHomologado = '99';
        }else if(tipoDocApoderado == 'Sin especificar'){
            tipoDocApoHomologado = '99';
        }

        return tipoDocApoHomologado;
    }

    private static String homologacionEstadoCivil(String estadoCivil){
        String estadoCivilHomologado;

        if(estadoCivil == 'Soltero'){
            estadoCivilHomologado = '0';
        }else if(estadoCivil == 'Casado'){
            estadoCivilHomologado = '1';
        }else if(estadoCivil == 'Viudo'){
            estadoCivilHomologado = '2';
        }else if(estadoCivil == 'Divorc'){
            estadoCivilHomologado = '3';
        }else if(estadoCivil == 'Separa'){
            estadoCivilHomologado = '5';
        }else if(estadoCivil == 'Conviv'){
            estadoCivilHomologado = '6';
        }else if(estadoCivil == 'CasSep'){
            estadoCivilHomologado = '7';
        }else if(estadoCivil == 'PRsep'){
            estadoCivilHomologado = 'A';
        }

        return estadoCivilHomologado;
    }

    private static String homologacionMoneda(String moneda){
        String monedaHomologado;

        if(moneda == '$'){
            monedaHomologado = 'USD';
        }else if(moneda == 'S/'){
            monedaHomologado = 'PEN';
        }else if(moneda == '€'){
            monedaHomologado = 'EUR';
        }

        return monedaHomologado;
    }

    private static String homologacionPais(String pais){
        String paisHomologado;

        if ( pais == 'PE'){
            return 'PE';
        } 

        List<CEN_Maestro_Pais__c> lpais = [SELECT Id, Name, CEN_Codigo_Pais__c FROM CEN_Maestro_Pais__c WHERE Name =: pais WITH USER_MODE];

        for (CEN_Maestro_Pais__c varPais : lpais) {
            paisHomologado = varPais.CEN_Codigo_Pais__c;
        }
        return paisHomologado;
    }

    private static CEN_CreateClientResponse callCreateClientApi(
        CEN_CreateClientRequest reqProcess
    ) {
        system.debug('IN CEN_CreateClientResponse');
        String customReqBody;
        CEN_CreateClientResponse resp = new CEN_CreateClientResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZMF_CREAR_CLIENTE',
            'urn:ZMF_CREAR_CLIENTE'
        );
        try {
            System.debug('customReqBody: ' + customReqBody);

            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_CrearCliente');
            Dom.Document docReq = new Dom.Document();
            System.debug('customReqBody: ' + customReqBody);
            String setReq = customReq.replace('myBody', customReqBody);
            setReq = setReq.replace('&', '&amp;');
            System.debug('CEN_CreateClient-setReq: ' + setReq);
            docReq.load(setReq);

            callApi.setRequestBody(docReq);
            if(!Test.isRunningTest()){
                callApi.setTimeout(50000);
            }
            resp = (CEN_CreateClientResponse) callApi.makeCallout().getParsedResponse();
            system.debug('CEN_CreateClient-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_CreateClient-Error: ' + ex.getMessage() + '-' + ex.getLineNumber());
        }
        return resp;
    }

    public class CreateClientException extends Exception {
    }

}