public class CEN_ModifyClientObjectRequest {
   
    public ZRFC_OTC_MODIF_DATOS_CLIENTE_element ZRFC_OTC_MODIF_DATOS_CLIENTE;

    public class ZRFC_OTC_MODIF_DATOS_CLIENTE_element {
        public ZACCO_MODIF_DATOS_CLIENTE IS_MODIF_DATOS_CLIENTE;
        public ZACCO_MODIF_DATOS_CLIENTEX IS_MODIF_DATOS_CLIENTEX;
        public String I_CLIENTE;
        public String I_SOCIEDAD;
    }

    public class ZACCO_MODIF_DATOS_CLIENTE {
        public String TRATAMIENTO;
        public String NOMBRES;
        public String APELLIDOS;
        public String FECHA_NACIMIENTO;
        public String ESTADO_CIVIL;
        public String NACIONALIDAD;
        public String LUGAR_NACIMIENTO;
        public String DIRECCION;
        public String REFERENCIA;
        public String DISTRITO;
        public String PROVINCIA;
        public String DEPARTAMENTO;
        public String TELEFONO_FIJO;
        public String TELEFONO_MOVIL;
        public String EMAIL;
    }

    public class ZACCO_MODIF_DATOS_CLIENTEX {
        public String TRATAMIENTO;
        public String NOMBRES;
        public String APELLIDOS;
        public String FECHA_NACIMIENTO;
        public String ESTADO_CIVIL;
        public String NACIONALIDAD;
        public String LUGAR_NACIMIENTO;
        public String DIRECCION;
        public String REFERENCIA;
        public String DISTRITO;
        public String PROVINCIA;
        public String DEPARTAMENTO;
        public String TELEFONO_FIJO;
        public String TELEFONO_MOVIL;
        public String EMAIL;
    }
}