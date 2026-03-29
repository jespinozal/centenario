/**
 * @description       : CEN_OwnershipTransferQuote_tst
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 07-01-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-01-2021   @everis.com   Initial Version
**/public class CEN_OwnershipTransferQuote_ctr {
    @invocableMethod(label = 'Generate PDFQuote for new owner ' description = 'Genera PDFs para ambas oportunidades')
    public static void GeneratePDF(List<FlowParameters> parameterId){
        if((parameterId!=null && parameterId.size()>0 && parameterId[0].opQuote!=null && parameterId[0].opQuote.size()>0) &&
         (parameterId!=null && parameterId.size()>0 && parameterId[0].opIdsNew!=null && parameterId[0].opIdsNew.size()>0)){
             List<Quote> quote = [SELECT id from Quote where id IN: parameterId[0].opQuote];
             List<Opportunity> oppNueva = [SELECT id from Opportunity where id IN: parameterId[0].opIdsNew];
             generarPDF(quote[0].id, oppNueva[0].id);
        }        
    }

    @future(callout=true)
    public static void generarPDF(String idCotizacion, String idOportunidad) {
        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_OwnershipTransferQuotePDF_vf;
        pdfPage.getParameters().put('Id', idCotizacion);
        
        try {
            if (Test.isRunningTest()) {
                pdfGenerado = blob.valueOf('Unit.Test');
            } else {
                pdfGenerado = pdfPage.getContentAsPDF();
            }
            
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idCotizacion;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            
            insert listAttachments;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' + e.getTypeName() + '. Line: ' + e.getLineNumber());
        }
    }

    public class FlowParameters {
        @InvocableVariable(label = 'QuoteIdsParamts' description = 'Ids QUotes parameters' required = true)
        public List<String> opQuote;
        @InvocableVariable(label = 'OPIdsParamtsNew' description = 'Ids Ops parameters' required = true)
        public List<String> opIdsNew;
    }    
}