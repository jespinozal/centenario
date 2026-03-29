/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 04-16-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-16-2021   @everis.com   Initial Version
**/
public class CEN_PaymentOrderRequest {
    public Integer amount;
    public String currency_code;
    public String description;
    public String order_number;
    public ClientPayment client_details; 
    public Long expiration_date;

            public class ClientPayment {
                public String first_name;
                public String last_name;
                public String email;
                public String phone_number;
            }

}