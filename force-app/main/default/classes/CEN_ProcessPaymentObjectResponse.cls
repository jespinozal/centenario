/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 04-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
**/

public with sharing class CEN_ProcessPaymentObjectResponse {
    //public class ZRFC_OTC_CAJA_AUTO_WSResponse_element {
        public String BELNR_ANTI;
        public String BUKRS_ANTI;
        //public ABONO_CTA ET_ABCU;
        //public ANTICIPOS ET_ANTICIPOS;
        //public EFECTIVO ET_EFECTIVO;
        public PAGOS_CLIENTE ET_PAGOS_CLIENTE;
        public BAPIRET2 ET_RETURN;
        //public TARJETA ET_TARJETA;
        public String E_OK;
        public String GJAHR_ANTI;
    //}

    /*
    public class ABONO_CTA {
        public ABONO_CTA_ITEM[] item;
    }

    public class ABONO_CTA_ITEM {
        public String OPE_NUMERO;
        public String OPE_IMPORTE;
        public String OPE_FECHA;
        public String BNKN2;
        public String FECCON;
    }

    public class ANTICIPOS {
        public ANTICIPOS_ITEM[] item;
    }

    public class ANTICIPOS_ITEM {
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
    }

    public class EFECTIVO {
        public EFECTIVO_ITEM[] item;
    }

    public class EFECTIVO_ITEM {
        public String IMPORTE;
    }
    */

    public class PAGOS_CLIENTE {
        public PAGOS_CLIENTE_ITEM[] item;
    }

    public class PAGOS_CLIENTE_ITEM {
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
        public String WRBTR;
    }

    public class BAPIRET2 {
        public BAPIRET2_ITEM[] item;
    }

    public class BAPIRET2_ITEM {
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

    /*
    public class TARJETA {
        public TARJETA_ITEM[] item;
    }

    public class TARJETA_ITEM {
        public String NRO_CHEQUE;
        public String REFERENCIA;
        public String OPE_IMPORTE;
        public String OPE_FECHA;
        public String PAIS_BANCO;
        public String CLAVE_BANC;
    }
    */
}