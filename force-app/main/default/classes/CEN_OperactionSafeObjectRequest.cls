/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 05-30-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
 * 1.1   26-01-2026   Felipe Bermudez Se agrego el nuevo bloque a la respuesta del servicio IT_PERIODO escenarios de financiamiento
 **/
public class CEN_OperactionSafeObjectRequest {

    public FINANCIAMIENTO ZRFC_OTC_FINANCIAMIENTO_SF_WS;

    public class FINANCIAMIENTO {
      public ANTICIPOS IT_ANTICIPOS;
      public CUOTA_LIBRE_INICIAL IT_CUOTA_LIBRE_INICIAL;
      public INTERLOCUTORES IT_INTERLOCUTORES;
      public FILA IT_FILA;
      public MODIFICAR_PROFORMA IS_MODIFICAR_PROFORMA;
      public String I_PROCESO;
      public PROFORMA IS_CREAR_PROFORMA;
      public DEVOLUCION IS_REALIZAR_DEVOLUCION;
      public VIA_FINANCIAMIENTO IS_CAMBIAR_VIA_FINANCIAMIENTO;
      public PREPAGO_CAMPOS IS_PREPAGO_CAMPOS;
      public PALANCAS_FINALES IT_PALANCAS_FINALES;
      public TASAS_POLITVEN_FINAL IT_TASAS_POLITVEN_FINAL;

      public PERIODOS IT_PERIODO; 
    }
    public class PERIODOS {
      public PERIODOS_ITEM[] item; 
    }

    public class PERIODOS_ITEM{
      public String SALDO_NO_CUOTAS; 
    }

    public class ANTICIPOS {
      public ANTICIPOS_ITEM[] item;
    }

    public class ANTICIPOS_ITEM {
      public String BUKRS;
      public String BELNR;
      public String GJAHR;
    }

    public class CUOTA_LIBRE_INICIAL {
      public CUOTA_LIBRE_INICIAL_ITEM[] item;
    }

    public class CUOTA_LIBRE_INICIAL_ITEM {
      public Integer CUOTA;
      public String AMORTIZACION;
      public String WAERS;
    }

    public class INTERLOCUTORES {
      public INTERLOCUTORES_ITEM[] item;
    }

    public class INTERLOCUTORES_ITEM {
      public String IND_INTERLOCUTOR;
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
    }

    public class FILA {
      public FILA_ITEM[] item;
    }

    public class FILA_ITEM {
      public String BUKRS;
      public String PROCESSO;
      public String COD_PROPIEDAD;
      public String IND_ELIMINAR_PROD;
      public String DESCUENTO_OPS;
      public String MONEDA_DESCUENTO;
      public String PRECIO_VENTA;
    }

    public class MODIFICAR_PROFORMA {
      public String IND_MODF_PROFORMA;
      public String IND_ADMINISTRAR_PRODUCTOS;
      public Integer PROFORMA;
      public String DIAS_PAGO;
      public String MOTIVO_COMPRA;
      public String APODERADO_CENTENARIO1;
      public String APODERADO_CENTENARIO2;
      public String MEDIO;
      public String ZONA_VENTA;
      public String CONVERSION_ARRAS;
      public String MONEDA_PROFORMA;
      public String IMPORTE_CI_CHAR;
      public Integer SALDO_NO_CUOTAS;
      public Integer CUOTA_INIC_NO_CUOTAS;
      public String IND_FINAN_CI;
      public String INTERESES_CI;
      public String FACILOTE_IND_CI;
      public String PROMOTOR;
      public String FECHA_VEN_OPS;
      public String GUARDAR_MONTO;
      public String IMPORTE_OCD;
      public String IMP_CUOTA_LIBRE_INICIAL;
      public String IND_IMP_CUOTA_LIBRE;
      public Integer NO_CUOTAS_TOT_SI;
      public String OPCION_FECHA;
      public String FECHA_VENC_CS;
    }

    public class PROFORMA {
      public String BUKRS;
      public String PROCESSO;
      public String DIAS_PAGO;
      public String MOTIVO_COMPRA;
      public String APODERADO_CENTENARIO1;
      public String APODERADO_CENTENARIO2;
      public String MEDIO;
      public String ZONA_VENTA;
      public String CONVERSION_ARRAS;
      public String MONEDA_PROFORMA;
      public String IMPORTE_CI_CHAR;
      public String STCD1;
      public String VIA_FINANCIAMIENTO;
      public Integer SALDO_NO_CUOTAS;
      public Integer CUOTA_INIC_NO_CUOTAS;
      public String IND_FINAN_CI;
      public String INTERESES_CI;
      public String FACILOTE_IND_CI;
      public String PROMOTOR;
      public String IMPORTE_OCD;
      public String SUPERV_VENTA;
      public String SUPERV_ASIGNADO;
      public String IMP_CUOTA_LIBRE_INICIAL;
      public String IND_IMP_CUOTA_LIBRE;
      public Integer NO_CUOTAS_TOT_SI;
      public String OPCION_FECHA;
      public String FECHA_VENC_CS;

      public String TIPO_PERIODO; //Felipe
    }

    public class DEVOLUCION {
      public String REALIZAR_DEVOLUCION;
      public String BANCO;
      public String CUENTA_BANCARIA;
      public String CUENTA_INTERBANCARIA;
    }

    public class VIA_FINANCIAMIENTO {
      public String IND_MODF_PROFORMA;
      public String IND_ADMINISTRAR_PRODUCTOS;
      public Integer PROFORMA;
      public String BUKRS;
      public String PROCESSO;
      public String DIAS_PAGO;
      public String MOTIVO_COMPRA;
      public String APODERADO_CENTENARIO1;
      public String APODERADO_CENTENARIO2;
      public String MEDIO;
      public String ZONA_VENTA;
      public String CONVERSION_ARRAS;
      public String MONEDA_PROFORMA;
      public String IMPORTE_CI_CHAR;
      public String STCD1;
      public String VIA_FINANCIAMIENTO;
      public Integer SALDO_NO_CUOTAS;
      public Integer CUOTA_INIC_NO_CUOTAS;
      public String IND_FINAN_CI;
      public String INTERESES_CI;
      public String FACILOTE_IND_CI;
      public String PROMOTOR;
      public String IMPORTE_OCD;
      public Integer NO_CUOTAS_TOT_SI;
      public String OPCION_FECHA;
      public String FECHA_VENC_CS;
    }

    public class PREPAGO_CAMPOS {
      public String MANTENER_CUOTA;
      public String DISMINUIR_CUOTA;
      public String SALDO_INICIAL_PREPAGO;
      public Integer SALDO_NO_CUOTAS_PREPAGO;
      public String FECHA_PREPAGO;
      public String PROFORMA;
    }

    public class PALANCAS_FINALES {
      public PALANCAS_FINALES_ITEM[] item;
    }

    public class PALANCAS_FINALES_ITEM {
      public String COD_PALANCA;
      public String COD_PROMOCION;
      public String PORCENTAJE;
      public String IMPORTE;
      public String MONEDA;
      public String APROBADOR;
      public String FECHA;
      public String HORA;
    }

    public class  TASAS_POLITVEN_FINAL{
      public TASAS_POLITVEN_FINAL_ITEM[] item;
    }

    public class TASAS_POLITVEN_FINAL_ITEM {
      public String COD_TASA;
      public String TASA;
      public String USUARIO;
      public String FECHA;
      public String HORA;
    }

}