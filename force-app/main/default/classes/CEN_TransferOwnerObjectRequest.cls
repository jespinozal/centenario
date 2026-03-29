/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-15-2021   @everis.com   Initial Version
**/
public class CEN_TransferOwnerObjectRequest {
    public TransferCliente ZRFC_OTC_TRANSFE_CLIENTE_WS;

    public class TransferCliente{
        public String I_PROCESO;
        public TRANSFERENCIA IS_TRANSFERENCIA;
    }

    public class TRANSFERENCIA{
        public String SALEFORCE;
        public String PROCESSO;
        public String CLIENTE;
        public String SOCIEDAD;
        public String PROFORMA;
        public String MONEDA_PROFORMA;
    }
}