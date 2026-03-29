({
  doInit: function (component, event, helper) {
    helper.obtenerTiposDocumentoCotizacion(component);
    helper.setDatosPersona(component);
    helper.getCuotasFaciloteHelper(component);
    console.log("Ingreso a doInit");
    helper.getTypeOfSale(component);
    helper.validatePermissionSet(component);
    helper.validatePermissionAdditionalSet(component);
  },

  onChangeDatosOportunidad: function (component, event, helper) {
    var IdOportunidad = component.get("v.IdOportunidad");
    helper.getDatosClienteOportunidad(component, IdOportunidad);
    helper.getLotesRelacionadosAoportunidad(component, IdOportunidad);
  },

  onChangeLotesList: function (component, event, helper) {
    var pageCotizador = component.get("v.pageCotizador");
    console.log('pageCotizador: ' + pageCotizador);
    if (pageCotizador) {

      console.log("Ingreso a onChangeLotesList");
      component.set("v.disabledBtnGenerarFinanciamento", true);
      component.set("v.disabledBtnSimuladorPrepago", true);
      component.set("v.disabledBtnGestionDescuento", true);
      // component.set("v.disabledTasa",false);
      component.set("v.totalPercentage", 0.00);
      component.set("v.totalDiscount", 0.00);
      component.set("v.iniPorcentajePrimeraCuota", 0.00);
      component.set("v.montoDeCuotas", 0.00);

      //component.set("v.data", null);
      component.set("v.flagDesembolso", false);
      component.set("v.selectedFrecuencia", "");
      component.set("v.selectedOpcionFecha", "");
      component.set("v.opcionDesembolso", "");
      component.set("v.fechaDesembolso", "");
      component.set("v.disabledOpcion", false);
      var action2 = component.get("c.onChangeFrecuencia");
      $A.enqueueAction(action2);

      // var fieldMap = [];
      // fieldMap.push({value: 0.00, label: 'Seleccione una Tasa', selected : true});
      // component.set("v.optionsTasa", fieldMap);

      var lotesList = component.get("v.lotesList");

      for (var i in lotesList) {
        lotesList[i].Discount = 0.0;
        //lotesList[i].PrecioVentaDsctoAux = 0.0;
        lotesList[i].PrecioVentaDscto = lotesList[i].Precioventafun;
      }
      component.set("v.lotesList", lotesList);
      helper.calcularCambiosDesdeLote(component);

      if(lotesList[0].Codmonedafuncional.toUpperCase() == 'PEN'){
        component.set("v.moneda",'S/');
      }else{
        component.set("v.moneda", '$');
      }

      //SELECCIONAR FRECUENCIA
      var fieldMapFrecuencia = [];
      fieldMapFrecuencia.push({value: "0", label: 'Seleccione Frecuencia', selected : true});
      fieldMapFrecuencia.push({value: "1", label: 'Mensual', selected : false});
      // fieldMapFrecuencia.push({value: "2", label: 'Bimensual', selected : false});
      // fieldMapFrecuencia.push({value: "3", label: 'Trimestral', selected : false});
      component.set("v.optionsFrecuencia",fieldMapFrecuencia);

      //SELECCIONAR TIPO DE VENTA
      var tipoVenta = component.get("v.tipoVenta");
      if(tipoVenta == null){
        component.find("slcTypeOfSale").set("v.value","CD");
      }else{
        component.find("slcTypeOfSale").set("v.value",tipoVenta);
      }
      var action = component.get("c.onChangeTypeOfSale");
      $A.enqueueAction(action);

    }
  },

  updatePreciosLote: function (component, event, helper) {
    helper.calcularCambiosDesdeLote(component);
    helper.calcularFinanciamientoDesdeLotes(component);
  },

  /**
   *  cada vez que se actualice el proyecto podrian actualizar la tasa interes
   * @param {*} component
   * @param {*} event
   * @param {*} helper
   */
  onChangeProyecto: function (component, event, helper) {
       // cada vez que se actualice el proyecto podrian actualizar la tasa interes
       // usando la data iniciial cargada del atributo zonasProyecto
       var proyecto = component.get("v.proyecto");
       if(proyecto && proyecto.Zona__c!=NaN && proyecto.Zona__c!=null){
         helper.getCMTtasasInteres(component, proyecto.Zona__c);
       }
  },

  inputInicial: function (component, event, helper) {

    var porcentajePrimeraCuotaInicial = component.get("v.iniPorcentajePrimeraCuota");//% Monto de la cuota (Inicial)
    var checkPrimeraCuota = component.find("checkboxCI").get("v.value");
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var precioTotalDscto = component.get("v.precioTotalDscto");

    var inicial = component.get("v.inicialvalue");
    var ncuotasinicial = component.get("v.nCuoInit");
    var inicialporcentaje = (inicial * 100) / precioTotalDscto;
    var factorOfTen = Math.pow(10, 3);
    var factorOfTenIP = Math.round(inicialporcentaje * factorOfTen) / factorOfTen;
    var inicialporcentajeCalculado = Number(Math.round(factorOfTenIP + "e2") + "e-2");
    var montocuota = inicial / ncuotasinicial; //1.40
    var factorOfTenMonto = Math.round(montocuota * factorOfTen) / factorOfTen;
    var montoCalculado = Number(Math.round(factorOfTenMonto + "e2") + "e-2");

    component.set("v.iniporcentajevalue", inicialporcentajeCalculado); //Inicial
    if (!checkPrimeraCuota || porcentajePrimeraCuotaInicial == 0) {
      component.set("v.montoCuota", montoCalculado);
      component.set("v.montoCuotaAux", montoCalculado);
    }else{
      var a = component.get('c.inputPorcentajeCuotaInicial');
        $A.enqueueAction(a);

    }

    helper.changeMontoDeCuotas(component, event, helper,checkPrimeraCuota,porcentajePrimeraCuotaInicial);
  },

  inputPorcentaje: function (component, event, helper) {

    var porcentajePrimeraCuotaInicial = component.get("v.iniPorcentajePrimeraCuota");
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var iniporcentajevalue = component.get("v.iniporcentajevalue");
    var ncuotasinicial = component.get("v.nCuoInit");
    component.get("v.iniporcentajevalue", iniporcentajevalue);
    //if ((checkPrimeraCuota && porcentajePrimeraCuotaInicial > iniporcentajevalue) || checkPrimeraCuota==false ) {
    var factorOfTen = Math.pow(10, 3);
    var inicialv = precioTotalDscto * (iniporcentajevalue / 100);
    var factorOfTenInicial = Math.round(inicialv * factorOfTen) / factorOfTen;
    var inicialCalculado = Number(Math.round(factorOfTenInicial + "e2") + "e-2");

    var montocuota = inicialCalculado / ncuotasinicial;

    var factorOfTenMonto = Math.round(montocuota * factorOfTen) / factorOfTen;
    var montoCalculado = Number(Math.round(factorOfTenMonto + "e2") + "e-2");
    var checkPrimeraCuota = component.find("checkboxCI").get("v.value");

    component.set("v.inicialvalue", inicialCalculado);
    if (!checkPrimeraCuota) {
      component.set("v.montoCuota", montoCalculado);
      component.set("v.montoCuotaAux", montoCalculado);
    }

    var a = component.get("c.actualizarCuotaInicial");
    $A.enqueueAction(a);

  },

  actualizarCuotaInicial: function (component, event, helper) {
    var porcentajePrimeraCuotaInicial = component.get("v.iniPorcentajePrimeraCuota");//% Monto de la cuota (Inicial)
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var iniporcentajevalue = component.get("v.iniporcentajevalue");//Inicial porcentaje
    var checkPrimeraCuota = component.find("checkboxCI").get("v.value");

    if ((checkPrimeraCuota && porcentajePrimeraCuotaInicial > iniporcentajevalue)) {
      component.set("v.iniPorcentajePrimeraCuota", iniporcentajevalue);
      porcentajePrimeraCuotaInicial = iniporcentajevalue;
      var factorOfTen = Math.pow(10, 3);
      var inicialv = precioTotalDscto * (porcentajePrimeraCuotaInicial / 100);
      var factorOfTenInicial = Math.round(inicialv * factorOfTen) / factorOfTen;
      var inicialCalculado = Number(Math.round(factorOfTenInicial + "e2") + "e-2");
      component.set("v.montoCuota", inicialCalculado);
    }
    helper.changeMontoDeCuotas(component, event, helper,checkPrimeraCuota,porcentajePrimeraCuotaInicial);
  },

  inputPorcentajeCuotaInicial: function (component, event, helper) {
    console.log('entra1');
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var porcentajePrimeraCuotaInicial = component.get("v.iniPorcentajePrimeraCuota");
    var iniPorcentaje = component.get("v.iniporcentajevalue");
    var checkPrimeraCuota = component.find("checkboxCI").get("v.value");
    var Inicial = component.get("v.inicialvalue");

    if (porcentajePrimeraCuotaInicial >= iniPorcentaje) {
      console.log('entra2');
      component.set("v.iniPorcentajePrimeraCuota", iniPorcentaje);
      porcentajePrimeraCuotaInicial = (Inicial/precioTotalDscto)*100;//iniPorcentaje;
    }

    //calculo del porcentaje del inicial
    if(porcentajePrimeraCuotaInicial > 0){
      console.log('entra3');
      var factorOfTen = Math.pow(10, 3);
      var inicialv = precioTotalDscto * (porcentajePrimeraCuotaInicial / 100);
      var factorOfTenInicial = Math.round(inicialv * factorOfTen) / factorOfTen;
      var inicialCalculado = Number(Math.round(factorOfTenInicial + "e2") + "e-2");
      component.set("v.montoCuota", inicialCalculado);
      component.set("v.montoCuotaAux", inicialCalculado);
      helper.changeMontoDeCuotas(component, event, helper,checkPrimeraCuota,porcentajePrimeraCuotaInicial);
    }
  },

  changeMontocuotas: function (component, event, helper) {
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var iniporcentajevalue = component.get("v.iniporcentajevalue");
    var ncuotasinicial = component.find("ncuotasinicial");
    var montocuota = component.get("v.montocuota");

    if (ncuotasinicial) {
      ncuotasinicial = ncuotasinicial.get("v.value");
    }
    if (montocuota == precioTotalDscto) {
      ncuotasinicial = 1;
    }
    if (!ncuotasinicial || ncuotasinicial === 0) {
      ncuotasinicial = 1;
    }
    if (!precioTotalDscto || precioTotalDscto === 0) {
      precioTotalDscto = 1;
    }

    iniporcentajevalue = (montocuota * ncuotasinicial * 100) / precioTotalDscto;

    component.set("v.montocuota", Math.round(montocuota * 100) / 100);
    component.set(
      "v.iniporcentajevalue",
      Math.round(iniporcentajevalue * 100) / 100
    );
    component.find("ncuotasinicial").set("v.value", ncuotasinicial);

    helper.evaluarAlContado(component);

    var action = component.get("c.inputPorcentaje");
    $A.enqueueAction(action);
  },

  inputCuotasFinanciar: function (component, event, helper) {
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
  },

  inputCuotasFinanciarSI: function (component, event, helper) {
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var checkCICmp = component.find("checkboxCI");
    var tipoVenta = component.find("slcTypeOfSale").get("v.value");
    var numCuotasSI = component.get("v.numCuotasSI");
    var Inicial = component.get("v.inicialvalue");
    var calculoFinan = Inicial / numCuotasSI;
    var resultCmp = component.find("montoCuota");

    var factorOfTen = Math.pow(10, 3);
    var factorOfTenMonto = Math.round(calculoFinan * factorOfTen) / factorOfTen;
    var montoCalculado = Number(Math.round(factorOfTenMonto + "e2") + "e-2");

    if(tipoVenta == 'CS'){
      if(!checkCICmp.get("v.value")){
        component.set("v.montoCuota", montoCalculado);
        component.set("v.montoCuotaAux", montoCalculado);
        component.set("v.monotocuotafinan", montoCalculado);
      }else{
        component.set("v.montoCuotaAux", montoCalculado);
      }
    }

    resultCmp.set("v.errors", "");
  },
 
  // GENERAR FINANCIAMIENTO
  Save: function (component, event, helper) {
    var flagGenerarCotizacion = component.get("v.flagGenerarCotizacion");
    var flagCalcularCotizacion = component.get("v.flagCalcularCotizacion");
    var flagCalcularDescuento = component.get("v.flagCalcularDescuento");

    //console.log("flagGenerarCotizacion: " + flagGenerarCotizacion);
    // console.log("flagCalcularCotizacion: " + flagCalcularCotizacion);
    // console.log("flagCalcularDescuento: " + flagCalcularDescuento);

    // var errorMontoAdelanto = component.find("montoAdelanto");
    // errorMontoAdelanto.set("v.errors", null);

    if (!flagGenerarCotizacion && !flagCalcularCotizacion && !flagCalcularDescuento) {
      return false;
    }

    var message_requerido = [{ message: "Este valor es requerido." }];
    var message_fechaDesembolso = [{ message: "Debera seleccionar Frecuencia y opción de Desembolso." }];
    var message_montoAdelanto = [{ message: "El monto de adelanto no debe ser menor a la cuota inicial " + component.get("v.montoCuotaAux") + " ni mayor a la inicial " + component.get("v.inicialvalue") }]; //MontoAdelantoCuota
    var message_montoCuotaAux = [{ message: "El monto de la primera cuota no debe ser menor a la cuota inicial " + component.get("v.montoCuotaAux") + " ni mayor a la inicial " + component.get("v.inicialvalue") }]; //MontoAdelantoCuota
    var message_nroCuotasValidas = [{ message: "El número de cuotas de la inicial debe ser 1" }];
    var message_cFacilote = [{ message: "Si el tipo de venta es al Contado ó Crédito sin intereses (24 meses), deberás seleccionar la opción: Sin cuota facilote" }];
    var CotizacionLibre = component.get("v.CotizacionLibre");
    var lotesList = component.get("v.lotesList");
    var inpAnotaciones = component.get("v.inpAnotaciones");
    inpAnotaciones = helper.corregirNulo(inpAnotaciones);
    component.set("v.disabledBtnGenerarFinanciamento", true);

    var IdOportunidad = component.get("v.IdOportunidad");
    var idCotizacionSimulador = component.get("v.idCotizacionSimulador");
    var area = component.get("v.areavalue");
    var Inicial = component.get("v.inicialvalue");
    var Iniporcentajevalue = component.get("v.iniporcentajevalue");
    var ncuotasinicial = component.find("ncuotasinicial").get("v.value");
    var bolMontoPrimeraCuota = component.find("checkboxCI").get("v.value");
    var montocuota = component.get("v.montoCuota");
    var isFacilote = component.get("v.isFacilote");
    var monotofinan = component.get("v.monotofinan");
    var cuotasfinan = component.get("v.numCuotas");
    var numCuotasSI = component.get("v.numCuotasSI");
    var montoAdelanto = component.find("montoAdelanto").get("v.value");
    var bolMontoAdelanto = component.find("checkbox").get("v.value");
    var montoCuotaAux = component.get("v.montoCuotaAux");
    var tasainteres = component.find("tasainteres").get("v.value");
    var PrecioVenta = component.get("v.preciototalvalue");
    var preciom2 = Math.round((PrecioVenta / area) * 100) / 100;
    var monotocuotafinan = component.get("v.monotocuotafinan");
    var montocuotarestfinan = component.get("v.montocuotarestfinan");
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var fecCuotaSaldoIni = component.get("v.fecCuotaSaldoIni");
    var fecCuotaSaldoFin = component.get("v.fecCuotaSaldoFin");
    var jsonPalancas = component.get("v.jsonPalancas");
    var filesUploaded = component.get("v.filesUploaded");
    var hasPermission = component.get("v.hasPermission");
    //var tasa = component.get("v.selectedTasa");
    //var codTasa = component.get("v.selectedCodTasa");
    var tasa = component.get("v.tasa");
    var codTasa = component.get("v.codTasa");
    var opcionDesembolso = component.get("v.opcionDesembolso");
    var fechaDesembolso = component.get("v.fechaDesembolso");
    var data = component.get("v.data");

    if(cuotasfinan > 0){
      var errorMontoFinan = component.find("ncuotasfinanciar").get("v.errors");
    }
    var moneda = lotesList[0].Codmonedafuncional.toUpperCase();
    var tipoVenta = component.find("slcTypeOfSale").get("v.value");

    if (!lotesList || lotesList.length == 0) {
      helper.showAlert("No hay lote seleccionado.", "error");
      component.set("v.disabledBtnGenerarFinanciamento", false);
      component.set("v.flagGenerarCotizacion", false);
      return false;
    }
    var inpDatosPersona = component.get("v.inpDatosPersona");
    var noPasoValidacion = false;
    if(Iniporcentajevalue!=100 && ncuotasinicial!=1){
      if (Inicial < 0 || !Inicial) {
        component.find("inicial").set("v.errors", message_requerido);
        noPasoValidacion = true;
      }
      if (PrecioVenta < 0 || !PrecioVenta) {
        component.find("preciototal").set("v.errors", message_requerido);
        noPasoValidacion = true;
      }
      if (ncuotasinicial < 0 || !ncuotasinicial) {
        component.find("ncuotasinicial").set("v.errors", message_requerido);
        noPasoValidacion = true;
      }
      if(errorMontoFinan){
        if(Array.isArray(errorMontoFinan) && errorMontoFinan.length>0){
          noPasoValidacion = true;
        }
      }
      if (cuotasfinan < 0 || !cuotasfinan) {
        component.find("ncuotasfinanciar").set("v.errors", message_requerido);
        noPasoValidacion = true;
      }else if(!errorMontoFinan || errorMontoFinan.length == 0){
        component.find("ncuotasinicial").set("v.errors", null);
      }

      if(ncuotasinicial > 1 && montocuota == Inicial) {
        component.find("ncuotasinicial").set("v.errors", message_nroCuotasValidas);
        noPasoValidacion = true;
      }
    }

    if (bolMontoAdelanto == true && (montoAdelanto < montocuota || montoAdelanto > Inicial)) {
      component.find("montoAdelanto").set("v.errors", message_montoAdelanto);
      noPasoValidacion = true;
    }

    // if(tipoVenta == "CD" && ncuotasinicial == 1 && (fechaDesembolso == '' || fechaDesembolso == '0')){
    //   component.find("fechaDesembolso").set("v.errors", message_fechaDesembolso);
    //   noPasoValidacion = true;
    // }

    // if (bolMontoPrimeraCuota == true && (montocuota < montoCuotaAux || montocuota > Inicial)) {
    //   component.find("montoCuota").set("v.errors", message_montoCuotaAux);
    //   noPasoValidacion = true;
    // }

    //console.log(isFacilote);
    if (isFacilote && (tipoVenta == 'CO' || tipoVenta == 'CS')) {
      component.find("ncuotasinicial").set("v.errors", message_cFacilote);
      noPasoValidacion = true;
    }

    if(noPasoValidacion){
      component.set("v.flagGenerarCotizacion", false);
      component.set("v.flagCalcularCotizacion", false);
      component.set("v.flagCalcularDescuento", false);
      return false;
    }

    var codigosLotesRecotizables = component.get("v.codigosLotesRelOpp");
    for (var i in lotesList) {
      if (
        lotesList[i].Codestadolote.toUpperCase() == "LIBRE" ||
        lotesList[i].Codestadolote.toUpperCase() == "L" ||
        codigosLotesRecotizables.includes(lotesList[i].Codlote)
      ) {
      } else {
        helper.showAlert(
          "El lote " + lotesList[i].Descripcionlote + " no está Libre. Considere usar Lotes relacionados a la Oportunidad, sus Cotizaciones o Lotes libres.",
          "error"
        );
        component.set("v.disabledBtnGenerarFinanciamento", true);
        component.set("v.flagCalcularCotizacion", false);
        component.set("v.flagGenerarCotizacion", false);
        return false;
      }
    }

    if (
      Iniporcentajevalue &&
      Inicial &&
      PrecioVenta &&
      Iniporcentajevalue > 0 &&
      PrecioVenta > 0
    ) {
      console.log("Campos requeridos pasados.");
      console.log(cuotasfinan);
      var action = component.get("c.getcreateCotiz");
      action.setParams({
        datosPersona: inpDatosPersona,
        lotesList: lotesList,
        anotacionesList: inpAnotaciones,
        IdOportunidad: IdOportunidad,
        area: area,
        preciom2: preciom2,
        PrecioVenta: PrecioVenta,
        precioTotalDscto: precioTotalDscto,
        Iniporcentajevalue: Iniporcentajevalue,
        Inicial: Number((Math.round(Inicial * 1000) / 1000).toFixed(2)),
        ncuotasinicial: ncuotasinicial,
        bolMontoPrimeraCuota: bolMontoPrimeraCuota,
        montocuota: montocuota,
        isFacilote: isFacilote,
        monotofinan: monotofinan,
        cuotasfinan: cuotasfinan,
        numCuotasSI: numCuotasSI,
        fecCuotaSaldoIni: fecCuotaSaldoIni,
        fecCuotaSaldoFin: fecCuotaSaldoFin,
        tasainteres: tasainteres,
        monotocuotafinan: monotocuotafinan,
        esCotizacionLibre: CotizacionLibre,
        bolMontoAdelanto: bolMontoAdelanto,
        montoAdelanto: montoAdelanto,
        moneda: moneda,
        tipoVenta: tipoVenta,
        simulador: flagCalcularCotizacion,
        idCotizacionSimulador: idCotizacionSimulador,
        jsonPalancas: jsonPalancas,
        hasPermission: hasPermission,
        data: data,
        montocuotarestfinan: montocuotarestfinan
      });
      console.log("action" + action);
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var data = response.getReturnValue();
          console.log("response from controller:");
          if (data) {
            if (data.ok) {
              console.log("entro data.ok");
              if(!flagCalcularCotizacion){
                component.set(
                "v.idRegistroCotizacion",
                data.idCotizacionGenerado
                );
                helper.getCotizacionDocumentada(
                  component,
                  data.idCotizacionGenerado,
                  IdOportunidad,
                  CotizacionLibre
                );

                if(filesUploaded.length > 0){
                  helper.uploadFile(component,IdOportunidad);
                }

                $A.enqueueAction(component.get('c.callChildMethod'));
              }else{
                console.log("paso al else  data.ok");
                helper.getFinanciamiento(component,IdOportunidad,flagCalcularCotizacion);
                component.set("v.idCotizacionSimulador", data.idCotizacionGenerado);
              }
            } else {
              component.set("v.flagCalcularCotizacion", false);
              helper.showAlert(data.mensaje, "error");
              console.error(data.detalle);
            }
          } else {
            console.error("data es nulo");
          }
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              component.set("v.flagCalcularCotizacion", false);
              console.log("Error message [Save]: " + errors[0].message);
              helper.showAlert(errors[0].message, "error");
            }
          } else {
            console.log("Unknown error");
          }
        }
        component.set("v.flagGenerarCotizacion", false);
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.disabledBtnGenerarFinanciamento", false);
      component.set("v.flagGenerarCotizacion", false);
      console.log("Campos requeridos no pasados.");
      component.set("v.disabledPeriodos", false);
    }

  },

  closeModelNProd0: function (component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
    component.set("v.isModalOpen", false);
    // component.set("v.selTabId", "1");
  },

  /********************* 19/04/2021 ****************************/
  inputCuotas: function (component, event, helper) {
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var tipoVenta = component.find("slcTypeOfSale").get("v.value");
    var opcionF = component.get("v.opcionFacilote");
    var numCuotasSI = component.get("v.numCuotasSI");
    var numCuotas = component.get("v.nCuoInit");
    var Inicial = component.get("v.inicialvalue");
    var checkPrimeraCuotaInicial = component.find("checkboxCI").get("v.value");
    var porcentajePrimeraCuotaInicial=component.get("v.iniPorcentajePrimeraCuota");

    if(tipoVenta == 'CS'){
      var calculoCuotaSI = Inicial / numCuotasSI;
      var factorOfTen = Math.pow(10, 3);
      var factorOfTen2 = Math.round(calculoCuotaSI * factorOfTen) / factorOfTen;
      var montoCuotaDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");
      if (!checkPrimeraCuotaInicial){
        component.set("v.montoCuota", montoCuotaDecimal);
        component.set("v.montoCuotaAux", montoCuotaDecimal);
      }
    }else{
      if (opcionF=="cFacilote"){
        var calculoCuota = Inicial / (numCuotas-1);
      }else{
        var calculoCuota = Inicial / numCuotas;
      }
      var factorOfTen = Math.pow(10, 3);
      var factorOfTen2 = Math.round(calculoCuota * factorOfTen) / factorOfTen;
      var montoCuotaDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");
      if (!checkPrimeraCuotaInicial){
        component.set("v.montoCuota", montoCuotaDecimal);
        component.set("v.montoCuotaAux", montoCuotaDecimal);
      }else{
        $A.enqueueAction(component.get('c.onCheckCI'));
      }
    }

    $A.enqueueAction(component.get("c.onChangeFrecuencia"));
    helper.changeMontoDeCuotas(component, event, helper,checkPrimeraCuotaInicial,porcentajePrimeraCuotaInicial);
  },

  cambiaFacilote: function (component, event, helper) {
      component.set("v.disabledBtnGenerarFinanciamento", true);
      component.set("v.disabledBtnSimuladorPrepago", true);
      component.set("v.disabledBtnGestionDescuento", true);
      var selectedOptionValue = event.getParam("value");
      component.set("v.opcionFacilote", selectedOptionValue);
      var inicial = component.get("v.inicialvalue");

      var checkCmp = component.find("checkbox");
      var checkCICmp = component.find("checkboxCI");
      var montoAdelantoCmp = component.find("montoAdelanto");
      var montoCuotaCmp = component.find("montoCuota");

      if(selectedOptionValue == "cFacilote") {
          component.set("v.nCuoInit", 9);
          component.set('v.isFacilote', true);
          checkCmp.set("v.disabled", ""+true);
          checkCICmp.set("v.disabled", ""+true);
      }
      else if(selectedOptionValue == "sFacilote") {
          component.set("v.nCuoInit", 10);
          $A.enqueueAction(component.get('c.borrarAnotaciones'));
          component.set('v.isFacilote', false);
          checkCmp.set("v.disabled", ""+false);
          checkCICmp.set("v.disabled", ""+false);
      }

      component.set("v.montoCuota", inicial / 10);
      component.set("v.montoCuotaAux", inicial / 10);
      checkCICmp.set("v.value", "false");
      montoCuotaCmp.set("v.disabled", ""+true);
      checkCmp.set("v.value", "false");
      montoAdelantoCmp.set("v.value", "0");
      montoAdelantoCmp.set("v.disabled", ""+true);

  },

  actualizarAnotaciones: function (component, event, helper) {
      var inpAnotaciones = [];
      var montoCuotaInter = component.get("v.montoCuota");
      var cuotaN1 = Number(Math.round((montoCuotaInter/2) + "e2") + "e-2");
      var cuotaN2 = montoCuotaInter - cuotaN1;
      inpAnotaciones.push({
          key: 1,
          fecha: null,
          monto:  cuotaN1,
          anotaciones: "Cuota 1 de la inicial (Pago minimo para la firma de contrato)"
      });
      inpAnotaciones.push({
          key: 2,
          fecha: null,
          monto:  cuotaN2,
          anotaciones: "Cuota 2 de la inicial"
      });
      inpAnotaciones.push({
          key: 3,
          fecha: null,
          monto: montoCuotaInter,
          anotaciones: "De la cuota 3 a la cuota "+ component.get("v.nCuoInit") +" de la inicial"
      });

      component.set("v.inpAnotaciones", inpAnotaciones);
  },

  borrarAnotaciones: function (component, event, helper) {
      var inpAnotaciones = [];

      inpAnotaciones.push({
          key: 1,
          fecha: null,
          monto: null,
          anotaciones: null
      });
      inpAnotaciones.push({
          key: 2,
          fecha: null,
          monto: null,
          anotaciones: null
      });
      inpAnotaciones.push({
          key: 3,
          fecha: null,
          monto: null,
          anotaciones: null
      });

      component.set("v.inpAnotaciones", inpAnotaciones);
  },

  validarNumero: function (component) {
      var mensaje = component.get("v.stringnCuoFacilList");
      var message_valor_nulo = [{ message: mensaje }];
      var ncuotasinicial = component.find("ncuotasinicial");
      ncuotasinicial.set("v.errors", message_valor_nulo);
  },

  validarNumero2: function (component) {
      var mensaje = "Los valores permitidos estan entre 1 y 12.";
      var message_valor_nulo = [{ message: mensaje }];
      var ncuotasinicial = component.find("ncuotasinicial");
      ncuotasinicial.set("v.errors", message_valor_nulo);
  },

  desvalidarNumero: function (component) {
      var ncuotasinicial = component.find("ncuotasinicial");
      ncuotasinicial.set("v.errors", null);
  },

  callChildMethod : function(component, event, helper) {
    var findChildComp=component.find('childLwcCompId');
    findChildComp.openModal();
  },

  callSimuladorPrepago : function(component, event, helper) {
    var findChildComp=component.find('childSimuladorPrepago');
    findChildComp.openModal();
  },

  callGestionDescuento : function(component, event, helper) {
    var findChildComp=component.find('childGestionDescuento');
    findChildComp.openModal();
  },

  onCheck: function(cmp, evt) {
    cmp.set("v.disabledBtnGenerarFinanciamento", true);
    cmp.set("v.disabledBtnSimuladorPrepago", true);
    cmp.set("v.disabledBtnGestionDescuento", true);
    var checkCmp = cmp.find("checkbox");
    var checkCICmp = cmp.find("checkboxCI");
    var resultCmp = cmp.find("montoAdelanto");
    if(!checkCmp.get("v.value")){
      resultCmp.set("v.value", "0");
      resultCmp.set("v.disabled", true);
      checkCICmp.set("v.disabled", false);
      resultCmp.set("v.errors", "");
    }else{
      resultCmp.set("v.disabled", false);
      checkCICmp.set("v.disabled", true);
      checkCICmp.set("v.value", false);
    }

  },

  onCheckCI: function(cmp, evt) {

    var tipoVenta = cmp.find("slcTypeOfSale").get("v.value");
    cmp.set("v.disabledBtnGenerarFinanciamento", true);
    cmp.set("v.disabledBtnSimuladorPrepago", true);
    cmp.set("v.disabledBtnGestionDescuento", true);
    var checkCmp = cmp.find("checkbox");
    var checkCICmp = cmp.find("checkboxCI");
    var resultCmp = cmp.find("montoCuota");
    var resultCmpPorcentaje = cmp.find("porcentajeMontoCuota");

    //var montoCuota = cmp.get("v.montoCuotaAux");
    var montoCuota = cmp.get("v.inicialvalue") / cmp.get("v.nCuoInit");

    // var fieldMap = [];
    // fieldMap.push({value: 0.00, label: 'Seleccione una Tasa', selected : true});
    // cmp.set("v.optionsTasa", fieldMap);

    if(!checkCICmp.get("v.value")){
      // resultCmp.set("v.disabled", true);
      resultCmpPorcentaje.set("v.disabled", true);
      resultCmp.set("v.disabled", true);

      if(tipoVenta != 'CS'){
        checkCmp.set("v.disabled", false);
      }

      cmp.set("v.montoCuota", montoCuota);
      resultCmp.set("v.errors", "");
      cmp.set("v.iniPorcentajePrimeraCuota", 0);
      resultCmpPorcentaje.set("v.errors", "");

      cmp.set('v.montoDeCuotas',0);
      cmp.set("v.seccionMontoCuotas", false);

      //Limpiar Descuentos y Palancas
      cmp.set("v.totalDiscount",0);
      cmp.set("v.totalPercentage",0);
      cmp.set("v.jsonPalancas", "");
    }else{
      // resultCmp.set("v.disabled", false);
      resultCmpPorcentaje.set("v.disabled", false);
      resultCmp.set("v.disabled", false);
      checkCmp.set("v.disabled", true);
      if(tipoVenta != 'CS'){
        cmp.set("v.seccionMontoCuotas", true);
      }else{
        cmp.set("v.seccionMontoCuotas", false);
      }
    }

  },

  inputMontoCuotas: function(component,evt,helper){
    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);
    component.set("v.disabledBtnGestionDescuento", true);
    var errorMontoCuota = component.find("montoCuota");
    errorMontoCuota.set("v.errors", null);
    var resultCmp = component.get('v.montoCuota');
    var resultCmpPorcentaje = component.find("porcentajeMontoCuota").get("v.value");
    var preciototalvalue = component.get('v.preciototalvalue');
    var checkPrimeraCuota = component.find("checkboxCI").get("v.value");
    var Inicial = component.get("v.inicialvalue");
    var iniporcentajevalue = component.get("v.iniporcentajevalue");
    var precioTotalDscto = component.get('v.precioTotalDscto');
    var totalPercentage = component.get('v.totalPercentage');
    var totalDiscount = component.get('v.totalDiscount');

    console.log('totalDiscount: ' + totalDiscount);
    if(totalDiscount > 0){
      console.log('totalPercentage > 0: ' + totalPercentage)
      preciototalvalue = precioTotalDscto;
    }

    var porcentajeAux = (resultCmp/preciototalvalue)*100;

    var factorOfTen = Math.pow(10, 3);
    var factorOfTen2 = Math.round(porcentajeAux * factorOfTen) / factorOfTen;
    porcentajeAux = Number(Math.round(factorOfTen2 + "e2") + "e-2");

    if (Inicial >= resultCmp) {
      component.set("v.iniPorcentajePrimeraCuota", porcentajeAux);
      helper.changeMontoDeCuotas(component, evt, helper,checkPrimeraCuota,porcentajeAux);
    }else{
      component.set('v.montoCuota', Inicial);
      component.set("v.iniPorcentajePrimeraCuota", iniporcentajevalue);
      helper.changeMontoDeCuotas(component, evt, helper,checkPrimeraCuota,porcentajeAux);
    }

  },

  inputMontoAdelanto: function(component,evt){
    var errorMontoAdelanto = component.find("montoAdelanto");
    errorMontoAdelanto.set("v.errors", null);
  },

  // onChangeTasa: function(component,evt){
  //   var tasa = component.get("v.selectedTasa");
  //   var tasas = component.get("v.optionsTasa");
  //   component.set("v.disabledBtnGenerarFinanciamento", true);
  //   component.set("v.tasainter", tasa);

  //   for(var i in tasas){
  //     if(tasas[i].value == tasa){
  //       component.set("v.selectedCodTasa", tasas[i].label);
  //     }
  //   }
  // },

  onChangeFrecuencia: function(component,evt,helper){
    component.set("v.disabledBtnGenerarFinanciamento", true);
    //component.set("v.data", null);
    const fecha = new Date();
    //component.set("v.fechaDesembolso", "");
    var frecuenciaSeleccionada = component.get("v.selectedFrecuencia");
    var myMap = component.get("v.data");
    myMap['fechaDesembolso'] = null;
    myMap['opcionDesembolso'] = null;
    myMap['frecuenciaDesembolso'] = frecuenciaSeleccionada;
    component.set("v.data", myMap);
    //var ultimoDia = new Date(date.getFullYear(), date.getMonth() + 1, 0);
    component.set("v.optionsFecha", helper.calcularFecha(component, fecha, frecuenciaSeleccionada));
  },

  onChangeOpcionFecha: function(component){
    component.set("v.disabledBtnGenerarFinanciamento", true);
    var opcionSeleccionada = component.get("v.selectedOpcionFecha");
    component.set("v.fechaDesembolso", opcionSeleccionada);
    var options = component.get("v.optionsFecha");
    var myMap = component.get("v.data");
    myMap['fechaDesembolso'] = opcionSeleccionada;

    for(var i in options){
      if(options[i].value == opcionSeleccionada){
        component.set("v.opcionDesembolso", options[i].label);
        myMap['opcionDesembolso'] = options[i].label;
      }
    }

    component.set("v.data", myMap);
  },

  onChangeTypeOfSale: function(component,evt){
    var tipoVenta = component.find("slcTypeOfSale").get("v.value");
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var checkCmp = component.find("checkbox");
    var checkCICmp = component.find("checkboxCI");
    var resultCmp = component.find("montoCuota");
    var porcentajeMontoCuota = component.find("porcentajeMontoCuota");

    component.set("v.disabledTypeOfSale", false);

    //console.log(tipoVenta);
    if(tipoVenta == 'CO'){
      component.set("v.inicialvalue", precioTotalDscto);
      component.find("inicial").set("v.disabled", true);
      component.set("v.iniporcentajevalue", 100);
      component.find("inicialporcentaje").set("v.disabled", true);
      component.set("v.nCuoInit", 1);
      component.set("v.numCuotasSI", 0);
      component.find("ncuotasinicial").set("v.disabled", true);
      component.set("v.montoCuota", precioTotalDscto);
      component.set("v.montoCuotaAux", precioTotalDscto);
      resultCmp.set("v.disabled", true);
      component.find("montoAdelanto").set("v.value", 0);
      component.find("montoAdelanto").set("v.disabled", true);
      component.set("v.seccionMontoCuotas", false);
      component.set("v.monotofinan", 0);
      component.set("v.numCuotas",0);
      component.set("v.numCuotasSI",0);
      component.find("ncuotasfinanciar").set("v.disabled", true);
      component.find("tasainteres").set("v.value", 0);
      component.set("v.monotocuotafinan", 0);
      component.set("v.flagDesembolso", false);
      if(component.get("v.flagCuotaFacilote")){
      component.find("cbFacilote").set("v.disabled", true);
      component.find("cbFacilote").set("v.value", "sFacilote");
      }
      checkCmp.set("v.disabled", true);
      checkCICmp.set("v.disabled", true);
      checkCmp.set("v.value", false);
      checkCICmp.set("v.value", false);
      component.set('v.isFacilote', false);
      $A.enqueueAction(component.get('c.borrarAnotaciones'));
      component.set("v.disabledBtnCalcularFinanciamento", false);
      component.set("v.disabledBtnGenerarFinanciamento", true);
      component.set("v.disabledBtnSimuladorPrepago", true);
      component.set("v.disabledBtnGestionDescuento", true);
      porcentajeMontoCuota.set("v.disabled", true);
    } else if(tipoVenta == 'CS'){

      var montoCuota =  precioTotalDscto / 24;
      var factorOfTen = Math.pow(10, 3);
      var factorOfTen2 = Math.round(montoCuota * factorOfTen) / factorOfTen;
      var montoCuotaDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");

      component.set("v.inicialvalue", precioTotalDscto);
      component.find("inicial").set("v.disabled", true);
      component.set("v.iniporcentajevalue", 100);
      component.find("inicialporcentaje").set("v.disabled", true);
      component.set("v.nCuoInit", 0);
      component.set("v.numCuotasSI", 24);
      component.find("ncuotasinicial").set("v.disabled", true);
      component.set("v.montoCuota", montoCuotaDecimal);
      component.set("v.montoCuotaAux", montoCuotaDecimal);
      resultCmp.set("v.disabled", true);
      component.find("montoAdelanto").set("v.value", 0);
      component.find("montoAdelanto").set("v.disabled", true);
      component.set("v.seccionMontoCuotas", false);
      component.set("v.monotofinan", 0);
      component.set("v.numCuotas",0);
      component.set("v.numCuotasSI",24);
      component.find("ncuotasfinanciar").set("v.disabled", false);
      component.find("tasainteres").set("v.value", 0);
      component.set("v.monotocuotafinan", montoCuotaDecimal);
      component.set("v.flagDesembolso", false);
      if(component.get("v.flagCuotaFacilote")){
      component.find("cbFacilote").set("v.disabled", true);
      component.find("cbFacilote").set("v.value", "sFacilote");
      }
      checkCmp.set("v.disabled", true);
      checkCICmp.set("v.disabled", false);
      checkCmp.set("v.value", false);
      checkCICmp.set("v.value", false);
      component.set('v.isFacilote', false);
      $A.enqueueAction(component.get('c.borrarAnotaciones'));
      component.set("v.disabledBtnCalcularFinanciamento", false);
      component.set("v.disabledBtnGenerarFinanciamento", true);
      component.set("v.disabledBtnSimuladorPrepago", true);
      component.set("v.disabledBtnGestionDescuento", true);
      porcentajeMontoCuota.set("v.disabled", true);
    } else {

      var montoCuota =  (precioTotalDscto*0.20) / 10;
      var factorOfTen = Math.pow(10, 3);
      var factorOfTen2 = Math.round(montoCuota * factorOfTen) / factorOfTen;
      var montoCuotaDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");

      var inicial = precioTotalDscto * 0.20;
      var factorInicial = Math.round(inicial * factorOfTen) / factorOfTen;
      var inicialCalculado = Number(Math.round(factorInicial + "e2") + "e-2");

      component.set("v.inicialvalue", inicialCalculado);
      component.find("inicial").set("v.disabled", false);
      component.set("v.iniporcentajevalue", 20);
      component.find("inicialporcentaje").set("v.disabled", false);
      component.set("v.nCuoInit", 10);
      component.set("v.numCuotasSI", 0);
      component.find("ncuotasinicial").set("v.disabled", false);
      component.set("v.montoCuota", montoCuotaDecimal);
      component.set("v.montoCuotaAux", montoCuotaDecimal);
      resultCmp.set("v.disabled", true);
      component.find("montoAdelanto").set("v.value", 0);
      component.find("montoAdelanto").set("v.disabled", true);
      component.set("v.seccionMontoCuotas", false);
      component.set("v.monotofinan", 0);
      component.set("v.numCuotas",60);
      component.set("v.numCuotasSI",0);
      component.find("ncuotasfinanciar").set("v.disabled", false);
      component.find("tasainteres").set("v.value", 0);
      component.set("v.monotocuotafinan", 0);
      if(component.get("v.flagCuotaFacilote")){
      component.find("cbFacilote").set("v.disabled", false);
      component.find("cbFacilote").set("v.value", "sFacilote");
      }
      checkCmp.set("v.disabled", false);
      checkCICmp.set("v.disabled", false);
      checkCmp.set("v.value", false);
      checkCICmp.set("v.value", false);
      component.set('v.isFacilote', false);
      $A.enqueueAction(component.get('c.borrarAnotaciones'));
      component.set("v.disabledBtnCalcularFinanciamento", false);
      component.set("v.disabledBtnGenerarFinanciamento", true);
      component.set("v.disabledBtnSimuladorPrepago", true);
      component.set("v.disabledBtnGestionDescuento", true);
      porcentajeMontoCuota.set("v.disabled", true);
    }
  },

  getValueFromLwc : function(component, event, helper) {

    var totalPercentage  = event.getParam('totalPercentage');
    var totalDiscount  = event.getParam('totalDiscount');
    var lotesList = component.get("v.lotesList");
    var precioFull = component.get("v.preciototalvalue");
    var descuentoReal = totalDiscount / precioFull;
    var tipoVenta = component.find("slcTypeOfSale").get("v.value");

    if (totalDiscount > 0) {
      console.log('entra aqui descuento');
      console.log('totalPercentage: ' + totalPercentage);
      console.log('totalDiscount: ' + totalDiscount);
      var factorOfTen = Math.pow(10, 3);
      for (var i in lotesList) {
        var percentage = descuentoReal;
        var amountDiscountLot = lotesList[i].Precioventafun - (lotesList[i].Precioventafun * (1 - percentage));
        console.log('amountDiscountLot: ' + amountDiscountLot);
        var factorOfTen2 = Math.round(amountDiscountLot * factorOfTen) / factorOfTen;
        var amountDiscountLotDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");

        console.log('amountDiscountLotDecimal: ' + amountDiscountLotDecimal);
        lotesList[i].PrecioVentaDscto = lotesList[i].Precioventafun - amountDiscountLotDecimal;
        lotesList[i].Discount = totalPercentage;
      }
    }
    component.set("v.jsonPalancas",event.getParam('jsonPalancas'));
    component.set("v.filesUploaded",event.getParam('filesUploaded'));
    component.set("v.totalDiscount",event.getParam('totalDiscount'));
    component.set("v.totalPercentage",event.getParam('totalPercentage'));
    component.set("v.lotesList", lotesList);
    component.set("v.monotofinan", 0);
    component.find("tasainteres").set("v.value", 0);
    component.set("v.monotocuotafinan", 0);

    component.set("v.disabledTypeOfSale", true);
    component.set("v.disabledBtnGestionDescuento", true);
    //component.find("inicial").set("v.disabled", true);
    component.find("inicialporcentaje").set("v.disabled", true);
    component.find("ncuotasinicial").set("v.disabled", true);
    if(tipoVenta == 'CS'){
      component.find("nCuotasSI").set("v.disabled", true);
    }else{
      component.find("ncuotasfinanciar").set("v.disabled", true);
    }
    if(component.get("v.flagCuotaFacilote")){
      component.find("cbFacilote").set("v.disabled", true);
    }
    component.set("v.disabledBtnSimuladorPrepago", true);
    var action = component.get("c.updatePreciosLote");
    $A.enqueueAction(action);

    var action2 = component.get("c.inputPorcentajeCuotaInicial");
    $A.enqueueAction(action2);
  },
  //ESCENARIOS DE FINANCIAMIENTO
  getPeriodos: function(component, event, helper) {
    var IdOportunidad = component.get("v.IdOportunidad");
    
    // 🔔 Mostrar alerta verde
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        title: "Se estan generando ESCENARIOS DE FINANCIAMIENTO",
        message: "por favor espere...",
        type: "success",
        duration: 14000 
    });
    toastEvent.fire();

    helper.getPeriodosCotizacion(component, IdOportunidad);
  }
  //FIN ESCENARIOS DE FINANCIAMIENTO
});