/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 29-01-2025
 * @last modified by   : Luis Maldonado
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   29-01-2025   Luis Maldonado   Initial Version
**/
public with sharing class CEN_parambuscadorGoogleMap_cls {

    private final Account acct;
    public List<Account> Cuenta;
    Map<String, String> mapaCampos;
    public List<String> listaDeErrores{get;set;}
    public Boolean MsgError {get;set;}
    public Boolean MsgMapaOk {get;set;}
    public final String RT_PersonAccount='PersonAccount';
    public final String RT_Cuenta_Empresa='Cuenta_Empresa';

    public CEN_parambuscadorGoogleMap_cls(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        Cuenta = [SELECT id,Name,LastName,FirstName,CEN_Tipo_de_documento__pc,CEN_N_mero_de_documento__pc,CEN_Sexo__pc,CEN_Nacionalidad__pc,CEN_Distrito__pc,CEN_Distrito__pr.Name,
                    CEN_Distrito__pr.Provincia__c,CEN_Distrito__pr.Departamento__c,CEN_Tipo_Via__c,CEN_Direccion__pc,CEN_Referencia_direccion__c,CEN_Situacion_vivienda__c,PersonEmail,
                    CEN_Tiempo_de_Residencia__c,CEN_Estado_civil__pc,CEN_Tel_fono_Trabajo__pc,PersonMobilePhone, RecordType.DeveloperName,CEN_Tipo_de_documento__c,CEN_Numero_de_documento_del__c,
                    CEN_fld_Nombres_Apoderado__c, CEN_fld_Apellidos_apoderado__c, CEN_fld_Apellido_mat_apoderado__c, CEN_fld_Tipo_de_documento_de_apoderado__c, CEN_fld_Numero_de_documento_apoderado__c, CEN_fld_Numero_de_partida_registral__c,
                    CEN_fld_Zona_Registral__c, CEN_Distrito__r.Name, CEN_fld_Nacionalidad_apoderado__c, CEN_Direcci_n__c, CEN_fld_Correo_empresa__c, CEN_Numero_Tiempo_Residencia__c,Phone,
                    CEN_fld_Direccion_apoderado__c, CEN_Telefono_Trabajo_Empresa__c
                  FROM Account
                  WHERE id = :acct.Id];
        if (Cuenta.size()>0 && generarMapaDeCampos(Cuenta)) {
            MsgError=false;
            MsgMapaOk=true;
        } else {
            MsgError=true;
            MsgMapaOk=false;
        }
    }

    public PageReference guardarDireccion(){
        PageReference pr;
        try {
                update acct;
                pr = new PageReference('/'+acct.Id );
        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'No se pudo actualizar: ' +
                e.getMessage() +
                '. Type: ' +
                e.getTypeName() +
                '. Line: ' +
                e.getLineNumber()
            );
        }
        return pr;
    }

    public Boolean generarMapaDeCampos(List<Account> Cuenta){

        mapaCampos = new Map<String, String>();
        listaDeErrores = new List<String>();
        Boolean camposLlenos = true;

        if (Cuenta[0].RecordType.DeveloperName==RT_PersonAccount) {
            mapaCampos.put('Nombre',String.isBlank(cuenta[0].Name)?'vacio':cuenta[0].Name);
            mapaCampos.put('Apellidos',String.isBlank(cuenta[0].LastName)?'vacio':cuenta[0].LastName);
            mapaCampos.put('Primer Nombre',String.isBlank(cuenta[0].FirstName)?'vacio':cuenta[0].FirstName);
            mapaCampos.put('Número de Documento',String.isBlank(cuenta[0].CEN_N_mero_de_documento__pc)?'vacio':cuenta[0].CEN_N_mero_de_documento__pc);
            mapaCampos.put('Sexo',String.isBlank(cuenta[0].CEN_Sexo__pc)?'vacio':cuenta[0].CEN_Sexo__pc);
            mapaCampos.put('Nacionalidad',String.isBlank(cuenta[0].CEN_Nacionalidad__pc)?'vacio':cuenta[0].CEN_Nacionalidad__pc);
            mapaCampos.put('Distrito',String.isBlank(cuenta[0].CEN_Distrito__pr.Name)?'vacio':cuenta[0].CEN_Distrito__pr.Name);
            mapaCampos.put('Tipo via',String.isBlank(cuenta[0].CEN_Tipo_Via__c)?'vacio':cuenta[0].CEN_Tipo_Via__c);
            mapaCampos.put('Referencia dirección',String.isBlank(cuenta[0].CEN_Referencia_direccion__c)?'vacio':cuenta[0].CEN_Referencia_direccion__c);
            mapaCampos.put('Situación vivienda',String.isBlank(cuenta[0].CEN_Situacion_vivienda__c)?'vacio':cuenta[0].CEN_Situacion_vivienda__c);
            mapaCampos.put('Email personal',String.isBlank(cuenta[0].PersonEmail)?'vacio':cuenta[0].PersonEmail);
            mapaCampos.put('Numero Tiempo Residencia',cuenta[0].CEN_Numero_Tiempo_Residencia__c == null ? 'vacio':String.valueOf(cuenta[0].CEN_Numero_Tiempo_Residencia__c));
            mapaCampos.put('Tiempo de residencia',String.isBlank(cuenta[0].CEN_Tiempo_de_Residencia__c)?'vacio':cuenta[0].CEN_Tiempo_de_Residencia__c);
            mapaCampos.put('Estado civil',String.isBlank(cuenta[0].CEN_Estado_civil__pc)?'vacio':cuenta[0].CEN_Estado_civil__pc);
            mapaCampos.put('Telefono',String.isBlank(cuenta[0].Phone)?'vacio':cuenta[0].Phone);
            mapaCampos.put('Celular',String.isBlank(cuenta[0].PersonMobilePhone)?'vacio':cuenta[0].PersonMobilePhone);
            // mapaCampos.put('Direccion',String.isBlank(cuenta[0].CEN_Direccion__pc)?'vacio':cuenta[0].CEN_Direccion__pc);
        } else if (Cuenta[0].RecordType.DeveloperName==RT_Cuenta_Empresa) {
            mapaCampos.put('Tipo Documento',String.isBlank(cuenta[0].CEN_Tipo_de_documento__c)?'vacio':cuenta[0].CEN_Tipo_de_documento__c);
            mapaCampos.put('Número Documento',String.isBlank(cuenta[0].CEN_Numero_de_documento_del__c)?'vacio':cuenta[0].CEN_Numero_de_documento_del__c);
            mapaCampos.put('Nombre Apoderado',String.isBlank(cuenta[0].CEN_fld_Nombres_Apoderado__c)?'vacio':cuenta[0].CEN_fld_Nombres_Apoderado__c);
            mapaCampos.put('Apellido Apoderado',String.isBlank(cuenta[0].CEN_fld_Apellidos_apoderado__c) && String.isBlank(cuenta[0].CEN_fld_Apellido_mat_apoderado__c) ? 'vacio' : ((String.isBlank(cuenta[0].CEN_fld_Apellidos_apoderado__c) ? '' : cuenta[0].CEN_fld_Apellidos_apoderado__c) + ' ' + (String.isBlank(cuenta[0].CEN_fld_Apellido_mat_apoderado__c) ? '' : cuenta[0].CEN_fld_Apellido_mat_apoderado__c)).trim());
            mapaCampos.put('Tipo Documento Apoderado',String.isBlank(cuenta[0].CEN_fld_Tipo_de_documento_de_apoderado__c)?'vacio':cuenta[0].CEN_fld_Tipo_de_documento_de_apoderado__c);
            mapaCampos.put('Numero Documento Apoderado',String.isBlank(cuenta[0].CEN_fld_Numero_de_documento_apoderado__c)?'vacio':cuenta[0].CEN_fld_Numero_de_documento_apoderado__c);
            mapaCampos.put('Numero Partida Registral',String.isBlank(cuenta[0].CEN_fld_Numero_de_partida_registral__c)?'vacio':cuenta[0].CEN_fld_Numero_de_partida_registral__c);
            mapaCampos.put('Zona Registral',String.isBlank(cuenta[0].CEN_fld_Zona_Registral__c)?'vacio':cuenta[0].CEN_fld_Zona_Registral__c);
            mapaCampos.put('Distrito',String.isBlank(cuenta[0].CEN_Distrito__r.Name)?'vacio':cuenta[0].CEN_Distrito__r.Name);
            mapaCampos.put('Nacionalidad Apoderado',String.isBlank(cuenta[0].CEN_fld_Nacionalidad_apoderado__c)?'vacio':cuenta[0].CEN_fld_Nacionalidad_apoderado__c);
            mapaCampos.put('Tipo Via',String.isBlank(cuenta[0].CEN_Tipo_Via__c)?'vacio':cuenta[0].CEN_Tipo_Via__c);
            // mapaCampos.put('Domicilio Apoderado',String.isBlank(cuenta[0].CEN_fld_Direccion_apoderado__c)?'vacio':cuenta[0].CEN_fld_Direccion_apoderado__c);
            mapaCampos.put('Referencia Direccion',String.isBlank(cuenta[0].CEN_Referencia_direccion__c)?'vacio':cuenta[0].CEN_Referencia_direccion__c);
            mapaCampos.put('Situacion Vivienda',String.isBlank(cuenta[0].CEN_Situacion_vivienda__c)?'vacio':cuenta[0].CEN_Situacion_vivienda__c);
            mapaCampos.put('Correo Empresa',String.isBlank(cuenta[0].CEN_fld_Correo_empresa__c)?'vacio':cuenta[0].CEN_fld_Correo_empresa__c);
            mapaCampos.put('Numero Tiempo Residencia',cuenta[0].CEN_Numero_Tiempo_Residencia__c == null ? 'vacio': String.valueOf(cuenta[0].CEN_Numero_Tiempo_Residencia__c));
            mapaCampos.put('Tiempo Residencia',String.isBlank(cuenta[0].CEN_Tiempo_de_Residencia__c)?'vacio':cuenta[0].CEN_Tiempo_de_Residencia__c);
            mapaCampos.put('Telefono Trabajo',String.isBlank(cuenta[0].CEN_Telefono_Trabajo_Empresa__c)?'vacio':cuenta[0].CEN_Telefono_Trabajo_Empresa__c);
            mapaCampos.put('Celular',String.isBlank(cuenta[0].Phone)?'vacio':cuenta[0].Phone);
        } else {
            mapaCampos.put('Tipo de record type no reconocido','vacio');
        }

        for(String key: mapaCampos.keySet()){
            if (mapaCampos.get(key)=='vacio') {
                camposLlenos=false;
                listaDeErrores.add(key);
            }
        }
        return camposLlenos;
    }

}