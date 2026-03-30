trigger CEN_trg_AdjuntoRelacionadoOpportunity on ContentDocumentLink (after insert) {
    IND_AdjuntoRelacionadoOpportunity_cls.validarYCrearAdjuntoRelacionado(Trigger.new);
}