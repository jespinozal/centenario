@IsTest
private class OFI_ObjetoAlquilerHelper_tst {

    // ==============================================================
    // TEST PRINCIPAL – Flujo completo con Callout Mock
    // ==============================================================
    @IsTest
    static void testProcessObjetoAlquiler_OK() {

        // ----------------------------------------------------------
        // 1. Preparación del mock del callout
        // ----------------------------------------------------------
        Test.setMock(
            HttpCalloutMock.class,
            new OFI_ObjetoAlquilerServiceMock_cls()
        );

        // ----------------------------------------------------------
        // 2. Datos previos necesarios
        // ----------------------------------------------------------

        // Pricebook "Oficinas" (requerido por el helper)
        Pricebook2 oficinasPB = new Pricebook2(
            Name = 'Oficinas',
            IsActive = true
        );
        insert oficinasPB;

        // Maestro de precios del edificio
        OFI_obj_MaestroPrecioEdificio__c maestro = 
            new OFI_obj_MaestroPrecioEdificio__c(
                OFI_fld_MtroPrecioEdif_EdifExtId__c = 'EDIF001',
                OFI_fld_MtroPrecioEdif_PrecioCascoGris__c = 10,
                OFI_fld_MtroPrecioEdif_PrecioImplCen__c = 15,
                OFI_fld_MtroPrecioEdif_PrecioImplExCli__c = 20,
                OFI_fld_MtroPrecioEdif_EsPrecioFijo__c = false
            );
        insert maestro;

        // ----------------------------------------------------------
        // 3. Ejecución
        // ----------------------------------------------------------
        Test.startTest();

        List<OFI_ObjetoAlquilerObjectResponse_cls> resp =
            OFI_ObjetoAlquilerService_cls.getObjetosAlquiler('20251029');

        // Simulamos ejecución Batch (chunk pequeño)
        OFI_ObjetoAlquilerHelper_cls.processObjAlqChunk(resp);

        Test.stopTest();

        // ----------------------------------------------------------
        // 4. Validaciones (ASSERTS)
        // ----------------------------------------------------------

        // ✅ Proyecto creado
        Proyecto__c proyecto = [
            SELECT Id, Name, ONI_fld_Proyecto_EdificioExternalId__c
            FROM Proyecto__c
            WHERE ONI_fld_Proyecto_EdificioExternalId__c = 'EDIF001'
            LIMIT 1
        ];
        System.assertNotEquals(null, proyecto, 'El Proyecto debe existir');

        // ✅ Producto creado
        Product2 producto = [
            SELECT Id,
                   Name,
                   ONI_fld_Product2_ObjAlquilerCompuesto__c,
                   OFI_fld_Product2_BaseMedida__c,
                   CEN_Proyecto__c
            FROM Product2
            WHERE ONI_fld_Product2_ObjAlquilerCompuesto__c =
                  'SOC1|EDIF001|OBJ001'
            LIMIT 1
        ];
        System.assertNotEquals(null, producto, 'El Producto debe existir');
        System.assertEquals(
            50,
            producto.OFI_fld_Product2_BaseMedida__c,
            'La base de medida debe ser 50'
        );
        System.assertEquals(
            proyecto.Id,
            producto.CEN_Proyecto__c,
            'El producto debe estar relacionado al proyecto'
        );

        // ✅ PricebookEntries creados (Standard + Oficinas)
        List<PricebookEntry> pbes = [
            SELECT Id, Pricebook2Id, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id = :producto.Id
        ];
        System.assertEquals(
            2,
            pbes.size(),
            'Deben existir 2 PricebookEntry'
        );

        // Validar precio calculado
        Decimal expectedPrice = 50 * 10; // baseMedida * precioCascoGris
        for (PricebookEntry pbe : pbes) {
            System.assertEquals(
                expectedPrice,
                pbe.UnitPrice,
                'El precio calculado es incorrecto'
            );
        }
    }

    // ==============================================================
    // TEST DE SEGURIDAD – Lista vacía
    // ==============================================================
    @IsTest
    static void testProcessObjetoAlquiler_EmptyList() {

        Test.startTest();
        OFI_ObjetoAlquilerHelper_cls.processObjAlqChunk(
            new List<OFI_ObjetoAlquilerObjectResponse_cls>()
        );
        Test.stopTest();

        System.assert(true, 'No debe lanzar excepciones');
    }
}