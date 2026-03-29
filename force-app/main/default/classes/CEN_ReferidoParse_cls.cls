/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 10-09-2024
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   10-09-2024   @nttdata.com  Initial Version
**/
public with sharing class CEN_ReferidoParse_cls implements CEN_CalloutParser{
    public Object parseResponse(String obj){
        System.debug('obj: ' + obj);
        //obj = obj.replace('"datetime"', '"wDateTime"');
        //obj = obj.replace('"system"', '"wSystem"');
        //List<attributesList>  myResp = (List<attributesList>)JSON.deserialize(obj, List<attributesList>.class);
        CEN_ReferidoResponse  myResp = (CEN_ReferidoResponse)JSON.deserialize(obj, CEN_ReferidoResponse.class);
        System.debug('myResp: ' + myResp);
        return myResp;
    }

    public Object parseRequest(String obj){
        return false;
    }

    // public class attributesList{
    //     public List<CEN_ReferidoResponse> data;
    // }

}