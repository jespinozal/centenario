/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 06-03-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-03-2021   @everis.com   Initial Version
**/
public with sharing class CEN_AdvanceListObjectRequest {
    
    public ZRFC_OTC_LISTA_ANTICIPOS_WS_element ZRFC_OTC_LISTA_ANTICIPOS_WS;
    
    public class ZRFC_OTC_LISTA_ANTICIPOS_WS_element {
       // public ZTT_ANTICIPOS ET_ANTICIPOS;
        public String I_BUKRS;
        public String I_STCD1;
    }
    
    public class ZTT_ANTICIPOS {   
        public ZACCC_ANTICIPOS_ALV[] item;
    }
    
    public class ZACCC_ANTICIPOS_ALV {
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
        public String WRBTR;
        public String WAERS;
        public String DMBTR;
        public String BLDAT;
        public String BUDAT;
        public String BLART;
        public String LTEXT;
        public String KUNNR;
        public String PROFORMA;
        public String RESERVA;
    }
    
}