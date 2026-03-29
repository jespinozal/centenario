/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-02-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-15-2021   @everis.com   Initial Version
**/
public class CEN_TransferOwnerObjectResponse {
    public PAGOS ET_PAGOS_CLIENTE;
    public CEN_TransferOwnerObjectResponse.BAPIRET2_T ET_RETURN;
    public String E_OK;
    
    public class BAPIRET2_T {
        public CEN_TransferOwnerObjectResponse.BAPIRET2[] item;
        
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

    public class PAGOS {
        public CEN_TransferOwnerObjectResponse.PAGO[] item;
    }

    public class PAGO {
        public string BUKRS;
        public string GJAHR;
        public string BELNR;
        public string BELNR_ANTERIOR;
    }
    
    
}