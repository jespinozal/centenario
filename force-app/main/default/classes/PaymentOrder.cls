public class PaymentOrder {
    
        Public  Id IDENT { get; set; }
        Public  String PROFORMA { get; set; }
        Public  String BUKRS { get; set; }
        Public  String BELNR { get; set; }
        Public  Decimal GJAHR { get; set; }
        Public  Decimal OPE_IMPORTE { get; set; }
        Public  String WAERS { get; set; }
        Public  String VIA_PAGO { get; set; }
        Public  Datetime OPE_FECHA { get; set; }
        Public  boolean PAGO_EXTRANJERO { get; set; }
        //Si es abono en cuenta
        Public  String OPE_NUMERO { get; set; }
        Public  String NRO_CTA_BANCO { get; set; }
        Public  Datetime FEC_CONTAB { get; set; }
        //Pago si es tarjeta
        Public  String NRO_TARJETA { get; set; }
        Public  String REFERENCIA { get; set; }
        Public  String PAIS_BANCO { get; set; }
        Public  String CLAVE_BANC { get; set; }
        Public  Decimal COMIS_CULQI { get; set; }
        Public  Datetime FECHA_CULQI { get; set; }
        Public  String TIPO_OPERACION { get; set; }
        Public  String DESCRIPCION { get; set; }

        public static List<PaymentOrder> parse(String jsonString) {
            return (List<PaymentOrder>)JSON.deserialize(jsonString, PaymentOrder.class);
        }
    
}