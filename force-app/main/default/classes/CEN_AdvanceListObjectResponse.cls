public with sharing class CEN_AdvanceListObjectResponse {
    
    public ZTT_ANTICIPOS ET_ANTICIPOS;
    
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