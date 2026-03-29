@isTest
public with sharing class ONI_InventarioLauncher_tst {

    @testSetup
    static void setup() {

        insert new Proyecto__c(
            Name = 'Macrópolis - Etapa 1',
            CEN_CODIGOSAP__c = 'SAP001'
        );

        insert new Proyecto__c(
            Name = 'Macrópolis - Etapa 2',
            CEN_CODIGOSAP__c = 'SAP002'
        );

        // Activar Standard Pricebook
        Pricebook2 standardPb = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPb;

        // Crear Pricebook requerido
        insert new Pricebook2(
            Name = 'MacrOpolis',
            IsActive = true
        );
    }

    @isTest
    static void testLauncherEnqueuesJobs() {

        // Mock mínimo para evitar error de callout
        Test.setMock(HttpCalloutMock.class, new DummyMock());

        Test.startTest();
            ONI_InventarioLauncher_cls.run();
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id, JobType
            FROM AsyncApexJob
            WHERE JobType = 'Queueable'
        ];

        System.assertEquals(2, jobs.size());
    }

    // Mock simple (no necesitamos lógica compleja aquí)
    public class DummyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[]'); // No devuelve lotes
            return res;
        }
    }
}