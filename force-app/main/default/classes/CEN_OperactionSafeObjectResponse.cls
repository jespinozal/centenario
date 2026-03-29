/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 04-15-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-12-2021   @everis.com   Initial Version
 * 1.1   26-01-2026   Felipe Bermudez Se agrego el nuevo bloque a la respuesta del servicio ET_CUOTAS_SIMU_PROF escenarios de financiamiento
**/
public with sharing class CEN_OperactionSafeObjectResponse {

    public DATOS_PREPAGO ES_DATOS_PREPAGO;
    public CUOTAS IT_CUOTAS_PREPAGO;
    public DETALLE_DSCTO_ADICIONAL ET_DETALLE_DSCTO_ADICIONAL;
    public DETALLE_PALANCAS ET_DETALLE_PALANCAS;
    public MENSAJE_DSCTO_PALANCAS ET_MENSAJE_DSCTO_PALANCAS;
    public BAPIRET2_T ET_RETURN;
    public PROFORMA E_CAB_PROFORMA_SF;
    public String E_OPERACION_SEGURA;
    public CUOTAS ET_CUOTAS_PROFORMA_SF;
    public TASAS ET_TASAS_POLITVEN;

    public PERIODOS ET_CUOTAS_SIMU_PROF; 

    public class PERIODOS{
        public PERIODOS_ITEM[] item;
    }
    public class PERIODOS_ITEM {
        public String TIPO_PERIODO;
        public String SALDO_NO_CUOTAS;
        public String IMP_CUOTA_1_CS;
        public String IMP_CUOTA;
        public String IND_FINAN_CI;
        public String TASA_ANUAL_INTERES_FINAN;
        public String IND_ERROR;
        public String MENSAJE_ERROR;
    }
    
    public class TASAS {
        public TASAS_ITEM[] item;
    }

    public class TASAS_ITEM {
        public String BUKRS;
        public String CODIGO_PROJ;
        public String FECHA_INICIO;
        public String COD_TASA;
        public String TASA;
        public String DESCRIPCION;
        public String CASH_FIRMA_MIN_x_x25;
        public String CASH_FIRMA_MAX_x_x25;
        public String FRACCIONAMIENTO;
        public String TIEMPO_FINAN_MIN;
        public String TIEMPO_FINAN_MAX;
        public String UNI_MED_TIEMPO;
    }

    public class CUOTAS {
        public CUOTAS_ITEM[] item;
    }

    public class CUOTAS_ITEM {
        public String TIPO_CUOTA;
        public String CUOTA;
        public String NO_DIAS;
        public String NO_DIAS_ACU;
        public String SALDO_INICIAL;
        public String AMORTIZACION;
        public String INTERESES;
        public String GASTOS;
        public String INTERES_GASTOS;
        public String DESEMPLEO;
        public String SEGURO_VIDA;
        public String IMP_CUOTA;
        public String WAERS;
        public String NO_MOD;
        public String SALDO_FINAL;
        public String FECHA_VENCIMIENTO;
        public String PORCENTAJE;
        public String MLSTN;
        public String BUKRS;
        public String BELNR;
        public String GJAHR;
    }

    public class BAPIRET2_T {
        public BAPIRET2[] item;
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
        public String ROW;
        public String FIELD;
        public String SYSTEM_x;
    }

    public class PROFORMA {
        public String PROFORMA;
        public String VERSION;
        public String PROFORMA_ANT;
        public String PROCESSO;
        public String COD_PROPIEDAD;
        public String COD_MINUTA;
        public String PROPIEDADES;
        public String BUKRS;
        public String TIPO_PROFORMA;
        public String VBELN;
        public String POSID;
        public String POSNR;
        public String WAERS;
        public String PRECIO;
        public String KUNNR;
        public String TIP_CLI_CONT;
        public String CUOTA_MINIMA;
        public String CUOTA_INIC_IMP;
        public String CUOTA_INIC_POR;
        public String CUOTA_INIC_NO_CUOTAS;
        public String CUOTA_INIC_MIN;
        public String CUOTA_INIC_MAX;
        public String CUOTA_INIC_INTERES;
        public String CUOTA_INIC_INTGAS;
        public String CUOTA_INIC_NO_CUOTAS_MIN;
        public String CUOTA_INIC_NO_CUOTAS_MAX;
        public String SALDO_NO_CUOTAS;
        public String SALDO_NO_CUOTAS_MAX;
        public String SALDO_INTERESES;
        public String SALDO_INTGAS;
        public String CUOTA_INIC_IMP_R;
        public String PROMOTOR;
        public String FECHA_INICIO;
        public String VIA_FINANCIAMIENTO;
        public String CASH;
        public String CASH_BLDAT;
        public String CHECK_ENTREGA;
        public String TELEMARKETING;
        public String FIRMA_MECANIZ;
        public String STATUS_INICIAL;
        public String BFH;
        public String FECHA_ENT_PROY;
        public String IND_FINAN_CI;
        public String FACILOTE_IND_CI;
        public String COTIZACION_PROFORMA;
        public String DIAS_PAGO;
        public String INTERESES_CI;
        public String IMPORTE_RESERVA;
        public String ZZZONAVENTA;
        public String MEDIO;
        public String CANAL;
        public String ETI_CLI_CONTA;
        public String ETI_MEDIO;
        public String ETI_ZONA;
        public String ETI_PROMOTOR;
        public String ETI_APO1;
        public String ETI_APO2;
        public String IMPORTE_SALDO_PRECIO;
        public String TASA_MANUAL_IND;
        public String TASA_ANUAL_INTERES_FINAN;
        public String TASA_ANUAL_GASTOS_ADMIN;
        public String TASA_MENSUAL_INTERES_FINAN;
        public String TASA_MENSUAL_GASTOS_ADMIN;
        public String COSTO_TOTAL_MENSUAL;
        public String COSTO_TOTAL_ANUAL;
        public String PERFIL_COBRAN;
        public String PERIODO_DIAS;
        public String IMPORTE_CUOTA;
        public String CANTIDAD_LOTES;
        public String AREA_VENDIBLE;
        public String APODERADO_CENTENARIO1;
        public String APODERADO_CENTENARIO2;
        public String DIAS_ADICIONALES;
        public String PRECIO_ORIGINAL;
        public String TIPO_CAMBIO;
        public String INTERLOCUTOR1;
        public String INTERLOCUTOR2;
        public String INTERLOCUTOR3;
        public String INTERLOCUTOR4;
        public String INTERLOCUTOR5;
        public String INTERLOCUTOR6;
        public String INTERLOCUTOR7;
        public String INTERLOCUTOR8;
        public String INTERLOCUTOR9;
        public String INTERLOCUTOR10;
        public String APODERADO1;
        public String APODERADO2;
        public String MOTIVO_COMPRA;
        public String IMPORTE_CI_CHAR;
        public String IND_PORCENTAJE;
        public String ENTREGA;
        public String FECHA_ENTREGA;
        public String CONVERSION_ARRAS;
    }

    public class DATOS_PREPAGO{
        public String MONTO_AHORRO;
    }

    public class DETALLE_DSCTO_ADICIONAL {
        public DETALLE_DSCTO_ADICIONAL_ITEM[] item;
    }

    public class DETALLE_DSCTO_ADICIONAL_ITEM {
        public String COD_PALANCA;
        public String DESC_PALANCA ;
        public String COD_PROMOCION;
        public String DESC_DESCUENTO;
        public Integer NIVEL_LIBERACION;
        public String PORCEN_MAX_DESCUENTO;
        public String IMPORTE_MAX_DESCUENTO;
        public String MONEDA;
        public String APROBADOR;
    }

    public class MENSAJE_DSCTO_PALANCAS {
        public MENSAJE_DSCTO_PALANCAS_ITEM[] item;
    }

    public class MENSAJE_DSCTO_PALANCAS_ITEM {
        public String COD_MENSAJE;
        public String DETALLE;
        public String PALANCA;
        public String PORCEN_DESCUENTO;
        public String IMPORTE_DESCUENTO;
        public String MONEDA;
    }

    public class DETALLE_PALANCAS {
        public DETALLE_PALANCAS_ITEM[] item;
    }

    public class DETALLE_PALANCAS_ITEM {
        public String LLAVE;
        public Boolean MARCADO;
        public Integer QUANTITY;
        public String COD_PALANCA;
        public String DESC_PALANCA;
        public String COD_PROMOCION;
        public String DESC_DESCUENTO;
        public String PORCEN_DESCUENTO;
        public String IMPORTE_DESCUENTO;
        public String MONEDA;
        public String OBLIGATORIO;
        public String SUSTENTO;
        public String PRIORIDAD;
        public String APLICA;
        public String MOTIVO;
    }
}