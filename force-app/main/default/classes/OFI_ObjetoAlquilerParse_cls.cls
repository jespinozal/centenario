/**
* @author: Alfredo Morote (amorotet@nttdata.com) 
* @date: 29-10-2025
* @description: Parser para respuesta JSON de Objetos de Alquiler, implementa CEN_CalloutParser y devuelve OFI_ObjetoAlquilerObjectResponse_cls
* 
* VERSION      DATE                 AUTOR                     ACTION 
* 0.1          29-10-2025           Alfredo Morote            Creación 
*  
**/
public with sharing class OFI_ObjetoAlquilerParse_cls
    implements CEN_CalloutParser {

    public Object parseRequest(String obj) {
        return null;
    }

    public Object parseResponse(String responseBody) {

        // Normalizar body
        String body = responseBody != null ? responseBody.trim() : '';

        // ------------------------------------------------------
        // CASO 1: Respuesta funcional sin datos
        // ------------------------------------------------------
        if (body.startsWith('{') && body.contains('"codigo"')) {

            Map<String, Object> errorResp =
                (Map<String, Object>) JSON.deserializeUntyped(body);

            if (errorResp.containsKey('codigo')
                && String.valueOf(errorResp.get('codigo')) == '311') {

                // Caso esperado: no hay datos
                return new List<OFI_ObjetoAlquilerObjectResponse_cls>();
            }
        }

        // ------------------------------------------------------
        // CASO 2: Respuesta normal con datos (array)
        // ------------------------------------------------------
        if (body.startsWith('[')) {
            return (List<OFI_ObjetoAlquilerObjectResponse_cls>)
                JSON.deserialize(
                    body,
                    List<OFI_ObjetoAlquilerObjectResponse_cls>.class
                );
        }

        // ------------------------------------------------------
        // CASO 3: Respuesta inesperada
        // ------------------------------------------------------
        throw new CalloutException(
            'Respuesta inesperada del servicio: ' + body
        );
    }
}