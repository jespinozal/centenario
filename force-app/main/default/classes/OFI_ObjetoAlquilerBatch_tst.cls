@IsTest
private class OFI_ObjetoAlquilerBatch_tst {

    // ==============================================================
    // TEST PRINCIPAL – Ejecución completa del Batch
    // ==============================================================
    @IsTest
    static void testBatch_OK() {

        // ----------------------------------------------------------
        // 1. DATOS BASE NECESARIOS
        // ----------------------------------------------------------

        // Pricebook "Oficinas"
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
        // 2. DATASET SIMULADO (DTOs)
        // ----------------------------------------------------------
        List<OFI_ObjetoAlquilerObjectResponse_cls> data =
            buildMockResponses(50);

        // ----------------------------------------------------------
        // 3. EJECUCIÓN DEL BATCH
        // ----------------------------------------------------------
        Test.startTest();

        Database.executeBatch(
            new OFI_ObjetoAlquilerBatch_cls(data),
            data.size() // Chunk pequeño para asegurar heap bajo
        );

        Test.stopTest();

        // ----------------------------------------------------------
        // 4. ASSERTS
        // ----------------------------------------------------------

        // ✅ Proyecto creado
        Proyecto__c proyecto = [
            SELECT Id, Name, ONI_fld_Proyecto_EdificioExternalId__c
            FROM Proyecto__c
            WHERE ONI_fld_Proyecto_EdificioExternalId__c = 'EDIF001'
            LIMIT 1
        ];
        System.assertNotEquals(
            null,
            proyecto,
            'Debe existir el Proyecto'
        );

        // ✅ Productos creados
        List<Product2> productos = [
            SELECT Id, Name, ONI_fld_Product2_ObjAlquilerCompuesto__c
            FROM Product2
            WHERE ONI_fld_Product2_ObjAlquilerCompuesto__c
                  LIKE 'SOC1|EDIF001%'
        ];
        System.assertEquals(
            50,
            productos.size(),
            'Debe haber 50 productos'
        );

        // ✅ PricebookEntries creados
        List<PricebookEntry> pbes = [
            SELECT Id, Product2Id, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id IN :productos
        ];
        System.assertEquals(
            100,
            pbes.size(),
            'Deben existir 2 PBEs por producto'
        );
    }

    // ==============================================================
    // TEST DE SEGURIDAD – Lista vacía
    // ==============================================================
    @IsTest
    static void testBatch_EmptyList() {

        Test.startTest();
        Database.executeBatch(
            new OFI_ObjetoAlquilerBatch_cls(
                new List<OFI_ObjetoAlquilerObjectResponse_cls>()
            ),
            10
        );
        Test.stopTest();

        System.assert(true, 'No debe lanzar excepciones');
    }

    // ==============================================================
    // MÉTODO AUXILIAR – CREACIÓN DE DTOs SIMULADOS
    // ==============================================================
    private static List<OFI_ObjetoAlquilerObjectResponse_cls>
        buildMockResponses(Integer qty) {

        List<OFI_ObjetoAlquilerObjectResponse_cls> result =
            new List<OFI_ObjetoAlquilerObjectResponse_cls>();

        for (Integer i = 0; i < qty; i++) {
            OFI_ObjetoAlquilerObjectResponse_cls oa =
                new OFI_ObjetoAlquilerObjectResponse_cls();

            oa.sociedad = 'SOC1';
            oa.descSociedad = 'Sociedad 1';
            oa.estado = 'Libre';
            oa.clase = 1;
            oa.descClase = 'Oficina';
            oa.unidadEconomica = 'UE1';
            oa.descUnidEco = 'Unidad Economica 1';
            oa.edificio = 'EDIF001';
            oa.descEdificio = 'Edificio Test';
            oa.objetoAlquiler = 'OBJ' + i;
            oa.descObjAlq = 'Oficina ' + i;
            oa.responsable = 'Usuario Test';
            oa.fecUltimaModif = '2025-10-29';
            oa.claseObjeto = '01';
            oa.descClaseObj = 'Casco Gris';
            oa.piso = '1';
            oa.descPiso = 'Primer Piso';
            oa.categoria = 'OFI';
            oa.descCategoria = 'Oficina';

            OFI_ObjetoAlquilerObjectResponse_cls.Medida m =
                new OFI_ObjetoAlquilerObjectResponse_cls.Medida();
            m.tipoMedicion = 'MA02';
            m.descTipmed = 'Metros Cuadrados';
            m.baseMedida = 50;
            m.um = 'M2';
            m.validoDe = '2025-01-01';
            m.validoHasta = '2025-12-31';

            oa.medidas =
                new List<OFI_ObjetoAlquilerObjectResponse_cls.Medida>{ m };

            result.add(oa);
        }
        return result;
    }
}