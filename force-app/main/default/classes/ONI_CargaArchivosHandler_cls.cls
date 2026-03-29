/********************************************************************* 
* @author: Alfredo Morote (amorotet@nttdata.com) 
* @date: 10-12-2025
* @description: Trigger Handler para la validación de carga de archivos en registros de Evaluación 
* 
* VERSION      DATE                 AUTOR                     ACTION 
* 0.1          10-12-2025           Alfredo Morote            Creación 
*  
*********************************************************************/
public with sharing class ONI_CargaArchivosHandler_cls {
    public static final Set<String> TIPO_ARCHIVOS = new Set<String>{'pdf', 'jpg', 'jpeg', 'png'};
    public static final String PREFIJO_EVALUACION = OFI_obj_Evaluacion__c.SObjectType.getDescribe().getKeyPrefix();

    public ONI_CargaArchivosHandler_cls() {}

    public static void validaTipoArchivo(List<ContentVersion> newVersions) {

        for(ContentVersion cv: newVersions) {
            if (cv.FirstPublishLocationId == null) {
                continue;
            }
            String prefijoRegEval = String.valueOf(cv.FirstPublishLocationId).substring(0,3);

            if(prefijoRegEval == PREFIJO_EVALUACION && cv.PathOnClient != null) {
                String extArchivo = cv.PathOnClient.substringAfterLast('.').toLowerCase();

                if(!TIPO_ARCHIVOS.contains(extArchivo)) {
                    cv.addError('El tipo de archivo no es válido. Solo se permiten archivos con las siguientes extensiones: pdf, jpg, jpeg, png.');
                }
            }
        }
    } 
}