/**
 * @author: Alfredo Morote (amorotet@nttdata.com) 
 * @date:           29-10-2025
 * @description:    Clase de solicitud para el servicio de Objeto de Alquiler
 *
 * VERSION      DATE                 AUTOR                   ACTION 
 * 0.1          29-10-2025           Alfredo Morote          Creación 
 **/
public with sharing class OFI_ObjetoAlquilerObjectRequest_cls {
    public String fecha; // Parametro de entrada para la solicitud
    public OFI_ObjetoAlquilerObjectRequest_cls(String fecha) {
        this.fecha = fecha;
    }
}