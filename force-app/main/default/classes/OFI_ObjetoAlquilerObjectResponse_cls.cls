/**
 * @author: Alfredo Morote (amorotet@nttdata.com) 
 * @date:           29-10-2025
 * @description:    Clase wrapper para la respuesta del servicio Objeto Alquiler (estacionamiento, oficina, local comercial, sala, deposito)
 * 
 * VERSION      DATE                 AUTOR                     ACTION 
 * 0.1          29-10-2025           Alfredo Morote            Creación 
 **/
public with sharing class OFI_ObjetoAlquilerObjectResponse_cls {

    public String sociedad;
    public String descSociedad;
    public String estado;
    public Integer clase;
    public String descClase;
    public String unidadEconomica;
    public String descUnidEco;
    public String edificio;
    public String descEdificio;
    public String objetoAlquiler;
    public String descObjAlq;
    public String responsable;
    public String fecUltimaModif;
    public String claseObjeto;
    public String descClaseObj;
    public String piso;
    public String descPiso;
    public String categoria;
    public String descCategoria;
    public Medida[] medidas;

    public class Medida {
        public String tipoMedicion;
        public String descTipmed;
        public Decimal baseMedida;
        public String um;
        public String validoDe;
        public String validoHasta;
    }
}