/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/
public class CEN_PaymentOrderCashCulqiResponse {
    public String wObject;
    public String id;
    public Integer amount;
    public String payment_code;
    public String currency_code;
    public String description;
    public String order_number;
    public String state;
    public Decimal total_fee;
    public Integer net_amount;
    public Fee_Details fee_details;
    public String creation_date;
    public String expiration_date;
    public Metadata metadata;
    public String updated_at;
    public String paid_at;
    public String available_on;

    public class Metadata {
        public String user_id;
        public String order_id;
        public String product;
    }

    public class Fee_Details {
        public Fixed_Fee fixed_fee;
        public Variable_Fee variable_fee;
    }

    public class Fixed_Fee {}
    
    public class Variable_Fee {
        public String currency_code;
        public Decimal commision;
        public Decimal total;
    }

}