({
  doInit: function (component, event, helper) {
    //	json lotes seleccionados
    var IdProyecto = component.get("v.idProyecto");
    var idProyectoSF = component.get("v.idProyectoSF");
    console.log("IdProyecto: " + IdProyecto);
    console.log("idProyectoSF: " + idProyectoSF);
    var monedaOpp = component.get("v.moneda");
    component.set("v.selectedMoneda", monedaOpp);
    if (idProyectoSF) {
      IdProyecto = idProyectoSF;
    }
    if (IdProyecto != null) {
        
      var action = component.get("c.buscarProyectobyId");
      action.setParams({
        Idproyecto: IdProyecto
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var oRes = response.getReturnValue();
          if (oRes) {
            component.set("v.selectedLookUpRecord", oRes);
            component.set("v.idProyectoSF", oRes.Id);
            component.set("v.idProyecto", oRes.CEN_CODIGOSAP__c);
            helper.doInitHelper(component, event);
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
    // cuando el id oportunidad recibido desde el modalCotizador cambie se ejecuta esto
  onChangeDatosOportunidad: function (component, event, helper) {
    var IdOportunidad = component.get("v.IdOportunidad");
    var esCotizacionLibre = component.get("v.esCotizacionLibre");
    if (!esCotizacionLibre) {
      helper.getDatosProyectoOportunidad(component, IdOportunidad);
    }
  },
  buscarLotes: function (component, event, helper) {
    var proyecto = component.get("v.selectedLookUpRecord");
    var lista = component.get("v.listOfAllAccounts");
    console.log("proyecto data: ");
    console.log(proyecto);
    if (proyecto != null || proyecto != undefined) {
      component.set("v.idProyectoSF", proyecto.Id);
      // if (
      //   lista.length > 0 &&
      //   proyecto.CEN_CODIGOSAP__c == lista[0].Idproyecto
      // ) {
      //   helper.filterData(component);
      // } else {
        component.set("v.idProyecto", proyecto.CEN_CODIGOSAP__c);
        helper.doInitHelper(component, event);
      //}
    } else {
      component.set("v.idProyectoSF", null);
      component.set("v.errorMessage", "Ingrese un proyecto.");
    }
  },
  /* javaScript function for pagination */
  navigation: function (component, event, helper) {
    var sObjectList = component.get("v.listOfAllAccounts");
    var end = component.get("v.endPage");
    console.log(end);
    var start = component.get("v.startPage");
    console.log(start);
    var pageSize = component.get("v.pageSize");
    console.log(pageSize);
    var whichBtn = event.getSource().get("v.name");
    console.log(whichBtn);

    // check if whichBtn value is 'next' then call 'next' helper method
    if (whichBtn == "Next") {
      //console.log("entro");
      //console.log(component.get("v.currentPage"));
      component.set("v.currentPage", component.get("v.currentPage") + 1);
      helper.next(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (whichBtn == "Previous") {
      //console.log(component.get("v.currentPage"));
      component.set("v.currentPage", component.get("v.currentPage") - 1);
      helper.previous(component, event, sObjectList, end, start, pageSize);
    }
  },
  selectAllCheckbox: function (component, event, helper) {
    var selectedHeaderCheck = event.getSource().get("v.value");
    var updatedAllRecords = [];
    var updatedPaginationList = [];
    var listOfAllAccounts = component.get("v.listOfAllAccounts");
    var PaginationList = component.get("v.PaginationList");
    // play a for loop on all records list
    for (var i = 0; i < listOfAllAccounts.length; i++) {
      // check if header checkbox is 'true' then update all checkbox with true and update selected records count
      // else update all records with false and set selectedCount with 0
      if (selectedHeaderCheck == true) {
        listOfAllAccounts[i].isChecked = true;
        component.set("v.selectedCount", listOfAllAccounts.length);
      } else {
        listOfAllAccounts[i].isChecked = false;
        component.set("v.selectedCount", 0);
      }
      updatedAllRecords.push(listOfAllAccounts[i]);
    }
    // update the checkbox for 'PaginationList' based on header checbox
    for (var i = 0; i < PaginationList.length; i++) {
      if (selectedHeaderCheck == true) {
        PaginationList[i].isChecked = true;
      } else {
        PaginationList[i].isChecked = false;
      }
      updatedPaginationList.push(PaginationList[i]);
    }
    component.set("v.listOfAllAccounts", updatedAllRecords);
    component.set("v.PaginationList", updatedPaginationList);
  },
  checkboxSelect: function (component, event, helper) {
    // on each checkbox selection update the selected record count
    var selectedRec = event.getSource().get("v.value");
    var getSelectedNumber = component.get("v.selectedCount");
    if (selectedRec == true) {
      getSelectedNumber++;
    } else {
      getSelectedNumber--;
    }
    if (getSelectedNumber <= 0) {
      getSelectedNumber = 0;
    }
    var allRecords = component.get("v.listOfAllAccounts");
    var filterList = allRecords.filter((elemento) => elemento.isChecked);
    
    component.set("v.lotesList", filterList);
    component.set("v.lotesJSON", JSON.stringify(filterList));
    console.log(filterList);
    
    if (filterList && filterList.length > 0) {
      var selectedPrecioTotal = 0;
      var listaCodLotesSeleccionados = [];

      // Iterar sobre filterList para sumar precios y recolectar códigos
      filterList.forEach(function(item) {
        selectedPrecioTotal += item.Precioventafun || 0; // Sumar precio, usar 0 si no existe
        listaCodLotesSeleccionados.push(item.Codlote);
      });

      // Línea 159: Establecer los valores calculados
      component.set("v.jsonProyecto", JSON.stringify(listaCodLotesSeleccionados));
      component.set("v.selectedPrecioTotal", selectedPrecioTotal);
    } else {
      component.set("v.selectedPrecioTotal", 0);
      component.set("v.lotesJSON", null);
      component.set("v.jsonProyecto", null);
    }

    console.log("SelctNumber:" + getSelectedNumber);
    component.set("v.selectedCount", getSelectedNumber);
	},
  filterDataTable: function (component, event, helper) {
    helper.filterData(component);
  },
  cleanFilters: function (component, event, helper) {
    var minValT, maxValT, minValP, maxValP, lote, manzana, i, data;
    //component.set("v.dataCharged", true);
    data = component.get("v.listOfAllAccounts");
    minValT = component.get("v.sliderTamaniomin");
    maxValT = component.get("v.sliderTamaniomax");
    minValP = component.get("v.sliderPreciomin");
    maxValP = component.get("v.sliderPreciomax");
    component.set("v.selectedValueEstado", "");
    component.set("v.sliderTamanio1Value", minValT);
    component.set("v.sliderTamanio2Value", maxValT);
    component.set("v.sliderPrecio1Value", minValP);
    component.set("v.sliderPrecio2Value", maxValP);
    component.find("lote").set("v.value", null);
    component.find("manzana").set("v.value", null);
    component.set("v.selectedOrdenPor", "LoteASC");
    component.set("v.selectedElegido", "todos");

    helper.filterData(component);
  },
  selectChange: function (component, event, helper) {
    var changeElement = component.find("DivID");
    $A.util.toggleClass(changeElement, "slds-hide");
    if (component.get("v.selectChangeTamanioEnabled") == true) {
      component.set("v.selectChangeTamanioEnabled", false);
      component.set(
        "v.sliderTamanio1Value",
        component.get("v.sliderTamaniomin")
      );
      component.set(
        "v.sliderTamanio2Value",
        component.get("v.sliderTamaniomax")
      );
    } else {
      component.set("v.selectChangeTamanioEnabled", true);
    }
  },
  selectChange2: function (component, event, helper) {
    var changeElement = component.find("DivID2");
    $A.util.toggleClass(changeElement, "slds-hide");
    if (component.get("v.selectChangePrecioEnabled") == true) {
      component.set("v.selectChangePrecioEnabled", false);
      component.set("v.sliderPrecio1Value", component.get("v.sliderPreciomin"));
      component.set("v.sliderPrecio2Value", component.get("v.sliderPreciomax"));
    } else {
      component.set("v.selectChangePrecioEnabled", true);
    }
  },
  bimonedaSelected: function (component, event, helper) {
    var chkBimoneda = component.get("v.selectedBimoneda");
    var strBimoneda = !chkBimoneda ? 'X' : '';
    component.set("v.selectedBimoneda", !chkBimoneda);
    component.set("v.bimoneda", strBimoneda);
    console.log('!chkBimoneda: ' + !chkBimoneda);
    console.log('strBimoneda: ' + strBimoneda);

    
    helper.cleanSearch(component);
  },
  onMoneda: function (component, event, helper) {
    helper.cleanSearch(component);
  }
});