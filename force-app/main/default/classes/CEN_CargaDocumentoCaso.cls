/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
public with sharing class CEN_CargaDocumentoCaso {
    /**
    * @description 
    * @author Richard Villafana - NTT DATA | 09-06-2024 
    * @param idCaso 
    * @param tipoDeClausula     = PREPAGO, RESOLUCION
    * @param extensionArchivo   = PDF
    * @param idDocument 
    * @return CEN_CargaDocumentoOnbaseApi.documentoResponse 
    **/
    @AuraEnabled
    public static CEN_CargaDocumentoOnbaseApi.documentoResponse uploadDocumento(String idCaso, String tipoDeClausula, String extensionArchivo, String idDocument){
        CEN_CargaDocumentoOnbaseApi.documentoResponse respuesta     =   new CEN_CargaDocumentoOnbaseApi.documentoResponse();
        System.debug('idCaso: '             +idCaso);
        System.debug('tipoDeClausula: '     +tipoDeClausula);
        System.debug('extensionArchivo: '   +extensionArchivo);
        System.debug('idDocument: '         +idDocument);
        ContentDocument cd              =   [SELECT Id, Title, FileType, ContentSize, Description 
                                            FROM ContentDocument 
                                            WHERE Id =: idDocument 
                                            WITH SECURITY_ENFORCED];

        List<ContentVersion> datosFiles =   [SELECT Title,ContentDocumentId,FileExtension,FileType,Id,VersionData,ContentSize
                                            FROM ContentVersion 
                                            WHERE ContentDocumentId =: idDocument
                                            WITH SECURITY_ENFORCED];

        String blobBase64   =   EncodingUtil.base64Encode(datosFiles.get(0).VersionData);
        System.debug('blobBase64: '+blobBase64);
        respuesta   =   CEN_CargaDocumentoOnbase.sendDocumentos(idCaso, tipoDeClausula, extensionArchivo, blobBase64);
        //Obtener el id del request
        String idLog;
        idLog = Request.getCurrent().getRequestId();
        respuesta.idLog =   idLog;
        Case c  =   [SELECT Id, CEN_IdDeDocumentoOnbase__c
                    FROM Case 
                    WHERE Id =: idCaso
                    WITH SECURITY_ENFORCED];
        c.CEN_IdDeDocumentoOnbase__c            =   respuesta.mensaje_error;
        C.CEN_FechaHoraCargaDocumentosSAP__c    =   System.now();
        try {
            update c;
            delete cd;
        } catch (Exception e) {
            System.debug('Error: '+e);
        }
        return respuesta;
    }

    /**
    * @description 
    * @author Juan Medina - NTT DATA | 20-10-2024 
    * @param idCaso 
    * @param jsonRespuesta
    * @return CEN_CargaDocumentoOnbaseApi.documentoResponse 
    **/
    @AuraEnabled
    public static CEN_CargaDocumentoOnbaseApi.documentoResponse uploadCont(String idCaso,String jsonRespuesta){
        try {

            CEN_CargaDocumentoOnbaseApi.documentoResponse respuesta = (CEN_CargaDocumentoOnbaseApi.documentoResponse) System.JSON.deserialize(jsonRespuesta, CEN_CargaDocumentoOnbaseApi.documentoResponse.class);

            String idLog;
        idLog = Request.getCurrent().getRequestId();
        respuesta.idLog =   idLog;
        Case c  =   [SELECT Id, CEN_IdDeDocumentoOnbase__c
                    FROM Case 
                    WHERE Id =: idCaso
                    WITH SECURITY_ENFORCED];
        c.CEN_IdDeDocumentoOnbase__c            =   respuesta.mensaje_error;
        C.CEN_FechaHoraCargaDocumentosSAP__c    =   System.now();
        try {
            Database.update(c,AccessLevel.USER_MODE);
            
        } catch (Exception e) {
            System.debug('Error: '+e);
        }
        return respuesta;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Richard Villafana - NTT DATA | 09-06-2024 
    * @param idCaso 
    * @param tipoDeClausula     = PREPAGO, RESOLUCION
    * @param extensionArchivo   = PDF
    * @param idDocument 
    * @return CEN_CargaDocumentoOnbaseApi.documentoResponse 
    **/
    @AuraEnabled
    @future
    public static void relateCaseLog(String idCaso, String idLog){
        List<CEN_ServicesLog__c> log  =   [SELECT CEN_caseId__c, Id, CEN_RequestId__c
                                    FROM CEN_ServicesLog__c
                                    WHERE CEN_RequestId__c =: idLog];
        System.debug('idCaso: '+idCaso);
        System.debug('idLog: '+idLog);
        System.debug('log: '+log);

        if(log.size()>0){
            try {
                for(CEN_ServicesLog__c l : log){
                    l.CEN_caseId__c   =   idCaso;
                }
                update log;
            } catch (Exception e) {
                System.debug('Error al actualizar log con caso: '+e);
            }
        }
    }

    /**
    * @description 
    * @author Juan Medina - NTT DATA | 20-10-2024 
    * @return CEN_AvailableWebservices__mdt 
    **/
    @AuraEnabled
    public static CEN_AvailableWebservices__mdt getFetchParams(){
       
            return  [SELECT CEN_AdditionalHeaders__c, CEN_Endpoint__c, CEN_Method__c, CEN_NamedCredential__c, CEN_ParserClass__c FROM CEN_AvailableWebservices__mdt WHERE DeveloperName ='CEN_OnbaseDocumentos'];
       
    }
    /**
    * @description 
    * @author Juan Medina - NTT DATA | 20-10-2024 
    * @param idCaso 
    * @return Case
    **/
    @AuraEnabled
    public static Case getCaseForDocument(String idCaso){
        try {

            Case caso   =   [SELECT CaseNumber, Account.RecordType.DeveloperName, CEN_Etapa__c, CEN_VersionFinanciamiento__c,
                        CEN_CodFinanciamiento__c, Account.Name, Account.CEN_Tipo_de_documento__c, toLabel(Account.CEN_Tipo_de_documento__pc),
                        Account.CEN_N_mero_de_documento__pc, Account.CEN_Numero_de_documento_del__c, CEN_Lotes_asignados__c, CEN_CodigoDeLotes__c, ParentId,
                        Parent.CEN_CodFinanciamiento__c, Parent.CaseNumber, CEN_SociedadFinanciamiento__c, RecordType.DeveloperName
                        FROM Case
                        WHERE Id =: idCaso
                        WITH SECURITY_ENFORCED];

            return caso;                        
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

       
    }
    
    /**
    * @description 
    * @author Juan Medina - NTT DATA | 20-10-2024 
    * @param idCaso 
    * @return ResumenDocumentos 
    **/
    @AuraEnabled
    public static ResumenDocumentos getDatosDocumentos(String idCaso){
        ResumenDocumentos resumen   =   new ResumenDocumentos();
        Case caso       =   [SELECT RecordType.developerName, Account.CEN_Numero_de_documento_del__c, Account.CEN_N_mero_de_documento__pc, Account.IsPersonAccount,
                            CEN_CodFinanciamiento__c, CEN_DocumentosSAP__c, Owner.name, CEN_FechaHoraCargaDocumentosSAP__c, CEN_IdDeDocumentoOnbase__c
                            FROM Case
                            WHERE Id=: idCaso
                            WITH SECURITY_ENFORCED];
        
        if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionUrbanoResolucion'){
            resumen.tipoDeSolicitud         =   'Resolución';
        }else if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionPrepago'){
            resumen.tipoDeSolicitud         =   'Prepago';
        }
        if(caso.Account.IsPersonAccount){
            resumen.numeroDocumento         =   caso.Account.CEN_N_mero_de_documento__pc;
        }else{
            resumen.numeroDocumento         =   caso.Account.CEN_Numero_de_documento_del__c;
        }
        resumen.financiamiento              =   caso.CEN_CodFinanciamiento__c;
        resumen.estado                      =   caso.CEN_IdDeDocumentoOnbase__c;
        resumen.url                         =   caso.CEN_DocumentosSAP__c;
        resumen.usuario                     =   caso.Owner.name;
        if(caso.CEN_FechaHoraCargaDocumentosSAP__c!=null){
            resumen.fechaDeCarga            =   String.valueOf(caso.CEN_FechaHoraCargaDocumentosSAP__c.format());
        }
        return resumen;
    }

    public class ResumenDocumentos{
        @AuraEnabled public String  tipoDeSolicitud;
        @AuraEnabled public String  numeroDocumento;
        @AuraEnabled public String  financiamiento;
        @AuraEnabled public String  estado;
        @AuraEnabled public String  url;
        @AuraEnabled public String  usuario;
        @AuraEnabled public String  fechaDeCarga;

    }

}