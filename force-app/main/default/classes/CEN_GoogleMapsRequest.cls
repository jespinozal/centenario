/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 05-09-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-09-2023   @nttdata.com  Initial Version
**/
public with sharing class CEN_GoogleMapsRequest {

    public ZWS_REGISTRA_URL_MAPS_element ZWS_REGISTRA_URL_MAPS;

    public class ZWS_REGISTRA_URL_MAPS_element {
        public String I_KUNNR;
        public String I_URL;
    }
}