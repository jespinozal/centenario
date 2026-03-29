public class CEN_Helper_Metadata {
    /*
     * @Autor: Adolfo Crispin - Protivi
     * @Fecha: 5/06/2020
     * @Descripcion: Metodo que devuelve el código de medio publicitario que se tiene registrado en Metadata
	*/
    public static String GetCodigo_MedioPublicitario(String medio_publicitario){
        String medio_publicitario_founded = '';
        medio_publicitario = medio_publicitario.toUpperCase().trim();
        try{
            medio_publicitario_founded = [SELECT CEN_Codigo_Interno_SAP__c FROM CEN_cmt_Medios_Publicitario__mdt 
                                          WHERE Label LIKE :medio_publicitario LIMIT 1].CEN_Codigo_Interno_SAP__c;
        }catch(Exception ex){
            System.debug('No se encontró coincidencia de medio publicitario');
            System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'');        
        }
        return medio_publicitario_founded;
    }

}