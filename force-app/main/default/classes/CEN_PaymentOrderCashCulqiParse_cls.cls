/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
public class CEN_PaymentOrderCashCulqiParse_cls {
    public Object parseResponse(String obj){
        system.debug('CEN_PaymentOrderCashCulqiResponse-parseResponse: '+obj);
        obj = obj.replace('"object"', '"wObject"');
         attributesList myResp = (attributesList)JSON.deserialize(obj,attributesList.class);
        //List<CEN_PaymentOrderCashCulqiResponse> myResp =(List<CEN_PaymentOrderCashCulqiResponse>) JSON.deserialize(obj,CEN_PaymentOrderCashCulqiResponse.class);
        system.debug('Mi respond: ' + myResp);
        return myResp;
    }

    public Object parseRequest(String obj){return false;}

    public class attributesList{
        public List<CEN_PaymentOrderCashCulqiResponse> data;
    }
}