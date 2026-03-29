public with sharing class CEN_cls_TratamientoDatosPersonales {
	@AuraEnabled
    public static Account getAccount(String Id){
        Account account = [SELECT Id, Name, check1__c, check2__c, check3__c From Account where Id =:Id];
        return account;
    }
    
    @AuraEnabled
    public static Account setPrivacidad(String id, Boolean check1, Boolean check2, Boolean check3, String document){
        Account p = [SELECT Id, check1__c, check2__c, check3__c FROM Account where Id=:id];
        
        if (document == 'presencial'){
            p.check1__c = check1;
            p.check2__c = check2;
            p.check3__c = check3;
        }else{
            p.check1__c = true;
            p.check2__c = true;
            p.check3__c = true;
        }
        
        try {
            update p;
            attach(p.Id, document);
        	System.debug('check1: ' + p.check1__c + 'check2: ' + p.check2__c + 'check3: ' + p.check3__c + 'document: ' + document);
            
        } catch(Exception e){
        	System.debug('error: '+e.getMessage());
        }
        return p;
    }
    
    @Future(callout = True)
    public static void attach(String cuentaId, String document){
        
        PageReference pdfPage = document == 'presencial' ? Page.CEN_TratamientoDatosPersonalesPDF : Page.CEN_TratamientoDatosPersonalesPDFNP;
        pdfPage.getParameters().put('id',cuentaId);
        Blob pdfBlob;
        
        system.debug('refe'+pdfPage);
        
        Datetime now = Datetime.now();
		Integer offset = UserInfo.getTimezone().getOffset(now);
		Datetime local = now.addSeconds(offset/1000);
        
        if(Test.isRunningTest()) {pdfBlob = blob.valueOf('Unit.Test');} else {pdfBlob = pdfPage.getContent();}
		Attachment attach = new Attachment(parentId = cuentaId, Name = 'Tratamiento de datos personales ' + local+'.pdf', body = pdfBlob, contentType='application/pdf', isPrivate=false);
		insert attach;
	}
}