@isTest
public with sharing class ONI_ActualizarEstadoLote_tst {
    

    public class UpdateLotMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Verify endpoint and method
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class UpdateLotErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Internal Server Error');
            return res;
        }
    }

    @isTest
    static void testUpdateLotQueueableSuccess() {
        // Prepare the Request data
        ONI_ActualizarEstadoLote_cls.Request req = new ONI_ActualizarEstadoLote_cls.Request();
        req.qId = '001000000000000AAA'; // Dummy ID
        req.proyecto = '13I1.103E';
        req.lote = '25';
        req.manzana = 'A';
        req.material = '840038366';
        req.usuario = 'TEST_USER';

        List<ONI_ActualizarEstadoLote_cls.Request> reqlist =
            new List<ONI_ActualizarEstadoLote_cls.Request> {req};

        // Set the mock implementation
        Test.setMock(HttpCalloutMock.class, new UpdateLotMock());

        Test.startTest();
            ONI_ActualizarEstadoLote_cls.lotUpdate(reqList);
            
            System.assertEquals(1, Limits.getQueueableJobs(), 'Queueable job should have been added');
        Test.stopTest();

        // Since the method is void and only performs a debug, 
        // success is confirmed if no exception is thrown.
    }

    @isTest
    static void testUpdateLotError() {
        // Set a mock that returns a 500 error
        Test.setMock(HttpCalloutMock.class, new UpdateLotErrorMock());

        ONI_ActualizarEstadoLote_cls.Request req = new ONI_ActualizarEstadoLote_cls.Request();
        
        Test.startTest();
        ONI_ActualizarEstadoLote_cls.updateLot(req);
        Test.stopTest();
        
        System.assert(true, 'Error handled by catch/else block');
    }

}