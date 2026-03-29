/********************************************************************* 
* @author: Alfredo Morote (amorotet@nttdata.com) 
* @date: 29-10-2025
* @description: Servicio para obtener datos de Objetos de Alquiler
* 
* VERSION      DATE                 AUTOR                     ACTION 
* 0.1          29-10-2025           Alfredo Morote            Creación 
*  
*********************************************************************/
public with sharing class OFI_ObjetoAlquilerService_cls{

    /**
     * @description Realiza llamado al servicio de objetos de alquiler, devuelve DTO parseado y procesa en Salesforce
     * @param request Objeto con los parámetros de la solicitud
     * @return OFI_ObjetoAlquilerObjectResponse_cls Respuesta parseada del servicio
     */
    public static List<OFI_ObjetoAlquilerObjectResponse_cls> getObjetosAlquiler(String fecha) {
        OFI_ObjetoAlquilerObjectRequest_cls req = new OFI_ObjetoAlquilerObjectRequest_cls(fecha);


        List<OFI_ObjetoAlquilerObjectResponse_cls> resp = new List<OFI_ObjetoAlquilerObjectResponse_cls>();
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('OFI_ObjetoAlquilerService');
            callApi.setRequestBody(req);

            if (!Test.isRunningTest()) callApi.setTimeout(60000);
            resp = (List<OFI_ObjetoAlquilerObjectResponse_cls>) callApi.makeCallout().getParsedResponse();

            if (resp == null || resp.isEmpty()) {
                return resp;
            }

            Database.executeBatch(
                new OFI_ObjetoAlquilerBatch_cls(resp),
                100
            );
            

        } catch (Exception ex) {
            System.debug('Error servicio ObjAlquiler: ' + ex.getMessage());
            throw ex;
        }

        return resp;
    }
}