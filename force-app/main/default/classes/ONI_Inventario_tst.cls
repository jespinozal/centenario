@isTest
public with sharing class ONI_Inventario_tst {

    @testSetup
    static void setup() {

        // Proyecto requerido por el Queueable (ahora recibe Id por constructor)
        Proyecto__c pro = new Proyecto__c(
            Name = 'Macropolis - Etapa 3',
            CEN_CODIGOSAP__c = 'SAP001'
        );
        insert pro;

        // Activar Standard Pricebook
        Pricebook2 standardPb = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPb;

        // Pricebook requerido por nombre hardcodeado
        Pricebook2 customPB = new Pricebook2(
            Name = 'MacrOpolis',
            IsActive = true
        );
        insert customPB;

        // Producto existente para cubrir escenario UPDATE
        Product2 prod = new Product2(
            Name = 'Existing Lote',
            CODLOTE__c = '1', // '001' será convertido a '1'
            IsActive = true
        );
        insert prod;
    }

    @isTest
    static void testQueueableExecution_InsertAndUpdate() {

        // Obtener proyecto creado en testSetup
        Proyecto__c pro = [
            SELECT Id, CEN_CODIGOSAP__c
            FROM Proyecto__c
            LIMIT 1
        ];

        // Mock del callout
        Test.setMock(HttpCalloutMock.class, new ONI_Inventario_Mock());

        Test.startTest();
        System.enqueueJob(new ONI_Inventario_cls(pro.Id));
        Test.stopTest();

        // =========================
        // VALIDAR PRODUCTO UPSERT
        // =========================
        Product2 p = [
            SELECT Id, Name, CODLOTE__c, CEN_PRECIOVENTAFUN__c
            FROM Product2
            WHERE CODLOTE__c = '1'
            LIMIT 1
        ];

        System.assertEquals('Lote Test', p.Name);
        System.assertEquals('1000', p.CEN_PRECIOVENTAFUN__c);

        // =========================
        // VALIDAR PRICEBOOK ENTRIES
        // =========================
        List<PricebookEntry> pbeList = [
            SELECT Id, Pricebook2.Name, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id = :p.Id
        ];

        System.assertEquals(
            2,
            pbeList.size(),
            'Debe existir un PricebookEntry en Standard y otro en MacrOpolis'
        );

        Boolean foundStandard = false;
        Boolean foundCustom = false;

        for (PricebookEntry pbe : pbeList) {

            if (pbe.Pricebook2.Name == 'Standard Price Book') {
                foundStandard = true;
                System.assertEquals(false, pbe.IsActive);
                System.assertEquals(1000, pbe.UnitPrice);
            }

            if (pbe.Pricebook2.Name == 'MacrOpolis') {
                foundCustom = true;
                System.assertEquals(true, pbe.IsActive);
                System.assertEquals(1000, pbe.UnitPrice);
            }
        }

        System.assert(foundStandard, 'Debe existir Standard PricebookEntry');
        System.assert(foundCustom, 'Debe existir MacrOpolis PricebookEntry');
    }

    /**
     * Mock del endpoint SAP
     * Debe coincidir con estructura LoteWrapper
     */
    public class ONI_Inventario_Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            res.setBody(
                '[{' +
                    '"codLote":"001",' +
                    '"descripcionLote":"Lote Test",' +
                    '"descripcionCorta":"Test",' +
                    '"idLote":123,' +
                    '"precioVenta":1000,' +
                    '"areaMt2":200,' +
                    '"estadoActualLote":"L",' +
                    '"monedaLote":"PEN",' +
                    '"codCompania":"C01",' +
                    '"lote":"1",' +
                    '"descripcionTipologia":"Industrial",' +
                    '"tipologiaProductos":"Industrial",' +
                    '"idCrm":""' +
                '}]'
            );

            return res;
        }
    }
}