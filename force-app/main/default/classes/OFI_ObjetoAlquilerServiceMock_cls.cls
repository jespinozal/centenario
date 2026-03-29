@IsTest
global class OFI_ObjetoAlquilerServiceMock_cls implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        // JSON que matchea el DTO
        String body = '[{' +
            '"sociedad": "SOC1",' +
            '"descSociedad": "Sociedad 1",' +
            '"estado": "L",' +
            '"clase": 1,' +
            '"descClase": "Oficina",' +
            '"unidadEconomica": "UE1",' +
            '"descUnidEco": "Unidad Economica 1",' +
            '"edificio": "EDIF001",' +
            '"descEdificio": "Edificio de prueba",' +
            '"objetoAlquiler": "OBJ001",' +
            '"descObjAlq": "Oficina 101",' +
            '"responsable": "Usuario X",' +
            '"fecUltimaModif": "2025-10-29",' +
            '"claseObjeto": "01",' +
            '"descClaseObj": "Casco Gris",' +
            '"piso": "1",' +
            '"descPiso": "Primer Piso",' +
            '"categoria": "OFI",' +
            '"descCategoria": "Oficina",' +
            '"medidas": [{' +
                '"tipoMedicion": "MA02",' +
                '"descTipmed": "Metros Cuadrados",' +
                '"baseMedida": 50.0,' +
                '"um": "M2",' +
                '"validoDe": "2025-01-01",' +
                '"validoHasta": "2025-12-31"' +
                '}]' +
            '}]';
            res.setBody(body);
            return res;
        }
    }