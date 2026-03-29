/********************************************************************************
* @author: Jhanluck Onofre (jonofres@nttdata.com)
* @date: 2024-08-16
* @description: Clase apex usada en un flow para llamar a la clase CEN_GenerarDocumentos.
* 
* VERSION		DATE			AUTOR					ACTION
* 0.1			2024-08-16		Jhanluck Onofre		Creación
********************************************************************************/
public class CEN_InvocableGenerarDocumentos {

    public class Request {

        @InvocableVariable(required=true)
        public String idIteracion;

        @InvocableVariable(required=true)
        public String proforma;

        @InvocableVariable(required=true)
        public String tipoProceso;
    }

    public class Response {
        @InvocableVariable
        @AuraEnabled
        public String fechaCarga;

        @InvocableVariable
        @AuraEnabled
        public String horaCarga;

        @InvocableVariable
        @AuraEnabled
        public String codigoRespuesta;

        @InvocableVariable
        @AuraEnabled
        public String mensajeRespuesta;

        @InvocableVariable
        @AuraEnabled
        public String urlDocumento;

        @InvocableVariable
        @AuraEnabled
        public String idLog;
    }

    @InvocableMethod(label='Generar Documentos' description='Genera documentos llamando al servicio SAP y devuelve fecha y hora de carga, junto con el código y mensaje de respuesta.')
    public static List<Response> generateDocuments(List<Request> requestList) {
        CEN_GenerarDocumentos   documentos  =   callApiDocuments(requestList);
        List<Response> respuestaList        =   new List<Response>();
        Response respuesta                  =   new Response();
        for(CEN_GenerarDocumentos.Mensaje mensaje : documentos.mensaje){
                respuesta.codigoRespuesta   =   mensaje.type;
                respuesta.mensajeRespuesta  =   mensaje.message;
        }
        respuesta.fechaCarga                =   documentos.fechaCarga;
        respuesta.horaCarga                 =   documentos.horaCarga;
        respuesta.urlDocumento              =   Label.CEN_UrlOnbaseDocumentos + requestList[0].idIteracion + '_00000' + requestList[0].proforma; 
        respuestaList.add(respuesta);           
        return respuestaList;
    }

    public static CEN_GenerarDocumentos callApiDocuments(List<Request> requestList){
        Map<String, String> params = new Map<String, String>();
        params.put('tipoProceso',   requestList[0].tipoProceso);
        params.put('idIteracion',   requestList[0].idIteracion);
        params.put('proforma',      requestList[0].proforma);
        String requestBody = JSON.serialize(params);
        String resp;
        CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_DocumentosPrepagoResolucion');
        callApi.setRequestBody(requestBody);
        callApi.setTimeout(120000);
        if(!Test.isRunningTest()){
            resp    =   (String) callApi.makeCallout().getParsedResponse();
        }else{
            resp    =   '{"fechaCarga":"2024-08-29","horaCarga":"15:20:29","documento1":"X","documento2":"X","claveUnica":"240234017_0000059688","mensaje":[{"type":"S","id":"ZAC_SF","number":0,"message":"Proceso realizado exitosamente.","logNo":"","logMsgNo":0,"messageV1":"","messageV2":"","messageV3":"","messageV4":"","parameter":"","row":0,"field":"","system":"Q01CLNT100"}]}';
        }
        System.debug('resp: '+resp);
        CEN_GenerarDocumentos documentos;
        documentos  = CEN_GenerarDocumentos.parse(resp);
        return documentos;
    }
}