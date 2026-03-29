/**
 * @description       : CEN_OwnershipTransfer_tst
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-30-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
public class CEN_OwnershipTransfer_ctr {
    
    @invocableMethod(label = 'Generate PDF for new owner' description = 'Genera PDFs para ambas oportunidades')
    public static void GeneratePDF(List<FlowParameters> parameterId){
        if((parameterId!=null && parameterId.size()>0 && parameterId[0].opIds!=null && parameterId[0].opIds.size()>0) &&
         (parameterId!=null && parameterId.size()>0 && parameterId[0].opIdsNew!=null && parameterId[0].opIdsNew.size()>0)){
             List<Opportunity> opp = [SELECT id from Opportunity where id IN: parameterId[0].opIds];
             List<Opportunity> oppNueva = [SELECT id from Opportunity where id IN: parameterId[0].opIdsNew];
             generarPDF(opp[0].id, oppNueva[0].id);
        }        
    }

    @future(callout=true)
    public static void generarPDF(String idOportunidad, String idOportunidadNueva) {
        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_OwnershipTransferPDF_vf;
        pdfPage.getParameters().put('Id', idOportunidad);
        
        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContentAsPDF();
            }
            
            if (pdfGenerado != null && String.isNotBlank(idOportunidad)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Cesión de Abonos PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(idOportunidad)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidadNueva;
                objAttachment.Name = 'Cesión de Abonos PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                System.debug('Cesionario: '+idOportunidadNueva);
                listAttachments.add(objAttachment);
            }
            
            insert listAttachments;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' + e.getTypeName() + '. Line: ' + e.getLineNumber());
        }
    }

    public class FlowParameters {
        @InvocableVariable(label = 'OPIdsParamts' description = 'Ids Ops parameters' required = true)
        public List<String> opIds;
        @InvocableVariable(label = 'OPIdsParamtsNew' description = 'Ids Ops parameters' required = true)
        public List<String> opIdsNew;
    }
}