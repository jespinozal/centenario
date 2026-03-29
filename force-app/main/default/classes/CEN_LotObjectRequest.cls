/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 06-30-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-07-2021   @everis.com   Initial Version
**/
public with sharing class CEN_LotObjectRequest {
    
    Public String idProyectoSap;
    Public String tipoProyect;
    Public List<lot> lots;

    Public class lot{
        Public Boolean isActive;
        Public String codCliente;
        Public String costoAbitacionUrba;
        Public String costoMayorValor;
        Public String costoTerreno;
        Public String costoVenta;
        Public String codCompania;
        Public String codEstadoEntrega;
        Public String codEstadoLote;
        Public String codMonedaFuncional;
        Public String codLoteSap;
        Public String codSituacionLote;
        Public String descripcionCorta;
        Public String descripcionLote;
        Public String etapaLote;
        Public String fechaIngreso;
        Public String fechaIngresoNotaria;
        Public String fechaVenta;
        Public String idLotSap;	
        Public String linderoDerecha;
        Public String linderoFondo;
        Public String linderoFrente;
        Public String linderoIzquierda;
        Public String manzana;
        Public String medidaDerecha;
        Public String medidaFondo;
        Public String medidaFrente;
        Public String medidaIzquierda;
        Public String numeroFichaRegistral;
        Public String numeroKardex;
        Public String precioVenta;
        Public String productCode;
        Public String description;
        Public String name;
        Public String productSKU;
        Public String sector;
        Public Boolean tieneReserva;
        Public String tipoInmueble;
        Public String tipoLote;
        Public String tipologia;
        Public String urbanizacion;
        Public String usoInmueble;
        Public String zonificacion;
        Public Boolean eliminado;
        Public String areaLote;
    }
    
}