global class CEN_cls_OppAttach {
    
    
    public Opportunity pr;   
    
    @future(callout=true)
    public static void createPDF(ID Id)
    {
        //string idattach;
        system.debug('Paso');
        PageReference pdfPage = Page.CEN_vf_CotizacionPDF;
        pdfPage.getParameters().put('id',Id);
        Blob pdfBlob;
        
        Datetime now = Datetime.now();
		Integer offset = UserInfo.getTimezone().getOffset(now);
		Datetime local = now.addSeconds(offset/1000);
        
        System.debug('Id Oportunidad:'+Id);
        if(Test.isRunningTest()) {pdfBlob = blob.valueOf('Unit.Test');} else {pdfBlob = pdfPage.getContent();}
		Attachment attach = new Attachment(parentId = Id, Name = 'Cotización PDF' + local+'.pdf', body = pdfBlob, contentType='application/pdf', isPrivate=false);
		insert attach;

        //idattach = attach.id;
        //System.debug('idattach:' +idattach);
        //return  idattach;
    }
   
}