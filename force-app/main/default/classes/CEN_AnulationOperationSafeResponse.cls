/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 19-05-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
 **/
public class CEN_AnulationOperationSafeResponse {

    public class ZRFC_OTC_ANULAR_OPS_WSResponse {
        public ZTT_DOCUMENTOS_OTC ET_DOCUMENTOS;
        public BAPIRET2_T ET_RETURN;
        public String E_OK;
    }

    public class BAPIRET2_T {
        public BAPIRET2[] item;
    }

    public class ZTT_DOCUMENTOS_OTC {
        public ZST_DOCUMENTOS_OTC[] item;
    }

    public class BAPIRET2 {
        public String TYPE_x;
        public String ID;
        public String NUMBER_x;
        public String MESSAGE;
        public String LOG_NO;
        public String LOG_MSG_NO;
        public String MESSAGE_V1;
        public String MESSAGE_V2;
        public String MESSAGE_V3;
        public String MESSAGE_V4;
        public String PARAMETER;
        public Integer ROW;
        public String FIELD;
        public String SYSTEM_x;
    }

    public class ZST_DOCUMENTOS_OTC {
        public String PROFORMA;
        public String BUKRS_PAGO;
        public String BELNR_PAGO;
        public String GJAHR_PAGO;
        public String VIA_PAGO;
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
        public String IMPORTE;
        public String MONEDA;
        public String TIPO;
    }
}