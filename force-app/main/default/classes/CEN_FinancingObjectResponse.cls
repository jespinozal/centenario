public class CEN_FinancingObjectResponse {

    public BAPIRET2_T ET_RETURN;
    public String E_OK;

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
        public Integer ROW;
        public String FIELD;
        public String SYSTEM_x;
    }
}