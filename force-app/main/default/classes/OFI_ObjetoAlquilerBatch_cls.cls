public with sharing class OFI_ObjetoAlquilerBatch_cls
    implements Database.Batchable<OFI_ObjetoAlquilerObjectResponse_cls> {

    private List<OFI_ObjetoAlquilerObjectResponse_cls> source;

    public OFI_ObjetoAlquilerBatch_cls(
        List<OFI_ObjetoAlquilerObjectResponse_cls> source
    ) {
        this.source = source;
    }

    public Iterable<OFI_ObjetoAlquilerObjectResponse_cls> start(
        Database.BatchableContext bc
    ) {
        return source;
    }

    public void execute(
        Database.BatchableContext bc,
        List<OFI_ObjetoAlquilerObjectResponse_cls> scope
    ) {
        OFI_ObjetoAlquilerHelper_cls.processObjAlqChunk(scope);
    }

    public void finish(Database.BatchableContext bc) {
        // logging o notificación opcional
    }
}