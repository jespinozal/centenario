/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-22 
* @description: Clase Response - Crear Cliente SAP. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-06-22           Alan Alvarez            Creación 
*  
*********************************************************************/
public class CEN_CreateClientResponse {
    
    public ZTT_CLIENTE_DOCSAP ET_CLIENTE;
    public BAPIRET2_T ET_RETURN;
    
    public class ZTT_CLIENTE_DOCSAP {
        public ZWS_CLIENTE_DOCSAP[] item;
    }
    
    public class BAPIRET2_T {
        public BAPIRET2[] item;
    }
    
    public class ZWS_CLIENTE_DOCSAP {
        public String TIPO_DOC;
        public String STCD1;
        public String KUNNR;
        public String NAME;
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
    
}