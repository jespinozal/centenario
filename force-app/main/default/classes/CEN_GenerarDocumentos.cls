/********************************************************************************
* @author: Jhanluck Onofre (jonofres@nttdata.com)
* @date: 2024-08-16
* @description: Web service para consumir el servicio de SAP para la obtención de 
*               documentos finales de resolución de contrato.
* 
* VERSION		DATE			AUTOR					ACTION
* 0.1			2024-08-16		Jhanluck Onofre		Creación
********************************************************************************/
public class CEN_GenerarDocumentos {
    @AuraEnabled public String fechaCarga;
    @AuraEnabled public String horaCarga;
    @AuraEnabled public String documento1;
    @AuraEnabled public String documento2;
    @AuraEnabled public String claveUnica;
    @AuraEnabled public List<Mensaje> mensaje;


    public class Mensaje{
        @AuraEnabled public String  type;
        @AuraEnabled public String  id;
        //@AuraEnabled public String  number;
        @AuraEnabled public String  message;
        @AuraEnabled public String  logNo;
        @AuraEnabled public Integer logMsgNo;
        @AuraEnabled public String  messageV1;
        @AuraEnabled public String  messageV2;
        @AuraEnabled public String  messageV3;
        @AuraEnabled public String  messageV4;
        @AuraEnabled public String  parameter;
        @AuraEnabled public Integer row;
        @AuraEnabled public String  field;
        //@AuraEnabled public String  system;

    }
    public static CEN_GenerarDocumentos parse(String json) {
		return (CEN_GenerarDocumentos) System.JSON.deserialize(json, CEN_GenerarDocumentos.class);
	}

    
}