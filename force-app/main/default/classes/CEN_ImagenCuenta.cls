public class CEN_ImagenCuenta {
    
    @AuraEnabled
    public static LCH_ContactHighlightContainer getInfoFromObject(Id objectId, String SObjectName) {            
        if (SObjectName == 'Case') {
            return getInfoFromCase(objectId);
        
        } else if (SObjectName == 'Contact') {
            //return getInfoFromContact(objectId);
        } else 
            if (SObjectName == 'Account') {
            return getInfoFromPersonAccount(objectId);
        }
        return NULL;
    }
    
         @AuraEnabled
     public static LCH_ContactHighlightContainer getInfoFromCase(Id caseId) {  
        //Case cList = [SELECT Id, Subject, Description, Status, ContactId,CEN_Actualizar_Datos__c
          //        FROM Case WHERE ID = :caseId];
         
        List<Case> cList = (List<Case>)Database.query('SELECT Id, Subject, Description, Status, ContactId,CEN_Actualizar_Datos__c FROM Case WHERE ID = :caseId');

         LCH_ContactHighlightContainer chc = new LCH_ContactHighlightContainer();
         system.debug('ACTUALIZAR DATOS'+cList[0].CEN_Actualizar_Datos__c);
        if (cList != NULL) {
            Case c = cList[0];
            //LCH_ContactHighlightContainer chc = getInfoFromCase(c.ContactId);
            chc.RelatedCase = c;
            system.debug('Datos Case. '+chc.RelatedCase);
            
            //chc.RelatedCase = c;
            return chc;
        } else 
             return NULL;
     }
    
 
    
    @AuraEnabled
    public static LCH_ContactHighlightContainer getInfoFromPersonAccount(Id PersonAccountId) {  
        Account acc = [SELECT id FROM account WHERE id = :PersonAccountId];
        
        if (acc != NULL) {
            return getInfoFromContact(acc.id);
        } else 
            return NULL;
    }
    
    
    @AuraEnabled
    public static LCH_ContactHighlightContainer getInfoFromContact(Id ContactId) {
        LCH_ContactHighlightContainer chc = new LCH_ContactHighlightContainer();
        String ContactStrId = ContactId;
        
        List<Account> cList = (List<Account>)Database.query('SELECT Id, Name, CEN_N_mero_de_documento__pc, CEN_Tipo_de_documento__pc, PersonLeadSource, CEN_Origen__c  FROM Account WHERE ID = :ContactStrId');
        if (!cList.isEmpty()) {
            Account co = cList[0];
            List <User> u= [SELECT FullPhotoUrl FROM User WHERE contactId = :ContactId LIMIT 1];
            //AggregateResult[] csatResults = Database.query('SELECT AVG(CSAT__c)aver FROM Customer_Survey__c WHERE Contact__c = :ContactStrId GROUP By Contact__c');
            //List<Sobject> npsResults = Database.query('SELECT NPS__c FROM Customer_Survey__c WHERE Contact__c = :ContactStrId');
            
            //chc.CaseByPhone = [SELECT Count() FROM Case WHERE ContactId = :co.id AND Origin='Phone'];
            //chc.CaseByWeb = [SELECT Count() FROM Case WHERE ContactId = :co.id AND (Origin='Website' OR Origin = 'Community' OR Origin = 'Mobile Device')];
            //chc.CaseByChat = [SELECT Count() FROM Case WHERE ContactId = :co.id AND Origin='Chat'];
            //chc.CaseBySocial = [SELECT Count() FROM Case WHERE ContactId = :co.id AND (Origin='Facebook' OR Origin = 'Twitter' OR Origin = 'Instagram' OR Origin = 'LinkedIn')];
            chc.Account = co;
            
            if (u.isEmpty())
                chc.photoUrl='/img/social/unknown_profile_pic.png?v=2';
            else 
               chc.photoURL=u[0].FullPhotoUrl;
            //if (!csatResults.isEmpty())
                //chc.CSAT= ((decimal)csatResults[0].get('aver')).setScale(1).format().replace(',','.');
            //else
                //chc.CSAT = '0';
            //if (!npsResults.isEmpty()){
               // Decimal positives=0;
                //Decimal negatives=0;
                
                //for(Integer i = 0; i < npsResults.size(); i++){
                    //Double nps = (Double)npsResults[i].get('NPS__c');
                    
                    //if(nps == 10 || nps == 9)positives++;
                    //else if(nps != 7 && nps != 8)negatives++;
                //}
                //chc.NPS=(((positives-negatives)/npsResults.size())*100).intValue().format();
            //} else {
                //chc.NPS = '0';
            //}
       	} else
            chc.Account = new Account();
        return chc; 
    }
    
    //Lurdes
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {

        // Attachment permissions are set in parent object (Contact)
        /*if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            return null;
        }*/

        Attachment  oAttachment=new Attachment();
            try {
                    oAttachment = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
                        WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
                        ORDER BY LastModifiedDate DESC LIMIT 1];

            }catch(Exception  e)
            {
                    oAttachment =null;
            }     

 
        /*return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];*/
            return oAttachment;

    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 

        // Edit permission on parent object (Contact) is required to add attachments
        /*if (!Schema.sObjectType.Contact.isUpdateable()) {
            throw new System.NoAccessException();
            return null;
        }*/

        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
		attachment.contentType = contentType;
        insert attachment;
        return attachment.id;
    }
    
    

}