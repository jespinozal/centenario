@isTest
public with sharing class ONI_InventarioLauncherScheduler_tst {

    @testSetup
    static void setup() {

        // Proyectos requeridos por el launcher
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

        // Crear Pricebook requerido por Inventario
        insert new Pricebook2(
            Name = 'MacrOpolis',
            IsActive = true
        );
    }

    @isTest
    static void testSchedulerExecution() {

        // Mock para evitar fallo de callout
        Test.setMock(HttpCalloutMock.class, new DummyMock());

        String cronExp = '0 0 * * * ?';

        Test.startTest();
            System.schedule(
                'Test ONI Inventario Scheduler',
                cronExp,
                new ONI_InventarioLauncherScheduler_cls()
            );
        Test.stopTest();

        // Validar que el job fue creado
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test ONI Inventario Scheduler'
            LIMIT 1
        ];

        System.assertEquals(cronExp, ct.CronExpression);
        System.assert(ct.TimesTriggered >= 0);
    }

    // Mock simple para el callout del Queueable
    public class DummyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[]');
            return res;
        }
    }
}