public with sharing class OFI_ObjetoAlquilerQueueable_cls
    implements Queueable, Database.AllowsCallouts {

    private String fecha;

    public OFI_ObjetoAlquilerQueueable_cls(String fecha) {
        this.fecha = fecha;
    }

    public void execute(QueueableContext qc) {
        OFI_ObjetoAlquilerService_cls.getObjetosAlquiler(fecha);
    }
}