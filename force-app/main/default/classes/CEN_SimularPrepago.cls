/**
 * @description       : Clase controladora del lwc CEN_SimularPrepago
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 12-09-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * @last modified by  : Felipe Bermudez - NTT DATA / campo nuevo interesxPagSinPrepago y resumeninteresxPagSinPrepagoPDF
 * @last modified by  : Felipe Bermudez - NTT DATA / limitar renderizar EJECUTAR PREPAGO para callcenter mtd(isCallCenterUser)
**/
public with sharing class CEN_SimularPrepago {
    public static String responseSimulacionTest;
    /**
    * @description Retorna el resumen de financiamiento seleccionado previamente.
    * @author Richard Villafana - NTT DATA | 08-16-2024 
    * @param idCaso 
    * @return List<Financiamiento> 
    **/
    @AuraEnabled
    public static Prepago getResumenFinanciamiento(String idCaso){
        Case    casoActual  =   [SELECT Id, toLabel(CEN_TipoDePrepago__c), CEN_ImporteDeFinanciamiento__c, CEN_EstadoSAP__c, toLabel(CEN_EstadoFinanciamiento__c), CEN_FechaDePrepago__c
                                FROM Case
                                WHERE Id =: idCaso
                                WITH SECURITY_ENFORCED];
        Prepago  financiamiento  =   new Prepago();
        financiamiento.importeFinanciamiento    =   casoActual.CEN_ImporteDeFinanciamiento__c;
        financiamiento.tipoDePrepago            =   casoActual.CEN_TipoDePrepago__c;
        financiamiento.estadoSap                =   casoActual.CEN_EstadoSAP__c;
        financiamiento.fechaDePrepago           =   casoActual.CEN_FechaDePrepago__c;
        if(casoActual.CEN_EstadoFinanciamiento__c   !=  null){
            financiamiento.estadoFinanciamiento     =   casoActual.CEN_EstadoFinanciamiento__c;
        }else{
            financiamiento.estadoFinanciamiento     =   'Inactivo';
        }
        return financiamiento;
    }
    /**
    * @description Formateo de body de Request para el servicio de simulación y ejecución de prepago
    * @author Richard Villafana - NTT DATA | 09-11-2024 
    * @param tipoModo 
    * @param cuota 
    * @param idCaso 
    * @param montoFinanciamiento 
    * @return SimulacionDePrepago 
    **/
    @AuraEnabled
    public static SimulacionDePrepago getResumenCuotas(String tipoModo, String cuota, String idCaso, Decimal montoFinanciamiento, Date fecha, String idApoderado1, String idApoderado2){
        System.debug('fecha: '+fecha);
        CEN_Apoderado__c apoderado1;
        CEN_Apoderado__c apoderado2;
        Case    casoActual  =   [SELECT Id, CaseNumber, CEN_CodFinanciamiento__c, CEN_VersionFinanciamiento__c, CEN_FechaDePrepago__c
                                FROM Case
                                WHERE Id =: idCaso
                                WITH SECURITY_ENFORCED];
        casoActual.CEN_ImporteDeFinanciamiento__c           =   montoFinanciamiento;
        casoActual.CEN_FechaDePrepago__c                    =   fecha;
        SimularEjecutarPrepago  datosSimulacionEjecucion    =   new SimularEjecutarPrepago();
        String codFinanciamiento            =   casoActual.CEN_CodFinanciamiento__c;
        if(tipoModo         ==  'simularPrepagoRadio'  ){
            datosSimulacionEjecucion.modo   =   'SIMU';
        }else if(tipoModo    ==  'ejecutarPrepagoRadio'){
            datosSimulacionEjecucion.modo   =   'PROC';
            if(String.isNotBlank(idApoderado1)){
                casoActual.CEN_Apoderado1__c    =   idApoderado1;
                apoderado1  =   [SELECT Name, CEN_CodigoApoderado__c FROM CEN_Apoderado__c WHERE Id=: idApoderado1];
                datosSimulacionEjecucion.prepago.apoderadoCentenario1   =   apoderado1.CEN_CodigoApoderado__c;

            }
            if(String.isNotBlank(idApoderado2)){
                casoActual.CEN_Apoderado2__c    =   idApoderado2;
                apoderado2  =   [SELECT Name, CEN_CodigoApoderado__c FROM CEN_Apoderado__c WHERE Id=: idApoderado2];
                datosSimulacionEjecucion.prepago.apoderadoCentenario2   =   apoderado2.CEN_CodigoApoderado__c;
            }
        }
        datosSimulacionEjecucion.idIteracion            =   casoActual.CaseNumber;
        datosSimulacionEjecucion.prepago.proforma       =   codFinanciamiento;
        datosSimulacionEjecucion.prepago.version        =   casoActual.CEN_VersionFinanciamiento__c;
        datosSimulacionEjecucion.prepago.FechaPrepago   =   casoActual.CEN_FechaDePrepago__c.year() + '-' + String.valueOf(casoActual.CEN_FechaDePrepago__c.month()).leftPad (2, '0') + '-' + String.valueOf(casoActual.CEN_FechaDePrepago__c.day()).leftPad(2, '0');

        
        if(cuota    ==  'mantenerCuotaRadio'){
            datosSimulacionEjecucion.prepago.mantenerCuota  =   'X';
            casoActual.CEN_TipoDePrepago__c                 =   'Mantener Cuota';
        }
        if(cuota    ==  'disminuirCuentaRadio'){
            datosSimulacionEjecucion.prepago.disminuirCuota =   'X';
            casoActual.CEN_TipoDePrepago__c                 =   'Disminuir Cuenta';
        }
        datosSimulacionEjecucion.prepago.saldoInicialPrepago    =   montoFinanciamiento;
        String bodyRequest  =   JSON.serialize(datosSimulacionEjecucion);
        String bodyResponse;
            bodyResponse    =   callApiSimularEjecutarApi(bodyRequest);
        CEN_SimularPrepagoApi   simularResponse;
        
        simularResponse     =   CEN_SimularPrepagoApi.parse(bodyResponse);
        
        
        SimulacionDePrepago simulacion  =   calculateValoresDePrepago(simularResponse, montoFinanciamiento, cuota);
        simulacion.nroFinanciamiento    =   codFinanciamiento;
        List<datosPdf> datosPdf         =   new List<datosPdf>();
        for(CEN_SimularPrepagoApi.Detalle det: simulacion.detalles){
            datosPdf pdf                =   new datosPdf();
            pdf.cuota                   =   det.cuota;
            pdf.amortizacionFormato     =   det.amortizacionFormato;
            pdf.flagPagado              =   det.flagPagado;
            pdf.impCuotaFormato         =   det.impCuotaFormato;
            pdf.interesesFormato        =   det.interesesFormato;
            pdf.interesGastosFormato    =   det.interesGastosFormato;
            pdf.saldoFinalFormato       =   det.saldoFinalFormato;
            pdf.saldoInicialFormato     =   det.saldoInicialFormato;
            pdf.tipoCuota               =   det.tipoCuota;
            pdf.fechaVencimiento        =   det.fechaVencimiento;
            pdf.fechaPago               =   det.fechaPago;
            datosPdf.add(pdf);
        }
        casoActual.CEN_CuotasPrepagoPdf__c  =   JSON.serialize(datosPdf);
        if(simularResponse.extras.estado    ==  'COMPLETADO'    &&  tipoModo    ==  'ejecutarPrepagoRadio'){
            casoActual.CEN_EstadoSAP__c     =   'Completado';
        }
        try {
            update casoActual;
        } catch (Exception e) {
            System.debug('error: '+e);
        }
        //Obtener el id del request
        String idLog;
        idLog = Request.getCurrent().getRequestId();
        simulacion.idLog    =   idLog;
        return simulacion;
    }
    @AuraEnabled
    @future
    public static void relateCaseLog(String idCaso, String idLog){
        CEN_ServicesLog__c log  =   [SELECT CEN_caseId__c, Id, CEN_RequestId__c
                                    FROM CEN_ServicesLog__c
                                    WHERE CEN_RequestId__c =: idLog];
        if(log!=null){
            try {
                log.CEN_caseId__c   =   idCaso;
                update log;
            } catch (Exception e) {
                System.debug('Error al actualizar log con caso: '+e);
            }
        }
    }
    //clase para validar profile del usuario
    @AuraEnabled(cacheable=true)
    public static Boolean isCallCenterUser() {
        Id userId = UserInfo.getUserId();
        User u = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        return u.Profile.Name == 'CEN_Callcenter';
    }

    //Clases usadas para el request del servicio.
    public class SimularEjecutarPrepago{
        public String                   modo;
        public String                   idIteracion;
        public PrepagoSimularEjecutar   prepago     =   new PrepagoSimularEjecutar();
    }
    public class PrepagoSimularEjecutar{
        public String   proforma;
        public String   version;
        public String   disminuirCuota          =   '';
        public String   mantenerCuota           =   '';
        public Decimal  saldoInicialPrepago;
        public String   FechaPrepago;
        public String   apoderadoCentenario1    =   '';
        public String   apoderadoCentenario2    =   '';


    }
    /**
    * @description Cálculo de valores de resumen de prepago
    * @author Richard Villafana - NTT DATA | 09-11-2024 
    * @param simularResponse 
    * @param importeSimulado 
    * @param cuota 
    * @return SimulacionDePrepago 
    **/
    public static SimulacionDePrepago calculateValoresDePrepago(CEN_SimularPrepagoApi simularResponse, Decimal importeSimulado, String cuota){
        SimulacionDePrepago simulacion  =   new SimulacionDePrepago();
        //Importe Simulado
        simulacion.importeSimulado      =   'S/.'+ (importeSimulado.format().contains('.')?importeSimulado.format():(importeSimulado.format()+'.00'));
        //Número de cuotas
        if(simularResponse.detalle.size()>0){
            simulacion.totalDeCuotas    =   String.valueOf(Integer.valueOf(simularResponse.detalle[simularResponse.detalle.size()-1].tipoCuota.split('CS')[1]));
        }
        
        //Nueva Cuota   y
        //Fecha de Vencimiento de la próxima cuota
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado       ==  ''    &&    detalle.tipoCuota.contains('CS') ){
                simulacion.nuevaCuota       =   'S/.'+ (detalle.impCuota.format().contains('.')?detalle.impCuota.format():(detalle.impCuota.format()+'.00'));
                List<String> fecha          =   detalle.fechaVencimiento.split('-');
                simulacion.fechaVencimientoProximaCuota   =   Date.newInstance(Integer.valueOf(fecha[0]), Integer.valueOf(fecha[1]), Integer.valueOf(fecha[2])).format();
                break;
            }
        }
        //Cuota Actual
        //Interes por Pagar Antes
        Decimal interesesPorPagarAntes  =   0;
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado       ==  'X'    &&    detalle.tipoCuota.contains('CS') ){
                simulacion.cuotaActual  =   'S/.'+ (detalle.impCuota.format().contains('.')?detalle.impCuota.format():(detalle.impCuota.format()+'.00'));
                interesesPorPagarAntes  =   interesesPorPagarAntes  + detalle.intereses;
            }
        }
        simulacion.interesesPorPagarAntes   =   'S/.'+ (interesesPorPagarAntes.format().contains('.')?interesesPorPagarAntes.format():(interesesPorPagarAntes.format()+'.00'));
        //Última Cuota  y
        //Fecha de Vencimiento de la última cuota
        //Saldo Capital Despues
        //Interes por Pagar Despues
        Decimal saldoCapitalDespues         =   0;
        Decimal interesesPorPagarDespues    =   0;
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado       ==  ''    &&    detalle.tipoCuota.contains('CS') ){
                simulacion.ultimaCuota      =   'S/.'+ (detalle.impCuota.format().contains('.')?detalle.impCuota.format():(detalle.impCuota.format()+'.00'));
                List<String> fecha          =   detalle.fechaVencimiento.split('-');
                simulacion.fechaVencimientoUltimaCuota   =   Date.newInstance(Integer.valueOf(fecha[0]), Integer.valueOf(fecha[1]), Integer.valueOf(fecha[2])).format();
                saldoCapitalDespues         =   detalle.amortizacion + saldoCapitalDespues;
                interesesPorPagarDespues    =   interesesPorPagarDespues + detalle.intereses;
            }
        }
        simulacion.interesesPorPagarDespues   =   'S/.'+ (interesesPorPagarDespues.format().contains('.')?interesesPorPagarDespues.format():(interesesPorPagarDespues.format()+'.00'));

        simulacion.saldoDeCapitalDespues    =   'S/.'+ (saldoCapitalDespues.format().contains('.')?saldoCapitalDespues.format():(saldoCapitalDespues.format()+'.00'));
        //Capital Amortizado
        Decimal capitalAmortizado   =   0;
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado   ==  'X' ){
                capitalAmortizado   =    capitalAmortizado    +   detalle.amortizacion;
            }
        }
        simulacion.capitalAmortizado    =   'S/.'+ (capitalAmortizado.format().contains('.')?capitalAmortizado.format():(capitalAmortizado.format()+'.00'));
        
        //Saldo Capital
        Decimal saldoCapital        =   0;
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado   ==  '' ){
                saldoCapital        =    saldoCapital    +   detalle.amortizacion;
            }
        }
        simulacion.saldoDeCapital   =   'S/.'+ (saldoCapital.format().contains('.')?saldoCapital.format():(saldoCapital.format()+'.00'));
        //Prepago
        Decimal amortizacionPrepago =   0;
        for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
            if(detalle.flagPagado   ==  ''   &&    detalle.tipoCuota.contains('CP') ){
                simulacion.prepago  =    'S/.'+ (detalle.impCuota.format().contains('.')?detalle.impCuota.format():(detalle.impCuota.format()+'.00'));
                amortizacionPrepago =   detalle.amortizacion;
                break;
            }
        }
        //Capital Amortizado Despues
        Decimal capitalAmortizadoDespues = 0;
        capitalAmortizadoDespues            =   capitalAmortizado   +   amortizacionPrepago;
        simulacion.capitalAmortizadoDespues =   'S/.'+ (capitalAmortizadoDespues.format().contains('.')?capitalAmortizadoDespues.format():(capitalAmortizadoDespues.format()+'.00'));
        //Fecha de Término
        if(simularResponse.detalle.size()>0){
            List<String> fecha          =   simularResponse.detalle[simularResponse.detalle.size()-1].fechaVencimiento.split('-');
            simulacion.fechaDeTermino   =   Date.newInstance(Integer.valueOf(fecha[0]), Integer.valueOf(fecha[1]), Integer.valueOf(fecha[2])).format();
        }
        
        //Precio de Venta
        simulacion.precioDeVentas       =   'S/.'+ (simularResponse.cabecera.precio.format().contains('.')?simularResponse.cabecera.precio.format():(simularResponse.cabecera.precio.format()+'.00'));
        //Cuotas por pagar
        if(simularResponse.detalle.size()>0){
            Integer cuotasPorPagar      =   0;
            for(CEN_SimularPrepagoApi.Detalle detalle   :   simularResponse.detalle){
                if(detalle.flagPagado   ==  ''   &&    detalle.tipoCuota.contains('CS')){
                    cuotasPorPagar++;
                }
            }   
            simulacion.cuotasPorPagar       =   String.valueOf(cuotasPorPagar);
        }
        //Capital Amortizado
        if(simularResponse.mensaje.size()>0){
            for(CEN_SimularPrepagoApi.Mensaje mensaje : simularResponse.mensaje){
                if(simulacion.mensajeServicio ==null){
                    simulacion.mensajeServicio  =   mensaje.message;
                }else{
                    simulacion.mensajeServicio  =   simulacion.mensajeServicio  +   '\n' + mensaje.message;
                }
            }
        }
        //Tipo de Simulacion
        if(cuota    ==  'mantenerCuotaRadio'){
            simulacion.tipoSimulacion   =   'Reducción de tiempo';
        }
        else if(cuota    ==  'disminuirCuentaRadio'){
            simulacion.tipoSimulacion   =   'Reducción del valor de la cuota mensual';
        }
        //Formateo de valores de Detalles
        simulacion.detalles             =   simularResponse.detalle;
        Decimal totalInteres        =   0;
        Decimal totalAmortizacion   =   0;
        Decimal totalCuota          =   0;

        for(CEN_SimularPrepagoApi.Detalle det: simulacion.detalles){
            det.saldoInicialFormato     =   'S/.'+ (det.saldoInicial.format().contains('.')?det.saldoInicial.format():(det.saldoInicial.format()+'.00'));
            det.amortizacionFormato     =   'S/.'+ (det.amortizacion.format().contains('.')?det.amortizacion.format():(det.amortizacion.format()+'.00'));
            det.interesesFormato        =   'S/.'+ (det.intereses.format().contains('.')?det.intereses.format():(det.intereses.format()+'.00'));
            det.interesGastosFormato    =   'S/.'+ (det.interesGastos.format().contains('.')?det.interesGastos.format():(det.interesGastos.format()+'.00'));
            det.impCuotaFormato         =   'S/.'+ (det.impCuota.format().contains('.')?det.impCuota.format():(det.impCuota.format()+'.00'));
            det.saldoFinalFormato       =   'S/.'+ (det.saldoFinal.format().contains('.')?det.saldoFinal.format():(det.saldoFinal.format()+'.00'));

            List<String> fechaFormateada    =   det.fechaVencimiento.split('-');
            det.fechaVencimiento        =   fechaFormateada[2]+ '/'+fechaFormateada[1]+'/'+fechaFormateada[0];
            //Fecha en la que el cliente pagó
            if(det.fechaPago    ==  '0000-00-00' || det.fechaPago    ==  ''){
                det.fechaPago   =   '';
            }else {
                List<String> fechaPagoFormateada    =   det.fechaPago.split('-');
                det.fechaPago               =   fechaPagoFormateada[2]+ '/'+fechaPagoFormateada[1]+'/'+fechaPagoFormateada[0];
            }
            
            det.tipoCuota = det.tipoCuota.replaceAll('(?<=\\d)0(?=\\d)', '');
            totalInteres        =   det.intereses       +   totalInteres;
            totalAmortizacion   =   det.amortizacion    +   totalAmortizacion;
            totalCuota          =   det.impCuota        +   totalCuota;
        }
        CEN_SimularPrepagoApi.Detalle totales =new CEN_SimularPrepagoApi.Detalle();
        totales.tipoCuota           =   'TOTALES';
        totales.interesesFormato    =   'S/.'+ (totalInteres.format().contains('.')?totalInteres.format():(totalInteres.format()+'.00'));
        totales.amortizacionFormato =   'S/.'+ (totalAmortizacion.format().contains('.')?totalAmortizacion.format():(totalAmortizacion.format()+'.00'));
        totales.impCuotaFormato     =   'S/.'+ (totalCuota.format().contains('.')?totalCuota.format():(totalCuota.format()+'.00'));
        simulacion.detalles.add(totales);
        simulacion.estado   =   simularResponse.extras.estado; 
        // INICIO Bloque nuevo agregado Felipe campo nuevo servicio
        Decimal interesValue = simularResponse.extras.interesxPagSinPrepago != null ? Decimal.valueOf(simularResponse.extras.interesxPagSinPrepago) : 0; //Felipe
        simulacion.interesxPagSinPrepago2 = 'S/.' + (interesValue.format().contains('.')?interesValue.format():(interesValue.format()+'.00')); //Felipe
        System.debug('simulacion.interesxPagSinPrepago2'+simulacion.interesxPagSinPrepago2);
        // FIN Bloque nuevo agregado Felipe campo nuevo servicio
        return simulacion;
    }
     
    /**
    * @description Ejecutar la api de ejecución y simulación de prepago
    * @author Richard Villafana - NTT DATA | 09-11-2024 
    * @param jsonRequest 
    * @return String 
    **/
    public static String callApiSimularEjecutarApi(String jsonRequest){
        //String jsonRequest  =   '{"modo": "SIMU","idIteracion": "10","prepago": {"proforma": "59188","version": "10","disminuirCuota": "","mantenerCuota": "X","saldoInicialPrepago": "20000"}}';
        // Convertir el mapa a JSON 
        String resp;
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_SimularPrepago');
            callApi.setRequestBody(jsonRequest);
            callApi.setTimeout(120000);
            if(!Test.isRunningTest()){
                resp = (String) callApi.makeCallout().getParsedResponse();
            }else{
                resp    =   responseSimulacionTest;
            }
        } catch (Exception e) {
            System.debug('Error de petición: '+e);
        }
        return resp;
    }
    public String   importeSimulado   {get; set;}
    public String   resumeninteresxPagSinPrepagoPDF   {get; set;} //Felipe
    public String   cuotaActual       {get; set;}
    public String   nuevaCuota        {get; set;}
    public String   fechaDeTermino    {get; set;}
    public String   totalDeCuotas     {get; set;}
    public String   precioDeVentas    {get; set;}
    public String   capitalAmortizado {get; set;}
    public String   saldoDeCapital    {get; set;}
    public String   prepago           {get; set;}
    public String   ultimaCuota       {get; set;}
    public String   cuotasPorPagar    {get; set;}
    public Case     caso              {get; set;}
    public static String   idCaso            {get; set;}
    public List<datosPdf> detalles          {get; set;}
    public String   tipoDeSimulacion        {get; set;}
    public String   nroFinanciamiento       {get; set;}
    public String   vencimientoProximaCuota {get; set;}
    public String   vencimientoUltimaCuota  {get; set;}
    public String   capitalAmortizadoDespues  {get; set;}
    public String   saldoDeCapitalDespues   {get; set;}
    public String   interesesPorPagar       {get; set;}
    public String   interesesPorPagarDespues    {get; set;}
    public String     today                   { get; set; }

    //Método constructor
    public CEN_SimularPrepago() {
        this.importeSimulado    = ApexPages.currentPage().getParameters().get('importeSimulado');
        this.resumeninteresxPagSinPrepagoPDF    = ApexPages.currentPage().getParameters().get('resumeninteresxPagSinPrepagoPDF');//Felipe
        this.cuotaActual        = ApexPages.currentPage().getParameters().get('cuotaActual');
        this.nuevaCuota         = ApexPages.currentPage().getParameters().get('nuevaCuota');
        this.fechaDeTermino     = ApexPages.currentPage().getParameters().get('fechaDeTermino');
        this.totalDeCuotas      = ApexPages.currentPage().getParameters().get('totalDeCuotas');
        this.precioDeVentas     = ApexPages.currentPage().getParameters().get('precioDeVentas');
        this.capitalAmortizado  = ApexPages.currentPage().getParameters().get('capitalAmortizado');
        this.saldoDeCapital     = ApexPages.currentPage().getParameters().get('saldoDeCapital');
        this.prepago            = ApexPages.currentPage().getParameters().get('prepago');
        this.ultimaCuota        = ApexPages.currentPage().getParameters().get('ultimaCuota');
        this.cuotasPorPagar     = ApexPages.currentPage().getParameters().get('cuotasPorPagar');
        String idCasoCapturado  = ApexPages.currentPage().getParameters().get('idCaso');
        this.tipoDeSimulacion   = ApexPages.currentPage().getParameters().get('tipoDeSimulacion');
        this.nroFinanciamiento   = ApexPages.currentPage().getParameters().get('nroFinanciamiento');
        this.vencimientoProximaCuota    = ApexPages.currentPage().getParameters().get('vencimientoProximaCuota');
        this.vencimientoUltimaCuota = ApexPages.currentPage().getParameters().get('vencimientoUltimaCuota');
        this.precioDeVentas         = ApexPages.currentPage().getParameters().get('precioDeVentas');
        this.capitalAmortizado      = ApexPages.currentPage().getParameters().get('capitalAmortizado');
        this.capitalAmortizadoDespues   = ApexPages.currentPage().getParameters().get('capitalAmortizadoDespues');
        this.saldoDeCapital         = ApexPages.currentPage().getParameters().get('saldoDeCapital');
        this.saldoDeCapitalDespues  = ApexPages.currentPage().getParameters().get('saldoDeCapitalDespues');
        this.interesesPorPagar      = ApexPages.currentPage().getParameters().get('interesesPorPagar');
        this.interesesPorPagarDespues   = ApexPages.currentPage().getParameters().get('interesesPorPagarDespues');
        this.today                      = Date.today().format();

        System.debug('idCaso: '+ApexPages.currentPage().getParameters().get('idCaso'));
        System.debug('idCasoCapturado: '+idCasoCapturado);
        System.debug('tipoDeSimulacion: '+tipoDeSimulacion);


        this.caso =  [SELECT CaseNumber, CEN_CuotasPrepagoPdf__c FROM Case WHERE Id=:idCasoCapturado  WITH SECURITY_ENFORCED  LIMIT 1];

        if (this.caso.CEN_CuotasPrepagoPdf__c != null) {
            this.detalles = (List<datosPdf>) System.JSON.deserialize(this.caso.CEN_CuotasPrepagoPdf__c, List<datosPdf>.class);
        } else {
            this.detalles = new List<datosPdf>();
        }
        
    }
    public class datosPdf{
        public Decimal  cuota                   { get; set; }
        public String   tipoCuota               { get; set; }
        public String   saldoInicialFormato     { get; set; }
        public String   amortizacionFormato     { get; set; }
        public String   interesesFormato        { get; set; }
        public String   interesGastosFormato    { get; set; }
        public String   impCuotaFormato         { get; set; }
        public String   saldoFinalFormato       { get; set; }
        public String   flagPagado              { get; set; }
        public String   fechaVencimiento        { get; set; }
        public String   fechaPago        { get; set; }

    }
        /**
        * @description Método que genera el documento de pdf de la simulación de prepago.
        * @author Richard Villafana - NTT DATA | 09-11-2024 
        * @param importeSimulado 
        * @param cuotaActual 
        * @param nuevaCuota 
        * @param fechaDeTermino 
        * @param totalDeCuotas 
        * @param precioDeVentas 
        * @param capitalAmortizado 
        * @param saldoDeCapital 
        * @param prepago 
        * @param ultimaCuota 
        * @param cuotasPorPagar 
        * @param idCaso 
        * @return String 
        **/
    @AuraEnabled 
        public static String downloadPdf(String importeSimulado, String cuotaActual, String nuevaCuota, String fechaDeTermino, String totalDeCuotas, String precioDeVentas, String capitalAmortizado, 
        String saldoDeCapital, String prepago, String ultimaCuota, String cuotasPorPagar,  String idCaso,
        String tipoDeSimulacion, String nroFinanciamiento, String vencimientoProximaCuota, String vencimientoUltimaCuota,
         String capitalAmortizadoDespues, 
        String saldoDeCapitalDespues, String interesesPorPagar, String interesesPorPagarDespues, 
        String resumeninteresxPagSinPrepagoPDF2
        ) {
            PageReference pdfPage = Page.CEN_SimularPrepagoPdf;
            pdfPage.getParameters().put('importeSimulado',  importeSimulado);
            pdfPage.getParameters().put('cuotaActual',      cuotaActual);
            pdfPage.getParameters().put('nuevaCuota',       nuevaCuota);
            pdfPage.getParameters().put('fechaDeTermino',   fechaDeTermino);
            pdfPage.getParameters().put('totalDeCuotas',    totalDeCuotas);
            pdfPage.getParameters().put('precioDeVentas',   precioDeVentas);
            pdfPage.getParameters().put('capitalAmortizado',capitalAmortizado);
            pdfPage.getParameters().put('saldoDeCapital',   saldoDeCapital);
            pdfPage.getParameters().put('prepago',          prepago);
            pdfPage.getParameters().put('ultimaCuota',      ultimaCuota);
            pdfPage.getParameters().put('cuotasPorPagar',   cuotasPorPagar);
            pdfPage.getParameters().put('idCaso',           idCaso);
            pdfPage.getParameters().put('tipoDeSimulacion', tipoDeSimulacion);
            pdfPage.getParameters().put('nroFinanciamiento', nroFinanciamiento);
            pdfPage.getParameters().put('vencimientoProximaCuota',  vencimientoProximaCuota);
            pdfPage.getParameters().put('vencimientoUltimaCuota',   vencimientoUltimaCuota);
            pdfPage.getParameters().put('precioDeVentas',           precioDeVentas);
            pdfPage.getParameters().put('capitalAmortizado',        capitalAmortizado);
            pdfPage.getParameters().put('capitalAmortizadoDespues', capitalAmortizadoDespues);
            pdfPage.getParameters().put('saldoDeCapital',           saldoDeCapital);
            pdfPage.getParameters().put('saldoDeCapitalDespues',    saldoDeCapitalDespues);
            pdfPage.getParameters().put('interesesPorPagar',        interesesPorPagar);
            pdfPage.getParameters().put('interesesPorPagarDespues', interesesPorPagarDespues);
            pdfPage.getParameters().put('resumeninteresxPagSinPrepagoPDF', resumeninteresxPagSinPrepagoPDF2);




            System.debug('tipoDeSimulacion: '+tipoDeSimulacion);
            Blob pdfBlob;
            if(!Test.isRunningTest()){
                pdfBlob        =    pdfPage.getContentAsPDF();
            }else{
                pdfBlob        =    blob.valueOf('Unit.Test');
            }
            
            String base64Pdf    = EncodingUtil.base64Encode(pdfBlob);
            return base64Pdf;
        }
       
    /**
    * @description Generar documentos en Onbase
    * @author Richard Villafana - NTT DATA | 09-11-2024 
    * @param idCaso 
    * @return CEN_InvocableGenerarDocumentos.Response 
    **/
    @AuraEnabled
    public static CEN_InvocableGenerarDocumentos.Response generarDocumentosApi(String idCaso){
        List<CEN_InvocableGenerarDocumentos.Request>    listRequest     = new List<CEN_InvocableGenerarDocumentos.Request>();
        CEN_InvocableGenerarDocumentos.Request          requestx         = new CEN_InvocableGenerarDocumentos.Request();
        List<CEN_InvocableGenerarDocumentos.Response>   listResponse    = new List<CEN_InvocableGenerarDocumentos.Response>();
        CEN_InvocableGenerarDocumentos.Response         response        = new CEN_InvocableGenerarDocumentos.Response();

        Case caso   = [SELECT CaseNumber, CEN_CodFinanciamiento__c, CEN_DocumentosSAP__c, CEN_FechaHoraCargaDocumentosSAP__c
                        FROM Case
                        WHERE Id =: idCaso
                        WITH SECURITY_ENFORCED];
        if(caso.CEN_DocumentosSAP__c==null){
            requestx.idIteracion     =   caso.CaseNumber;
            requestx.proforma        =   caso.CEN_CodFinanciamiento__c;
            requestx.tipoProceso     =   'PREP';
            listRequest.add(requestx);
            listResponse    =   CEN_InvocableGenerarDocumentos.generateDocuments(listRequest);
            
            response                =   listResponse[0];
            //Obtener el id del request
            String idLog;
            idLog                   =   Request.getCurrent().getRequestId();
            response.idLog          =   idLog;
            if(response.codigoRespuesta     ==  'S'){
                response.codigoRespuesta                    =   'Éxito';
                List<String> fecha  =   response.fechaCarga.split('-');
                List<String> hora   =   response.horaCarga.split(':');
                caso.CEN_DocumentosSAP__c                =   response.urlDocumento;
                caso.CEN_FechaHoraCargaDocumentosSAP__c  =   Datetime.newInstance(Integer.valueOf(fecha[0]), Integer.valueOf(fecha[1]), Integer.valueOf(fecha[2]), 
                                                                                  Integer.valueOf(hora[0]), Integer.valueOf(hora[1]), Integer.valueOf(hora[2]));
                try {
                    update caso;
                } catch (Exception e) {
                    System.debug('Error generarDocumentosApi:'+e);
                }
            }else if(response.codigoRespuesta     ==  'E'){
                response.codigoRespuesta    =   'Error';
            }
        }else{
            response.codigoRespuesta    =   'Generado';
            response.fechaCarga         =   String.valueOf(caso.CEN_FechaHoraCargaDocumentosSAP__c.date().format());
            response.horaCarga          =   String.valueOf(caso.CEN_FechaHoraCargaDocumentosSAP__c.hour() + ':'+  caso.CEN_FechaHoraCargaDocumentosSAP__c.minute()+':'+ caso.CEN_FechaHoraCargaDocumentosSAP__c.second());
            response.mensajeRespuesta   =   'Generado anteriormente.';
            response.urlDocumento       =   caso.CEN_DocumentosSAP__c;
        }
        return response;
    }
    public class Prepago{
        @AuraEnabled public String  tipoDePrepago;
        @AuraEnabled public Decimal importeFinanciamiento;
        @AuraEnabled public String  estadoSap;
        @AuraEnabled public String  estadoFinanciamiento ;
        @AuraEnabled public Date    fechaDePrepago;

    }

    public class SimulacionDePrepago{
        @AuraEnabled public String importeSimulado;
        @AuraEnabled public String tipoSimulacion;
        @AuraEnabled public String cuotaActual;
        @AuraEnabled public String nuevaCuota;
        @AuraEnabled public String nroFinanciamiento;
        @AuraEnabled public String fechaDeTermino;
        @AuraEnabled public String fechaVencimientoProximaCuota;
        @AuraEnabled public String fechaVencimientoUltimaCuota;
        @AuraEnabled public String totalDeCuotas;
        @AuraEnabled public String cuotasPorPagar;
        @AuraEnabled public String precioDeVentas;
        @AuraEnabled public String capitalAmortizado;
        @AuraEnabled public String capitalAmortizadoDespues;
        @AuraEnabled public String saldoDeCapital;
        @AuraEnabled public String saldoDeCapitalDespues;
        @AuraEnabled public String interesesPorPagarAntes;
        @AuraEnabled public String interesesPorPagarDespues;
        @AuraEnabled public String prepago;
        @auraEnabled public String ultimaCuota;
        @AuraEnabled public String mensajeServicio;
        @AuraEnabled public String estado;
        @AuraEnabled public String interesxPagSinPrepago2;//Felipe
        @AuraEnabled public String idLog;
        

        @auraEnabled public List<CEN_SimularPrepagoApi.Detalle> detalles;
    }
    //BUSQUEDA DE APODERADOS
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String name) {
        return [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + name + '%') LIMIT 10];
    }
}