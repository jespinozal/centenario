/********************************************************************* 
* @author: Jose Hernandez (jherncal@emeal.nttdata.com) 
* @date: 2022-10-27 
* @description: Clase Parse de evento call Api SAP - Campañas disponibles. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2022-10-27           Jose Hernandez          Creación 
*  
*********************************************************************/
public with sharing class CEN_CampanaObjectResponse {
    public ZTT_DETALLE_PALANCA_CAMP DETALLE_CAMPANA;

    public class ZTT_DETALLE_PALANCA_CAMP {
        public ZACCO_DETALLE_PALANCA[] item;
        
    }
    
    public class ZACCO_DETALLE_PALANCA {
        public String COD_CAMPANA;
        public String NOM_CAMPANA;
        public String NIVEL;
        public String MOTIVO_CAMPANA;
        public String PALANCA_PRINCIPAL;
        public String INICIO_VIGENCIA;
        public String FIN_VIGENCIA;
        public String PORCENTAJE_DESCUENTO;
        public String IMPORTE;
        public String MONEDA;
        public String SUSTENTO;
        public String SOCIEDAD;
        public String PROYECTO;
        
    }

}