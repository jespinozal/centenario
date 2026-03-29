@isTest
public class CEN_ModalCotizadorLibre_tst {
    @TestSetup
	static void SetUp(){
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        accs[0].CEN_N_mero_de_documento__pc = '45558711';
        insert accs;

        //---- PROYECTO
        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U1.011E';
        proyecto.CEN_Etapa__c='Etapa 1';
        insert proyecto;

        // //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].AccountId = accs[0].Id;
        opps[0].CEN_Proyecto__c = proyecto.Id;
        insert opps;
    }
    @IsTest
    static void validateStageOpp_tst(){
        Test.startTest();
        Opportunity oportunidad = [Select id, stagename from Opportunity limit 1];
        oportunidad.StageName = 'Cotización';
        Update oportunidad;
        Boolean resp = false;
        resp = CEN_ModalCotizadorLibre_ctr.validateStageOpp(oportunidad.Id);
        System.assertEquals(true, resp);
        Test.stopTest();
    }
    @IsTest
    static void getMonedaActualOpp_tst(){
        Test.startTest();
        Opportunity oportunidad = [Select id, stagename from Opportunity limit 1];
        oportunidad.StageName = 'Cotización';
        Update oportunidad;
        String resp = '';
        resp = CEN_ModalCotizadorLibre_ctr.getMonedaActual(oportunidad.Id);
        //System.assertEquals(true, resp);
        Test.stopTest();
    }

    @IsTest
    static void getOppData_tst(){
        Test.startTest();
        Opportunity oportunidad = [Select id, stagename from Opportunity limit 1];
        oportunidad.StageName = 'Cotización';
        Update oportunidad;
        Opportunity resp = CEN_ModalCotizadorLibre_ctr.getOppData(oportunidad.Id);
        //System.assertEquals(true, resp);
        Test.stopTest();
    }
}