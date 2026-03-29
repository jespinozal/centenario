/**
 * @description       Controlador de Apex para el LWC 'cen_adjuntararchivo_lwc'.
 * Su única responsabilidad es crear un registro personalizado 'CEN_AdjuntoRelacionado__c'
 * después de que un archivo ya ha sido subido a Salesforce a través del componente LWC estándar.
 * @author            Jose Miguel Espinoza Mestanza
 * @email             josemiguel.espinozamestanza@emeal.nttdata.com
 * @version           2.0
 */
public with sharing class CEN_AdjuntarArchivoController {

    /**
     * @description Método invocable desde LWC que crea el registro de relación personalizado.
     * @param caseId El ID del Caso al cual se asocia el archivo.
     * @param contentDocumentId El ID del ContentDocument (archivo) que ya fue subido.
     * @param tipoDeDocumento El valor del picklist seleccionado por el usuario.
     * @param fileName El nombre original del archivo subido.
     */
    @AuraEnabled
    public static void crearRegistroAdjunto(String caseId, String contentDocumentId, String tipoDeDocumento, String fileName) {
        // Se utiliza un bloque try-catch para manejar cualquier error durante la inserción del registro.
        try {
            // Se llama al método privado que contiene la lógica de creación.
            crearAdjuntoRelacionado(caseId, fileName, contentDocumentId, tipoDeDocumento);
        } catch (Exception e) {
            // Si ocurre un error, se registra en el debug y se lanza una AuraHandledException
            // para que el LWC pueda capturarla y mostrar un mensaje de error claro al usuario.
            System.debug('Error en crearRegistroAdjunto: ' + e.getMessage());
            throw new AuraHandledException('Error al crear el registro de adjunto: ' + e.getMessage());
        }
    }
    
    /**
     * @description Método privado que construye e inserta el registro 'CEN_AdjuntoRelacionado__c'.
     * @param caseId El ID del Caso.
     * @param archivo El nombre del archivo.
     * @param contentDocumentId El ID del ContentDocument.
     * @param tipoDeDocumento El tipo de documento seleccionado.
     */
    private static void crearAdjuntoRelacionado(String caseId, String archivo, String contentDocumentId, String tipoDeDocumento) {
        // La lógica interna de este método no necesita cambios.
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        
        CEN_AdjuntoRelacionado__c adjuntoRelacionado = new CEN_AdjuntoRelacionado__c();
        adjuntoRelacionado.Name = 'Link al Archivo'; // O puedes usar el nombre del archivo si prefieres.
        adjuntoRelacionado.CEN_NombreArchivo__c = archivo;
        adjuntoRelacionado.CEN_IdDocumento__c = contentDocumentId;
        adjuntoRelacionado.CEN_CaseID__c = caseId;
        adjuntoRelacionado.CEN_LinkDocumento__c = baseUrl + '/lightning/r/ContentDocument/' + contentDocumentId + '/view';
        adjuntoRelacionado.CEN_TipoDocumentoCaso__c = tipoDeDocumento;
        adjuntoRelacionado.CEN_TipoOrigen__c = 'File';
        
        insert adjuntoRelacionado;
    }
}