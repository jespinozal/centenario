@IsTest
global class OFI_ObjetoAlquilerServiceMock_311_cls
    implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        String body =
            '{' +
                '"tipo":"E",' +
                '"id":"ZACONS",' +
                '"codigo":311,' +
                '"mensaje":"No se encontraron datos"' +
            '}';

        res.setBody(body);
        return res;
    }
}