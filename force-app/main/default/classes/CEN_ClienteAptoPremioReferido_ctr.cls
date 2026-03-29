/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 11-20-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   10-09-2024   @nttdata.com      Initial Version
 * 1.1   19-12-2024   Felipe Bermudez   se agrego un or que valide si el campo viene vacio linea 64/19/72/77
**/
public with sharing class CEN_ClienteAptoPremioReferido_ctr {

    public static Map<String,Object> ActualizarDatosReferidoCaso(String documentoReferido, String documentoReferente, DateTime fechaDeCreacion) {
        CEN_ReferidoRequest mapReq = new CEN_ReferidoRequest();
        Map<String,Object> mapResp;
        try{
            Date fechaLanding =   fechaDeCreacion.date();
            Time horaLanding  =   fechaDeCreacion.time();
            /** Descomentar Solo Pruebas */
            mapReq.referido         =   documentoReferido;
            mapReq.referente        =   documentoReferente;
            mapReq.fecha_landing    =   fechaLanding.year() +'-'+   String.valueOf(fechaLanding.month()).leftPad(2, '0')    +'-'+   String.valueOf(fechaLanding.day()).leftPad(2, '0');
            mapReq.hora_landing     =   String.valueOf(horaLanding.hour()).leftPad(2, '0')  +':'+   String.valueOf(horaLanding.minute()).leftPad(2, '0')    +':'+   String.valueOf(horaLanding.second()).leftPad(2, '0');

            /** Comentar Solo Pruebas */
            //mapReq.referido = '80000008';
            //mapReq.referente = '80000007';

            mapResp = CEN_ClienteAptoPremioReferido_cls.ClienteAptoPremioReferido(mapReq);
        } catch (Exception ex) {
            mapResp = new Map<String,Object>();
            mapResp.put('data',ex.getMessage() + ':' + ex.getMessage());
        }
        System.debug('mapResp: ' + mapResp);
        return mapResp;
    }

    /*@future(callout=true)
    public static void ActualizarDatosReferidoCasoAsync(String documentoReferido, String documentoReferente) {
        Map<String, Object> mapResp = ActualizarDatosReferidoCaso(documentoReferido, documentoReferente);
    }*/

    @AuraEnabled(cacheable=false)
    public static CEN_ReferidoResponse ActualizarDatosReferidoCasoLWC(String recordId) {
        List<Case> lstCase = [SELECT Id,Account__r.CEN_N_mero_de_documento__pc,Account__r.CEN_Numero_de_documento_del__c,N_mero_de_documento__c, CreatedDate FROM Case WHERE Id =: recordId];
        String documentoReferente = String.isBlank(lstCase[0].Account__r.CEN_N_mero_de_documento__pc) ? lstCase[0].Account__r.CEN_Numero_de_documento_del__c : lstCase[0].Account__r.CEN_N_mero_de_documento__pc ;
        String documentoReferido = lstCase[0].N_mero_de_documento__c;
        Map<String,Object> data = ActualizarDatosReferidoCaso(documentoReferido,documentoReferente, lstCase[0].CreatedDate);
        System.debug('data: ' + data);
        CEN_ReferidoResponse respData;
        try{
            respData = (CEN_ReferidoResponse)data.get('data');
            if(respData.data != null && respData.data.size() > 0){
                List<Case> listaCaso = new List<Case>();
                for(CEN_ReferidoResponse.Data resp : respData.data){
                    System.debug('Entra FOR: ' + resp);
                    Case caso = new Case();
                    //resp.referente;
                    //resp.referido;
                    //resp.aprobado;
                    //resp.estado;
                    caso.Id = recordId;
                    caso.CEN_FechaCierreVentaReferente__c   = resp.fecCventaEnte == '0000-00-00' || resp.fecCventaEnte =='' ? null : Date.valueOf(resp.fecCventaEnte);
                    caso.CEN_PrecioVentaReferente__c        = resp.precioVentaEnte;
                    caso.CEN_SubzonaReferente__c            = resp.ciudadEnte;
                    caso.CEN_NumFinanciamientoReferente__c  = resp.proformaEnte;
                    caso.CEN_DeudaReferente__c              = resp.deudaEnte;
                    caso.CEN_FechaCierreArrasReferente__c   = resp.fechaArrasEnte == '0000-00-00' || resp.fechaArrasEnte=='' ? null : Date.valueOf(resp.fechaArrasEnte);
                    caso.CEN_AptoPremiacion__c              = resp.aprobado == 'X' ? true : false;
                    caso.CEN_ObservacionReferente__c        = resp.observacionEnte;
                    caso.CEN_FechaCierreVentaReferido__c    = resp.fecCventaIdo == '0000-00-00' || resp.fecCventaIdo =='' ? null : Date.valueOf(resp.fecCventaIdo);
                    caso.CEN_PrecioVentaReferido__c         = resp.precioVentaIdo;
                    caso.CEN_SubzonaReferido__c             = resp.ciudadIdo;
                    caso.CEN_NumFinanciamientoReferido__c   = resp.proformaIdo;
                    caso.CEN_FechaCierreArrasReferido__c    = resp.fechaArrasIdo == '0000-00-00' || resp.fechaArrasIdo=='' ? null : Date.valueOf(resp.fechaArrasIdo);
                    caso.CEN_ObservacionReferido__c         = resp.observacionIdo;
                    //resp.observacionIdo;
                    listaCaso.add(caso);
                }

                if(listaCaso.size()>0){
                    update listaCaso;
                }

                System.debug('listaCaso: '+ listaCaso);
            }else{
                //PINTAR ERROR DE EXCEPCION
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ':' + ex.getMessage());
        }

        System.debug('respData: '+ respData);
        return respData;
    }

}