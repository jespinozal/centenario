({
  onclickLimpiarFiltros: function (component) {
    var objInputBuscador = {
      nroCotizacion: null,
      fechaCotizacion: null,
      nombres: null,
      apellidos: null,
      tipoDocumento: "todos",
      nroDocumento: null
    };
    component.set("v.objInputBuscador", objInputBuscador);
    var optionsTipoDocumento = component.get("v.optionsTipoDocumento");
    for (var r in optionsTipoDocumento) {
      if (
        optionsTipoDocumento[r] != null &&
        objInputBuscador.tipoDocumento == optionsTipoDocumento[r].value
      ) {
        optionsTipoDocumento[r].selected = true;
      } else {
        optionsTipoDocumento[r].selected = false;
      }
    }
    component.set("v.optionsTipoDocumento", optionsTipoDocumento);
  },
  //  ACTIONS
  buscarCotizacionesLibres: function (component, objInputBuscador) {
    var action = component.get("c.buscarRegistrosCotizacionesLibres");
    action.setParams({
      objInputBuscadorJSON: JSON.stringify(objInputBuscador)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data && data.ok) {
          component.set(
            "v.listaCotizacionLibreWrapper",
            data.cotizacionesLibres
          );
        } else {
          this.showToast(
            component,
            "Error",
            "No se pudo buscar las cotizaciones libres.",
            "error"
          );
          console.log(data);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
      } else if (state === "ERROR") {
        var errors = response.getError();
        console.error("Error: " + JSON.stringify(errors));
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
        this.showToast(
          component,
          "Error interno",
          "Ocurrió un error interno con la búsqueda de Cotizaciones.",
          "error"
        );
      }
      component.set("v.estaBuscandoCotizaciones", false);
    });
    component.set("v.estaBuscandoCotizaciones", true);
    $A.enqueueAction(action);
  },
  obtenerTiposDocumentoCotizacion: function (component) {
    var action = component.get("c.getListaTipoDocumentos");
    action.setCallback(this, function (response) {
      var state = response.getState();
      var optionsTipoDocumento = [];
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data && data.ok) {
          optionsTipoDocumento = data.tipoDocumentos;
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
            console.error("Error message: " + errors[0].message);
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
      optionsTipoDocumento.push({
        label: "Todos",
        value: "todos",
        selected: true
      });
      component.set("v.optionsTipoDocumento", optionsTipoDocumento);
    });
    $A.enqueueAction(action);
  },
  obtenerDatosPersonaOportunidad: function (component) {
    var action = component.get("c.getDatosPersonaOportunidad");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data != null && data != undefined) {
          component.set("v.objInputBuscador", JSON.parse(JSON.stringify(data)));
        } else {
          this.onclickLimpiarFiltros(component);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  procesarAsociacion: function (
    component,
    idCotizacionSeleccionado,
    idOportunidad
  ) {
    // primero, obtener todos los lotes de la cotizacion
    this.showToast(
      component,
      null,
      "Obteniendo los Lotes de la cotización...",
      "info"
    );
    var action = component.get("c.getLotesCotizacion");
    action.setParams({
      idCotizacion: idCotizacionSeleccionado
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data != null && data.ok) {
          component.set("v.lotesCotizacionSeleccionado", data.lotesCotizacion);
          if (data.lotesCotizacion && data.lotesCotizacion.length > 0) {
            this.showToast(
              component,
              null,
              "Validando libertad de los Lotes de la cotización con SAP...",
              "info"
            );
            // iterar todos los lotes
            for (var r in data.lotesCotizacion) {
              this.validarLibertadLote(
                component,
                data.lotesCotizacion[r],
                idCotizacionSeleccionado,
                idOportunidad
              );
            }
          } else {
            this.showToast(
              component,
              "Lotes no encontrados",
              "La cotización elegida no tiene Lotes",
              "error"
            );
            component.set("v.asociandoCotizacion", false);
          }
        } else {
          this.showToast(component, "Error", data.mensaje, "error");
          console.error(data.detalle);
          component.set("v.asociandoCotizacion", false);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
        component.set("v.asociandoCotizacion", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
        component.set("v.asociandoCotizacion", false);
      }
    });
    $A.enqueueAction(action);
  },
  validarLibertadLote: function (
    component,
    loteWrapper,
    idCotizacionSeleccionado,
    idOportunidad
  ) {
    // segunda, validar si los lotes estan libres
    var action = component.get("c.validarLoteLibre");
    action.setParams({
      idLote: loteWrapper.idLote,
      codLote: loteWrapper.codLote,
      codProyecto: loteWrapper.codProyecto,
      manzana: loteWrapper.manzana
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      var lotesCotizacionSeleccionado = component.get(
        "v.lotesCotizacionSeleccionado"
      );
      var maplotesCotizacionSeleccionado = new Map(
        lotesCotizacionSeleccionado.map((i) => [i.idLote, i])
      );
      var estado = "No verificado";
      var estaLibre = false;
      var idLote = loteWrapper.idLote;
      var validado = true;
      var nombreLote = maplotesCotizacionSeleccionado.get(idLote).nombreLote;

      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data != null && data.ok) {
          if (data.lotesCotizacion && data.lotesCotizacion.length > 0) {
            // asociar a la lista y actualizar estado de libertad
            estado = data.lotesCotizacion[0].estado;
            estaLibre = data.lotesCotizacion[0].estaLibre;

            // en caso de que el lote no es libre alertar error
            if (!estaLibre) {
              var lotesNoLibre = component.get("v.lotesNoLibre");
              if (lotesNoLibre == null || lotesNoLibre == undefined) {
                lotesNoLibre = [];
              }
              lotesNoLibre.push(nombreLote);
              component.set("v.lotesNoLibre", lotesNoLibre);
            }
          }
        } else {
          this.showToast(component, "Error", data.mensaje, "error");
          console.error(data.detalle);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
      }
      // insertar los datos del lote
      maplotesCotizacionSeleccionado.get(idLote).estado = estado;
      maplotesCotizacionSeleccionado.get(idLote).estaLibre = estaLibre;
      maplotesCotizacionSeleccionado.get(idLote).validado = validado;

      var lotesCotizacionSeleccionado = Array.from(
        maplotesCotizacionSeleccionado.values()
      );
      component.set(
        "v.lotesCotizacionSeleccionado",
        lotesCotizacionSeleccionado
      );
      // verificar si todos los lotes estan validados y libres para ejecutar asociacion
      var procesados = lotesCotizacionSeleccionado.filter((x) =>
        x.validado == true ? true : false
      );
      if (
        procesados &&
        lotesCotizacionSeleccionado.length == procesados.length
      ) {
        this.asociarCotizacion(
          component,
          idCotizacionSeleccionado,
          idOportunidad
        );
      }
    });
    $A.enqueueAction(action);
    // marcar lote como procesado
    var lotesCotizacionSeleccionado = component.get(
      "v.lotesCotizacionSeleccionado"
    );
    var maplotesCotizacionSeleccionado = new Map(
      lotesCotizacionSeleccionado.map((i) => [i.idLote, i])
    );
    maplotesCotizacionSeleccionado.get(loteWrapper.idLote).procesado = true;
    var lotesCotizacionSeleccionado = Array.from(
      maplotesCotizacionSeleccionado.values()
    );
    component.set("v.lotesCotizacionSeleccionado", lotesCotizacionSeleccionado);
  },
  asociarCotizacion: function (
    component,
    idCotizacionSeleccionado,
    idOportunidad
  ) {
    var lotesNoLibre = component.get("v.lotesNoLibre");
    if (lotesNoLibre && lotesNoLibre.length > 0) {
      this.showToast(
        component,
        "Algunos lotes no están libres",
        "Los siguientes lotes no están libre: " + lotesNoLibre.join(", "),
        "warning"
      );
      component.set("v.asociandoCotizacion", false);
      component.set("v.lotesCotizacionSeleccionado", null);
      component.set("v.lotesNoLibre", null);
      return;
    }
    // limpiar datos reusables
    component.set("v.lotesNoLibre", null);
    component.set("v.lotesCotizacionSeleccionado", null);
    component.set("v.lotesNoLibre", null);
    // tercero, si todos los lotes estan validados y libres ejectuar asociacion
    this.showToast(
      component,
      null,
      "Asociando la cotización y los lotes a la oportunidad en desarrollo...",
      "info"
    );

    var action = component.get("c.setCotizacionAoportunidad");
    action.setParams({
      idCotizacion: idCotizacionSeleccionado,
      idOportunidad: idOportunidad
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data != null && data.ok) {
          component.set("v.idCotizacionSeleccionado", null);
          this.showToast(
            component,
            "¡Cotización asociada!",
            "La cotización se asoció a la oportunidad correctamente.",
            "success"
          );
          this.buscarCotizacionesLibres(
            component,
            component.get("v.objInputBuscador")
          );
        } else {
          this.showToast(component, "Error", data.mensaje, "error");
          console.error(data.detalle);
        }
      } else if (state === "INCOMPLETE") {
        console.warn("INCOMPLETE");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.error("Error message: " + errors[0].message);
          }
        } else {
          console.error("Unknown error");
        }
      }
      component.set("v.asociandoCotizacion", false);
    });
    $A.enqueueAction(action);
  },
  //  TOOLS
  showToast: function (component, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      mode: "dismissible",
      type: type,
      duration: 6000
    });
    toastEvent.fire();
  }
});