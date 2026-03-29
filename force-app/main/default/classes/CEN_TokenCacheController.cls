public class CEN_TokenCacheController {
    //	DATA FOR PARTITION
	private String partition_name = 'CENpartition1';
    private Cache.OrgPartition cache_org_partition = null;
    //	ONBASE
    public String token_label_name_onbase = 'cenaconbase';
    private Integer token_time_expire_onbase = 1795;

    //	VISOR
    public String token_label_name_visor = 'cenacvisor';
    private Integer token_time_expire_visor = 28740;

    //	DEBIDA DILIGENCIA
    public String token_label_name_sinergy = 'centokenonbasedev';
    private Integer token_time_expire_sinergy = 1795;

    public CEN_TokenCacheController(){
        try{
            cache_org_partition = Cache.Org.getPartition(partition_name);
            if(cache_org_partition==null){
                System.debug('Caché no encontrado');
            }else{
                System.debug('Cache info: ' + cache_org_partition);
            }
            System.debug('Token de ONBASE: ' + (String)cache_org_partition.get(token_label_name_onbase));
            System.debug('Token de VISOR: ' + (String)cache_org_partition.get(token_label_name_visor));
            System.debug('Token de SINERGY: ' + (String)cache_org_partition.get(token_label_name_sinergy));
        }catch(Exception e){
            System.debug('Caché no encontrado o hubo un problema: ' + e.getMessage() +'. Line: '+e.getLineNumber());
        }
    }
    public void StoreTokenInCacheOrg(String access_token, String type_token){
        if(type_token.equals(token_label_name_onbase)){
            cache_org_partition.put(token_label_name_onbase, access_token, token_time_expire_onbase, Cache.Visibility.ALL, true);
        }else if(type_token.equals(token_label_name_visor)){
            cache_org_partition.put(token_label_name_visor, access_token, token_time_expire_visor, Cache.Visibility.ALL, true);
        }else if(type_token.equals(token_label_name_sinergy)){
            cache_org_partition.put(token_label_name_sinergy, access_token, token_time_expire_sinergy, Cache.Visibility.ALL, true);
        }
    }
    public String GetTokenFromCacheOrg(String type_token){
        String token = '';
        if(type_token.equals(token_label_name_onbase)){
             token = (String)cache_org_partition.get(token_label_name_onbase);
        }else if(type_token.equals(token_label_name_visor)){
             token = (String)cache_org_partition.get(token_label_name_visor);
        }else if(type_token.equals(token_label_name_sinergy)){
            token = (String)cache_org_partition.get(token_label_name_sinergy);
        }
        return token;
    }
}