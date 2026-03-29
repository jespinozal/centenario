/**
* @description       :
* @author            : @everis.com
* @group             :
* @last modified on  : 04-28-2021
* @last modified by  : @everis.com
* Modifications Log
* Ver   Date         Author        Modification
* 1.0   04-16-2021   @everis.com   Initial Version
**/
public with sharing class CEN_PaymentOrderChargesCulqi_ctr {

    public static Map<String, Object> ListChargesCulqi(map<String,String> mapData) {
        Map<String, Object> mapResp = new Map<String, Object>();
        Map<String, String> mapResult = new Map<String, String>();

        try {
            System.debug('mapData: ' + mapData);
            mapResult = validateFilters(mapData);
            System.debug('resultado: ' + mapResult);
            mapResp = CEN_PaymentOrderChargesCulqi_cls.PaymentOrderCharges(mapResult);
            System.debug('respuesta: ' + mapResp);
        } catch (Exception ex) {
            mapResp.put('error', ex.getMessage());
            System.debug('error :' + ex.getMessage());
        }
        return mapResp;
    }

    private static Map<String, String> validateFilters(map<String,String> mapData) {
		System.debug('validateFilters :' + mapData);
        map<String,String> mapResult = new map<String,String>();
        Set <String> dataSet = new Set<String>();
        dataSet = mapData.keySet();
        String strdtFrom; 
        String strdtTo;

        for(String key : dataSet){
            String data = mapData.get(key);
            Integer monto;
            if(key == 'amount' && !String.isEmpty(data)){
                data = data.contains('.') ? data.replace('.','') : data.rightPad(data.length() + 2 ,'00');
                monto = integer.valueOf(data);
                data = String.valueOf(monto);
                System.debug('dataAmount ' + data);
                if(data.length() < 3){
                    throw new PaymentOrderChargesException('El valor del monto debe ser mayor o igual que (1 sol, 1 dólar)');    
                }
            }else if(key == 'first_name' && !String.isEmpty(data) && data.length() < 2){
                throw new PaymentOrderChargesException('Error en nombre del cliente');
            }else if(key == 'last_name' && !String.isEmpty(data) && data.length() < 2){
                throw new PaymentOrderChargesException('Error en apellido del cliente');
            }else if(key == 'creation_date_from'){
                strdtFrom = data.rightPad(data.length() + 3 ,'000');
            }else if(key == 'creation_date_to'){
                strdtTo = data.rightPad(data.length() + 3 ,'000');
            }
            
            if(!String.isEmpty(data)){
                mapResult.put(key,data);
            }
        }
        if(strdtFrom!= null && strdtTo!=null){
             Datetime dtF = DateTime.newInstance(long.valueOf(strdtFrom));
            Datetime dtT = DateTime.newInstance(long.valueOf(strdtTo));
            Date myDateF = date.newinstance(dtF.year(), dtF.month(), dtF.day());
            Date myDateT = date.newinstance(dtT.year(), dtT.month(), dtT.day());
    
            if (myDateF.daysBetween(myDateT) < 0) {
                throw new PaymentOrderChargesException('Error en fecha de creación: ' + myDateT.daysBetween(myDateF));
            }
        }else{
            throw new PaymentOrderChargesException('Error en fecha de creación: fecha es null ');
        }
       

        return mapResult;
    }

    public class PaymentOrderChargesException extends Exception {
    }
}