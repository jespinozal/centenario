/*
* Name: CEN_cls_VisorLotes
* Version: 1.0
* Descripción: clase controlador del componente CEN_Cotizador
* Fecha: 8/11/2020
* 14/01/2025: Se agrego validacion al campo Tipologia linea 432
* TestClass:
*  - TestClass
*  - Test_Controller
 * Ver   Date         Author        Modification
 * 1.0   26-01-2026   Felipe Bermudez Se agrego el generateAndUpdateOperationSafePeriodo para escenarios de financiamiento
*/
public with sharing class CEN_cls_VisorLotes {

    public class Levers {
        public String codigo;
        public String promocion;
        public String porcentaje;
        public String importe;
        public String moneda;
        public String descripcionPalanca;
        public Boolean aprobador;
    }

    public class Criteria {
        public Decimal importeAdicional;
        public Decimal importeEspecial;
        public Decimal porcentajeAdicional;
        public Decimal porcentajeEspecial;
        public String motivoInformativa;
    }

    public class LoteReceived {
        @AuraEnabled
        public Double Area { get; set; }
        @AuraEnabled
        public String Codestadolote { get; set; }
        @AuraEnabled
        public String Codlote { get; set; }
        @AuraEnabled
        public String Descripcioncorta { get; set; }
        @AuraEnabled
        public String Descripcionlote { get; set; }
        @AuraEnabled
        public String FillerStr02 { get; set; }
        @AuraEnabled
        public String Idproyecto { get; set; }
        @AuraEnabled
        public String Manzana { get; set; }
        @AuraEnabled
        public Integer Orden { get; set; }
        @AuraEnabled
        public Double PrecioVentaDscto { get; set; }
        @AuraEnabled
        public Double Precioventafun { get; set; }
        @AuraEnabled
        public Double Precioventam2fun { get; set; }
        @AuraEnabled
        public Boolean isChecked { get; set; }
        @AuraEnabled
        public Boolean isVisible { get; set; }
        @AuraEnabled
        public String Codmonedafuncional { get; set; }
    }

    public class data {
        @AuraEnabled
        public String codtasa { get; set; }
        @AuraEnabled
        public String tasa { get; set; }
        @AuraEnabled
        public String fechaDesembolso { get; set; }
        @AuraEnabled
        public String opcionDesembolso { get; set; }
        @AuraEnabled
        public String frecuenciaDesembolso { get; set; }
    }


    /**
     * @description
    ** Retorna todos los codigos de lotes disponibles a recotizar,
    ** ya que estan relacionados a la oportunidad y están en cotizaciones
    * @lastModifiedDate 20-07-2021
    * @param String recordId
    * @return List<String>
    **/
    @AuraEnabled
    public static List<String> getCodigosLotesRecotizables(String recordId){
        List<String> codigosLotesRelacionados = new List<String>(CEN_cls_utilsQuote.getCodLotesRelacionadosAoportunidad(recordId));
        return codigosLotesRelacionados;
    }

    @AuraEnabled
    public static CotizacionGeneradaWrapper getcreateCotiz(
        CEN_cls_utilsQuote.DatosPersonaWrapper datosPersona,
        List<LoteReceived> lotesList,
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotacionesList,
        String IdOportunidad,
        decimal area,
        decimal preciom2,
        decimal PrecioVenta,
        decimal precioTotalDscto,
        decimal Iniporcentajevalue,
        decimal Inicial,
        decimal ncuotasinicial,
        boolean bolMontoPrimeraCuota,
        decimal montocuota,
        boolean isFacilote,
        decimal monotofinan,
        decimal cuotasfinan,
        decimal numCuotasSI,
        String fecCuotaSaldoIni,
        String fecCuotaSaldoFin,
        decimal tasainteres,
        decimal monotocuotafinan,
        boolean esCotizacionLibre,
        decimal montoAdelanto,
        boolean bolMontoAdelanto,
        String moneda,
        String tipoVenta,
        boolean simulador,
        String idCotizacionSimulador,
        String jsonPalancas,
        boolean hasPermission,
        //String codTasa,
        //String tasa,
        data data,
        decimal montocuotarestfinan
        // String opcionDesembolso,
        // String fechaDesembolso
    ) {


        System.debug(LoggingLevel.INFO, datosPersona);
        System.debug(LoggingLevel.INFO, lotesList);
        System.debug(LoggingLevel.INFO, anotacionesList);
        System.debug(LoggingLevel.INFO, IdOportunidad);
        System.debug(LoggingLevel.INFO, area);
        System.debug(LoggingLevel.INFO, preciom2);
        System.debug(LoggingLevel.INFO, PrecioVenta);
        System.debug(LoggingLevel.INFO, Iniporcentajevalue);
        System.debug(LoggingLevel.INFO, Inicial);
        System.debug(LoggingLevel.INFO, ncuotasinicial);
        System.debug(LoggingLevel.INFO, bolMontoPrimeraCuota);
        System.debug(LoggingLevel.INFO, montocuota);
        System.debug(LoggingLevel.INFO, isFacilote);
        System.debug(LoggingLevel.INFO, monotofinan);
        System.debug(LoggingLevel.INFO, cuotasfinan);
        System.debug(LoggingLevel.INFO, numCuotasSI);
        System.debug(LoggingLevel.INFO, fecCuotaSaldoIni);
        System.debug(LoggingLevel.INFO, fecCuotaSaldoFin);
        System.debug(LoggingLevel.INFO, tasainteres);
        System.debug(LoggingLevel.INFO, monotocuotafinan);
        System.debug(LoggingLevel.INFO, esCotizacionLibre);
        System.debug(LoggingLevel.INFO, montoAdelanto);
        System.debug(LoggingLevel.INFO, bolMontoAdelanto);
        System.debug(LoggingLevel.INFO, moneda);
        System.debug(LoggingLevel.INFO, tipoVenta);
        System.debug(LoggingLevel.INFO, simulador);
        System.debug(LoggingLevel.INFO, idCotizacionSimulador);
        System.debug(LoggingLevel.INFO, jsonPalancas);
        System.debug(LoggingLevel.INFO, hasPermission);
        System.debug(LoggingLevel.INFO, data);
        System.debug(LoggingLevel.INFO, montocuotarestfinan);
        //System.debug(LoggingLevel.INFO, codTasa);
        //System.debug(LoggingLevel.INFO, tasa);
        // System.debug(LoggingLevel.INFO, opcionDesembolso);
        // System.debug(LoggingLevel.INFO, fechaDesembolso);

        Quote q;
        CotizacionGeneradaWrapper objCotizacionGeneradaWrapper = new CotizacionGeneradaWrapper();
        // if(simulador){
            Map<String, LoteReceived> lotesReceived_map = new Map<String, LoteReceived>();
            Opportunity oport = null;
            String codLotes = '';
            String manzanas = '';
            String lotes = '';
            String tipologias = '';

            for (Integer i = 0; i < lotesList.size(); i++) {
                lotesReceived_map.put(lotesList[i].Codlote, lotesList[i]);
                codlotes += lotesList[i].Codlote;
                manzanas += lotesList[i].Manzana;
                lotes += lotesList[i].Descripcionlote.substring(lotesList[i].Descripcionlote.length() - 5, lotesList[i].Descripcionlote.length());
                tipologias += lotesList[i].FillerStr02;
                if (i + 1 < lotesList.size()) {
                    codlotes += '/';
                    manzanas += '/';
                    lotes += '/';
                    tipologias += '/';
                }
            }


            List<String> productos_no_encontrados = new List<String>();
            List<Product2> productos = null;
            List<Product2> productos_to_update = new List<Product2>();
            Map<String, Product2> productos_map = new Map<String, Product2>();

            try {
                productos = [
                    SELECT
                    Id,
                    CODLOTE__c,
                    CODESTADOLOTE__c,
                    CEN_Proyecto__c,
                    DESCRIPCIONLOTE__c,
                    CEN_PRECIOVENTAFUN__c,
                    CODMONEDAFUNCIONAL__c
                    FROM Product2
                    WHERE CODLOTE__c IN :lotesReceived_map.keySet() AND CEN_Proyecto__r.name<>''
                ];
                for (Product2 pr : productos) {
                    productos_map.put(String.valueOf(Integer.valueOf(pr.CODLOTE__c)), pr);
                }

                // ACTUALIZA LOS ESTADOS DE LOTES QUE OBTUVE DEL SERVICIO
                for (LoteReceived lt : lotesList) {
                    productos_map.get(lt.Codlote).CODMONEDAFUNCIONAL__c = moneda;
                    if ((lt.Codestadolote.toUpperCase().equals('LIBRE') || lt.Codestadolote.toUpperCase().equals('L')) && productos_map.get(lt.Codlote) != null && (productos_map.get(lt.Codlote).CODESTADOLOTE__c != 'L' ||(productos_map.get(lt.Codlote).CODESTADOLOTE__c != null && productos_map.get(lt.Codlote).CODESTADOLOTE__c.toUpperCase() != 'LIBRE'))) {
                        productos_map.get(lt.Codlote).CODESTADOLOTE__c = 'L';
                        productos_to_update.add(productos_map.get(lt.Codlote));
                    } else if (productos_map.get(lt.Codlote) != null) {
                        productos_map.get(lt.Codlote).CODESTADOLOTE__c = lt.Codestadolote;
                        productos_to_update.add(productos_map.get(lt.Codlote));
                    } else if (productos_map.get(lt.Codlote) == null) {
                        productos_no_encontrados.add(lt.Descripcionlote);
                    }
                }
                update productos_to_update;
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
            }

            if (productos_no_encontrados != null && !productos_no_encontrados.isEmpty()) {
                String response_str = 'Error: ' + productos_no_encontrados[0];
                for (Integer i = 1; i < productos_no_encontrados.size(); i++) {
                    if (i + 1 >= productos_no_encontrados.size()) { response_str += ' y ' + productos_no_encontrados[i];}
                    else {response_str += ', ' + productos_no_encontrados[i];}
                }
                if (productos_no_encontrados.size() > 1) { response_str += ' no fueron encontrados en Salesforce.';}
                else { response_str += ' no fue encontrado en Salesforce.';}
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = response_str;
                objCotizacionGeneradaWrapper.detalle = response_str;
                return objCotizacionGeneradaWrapper;
            }
            //	Definiendo el tipo de venta de la oportunidad
            try {
                oport = [
                    SELECT
                    Id,
                    CEN_Proyecto__c,
                    CEN_Proyecto__r.CEN_MaximumTermForSigningTheContract__c,
                    CEN_Tipo_de_venta__c,
                    CEN_con_lote_desde_visor__c,
                    CEN_Inicial_de_precio__c,
                    CEN_N_Cuotas_de_inicial_de_precio__c,
                    CEN_Monto_cuota_de_inicial_de_precio__c,
                    CEN_Saldo_del_precio__c,
                    CEN_N_Cuotas_del_Saldo_del_precio__c,
                    CEN_Monto_Cuota_del_Saldo_de_precio__c,
                    CEN_Cuota_Facilote__c,
                    CEN_AmountAdvanceFee__c,
                    CEN_FirstInstallmentAmount__c,
                    CEN_ProformaVersion__c,
                    CEN_NumberInstallmentsSI__c,
                    CEN_dia_de_pago__c,
                    CEN_Motivo_de_Compra__c,
                    CEN_AmountPaidDate__c,
                    CreatedDate,
                    CEN_Discount__c,
                    CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__c,
                    OwnerId,
                    CEN_FechaDesembolso__c,
                    CEN_OpcionDesembolso__c,
                    CEN_FrecuenciaDesembolso__c
                    FROM Opportunity
                    WHERE Id = :IdOportunidad
                    LIMIT 1
                ];
                oport.CEN_Proyecto__c = productos[0].CEN_Proyecto__c;
                oport.CEN_con_lote_desde_visor__c = false;
                oport.CEN_NumberInstallmentsSI__c = numCuotasSI;

                if(oport.CEN_AmountPaidDate__c == 0){
                    Date dt = Date.newInstance(oport.CreatedDate.year(), oport.CreatedDate.month(), oport.CreatedDate.day());
                    Date newDate = dt.addDays(Integer.valueOf(oport.CEN_Proyecto__r.CEN_MaximumTermForSigningTheContract__c));
                    oport.CloseDate = newDate;
                }

                List<Quote> lstQuote = null;
                if(oport.CEN_ProformaVersion__c != null){
                    lstQuote = [SELECT Id, CEN_TypeOfSale__c FROM Quote WHERE OpportunityId =:oport.Id AND CEN_ProformaVersion__c =:oport.CEN_ProformaVersion__c  order by CreatedDate desc];
                }

                if ((bolMontoPrimeraCuota || bolMontoAdelanto)
                && lstQuote != null
                && lstQuote.size() > 0
                && lstQuote[0].CEN_TypeOfSale__c != tipoVenta
                ) {
                    objCotizacionGeneradaWrapper.ok = false;
                    objCotizacionGeneradaWrapper.mensaje = 'Error: Cambio de vía de financiamiento no activar [Primera Cuota de la Inicial] ó [Activar Adelanto Pago]';
                    objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje;
                    return objCotizacionGeneradaWrapper;
                }else if(PrecioVenta != precioTotalDscto
                && lstQuote != null
                && lstQuote.size() > 0
                && lstQuote[0].CEN_TypeOfSale__c != tipoVenta){
                    objCotizacionGeneradaWrapper.ok = false;
                    objCotizacionGeneradaWrapper.mensaje = 'Error: No se puede realizar un descuento cuando se cambia a otra Via de Financiamiento';
                    objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje;
                    return objCotizacionGeneradaWrapper;
                }else if(oport.CEN_dia_de_pago__c == null){
                    objCotizacionGeneradaWrapper.ok = false;
                    objCotizacionGeneradaWrapper.mensaje = 'Error: Seleccionar Día de Pago en la Oportunidad';
                    objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje;
                    return objCotizacionGeneradaWrapper;
                }else if(oport.CEN_Motivo_de_Compra__c == null){
                    objCotizacionGeneradaWrapper.ok = false;
                    objCotizacionGeneradaWrapper.mensaje = 'Error: Seleccionar Motivo de Compra en la Oportunidad';
                    objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje;
                    return objCotizacionGeneradaWrapper;
                }else{
                    oport.CEN_Tipo_de_venta__c = tipoVenta;
                    update oport;
                }
            } catch (Exception ex) {
                system.debug('ex: ' + ex.getMessage());
            }

            //	Buscando más datos del lote
            Pricebook2 standardPB = null;
            List<PricebookEntry> priceEntrys = null;
            Map<String, PricebookEntry> priceEntrys_map = new Map<String, PricebookEntry>();
            List<String> pbe_faltantes = new List<String>();
            try {
                if (!Test.isRunningTest()) {
                    standardPB = [
                        SELECT Id
                        FROM Pricebook2
                        WHERE isStandard = TRUE
                        LIMIT 1
                    ];
                    priceEntrys = [
                        SELECT id, Product2ID, Pricebook2Id, UnitPrice
                        FROM PricebookEntry
                        WHERE Product2ID IN :productos AND Pricebook2Id = :standardPB.Id
                    ];
                } else {
                    priceEntrys = [
                        SELECT id, Product2ID, Pricebook2Id, UnitPrice
                        FROM PricebookEntry
                        WHERE
                        Product2ID IN :productos
                        AND Pricebook2Id = :Test.getStandardPricebookId()
                    ];
                }
                for (PricebookEntry pbe : priceEntrys) {
                    priceEntrys_map.put(pbe.Product2Id, pbe);
                }
                for (Product2 pr : productos) {
                    if (
                        priceEntrys_map.get(pr.Id) == null &&
                        lotesReceived_map.get(
                            String.valueOf(Integer.valueOf(pr.CODLOTE__c))
                        ) != null
                    ) {
                        pbe_faltantes.add(
                            lotesReceived_map.get(
                                String.valueOf(Integer.valueOf(pr.CODLOTE__c))
                            )
                            .Descripcionlote
                        );
                    }
                }
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
            }

            if (standardPB == null && !Test.isRunningTest()) {
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: El Libro de precio estándar no fue encontrado en Salesforce.';
                objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje;
                return objCotizacionGeneradaWrapper;
            }

            if (pbe_faltantes != null && !pbe_faltantes.isEmpty()) {
                String response_str = 'Error: ' + pbe_faltantes[0];
                for (Integer i = 1; i < pbe_faltantes.size(); i++) {
                    if (i + 1 >= pbe_faltantes.size()) {response_str += ', ' + pbe_faltantes[i];}
                    else {response_str += ' y ' + pbe_faltantes[i]; }
                }
                if (pbe_faltantes.size() > 1) {response_str += ' no se les encontró la Entrada de catálogo de Precio en Salesforce.';}
                else {response_str += ' no se le encontró la Entrada de catálogo de Precio en Salesforce.'; }
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = response_str;
                objCotizacionGeneradaWrapper.detalle = response_str;
                return objCotizacionGeneradaWrapper;
            }

            //	Creando la cotización
            q = new Quote();
            q.Name = codlotes;
            q.OpportunityId = IdOportunidad;
            q.Pricebook2Id = Test.isRunningTest()? Test.getStandardPricebookId() : standardPB.Id;
            q.CEN_Area__c = area;
            q.CEN_Precio_por_mt2__c = preciom2;
            q.CEN_Precio_de_venta__c = PrecioVenta;
            q.CEN_Inicial__c = Inicial;
            q.CEN_Cuota_inicial__c = Inicial;
            q.CEN_FinanciamientoCuotasRestantes__c = montocuotarestfinan;
            q.CEN_Inicial_porct__c = Iniporcentajevalue;
            q.CEN_N_cuotas_de_inicial_de_precio__c = ncuotasinicial;
            q.CEN_Monto_cuota_de_inicial_de_precio__c = tipoVenta == 'CS' ? montocuota : bolMontoPrimeraCuota ? (Inicial - montocuota) / (ncuotasinicial - 1) : montocuota;
            q.CEN_Cuota_Facilote__c = isFacilote;
            q.CEN_Numero_de_cuotas_a_financiar__c = cuotasfinan == 0 ? numCuotasSI : cuotasfinan;
            q.CEN_N_cuotas_del_saldo_de_precio__c = cuotasfinan == 0 ? numCuotasSI : cuotasfinan;
            q.CEN_Tipologia__c = tipologias.length() > 255 ? tipologias.substring(0, 255) : tipologias;
            q.CEN_Lote__c = lotes;
            q.CEN_Manzana__c = manzanas;
            q.CEN_fld_Libre__c = esCotizacionLibre;
            q.CEN_Precio_de_venta_con_descuento__c = precioTotalDscto;
            q.CEN_Moneda__c = moneda;
            q.CEN_TypeOfSale__c = tipoVenta;
            q.CEN_FirstInstallmentAmount__c = bolMontoPrimeraCuota ? montocuota : 0;
            q.CEN_Simulator__c = simulador;
            q.CEN_NumberInstallmentsSI__c = numCuotasSI;
            q.CEN_CodigoTasa__c = data.tasa == '0' ? '' : data.codTasa;
            q.CEN_Tasa__c = data.tasa == '0' ? '' : data.tasa;
            q.CEN_Saldo_del_precio__c = monotofinan;
            q.CEN_Monto_cuota_del_saldo_de_precio__c = monotocuotafinan;
            q.CEN_Tasa_de_Interes_compensatorio_anual__c = tasainteres;
            if(fecCuotaSaldoIni != null && fecCuotaSaldoFin!= null){
                q.CEN_DateBalanceInstallment__c = Date.valueOf(fecCuotaSaldoIni);
                q.CEN_DateEndBalanceInstallment__c = Date.valueOf(fecCuotaSaldoFin);
            }

            if (anotacionesList != null) {
                q.CEN_fld_anotaciones__c = anotacionesAjson(anotacionesList);
            }
            if (datosPersona != null) {
                q.CEN_fld_nombres__c = datosPersona.nombres;
                q.CEN_fld_apellidos__c = datosPersona.apellidos;
                q.CEN_fld_tipoDocumento__c = datosPersona.tipoDocumento;
                q.CEN_fld_nroDocumento__c = datosPersona.nroDocumento;
                q.CEN_fld_celular__c = datosPersona.celular;
            }

            // --- Validación directa antes de insertar ---
            System.debug('Usuario actual: ' + UserInfo.getUserId());
            System.debug('Opportunity OwnerId: ' + q.OpportunityId);
            System.debug('Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);

            // Comprobar acceso a Opportunity
            Boolean puedeLeer = Schema.sObjectType.Opportunity.isAccessible();
            Boolean puedeEditar = Schema.sObjectType.Opportunity.isUpdateable();
            System.debug('Puede leer Opportunity: ' + puedeLeer);
            System.debug('Puede editar Opportunity: ' + puedeEditar);

            // Comprobar acceso a Quote
            Boolean puedeCrearQuote = Schema.sObjectType.Quote.isCreateable();
            System.debug('Puede crear Quote: ' + puedeCrearQuote);

            Opportunity oppCheck = [SELECT Id, OwnerId, StageName FROM Opportunity WHERE Id = :IdOportunidad LIMIT 1];

            if (!Schema.sObjectType.Opportunity.isUpdateable()) {
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: No tienes permisos para asociar una cotización a esta oportunidad.';
                objCotizacionGeneradaWrapper.detalle = 'Verifica permisos de edición sobre la oportunidad ' + oppCheck.Id;
                return objCotizacionGeneradaWrapper;
            }
            // --- Fin validación directa ---



            try {
                insert q;
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: No se pudo crear la Cotización en Salesforce.';
                objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje +' Exception: ' + ex.getMessage() +'. Line: ' + ex.getLineNumber() +'. Type: ' + ex.getTypeName();
                return objCotizacionGeneradaWrapper;
            }

            try{

                Integer divFacilote = isFacilote?2:1;
                oport.CEN_Cuota_Facilote__c = isFacilote;
                oport.CEN_Inicial_de_precio__c = Inicial;
                oport.CEN_N_Cuotas_de_inicial_de_precio__c = ncuotasinicial;
                Decimal toRound = montocuota/divFacilote;
                Decimal toRoundadvance = montoAdelanto >= toRound ?  montoAdelanto : toRound;
                oport.CEN_Monto_cuota_de_inicial_de_precio__c = toRoundadvance.setScale(2, RoundingMode.HALF_UP);
                oport.CEN_N_Cuotas_del_Saldo_del_precio__c = cuotasfinan == 0 ? numCuotasSI : cuotasfinan;
                oport.CEN_AmountAdvanceFee__c = montoAdelanto == 0 ? montoAdelanto : toRoundadvance.setScale(2, RoundingMode.HALF_UP);
                oport.CEN_Moneda__c = moneda;
                oport.CEN_FirstInstallmentAmount__c = bolMontoPrimeraCuota ? montocuota : 0;

                if(tipoVenta == 'CS'){
                    oport.CEN_MontoCuotaInicialPrecioEspejo__c = toRoundadvance.setScale(2, RoundingMode.HALF_UP);
                }else{
                    Decimal divi = (ncuotasinicial - 1) == 0 ? 1 : (ncuotasinicial - 1);
                    Decimal toRoundFirst = (Inicial - montocuota) / divi;
                    oport.CEN_MontoCuotaInicialPrecioEspejo__c = bolMontoPrimeraCuota ? toRoundFirst.setScale(2, RoundingMode.HALF_UP) : toRound.setScale(2, RoundingMode.HALF_UP);
                }

                oport.CEN_Simulator__c = simulador;
                oport.CEN_HasPermission__c = hasPermission;
                oport.CEN_motivoPalancaEspecial__c = '';
                oport.CEN_CarpetaDocumentacion__c = '';

                oport.CEN_Saldo_del_precio__c = monotofinan;
                oport.CEN_Monto_Cuota_del_Saldo_de_precio__c = monotocuotafinan;

                oport.CEN_OpcionDesembolso__c = null;
                oport.CEN_FechaDesembolso__c = null;
                oport.CEN_FrecuenciaDesembolso__c = null;
                oport.CEN_OpcionDesembolso__c = data.opcionDesembolso == null ? '' : data.opcionDesembolso;
                oport.CEN_FrecuenciaDesembolso__c = (data.frecuenciaDesembolso == null || data.frecuenciaDesembolso == '0') ? '' : data.frecuenciaDesembolso;
                if(data.fechaDesembolso != null) oport.CEN_FechaDesembolso__c = Date.valueOf(data.fechaDesembolso);

                update oport;
            }catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
            }

            Proyecto__c proyecto = null;
            String urbanizacion = '';
            String etapa = '';
            try {
                proyecto = [
                    SELECT Id, Name, CEN_Etapa__c
                    FROM Proyecto__c
                    WHERE Id = :productos[0].CEN_Proyecto__c
                    LIMIT 1
                ];
                urbanizacion = proyecto.Name;
                etapa = proyecto.CEN_Etapa__c;
                if (productos[0] != null &&String.isNotBlank(productos[0].DESCRIPCIONLOTE__c)) {
                    String description = productos[0].DESCRIPCIONLOTE__c.toUpperCase();
                    if (String.isBlank(etapa)) {
                        etapa = description.substringBetween('ETAPA', 'MZ.');
                        if (String.isNotBlank(etapa)) {etapa = etapa.trim();}
                    }
                    if (String.isBlank(urbanizacion)) {
                        urbanizacion = description.substringBefore('ETAPA');
                        if (String.isBlank(urbanizacion)) {urbanizacion = description.substringBefore('MZ.');}
                        if (String.isNotBlank(urbanizacion)) { urbanizacion = urbanizacion.trim();}
                    }
                }
                if (
                    productos[0] != null && String.isNotBlank(productos[0].CEN_Proyecto__c)
                ) {
                    try {
                        proyecto = [
                            SELECT Id, Name, CEN_Etapa__c
                            FROM Proyecto__c
                            WHERE Id = :productos[0].CEN_Proyecto__c
                            LIMIT 1
                        ];
                        urbanizacion = proyecto.Name;
                        etapa = proyecto.CEN_Etapa__c;
                        urbanizacion = urbanizacion.toUpperCase() .substringBefore('ETAPA').trim();
                    } catch (Exception ex) {
                        System.debug(
                            'Exception: ' +
                            ex.getMessage() +
                            '. Line: ' +
                            ex.getLineNumber() +
                            '. Type: ' +
                            ex.getTypeName()
                        );
                        objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.detalle ==null? ex.getMessage() : objCotizacionGeneradaWrapper.detalle + ex.getMessage();
                    }
                }
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
                objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.detalle == null ? ex.getMessage(): objCotizacionGeneradaWrapper.detalle + ex.getMessage();
            }

            //	Creando los lotes de la cotizacion
            List<QuoteLineitem> qlis = new List<QuoteLineitem>();
            String codlote_pr = '';
            LoteReceived lr = null;
            for (Product2 pr : productos) {
                codlote_pr = String.valueOf(Integer.valueOf(pr.CODLOTE__c));
                lr = lotesReceived_map.get(codlote_pr);
                QuoteLineitem q1 = new QuoteLineItem();
                q1.PricebookEntryId = priceEntrys_map.get(pr.Id).Id;
                q1.Quantity = 1;
                //q1.UnitPrice = priceEntrys_map.get(pr.Id).UnitPrice;
                q1.UnitPrice = lr.Precioventafun;
                q1.QuoteId = q.Id;
                if (lr != null) {
                    q1.CEN_area_del_lote__c = lr.Area;
                    q1.CEN_lote__c = lr.Descripcionlote.substring(
                        lr.Descripcionlote.length() - 5,
                        lr.Descripcionlote.length()
                    );
                    q1.CEN_manzana_del_lote__c = lr.Manzana.capitalize();
                    q1.CEN_precio_m2_cotizado_lote__c = lr.Precioventam2fun;
                    q1.CEN_precio_venta_cotizado_lote__c = lr.Precioventafun;
                    Decimal precioVtaDesc = lr.PrecioVentaDscto;
                    q1.CEN_fld_precioVentaDscto__c = precioVtaDesc.setScale(2, RoundingMode.HALF_UP);
                    q1.CEN_tipologia_del_lote__c = lr.FillerStr02.capitalize();
                }
                q1.CEN_urbanizacion_proyecto__c = urbanizacion;
                q1.CEN_etapa__c = etapa;
                q1.CEN_UnitPriceEspejo__c = lr.Precioventafun;
                q1.CEN_ListPriceEspejo__c = Decimal.valueOf(pr.CEN_PRECIOVENTAFUN__c);
                q1.CEN_SubtotalEspejo__c = lr.Precioventafun;
                q1.CEN_TotalPriceEspejo__c = lr.Precioventafun;
                qlis.add(q1);
                codlote_pr = '';
                lr = null;
            }

            try {
                insert qlis;
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );
                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: No se pudo crear las Partidas de Cotización en Salesforce.';
                objCotizacionGeneradaWrapper.detalle = objCotizacionGeneradaWrapper.mensaje + ex.getMessage();
                return objCotizacionGeneradaWrapper;
            }

            //	Limpiando los lotes de oportunidad
            List<OpportunityLineItem> Oppl = [
                SELECT id
                FROM OpportunityLineItem
                WHERE OpportunityID = :IdOportunidad
            ];
            try {
                delete Oppl;
            } catch (Exception ex) {
                System.debug(
                    'Exception: ' +
                    ex.getMessage() +
                    '. Line: ' +
                    ex.getLineNumber() +
                    '. Type: ' +
                    ex.getTypeName()
                );

                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: No se pudo quitar los Lotes de la Oportunidad de la anterior Cotización.';
                objCotizacionGeneradaWrapper.detalle = 'Error: No se pudo quitar los Lotes de la Oportunidad de la anterior Cotización.' +ex.getMessage();
                return objCotizacionGeneradaWrapper;
            }

            //	Creando los nuevos lotes de oportunidad
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            for (Product2 pr : productos) {
                OpportunityLineItem lineItem1 = new OpportunityLineItem();
                lineItem1.OpportunityID = IdOportunidad;
                lineItem1.PriceBookEntryID = priceEntrys_map.get(pr.Id).Id;
                lineItem1.quantity = 1;
                lineItem1.totalprice = lotesReceived_map.get(String.valueOf(Integer.valueOf(pr.CODLOTE__c))).Precioventafun;
                Decimal precioVtaDesc = lotesReceived_map.get(String.valueOf(Integer.valueOf(pr.CODLOTE__c))).PrecioVentaDscto;
                lineItem1.CEN_fld_precioVentaDscto__c = precioVtaDesc.setScale(2, RoundingMode.HALF_UP);
                olis.add(lineItem1);
            }

            try {
                insert olis;
            } catch (Exception ex) {
                System.debug( 'Exception: ' + ex.getMessage() + '. Line: ' + ex.getLineNumber() + '. Type: ' +ex.getTypeName());

                objCotizacionGeneradaWrapper.ok = false;
                objCotizacionGeneradaWrapper.mensaje = 'Error: No se pudo crear los Lotes de oportunidad en Salesforce.';
                objCotizacionGeneradaWrapper.detalle ='Error: No se pudo crear los Lotes de oportunidad en Salesforce.' +ex.getMessage();
                return objCotizacionGeneradaWrapper;
            }

            //Agregar Palancas
            if(String.isNotBlank(jsonPalancas)){
                List<Object> jsonArray = (List<Object>) JSON.deserializeUntyped(jsonPalancas);
                Map<String, Object> mapJson = (Map<String, Object>) jsonArray[0];
                Map<String, Object> mapJsonApprovers = (Map<String, Object>) jsonArray[1];
                List<Levers> lstDescuentos = (List<Levers>) JSON.deserialize(JSON.serialize(mapJson.get('levers')), List<Levers>.class);
                Criteria objCriteria = (Criteria) JSON.deserialize(JSON.serialize(mapJsonApprovers.get('criteria')), Criteria.class);
                List<CEN_DiscountLever__c> listPalancas = new List<CEN_DiscountLever__c>();

                Decimal totalPercentage = 0.00 ;
                Decimal totalAmount = 0.00;

                for (Levers objDescuento : lstDescuentos) {
                    CEN_DiscountLever__c palanca = new CEN_DiscountLever__c(
                    Name = objDescuento.descripcionPalanca,
                    CEN_DiscountPercentage__c = Decimal.valueOf(objDescuento.porcentaje),
                    CEN_ImporteDiscount__c=Decimal.valueOf(objDescuento.importe),
                    CEN_CodigoPalanca__c=objDescuento.codigo,
                    CEN_Promocion__c=objDescuento.promocion,
                    CEN_Moneda__c=objDescuento.moneda,
                    CEN_Opportunity__c = oport.Id,
                    CEN_QuoteId__c = q.Id,
                    CEN_ApprovalDiscountAdditional__c = (objCriteria.importeAdicional > 0 || objCriteria.importeEspecial > 0) ? oport.CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__c : oport.OwnerId
                    );

                    totalPercentage += Decimal.valueOf(objDescuento.porcentaje);
                    totalAmount += Decimal.valueOf(objDescuento.importe);

                    listPalancas.add(palanca);
                }

                Database.SaveResult[] srList = Database.insert(listPalancas, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted palanca. Palanca ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                            }
                    }
                }

                oport.CEN_DiscountApproval__c = 'No Requiere';
                oport.CEN_DiscountApprovalSpecial__c = 'No Requiere';
                oport.CEN_AmountDiscountAdditional__c = objCriteria.importeAdicional;
                oport.CEN_AmountDiscountSpecial__c = objCriteria.importeEspecial;
                oport.CEN_PercentageDiscountEspecial__c = objCriteria.porcentajeEspecial;
                oport.CEN_PercentageDiscountAdditional__c = objCriteria.porcentajeAdicional;
                oport.CEN_PerDiscount__c = totalPercentage;
                oport.CEN_Discount__c = totalAmount;
                oport.CEN_motivoPalancaEspecial__c = objCriteria.motivoInformativa;

                update oport;
            }

        // }else{

        //     q = [
        //         SELECT Id,
        //         Name,
        //         OpportunityId,
        //         Pricebook2Id,
        //         CEN_Area__c,
        //         CEN_Precio_por_mt2__c,
        //         CEN_Precio_de_venta__c,
        //         CEN_Inicial__c,
        //         CEN_Cuota_inicial__c,
        //         CEN_Inicial_porct__c,
        //         CEN_N_cuotas_de_inicial_de_precio__c,
        //         CEN_Monto_cuota_de_inicial_de_precio__c,
        //         CEN_Cuota_Facilote__c,
        //         CEN_Saldo_del_precio__c,
        //         CEN_Numero_de_cuotas_a_financiar__c,
        //         CEN_N_cuotas_del_saldo_de_precio__c,
        //         CEN_Tasa_de_Interes_compensatorio_anual__c,
        //         CEN_Monto_cuota_del_saldo_de_precio__c,
        //         CEN_Tipologia__c,
        //         CEN_Lote__c,
        //         CEN_Manzana__c,
        //         CEN_fld_Libre__c,
        //         CEN_Precio_de_venta_con_descuento__c,
        //         CEN_Moneda__c,
        //         CEN_TypeOfSale__c,
        //         CEN_FirstInstallmentAmount__c,
        //         CEN_Simulator__c,
        //         CEN_NumberInstallmentsSI__c,
        //         CEN_DateBalanceInstallment__c,
        //         CEN_DateEndBalanceInstallment__c,
        //         CEN_fld_anotaciones__c,
        //         CEN_fld_nombres__c,
        //         CEN_fld_apellidos__c,
        //         CEN_fld_tipoDocumento__c,
        //         CEN_fld_nroDocumento__c,
        //         CEN_fld_celular__c
        //         //CEN_Discount__c
        //         FROM Quote
        //         WHERE Id =: idCotizacionSimulador
        //         ORDER BY CreatedDate desc];

        //     q.CEN_Tasa_de_Interes_compensatorio_anual__c = tasainteres;
        //     q.CEN_Saldo_del_precio__c = monotofinan;
        //     q.CEN_Monto_cuota_del_saldo_de_precio__c = monotocuotafinan;
        //     q.CEN_Simulator__c = simulador;

        //     if(fecCuotaSaldoIni != null && fecCuotaSaldoFin!= null){
        //         q.CEN_DateBalanceInstallment__c = Date.valueOf(fecCuotaSaldoIni);
        //         q.CEN_DateEndBalanceInstallment__c = Date.valueOf(fecCuotaSaldoFin);
        //     }

        //     update q;

        //     Opportunity opp = [
        //         SELECT
        //         Id,
        //         CEN_Saldo_del_precio__c,
        //         CEN_MontoCuotaInicialPrecioEspejo__c,
        //         CEN_Monto_cuota_de_inicial_de_precio__c,
        //         CEN_Monto_cuota_del_saldo_de_precio__c,
        //         CEN_Proyecto__r.Name,
        //         CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__c,
        //         OwnerId
        //         FROM Opportunity
        //         WHERE Id =: IdOportunidad
        //     ];

        //     opp.CEN_Saldo_del_precio__c = monotofinan;
        //     opp.CEN_Monto_Cuota_del_Saldo_de_precio__c = monotocuotafinan;
        //     opp.CEN_Simulator__c = simulador;

        //     update opp;

        if(!simulador){
            //Eliminar Carpeta Descuentos
            List<CEN_Folder__c> listFolder = [SELECT Id FROM CEN_Folder__c WHERE Name = 'Descuento Especial' AND Opportunity__c  =: IdOportunidad];
            if(listFolder.size() > 0)delete listFolder;

            //Limpiando Quotes simuladas
            if(label.CEN_lbl_idOportunidadGenerica != IdOportunidad){
                List<Quote> quoteList = [
                    SELECT Id
                    FROM Quote
                    WHERE OpportunityId =:IdOportunidad AND CEN_Simulator__c = true order by CreatedDate desc
                ];
                try {
                    delete quoteList;
                } catch (Exception ex) {
                    System.debug(
                        'Exception: ' +
                        ex.getMessage() +
                        '. Line: ' +
                        ex.getLineNumber() +
                        '. Type: ' +
                        ex.getTypeName()
                    );

                    objCotizacionGeneradaWrapper.ok = false;
                    objCotizacionGeneradaWrapper.mensaje = 'Error: No se pudo quitar las cotizaciones de la Oportunidad.';
                    objCotizacionGeneradaWrapper.detalle = 'Error: No se pudo quitar las cotizaciones de la Oportunidad.' +ex.getMessage();
                    return objCotizacionGeneradaWrapper;
                }
            }
        }

        objCotizacionGeneradaWrapper.ok = true;
        objCotizacionGeneradaWrapper.cotizacion = q;
        objCotizacionGeneradaWrapper.idCotizacionGenerado = q.Id;
        return objCotizacionGeneradaWrapper;
    }

    @AuraEnabled
    public static Map<String, String>  generateAndUpdateOperationSafe(String IdOportunidad, Boolean simulador) {
        Map<String, String> generatedMapResp = new Map<String, String>();
        Opportunity oppData = [SELECT Id,Name,CEN_Proyecto__r.CEN_Sociedad__c,CEN_Proyecto__r.CEN_CODIGOSAP__c,CloseDate,CEN_Motivo_de_Compra__c, LeadSource,
        CEN_Medio_Publicitario__c,CEN_Oficina_de_Venta__c,CEN_Inicial_de_precio__c,Account.CEN_Numero_de_documento_del__c,
        Account.CEN_N_mero_de_documento__pc,Account.CEN_BankClient__c,Account.CEN_LocalAccountNumber__c,Account.CEN_InterbankAccountNumber__c,
        CEN_Tipo_de_venta__c,CEN_N_Cuotas_del_Saldo_del_precio__c,CEN_N_Cuotas_de_inicial_de_precio__c,CEN_ProformaVersion__c,CEN_NumberInstallmentsSI__c,
        CEN_fld_totalPrecioVentaDscto__c,Owner.EmployeeNumber,CEN_LotsRemoved__c,CEN_MaximumPaymentDate__c,CEN_Proforma__c,CEN_Cuota_Facilote__c,
        CEN_dia_de_pago__c,CEN_devolucion_saldo_Afavor__c,OwnerId,Owner.Manager.Email,Owner.Manager.DelegatedApproverId, CEN_MessageError__c,CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c,
        Amount,CEN_LastApiCall__c,CEN_AmountAdvanceFee__c, CEN_Monto_cuota_de_inicial_de_precio__c, CEN_Processing__c, CEN_FirstInstallmentAmount__c,
        CEN_Moneda__c, CEN_Simulator__c, Owner.Name, CEN_Discount__c, CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__r.Name, CEN_HasPermission__c,
        CEN_OpcionDesembolso__c,CEN_FechaDesembolso__c, CEN_FrecuenciaDesembolso__c
        FROM Opportunity
        WHERE Id = :IdOportunidad];
        CEN_OperactionSafeObjectResponse resp = CEN_OperactionSafe_cls.generateOperationByOppId(oppData, false, null);
        String errorType = resp.ET_RETURN != null ? resp.ET_RETURN.item[0].TYPE_x : 'S';
        generatedMapResp.put('success', JSON.Serialize(resp));
        generatedMapResp.put('errorType', errorType);
        return generatedMapResp;
    }

    //Periodos
    @AuraEnabled
    public static Map<String, String>  generateAndUpdateOperationSafePeriodo(String IdOportunidad, Boolean simulador) {
        Map<String, String> generatedMapResp = new Map<String, String>();
        Opportunity oppData = [SELECT Id,Name,CEN_Proyecto__r.CEN_Sociedad__c,CEN_Proyecto__r.CEN_CODIGOSAP__c,CloseDate,CEN_Motivo_de_Compra__c, LeadSource,
        CEN_Medio_Publicitario__c,CEN_Oficina_de_Venta__c,CEN_Inicial_de_precio__c,Account.CEN_Numero_de_documento_del__c,
        Account.CEN_N_mero_de_documento__pc,Account.CEN_BankClient__c,Account.CEN_LocalAccountNumber__c,Account.CEN_InterbankAccountNumber__c,
        CEN_Tipo_de_venta__c,CEN_N_Cuotas_del_Saldo_del_precio__c,CEN_N_Cuotas_de_inicial_de_precio__c,CEN_ProformaVersion__c,CEN_NumberInstallmentsSI__c,
        CEN_fld_totalPrecioVentaDscto__c,Owner.EmployeeNumber,CEN_LotsRemoved__c,CEN_MaximumPaymentDate__c,CEN_Proforma__c,CEN_Cuota_Facilote__c,
        CEN_dia_de_pago__c,CEN_devolucion_saldo_Afavor__c,OwnerId,Owner.Manager.Email,Owner.Manager.DelegatedApproverId, CEN_MessageError__c,CEN_Proyecto__r.CEN_MaximumPaymentDuePeriod__c,
        Amount,CEN_LastApiCall__c,CEN_AmountAdvanceFee__c, CEN_Monto_cuota_de_inicial_de_precio__c, CEN_Processing__c, CEN_FirstInstallmentAmount__c,
        CEN_Moneda__c, CEN_Simulator__c, Owner.Name, CEN_Discount__c, CEN_Proyecto__r.CEN_ApprovalDiscountAdditional__r.Name, CEN_HasPermission__c,
        CEN_OpcionDesembolso__c,CEN_FechaDesembolso__c, CEN_FrecuenciaDesembolso__c
        FROM Opportunity
        WHERE Id = :IdOportunidad];
        CEN_OperactionSafeObjectResponse resp = CEN_OperactionSafe_cls.generateOperationByOppIdPeriodos(oppData, false, null);
        String errorType = resp.ET_RETURN != null ? resp.ET_RETURN.item[0].TYPE_x : 'S';
        generatedMapResp.put('success', JSON.Serialize(resp));
        generatedMapResp.put('errorType', errorType);
        return generatedMapResp;
    }


    @AuraEnabled
    public static List<Id> uploadFile(list<Object> filesToInsert, String recordId) {
        //REGISTRAR FOLDER
        CEN_Folder__c folder = new CEN_Folder__c();
        folder.Name = 'Descuento Especial';
        folder.CEN_Alias_Folder__c = 'Descuento Especial';
        folder.Opportunity__c = recordId;
        insert folder;

        Opportunity opp = [SELECT Id,CEN_CarpetaDocumentacion__c FROM Opportunity WHERE Id =:recordId LIMIT 1];
        opp.CEN_CarpetaDocumentacion__c = folder.Id;
        update opp;

        List<Id> cvList = CEN_UploadFiles_ctr.saveFiles(filesToInsert);
        List<ContentDocumentLink> cdlList = CEN_UploadFiles_ctr.createContentLink(cvList, folder.Id);
        if (cvList == null || cdlList == null) { return null; }
        return cvList;
    }

    @AuraEnabled
    public static boolean checkPermission(String permissionSetName) {
        // Obtener la ID del usuario actual
        Id userId = UserInfo.getUserId();
        // Obtener el ID del permission set
        String permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1].Id;

        // Verificar si el usuario tiene el permiso del permission set
        return [SELECT count() FROM PermissionSetAssignment
                WHERE PermissionSetId = :permissionSetId AND AssigneeId = :userId] > 0;
    }

    @AuraEnabled
    public static void getCotizacionPDF(String idCotizacion,String idOportunidad) {
        generarPDF(idCotizacion, idOportunidad);
    }
    @future(callout=true)
    public static void generarPDF(String idCotizacion, String idOportunidad) {
        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        PageReference pdfPage = (PageReference) Page.CEN_vf_pdfPlantillaCotizador;
        pdfPage.getParameters().put('Id', idCotizacion);

        try {
            if (Test.isRunningTest()) {pdfGenerado = blob.valueOf('Unit.Test');}
            else {pdfGenerado = pdfPage.getContentAsPDF(); }

            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idCotizacion;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }

            insert listAttachments;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' +e.getTypeName() + '. Line: ' +e.getLineNumber());
        }
    }

    @AuraEnabled(cacheable = true)
    public static DatosPersonaWrapper getDatosCliente(String idOportunidad) {
        DatosPersonaWrapper objDatosPersonaWrapper = new DatosPersonaWrapper();
        Account cliente = null;
        Opportunity oportunidad = null;
        try {
            oportunidad = [
                SELECT Id, AccountId
                FROM Opportunity
                WHERE Id = :idOportunidad
            ];
            cliente = [
                SELECT
                Id,
                FirstName,
                LastName,
                Name,
                CEN_Tipo_de_documento__pc,
                CEN_Tipo_de_documento__c,
                CEN_N_mero_de_documento__pc,
                CEN_Numero_de_documento_del__c,
                PersonMobilePhone,
                Phone,
                IsPersonAccount
                FROM Account
                WHERE Id = :oportunidad.AccountId
            ];
            if (cliente.IsPersonAccount) {
                objDatosPersonaWrapper.datosPersona.nombres = cliente.FirstName;
                objDatosPersonaWrapper.datosPersona.apellidos = cliente.LastName;
                objDatosPersonaWrapper.datosPersona.nroDocumento = cliente.CEN_N_mero_de_documento__pc;
                objDatosPersonaWrapper.datosPersona.celular = cliente.PersonMobilePhone;
                objDatosPersonaWrapper.datosPersona.tipoDocumento = cliente.CEN_Tipo_de_documento__pc;
            }
            objDatosPersonaWrapper.ok = true;
        } catch (Exception e) {
            objDatosPersonaWrapper.ok = false;
            objDatosPersonaWrapper.detalle = 'Exception: ' + e.getMessage() + '. Line: ' +e.getLineNumber() +'. Type: ' +e.getStackTraceString();}
        return objDatosPersonaWrapper;
    }
    @AuraEnabled(cacheable = true)
    public static CEN_cls_utilsQuote.ListatipoDocumentoWrapper getListaTipoDocumentos() {
        return CEN_cls_utilsQuote.getListaTipoDocumentos();
    }
    private static String anotacionesAjson(List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotacionesList) {
        String jsonAnotaciones = null;
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotacionPorGuardar = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
        try {
            Integer key = 1;
            for ( CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion : anotacionesList) {
                if (String.isNotBlank(anotacion.anotaciones) || anotacion.fecha != null ||anotacion.monto != null ) {
                    anotacion.key = key;
                    anotacionPorGuardar.add(anotacion);
                    key++;
                }
            }
        } catch (Exception ex) {
        }
        if (!anotacionPorGuardar.isEmpty()) {jsonAnotaciones = JSON.serialize(anotacionPorGuardar);}
        return jsonAnotaciones;
    }

    public class CotizacionGeneradaWrapper extends ResponseWrapper {
        @AuraEnabled
        public String idCotizacionGenerado;
        @AuraEnabled
        public Quote cotizacion;
        public CotizacionGeneradaWrapper() {
            this.ok = false;
            this.mensaje = '';
            this.detalle = '';
            this.cotizacion = null;
            this.idCotizacionGenerado = null;
        }
    }
    public class DatosPersonaWrapper extends ResponseWrapper {
        @AuraEnabled
        public CEN_cls_utilsQuote.DatosPersonaWrapper datosPersona;
        public DatosPersonaWrapper() {
            this.datosPersona = new CEN_cls_utilsQuote.DatosPersonaWrapper();
            this.ok = false;
        }
    }

    @AuraEnabled
    public static List<Tasa_variable__mdt> getTasasMdt(String zona){
        List<Tasa_variable__mdt> tasas = [SELECT Id, Numero_cuota_minima__c, Numero_cuota_maxima__c, Tasa__c, Zona__c FROM Tasa_variable__mdt WHERE Zona__c = :zona];
        return tasas;
    }

    @AuraEnabled
    public static List<Cuota_Facilote_Permitida__mdt> getCuotasFacilote(){
        List<Cuota_Facilote_Permitida__mdt> cuotas = [SELECT Id, Numero_cuotas__c FROM Cuota_Facilote_Permitida__mdt ORDER BY Numero_cuotas__c DESC];
        return cuotas;
    }

    @AuraEnabled(cacheable = true)
    public static Opportunity getOpportunityData(Id oppId){

        Opportunity oppData = [ SELECT Id, Name, CEN_Tipo_de_venta__c, RecordTypeId
                                FROM Opportunity
                                WHERE Id = :oppId];

        return oppData;
    }

    @AuraEnabled(cacheable = true)
    public static String picklistValues(){
        List<PicklistValue> picklistValues = new List<PicklistValue>();
        Schema.DescribeFieldResult fieldResult = Opportunity.CEN_Tipo_de_venta__c.getDescribe();
		List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry pickListVal : values){
            PicklistValue pv = new PicklistValue();
            pv.value = pickListVal.value;
            pv.label = pickListVal.label;
			picklistValues.add(pv);
		}

        return JSON.Serialize(picklistValues);
    }

    public class PicklistValue{
        public String value;
        public String label;
    }

    @AuraEnabled
    public static List<PickListWrapper> getTipoVenta(){

        List<PickListWrapper> picklist = new List<PickListWrapper>();
        Schema.sObjectField picklistUsingGlobal = null;
        List<Schema.PicklistEntry> entries = null;

        picklistUsingGlobal = Opportunity.CEN_Tipo_de_venta__c;

        entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry spe:entries){
            if(spe.isActive()){
                PickListWrapper plw = new PickListWrapper();
                plw.label = spe.getLabel().toUpperCase();
                plw.value = spe.getValue();
                plw.selected = false;
                picklist.add(plw);
            }
        }
        return picklist;
    }
    public class PickListWrapper{
        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public Boolean selected{get;set;}
    }

}