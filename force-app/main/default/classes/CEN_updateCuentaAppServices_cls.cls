/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 14-08-2024
 * @last modified by  : Diego Bravo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   14-08-2024   @nttdata.com  Initial Version
**/
@RestResource(urlMapping='/updateCuentaApp/*')
global with sharing class CEN_updateCuentaAppServices_cls {
    @HttpPatch
    global static String doPatch(){
        List<Response> myRespList = new List<Response>();
        try {
             String jsonString = RestContext.request.requestBody.toString();
             List<Request> myObjReq = (List<Request> )JSON.deserialize(jsonString,List<Request>.class);
             System.debug('Request Servicio: ' + myObjReq);
            if(myObjReq.size()>200){
                Response resp = new Response();
                resp.id = 'All';
                resp.estado = 'error';
                resp.mensaje = 'procesar máximo 200 registros';
                myRespList.add(resp);
            }else{
                List<Response> myRespValidate = validateData(myObjReq);
                if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
            }

        } catch (Exception ex) {
            Response resp = new Response();
            resp.id = 'all';
            resp.estado = 'error';
            resp.mensaje = ex.getMessage() + ', no se registraron los registros en SFDC';
            myRespList.add(resp);
        }
        String myResp = JSON.serialize(myRespList);

        return myResp;
    }

    private static List<Response> validateData (List<Request> myObjReq){
        List<Response> myResp = new List<Response>();
        List<Account> cuentaObjList = new List<Account>();
        List<String> accountList = new List<String>();
        Map<Integer, String> mapAccount = new Map<Integer, String>();

        for(Request obj : myObjReq){
            accountList.add(obj.numeroDocumentoReferente);
            System.debug('Cuenta: ' + obj.numeroDocumentoReferente);
        }

        System.debug('accountList: ' + accountList);

        List<Account> cuentaEntontrada = [SELECT Id, Name, CEN_Numero_de_documento_del__c,CEN_N_mero_de_documento__pc  FROM Account WHERE (CEN_Numero_de_documento_del__c IN: accountList OR CEN_N_mero_de_documento__pc IN: accountList) WITH USER_MODE LIMIT 1];

         System.debug('cuentaEntontrada: ' + cuentaEntontrada);

        for(Request obj : myObjReq){
            if(cuentaEntontrada.size()==0){throw new updateCuentaAppServicesException('El número de documento ' + obj.numeroDocumentoReferente + ' no existe en la base de datos de SFDC');}
            for (Account varAccount : cuentaEntontrada) {
                if (obj.numeroDocumentoReferente == varAccount.CEN_Numero_de_documento_del__c || obj.numeroDocumentoReferente == varAccount.CEN_N_mero_de_documento__pc) {
                    Account cuentaObj = new Account();
                    cuentaObj.id = varAccount.Id;
                    cuentaObj.CEN_CantidadLinksGeneradosApp__c = obj.cantidadLinks;
                    cuentaObjList.add(cuentaObj);

                    Response resp = new Response();
                    resp.id = cuentaObj.id;
                    resp.estado = 'successfully';
                    resp.mensaje = 'Se actualizo el cliente: ' + varAccount.Name;
                    myResp.add(resp);
                }
            }
        }
        
        System.debug('cuentaObjList: ' + cuentaObjList);
        updateReferidos(cuentaEntontrada, myObjReq);
        Update cuentaObjList;
        return myResp;
    }

    public static void updateReferidos(List<Account> cuentaEntontrada, List<Request> myObjReq){

        List<CEN_detalleLinkReferidos__c> accountRefList = new List<CEN_detalleLinkReferidos__c>();
        String unixTime;
        Long unixTimeMilliseconds;
        DateTime gmtDatetime;
        Integer millisecondOffsetGmt;

        for (Request varObj : myObjReq) {
            for (Account varAccount : cuentaEntontrada) {
                if (varObj.numeroDocumentoReferente == varAccount.CEN_Numero_de_documento_del__c || 
                    varObj.numeroDocumentoReferente == varAccount.CEN_N_mero_de_documento__pc) {
                        for (Integer i = 0; i < varObj.referidos.size(); i++ ) {
                            CEN_detalleLinkReferidos__c accountRef = new CEN_detalleLinkReferidos__c();
                            accountRef.Account__c                   = varAccount.Id;
                            accountRef.Name                         = varObj.referidos[i].nombreReferido + ' ' + varObj.referidos[i].apellidoReferido;
                            accountRef.CEN_nombreReferido__c        = varObj.referidos[i].nombreReferido;
                            accountRef.CEN_apellidoReferido__c      = varObj.referidos[i].apellidoReferido;
                            accountRef.CEN_parentescoReferido__c    = varObj.referidos[i].parentescoReferido;

                            unixTime = varObj.referidos[i].fechaRegistro;
                            unixTimeMilliseconds = Long.valueOf(unixTime.rightPad(13, '0'));
                            gmtDatetime = DateTime.newInstance(unixTimeMilliseconds);
                            System.TimeZone myTz = UserInfo.getTimeZone();
                            millisecondOffsetGmt = myTz.getOffset(gmtDateTime);
                            accountRef.CEN_fechaRegistro__c  = DateTime.newInstance(unixTimeMilliseconds - millisecondOffsetGmt);                      

                            accountRef.CEN_url__c                   = varObj.referidos[i].URL;

                            unixTime = varObj.referidos[i].fechaVigenciaURL;
                            unixTimeMilliseconds = Long.valueOf(unixTime.rightPad(13, '0'));
                            gmtDatetime = DateTime.newInstance(unixTimeMilliseconds);
                            millisecondOffsetGmt = myTz.getOffset(gmtDateTime);
                            accountRef.CEN_fechaVigenciaUrl__c      = Datetime.newInstance(unixTimeMilliseconds - millisecondOffsetGmt);

                            accountRefList.add(accountRef);
                        }
                }
            }
        }

        Insert accountRefList;
        

    }

    public class Request{
        public String numeroDocumentoReferente;
        public Integer cantidadLinks;
        public List<Referido> referidos;
    }

    public class Referido{
        public String nombreReferido;
        public String apellidoReferido;
        public String parentescoReferido;
        public String fechaRegistro;
        public String URL;
        public String fechaVigenciaURL; 
    }

    public class Response {
        public String id;
        public String estado;
        public String mensaje; 
    }

    public class updateCuentaAppServicesException extends Exception {}
}