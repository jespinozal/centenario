trigger ONI_trg_ContentVersion_ValidaArchivos on ContentVersion (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(Trigger.new);
    }
}