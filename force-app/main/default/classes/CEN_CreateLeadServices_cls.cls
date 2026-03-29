/**
 * @name               : CEN_CreateLeadServices_cls
 * @author             : Joel Espinoza
 * @creation date      : 08-10-2024
 * @modification date  : 08-10-2024
 * @last modified by   : Richard Villafana - NTT DATA
 * @description        : Servicio para la creación de Lead con mensaje personalizado
 * @versions           : version 1.0: clase apex inicial
 * @test class         : CEN_Referidos_tst
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-10-2024   Joel Espinoza   Initial Version
**/

@RestResource(urlMapping='/createLead/*')
global class CEN_CreateLeadServices_cls {

    @HttpPost
    global static List<ResponseWrap> doPost() {
        List<ResponseWrap> listResp     =   new List<ResponseWrap>();
        String jsonString               =   RestContext.request.requestBody.toString();
        List<Lead> prospectos           =   (List<Lead> )JSON.deserialize(jsonString,List<Lead>.class);
        //Reglas de asignación de leads por default
        Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
        //Obtener los documentos de los leads
        List<String> listaDocumentos    =   new List<String>();
        for(Lead l : prospectos){
            l.OwnerId           =   UserInfo.getUserId();
            listaDocumentos.add(l.CEN_N_mero_de_documento__c);
            l.setOptions(dmo);
        }
        //Inserción de los leads
        List <Database.SaveResult> saveResults = Database.insert(prospectos, false);
        //Obtener los ids registrados
        List<String> idLeadRegistrados = new List<String>();
        for(Database.SaveResult sr : saveResults){
            idLeadRegistrados.add(sr.getId());
        }
        //Obtener los leads por documentos y por ids insertados
        //Mapa Key= Nro de documento, Valor Lead
        Map<String, Lead>   mapaLeadPorDocumento  =     getLeadPorDocumento(listaDocumentos);
        //Mapa Key = Id de Lead, Lead
        Map<Id, Lead>       mapaLeadPorId         =     getLeadPorId(idLeadRegistrados);

        Integer i = 0;
        //Recorrer los resultados de la inserción
        for(Database.SaveResult sr : saveResults){
            //Variable de Respuesta por cada Lead insertado o intento de inserción
            ResponseWrap resp = new ResponseWrap();
            Id idLead = sr.getId();
            //Se realizó la inserción correctamente.
            if(sr.isSuccess()){
                resp.message = 'Se registro prospecto con éxito';
                //Si el prospecto es referido
                if(prospectos[i].CEN_Referido__c){
                    //Validar que el lead está en la bd y es nuevo
                    if(mapaLeadPorId.get(idLead) != null){
                        //Si el estado es "Con referente Aplica y reintentos es 0
                        if(mapaLeadPorId.get(idLead).CEN_EstadoReferente__c ==  'Con Referente Aplica' && mapaLeadPorId.get(idLead).CEN_NumberRetries__c    == 0){
                            resp.message = 'Se registro prospecto con éxito para el programa de referidos.';
                            System.debug('1. Se registro prospecto con éxito para el programa de referidos.');
                        }
                        //Si el Lead insertado es No Valido, se registrará el lead pero será no válido.
                        else if(mapaLeadPorId.get(idLead).CEN_EstadoValidacionReferido__c ==  'No válido'){
                            resp.message = 'Se registro prospecto, referido no aplica para el programa.';
                            System.debug('3. Se registro prospecto, referido no aplica para el programa.');
                        }
                    }
                    //El Lead fue eliminado de la base de datos por insertar el mismo lead dentro de 24 horas.
                    else{
                        resp.message = 'Prospecto ya fue registrado hace unos instantes, por favor intente más tarde.';
                        System.debug('2. Prospecto ya fue registrado hace unos instantes, por favor intente más tarde.');
                    }

                    /*System.debug('leadList: '+leadList);
                    Decimal reintentos = leadList[0].CEN_NumberRetries__c;

                    if(leadList[0].CEN_EstadoReferente__c == 'Con Referente Aplica' && reintentos == 0){
                        resp.message = 'Se registro prospecto con éxito para el programa de referidos.';
                        System.debug('1. Se registro prospecto con éxito para el programa de referidos.');
                    }else if(reintentos > 0){
                        resp.message = 'Prospecto ya fue registrado hace unos instantes, por favor intente más tarde.';
                        System.debug('2. Prospecto ya fue registrado hace unos instantes, por favor intente más tarde.');

                    }else if(leadList[0].CEN_EstadoValidacionReferido__c == 'No válido'){
                        resp.message = 'Se registro prospecto, referido no aplica para el programa.';
                        System.debug('3. Se registro prospecto, referido no aplica para el programa.');

                    }else {
                        resp.message = 'Se registro prospecto, referido no aplica para el programa.';
                        System.debug('4. Se registro prospecto, referido no aplica para el programa.');

                    }*/
                }

                resp.row = i + 1;
                resp.id = idLead;
                resp.errors = null;
                listResp.add(resp);
            }else{
                resp.row = i + 1;
                resp.id = idLead;
                List<String> listaErrores = new List<String>();
                for(Database.Error error : sr.getErrors())
                {
                    listaErrores.add(error.getStatusCode() + ' - ' + error.getMessage());
                }
                resp.errors = listaErrores;
                resp.message = 'Error al registrar';
                listResp.add(resp);
            }
            i++;
        }

            return listResp;
        // } catch (Exception ex) {
        //     ResponseWrap resp = new ResponseWrap();
        //     resp.row = null;
        //     resp.id = null;
        //     resp.message = 'Error: Comunicarse con el equipo de Salesforce: ' + ex.getMessage() + ' ' + ex.getLineNumber();
        //     resp.errors = null;
        //     listResp.add(resp);
        //     return listResp;
        // }
    }

    /*public static List<Lead> getLeadPorDocumento(String documentoReferido){
        return [SELECT Id,CEN_EstadoReferente__c,CEN_NumberRetries__c, CEN_EstadoValidacionReferido__c, FirstName FROM Lead WHERE (CEN_N_mero_de_documento__c =: documentoReferido) ORDER BY CreatedDate DESC];
    }*/
    /**
    * @description Consulta de Datos del registro insertado
    * @author Richard Villafana - NTT DATA | 10-16-2024 
    * @param idLead 
    * @return Map<Id, Lead> 
    **/
    public static Map<String, Lead> getLeadPorDocumento(List<String> listaDocumentos){
        Map<String, Lead> mLead = new Map<String, Lead>();
        //Fecha y hora actual menos 2 minutos para obtener el último actualizado en los últimos minutos.
        DateTime fechaHoraActual = System.now().addMinutes(-2);
        List<Lead> listaLead = [SELECT Id,CEN_EstadoReferente__c,CEN_NumberRetries__c, CEN_EstadoValidacionReferido__c, FirstName, CEN_N_mero_de_documento__c
                                                        FROM Lead 
                                                        WHERE CEN_N_mero_de_documento__c =: listaDocumentos 
                                                        AND LastModifiedDate >: fechaHoraActual
                                                        ORDER BY CreatedDate DESC];
        for(Lead l : listaLead){
            mLead.put(l.CEN_N_mero_de_documento__c, l);
        }
        return mLead;
    }
    /**
    * @description Consulta de Datos del registro insertado
    * @author Richard Villafana - NTT DATA | 10-16-2024 
    * @param idLead 
    * @return Map<Id, Lead> 
    **/
    public static Map<Id, Lead> getLeadPorId(List<String> idLeadRegistrados){
        Map<ID, Lead> mLead = new Map<ID, Lead>([SELECT Id,CEN_EstadoReferente__c,CEN_NumberRetries__c, CEN_EstadoValidacionReferido__c, FirstName 
                                                        FROM Lead 
                                                        WHERE Id =: idLeadRegistrados 
                                                        ORDER BY CreatedDate DESC]);
        return mLead;
    }

    global class ResponseWrap{
        Public Integer row { get; set; }
        Public String id { get; set; }
        Public String message { get; set; }
        Public List<String> errors { get; set; }
    }

}