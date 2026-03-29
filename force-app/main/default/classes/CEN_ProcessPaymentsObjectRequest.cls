/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-14-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
**/

public class CEN_ProcessPaymentsObjectRequest {
   
    public CAJA_AUTO ZRFC_OTC_CAJA_AUTO_WS;

    public class CAJA_AUTO {
        public ABONO_CTA IT_ABCU;
        public ANTICIPOS IT_ANTICIPOS;
        public EFECTIVO IT_EFECTIVO;
        public PAGO_ELECTRONICO IT_PAGO_ELECTRONICO;
        public TARJETA IT_TARJETA;
        public String I_BUKRS;
        public String I_CAJA;
        public Integer I_CUOTA;
        public String I_MONEDA_PROFORMA;
        public String I_PAGO_EXTRANJERO;
        public String I_STCD1;
        public String I_PROFORMA;
        public String I_VIA_PAGO;
        public String I_TIPO_PAGO;
        public IS_PAGO_OTRA_SOCIEDAD IS_PAGO_OTRA_SOCIEDAD; //SUBIRLO EN TRASLADO DE ABONOS
        
    }

    //SUBIRLO EN TRASLADO DE ABONOS
    public class IS_PAGO_OTRA_SOCIEDAD{
        public String PAG_OTRA_SOC;
        public String SOCIEDAD;
    }

    public class ABONO_CTA {
        public ABONO_CTA_ITEM[] item;
    }

    public class ABONO_CTA_ITEM {
        public String OPE_NUMERO;
        public String OPE_IMPORTE;
        public String OPE_FECHA;
        public String BNKN2;
        public String FECCON;
        public String MONEDA_PAGO;
    }

    public class ANTICIPOS {
        public ANTICIPOS_ITEM[] item;
    }

    public class ANTICIPOS_ITEM {
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
        public String WRBTR;
        //public String VIA_PAGO;
    }

    public class EFECTIVO {
        public EFECTIVO_ITEM[] item;
    }

    public class EFECTIVO_ITEM {
        public String IMPORTE;
        public String MONEDA_PAGO;
    }

    public class PAGO_ELECTRONICO {
        public PAGO_ELECTRONICO_ITEM[] item;
    }

    public class PAGO_ELECTRONICO_ITEM {
        public String IMPORTE;
        public String FECHA_PAGO_ESTIM;
        public String MONEDA_PAGO;
    }

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
        public String MONEDA_PAGO;
        public String DESCRIPCION_BANCO;
    }
}