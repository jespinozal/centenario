/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 14-12-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   14-12-2023   @nttdata.com   Initial Version
**/
public with sharing class CEN_GestionCobranzaRequest {

    public ZRFC_GESTION_COBRANZA_WS_element ZRFC_GESTION_COBRANZA_WS;

    public class ZRFC_GESTION_COBRANZA_WS_element {
        public ZACCO_COBRANZA_CAMPOS IS_CAB_COBRANZA;
        public ZTT_COBRANZA_FILA IT_FILA_COBRANZA;
        public ZTT_SOCIOS_FILA IT_FILA_SOCIOS;
    }

    public class ZACCO_COBRANZA_CAMPOS {
        public String SOCIEDAD;
        public String PROFORMA;
        public String CODIGO_CLIENTE;
    }

    public class ZTT_COBRANZA_FILA {
        public ZACCO_COBRANZA_FILA[] item;
    }

    public class ZACCO_COBRANZA_FILA {
        public String NOMBRE_ASESOR_GESTION;
        public String FECHA_GESTION;
        public String HORA_GESTION;
        public String TIPO_GESTION;
        public String TIP_GESTION_CATEGORIA;
        public String TIP_GESTION_MOTIVO;
        public String TIP_GESTION_SUBMOTIVO;
        public String MOTIVO_NO_PAGO;
        public String MOTIVO_RESOLUCION;
        public String VIVE_LOTE;
        public String DERIVACION_POSTVENTA;
        public String DERIVACION_REPROGRAMACION;
        public String TIPO_ACUERDO;
        public String MONTO_ACUERDO;
        public String WAERS;
        public String FECHA_VENC;
        public String COMENTARIO_ACUERDO_PAGO;
        public String COMENTARIO_GESTION;
        public String FECHA_Y_HORA_GESTION;
        public String TELEFONO_CONTACTO;
        public String CORREO_CONTACTO;
        public String DIRECCION_CONTACTO;
        public String OTROS;
        public String RESPONSABLE_PAGO;
        public String PARENT_RESPONSABLE_PAGO;
        public String ANIO_GESTION;
        public String MES_GESTION;
        public String DERIVACION_POSTVENTA_RES_MES;
        public String INCUMP_ACUERDO_PAGO_MES;
        public String TIPO_CLIENTE;
    }

    public class ZTT_SOCIOS_FILA {
        public ZACCO_SOCIOS_FILA[] item;
    }

    public class ZACCO_SOCIOS_FILA {
        public String CODIGO_COPROPIETARIO;
    }
}