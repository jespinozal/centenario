/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-01-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-01-2021   @everis.com   Initial Version
**/
public with sharing class CEN_PaymentOrderChargesCulqiParse_cls implements CEN_CalloutParser {

    public Object parseResponse(String obj){
        system.debug('CEN_PaymentOrderChargesCulqiParse_cls-parseResponse: '+obj);
        obj = obj.replace('"object"', '"wObject"');
        attributesList myResp = (attributesList)JSON.deserialize(obj,attributesList.class);
        return myResp;
    }

    public Object parseRequest(String obj){return false;}

    public class attributesList{
        public List<CEN_PaymentOrderChargesCulqiResponse> data;
    }
  
}