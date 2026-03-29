public with sharing class ONI_ActualizarEstadoLote_cls {
    @InvocableMethod(label='Actualizar Estado Lote' description='Actualizar Estado Lote')
    public static List<Id> lotUpdate(List<Request> requestList) {
        Request req = requestList[0]; // Accepts one name
        System.debug(req);
        System.enqueueJob(new UpdateLotQueueable(req));
        
        return new List<Id>{};
        
    }

    public class UpdateLotQueueable implements Queueable, Database.AllowsCallouts {
        private Request req;

        public UpdateLotQueueable(Request req) {
            this.req = req;
        }

        public void execute(QueueableContext context) {
            updateLot(req);
        }
    }

    public static void updateLot(Request req){
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        
        // Reemplaza con tu URL real y configura el Named Credential
        request.setEndpoint('callout:OFI_nc_SAPOficinaWs/sap/bc/rest/zws_cvtas_indus');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        InputData iData = new InputData();
        iData.anulacion='';
        iData.codCotizInd=req.qId;
        iData.estadoLote='Q';
        iData.proyecto=req.proyecto;
        iData.lote=req.lote;
        iData.manzana=req.manzana;
        iData.material=req.material;
        iData.subestadoLote='CI';
        iData.anulacion='';
        iData.usuario=req.usuario;
        iData.fechaCreacion=DateTime.now().format('dd.MM.yyyy');
        iData.horaCreacion=DateTime.now().format('HH:mm:ss');
        System.debug('recueestttt >>' + iData);
        request.setBody(JSON.serialize(new Map<String,Object>{
            'input'=>new List<InputData>{iData}
        }));

        try {
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                System.debug('responseee >>' + response.getBody());
            } else {
                System.debug('Error en la respuesta: ' + response.getStatus());
                
            }
        } catch (Exception e) {
            System.debug('Excepción durante la llamada: ' + e.getMessage());
            
        }
    }
    
    public class Request{
        @InvocableVariable
        public Id qId;
        @InvocableVariable
        public String proyecto;
        @InvocableVariable
        public String lote;
        @InvocableVariable
        public String manzana;
        @InvocableVariable
        public String material;
        @InvocableVariable
        public String usuario;
        
    }

    public class InputData {
        public String codCotizInd;    // 0Q0Em000007dJBdKAM
        public String proyecto;       // 13I1.103E
        public String lote;           // 25
        public String manzana;        // A
        public String material;       // 840038366
        public String estadoLote;     // Q
        public String subestadoLote;  // CI
        public String anulacion;      // 
        public String usuario;        // INDRA_QAS
        public String fechaCreacion;  // 06.01.2026
        public String horaCreacion;   // 16:45:00
    }
}