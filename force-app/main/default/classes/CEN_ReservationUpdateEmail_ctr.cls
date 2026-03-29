/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-28
* @description: Clase de controladora para la generación de PDF del informe
*               de solicitud de modificación de reserva.
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-28           Alan Alvarez            Creación 
*  
*********************************************************************/
public with sharing class CEN_ReservationUpdateEmail_ctr {

    @future(callout=true)
    public static void doSendEmail(String idOpp) {
        try {
            Integer countCotizacion = [SELECT Id FROM Quote WHERE OpportunityId = :idOpp].size();
            Opportunity opp = [Select Id, Name, OwnerId, CEN_Proforma__c, CEN_devolucion_saldo_Afavor__c, Owner.Name, Owner.Email From Opportunity Where Id = :idOpp];
            if(opp.CEN_Proforma__c != null && (countCotizacion > 1 || opp.CEN_devolucion_saldo_Afavor__c == true)){
                //Generacion PDF            
                List<Attachment> listAttachments = new List<Attachment>();
                Blob pdfGenerado;
                PageReference pdfPage = (PageReference) Page.CEN_ReservationUpdate_vf;
                pdfPage.getParameters().put('id', idOpp);
                if (Test.isRunningTest()) {
                    pdfGenerado = blob.valueOf('Unit.Test');
                } else {
                    pdfGenerado = pdfPage.getContentAsPDF();
                }
                if (pdfGenerado != null && String.isNotBlank(idOpp)) {
                    Attachment objAttachment = new Attachment();
                    objAttachment.parentId = idOpp;
                    objAttachment.Name = 'Solicitud de Modificación de Reserva.pdf';
                    objAttachment.body = pdfGenerado;
                    objAttachment.contentType = 'application/pdf';
                    objAttachment.isPrivate = false;
                    listAttachments.add(objAttachment);
                }
                insert listAttachments;
            }
        } catch (Exception e) {
            System.debug('Error: No se pudo generar el PDF: ' + e.getMessage());
        }
    }
    
    @InvocableMethod(label='ReservationUpdatePdfEmail')
    public static List<String> processReservationUpdatePdfEmail(List<Id> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0){
            for(Id myPayment : parameters){
                doSendEmail(myPayment);
                resp.add(myPayment+'inProccess');
            }
        }else{
            resp.add('empty');
        }
        return resp;
    }
}