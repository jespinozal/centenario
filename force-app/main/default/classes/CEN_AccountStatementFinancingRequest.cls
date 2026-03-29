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
public with sharing class CEN_AccountStatementFinancingRequest {
    
    public ZWS_CONSULTA_ENVIO_EC_element ZWS_CONSULTA_ENVIO_EC;

    public class ZWS_CONSULTA_ENVIO_EC_element {
        public String I_FECHA_FIN;
        public String I_FECHA_INI;
        public String I_HORA_FIN;
        public String I_HORA_INI;
    }
}