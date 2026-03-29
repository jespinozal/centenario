/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-11-2021   @everis.com   Initial Version
**/

public class CEN_AnulationOperationSafeRequest {

    public ANULAR ZRFC_OTC_ANULAR_OPS_WS;     
    public class ANULAR {
        public ANULACION IS_ANULACION;
        public String I_GUARDAR_MONTO;
        public String I_PROCESO;
        public DEVOLUCION IS_REALIZAR_DEVOLUCION;
        
    } 
    
    public class ANULACION{
        public String PROCESSO;
        public String SOCIEDAD;
        public String PROFORMA;
        public String CREAR_MOTIVO;
        public String MOTIVO;
        public String DESCRIPCION;
        public String MONEDA_PROFORMA;
    }
    
    public class DEVOLUCION{
        public String REALIZAR_DEVOLUCION;
        public String BANCO;
        public String CUENTA_BANCARIA;
        public String CUENTA_INTERBANCARIA;
    }  
}