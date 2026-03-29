/**
 * @description       : Clase para subir archivos a un objeto
 * @author            : Joel Espinoza
 * @group             :
 * @last modified on  : 21-03-2023
 * @last modified by  : Joel Espinoza
 * @testclass         : CEN_UploadFiles_Test
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   21-03-2023   @nttdata.com   Initial Version
 **/
public with sharing class CEN_UploadFiles_ctr {
  
    public static List<ContentDocumentLink> createContentLink(List<String> cvList, String recordId) {
  
      if (cvList == null || cvList.size() < 1) { return null; }
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentVersion> lista = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvList];
        for(ContentVersion cv : lista){
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.ContentDocumentId = cv.ContentDocumentId;
          cdl.LinkedEntityId = recordId;
          // ShareType is either 'V', 'C', or 'I'
          // V = Viewer, C = Collaborator, I = Inferred
          cdl.ShareType = 'V';
          cdlList.add(cdl);
        }
  
        try {
        insert cdlList;
        return cdlList;
        } catch(DMLException e) {
        System.debug(e);
        return null;
      }
    }
  
    //@AuraEnabled
    public static list<Id> saveFiles(list<Object> filesToInsert){
      
      list<Id> lstCntVerIds = new list<Id>();
      List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
      for (Object file : filesToInsert) {
          FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
          ContentVersion objCntVersion = new ContentVersion();
          objCntVersion.PathOnClient = fileData.Title;
          objCntVersion.Title = fileData.Title;
          objCntVersion.VersionData = fileData.VersionData;
          lstVersionsToInsert.add(objCntVersion);
      }
  
      list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
      for (Database.SaveResult saveResult : res) {
          if(saveResult.isSuccess()) {
              lstCntVerIds.add(saveResult.getId());
          }
      }
      return lstCntVerIds;
    }
  
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}