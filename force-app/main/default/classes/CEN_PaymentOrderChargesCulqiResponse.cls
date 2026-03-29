/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 04-26-2021
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-19-2021   @everis.com   Initial Version
 **/
public class CEN_PaymentOrderChargesCulqiResponse {
    public String wObject;
    public Boolean duplicated;
    public String id;
    public Long creation_date;
    public Integer amount;
    public Integer amount_refunded;
    public Integer current_amount;
    public Integer installments;
    public Integer installments_amount;
    public String currency_code;
    public String email;
    public String description;
    public Source source;
    public Outcome outcome;
    public String fraud_score;
    public Antifraud_Details antifraud_details; 
    public Boolean dispute;
    public Boolean capture;
    public String reference_code;
    public String authorization_code;
    public Metadata metadata; 
    public Fee_Details fee_details;
    public Decimal total_fee;
    public Decimal total_fee_taxes;
    public Decimal transfer_amount;
    public Boolean paid;
    public String statement_descriptor;
    public String transfer_id;
    public Operations[] operations;
    public Long capture_date;
   
    public class Source {
        public String wObject;
        public String id;
        public String type;
        public Long creation_date;
        public String email;
        public String card_number;
        public String last_four;
        public Boolean active;
        public Iin iin;
        public Client client;
        public Metadata2 metadata;
    }

    public class Iin {
        public String wObject;
        public String bin;
        public String card_brand;
        public String card_type;
        public String card_category;
        public Issuer issuer;
        public Integer[] installments_allowed;
    }

    public class Issuer {
        public String name;
        public String country;
        public String country_code;
        public String website;
        public String phone_number;
    }

    public class Client {
        public String ip;
        public String ip_country;
        public String ip_country_code;
        public String browser;
        public String device_fingerprint;
        public String device_type;
    }

    public class Outcome {
        public String type;
        public String code;
        public String merchant_message;
        public String user_message;
    }

    public class Antifraud_Details {
        public String first_name;
        public String last_name;
        public String address;
        public String address_city;
        public String country_code;
        public String phone;
        public String wObject;
    }

    public class Metadata {
        public String user_id;
        public String order_id;
        public String product;
        public String purchaseNumber;
        public String captureType;
        public String terminalID; 
        public String transactionID;
    }
    
    public class Metadata2{
        public String Celular;
        public String order_id;
        public String dni;
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

    public class Operations {
        public String type;
        public String id;
        public Long creation_date;
        public Integer amount;
        public Integer idoperation_id;
        public String fixed_fee;
        public String variable_fee;
        public String total_fee_taxes;
        public String transfer_amount;
    }
}