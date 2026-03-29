/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-05-25 
* @description: Clase Request - Recaudadora. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-05-25           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_GathererRequest {
    
    public ZRFC_OTC_PROCESAR_PAGO_WS_element ZRFC_OTC_PROCESAR_PAGO_WS;
    
    public class ZRFC_OTC_PROCESAR_PAGO_WS_element {
        public ZATT_PAGO_RECAU IT_IMPORTE;
        public String I_IMPORTE;
    }
    
    public class ZATT_PAGO_RECAU {
        public ZWS_PAGO_RECAU[] item;
    }
    
    public class ZWS_PAGO_RECAU {
        public String CODIGO;
        public Integer CORREL;
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
        public String PROFORMA;
        public String UNAME;
        public String SUPERVISOR;
        public String FECHA_RECOJO;
        public String UNAME_ARQUEO;
        public String UNAME_APROBAR;
    }
    
}