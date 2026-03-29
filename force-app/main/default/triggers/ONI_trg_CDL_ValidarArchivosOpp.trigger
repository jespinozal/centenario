trigger ONI_trg_CDL_ValidarArchivosOpp on ContentDocumentLink (after insert, after delete) {
    /*
    Detecta cuando se crea o elimina un registro en el objeto ContentDocumentLink, almacenando las Opp relacionadas al mismo
    Posteriormente, delega la validación de archivos para tener el campo de checkbox actualizado
    */
    Set<Id> idsOportunidades = new Set<Id>();
    public static final String PREFIJO_OPPORTUNITY = Opportunity.SObjectType.getDescribe().getKeyPrefix();
    if (Trigger.isInsert) {
        for (ContentDocumentLink enlace : Trigger.new) {
            if (enlace.LinkedEntityId != null && String.valueOf(enlace.LinkedEntityId).startsWith(PREFIJO_OPPORTUNITY)) {
                idsOportunidades.add(enlace.LinkedEntityId);
            }
        }
    }

    if (Trigger.isDelete) {
        for (ContentDocumentLink enlace : Trigger.old) {
            if (enlace.LinkedEntityId != null && String.valueOf(enlace.LinkedEntityId).startsWith(PREFIJO_OPPORTUNITY)) {
                idsOportunidades.add(enlace.LinkedEntityId);
            }
        }
    }

    if (!idsOportunidades.isEmpty()) {
        ONI_ValidadorArchivosOportunidad_cls.validarOportunidades(idsOportunidades);
    }
}