public with sharing class CEN_generarDocumentosDomiciliarios {
    public CEN_generarDocumentosDomiciliarios() {

    }

    @future(callout=true)
    public static void generarPDF(String idAccount) {    
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        generarPDFCroquis(idAccount,local);
        generarPDFDeclaracionJurada(idAccount,local);
    }

    public static void generarPDFCroquis(String idAccount,Datetime local) {

        List<Attachment> listAttachments = new List<Attachment>();
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_vf_pdfCroquisCliente;
        pdfPage.getParameters().put('Id', idAccount);

        system.debug('croquis:'+pdfPage);

        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContentAsPDF();
            }
            
            if (pdfGenerado != null && String.isNotBlank(idAccount)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idAccount;
                objAttachment.Name = 'Documento_Croquis_' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            
            insert listAttachments;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            System.debug(
                LoggingLevel.ERROR,
                'No se pudo generar el PDF Domiciliario: ' +
                e.getMessage() +
                '. Type: ' +
                e.getTypeName() +
                '. Line: ' +
                e.getLineNumber()
            );
        }
    }

    public static void generarPDFDeclaracionJurada(String idAccount,Datetime local) {

        system.debug('idAccount: '+idAccount);
        Account cuenta = [SELECT RecordType.DeveloperName FROM ACCOUNT WHERE id = :idAccount]; 
        List<Attachment> listAttachments = new List<Attachment>();
        Blob pdfGenerado = null;
        PageReference pdfPage;
        system.debug('cuenta.RecordType.DeveloperName: ');
        system.debug(cuenta.RecordType.DeveloperName);
        pdfPage = cuenta.RecordType.DeveloperName == 'PersonAccount' ? (PageReference) Page.CEN_vf_pdfDeclaracionJuradaDomiciliaria : (PageReference) Page.CEN_vf_pdfDJDomiciliariaEmpresa;
        system.debug('uno');
        pdfPage.getParameters().put('Id', idAccount);
        system.debug('dos');
        system.debug('DJ:'+pdfPage);
        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContentAsPDF();
                system.debug('tres');
            }
            
            if (pdfGenerado != null && String.isNotBlank(idAccount)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idAccount;
                objAttachment.Name = 'Documento_Declaración_Jurada_' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            insert listAttachments;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            System.debug(
                LoggingLevel.ERROR,
                'No se pudo generar el PDF Domiciliario: ' +
                e.getMessage() +
                '. Type: ' +
                e.getTypeName() +
                '. Line: ' +
                e.getLineNumber()
            );
        }
    }


    @InvocableMethod(label='processGenerateDocumentAddress')
    public static List<String> processGenerateDocumentAddress(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].accIds!=null ){
        for(Integer i=0; i < parameters.size(); i++){  
            generarPDF(parameters[i].accIds);
            resp.add(parameters[i].accIds+'inProccess');
        }
        }else{
            resp.add('empty');
        }

    return resp;
    }

    public class FlowParameters {
		@InvocableVariable(label='IdAccount' description='Ids Accounts parameter' required=true)
		public String accIds;
  	}

}