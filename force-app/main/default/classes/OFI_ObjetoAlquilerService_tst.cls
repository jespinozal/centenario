@IsTest
public class OFI_ObjetoAlquilerService_tst {

    @IsTest
    static void testGetObjetosAlquiler() {
        // Configuramos el mock de callout HTTP
        Test.setMock(HttpCalloutMock.class, new OFI_ObjetoAlquilerServiceMock_cls());
        
        Id stdPbId = Test.getStandardPricebookId();
        // Aseguramos que el estándar esté activo
        update new Pricebook2(Id = stdPbId, IsActive = true);
        // IMPORTANTE: para que no falle el helper, creamos al menos:
        // - Pricebook "Oficinas"
        // - Maestro de precios para EDIF001
        Pricebook2 oficinasPb = new Pricebook2(
            Name = 'Oficinas',
            IsActive = true
        );
        insert oficinasPb;

        OFI_obj_MaestroPrecioEdificio__c mpeOficina = new OFI_obj_MaestroPrecioEdificio__c(
            Name = 'Edif Normal',
            OFI_fld_MtroPrecioEdif_EdifExtId__c = 'EDIF001',
            OFI_fld_MtroPrecioEdif_PrecioCascoGris__c = 10,
            OFI_fld_MtroPrecioEdif_EsPrecioFijo__c = false
        );
        insert mpeOficina;

        Test.startTest();
        List<OFI_ObjetoAlquilerObjectResponse_cls> result =
            OFI_ObjetoAlquilerService_cls.getObjetosAlquiler('20260101');
        Test.stopTest();

        System.assertNotEquals(null, result, 'La lista de respuesta no debe ser null');
        System.assertEquals(1, result.size(), 'Debe haber un registro deserializado');

        // Verificar que el helper haya creado producto y proyecto
        Proyecto__c proy = [
            SELECT Id
            FROM Proyecto__c
            WHERE ONI_fld_Proyecto_EdificioExternalId__c = 'EDIF001'
            LIMIT 1
        ];
        System.assertNotEquals(null, proy);

        Product2 prod = [
            SELECT Id
            FROM Product2
            WHERE OFI_fld_Product2_IdSAP__c = 'OBJ001'
            LIMIT 1
        ];
        System.assertNotEquals(null, prod);
    }

    @IsTest
    static void testGetObjetosAlquiler_NoData311() {

        Test.setMock(
            HttpCalloutMock.class,
            new OFI_ObjetoAlquilerServiceMock_311_cls()
        );

        Test.startTest();
        List<OFI_ObjetoAlquilerObjectResponse_cls> result =
            OFI_ObjetoAlquilerService_cls.getObjetosAlquiler('20260129');
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(
            0,
            result.size(),
            'Cuando el servicio devuelve 311, la lista debe estar vacía'
        );
    }
}