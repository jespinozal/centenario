/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 06-03-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-03-2021   @everis.com   Initial Version
**/
public with sharing class CEN_AccountStatementFinancingResponse {

    public ZLOG_ENVIO_EC_T ET_LOG_ENVIO;

    public class ZLOG_ENVIO_EC_T {
        public ZST_LOG_ENVIO_EC[] item;
    }

    public class ZST_LOG_ENVIO_EC {
        public String CLIENTE_ID_SAP;
        public String CLIENTE_DOC_NRO;
        public String CLIENTE_DOC_TIPO;
        public String PROFORMA;
        public String FECHA_ENVIO;
        public String HORA_ENVIO;
        public String CORREO;
        public String ESTADO;
    }

}