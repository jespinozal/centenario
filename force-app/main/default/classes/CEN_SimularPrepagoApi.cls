/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * @last modified by  : Felipe Bermudez - NTT DATA / campo nuevo interesxPagSinPrepago
**/
public with sharing class CEN_SimularPrepagoApi {
    public Cabecera         cabecera;
    public List<Detalle>    detalle;
    public List<Mensaje>    mensaje;
    public Extras           extras;

    public class Cabecera{
        @AuraEnabled public Integer     proforma;
        @AuraEnabled public Integer     version;
        @AuraEnabled public Integer     proformaAnt;
        @AuraEnabled public String      processo;
        @AuraEnabled public Integer     codPropiedad;
        @AuraEnabled public String      codMinuta;
        @AuraEnabled public String      propiedades;
        @AuraEnabled public String      bukrs;
        @AuraEnabled public Integer     tipoProforma;
        @AuraEnabled public String      vbeln;
        @AuraEnabled public String      posid;
        @AuraEnabled public Integer     posnr;
        @AuraEnabled public String      waers;
        @AuraEnabled public Decimal     precio;
        @AuraEnabled public String      kunnr;
        @AuraEnabled public String      tipCliCont;
        @AuraEnabled public Decimal     cuotaMinima;
        @AuraEnabled public Decimal     cuotaInicImp;
        @AuraEnabled public Decimal     cuotaInicPor;
        @AuraEnabled public Integer     cuotaInicNoCuotas;
        @AuraEnabled public Decimal     cuotaInicMin;
        @AuraEnabled public Decimal     cuotaInicMax;
        @AuraEnabled public Decimal     cuotaInicInteres;
        @AuraEnabled public Decimal     cuotaInicIntgas;
        @AuraEnabled public Integer     cuotaInicNoCuotasMin;
        @AuraEnabled public Integer     cuotaInicNoCuotasMax;
        @AuraEnabled public Integer     saldoNoCuotas;
        @AuraEnabled public Integer     saldoNoCuotasMax;
        @AuraEnabled public Decimal     saldoIntereses;
        @AuraEnabled public Decimal     saldoIntgas;
        @AuraEnabled public Decimal     cuotaInicImpR;
        @AuraEnabled public String      promotor;
        @AuraEnabled public String      fechaInicio;
        @AuraEnabled public String      viaFinanciamiento;
        @AuraEnabled public Decimal     cash;
        @AuraEnabled public String      cashBldat;
        @AuraEnabled public String      checkEntrega;
        @AuraEnabled public String      telemarketing;
        @AuraEnabled public String      firmaMecaniz;
        @AuraEnabled public String      statusInicial;
        @AuraEnabled public Decimal     bfh;
        @AuraEnabled public String      fechaEntProy;
        @AuraEnabled public String      indFinanCi;
        @AuraEnabled public String      faciloteIndCi;
        @AuraEnabled public String      cotizacionProforma;
        @AuraEnabled public String      diasPago;
        @AuraEnabled public String      interesesCi;
        @AuraEnabled public Decimal     importeReserva;
        @AuraEnabled public String      zzzonaventa;
        @AuraEnabled public String      medio;
        @AuraEnabled public String      canal;
        @AuraEnabled public String      etiCliConta;
        @AuraEnabled public String      etiMedio;
        @AuraEnabled public String      etiZona;
        @AuraEnabled public String      etiPromotor;
        @AuraEnabled public String      etiApo1;
        @AuraEnabled public String      etiApo2;
        @AuraEnabled public Decimal     importeSaldoPrecio;
        @AuraEnabled public String      tasaManualInd;
        @AuraEnabled public Decimal     tasaAnualInteresFinan;
        @AuraEnabled public Decimal     tasaAnualGastosAdmin;
        @AuraEnabled public Decimal     tasaMensualInteresFinan;
        @AuraEnabled public Decimal     tasaMensualGastosAdmin;
        @AuraEnabled public Decimal     costoTotalMensual;
        @AuraEnabled public Decimal     costoTotalAnual;
        @AuraEnabled public String      perfilCobran;
        @AuraEnabled public Integer     periodoDias;
        @AuraEnabled public Decimal     importeCuota;
        @AuraEnabled public Integer     cantidadLotes;
        @AuraEnabled public Decimal     areaVendible;
        @AuraEnabled public String      apoderadoCentenario1;
        @AuraEnabled public String      apoderadoCentenario2;
        @AuraEnabled public Integer     diasAdicionales;
        @AuraEnabled public Decimal     precioOriginal;
        @AuraEnabled public Decimal     tipoCambio;
        @AuraEnabled public String      interlocutor1;
        @AuraEnabled public String      interlocutor2;
        @AuraEnabled public String      interlocutor3;
        @AuraEnabled public String      interlocutor4;
        @AuraEnabled public String      interlocutor5;
        @AuraEnabled public String      interlocutor6;
        @AuraEnabled public String      interlocutor7;
        @AuraEnabled public String      interlocutor8;
        @AuraEnabled public String      interlocutor9;
        @AuraEnabled public String      interlocutor10;
        @AuraEnabled public String      apoderado1;
        @AuraEnabled public String      apoderado2;
        @AuraEnabled public String      motivoCompra;
        @AuraEnabled public String      importeCiChar;
        @AuraEnabled public String      indPorcentaje;
        @AuraEnabled public String      entrega;
        @AuraEnabled public String      fechaEntrega;
        @AuraEnabled public String      conversionArras;
        @AuraEnabled public Decimal     saldoOpSegura;
        @AuraEnabled public Decimal     montoOpSegura;
        @AuraEnabled public String      fechaVenOps;
        @AuraEnabled public Decimal     descuentoOps;
        @AuraEnabled public String      realizarDevolucionOps;
        @AuraEnabled public String      guardarMontoOps;
        @AuraEnabled public String      importeOcd;             //Formatear a Decimal
        @AuraEnabled public String      supervAsignado;
        @AuraEnabled public String      supervVenta;
        @AuraEnabled public Decimal     impCuotaLibreInicial;
        @AuraEnabled public String      indImpCuotaLibre;
        @AuraEnabled public Integer     noCuotasTotSi;
        @AuraEnabled public Integer     tipoInteres;
        @AuraEnabled public Integer     noCuotasMaxIl;
        @AuraEnabled public Integer     noCuotasTotFi;
        @AuraEnabled public Integer     cuotaFinalImp;
        @AuraEnabled public Decimal     tasaDiarioInteres;
        @AuraEnabled public Decimal     tasaDiarioGastos;
        @AuraEnabled public String      indAntInteres;
        @AuraEnabled public String      indConTasaDiaria;
        @AuraEnabled public Decimal     sumaDuration;
        @AuraEnabled public String      motivoTem;
        @AuraEnabled public String      indConTem;
    }
    public class Detalle{
        @AuraEnabled public Integer     proforma        { get; set; }
        @AuraEnabled public Integer     version;
        @AuraEnabled public Decimal     cuota           { get; set; }
        @AuraEnabled public Decimal     cuotaAux;
        @AuraEnabled public Integer     noDias;
        @AuraEnabled public Integer     noDiasAcu;
        @AuraEnabled public String      pagada;
        @AuraEnabled public String      tipoCuota       { get; set; }
        @AuraEnabled public Decimal     saldoInicial    { get; set; }
        @AuraEnabled public String      saldoInicialFormato    { get; set; }

        @AuraEnabled public Decimal     amortizacion    { get; set; }
        @AuraEnabled public String      amortizacionFormato    { get; set; }

        @AuraEnabled public Decimal     intereses       { get; set; }
        @AuraEnabled public String     interesesFormato       { get; set; }

        @AuraEnabled public Decimal     gastos;
        @AuraEnabled public Decimal     interesGastos   { get; set; }
        @AuraEnabled public String     interesGastosFormato   { get; set; }

        @AuraEnabled public Decimal     igv;
        @AuraEnabled public String      sujetoIntIgv;
        @AuraEnabled public Decimal     desempleo;
        @AuraEnabled public Decimal     seguroVida;
        @AuraEnabled public Decimal     impCuota        { get; set; }
        @AuraEnabled public String     impCuotaFormato        { get; set; }

        @AuraEnabled public String      waers;
        @AuraEnabled public Decimal     saldoFinal      { get; set; }
        @AuraEnabled public String     saldoFinalFormato      { get; set; }

        @AuraEnabled public String      fechaVencimiento    { get; set; }
        @AuraEnabled public String      fechaAlterna;
        @AuraEnabled public String      bukrs;
        @AuraEnabled public String      belnr;
        @AuraEnabled public Integer     gjahr;
        @AuraEnabled public String      fechaTcEntrega;
        @AuraEnabled public String      indCiLetra;
        @AuraEnabled public String      cuotaPagada;
        @AuraEnabled public String      fechaPago      { get; set; }
        @AuraEnabled public String      flagFacturado;
        @AuraEnabled public String      flagCompensado;
        @AuraEnabled public String      flagPagado      { get; set; }
        @AuraEnabled public Decimal     importeCuotaSap;
        @AuraEnabled public Decimal     descuentoPagoAdelantado;
        @AuraEnabled public String      fechaOperacion;
        @AuraEnabled public String      flagDevengado;
        @AuraEnabled public Decimal     importCancelado;
        @AuraEnabled public Decimal     importProtesto;
        @AuraEnabled public Decimal     importIntMoratorio;
        @AuraEnabled public Decimal     importComisiones;
        @AuraEnabled public Decimal     importPagoAdelantado;
        @AuraEnabled public String      flagEnvioBanco;
        @AuraEnabled public String      fechaEnvioBanco;
        @AuraEnabled public String      flagLargoPlazo;
        @AuraEnabled public Decimal     importeCuotaVencida;
        @AuraEnabled public String      usrcomppago;
        @AuraEnabled public String      flagCuotaRef;
        @AuraEnabled public Integer     porcentaje;
        @AuraEnabled public String      mlstn;
        @AuraEnabled public Decimal     impPendCuota;
        @AuraEnabled public Decimal     impPagoCuota;
        @AuraEnabled public Integer     noDiasAcuCs;
        @AuraEnabled public Decimal     noDiasCs;
        @AuraEnabled public Decimal     duration;
        @AuraEnabled public Decimal     va;
    }
    public class Mensaje{
        @AuraEnabled public String  type;
        @AuraEnabled public String  id;
        //@AuraEnabled public Integer number;
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
    public class Extras{
        @AuraEnabled public String estado;
        @AuraEnabled public String interesxPagSinPrepago;//Felipe campo nuevo
    }
    public static CEN_SimularPrepagoApi parse(String json) {
		return (CEN_SimularPrepagoApi) System.JSON.deserialize(json, CEN_SimularPrepagoApi.class);
	}
}