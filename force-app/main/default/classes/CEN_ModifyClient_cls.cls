public with sharing class CEN_ModifyClient_cls {
    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    public static CEN_ModifyClientObjectResponse modifyClientById(
       Id clientId, String sociedad, Map<String,String> mapAccount
    ) {
        system.debug('***IN CEN_ModifyClient_cls.modifyClientById***');
        system.debug('modifyClientById-clientId: ' + clientId);
        CEN_ModifyClientObjectResponse resp;
        try {

            Account acc = [Select Id, Salutation, Name, LastName, FirstName, CEN_Fecha_de_Nacimiento__c, 
            CEN_Tipo_de_documento__pc, CEN_N_mero_de_documento__pc, CEN_Distrito__pc, CEN_Direccion__pc, 
            PersonMobilePhone, CEN_Tel_fono_Trabajo__pc, PersonEmail, CEN_Tipo_de_documento__c, CEN_Numero_de_documento_del__c, 
            CEN_Distrito__c, CEN_Direcci_n__c, Phone, CEN_fld_Correo_empresa__c, Recordtype.DeveloperName, RecordTypeId, OwnerId, 
            RecordType.Name, CEN_SocietySAP__c, CEN_Referencia_direccion__c, CEN_Nacionalidad__pc, CEN_Estado_civil__pc, CEN_Lugar_de_nacimiento__pc,
            CEN_Departamento_cont__pc,CEN_Departamento__c, CEN_Provincia_contact__pc, Provincia__c 
            From Account Where Id =: clientId];

            CEN_ModifyClientObjectRequest req = new CEN_ModifyClientObjectRequest();
            CEN_ModifyClientObjectRequest.ZRFC_OTC_MODIF_DATOS_CLIENTE_element reqModClient = new CEN_ModifyClientObjectRequest.ZRFC_OTC_MODIF_DATOS_CLIENTE_element();
            CEN_ModifyClientObjectRequest.ZACCO_MODIF_DATOS_CLIENTE reqClient = new CEN_ModifyClientObjectRequest.ZACCO_MODIF_DATOS_CLIENTE();
            CEN_ModifyClientObjectRequest.ZACCO_MODIF_DATOS_CLIENTEX reqClientX = new CEN_ModifyClientObjectRequest.ZACCO_MODIF_DATOS_CLIENTEX();
            String idTablaMaestra;
            String documentNumber;
            String tratamiento;
            switch on acc.Salutation {
                when  'Sr.' {
                    tratamiento = 'Señor';
                }
                when 'Sra.' {
                    tratamiento = 'Señora';
                }
                when 'Srta.' {
                    tratamiento = 'Señora'; //revisar con SAP
                }
            }

            if(String.isBlank(acc.CEN_SocietySAP__c)){throw new ModifyClientException('El cliente no cuenta con sociedad');}

            if(acc.Recordtype.DeveloperName == 'PersonAccount'){
                System.debug(':::Entro:PersonAccount');
                idTablaMaestra = acc.CEN_Distrito__pc;
                reqClient.TRATAMIENTO = String.isEmpty(mapAccount.get('tratamiento')) ? '' : tratamiento;
                String strFirstName = acc.FirstName != null? acc.FirstName: '';
                reqClient.NOMBRES = String.isEmpty(mapAccount.get('nombres')) ? '' : strFirstName;
                String lastName = acc.LastName.length()>35? acc.LastName.substring(0, 35):acc.LastName;
                if(lastName.indexOf(' ') == -1){lastName = lastName + ' .';}
                reqClient.APELLIDOS = String.isEmpty(mapAccount.get('apellidos')) ? '' :lastName;
                reqClient.FECHA_NACIMIENTO = String.isEmpty(mapAccount.get('fechaNacimiento')) ? '' : String.valueOf(acc.CEN_Fecha_de_Nacimiento__c);
                List<CEN_EstadoCivil__mdt> lstEstCivMdt = [Select label, DeveloperName from CEN_EstadoCivil__mdt where DeveloperName =:acc.CEN_Estado_civil__pc];
                if(lstEstCivMdt.size() == 0){throw new ModifyClientException('El cliente no tiene estado civil');}
                reqClient.ESTADO_CIVIL = String.isEmpty(mapAccount.get('estadoCivil')) ? '' : lstEstCivMdt[0].label;
                reqClient.LUGAR_NACIMIENTO = String.isEmpty(mapAccount.get('lugarNacimiento')) ? '' : acc.CEN_Lugar_de_nacimiento__pc;
                String myStringDireccion = acc.CEN_Direccion__pc != null? acc.CEN_Direccion__pc: '';
                reqClient.DIRECCION = String.isEmpty(mapAccount.get('direccion')) ? '' : myStringDireccion.length()>35?myStringDireccion.substring(0, 35):myStringDireccion;
                String myStringRef = acc.CEN_Referencia_direccion__c != null? acc.CEN_Referencia_direccion__c: '';
                reqClient.REFERENCIA = String.isEmpty(mapAccount.get('referencia')) ? '' : myStringRef.length()>40?myStringRef.substring(0, 40):myStringRef;
                reqClient.TELEFONO_FIJO = String.isEmpty(mapAccount.get('telefonoFijo')) ? '' : acc.CEN_Tel_fono_Trabajo__pc;//acc.Phone;
                reqClient.TELEFONO_MOVIL = String.isEmpty(mapAccount.get('telefonoMovil')) ? '' : acc.PersonMobilePhone;
                reqClient.EMAIL = String.isEmpty(mapAccount.get('email')) ? '' : acc.PersonEmail;
                reqClient.NACIONALIDAD = String.isEmpty(mapAccount.get('nacionalidad')) ? '' : acc.CEN_Nacionalidad__pc;
                documentNumber = acc.CEN_N_mero_de_documento__pc;

                reqClientX.TRATAMIENTO = mapAccount.get('tratamiento');//'X';
                reqClientX.NOMBRES = mapAccount.get('nombres');//'X';
                reqClientX.APELLIDOS = mapAccount.get('apellidos');//'X';
                reqClientX.FECHA_NACIMIENTO = mapAccount.get('fechaNacimiento');//'X';
                reqClientX.ESTADO_CIVIL = mapAccount.get('estadoCivil');//'X';
                reqClientX.LUGAR_NACIMIENTO = mapAccount.get('lugarNacimiento');//'X';
                reqClientX.DIRECCION = mapAccount.get('direccion');//'X';
                reqClientX.REFERENCIA = mapAccount.get('referencia');//'X';
                reqClientX.TELEFONO_FIJO = mapAccount.get('telefonoFijo');//'X';
                reqClientX.TELEFONO_MOVIL = mapAccount.get('telefonoMovil');//'X';
                reqClientX.EMAIL = mapAccount.get('email');//'X';
                reqClientX.NACIONALIDAD = mapAccount.get('nacionalidad'); //'X';

            }else{
                System.debug(':::Entro:Juridica');
                idTablaMaestra = acc.CEN_Distrito__c;
                reqClient.TRATAMIENTO = String.isEmpty(mapAccount.get('tratamiento')) ? '' : 'Empresa';

                String empresaName = acc.Name.length()>35? acc.Name.substring(0, 35):acc.Name;
                reqClient.NOMBRES = String.isEmpty(mapAccount.get('nombres')) ? '' : empresaName;
                String myStringDireccion = acc.CEN_Direcci_n__c != null? acc.CEN_Direcci_n__c: '';
                reqClient.DIRECCION = String.isEmpty(mapAccount.get('direccion')) ? '' : myStringDireccion.length()>35?myStringDireccion.substring(0, 35):myStringDireccion;
                String myStringRef = acc.CEN_Referencia_direccion__c != null? acc.CEN_Referencia_direccion__c: '';
                reqClient.REFERENCIA = String.isEmpty(mapAccount.get('referencia')) ? '' : myStringRef.length()>40?myStringRef.substring(0, 40):myStringRef;
                reqClient.TELEFONO_FIJO = '';
                reqClient.TELEFONO_MOVIL = String.isEmpty(mapAccount.get('telefonoMovil')) ? '' : acc.Phone;
                reqClient.EMAIL = String.isEmpty(mapAccount.get('email')) ? '' : acc.CEN_fld_Correo_empresa__c;
                reqClient.LUGAR_NACIMIENTO = '';
                reqClient.FECHA_NACIMIENTO = '';
                reqClient.ESTADO_CIVIL = '';
                reqClient.APELLIDOS = '';
                reqClient.NACIONALIDAD = '';
                documentNumber = acc.CEN_Numero_de_documento_del__c;

                reqClientX.TRATAMIENTO = mapAccount.get('tratamiento');//'X';
                reqClientX.NOMBRES = mapAccount.get('nombres');//'X';
                reqClientX.DIRECCION = mapAccount.get('dreccion');//'X';
                reqClientX.REFERENCIA = mapAccount.get('referencia');//'X';
                reqClientX.TELEFONO_FIJO = mapAccount.get('telefonoFijo');//'X';
                reqClientX.TELEFONO_MOVIL = mapAccount.get('telefonoMovil');//'X';
                reqClientX.EMAIL = mapAccount.get('email');//'X';
                reqClientX.LUGAR_NACIMIENTO = '';
                reqClientX.FECHA_NACIMIENTO = '';
                reqClientX.ESTADO_CIVIL = '';
                reqClientX.APELLIDOS = '';
                reqClientX.NACIONALIDAD = '';
            }

            List<Tabla_maestra__c> lstTablaMaestra = [Select CEN_Codigo_departamento__c, CEN_Codigo_provincia__c, CEN_Codigo_distrito__c
                                                      From Tabla_maestra__c Where Id = :idTablaMaestra];
            if (!Test.isRunningTest()) {
                if(lstTablaMaestra.size() < 1){throw new ModifyClientException('El cliente no cuenta con Distrito');}
            }

            reqClient.DISTRITO = String.isEmpty(mapAccount.get('distrito')) ? '' : lstTablaMaestra[0].CEN_Codigo_distrito__c;
            reqClient.PROVINCIA = String.isEmpty(mapAccount.get('provincia')) ? '' : lstTablaMaestra[0].CEN_Codigo_provincia__c;
            reqClient.DEPARTAMENTO = String.isEmpty(mapAccount.get('departamento')) ? '' : lstTablaMaestra[0].CEN_Codigo_departamento__c;

            reqClientX.DISTRITO = mapAccount.get('distrito'); //'X';
            reqClientX.PROVINCIA = mapAccount.get('provincia'); // 'X';
            reqClientX.DEPARTAMENTO = mapAccount.get('departamento'); //'X';

            reqModClient.IS_MODIF_DATOS_CLIENTE = reqClient;
            reqModClient.IS_MODIF_DATOS_CLIENTEX = reqClientX;
            reqModClient.I_CLIENTE = documentNumber;

            reqModClient.I_SOCIEDAD = sociedad;
            req.ZRFC_OTC_MODIF_DATOS_CLIENTE = reqModClient;

            resp = callModifyClientApi(req);
            System.debug('req:' + req);
        } catch (Exception ex) {
            System.debug('modifyClientById-msgError: ' + ex.getMessage());
            resp = new CEN_ModifyClientObjectResponse();
            CEN_ModifyClientObjectResponse.BAPIRET2_T respError = new CEN_ModifyClientObjectResponse.BAPIRET2_T();
            List<CEN_ModifyClientObjectResponse.BAPIRET2> respErrorList = new List<CEN_ModifyClientObjectResponse.BAPIRET2>();
            CEN_ModifyClientObjectResponse.BAPIRET2 respErrorDetails = new CEN_ModifyClientObjectResponse.BAPIRET2();
            respErrorDetails.TYPE_x ='dataErrorCatch';
            //respErrorDetails.MESSAGE = ex.getMessage()+', en la linea: '+ex.getLineNumber();
            respErrorDetails.MESSAGE = ex.getMessage();
            respErrorList.add(respErrorDetails);
            respError.item = respErrorList;
            resp.ET_RETURN = respError;
        }
        return resp;
    }

    private static CEN_ModifyClientObjectResponse callModifyClientApi(
        CEN_ModifyClientObjectRequest reqProcess
    ) {
        system.debug('IN CEN_ModifyClientObjectResponse');
        String customReqBody;
        CEN_ModifyClientObjectResponse resp = new CEN_ModifyClientObjectResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_OTC_MODIF_DATOS_CLIENTE',
            'urn:ZRFC_OTC_MODIF_DATOS_CLIENTE'
        );
        try {
            System.debug('customReqBody: ' + customReqBody);

            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_ModificarCliente');
            Dom.Document docReq = new Dom.Document();
            System.debug('customReqBody: ' + customReqBody);
            String setReq = customReq.replace('myBody', customReqBody);
            setReq = setReq.replace('&', '&amp;');
            System.debug('CEN_ModificarCliente-setReq: ' + setReq);
            docReq.load(setReq);

            callApi.setRequestBody(docReq);

            resp = (CEN_ModifyClientObjectResponse) callApi.makeCallout().getParsedResponse();
            System.debug('CEN_ModificarCliente-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('CEN_ModificarCliente-Error: ' + ex.getMessage() + '-' + ex.getLineNumber());
        }
        return resp;
    }

    public class ModifyClientException extends Exception {
    }

}