/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 13-11-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-11-2023  @nttdata.com  Initial Version
**/
public with sharing class CEN_NotificationAppVecinoCentResponse {
    public Data data;
    public String message;
    public Boolean status;

    public class Data {
        public String tipo_documento;
        public String subject;
        public String origen;
        public String numero_documento;
        public String estado;
        public String case_number;
    }

}