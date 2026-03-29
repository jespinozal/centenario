/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 24-06-2025
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   04-19-2021   @everis.com       Initial Version
 * 1.1   24-06-2025   Felipe Bermudez   Se agrego nuevo campo FechaEntregaLoteContrato a la respuesta para mostrar en LWC
 **/
public class CEN_WS_Estado_Cuenta_Dos {
    public class ZttStProformaK {
        public CEN_WS_Estado_Cuenta_Dos.ZstProformaK[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZstProformaP {
        @AuraEnabled public String FechaEntregaLoteContrato{get;set;}//Felipe
        @AuraEnabled public String Proforma{get;set;}
        @AuraEnabled public String Version{get;set;}
        @AuraEnabled public Integer Cuota{get;set;}
        @AuraEnabled public String CuotaAux{get;set;}
        @AuraEnabled public Integer NoDias{get;set;}
        @AuraEnabled public Integer NoDiasAcu{get;set;}
        @AuraEnabled public String Pagada{get;set;}
        @AuraEnabled public String TipoCuota{get;set;}
        @AuraEnabled public String SaldoInicial{get;set;}
        @AuraEnabled public String Amortizacion{get;set;}
        @AuraEnabled public String Intereses{get;set;}
        @AuraEnabled public String Gastos{get;set;}
        @AuraEnabled public String InteresGastos{get;set;}
        @AuraEnabled public String Igv{get;set;}
        @AuraEnabled public String SujetoIntIgv{get;set;}
        @AuraEnabled public String Desempleo{get;set;}
        @AuraEnabled public String SeguroVida{get;set;}
        @AuraEnabled public String ImpCuota{get;set;}
        @AuraEnabled public String Waers{get;set;}
        @AuraEnabled public String SaldoFinal{get;set;}
        @AuraEnabled public String FechaVencimiento{get;set;}
        @AuraEnabled public String FechaAlterna{get;set;}
        @AuraEnabled public String Bukrs{get;set;}
        @AuraEnabled public String Belnr{get;set;}
        @AuraEnabled public String Gjahr{get;set;}
        @AuraEnabled public String FechaTcEntrega{get;set;}
        @AuraEnabled public String IndCiLetra{get;set;}
        @AuraEnabled public String CuotaPagada{get;set;}
        @AuraEnabled public String FechaPago{get;set;}
        @AuraEnabled public String FlagFacturado{get;set;}
        @AuraEnabled public String FlagCompensado{get;set;}
        @AuraEnabled public String FlagPagado{get;set;}
        @AuraEnabled public String ImporteCuotaSap{get;set;}
        @AuraEnabled public String DescuentoPagoAdelantado{get;set;}
        @AuraEnabled public String FechaOperacion{get;set;}
        @AuraEnabled public String FlagDevengado{get;set;}
        @AuraEnabled public String ImportCancelado{get;set;}
        @AuraEnabled public String ImportProtesto{get;set;}
        @AuraEnabled public String ImportIntMoratorio{get;set;}
        @AuraEnabled public String ImportComisiones{get;set;}
        @AuraEnabled public String ImportPagoAdelantado{get;set;}
        @AuraEnabled public String FlagEnvioBanco{get;set;}
        @AuraEnabled public String FechaEnvioBanco{get;set;}
        @AuraEnabled public String FlagLargoPlazo{get;set;}
        @AuraEnabled public String ImporteCuotaVencida{get;set;}
        @AuraEnabled public String Usrcomppago{get;set;}
        private String[] Proforma_type_info = new String[]{'Proforma','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Version_type_info = new String[]{'Version','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Cuota_type_info = new String[]{'Cuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaAux_type_info = new String[]{'CuotaAux','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] NoDias_type_info = new String[]{'NoDias','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] NoDiasAcu_type_info = new String[]{'NoDiasAcu','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Pagada_type_info = new String[]{'Pagada','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoCuota_type_info = new String[]{'TipoCuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SaldoInicial_type_info = new String[]{'SaldoInicial','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Amortizacion_type_info = new String[]{'Amortizacion','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Intereses_type_info = new String[]{'Intereses','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Gastos_type_info = new String[]{'Gastos','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] InteresGastos_type_info = new String[]{'InteresGastos','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Igv_type_info = new String[]{'Igv','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SujetoIntIgv_type_info = new String[]{'SujetoIntIgv','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Desempleo_type_info = new String[]{'Desempleo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SeguroVida_type_info = new String[]{'SeguroVida','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImpCuota_type_info = new String[]{'ImpCuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Waers_type_info = new String[]{'Waers','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SaldoFinal_type_info = new String[]{'SaldoFinal','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaVencimiento_type_info = new String[]{'FechaVencimiento','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaAlterna_type_info = new String[]{'FechaAlterna','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Bukrs_type_info = new String[]{'Bukrs','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Belnr_type_info = new String[]{'Belnr','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Gjahr_type_info = new String[]{'Gjahr','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaTcEntrega_type_info = new String[]{'FechaTcEntrega','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] IndCiLetra_type_info = new String[]{'IndCiLetra','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaPagada_type_info = new String[]{'CuotaPagada','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaPago_type_info = new String[]{'FechaPago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagFacturado_type_info = new String[]{'FlagFacturado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagCompensado_type_info = new String[]{'FlagCompensado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagPagado_type_info = new String[]{'FlagPagado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImporteCuotaSap_type_info = new String[]{'ImporteCuotaSap','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DescuentoPagoAdelantado_type_info = new String[]{'DescuentoPagoAdelantado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaOperacion_type_info = new String[]{'FechaOperacion','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagDevengado_type_info = new String[]{'FlagDevengado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImportCancelado_type_info = new String[]{'ImportCancelado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImportProtesto_type_info = new String[]{'ImportProtesto','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImportIntMoratorio_type_info = new String[]{'ImportIntMoratorio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImportComisiones_type_info = new String[]{'ImportComisiones','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImportPagoAdelantado_type_info = new String[]{'ImportPagoAdelantado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagEnvioBanco_type_info = new String[]{'FlagEnvioBanco','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaEnvioBanco_type_info = new String[]{'FechaEnvioBanco','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagLargoPlazo_type_info = new String[]{'FlagLargoPlazo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImporteCuotaVencida_type_info = new String[]{'ImporteCuotaVencida','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Usrcomppago_type_info = new String[]{'Usrcomppago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Proforma','Version','Cuota','CuotaAux','NoDias','NoDiasAcu','Pagada','TipoCuota','SaldoInicial','Amortizacion','Intereses','Gastos','InteresGastos','Igv','SujetoIntIgv','Desempleo','SeguroVida','ImpCuota','Waers','SaldoFinal','FechaVencimiento','FechaAlterna','Bukrs','Belnr','Gjahr','FechaTcEntrega','IndCiLetra','CuotaPagada','FechaPago','FlagFacturado','FlagCompensado','FlagPagado','ImporteCuotaSap','DescuentoPagoAdelantado','FechaOperacion','FlagDevengado','ImportCancelado','ImportProtesto','ImportIntMoratorio','ImportComisiones','ImportPagoAdelantado','FlagEnvioBanco','FechaEnvioBanco','FlagLargoPlazo','ImporteCuotaVencida','Usrcomppago'};
    }
    public class ZfsRfcEstadoCuenta2_element {
        public String PiProf;
        public String PiVers;
        private String[] PiProf_type_info = new String[]{'PiProf','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PiVers_type_info = new String[]{'PiVers','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'PiProf','PiVers'};
    }
    public class ZstProformaK {
        public String Proforma;
        public String Version;
        public String ProformaAnt;
        public String Processo;
        public String CodPropiedad;
        public String Propiedades;
        public String CodMinuta;
        public String FechaFinanciamiento;
        public String Bukrs;
        public String Waers;
        public String Precio;
        public String TipoCambio;
        public String DiasPago;
        public String ImporteReserva;
        public String CuotaInicImpR;
        public String ImporteSaldoPrecio;
        public String TasaAnualInteresFinan;
        public String TasaAnualGastosAdmin;
        public String TasaMensualInteresFinan;
        public String TasaMensualGastosAdmin;
        public String CostoTotalMensual;
        public String CostoTotalAnual;
        public String ImporteCuota;
        public String Amortizado;
        public String Kunnr;
        public String TipCliCont;
        public String Ersda;
        public String Aedat;
        public String Aenam;
        public String CashBldat;
        public String Cash;
        public String Bfh;
        public String CuotaInicImp;
        public String CuotaInicPor;
        public Integer CuotaInicNoCuotas;
        public String CuotaInicInteres;
        public String CuotaInicIntgas;
        public Integer SaldoNoCuotas;
        public Integer PeriodoDias;
        public String SaldoIntereses;
        public String SaldoIntgas;
        public String MantenerCuota;
        public String DisminuirCuota;
        public String Promotor;
        public String FechaInicio;
        public String ViaFinanciamiento;
        public String RepLeg1;
        public String RepLeg2;
        public String AreaVendible;
        public String SupConstruida;
        public String AreaLibre;
        public String BloquePortal;
        public String Numeroletra;
        public String CantidadLotes;
        public String Telemarketing;
        public String FirmaMecaniz;
        public String TipoContrato;
        public String PerimetroFrente;
        public String PerimetroFondo;
        public String PerimetroIzqui;
        public String PerimetroDerec;
        public String PerfilCobran;
        public String Estado;
        public String Motivo;
        public String Vbeln;
        public String TipoProforma;
        public String FechaCventas;
        public String CodMotgrup;
        public String CodMotdet;
        public String FechaInactivo;
        public String TipoPrepago;
        public String FechaPrepago;
        public String FechaReversionPrepago;
        public String FechaCierre2;
        public String FechaTcEntrega;
        public String FechaEntregaTc;
        public String FechaEntregaNiff;
        public String FechaEntregaFis;
        public String TipoEntrega;
        public String FechaCambCont;
        public String FechaDesembolso;
        public String Banco;
        public String FechaEntProy;
        public String CuotaInicialFinancia;
        public String ApoderadoCentenario1;
        public String ApoderadoCentenario2;
        public String Interlocutor1;
        public String Interlocutor2;
        public String Interlocutor3;
        public String Interlocutor4;
        public String Interlocutor5;
        public String Interlocutor6;
        public String Interlocutor7;
        public String Interlocutor8;
        public String Interlocutor9;
        public String Interlocutor10;
        public String Apoderado1;
        public String Apoderado2;
        public String Zzzonaventa;
        public String Medio;
        public String IndFinanCi;
        public String InteresesCi;
        public String FechaCartaNotarial;
        public String Resolucion;
        public String PendienteResolver;
        public String ResolPendApro;
        public String FechaResolver;
        public String PorcenResolPuntual;
        public String PorcenResolCentenario;
        public String PorcenResolMoroso;
        public String OpcionSolComprador;
        public String OpcionSolVendedor;
        public String OpcionCapital;
        public String OpcionCapitalInteresGastos;
        public String PorcenResolPuntualFinal;
        public String PorcenResolCentenarioFinal;
        public String PorcenComisionVentas;
        public String OtrosGastos;
        public String OtrosGastosCliente;
        public String CargosPorCtaCliente;
        public String TotalDescontarPenalidad;
        public String MontoNcCapitalPagado;
        public String MontoNcCapitalNoPagado;
        public String MontoNcInteresesPagado;
        public String MontoNcInteresesNoPagado;
        public String MontoNcPenalidad;
        public String SituacionFinanciamiento;
        public String CreadoPor;
        public String FlagVariacionArea;
        public String MetrosVariacionArea;
        public String MontoVariacionArea;
        public String ZacDocSunat;
        public Integer NcuotasSaldoOriginal;
        public String MotivoCompra;
        public String Asientoap1;
        public String Asientoap2;
        public String Usrcomppago;
        public String EsignEstado;
        public String EsignFecha;
        public String ComprobOracle;
        public String FechaEntregaLoteContrato;//Felipe
        private String[] FechaEntregaLoteContrato_type_info = new String[]{'FechaEntregaLoteContrato','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};//Felipe
        private String[] Proforma_type_info = new String[]{'Proforma','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Version_type_info = new String[]{'Version','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ProformaAnt_type_info = new String[]{'ProformaAnt','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Processo_type_info = new String[]{'Processo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CodPropiedad_type_info = new String[]{'CodPropiedad','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Propiedades_type_info = new String[]{'Propiedades','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CodMinuta_type_info = new String[]{'CodMinuta','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaFinanciamiento_type_info = new String[]{'FechaFinanciamiento','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Bukrs_type_info = new String[]{'Bukrs','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Waers_type_info = new String[]{'Waers','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Precio_type_info = new String[]{'Precio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoCambio_type_info = new String[]{'TipoCambio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DiasPago_type_info = new String[]{'DiasPago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImporteReserva_type_info = new String[]{'ImporteReserva','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicImpR_type_info = new String[]{'CuotaInicImpR','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImporteSaldoPrecio_type_info = new String[]{'ImporteSaldoPrecio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TasaAnualInteresFinan_type_info = new String[]{'TasaAnualInteresFinan','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TasaAnualGastosAdmin_type_info = new String[]{'TasaAnualGastosAdmin','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TasaMensualInteresFinan_type_info = new String[]{'TasaMensualInteresFinan','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TasaMensualGastosAdmin_type_info = new String[]{'TasaMensualGastosAdmin','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CostoTotalMensual_type_info = new String[]{'CostoTotalMensual','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CostoTotalAnual_type_info = new String[]{'CostoTotalAnual','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ImporteCuota_type_info = new String[]{'ImporteCuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Amortizado_type_info = new String[]{'Amortizado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Kunnr_type_info = new String[]{'Kunnr','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipCliCont_type_info = new String[]{'TipCliCont','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Ersda_type_info = new String[]{'Ersda','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Aedat_type_info = new String[]{'Aedat','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Aenam_type_info = new String[]{'Aenam','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CashBldat_type_info = new String[]{'CashBldat','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Cash_type_info = new String[]{'Cash','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Bfh_type_info = new String[]{'Bfh','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicImp_type_info = new String[]{'CuotaInicImp','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicPor_type_info = new String[]{'CuotaInicPor','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicNoCuotas_type_info = new String[]{'CuotaInicNoCuotas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicInteres_type_info = new String[]{'CuotaInicInteres','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicIntgas_type_info = new String[]{'CuotaInicIntgas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SaldoNoCuotas_type_info = new String[]{'SaldoNoCuotas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PeriodoDias_type_info = new String[]{'PeriodoDias','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SaldoIntereses_type_info = new String[]{'SaldoIntereses','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SaldoIntgas_type_info = new String[]{'SaldoIntgas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MantenerCuota_type_info = new String[]{'MantenerCuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DisminuirCuota_type_info = new String[]{'DisminuirCuota','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Promotor_type_info = new String[]{'Promotor','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaInicio_type_info = new String[]{'FechaInicio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ViaFinanciamiento_type_info = new String[]{'ViaFinanciamiento','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] RepLeg1_type_info = new String[]{'RepLeg1','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] RepLeg2_type_info = new String[]{'RepLeg2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] AreaVendible_type_info = new String[]{'AreaVendible','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SupConstruida_type_info = new String[]{'SupConstruida','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] AreaLibre_type_info = new String[]{'AreaLibre','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BloquePortal_type_info = new String[]{'BloquePortal','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Numeroletra_type_info = new String[]{'Numeroletra','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CantidadLotes_type_info = new String[]{'CantidadLotes','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Telemarketing_type_info = new String[]{'Telemarketing','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FirmaMecaniz_type_info = new String[]{'FirmaMecaniz','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoContrato_type_info = new String[]{'TipoContrato','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PerimetroFrente_type_info = new String[]{'PerimetroFrente','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PerimetroFondo_type_info = new String[]{'PerimetroFondo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PerimetroIzqui_type_info = new String[]{'PerimetroIzqui','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PerimetroDerec_type_info = new String[]{'PerimetroDerec','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PerfilCobran_type_info = new String[]{'PerfilCobran','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Estado_type_info = new String[]{'Estado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Motivo_type_info = new String[]{'Motivo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Vbeln_type_info = new String[]{'Vbeln','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoProforma_type_info = new String[]{'TipoProforma','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaCventas_type_info = new String[]{'FechaCventas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CodMotgrup_type_info = new String[]{'CodMotgrup','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CodMotdet_type_info = new String[]{'CodMotdet','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaInactivo_type_info = new String[]{'FechaInactivo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoPrepago_type_info = new String[]{'TipoPrepago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaPrepago_type_info = new String[]{'FechaPrepago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaReversionPrepago_type_info = new String[]{'FechaReversionPrepago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaCierre2_type_info = new String[]{'FechaCierre2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaTcEntrega_type_info = new String[]{'FechaTcEntrega','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaEntregaTc_type_info = new String[]{'FechaEntregaTc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaEntregaNiff_type_info = new String[]{'FechaEntregaNiff','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaEntregaFis_type_info = new String[]{'FechaEntregaFis','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TipoEntrega_type_info = new String[]{'TipoEntrega','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaCambCont_type_info = new String[]{'FechaCambCont','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaDesembolso_type_info = new String[]{'FechaDesembolso','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Banco_type_info = new String[]{'Banco','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaEntProy_type_info = new String[]{'FechaEntProy','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CuotaInicialFinancia_type_info = new String[]{'CuotaInicialFinancia','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ApoderadoCentenario1_type_info = new String[]{'ApoderadoCentenario1','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ApoderadoCentenario2_type_info = new String[]{'ApoderadoCentenario2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor1_type_info = new String[]{'Interlocutor1','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor2_type_info = new String[]{'Interlocutor2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor3_type_info = new String[]{'Interlocutor3','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor4_type_info = new String[]{'Interlocutor4','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor5_type_info = new String[]{'Interlocutor5','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor6_type_info = new String[]{'Interlocutor6','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor7_type_info = new String[]{'Interlocutor7','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor8_type_info = new String[]{'Interlocutor8','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor9_type_info = new String[]{'Interlocutor9','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Interlocutor10_type_info = new String[]{'Interlocutor10','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Apoderado1_type_info = new String[]{'Apoderado1','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Apoderado2_type_info = new String[]{'Apoderado2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Zzzonaventa_type_info = new String[]{'Zzzonaventa','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Medio_type_info = new String[]{'Medio','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] IndFinanCi_type_info = new String[]{'IndFinanCi','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] InteresesCi_type_info = new String[]{'InteresesCi','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaCartaNotarial_type_info = new String[]{'FechaCartaNotarial','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Resolucion_type_info = new String[]{'Resolucion','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PendienteResolver_type_info = new String[]{'PendienteResolver','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ResolPendApro_type_info = new String[]{'ResolPendApro','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FechaResolver_type_info = new String[]{'FechaResolver','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenResolPuntual_type_info = new String[]{'PorcenResolPuntual','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenResolCentenario_type_info = new String[]{'PorcenResolCentenario','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenResolMoroso_type_info = new String[]{'PorcenResolMoroso','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OpcionSolComprador_type_info = new String[]{'OpcionSolComprador','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OpcionSolVendedor_type_info = new String[]{'OpcionSolVendedor','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OpcionCapital_type_info = new String[]{'OpcionCapital','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OpcionCapitalInteresGastos_type_info = new String[]{'OpcionCapitalInteresGastos','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenResolPuntualFinal_type_info = new String[]{'PorcenResolPuntualFinal','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenResolCentenarioFinal_type_info = new String[]{'PorcenResolCentenarioFinal','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PorcenComisionVentas_type_info = new String[]{'PorcenComisionVentas','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OtrosGastos_type_info = new String[]{'OtrosGastos','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OtrosGastosCliente_type_info = new String[]{'OtrosGastosCliente','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CargosPorCtaCliente_type_info = new String[]{'CargosPorCtaCliente','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TotalDescontarPenalidad_type_info = new String[]{'TotalDescontarPenalidad','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoNcCapitalPagado_type_info = new String[]{'MontoNcCapitalPagado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoNcCapitalNoPagado_type_info = new String[]{'MontoNcCapitalNoPagado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoNcInteresesPagado_type_info = new String[]{'MontoNcInteresesPagado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoNcInteresesNoPagado_type_info = new String[]{'MontoNcInteresesNoPagado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoNcPenalidad_type_info = new String[]{'MontoNcPenalidad','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SituacionFinanciamiento_type_info = new String[]{'SituacionFinanciamiento','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CreadoPor_type_info = new String[]{'CreadoPor','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlagVariacionArea_type_info = new String[]{'FlagVariacionArea','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MetrosVariacionArea_type_info = new String[]{'MetrosVariacionArea','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MontoVariacionArea_type_info = new String[]{'MontoVariacionArea','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ZacDocSunat_type_info = new String[]{'ZacDocSunat','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] NcuotasSaldoOriginal_type_info = new String[]{'NcuotasSaldoOriginal','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] MotivoCompra_type_info = new String[]{'MotivoCompra','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Asientoap1_type_info = new String[]{'Asientoap1','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Asientoap2_type_info = new String[]{'Asientoap2','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Usrcomppago_type_info = new String[]{'Usrcomppago','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] EsignEstado_type_info = new String[]{'EsignEstado','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] EsignFecha_type_info = new String[]{'EsignFecha','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ComprobOracle_type_info = new String[]{'ComprobOracle','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Proforma','Version','ProformaAnt','Processo','CodPropiedad','Propiedades','CodMinuta','FechaFinanciamiento','Bukrs','Waers','Precio','TipoCambio','DiasPago','ImporteReserva','CuotaInicImpR','ImporteSaldoPrecio','TasaAnualInteresFinan','TasaAnualGastosAdmin','TasaMensualInteresFinan','TasaMensualGastosAdmin','CostoTotalMensual','CostoTotalAnual','ImporteCuota','Amortizado','Kunnr','TipCliCont','Ersda','Aedat','Aenam','CashBldat','Cash','Bfh','CuotaInicImp','CuotaInicPor','CuotaInicNoCuotas','CuotaInicInteres','CuotaInicIntgas','SaldoNoCuotas','PeriodoDias','SaldoIntereses','SaldoIntgas','MantenerCuota','DisminuirCuota','Promotor','FechaInicio','ViaFinanciamiento','RepLeg1','RepLeg2','AreaVendible','SupConstruida','AreaLibre','BloquePortal','Numeroletra','CantidadLotes','Telemarketing','FirmaMecaniz','TipoContrato','PerimetroFrente','PerimetroFondo','PerimetroIzqui','PerimetroDerec','PerfilCobran','Estado','Motivo','Vbeln','TipoProforma','FechaCventas','CodMotgrup','CodMotdet','FechaInactivo','TipoPrepago','FechaPrepago','FechaReversionPrepago','FechaCierre2','FechaTcEntrega','FechaEntregaTc','FechaEntregaNiff','FechaEntregaFis','TipoEntrega','FechaCambCont','FechaDesembolso','Banco','FechaEntProy','CuotaInicialFinancia','ApoderadoCentenario1','ApoderadoCentenario2','Interlocutor1','Interlocutor2','Interlocutor3','Interlocutor4','Interlocutor5','Interlocutor6','Interlocutor7','Interlocutor8','Interlocutor9','Interlocutor10','Apoderado1','Apoderado2','Zzzonaventa','Medio','IndFinanCi','InteresesCi','FechaCartaNotarial','Resolucion','PendienteResolver','ResolPendApro','FechaResolver','PorcenResolPuntual','PorcenResolCentenario','PorcenResolMoroso','OpcionSolComprador','OpcionSolVendedor','OpcionCapital','OpcionCapitalInteresGastos','PorcenResolPuntualFinal','PorcenResolCentenarioFinal','PorcenComisionVentas','OtrosGastos','OtrosGastosCliente','CargosPorCtaCliente','TotalDescontarPenalidad','MontoNcCapitalPagado','MontoNcCapitalNoPagado','MontoNcInteresesPagado','MontoNcInteresesNoPagado','MontoNcPenalidad','SituacionFinanciamiento','CreadoPor','FlagVariacionArea','MetrosVariacionArea','MontoVariacionArea','ZacDocSunat','NcuotasSaldoOriginal','MotivoCompra','Asientoap1','Asientoap2','Usrcomppago','EsignEstado','EsignFecha','ComprobOracle'};
    }
    public class ZttStProformaP {
        public CEN_WS_Estado_Cuenta_Dos.ZstProformaP[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZfsRfcEstadoCuenta2Response_element {
        public CEN_WS_Estado_Cuenta_Dos.ZttStProformaK ExTStProformaK;
        public CEN_WS_Estado_Cuenta_Dos.ZttStProformaP ExTStProformaP;
        public String FlError;
        public String TxtError;
        private String[] ExTStProformaK_type_info = new String[]{'ExTStProformaK','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExTStProformaP_type_info = new String[]{'ExTStProformaP','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FlError_type_info = new String[]{'FlError','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TxtError_type_info = new String[]{'TxtError','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ExTStProformaK','ExTStProformaP','FlError','TxtError'};
    }
    public class ZWSSF_ESTADO_CUENTA2_BD {
        public String endpoint_x = label.CEN_ws_estado_cuenta_2;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'CEN_WS_Estado_Cuenta_Dos', 'urn:sap-com:document:sap:rfc:functions', 'sapComDocumentSapRfcFunctions'};
        public CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element ZfsRfcEstadoCuenta2(String PiProf,String PiVers) {
            CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2_element request_x = new CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2_element();
            request_x.PiProf = PiProf;
            request_x.PiVers = PiVers;
            CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element response_x;
            Map<String, CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element> response_map_x = new Map<String, CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:sap-com:document:sap:soap:functions:mc-style:ZWSSF_ESTADO_CUENTA2:ZfsRfcEstadoCuenta2Request',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZfsRfcEstadoCuenta2',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZfsRfcEstadoCuenta2Response',
              'CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}