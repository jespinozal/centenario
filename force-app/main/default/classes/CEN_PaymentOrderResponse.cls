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
public class CEN_PaymentOrderResponse {
  public String wObject { get; set; }
  public String id { get; set; }
  public Integer amount { get; set; }
  public String payment_code { get; set; }
  public String currency_code { get; set; }
  public String description { get; set; }
  public String order_number { get; set; }
  public String state { get; set; }
  public Integer total_fee { get; set; }
  public Integer net_amount { get; set; }
  public String fee_details { get; set; }
  public Integer creation_date { get; set; }
  public Integer expiration_date { get; set; }
  public Integer updated_at { get; set; }
  public String paid_at { get; set; }
  public String available_on { get; set; }
}