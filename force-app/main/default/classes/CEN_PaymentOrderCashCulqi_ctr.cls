public class CEN_PaymentOrderCashCulqi_ctr {

    public static Map<String, Object> ListCashCulqi(map<String,String> mapData) {
        Map<String, Object> mapResp = new Map<String, Object>();
        Map<String, String> mapResult = new Map<String, String>();
        try {
            System.debug('mapData: ' + mapData);
            mapResult = validateFilters(mapData);
            System.debug('resultado: ' + mapResult);
            mapResp = CEN_PaymentOrderCashCulqi_cls.PaymentOrderCash(mapResult);
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
            if(key == 'amount' && !String.isEmpty(data)){
                data = data.contains('.') ? data.replace('.','') : data.rightPad(data.length() + 2 ,'00');
                if(data.length() < 4){
                    throw new PaymentOrderCashException('Error en el importe');    
                }
            }else if(key == 'first_name' && !String.isEmpty(data) && data.length() < 2){
                throw new PaymentOrderCashException('Error en nombre del cliente');
            }else if(key == 'last_name' && !String.isEmpty(data) && data.length() < 2){
                throw new PaymentOrderCashException('Error en apellido del cliente');
            }else if(key == 'creation_date_from'){
                strdtFrom = data.rightPad(data.length() + 3 ,'000');
                system.debug('ERRO FECHA AQUI: '+strdtFrom);
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
            system.debug('ERRO FECHA AQUI2: '+dtF + 'otra cosa' + myDateF);
            if (myDateF.daysBetween(myDateT) < 0) {
                throw new PaymentOrderCashException('Error en fecha de creación: ' + myDateT.daysBetween(myDateF));
            }
        }else{
            throw new PaymentOrderCashException('Error en fecha de creación: fecha es null ');
        }
       

        return mapResult;
    }

    public class PaymentOrderCashException extends Exception {
    }
}