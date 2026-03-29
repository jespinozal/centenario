/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 05-09-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_GoogleMaps_ctr {

    public static Map<String, String> callUpdateAddress(String accId) {
        Map<String, String> resp = new Map<String, String>();
        CEN_GoogleMapsResponse respSap = new CEN_GoogleMapsResponse();
        respSap = CEN_GoogleMaps_cls.updateAccountAddressById(accId);
        return resp;
    }

    @future(callout=true)
    public static void callUpdateAddressAsinc(String accId) {
        Map<String, String> mapResp = callUpdateAddress(accId);
    }

    @InvocableMethod(label='processUpdateMapURL')
    public static List<String> processUpdateMapURL(List<FlowParameters> parameters){
        List<String> resp = new List<String>();
        if(parameters!=null && parameters.size()>0 && parameters[0].accId!=null){
            for(Integer i=0; i < parameters.size(); i++){
                if(i==0){
                    callUpdateAddressAsinc(parameters[0].accId);
                    resp.add(parameters[0].accId+'inProccess');
                }else{
                    resp.add(parameters[0].accId+'inProccess2');
                }
            }
        }else{
            resp.add('empty');
        }
        return resp;
    }

    public class FlowParameters {
        @InvocableVariable(label='accIdParameter' description='Id Account parameter' required=true)
        public String accId;
    }

}