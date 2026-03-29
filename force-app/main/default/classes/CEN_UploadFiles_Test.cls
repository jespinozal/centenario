/**
 * @description       : Clase test para subir archivos a un objeto
 * @author            : Joel Espinoza
 * @group             :
 * @last modified on  : 21-03-2023
 * @last modified by  : Joel Espinoza
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   21-03-2023   Joel Espinoza   Initial Version
 **/
@IsTest
public with sharing class CEN_UploadFiles_Test {

    @TestSetup
	static void setUp(){
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558710';
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        insert opps;
    }

    @isTest static void uploadFiles() {

        List<Object> filesToInsert = (List<Object>)JSON.deserializeUntyped('[{"Title":"imagen.txt","VersionData":"YWRzYXNk"}]');

        String recordId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<Id> cvList = CEN_cls_VisorLotes.uploadFile(filesToInsert, recordId);

        System.assertEquals(cvList.size(), 1, 'Cantidad de registros exitoso.');
    }
}