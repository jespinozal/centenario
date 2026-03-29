/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-22 
* @description: Clase Request - Crear Cliente SAP. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-22           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_CreateClientRequest {
    
    public ZRFC_OTC_CREAR_CLIENTES_WS_element ZMF_CREAR_CLIENTE;
    
    public class ZRFC_OTC_CREAR_CLIENTES_WS_element {
        public ZTT_CREAR_CLIENTE IT_DATOS_CLIENTE;
    }
    
    public class ZTT_CREAR_CLIENTE {
        public ZWS_CREAR_CLIENTE[] item;
    }
    
    public class ZWS_CREAR_CLIENTE {
        public String SOCIEDAD;
        public String TIPO_IDENTIF;
        public String NIF;
        public String APEL_CONTACTO;
        public String PERS_CONTACTO;
        public String ZZVENDEDOR;
        public String ZZMEDIO;
        public String ZZZONAVENTA;
        public String ZZPAIS;
        public String ZZDEPARTAMENTO;
        public String ZZPROVINCIA;
        public String ZZDISTRITO;
        public String DIRECCION;
        public String DIRECCION1;
        public String DIRECCION2;
        public String TELEF_FIJO;
        public String TELEF_MOVIL;
        public String MAIL;

        public String COMENTARIOS;
        public String NACIONALIDAD;
        public String LUGARNACIM;
        public String PAISRESIDENCIA;

        public String DEPENDIENTE;
        public String INDEPENDIENTE;

        public String ESTADO_CIVIL;
        public String PROFESION;
        public String CENTRO_TRABAJO;
        public String JEFE_DIRECTO;
        public String CARGO_ACTUAL;
        public String DETALLE_ACT;
        public String DIREC_CTRABAJO;
        public String DEPARTAMENTO;
        public String PROVINCIA;
        public String DISTRITO;
        public String FECH_NACIMIENTO;
        public String TELEF_CTRABAJO;
        public String WAERS;
        public String INGRESO_SOLICITANTE;
        public String NOMBREAPO;
        public String APEPATAPO;
        public String APEMATAPO;
        public String TIPODOCAPO;
        public String NUMDOCAPO;
        public String NACAPO;
        public String TIPOPODER;
        public String NRO_PARTIDA_REGISTRAL;
        public String DIRECCAPO;


    }
}