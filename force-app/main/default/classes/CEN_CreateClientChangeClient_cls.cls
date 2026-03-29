/*********************************************************************
 * @author: Alan Alvarez (aalvarpe@everis.com)
 * @date: 2021-08-04
 * @description: Clase test de call Api SAP - Crear Cliente desde
 *               transferencia de titularidad.
 *
 * VERSION      DATE                 AUTOR                   ACTION
 * 0.1          2021-08-04           Alan Alvarez            Creación
 *
 *********************************************************************/
public with sharing class CEN_CreateClientChangeClient_cls { 
  private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';

  public static CEN_CreateClientResponse createClientSap(
    Id oppId,
    Id accId,
    String society
  ) {
    system.debug('***IN CEN_CreateClient_cls.createClientByOppId***');
    system.debug('createClientByOppId-oppId: ' + oppId);
    CEN_CreateClientResponse resp;
    try {
      List<Opportunity> lstOpportunity = [
        SELECT
          AccountId,
          CEN_Oficina_de_Venta__c,
          CEN_Medio_Publicitario__c,
          Owner.EmployeeNumber
        FROM Opportunity
        WHERE Id = :oppId
      ];

      if (!Test.isRunningTest()) {
        if (lstOpportunity[0].Owner.EmployeeNumber == null) {
          throw new CreateClientException(
            'Su usuario no cuenta con código de empleado'
          );
        }
      }
      List<Account> lstAccount = [
        SELECT
          Id, Name, LastName, FirstName,
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
        WHERE Id = :accId
      ];
      CEN_CreateClientRequest req = new CEN_CreateClientRequest();
      CEN_CreateClientRequest.ZRFC_OTC_CREAR_CLIENTES_WS_element reqCrearClientes = new CEN_CreateClientRequest.ZRFC_OTC_CREAR_CLIENTES_WS_element();
      CEN_CreateClientRequest.ZTT_CREAR_CLIENTE reqDatosCliente = new CEN_CreateClientRequest.ZTT_CREAR_CLIENTE();
      List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE> lstItem = new List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE>();
      List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE> lstItemApo = new List<CEN_CreateClientRequest.ZWS_CREAR_CLIENTE>();
      CEN_CreateClientRequest.ZWS_CREAR_CLIENTE item = new CEN_CreateClientRequest.ZWS_CREAR_CLIENTE();
      String idTablaMaestra;
      String idTablaMaestraInfLab;
      if (lstAccount[0].Recordtype.DeveloperName == 'PersonAccount') {
        System.debug(':::Entro:PersonAccount');
        String lastName = lstAccount[0].LastName.length() > 50
          ? lstAccount[0].LastName.substring(0, 48)
          : lstAccount[0].LastName;
        if (lastName.indexOf(' ') == -1) {
          lastName = lastName + ' .';
        }
        idTablaMaestra = lstAccount[0].CEN_Distrito__pc;
        idTablaMaestraInfLab = lstAccount[0].CEN_Distrito__pc;
        String documentNumber = lstAccount[0].CEN_N_mero_de_documento__pc;
        documentNumber = documentNumber.replaceFirst('^0+', '');
        Integer lengthDocument = documentNumber.length();
        String strDocumentType = lstAccount[0].CEN_Tipo_de_documento__pc;
        if (
          lstAccount[0].CEN_Tipo_de_documento__pc == 'DNI' &&
          lengthDocument < 8
        ) {
          strDocumentType = 'DNI.ESP';
        }
        if (lstAccount[0].CEN_Tipo_de_documento__pc == 'CAREXTRAN') {
          strDocumentType = 'CARN.EXT';
        }
        item.TIPO_IDENTIF = strDocumentType;
        item.NIF = lstAccount[0].CEN_N_mero_de_documento__pc;
        item.APEL_CONTACTO = lastName;
        String strFirstName = lstAccount[0].FirstName != null
          ? lstAccount[0].FirstName
          : '';
        item.PERS_CONTACTO = strFirstName.length() > 50
          ? strFirstName.substring(0, 50)
          : strFirstName;
        String direccionFull = lstAccount[0].CEN_Direccion__pc != null ? lstAccount[0].CEN_Direccion__pc : '';
        item.DIRECCION = (direccionFull.length() > 60) ? direccionFull.substring(0, 60) : direccionFull;
        item.DIRECCION1 = (direccionFull.length() > 60) ? 
            (direccionFull.length() > 100 ? direccionFull.substring(60, 100) : direccionFull.substring(60)) : '';
        item.DIRECCION2 = (direccionFull.length() > 100) ? 
            (direccionFull.length() > 140 ? direccionFull.substring(100, 140) : direccionFull.substring(100)) : '';
        item.TELEF_FIJO = lstAccount[0].CEN_Tel_fono_Trabajo__pc;
        item.TELEF_MOVIL = lstAccount[0].PersonMobilePhone;
        item.MAIL = lstAccount[0].PersonEmail;

        item.NACIONALIDAD = homologacionPais(lstAccount[0].CEN_Nacionalidad__pc);
        item.LUGARNACIM = lstAccount[0].CEN_Lugar_de_nacimiento__pc;
        item.PAISRESIDENCIA = homologacionPais(lstAccount[0].CEN_paisResidencia__pc);
        If (lstAccount[0].CEN_Tipo_de_relaci_n_laboral__pc == 'Dependiente'){
            item.DEPENDIENTE = 'X';
            item.INDEPENDIENTE = '';
        }else if(lstAccount[0].CEN_Tipo_de_relaci_n_laboral__pc == 'Independiente'){
            item.DEPENDIENTE = '';
            item.INDEPENDIENTE= 'X';
        }
        if (lstAccount[0].CEN_fld_Tiene_apoderado__c){
            item.NOMBREAPO = lstAccount[0].CEN_fld_Nombres_Apoderado__c;
            item.APEPATAPO = lstAccount[0].CEN_fld_Apellidos_apoderado__c;
            item.APEMATAPO = lstAccount[0].CEN_fld_Apellido_mat_apoderado__c;
            item.TIPODOCAPO = homologacionTipoDocApoderado(lstAccount[0].CEN_fld_Tipo_de_documento_de_apoderado__c);
            item.NUMDOCAPO = lstAccount[0].CEN_fld_Numero_de_documento_apoderado__c;
            item.NACAPO = homologacionPais(lstAccount[0].CEN_fld_Nacionalidad_apoderado__c);
            item.NRO_PARTIDA_REGISTRAL = lstAccount[0].CEN_fld_Numero_de_partida_registral__c;
            item.DIRECCAPO = lstAccount[0].CEN_fld_Direccion_apoderado__c;
            item.TIPOPODER = lstAccount[0].CEN_Tipo_poder__c;
        }
        item.ESTADO_CIVIL = homologacionEstadoCivil(lstAccount[0].CEN_Estado_civil__pc);
        item.PROFESION = (lstAccount[0].CEN_Profesion_u_oficio__pc != null && lstAccount[0].CEN_Profesion_u_oficio__pc.length() > 50)
                            ? lstAccount[0].CEN_Profesion_u_oficio__pc.substring(0, 50)
                            : lstAccount[0].CEN_Profesion_u_oficio__pc;
        item.CENTRO_TRABAJO = (lstAccount[0].CEN_Centro_de_trabajo__c != null && lstAccount[0].CEN_Centro_de_trabajo__c.length() > 40)
                            ? lstAccount[0].CEN_Centro_de_trabajo__c.substring(0, 40)
                            : lstAccount[0].CEN_Centro_de_trabajo__c;
        item.JEFE_DIRECTO = lstAccount[0].CEN_Jefe_Directo__pc;
        item.CARGO_ACTUAL = (lstAccount[0].CEN_Cargo_que_ocupa__pc != null && lstAccount[0].CEN_Cargo_que_ocupa__pc.length() > 20)
                            ? lstAccount[0].CEN_Cargo_que_ocupa__pc.substring(0, 20)
                            : lstAccount[0].CEN_Cargo_que_ocupa__pc;
        item.DETALLE_ACT = (lstAccount[0].CEN_fld_Detalle_de_actividad__c != null && lstAccount[0].CEN_fld_Detalle_de_actividad__c.length() > 50)
                            ? lstAccount[0].CEN_fld_Detalle_de_actividad__c.substring(0, 50)
                            : lstAccount[0].CEN_fld_Detalle_de_actividad__c;
        item.DIREC_CTRABAJO = (lstAccount[0].CEN_Direcci_n_Centro_de_Trabajo__pc != null && lstAccount[0].CEN_Direcci_n_Centro_de_Trabajo__pc.length() > 50)
                            ? lstAccount[0].CEN_Direcci_n_Centro_de_Trabajo__pc.substring(0, 50)
                            : lstAccount[0].CEN_Direcci_n_Centro_de_Trabajo__pc;
        // Obtener la fecha como String en formato predeterminado
        String fechaNacimientoRaw = String.valueOf(lstAccount[0].CEN_Fecha_de_Nacimiento__c);
        // Dividir la fecha en componentes (asume que viene en formato yyyy-MM-dd)
        List<String> dateParts = fechaNacimientoRaw.split('-');
        // Reorganizar los componentes al formato dd-MM-yyyy
        String fechaNacimientoFormatted = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
        // Mostrar el resultado
        System.debug('Fecha de nacimiento formateada: ' + fechaNacimientoFormatted);
                        //String formattedDate = String.valueOf(fechaNacimiento.day()).padLeft(2, '0') + '-' + String.valueOf(fechaNacimiento.month()).padLeft(2, '0') + '-' + String.valueOf(fechaNacimiento.year());                
        item.FECH_NACIMIENTO = fechaNacimientoFormatted;
      
        item.TELEF_CTRABAJO = (lstAccount[0].CEN_Tel_fono_Trabajo__pc != null && lstAccount[0].CEN_Tel_fono_Trabajo__pc.length() > 10)
                                ? lstAccount[0].CEN_Tel_fono_Trabajo__pc.substring(0, 10)
                                : lstAccount[0].CEN_Tel_fono_Trabajo__pc;
        item.INGRESO_SOLICITANTE = String.valueOf(lstAccount[0].CEN_Promedio_Mensual_Ingresos__pc);

      } else {
        System.debug(':::Entro:Juridica');
        idTablaMaestra = lstAccount[0].CEN_Distrito__c;
        idTablaMaestraInfLab = lstAccount[0].CEN_Distrito__c;
        item.TIPO_IDENTIF = lstAccount[0].CEN_Tipo_de_documento__c;
        item.NIF = lstAccount[0].CEN_Numero_de_documento_del__c;
        String strName = lstAccount[0].Name != null ? lstAccount[0].Name : '';
        item.APEL_CONTACTO = strName.length() > 50
          ? strName.substring(0, 50)
          : strName;
        String myStringJuri = lstAccount[0].CEN_Direcci_n__c != null
          ? lstAccount[0].CEN_Direcci_n__c
          : '';
        item.DIRECCION = myStringJuri.length() > 50
          ? myStringJuri.substring(0, 50)
          : myStringJuri;
        item.TELEF_MOVIL = lstAccount[0].Phone;
        item.MAIL = lstAccount[0].CEN_fld_Correo_empresa__c;

        item.TELEF_CTRABAJO = (lstAccount[0].CEN_Telefono_Trabajo_Empresa__c != null && lstAccount[0].CEN_Telefono_Trabajo_Empresa__c.length() > 10)
                                ? lstAccount[0].CEN_Telefono_Trabajo_Empresa__c.substring(0, 10)
                                : lstAccount[0].CEN_Telefono_Trabajo_Empresa__c;
        item.NOMBREAPO = lstAccount[0].CEN_fld_Nombres_Apoderado__c;
                        
        item.APEPATAPO = lstAccount[0].CEN_fld_Apellidos_apoderado__c;
        item.APEMATAPO = lstAccount[0].CEN_fld_Apellido_mat_apoderado__c;
        item.TIPODOCAPO = homologacionTipoDocApoderado(lstAccount[0].CEN_fld_Tipo_de_documento_de_apoderado__c);
        item.NUMDOCAPO = lstAccount[0].CEN_fld_Numero_de_documento_apoderado__c;
        item.NACAPO = homologacionPais(lstAccount[0].CEN_fld_Nacionalidad_apoderado__c);
        item.NRO_PARTIDA_REGISTRAL = lstAccount[0].CEN_fld_Numero_de_partida_registral__c;
        item.DIRECCAPO = lstAccount[0].CEN_fld_Direccion_apoderado__c;
        item.TIPOPODER = lstAccount[0].CEN_Tipo_poder__c;
      }
      if (society == null || society == '') {
        throw new CreateClientException(
          'No se ha registrado alguna sociedad en CEN_SocietySAP__mdt'
        );
      }

      item.COMENTARIOS = (lstAccount[0].CEN_Referencia_direccion__c != null && lstAccount[0].CEN_Referencia_direccion__c.length() > 50) 
                                    ? lstAccount[0].CEN_Referencia_direccion__c.substring(0, 50) 
                                    : lstAccount[0].CEN_Referencia_direccion__c;
      item.DEPARTAMENTO = lstAccount[0].CEN_Departamento__c;

      item.PROVINCIA = lstAccount[0].Provincia__c;
      item.DISTRITO = lstAccount[0].CEN_Distrito__c;
      item.WAERS = homologacionMoneda(lstAccount[0].Moneda__pc);
      item.ZZPAIS = 'PE';
      item.SOCIEDAD = society;
      item.ZZVENDEDOR = lstOpportunity[0].Owner.EmployeeNumber;
      item.ZZMEDIO = lstOpportunity[0].CEN_Medio_Publicitario__c;
      item.ZZZONAVENTA = lstOpportunity[0].CEN_Oficina_de_Venta__c;
      //Distrito
      List<Tabla_maestra__c> lstTablaMaestra = [
        SELECT
          CEN_Codigo_departamento__c,
          CEN_Codigo_provincia__c,
          CEN_Codigo_distrito__c
        FROM Tabla_maestra__c
        WHERE Id = :idTablaMaestra
      ];
      if (!Test.isRunningTest()) {
        if (lstTablaMaestra.size() < 1) {
          throw new CreateClientException('El cliente no cuenta con Distrito');
        }
      }
      item.ZZPAIS = 'PE';
      item.ZZDEPARTAMENTO = lstTablaMaestra[0].CEN_Codigo_departamento__c;
      item.ZZPROVINCIA = lstTablaMaestra[0].CEN_Codigo_provincia__c;
      item.ZZDISTRITO = lstTablaMaestra[0].CEN_Codigo_distrito__c;
      lstItem.add(item);

      List<Tabla_maestra__c> lstTablaMaestraApo = [Select CEN_Codigo_departamento__c, CEN_Codigo_provincia__c, CEN_Codigo_distrito__c
                                                          From Tabla_maestra__c Where Id = :idTablaMaestraInfLab];
      item.DEPARTAMENTO = lstTablaMaestraApo.isEmpty() ? null : lstTablaMaestraApo[0].CEN_Codigo_departamento__c;
      item.PROVINCIA = lstTablaMaestraApo.isEmpty() ? null :lstTablaMaestraApo[0].CEN_Codigo_provincia__c;
      item.DISTRITO = lstTablaMaestraApo.isEmpty() ? null: lstTablaMaestraApo[0].CEN_Codigo_distrito__c;
      
      lstItemApo.add(item);

      
      reqDatosCliente.item = lstItem;
      reqCrearClientes.IT_DATOS_CLIENTE = reqDatosCliente;
      req.ZMF_CREAR_CLIENTE = reqCrearClientes;
      resp = callCreateClientApi(req);
    } catch (Exception ex) {
      System.debug('createClientByOppId-msgError: ' + ex.getMessage());
      resp = new CEN_CreateClientResponse();
      CEN_CreateClientResponse.BAPIRET2_T respError = new CEN_CreateClientResponse.BAPIRET2_T();
      List<CEN_CreateClientResponse.BAPIRET2> respErrorList = new List<CEN_CreateClientResponse.BAPIRET2>();
      CEN_CreateClientResponse.BAPIRET2 respErrorDetails = new CEN_CreateClientResponse.BAPIRET2();
      respErrorDetails.TYPE_x = 'E';
      respErrorDetails.MESSAGE = ex.getMessage();
      respErrorList.add(respErrorDetails);
      respError.item = respErrorList;
      resp.ET_RETURN = respError;
      CEN_CreateClientResponse.ZTT_CLIENTE_DOCSAP respErrorClient = new CEN_CreateClientResponse.ZTT_CLIENTE_DOCSAP();
      List<CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP> respErrorClientList = new List<CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP>();
      CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP respErrorClientDetails = new CEN_CreateClientResponse.ZWS_CLIENTE_DOCSAP();
      respErrorClientDetails.KUNNR = null;
      respErrorClientList.add(respErrorClientDetails);
      respErrorClient.item = respErrorClientList;
      resp.ET_CLIENTE = respErrorClient;
    }
    return resp;
  }

  private static CEN_CreateClientResponse callCreateClientApi(
    CEN_CreateClientRequest reqProcess
  ) {
    system.debug('IN CEN_CreateClientResponse');
    String customReqBody;
    CEN_CreateClientResponse resp = new CEN_CreateClientResponse();
    XMLSerializer serializerXML = new XMLSerializer();
    customReqBody = serializerXML.serialize(reqProcess);
    customReqBody = customReqBody.replace('ZMF_CREAR_CLIENTE','urn:ZMF_CREAR_CLIENTE');
    try {
      CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_CrearCliente');
      Dom.Document docReq = new Dom.Document();
      String setReq = customReq.replace('myBody', customReqBody);
      System.debug('CEN_CreateClient-setReq: ' + setReq);
      docReq.load(setReq);
      callApi.setRequestBody(docReq);
      resp = (CEN_CreateClientResponse) callApi.makeCallout()
        .getParsedResponse();
      system.debug('CEN_CreateClient-resp: ' + resp);
    } catch (Exception ex) {
      System.debug(
        'CEN_CreateClient-Error: ' + ex.getMessage() + '-' + ex.getLineNumber()
      );
    }
    return resp;
  }

  public class CreateClientException extends Exception {
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
}