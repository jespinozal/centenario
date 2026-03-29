public class CEN_FinancingObjectRequest {
    public ZRFC_OTC_MODIF_DATOS_FINANC_WS_element ZRFC_OTC_MODIF_DATOS_FINANC_WS;

    public class ZRFC_OTC_MODIF_DATOS_FINANC_WS_element {
        public ZACCO_MODIF_DATOS_FINANCIAMIEN IS_MODIF_DATOS_FINANCIAMIENTO;
        public ZACCO_MODIF_DATOS_FINANCIAMIEX IS_MODIF_DATOS_FINANCIAMIENTOX;
        public ZTT_PROFORMA IT_PROFORMA;
    }

    public class ZPROFORMA_S {
        public String PROFORMA;
    }

    public class ZTT_PROFORMA {
        public ZPROFORMA_S[] item;
    }

    public class ZACCO_MODIF_DATOS_FINANCIAMIEX {
        public String NOMBRE_NOTARIO;
        public String LOCAL_REGISTRO;
        public String NUMERO_KARDEX;
        public String FECHA_ENTREGA_FISICA;
        public String NO_PARTIDA;
    }

    public class ZACCO_MODIF_DATOS_FINANCIAMIEN {
        public String NOMBRE_NOTARIO;
        public String LOCAL_REGISTRO;
        public String NUMERO_KARDEX;
        public String FECHA_ENTREGA_FISICA;
        public String NO_PARTIDA;
    }
}