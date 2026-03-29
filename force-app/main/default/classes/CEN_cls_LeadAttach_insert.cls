global class CEN_cls_LeadAttach_insert {
    
    
    public Lead pr;   
    
    @future (callout=true)
    public static void createPDF(ID Id)
    {
        PageReference pdfPage = Page.CEN_vf_Lead2;
        pdfPage.getParameters().put('id',id);
        Blob pdfBlob;
        
        Datetime now = Datetime.now();
		Integer offset = UserInfo.getTimezone().getOffset(now);
		Datetime local = now.addSeconds(offset/1000);
        
        System.debug('Id lead:'+id);
        if(Test.isRunningTest()) {pdfBlob = blob.valueOf('Unit.Test');} else {pdfBlob = pdfPage.getContent();}
		Attachment attach = new Attachment(parentId = id, Name = 'Ley de Protección de Datos Personales ' + local+'.pdf', body = pdfBlob, contentType='application/pdf', isPrivate=false);
		insert attach;
        
        
    }
    

   
}