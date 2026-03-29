/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
@isTest
public with sharing class CEN_CargaDocumentoOnbase_test {
    @TestSetup
    static void makeData(){
        Product2 product     =   new Product2(
            Name        =   'Producto Test',
            CODLOTE__c  =   '840037564'
        );
        insert product;

        Account acc = new Account(
            Name = 'Business Account',
            CEN_Numero_de_documento_del__c = '87654321'
        );
        insert acc;

        Case testCase = new Case(
            AccountId                           =   acc.Id,
            CEN_Lotes_asignados__c              =   '840037564',
            CEN_CodigoDeLotes__c                =   '840037564',
            CEN_CodFinanciamiento__c            =   '59530',
            CEN_FechaHoraCargaDocumentosSAP__c  =   System.now()

        );
        insert testCase;

        RecordType rtPersonAccount  =   [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account personAccount   =   new Account(
        FirstName       =   'Person',
        LastName        =   'Account',
        RecordTypeId    =   rtPersonAccount.Id
        );
        insert personAccount;

        Case testCasePersonAccount = new Case(
            AccountId                   =   personAccount.Id,
            CEN_Lotes_asignados__c      =   '840037564',
            CEN_CodigoDeLotes__c        =   '840037564',
            CEN_CodFinanciamiento__c    =   '59530'
        );
        insert testCasePersonAccount;

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId      = testCase.Id;
            cdl.ContentDocumentId   = documents[0].Id;
            cdl.ShareType           = 'V';
            cdl.Visibility          = 'AllUsers';
            insert cdl;

    }
    @isTest
    static void test_sendDocumentosJuridico(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        ContentDocument cd              =   [SELECT Id, Title, FileType, ContentSize, Description 
                                            FROM ContentDocument 
                                            LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        CEN_CargaDocumentoOnbaseApi.documentoResponse resp = CEN_CargaDocumentoCaso.uploadDocumento(casoTest.Id, 'PREPAGO', 'PDF', cd.Id);
        CEN_CargaDocumentoCaso.relateCaseLog(casoTest.Id, resp.idLog);
        Test.stopTest();  
    }

    @isTest
    static void test_sendDocumentosNatural(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Person Account' LIMIT 1];
        ContentDocument cd              =   [SELECT Id, Title, FileType, ContentSize, Description 
                                            FROM ContentDocument 
                                            LIMIT 1];
        CEN_CargaDocumentoOnbaseApi.documentoResponse resp = CEN_CargaDocumentoCaso.uploadDocumento(casoTest.Id, 'PREPAGO', 'PDF', cd.Id);
        CEN_CargaDocumentoCaso.relateCaseLog(casoTest.Id, resp.idLog);
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        Test.stopTest();  
    }
    @isTest
    static void test_getDatosDocumentos(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        CEN_CargaDocumentoCaso.getDatosDocumentos(casoTest.Id);
        Test.stopTest();  
    }

    @isTest
    static void test_uploadCont(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        String jsonRespuesta = '{"cod_respuesta": 0,"mensaje_error": "Mensaje: Cargo Exitosamente. ID: 2366636"}';
        CEN_CargaDocumentoCaso.uploadCont(casoTest.Id,jsonRespuesta);
        Test.stopTest();  
    }

    @isTest
    static void test_uploadContException(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        String jsonRespuesta = '{"cod_respuesta": 0,"mensaje_error": "Mensaje: Cargo Exitosamente. ID: 2366636"}';
        try{
        CEN_CargaDocumentoCaso.uploadCont('111884949',jsonRespuesta);
        }catch(Exception e){ //NOPMD
           
        }
        Test.stopTest();  
    }

    @isTest
    static void test_getFetchParams(){
        Test.startTest();
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        
        CEN_CargaDocumentoCaso.getFetchParams();
        Test.stopTest();  
    }

    @isTest
    static void test_getCaseForDocument(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        CEN_CargaDocumentoCaso.getCaseForDocument(casoTest.Id);
        Test.stopTest();  
    }

    @isTest
    static void test_getCaseForDocumentException(){
        Test.startTest();
        Case casoTest = [SELECT Id FROM Case WHERE Account.Name = 'Business Account' LIMIT 1];
        //CEN_CargaDocumentoOnbase.sendDocumentos(casoTest.Id, 'PREPAGO', 'PDF', 'docBase64');
        try{
        CEN_CargaDocumentoCaso.getCaseForDocument('161168181');
        }catch(Exception e){//NOPMD
            
        }
        Test.stopTest();  
    }
}