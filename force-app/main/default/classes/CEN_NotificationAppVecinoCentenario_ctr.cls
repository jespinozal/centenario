/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 13-11-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-11-2023  @nttdata.com  Initial Version
**/
public with sharing class CEN_NotificationAppVecinoCentenario_ctr {
    public static Map<String, Object> notificationAppVecinoCentenario (String caseNumber, String estado, String subject, String origen, String tipoDocumento,String numeroDocumento) {
        CEN_NotificationAppVecinoCentRequest mapReq = new CEN_NotificationAppVecinoCentRequest();
        Map<String, Object> mapResp = new Map<String, Object>();
        CEN_NotificationAppVecinoCentRequest mapResult = new CEN_NotificationAppVecinoCentRequest();

        try{

            mapReq.case_number=caseNumber;
            mapReq.estado=estado;
            mapReq.origen=origen;
            mapReq.subject=subject;
            mapReq.tipo_documento=tipoDocumento;
            mapReq.numero_documento=numeroDocumento;

            mapResult = validarFiltros(mapReq);
            mapResp = CEN_NotificationAppVecinoCentenario_cls.notificationAppVecinoCentenario(mapResult);
            System.debug('mapResp: ' + mapResp);

        }catch (Exception ex){
            mapResp.put('error', ex.getMessage());

        } 
        return mapResp;
    }

    private static CEN_NotificationAppVecinoCentRequest validarFiltros(CEN_NotificationAppVecinoCentRequest mapData) {
        CEN_NotificationAppVecinoCentRequest mapResult = new CEN_NotificationAppVecinoCentRequest();
        Set <String> dataSet = new Set<String>();
        return mapData;
    }

    @future(callout=true)
    public static void notificationAppVecinoCentenarioAsinc(String caseNumber, String estado, String subject, String origen, String tipoDocumento,String numeroDocumento) {
        Map<String, Object> mapResp = notificationAppVecinoCentenario(caseNumber, estado, subject, origen,tipoDocumento,numeroDocumento);
    }

    @InvocableMethod(label='notificacionInteraccionAppVecino')
    public static List<String> notificacionInteraccionAppVecino(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].caseNumber!=null){
            for(Integer i=0; i < parameters.size(); i++){
                if(i==0){
                    notificationAppVecinoCentenarioAsinc(parameters[0].caseNumber, parameters[0].estado,parameters[0].subject, parameters[0].origen, parameters[0].tipoDocumento,parameters[0].numeDocumento);
                    resp.add(parameters[0].caseNumber+'notificado');
                }else{
                    resp.add(parameters[0].caseNumber+'noNotificado');
                }
            }
        }else{
            resp.add('vacio');
        }
        return resp;
    }

    public class FlowParameters {
        @InvocableVariable(label='caseNumber' description='Id de la interacción' required=true)
        public String caseNumber;
        @InvocableVariable(label='estado' description='Estado de la interacción' required=true)
        public String estado;
        @InvocableVariable(label='subject' description='Asunto de la interacción' required=true)
        public String subject;
        @InvocableVariable(label='origen' description='Origen de la interacción' required=true)
        public String origen;
        @InvocableVariable(label='tipoDocumento' description='Tipo de documento DNI, RUC' required=false)
        public String tipoDocumento;
        @InvocableVariable(label='numeroDocumento' description='Numero de documento' required=true)
        public String numeDocumento;

    }

    public class NotificationAppVecinoCentenarioException extends Exception {

    }

}