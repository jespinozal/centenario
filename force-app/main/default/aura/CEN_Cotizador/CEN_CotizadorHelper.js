({
  setAnotaciones: function (component) {
    var inpAnotaciones = [];
    for (var i = 0; i < 4; i++) {
      inpAnotaciones.push({
        key: parseInt(i) + 1,
        fecha: null,
        monto: null,
        anotaciones: null
      });
    }
    component.set("v.inpAnotaciones", inpAnotaciones);
  },
  setDatosPersona: function (component) {
    var inpDatosPersona = {
      nombres: null,
      apellidos: null,
      tipoDocumento: null,
      nroDocumento: null,
      celular: null
    };
    component.set("v.inpDatosPersona", inpDatosPersona);

    //get datos de persona
  },
  calcularCambiosDesdeLote: function (component) {
    console.log('entra calcularCambiosDesdeLote');
    var lotesList = component.get("v.lotesList");
    var totalDiscount = component.get("v.totalDiscount");
    //  datos totales de lotes
    var areavalue = 0.0;
    var preciototalvalue = 0.0;
    var precioTotalDscto = 0.0;
    //var precioTotalDsctoAux = 0.0;
    for (var i in lotesList) {
      lotesList[i].Orden = parseInt(i) + 1;
      areavalue = areavalue + lotesList[i].Area;
      preciototalvalue = preciototalvalue + lotesList[i].Precioventafun;
      precioTotalDscto = precioTotalDscto + lotesList[i].PrecioVentaDscto;
    }
    component.set("v.lotesList", lotesList);
    component.set("v.areavalue", areavalue);
    component.set("v.preciototalvalue", preciototalvalue);
    if(totalDiscount > 0){
      component.set("v.precioTotalDscto", preciototalvalue - totalDiscount);
    }else{
      component.set("v.precioTotalDscto", precioTotalDscto);
    }

  },
  calcularFinanciamientoDesdeLotes: function (component) {

    component.set("v.disabledBtnGenerarFinanciamento", true);
    component.set("v.disabledBtnSimuladorPrepago", true);

    var tipoVenta = component.find("slcTypeOfSale").get("v.value");
    var precioTotalDscto = component.get("v.precioTotalDscto");
    var iniporcentajevalue = component.get("v.iniporcentajevalue");
    var numeroCuotasInicial = component.get("v.nCuoInit");
    var inicialv = precioTotalDscto * (iniporcentajevalue / 100);
    var factorOfTenMontoCuota;
    var opcionF = component.get("v.opcionFacilote");

    var checkCICmp = component.find("checkboxCI");
    var montoCuota = component.get("v.montoCuota");
    var montoCuotaAux = component.get("v.montoCuotaAux");

    var factorOfTen = Math.pow(10, 3);
    var factorOfTen2 = Math.round(inicialv * factorOfTen) / factorOfTen;
    var inicialDecimal = Number(Math.round(factorOfTen2 + "e2") + "e-2");
    component.set("v.inicialvalue", inicialDecimal);

    if(tipoVenta == 'CD'){
      if(!checkCICmp.get("v.value")){
        if(opcionF == "cFacilote") {
          numeroCuotasInicial = numeroCuotasInicial-1;
        }
        var montoCuotasInicial = (inicialv/numeroCuotasInicial);
        factorOfTenMontoCuota = Math.round(montoCuotasInicial * factorOfTen) / factorOfTen;
        var montoCuotasInicialDecimal = Number(Math.round(factorOfTenMontoCuota + "e2") + "e-2");
        component.set("v.montoCuota", montoCuotasInicialDecimal);
        component.set("v.montoCuotaAux", montoCuotasInicialDecimal);
      }
    }else if(tipoVenta == 'CS'){
      var checkCICmp = component.find("checkboxCI");
      var montoCuotaCmp = component.find("montoCuota");
      checkCICmp.set("v.value", "false");
      montoCuotaCmp.set("v.disabled", ""+true);
      var ncuotasfinanciar = component.get("v.numCuotasSI");
      var inicialDecimal = inicialv / ncuotasfinanciar;
      factorOfTenMontoCuota = Math.round(inicialDecimal * factorOfTen) / factorOfTen;
      var montoCuotasInicialDecimal = Number(Math.round(factorOfTenMontoCuota + "e2") + "e-2");
      component.set("v.montoCuota", montoCuotasInicialDecimal);
      component.set("v.monotocuotafinan", montoCuotasInicialDecimal);
      component.set("v.montoCuotaAux", montoCuotasInicialDecimal);
    }else if(tipoVenta == 'CO'){
      component.set("v.montoCuota", precioTotalDscto);
      component.set("v.montoCuotaAux", precioTotalDscto);
    }

  },
  evaluarAlContado: function (component) {
    var inicialporcentaje = component.find("inicialporcentaje");
    var ncuotasinicial = component.find("ncuotasinicial");
    var monotofinan = component.get("v.monotofinan");

    if (inicialporcentaje != null) {
      inicialporcentaje = inicialporcentaje.get("v.value");
    }
    if (ncuotasinicial != null) {
      ncuotasinicial = ncuotasinicial.get("v.value");
    }

    var ncuotasfinanciar = component.find("ncuotasfinanciar");
    var tasainteres = component.find("tasainteres");

    if (ncuotasfinanciar != null) {
      ncuotasfinanciar = ncuotasfinanciar.get("v.value");
    }
    if (tasainteres != null) {
      tasainteres = tasainteres.get("v.value");
    }

    if (inicialporcentaje == 100 && ncuotasinicial == 1 && ncuotasfinanciar != 23 ) {
      component.find("ncuotasfinanciar").set("v.value", 0);
      component.find("tasainteres").set("v.value", 0);
    } else if (monotofinan == 0) {
      component.find("tasainteres").set("v.value", 0);
    } else if (
      monotofinan != 0 &&
      inicialporcentaje != 100 &&
      ncuotasinicial != 1 &&
      ncuotasfinanciar != 60 &&
      tasainteres != 23
    ) {
      if (ncuotasfinanciar == 0) {
        component.find("ncuotasfinanciar").set("v.value", 60);
      }
      if (tasainteres == 0) {
        component.find("tasainteres").set("v.value", 23);
      }

      var action = component.get("c.inputCuotasFinanciar");
      $A.enqueueAction(action);
    }
  },
  obtenerTiposDocumentoCotizacion: function (component) {
    var action = component.get("c.getListaTipoDocumentos");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data && data.ok) {
          component.set("v.optionsTipoDocumento", data.tipoDocumentos);
        } else {
          this.showToast(
            component,
            "Error",
            "No se pudo buscar los tipo de documentos",
            "error"
          );
          console.log(data);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message[obtenerTiposDocumentoCotizacion]: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
        this.showToast(
          component,
          "Error interno",
          "Ocurrió un error interno con la busqueda de tipo de documentos.",
          "error"
        );
      }
    });
    $A.enqueueAction(action);
  },
  validarNegativos: function (component) {
    var message_valor_negativo = [{ message: "Este valor es negativo." }];
    var message_valor_nulo = [{ message: "Este valor es nulo." }];
    // validar negativos de los valores de los lotes
    var areacmp = component.find("areacmp");
    var precioTotalDsctcmp = component.find("precioTotalDsctcmp");
    var precioTotalcmp = component.find("precioTotalcmp");

    if (Array.isArray(areacmp)) {
      for (var i in areacmp) {
        if (areacmp[i].get("v.value") && areacmp[i].get("v.value") < 0) {
          areacmp[i].set("v.errors", message_valor_negativo);
        } else {
          areacmp[i].set("v.errors", null);
        }
      }
    } else if (areacmp && areacmp instanceof Object) {
      if (areacmp.get("v.value") && areacmp.get("v.value") < 0) {
        areacmp.set("v.errors", message_valor_negativo);
      } else {
        areacmp.set("v.errors", null);
      }
    }

    if (Array.isArray(precioTotalDsctcmp)) {
      for (var i in precioTotalDsctcmp) {
        if (
          precioTotalDsctcmp[i].get("v.value") &&
          precioTotalDsctcmp[i].get("v.value") < 0
        ) {
          precioTotalDsctcmp[i].set("v.errors", message_valor_negativo);
        } else {
          precioTotalDsctcmp[i].set("v.errors", null);
        }
      }
    } else if (precioTotalDsctcmp && precioTotalDsctcmp instanceof Object) {
      if (
        precioTotalDsctcmp.get("v.value") &&
        precioTotalDsctcmp.get("v.value") < 0
      ) {
        precioTotalDsctcmp.set("v.errors", message_valor_negativo);
      } else {
        precioTotalDsctcmp.set("v.errors", null);
      }
    }

    if (Array.isArray(precioTotalcmp)) {
      for (var i in precioTotalcmp) {
        if (
          precioTotalcmp[i].get("v.value") &&
          precioTotalcmp[i].get("v.value") < 0
        ) {
          precioTotalcmp[i].set("v.errors", message_valor_negativo);
        } else {
          precioTotalcmp[i].set("v.errors", null);
        }
      }
    } else if (precioTotalcmp && precioTotalcmp instanceof Object) {
      if (precioTotalcmp.get("v.value") && precioTotalcmp.get("v.value") < 0) {
        precioTotalcmp.set("v.errors", message_valor_negativo);
      } else {
        precioTotalcmp.set("v.errors", null);
      }
    }
    // validar negativos de los valores totales
    var vtAreaTotal = component.find("vtAreaTotal");
    if (vtAreaTotal && vtAreaTotal.get("v.value") < 0) {
      vtAreaTotal.set("v.errors", message_valor_negativo);
    } else if (vtAreaTotal) {
      vtAreaTotal.set("v.errors", null);
    }
    var vtPrecioTotal = component.find("vtPrecioTotal");
    if (vtPrecioTotal && vtPrecioTotal.get("v.value") < 0) {
      vtPrecioTotal.set("v.errors", message_valor_negativo);
    } else if (vtPrecioTotal) {
      vtPrecioTotal.set("v.errors", null);
    }
    var vtPrecioTotalDscto = component.find("vtPrecioTotalDscto");
    if (vtPrecioTotalDscto && vtPrecioTotalDscto.get("v.value") < 0) {
      vtPrecioTotalDscto.set("v.errors", message_valor_negativo);
    } else if (vtPrecioTotalDscto) {
      vtPrecioTotalDscto.set("v.errors", null);
    }
    // validar negativos de los valores del financimiento
    var inicial = component.find("inicial");
    if (inicial && inicial.get("v.value") < 0) {
      inicial.set("v.errors", message_valor_negativo);
    } else if (inicial) {
      inicial.set("v.errors", null);
    }
    var inicialporcentaje = component.find("inicialporcentaje");
    if (inicialporcentaje && inicialporcentaje.get("v.value") < 0) {
      inicialporcentaje.set("v.errors", message_valor_negativo);
    } else if (inicialporcentaje) {
      inicialporcentaje.set("v.errors", null);
    }
    var ncuotasinicial = component.find("ncuotasinicial");
    if (ncuotasinicial && ncuotasinicial.get("v.value") == 0) {
      ncuotasinicial.set("v.errors", message_valor_nulo);
    } else if (ncuotasinicial) {
      ncuotasinicial.set("v.errors", null);
    }
    var montocuotas = component.find("montocuotas");
    if (montocuotas && montocuotas.get("v.value") < 0) {
      montocuotas.set("v.errors", message_valor_negativo);
    } else if (montocuotas) {
      montocuotas.set("v.errors", null);
    }
    var montofinanciar = component.find("montofinanciar");
    if (montofinanciar && montofinanciar.get("v.value") < 0) {
      montofinanciar.set("v.errors", message_valor_negativo);
    } else if (montofinanciar) {
      montofinanciar.set("v.errors", null);
    }

    var tasainteres = component.find("tasainteres");
    if (tasainteres && tasainteres.get("v.value") < 0) {
      tasainteres.set("v.errors", message_valor_negativo);
    } else if (tasainteres) {
      tasainteres.set("v.errors", null);
    }

    var ncuotasfinanciar = component.find("ncuotasfinanciar");
    if (ncuotasfinanciar) {
      ncuotasfinanciar.set("v.errors", null);
    }
    if (ncuotasfinanciar && ncuotasfinanciar.get("v.value") < 0) {
      ncuotasfinanciar.set("v.errors", message_valor_negativo);
    }
    var Iniporcentajevalue = component.get("v.iniporcentajevalue");
    var ncuotasinicial = component.find("ncuotasinicial").get("v.value");
    if(Iniporcentajevalue!=100 && ncuotasinicial!=1){
      var errorExcede = [{message : "La cantidad de cuotas del financiamiento excede el máximo permitido"}];
      var interesEncontrado = this.findTasaInteres(component);
      if(ncuotasfinanciar && interesEncontrado==null){
        ncuotasfinanciar.set("v.errors", errorExcede);
      }
      this.validarTasasXzona(component);
    }

    var monotocuotafinan = component.find("monotocuotafinan");
    if (monotocuotafinan && monotocuotafinan.get("v.value") < 0) {
      monotocuotafinan.set("v.errors", message_valor_negativo);
    } else if (monotocuotafinan) {
      monotocuotafinan.set("v.errors", null);
    }
  },
  validarDatosPersona: function (component) {
    var error = false;
    var message_valor_vacio = [{ message: "Este campo esta vacío" }];
    var inpDatosPersona = component.get("v.inpDatosPersona");
    if (inpDatosPersona) {
      var inPersonaNombres = component.find("inPersonaNombres");
      var inPersonaApellidos = component.find("inPersonaApellidos");
      var search_tipoDocumento = component.find("search_tipoDocumento");
      var inPersonaNroDocumento = component.find("inPersonaNroDocumento");
      var inPersonaNroDocumento = component.find("inPersonaNroDocumento");
      var inPersonaCelular = component.find("inPersonaCelular");
      if (!inpDatosPersona.nombres && inPersonaNombres) {
        inPersonaNombres.set("v.errors", message_valor_vacio);
        error = true;
      } else if (inPersonaNombres) {
        inPersonaNombres.set("v.errors", null);
      }
      if (!inpDatosPersona.apellidos && inPersonaApellidos) {
        inPersonaApellidos.set("v.errors", message_valor_vacio);
        error = true;
      } else if (inPersonaApellidos) {
        inPersonaApellidos.set("v.errors", null);
      }
      if (!inpDatosPersona.tipoDocumento && search_tipoDocumento) {
        search_tipoDocumento.set("v.errors", message_valor_vacio);
        error = true;
      } else if (search_tipoDocumento) {
        search_tipoDocumento.set("v.errors", null);
      }
      if (!inpDatosPersona.nroDocumento && inPersonaNroDocumento) {
        inPersonaNroDocumento.set("v.errors", message_valor_vacio);
        error = true;
      } else if (inPersonaNroDocumento) {
        inPersonaNroDocumento.set("v.errors", null);
      }
      if (!inpDatosPersona.celular && inPersonaCelular) {
        inPersonaCelular.set("v.errors", message_valor_vacio);
        error = true;
      } else if (inPersonaCelular) {
        inPersonaCelular.set("v.errors", null);
      }
    } else {
      this.showAlert("Falta los datos del usuario", "warning");
      error = true;
    }
    return error;
  },
  corregirNulo: function (value) {
    if (value == "" || value == undefined) {
      return null;
    }
    if (Array.isArray(value)) {
      for (var i in value) {
        for (var j in value[i]) {
          if (value[i][j] == "" || value[i][j] == undefined) {
            value[i][j] = null;
          }
        }
      }
    }
    return value;
  },
  // ACTIONS
  getCotizacionDocumentada: function (component, idCotizacion, idOportunidad) {
    var action = component.get("c.getCotizacionPDF");
    action.setParams({
      idCotizacion: idCotizacion,
      idOportunidad: idOportunidad
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        console.log(data);
        var planillaPDFcotizadorEndpoint = $A.get(
          "$Label.c.CEN_lbl_planillaPDFcotizador"
        );
        //  open pdf visualforce
        window.open(planillaPDFcotizadorEndpoint + "?id=" + idCotizacion);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message[getCotizacionDocumentada]: " + errors[0].message);
            this.showAlert(errors[0].message, "error");
          }
        } else {
          console.log("Unknown error");
        }
      }
      component.set("v.disabledBtnGenerarFinanciamento", false);
    });
    $A.enqueueAction(action);
  },
  getDatosClienteOportunidad: function (component, idOportunidad) {
    var action = component.get("c.getDatosCliente");
    action.setParams({
      idOportunidad: idOportunidad
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data) {
          if (data.ok) {
            if (data.datosPersona != undefined && data.datosPersona != null) {
              var CotizacionLibre = component.get("v.CotizacionLibre");
              var optionsTipoDocumento = component.get(
                "v.optionsTipoDocumento"
              );
              if (!CotizacionLibre) {
                for (var r in optionsTipoDocumento) {
                  optionsTipoDocumento[r].selected = false;

                  if (
                    data.datosPersona.tipoDocumento != null &&
                    optionsTipoDocumento[r].value ==
                      data.datosPersona.tipoDocumento
                  ) {
                    optionsTipoDocumento[r].selected = true;
                  } else if (
                    data.datosPersona.tipoDocumento == null &&
                    data.datosPersona.tipoDocumento == undefined &&
                    optionsTipoDocumento[r].value == ""
                  ) {
                    data.datosPersona.tipoDocumento = "";
                    optionsTipoDocumento[r].selected = true;
                  }
                }
                component.set("v.optionsTipoDocumento", optionsTipoDocumento);
                component.set("v.inpDatosPersona", data.datosPersona);
              } else {
                this.setDatosPersona(component);
              }
            }
          } else {
            console.error(data.detalle);
          }
        } else {
          console.error("data es nulo");
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message [getDatosClienteOportunidad]: " + errors[0].message);
            this.showAlert(errors[0].message, "error");
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  showAlert: function (sms, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "dismissible",
      duration: 10000,
      message: sms,
      type: type
    });
    toastEvent.fire();
  },
    //**************************SE AGREGO 26/02/2021 ***********************
    getCMTtasasInteres : function(component, zona){
      var action = component.get("c.getTasasMdt");
      action.setParams({
          'zona': zona,
      });
      action.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
              var dataResponse = response.getReturnValue();
              component.set("v.cmtTasas",dataResponse);
              // recalcular?
          }else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
              if (errors[0] && errors[0].message) {
                console.log("Error message [getCMTtasasInteres]: " + errors[0].message);
              }
            } else {
              console.log("Unknown error");
            }
          }
      });
      $A.enqueueAction(action);
    },
    /**
     * encuentra el interes segun el ncuotas a financiar
     * @param {*} component
     * @return interes
     */
    updateTasaInteres : function(component){
      var interes = 0;
      var Iniporcentajevalue = component.get("v.iniporcentajevalue");
      var ncuotasinicial = component.find("ncuotasinicial").get("v.value");

      if(!(Iniporcentajevalue==100 && ncuotasinicial==1)){//04/07/21 - Cambio para que calcule la TCEA
        var interesEncontrado = this.findTasaInteres(component);
        if(interesEncontrado!=null){
          interes = interesEncontrado;
        }
      }

      return interes;
    },
    /**
     * encuentra la tasa de interes segun las zonas
     * @param {*} component
     * @return interesEncontrado
     */
    findTasaInteres : function(component){
      var interesEncontrado;
      var ncuotasfinanciar = component.find("ncuotasfinanciar").get("v.value");
      var zonasAevaluar = component.get("v.cmtTasas");
      var zonasFiltradas = zonasAevaluar.filter(
        x => (
          x.Numero_cuota_minima__c <= ncuotasfinanciar &&
          x.Numero_cuota_maxima__c >= ncuotasfinanciar
        )
      );
      if(zonasFiltradas && zonasFiltradas.length > 0){
        interesEncontrado = zonasFiltradas[0].Tasa__c;
      } else if(!zonasFiltradas || zonasFiltradas.length==0){
        interesEncontrado = null;
      }
      return interesEncontrado;
    },
    validarTasasXzona : function (component) {
      var tasainteres = component.find("tasainteres");
      var errorSintasas = [{message : "No se ha configurado la tasa de interes de la zona."}];
      var zonasAevaluar = component.get("v.cmtTasas");
      if(!zonasAevaluar || (zonasAevaluar && Array.isArray(zonasAevaluar) && zonasAevaluar.length <= 0)){
        tasainteres.set("v.errors", errorSintasas);
      }
    },

    //inicio 24/07/2023
    changeMontoDeCuotas: function (component, event, helper,checkPrimeraCuota,porcentajePrimeraCuotaInicial) {
      var checkCmp = component.find("checkbox");
      var checkCICmp = component.find("checkboxCI");
      var tipoVenta = component.find("slcTypeOfSale").get("v.value");
      var inicialvalue = component.get("v.inicialvalue");//valor total con descuento
      var montocuota = component.get("v.montoCuota");//descuento de la 1ra cuota nCuoInit
      var nCuoInit = component.get("v.nCuoInit");
      if (checkPrimeraCuota && porcentajePrimeraCuotaInicial>0) {
        var cuotaMensual = (inicialvalue - montocuota)/(nCuoInit-1);
        var factorOfTen = Math.pow(10, 3);
        var factorOfTen2 = Math.round(cuotaMensual * factorOfTen) / factorOfTen;
        cuotaMensual = Number(Math.round(factorOfTen2 + "e2") + "e-2");
        component.set("v.montoDeCuotas", cuotaMensual);
      }

      if(nCuoInit>1 && tipoVenta == 'CD'){
        component.set("v.flagDesembolso", false);
        if(!checkPrimeraCuota){checkCmp.set("v.disabled", false);}
        checkCICmp.set("v.disabled", false);
        //checkCmp.set("v.value", false);
        if(!checkPrimeraCuota){checkCICmp.set("v.value", false);}
        component.set("v.selectedFrecuencia", "0");
        //var action = component.get("c.onChangeFrecuencia");
        //$A.enqueueAction(action);
        //component.set("v.disabledPrimeraCuotaInicial", false);
      }else if(tipoVenta != 'CS'){
        component.set("v.flagDesembolso", true);
        checkCmp.set("v.disabled", true);
        checkCICmp.set("v.disabled", true);
        checkCmp.set("v.value", false);
        checkCICmp.set("v.value", false);
        //component.set("v.disabledPrimeraCuotaInicial", true);
      }
    },
    //fin 24/07/2023
    /************************** 19/04/2021 ***********************/
    getCuotasFaciloteHelper: function(component){
        //console.log("Ingreso a CuotasFaciloteHelper");
        var action = component.get("c.getCuotasFacilote");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var dataResponse = response.getReturnValue();
                //console.log(dataResponse);
                //component.set("v.nCuoInit", dataResponse[0].Numero_cuotas__c);
                component.set("v.nCuoFacilList", dataResponse);

                var listLength = component.get("v.nCuoFacilList").length;
                //console.log("Tamaño lista: " + listLength);

                var nueva = [1,2];
                //console.log(nueva[1]);
                var cadena = "";

                for(var i=0; i<listLength ; i++){
                    nueva[i] = dataResponse[i].Numero_cuotas__c;
                    //console.log(nueva);
                    cadena = cadena + dataResponse[i].Numero_cuotas__c + ", ";
                }
                cadena = "Valores admitidos para este campo son: " + (cadena.slice(0, -2));
                //console.log(cadena);
                component.set("v.stringnCuoFacilList", cadena);

                component.set("v.nCuoFacilList", nueva);
                //console.log(component.get("v.nCuoFacilList"));
            }
            else if (state === "ERROR") {
              this.errorFunctionHandler(component, response);
            }
        });
        //@ts-ignore
        $A.enqueueAction(action);
    },

    /**
     * @description Obtiene los lotes disponibles a recotizar
     * @createdDate 20/07/2021
     * @param {*} component
     */
    getLotesRelacionadosAoportunidad : function(component, idOportunidad){
      var esCotizacionLibre = component.get("v.CotizacionLibre");

      if(!esCotizacionLibre){

        var action = component.get("c.getCodigosLotesRecotizables");

        action.setParams( { recordId : idOportunidad } );
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {

              var codigosLotes = response.getReturnValue();
              if(codigosLotes != null && codigosLotes != undefined && Array.isArray(codigosLotes)){
                component.set("v.codigosLotesRelOpp", codigosLotes);
              }

            }
            else if (state === "ERROR") {
              this.errorFunctionHandler(component, response);
            }
        });
        // @ts-ignore
        $A.enqueueAction(action);

      }
    },

    /**
     * @description Funcion para el response con error
     * @createdDate 20/07/2021
     * @param {*} component
     * @param {*} response
     */
    errorFunctionHandler : function(component, response){
      var errors = response.getError();

      if (errors) {
          if (errors[0] && errors[0].message) {
              console.log("Error message[errorFunctionHandler]: " + errors[0].message);
          }
      } else {
          console.log("Unknown error");
      }
    },
    getTypeOfSale: function (component) {
      var action = component.get("c.getTipoVenta");
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS"){
              //	insetar tipo venta
              var datos = response.getReturnValue();
              if(datos){
                  datos = datos.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
              }
              console.log('datos');
              console.log(datos);
              component.set("v.optionsTypeOfSale", datos);
          }else if (state === "INCOMPLETE"){
              console.log("No se terminó de obtener los datos de tipo de venta. Revisar conexión a internet.");
          }else if (state === "ERROR") {
              var errors = response.getError();
              if(errors){
                  if(errors[0] && errors[0].message){
                      console.log("Error obteniendo tipo de venta. " + errors[0].message);
                  }
              }else{
                  console.log("Unknown error");
              }
          }
      });
      $A.enqueueAction(action);
    },

    getFinanciamiento: function (component, IdOportunidad, simulador) {

      var flagCalcularCotizacion = component.get("v.flagCalcularCotizacion");

      var nCuotas = component.get("v.nCuoInit");
      var nCuotasSaldo = component.get("v.numCuotas");
      console.log("nCuotas: " + nCuotas);
      console.log("nCuotasSaldo: " + nCuotasSaldo);
      var flagCalcularDescuento = component.get("v.flagCalcularDescuento");
      var hasPermission = component.get("v.hasPermission");
      var nCuotasTotal = nCuotasSaldo + nCuotas - 1;
      console.log("nCuotasTotal: " + nCuotasTotal);
      var action = component.get("c.generateAndUpdateOperationSafe");

      if (!flagCalcularCotizacion && !flagCalcularDescuento) {
        return false;
      }

      action.setParams({
        IdOportunidad: IdOportunidad,
        simulador: simulador
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log('state[Simulacion]: ' + state);
        if (state === "SUCCESS") {
          var data = response.getReturnValue();
          //console.log('financiamiento:');
          //console.table(data);
          if (data) {
            var resp = JSON.parse(data.success);
            console.log('data.error:'+data.success);
            console.log('data.error:'+data.errorType);
            var errorType = data.errorType;
            var errors = resp.ET_RETURN;
            if (errors != null && errorType != 'S') {
              //console.log('financiamiento-Error');
              var errorList = errors.item;
              errorList.forEach((item) => {
                  var message = item.MESSAGE;
                  var variant = 'error';
                  this.showAlert(message, variant);
                  //console.log(item.MESSAGE_V1);
              });
              component.set("v.flagCalcularDescuento", false);
              component.set("v.disabledBtnGenerarFinanciamento", true);
            }else{
              console.log('financiamiento-Success');
              var cuotasSimu = resp.ET_CUOTAS_SIMU_PROF;        //Felipe
              var listaFin = this.mapearCuotasSimu(cuotasSimu); //Felipe
              component.set("v.listaFinanciamiento", listaFin); //Felipe

              var cabecera = resp.E_CAB_PROFORMA_SF;
              var tasaInteresComp = parseFloat(cabecera.TASA_ANUAL_INTERES_FINAN);
              var montoAFinanciar = parseFloat(cabecera.IMPORTE_SALDO_PRECIO);
              var viaFinanciamiento = cabecera.VIA_FINANCIAMIENTO;
              var cuotaFacilote = cabecera.FACILOTE_IND_CI;
              var cuotas = resp.ET_CUOTAS_PROFORMA_SF;
              if(cuotas != null){
                if(viaFinanciamiento == 'CD'){
                  var cuota = Object.values(resp.ET_CUOTAS_PROFORMA_SF)[0];
                  var montoCuotaFinanciar = cuota[nCuotas].IMP_CUOTA;
                  var montoCuotaRestanteFinanciar = cuota[nCuotas+1].IMP_CUOTA;
                  console.log('montoCuotaRestanteFinanciar: ' + montoCuotaRestanteFinanciar);
                  var primeraFechaCuotaSaldo = cuota[nCuotas].FECHA_VENCIMIENTO;
                  var ultimaFechaCuotaSaldo = cuota[nCuotasTotal].FECHA_VENCIMIENTO;
                  component.set("v.tasainter", tasaInteresComp);
                  component.set("v.monotofinan", montoAFinanciar);
                  component.set("v.monotocuotafinan", montoCuotaFinanciar);
                  component.set("v.montocuotarestfinan", montoCuotaRestanteFinanciar);
                  component.set("v.fecCuotaSaldoIni", primeraFechaCuotaSaldo);
                  component.set("v.fecCuotaSaldoFin", ultimaFechaCuotaSaldo);
                  if(cuotaFacilote == 'X'){
                    //component.find("montoCuota").set("v.value", cuota[2].IMP_CUOTA);
                    var inpAnotaciones = [];
                    inpAnotaciones.push({
                        key: 1,
                        fecha: cuota[0].FECHA_VENCIMIENTO,
                        monto:  cuota[0].IMP_CUOTA,
                        anotaciones: "Cuota 1 de la inicial (Pago minimo para la firma de contrato)"
                    });
                    inpAnotaciones.push({
                        key: 2,
                        fecha: cuota[1].FECHA_VENCIMIENTO,
                        monto:  cuota[1].IMP_CUOTA,
                        anotaciones: "Cuota 2 de la inicial"
                    });
                    inpAnotaciones.push({
                        key: 3,
                        fecha: cuota[2].FECHA_VENCIMIENTO,
                        monto: cuota[2].IMP_CUOTA,
                        anotaciones: "De la cuota 3 a la cuota "+ component.get("v.nCuoInit") +" de la inicial"
                    });

                    component.set("v.inpAnotaciones", inpAnotaciones);

                  }else{
                    //component.find("montoCuota").set("v.value", cuota[0].IMP_CUOTA);
                  }

                  component.set("v.disabledBtnSimuladorPrepago", false);

                }else if(viaFinanciamiento == 'CS'){
                  var checkCICmp = component.find("checkboxCI");
                  var flagPrimeraCuota = checkCICmp.get("v.value");
                  var cuota = Object.values(resp.ET_CUOTAS_PROFORMA_SF)[0];
                  var montoCuotaFinanciar = flagPrimeraCuota ? cuota[1].IMP_CUOTA : cuota[0].IMP_CUOTA;
                  component.set("v.monotocuotafinan", montoCuotaFinanciar);
                }
              }

              /** TASAS */
              var tasas = resp.ET_TASAS_POLITVEN;
              if(tasas != null){
                component.set("v.tasa", tasas.item[0].TASA);
                component.set("v.codTasa", tasas.item[0].COD_TASA);
                var myMap = component.get("v.data");
                myMap['tasa'] = tasas.item[0].TASA;
                myMap['codTasa'] = tasas.item[0].COD_TASA;
                component.set("v.data", myMap);
                //console.log("myMap: " + JSON.stringify(myMap));
                //component.set("v.tasainter", tasas.item[0].TASA);
              }
              // var fieldMap = [];
              // fieldMap.push({value: 0, label: 'Seleccione Tasa', selected : true});
              // if(tasas != null){
              //   tasas.item.forEach((tasa) => {
              //     fieldMap.push({value: tasa.TASA, label: tasa.COD_TASA, selected : false});
              //   });
              //   if(fieldMap){
              //     fieldMap = fieldMap.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
              //   }
              //   component.set("v.optionsTasa", fieldMap);
              // }else{
              //   component.set("v.tasainter", tasaInteresComp);
              //   fieldMap.push({value: tasaInteresComp, label: 'Tasa Cotizada', selected : true});
              //   component.set("v.disabledTasa",true);
              //   component.set("v.disabledBtnCalcularFinanciamento", true);
              //   component.set("v.optionsTasa", fieldMap);
              // }

              /** DESCUENTOS - INICIO */
              var listDiscount = resp.ET_DETALLE_DSCTO_ADICIONAL == null ? [] : Object.values(resp.ET_DETALLE_DSCTO_ADICIONAL)[0];
              var listPalanca = resp.ET_DETALLE_PALANCAS == null ? [] : Object.values(resp.ET_DETALLE_PALANCAS)[0];
              var listMessage = resp.ET_MENSAJE_DSCTO_PALANCAS == null ? [] : Object.values(resp.ET_MENSAJE_DSCTO_PALANCAS)[0];
              component.set("v.listDiscount", JSON.stringify(listDiscount));
              component.set("v.listPalanca", JSON.stringify(listPalanca));
              component.set("v.listMessage", JSON.stringify(listMessage));
              /** DESCUENTOS - FIN */

              component.set("v.disabledBtnGestionDescuento", false);
              component.set("v.disabledBtnGenerarFinanciamento", false);

              if(flagCalcularDescuento){
                component.set("v.flagCalcularDescuento", false);
                component.set("v.disabledBtnGenerarFinanciamento", true);
                var findChildComp=component.find('childGestionDescuento');
                findChildComp.openModal();
              }

            }
          } else {
            console.error("data es nulo");
          }
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message[getFinanciamiento]: " + errors[0].message);
              this.showAlert(errors[0].message, "error");
            }
          } else {
            console.log("Unknown error");
          }
        }

        component.set("v.flagCalcularCotizacion", false);
        component.set("v.disabledPeriodos", false);
      });
      $A.enqueueAction(action);
    },

    //ESCENARIOS DE FINANCIAMIENTO
    getPeriodosCotizacion: function (component,IdOportunidad) {
      console.log("Botón Simulador Periodos clickeado");

      var action = component.get("c.generateAndUpdateOperationSafePeriodo");
      action.setParams({
        IdOportunidad: IdOportunidad,
        simulador: true
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var data = response.getReturnValue();
            //console.log('financiamiento:');
            //console.table(data);
            if (data) {
              var resp = JSON.parse(data.success);
              var errorType = data.errorType;
              var errors = resp.ET_RETURN;
              if (errors != null && errorType != 'S') {
                //console.log('financiamiento-Error');
                var errorList = errors.item;
                errorList.forEach((item) => {
                    var message = item.MESSAGE;
                    var variant = 'error';
                    this.showAlert(message, variant);
                    //console.log(item.MESSAGE_V1);
                    component.set("v.disabledPeriodos", false);
                });
              }else{
                console.log('financiamiento-Success Periodos');
                var cuotasSimu = resp.ET_CUOTAS_SIMU_PROF;        //Felipe
                console.log("cuotasSimu" + cuotasSimu);
                var listaFin = this.mapearCuotasSimu(cuotasSimu); //Felipe
                component.set("v.listaFinanciamiento", listaFin); //Felipe
                component.set("v.disabledPeriodos", true);
              }
            } else {
              console.error("data es nulo");
            }
          } else if (state === "ERROR") {
           // Toast de error de servicio
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: message,
                type: "error"
            });
            toastEvent.fire();
          }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Completado",
            message: "Los periodos fueron calculados correctamente",
            type: "success"
        });
        toastEvent.fire();
      });
      $A.enqueueAction(action);
    },


    mapearCuotasSimu: function (cuotasSimu) {
      var lista = [];
      if (!cuotasSimu || !cuotasSimu.item) {
          return lista;
      }
      cuotasSimu.item.forEach(function (c) {
          var monto = c.IMP_CUOTA;
          lista.push({
              anio: parseInt(c.SALDO_NO_CUOTAS, 10),
              monto: monto,
              mensajeError: monto === 0 ? c.MENSAJE_ERROR : null
          });
      });
      return lista;
    },
    //FIN ESCENARIOS DE FINANCIAMIENTO


    validatePermissionSet: function (component, event, helper) {
      // Obtener el nombre del permission set
      var permissionSetName = "CEN_DiscountSupervisorJefe";
      var permissionSetNameAdditional = "CEN_DiscountAdditionalSupervisorJefe";
      //var permissionSetName = "MyPermissionSet";

      // Llamar a un método Apex para verificar si el usuario actual tiene el permiso del permission set
      var action = component.get("c.checkPermission");
      action.setParams({permissionSetName: permissionSetName});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              // Obtener el valor booleano de la respuesta y establecer la variable de componente hasPermission en consecuencia
              component.set("v.hasPermission", response.getReturnValue());
          }
          else {
              // Manejar el error
              console.log("Error: " + response.getError());
          }
      });

      $A.enqueueAction(action);
    },

    validatePermissionAdditionalSet: function (component, event, helper) {
      // Obtener el nombre del permission set
      var permissionSetName = "CEN_DiscountAdditionalSupervisorJefe";
      //var permissionSetName = "MyPermissionSet";

      // Llamar a un método Apex para verificar si el usuario actual tiene el permiso del permission set
      var action = component.get("c.checkPermission");
      action.setParams({permissionSetName: permissionSetName});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              // Obtener el valor booleano de la respuesta y establecer la variable de componente hasPermission en consecuencia
              component.set("v.hasPermissionAdditional", response.getReturnValue());
          }
          else {
              // Manejar el error
              console.log("Error: " + response.getError());
          }
      });

      $A.enqueueAction(action);
    },

    uploadFile: function (component, idOportunidad) {
      var filesUploaded = component.get("v.filesUploaded");
      var action = component.get("c.uploadFile");
      action.setParams({
        filesToInsert: filesUploaded,
        recordId: idOportunidad
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          console.log('cargo archivo');
        } else {
          // Manejar el error
          console.log("Error: " + response.getError());
        }
      });
      $A.enqueueAction(action);

    },

    CuotasFinanciamiento: function (component, event,helper,rate,periods,vmonto){
      var vmonto;
      var periods;
      var rate;
      var payment;
      var rateTaxMonth;
      var ratePeriods;
      rate=rate/100;
      rateTaxMonth=Math.pow(1 + rate, 1/12)-1;
      ratePeriods=Math.pow(1 + rateTaxMonth, periods*12);
      rate=(rateTaxMonth*ratePeriods)/(ratePeriods-1);
      payment =vmonto*rate;
      return payment.toFixed(2);
    },

    calcularFecha: function (component, fecha, frecuencia){
      var fieldMapFechas = [];
      var quincena = new Date(fecha.getFullYear(), fecha.getMonth(), 15);
      var diaA, diaB;
      var siguienteMes;
      var fechaOpcionA, fechaOpcionB, fechaOpcionC;
      var valorOpcionA, valorOpcionB, valorOpcionC;
      var frecuenciaSeleccionada = frecuencia;
      
      console.log('frecuencia: ' + frecuencia);
      console.log('fecha: ' + fecha);
      if(fecha > quincena){
        diaA = 1;
        diaB = 15;
      }else{
        frecuencia = parseInt(frecuencia) - 1;
        diaA = 15;
        diaB = 1;
      }

      console.log('diaA: ' + diaA);
      console.log('diaB: ' + diaB);

      frecuencia = parseFloat(frecuencia);
      console.log('frecuencia: ' + frecuencia);
      console.log('fecha.getMonth(): ' + fecha.getMonth());
      siguienteMes = new Date(fecha.setMonth(fecha.getMonth()+frecuencia));
      console.log('siguienteMes: ' + siguienteMes);
      fechaOpcionA = new Date(siguienteMes.getFullYear(), siguienteMes.getMonth(), diaA);
      //fechaOpcionA = new Date(2025,3,15);
      siguienteMes = diaA == 1 ? new Date(fecha.setMonth(fecha.getMonth())) : new Date(fecha.setMonth(fecha.getMonth()+1));
      fechaOpcionB = new Date(siguienteMes.getFullYear(), siguienteMes.getMonth(), diaB);
      //fechaOpcionB = new Date(2025,4,1);
      siguienteMes = diaA == 1 ? new Date(fecha.setMonth(fecha.getMonth()+1)) : new Date(fecha.setMonth(fecha.getMonth()));
      fechaOpcionC = new Date(siguienteMes.getFullYear(), siguienteMes.getMonth(), diaA);
      //fechaOpcionC = new Date(2026,1,1);

      console.log('fechaOpcionA: ' + fechaOpcionA);
      console.log('fechaOpcionB: ' + fechaOpcionB);
      console.log('fechaOpcionC: ' + fechaOpcionC);

      valorOpcionA = this.formatearFecha(fechaOpcionA);
      valorOpcionB = this.formatearFecha(fechaOpcionB);
      valorOpcionC = this.formatearFecha(fechaOpcionC);

      if(frecuenciaSeleccionada > 0){
        fieldMapFechas.push({value: "0", label: 'Seleccione Opción', selected : true});
        fieldMapFechas.push({value: valorOpcionA, label: 'OPCION A', selected : false});
        fieldMapFechas.push({value: valorOpcionB, label: 'OPCION B', selected : false});
        fieldMapFechas.push({value: valorOpcionC, label: 'OPCION C', selected : false});
      }else{
        fieldMapFechas.push({value: "0", label: 'Seleccione Opción', selected : true});
      }
      component.set("v.fechaDesembolso", "");
      component.set("v.disabledOpcion",true);
      setTimeout(function () {
        component.set("v.disabledOpcion",false);
      }, 2000);

      return fieldMapFechas;
    },

    formatearFecha: function (fecha){
      let day = fecha.getDate();
      let month = fecha.getMonth() + 1;
      let year = fecha.getFullYear();
      let fechaFormateada = year + '-' + ('0'+month).slice(-2) + '-' + ('0'+day).slice(-2);
      return fechaFormateada;
    }

});