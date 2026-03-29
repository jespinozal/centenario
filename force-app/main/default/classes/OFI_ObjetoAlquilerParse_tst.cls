@IsTest
private class OFI_ObjetoAlquilerParse_tst {

    // ==============================================================
    // TEST: parseRequest devuelve null
    // ==============================================================
    @IsTest
    static void testParseRequest() {

        OFI_ObjetoAlquilerParse_cls parser =
            new OFI_ObjetoAlquilerParse_cls();

        Object result = parser.parseRequest('{"fecha":"20260129"}');

        System.assertEquals(
            null,
            result,
            'parseRequest debe devolver null'
        );
    }

    // ==============================================================
    // TEST: Respuesta funcional SIN DATOS (codigo 311)
    // ==============================================================
    @IsTest
    static void testParseResponse_NoData_311() {

        String jsonResponse =
            '{' +
                '"tipo":"E",' +
                '"id":"ZACONS",' +
                '"codigo":311,' +
                '"mensaje":"No se encontraron datos"' +
            '}';

        OFI_ObjetoAlquilerParse_cls parser =
            new OFI_ObjetoAlquilerParse_cls();

        Object result = parser.parseResponse(jsonResponse);

        System.assert(
            result instanceof List<OFI_ObjetoAlquilerObjectResponse_cls>,
            'El resultado debe ser una lista'
        );

        List<OFI_ObjetoAlquilerObjectResponse_cls> data =
            (List<OFI_ObjetoAlquilerObjectResponse_cls>) result;

        System.assertEquals(
            0,
            data.size(),
            'La lista debe estar vacía cuando el código es 311'
        );
    }

    // ==============================================================
    // TEST: Respuesta NORMAL con datos (array JSON)
    // ==============================================================
    @IsTest
    static void testParseResponse_WithData() {

        String jsonResponse =
            '[' +
                '{' +
                    '"sociedad":"SOC1",' +
                    '"descSociedad":"Sociedad 1",' +
                    '"estado":"Libre",' +
                    '"clase":1,' +
                    '"descClase":"Oficina",' +
                    '"unidadEconomica":"UE1",' +
                    '"descUnidEco":"Unidad Economica 1",' +
                    '"edificio":"EDIF001",' +
                    '"descEdificio":"Edificio Test",' +
                    '"objetoAlquiler":"OBJ001",' +
                    '"descObjAlq":"Oficina 101",' +
                    '"responsable":"Usuario Test",' +
                    '"fecUltimaModif":"2025-10-29",' +
                    '"claseObjeto":"01",' +
                    '"descClaseObj":"Casco Gris",' +
                    '"piso":"1",' +
                    '"descPiso":"Primer Piso",' +
                    '"categoria":"OFI",' +
                    '"descCategoria":"Oficina",' +
                    '"medidas":[' +
                        '{' +
                            '"tipoMedicion":"MA02",' +
                            '"descTipmed":"Metros Cuadrados",' +
                            '"baseMedida":50.0,' +
                            '"um":"M2",' +
                            '"validoDe":"2025-01-01",' +
                            '"validoHasta":"2025-12-31"' +
                        '}' +
                    ']' +
                '}' +
            ']';

        OFI_ObjetoAlquilerParse_cls parser =
            new OFI_ObjetoAlquilerParse_cls();

        Object result = parser.parseResponse(jsonResponse);

        System.assert(
            result instanceof List<OFI_ObjetoAlquilerObjectResponse_cls>,
            'El resultado debe ser una lista'
        );

        List<OFI_ObjetoAlquilerObjectResponse_cls> data =
            (List<OFI_ObjetoAlquilerObjectResponse_cls>) result;

        System.assertEquals(
            1,
            data.size(),
            'Debe deserializar un elemento'
        );

        System.assertEquals(
            'SOC1',
            data[0].sociedad,
            'La sociedad debe coincidir'
        );
        System.assertEquals(
            'EDIF001',
            data[0].edificio,
            'El edificio debe coincidir'
        );
        System.assertEquals(
            50,
            data[0].medidas[0].baseMedida,
            'La base de medida debe ser 50'
        );
    }

    // ==============================================================
    // TEST: Respuesta inesperada → excepción
    // ==============================================================
    @IsTest
    static void testParseResponse_UnexpectedFormat() {

        String invalidResponse = '"esto no es ni array ni error"' ;

        OFI_ObjetoAlquilerParse_cls parser =
            new OFI_ObjetoAlquilerParse_cls();

        Boolean exceptionThrown = false;

        try {
            parser.parseResponse(invalidResponse);
        } catch (Exception ex) {
            exceptionThrown = true;
            System.assert(
                ex.getMessage().contains('Respuesta inesperada'),
                'El mensaje de error debe indicar respuesta inesperada'
            );
        }

        System.assertEquals(
            true,
            exceptionThrown,
            'Debe lanzarse una excepción para respuestas inválidas'
        );
    }
}