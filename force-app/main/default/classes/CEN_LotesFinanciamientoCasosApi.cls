/**
 * @description       : Clase con la estructura del servicio Financiamiento y Lotes, se usa en la clase CEN_LotesFinanciamientoCasos
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
public with sharing class CEN_LotesFinanciamientoCasosApi {
    
    @AuraEnabled 
    public List<FinanciamientoLote>     financiamientos;

    public class FinanciamientoLote{
        @AuraEnabled public Integer     proforma;                           //Financiamiento
        @AuraEnabled public Integer     version;                            //Versión
        @AuraEnabled public String      bukrs;                              //Sociedad
        @AuraEnabled public String      processo;                           //Proyecto
        @AuraEnabled public String      codprocesso;                        //Cod Proyecto
        @AuraEnabled public String      estadoFinanciamiento;               //Estado de Financiamiento
        @AuraEnabled public String      estadoFinanciamientoFormateado;     //Estado de Financiamiento
        @AuraEnabled public String      urbanizacion;                       //Urbanización
        @AuraEnabled public String      lotesConcatenados;                  //Lotes concatenados
        @AuraEnabled public List<lote>  lotes;
        @auraEnabled public String      idLog;

    }
    public class Lote{
        @AuraEnabled public Integer     idLoteSap;          //Id de Lote de SAP
        @AuraEnabled public String      codLote;            //Código de Material
        @AuraEnabled public String      nombreLote;         //Código de Material
        @AuraEnabled public String      idLote;             //Código de Material
        @AuraEnabled public Decimal     valor;              //Importe de Precio de Venta
        @AuraEnabled public String      valorFormateado;    //Importe de Precio de Venta Formateado
        @AuraEnabled public String      estadoLote;         //Estado
        @AuraEnabled public String      subestadoLote;      //Sub estado
        @AuraEnabled public String      manzana;            //Manzana
        @AuraEnabled public String      lote;               //Lote
    }
    /**
    * @description Método de conversión de String a objeto FinanciamientosWrapper
    * @author Richard Villafana - NTT DATA | 08-08-2024 
    * @param json 
    * @return FinanciamientosWrapper 
    **/
    public static CEN_LotesFinanciamientoCasosApi parse(String json) {
		return (CEN_LotesFinanciamientoCasosApi) System.JSON.deserialize(json, CEN_LotesFinanciamientoCasosApi.class);
	}
}