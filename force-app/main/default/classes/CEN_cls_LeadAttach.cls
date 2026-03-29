public class CEN_cls_LeadAttach {
    public Lead pr;   
    
    
    public  CEN_cls_LeadAttach (ApexPages.StandardController standardPageController)
    {
        pr = (Lead)standardPageController.getRecord();
    }
    
    public PageReference attach(){
        PageReference pdfPage = Page.CEN_vf_Lead2;
        pdfPage.getParameters().put('id',pr.id);
        Blob pdfBlob;
        
        Datetime now = Datetime.now();
		Integer offset = UserInfo.getTimezone().getOffset(now);
		Datetime local = now.addSeconds(offset/1000);
        
        
        if(Test.isRunningTest()) {pdfBlob = blob.valueOf('Unit.Test');} else {pdfBlob = pdfPage.getContent();}
		Attachment attach = new Attachment(parentId = pr.id, Name = 'Ley de Protección de Datos Personales ' + local+'.pdf', body = pdfBlob, contentType='application/pdf', isPrivate=false);
		insert attach;
        
        PageReference pageWhereWeWantToGo = new ApexPages.StandardController(pr).view();
		pageWhereWeWantToGo.setRedirect(true); 
		return pageWhereWeWantToGo;
    }
}