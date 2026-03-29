/********************************************************************* 
* @author: Jose Hernandez (jherncal@emeal.nttdata.com) 
* @date: 2022-10-27 
* @description: Clase Parse de evento call Api SAP - Campañas disponibles. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2022-10-27           Jose Hernandez          Creación 
*  
*********************************************************************/
public with sharing class CEN_CampanaObjectRequest {
 
    public ZRFC_OTC_CAMPANA_SF_WS_element ZRFC_OTC_CAMPANA_SF_WS;
 
    public class ZRFC_OTC_CAMPANA_SF_WS_element {
        public String COD_PALANCA;
        public ZTT_LOTE_DESCT IT_LOTE_DESCT;
        public String SOCIEDAD;       
    }
    
    public class ZTT_LOTE_DESCT {
        public ZACCO_LOTE_DESCT[] item;            
    }
    
    public class ZACCO_LOTE_DESCT {
            public String PROYECTO;
            public String COD_PROPIEDAD;           
    }        
}