/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 09-10-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   09-10-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_DebidaDiligenciaParse_cls implements CEN_CalloutParser {

    public Object parseResponse(String obj){
        System.debug('obj: ' + obj);
        obj = obj.replace('"datetime"', '"wDateTime"');
        obj = obj.replace('"system"', '"wSystem"');
        //attributesList myResp = (attributesList)JSON.deserialize(obj,attributesList.class);
        List<CEN_DebidaDiligenciaResponse>  myResp = (List<CEN_DebidaDiligenciaResponse>)JSON.deserialize(obj, List<CEN_DebidaDiligenciaResponse>.class);
        //CEN_DebidaDiligenciaResponse myResp = (CEN_DebidaDiligenciaResponse) JSON.deserialize(obj,CEN_DebidaDiligenciaResponse.class);
        System.debug('myResp: ' + myResp);
        return myResp;
    }

    public Object parseRequest(String obj){
        return false;
    }

    // public class attributesList{
    //     public List<CEN_DebidaDiligenciaResponse> data;
    // }

}