public class CEN_Lotes_Cliente {
    public static List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> LotesPorClientSAP(String tipoDocumento, String nDocumento){
        System.debug('<!--LotesPorCliente ('+tipoDocumento+','+nDocumento+')');
        Map<String,String> tipo_NIF = new Map<String,String>();
        tipo_NIF.put('CAREXTRAN','91');
        tipo_NIF.put('RUC','92');
        tipo_NIF.put('P.NAC.','93');
        tipo_NIF.put('Pasaporte','94');
        tipo_NIF.put('DNI','96');
        tipo_NIF.put('P.T.P.','99');
        tipo_NIF.put('Sin especificar','99');
        tipo_NIF.put('Otros','99');
        List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotes = null;        
        CEN_WS_Lotes_por_Cliente.ZWS_LOTESXCLI service = new CEN_WS_Lotes_por_Cliente.ZWS_LOTESXCLI();
        service.timeout_x=30000;
        service.inputHttpHeaders_x = new Map<String,String>();
        service.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(label.CEN_usersap+':'+label.CEN_passSap)));
        CEN_WS_Lotes_por_Cliente.ZSF_RFC_LOTES_X_CLIENTEResponse_element response = null;
        try{
            String nif = tipo_NIF.get(tipoDocumento);
            System.debug('service.ZSF_RFC_LOTES_X_CLIENTE ('+nDocumento+','+nif+')');
            response =  service.ZSF_RFC_LOTES_X_CLIENTE(nDocumento,nif);
            if(response!=null){
                System.debug('response.E_RETURN:'+response.E_RETURN);
                System.debug('response.ET_LOTES:'+response.ET_LOTES);
                if(String.isBlank(response.E_RETURN)){
                    lotes = (List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES>) response.ET_LOTES.item;
                    if(lotes!=null){
                        System.debug('lotes size: '+lotes.size());   
                    }                    
                }else{
                    System.debug('Lotes por cliente desde SAP error: '+response.E_RETURN);
                }
            }
        }catch(Exception ex){
            System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        if(lotes==null){lotes = new List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES>();}
        System.debug('-->LotesPorCliente ('+tipoDocumento+','+nDocumento+')');
        return lotes;
    }
        
}