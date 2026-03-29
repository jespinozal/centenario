({
  /* doInitHelper funcation to fetch all records, and set attributes value on component load */
  doInitHelper: function (component, event) {
    var IdProyecto = component.get("v.idProyecto");
    console.log("IdProyecto: " + IdProyecto);

    var spinner = component.find("mySpinner");
    $A.util.toggleClass(spinner, "slds-hide");

    var action1 = component.get("c.fetchAccountWrapper");
    action1.setParams({
      Idproyecto: IdProyecto
    });
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();

        if (oRes.estado == "ok") {
          //	Setear mínimos y máximos
          component.set("v.sliderTamaniomin", oRes.tamanioMin);
          component.set("v.sliderTamaniomax", oRes.tamanioMax);
          component.set("v.sliderTamanio1Value", oRes.tamanioMin);
          component.set("v.sliderTamanio2Value", oRes.tamanioMax);

          component.set("v.sliderPreciomin", oRes.precioMin);
          component.set("v.sliderPreciomax", oRes.precioMax);
          component.set("v.sliderPrecio1Value", oRes.precioMin);
          component.set("v.sliderPrecio2Value", oRes.precioMax);

          if (oRes.getlotes.length > 0) {
            //console.table(oRes.getlotes); //SOLO PRUEBA BIMONEDA
            component.set("v.listOfAllAccounts", oRes.getlotes);
            var pageSize = component.get("v.pageSize");
            var totalRecordsList = oRes.getlotes;
            var totalLength = totalRecordsList.length;

            component.set("v.totalRecordsCount", totalLength);
            component.set("v.startPage", 0);
            component.set("v.endPage", pageSize - 1);
            var PaginationLst = [];
            for (var i = 0; i < pageSize; i++) {
              if (oRes.getlotes.length > i) {
                PaginationLst.push(oRes.getlotes[i]);
              }
            }
            component.set("v.bNoRecordsFound", false);
            component.set("v.PaginationList", PaginationLst);
            component.set("v.selectedCount", 0);
            component.set("v.selectedPrecioTotal", 0);
            component.set("v.selectedElegido", "todos");
            //use Math.ceil() to Round a number upward to its nearest integer
            component.set(
              "v.totalPagesCount",
              Math.ceil(totalLength / pageSize)
            );
            console.log("Entra a filtro");

            this.filterData(component);
            //this.autoSeleccionar(component);
          } else {
            // if there is no records then display message
            component.set("v.bNoRecordsFound", true);
            console.log(oRes.mensaje);
            component.set("v.serviceMensaje", oRes.mensaje);
          }
        } else {
          component.set("v.bNoRecordsFound", true);
          console.log(oRes.mensaje);
          component.set("v.serviceMensaje", oRes.mensaje);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
      $A.util.toggleClass(spinner, "slds-hide");
    });
    $A.enqueueAction(action1);
  },
    // se obtiene desde el apex el proyecto de la oportunidad
  getDatosProyectoOportunidad: function (component, IdOportunidad) {
    var action = component.get("c.getProyectoDeOportunidad");
    action.setParams({
      IdOportunidad: IdOportunidad
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data != null && data != undefined) {
          component.set("v.selectedLookUpRecord", data);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            this.showAlert(errors[0].message, "error");
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  // navigate to next pagination record set
  next: function (component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var dataF = sObjectList.filter((element) => element.isVisible);
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (dataF.length > i) {
        Paginationlist.push(dataF[i]);
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
  // navigate to previous pagination record set
  previous: function (component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var dataF = sObjectList.filter((element) => element.isVisible);
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        Paginationlist.push(dataF[i]);

        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
  filterData: function (component) {
    var minValT,
      maxValT,
      minValP,
      maxValP,
      lote,
      manzana,
      i,
      data,
      estado,
      orden,
      elegido,
      moneda,
      bimoneda;
    //	Filter all datatable
    estado = component.get("v.selectedValueEstado");
    orden = component.get("v.selectedOrdenPor");
    elegido = component.get("v.selectedElegido");
    minValT = component.get("v.sliderTamanio1Value");
    console.log("minValT: " + minValT);
    maxValT = component.get("v.sliderTamanio2Value");
    console.log("maxValT: " + maxValT);
    minValP = component.get("v.sliderPrecio1Value");
    console.log("minValP: " + minValP);
    maxValP = component.get("v.sliderPrecio2Value");
    console.log("maxValP: " + maxValP);
    lote = component.find("lote").get("v.value");
    lote = lote.toUpperCase();
    manzana = component.find("manzana").get("v.value");
    manzana = manzana.toUpperCase();
    moneda = component.get("v.selectedMoneda");
    bimoneda = component.get("v.bimoneda");

    data = component.get("v.listOfAllAccounts");

    if (!estado) {
      estado = "";
    } else {
      estado = estado.toUpperCase();
    }
    if (!manzana) {
      manzana = "";
    }
    if (!lote) {
      lote = "";
    }
    console.log("estado: " + estado);
    console.log("manzana: " + manzana);
    console.log("lote: " + lote);
    console.log("moneda: " + moneda);
    console.log("bimoneda: " + bimoneda);

    data = data.sort(function (a, b) {
      if (orden == "LoteASC") {
        if (a.Descripcionlote > b.Descripcionlote) {
          return 1;
        }
        if (a.Descripcionlote < b.Descripcionlote) {
          return -1;
        }
      } else if (orden == "LoteDESC") {
        if (a.Descripcionlote < b.Descripcionlote) {
          return 1;
        }
        if (a.Descripcionlote > b.Descripcionlote) {
          return -1;
        }
      } else if (orden == "AreaASC") {
        if (a.Area > b.Area) {
          return 1;
        }
        if (a.Area < b.Area) {
          return -1;
        }
      } else if (orden == "AreaDESC") {
        if (a.Area < b.Area) {
          return 1;
        }
        if (a.Area > b.Area) {
          return -1;
        }
      } else if (orden == "PrecioASC") {
        if (a.Precioventafun > b.Precioventafun) {
          return 1;
        }
        if (a.Precioventafun < b.Precioventafun) {
          return -1;
        }
      } else if (orden == "PrecioDESC") {
        if (a.Precioventafun < b.Precioventafun) {
          return 1;
        }
        if (a.Precioventafun > b.Precioventafun) {
          return -1;
        }
      } else if (orden == "ManzanaASC") {
        if (a.Manzana > b.Manzana) {
          return 1;
        }
        if (a.Manzana < b.Manzana) {
          return -1;
        }
      } else if (orden == "ManzanaDESC") {
        if (a.Manzana < b.Manzana) {
          return 1;
        }
        if (a.Manzana > b.Manzana) {
          return -1;
        }
      }
      return 0;
    });

    var totalLength = 0;

    for (i = 0; i < data.length; i++) {

      if(data[i].Bimoneda == 'X' && moneda == 'USD'){
        data[i].Precioventafun = parseFloat(data[i].Precioventafuncional2);
        data[i].Codmonedafuncional = data[i].Codmonedafuncional2;
      }else if(data[i].Bimoneda == 'X' && moneda == 'PEN'){
        data[i].Precioventafun = data[i].PrecioOriginal;
        data[i].Codmonedafuncional = data[i].MonedaOriginal;
      }

      if (
        data[i].Area >= minValT &&
        data[i].Area <= maxValT &&
        data[i].Precioventafun >= minValP &&
        data[i].Precioventafun <= maxValP &&
        data[i].Descripcionlote.toUpperCase().indexOf(lote) > -1 &&
        data[i].Manzana.toUpperCase().indexOf(manzana) > -1 &&
        data[i].Codestadolote.toUpperCase().indexOf(estado) > -1 &&
        data[i].Bimoneda == bimoneda &&
        data[i].Codmonedafuncional.toUpperCase().indexOf(moneda) > -1
      ) {
        data[i].isVisible = false;
        if (elegido == "todos") {
          data[i].isVisible = true;
          totalLength++;
        } else if (elegido == "si" && data[i].isChecked) {
          data[i].isVisible = true;
          totalLength++;
        } else if (elegido == "no" && !data[i].isChecked) {
          data[i].isVisible = true;
          totalLength++;
        }
      } else {
        data[i].isVisible = false;
      }
    }

    var pageSize = component.get("v.pageSize");
    component.set("v.totalRecordsCount", totalLength);
    component.set("v.startPage", 0);
    component.set("v.endPage", pageSize - 1);

    var PaginationLst = [];
    var dataF = data.filter((element) => element.isVisible);
    for (var i = 0; i < pageSize; i++) {
      if (dataF.length > i) {
        PaginationLst.push(dataF[i]);
      }
    }

    component.set("v.PaginationList", PaginationLst);
    //use Math.ceil() to Round a number upward to its nearest integer
    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
    component.set("v.currentPage", 1);
  },
  autoSeleccionar: function (component) {
    //	codlotes de lotes seleccionados
    var jsonProyecto = component.get("v.jsonProyecto");
    if (
      jsonProyecto &&
      jsonProyecto != null &&
      jsonProyecto != undefined &&
      jsonProyecto != ""
    ) {
      var listaCodLotesSeleccionados = JSON.parse(jsonProyecto);
      component.set("v.selectedCount", listaCodLotesSeleccionados.length);

      var listOfAllAccounts = component.get("v.listOfAllAccounts");
      var filterList = listOfAllAccounts.filter((elemento) =>
        listaCodLotesSeleccionados.includes(elemento.Codlote) ? true : false
      );

      var selectedPrecioTotal = 0;
      for (var i in filterList) {
        filterList[i].isChecked = true;
        selectedPrecioTotal =
          selectedPrecioTotal + filterList[i].Precioventafun;
      }
      component.set("v.selectedPrecioTotal", selectedPrecioTotal);
      component.set("v.listOfAllAccounts", listOfAllAccounts);
    }
  },
  showAlert: function (sms, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "dismissible",
      message: sms,
      type: type
    });
    toastEvent.fire();
  },
  cleanSearch: function(component){
    component.set("v.PaginationList", null);
    component.set("v.selectedCount", 0);
    component.set("v.currentPage", 0);
    component.set("v.totalPagesCount", 0);
    component.set("v.endPage", 0);
    component.set("v.startPage", 0);
    component.set("v.totalRecordsCount", 0);
    component.set("v.selectedPrecioTotal", 0);
    component.set("v.lotesList", null);
    component.set("v.lotesJSON", null);
  }
});