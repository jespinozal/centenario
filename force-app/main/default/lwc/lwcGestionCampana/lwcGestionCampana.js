import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCampanaList from "@salesforce/apex/CEN_Campana_ctr.getCampanaList";

const myAlignment = "center";

const columns = [
  {
    label: "COD_CAMPANA",
    fieldName: "COD_CAMPANA",
    type: "text",
    sortable: true
  },
  {
    label: "NOM_CAMPANA",
    fieldName: "NOM_CAMPANA",
    type: "text",
    wrapText: true
  },
  {
    label: "NIVEL",
    fieldName: "NIVEL",
    type: "text",
    sortable: true,
    // initialWidth: 80,
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "MOTIVO_CAMPANA",
    fieldName: "MOTIVO_CAMPANA",
    type: "text",
    wrapText: true
  },
  {
    label: "PALANCA_PRINCIPAL",
    fieldName: "PALANCA_PRINCIPAL",
    type: "text",
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "INICIO_VIGENCIA",
    fieldName: "INICIO_VIGENCIA",
    type: "date-local",
    sortable: true,
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    },
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "FIN_VIGENCIA",
    fieldName: "FIN_VIGENCIA",
    // type: "text",
    type: "date-local",
    sortable: true,
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    },
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "% DESCUENTO",
    fieldName: "PORCENTAJE_DESCUENTO",
    // type: "text",
    type: "percent",
    typeAttributes: {
      minimumFractionDigits: "2"
    },
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "IMPORTE",
    fieldName: "IMPORTE",
    type: "text",
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "MONEDA",
    fieldName: "MONEDA",
    type: "text",
    cellAttributes: { alignment: myAlignment }
  },
  {
    label: "SUSTENTO",
    fieldName: "SUSTENTO",
    type: "text",
    cellAttributes: { alignment: myAlignment }
  }
];

export default class LwcGestionCampana extends LightningElement {
  // variable para spinner
  loaded = false;

  selectedProyect = "";
  valueCurrency = "";
  valueSupport = "";
  valueCampaign = "";
  valueLever = "";
  valueStartDate = "";
  valueEndDate = "";
  campanaList = "";
  data = [];
  columns = columns;
  // variables paginador
  items = [];
  page = 1;
  totalRecountCount = 0;
  pageSize = 5;
  totalPage = 1;
  startingRecord = 1;
  endingRecord = 0;
  // ------
  // variables de Filtros
  dataFiltrada = [];
  isPageChanged = false;
  isDataChanged = false;
  // variables de ordenamiento
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    console.log("entro");
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  processRecords(data) {
    this.items = data;
    this.page = 1;
    this.totalRecountCount = data.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

    this.data = this.items.slice(0, this.pageSize);
    this.endingRecord = this.pageSize;
    this.columns = columns;

    console.log("this.items: ", this.items);
    console.log("this.page: ", this.page);
    console.log("this.totalRecountCount: ", this.totalRecountCount);
    console.log("this.totalPage: ", this.totalPage);
    console.log("this.data slice: ", this.data);
    console.log("this.endingRecord: ", this.endingRecord);
  }

  previousHandler() {
    this.isPageChanged = true;
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //clicking on next button this method will be called
  nextHandler() {
    this.isPageChanged = true;

    console.log("this.page" + this.page);

    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //this method displays records page by page
  displayRecordPerPage(page) {
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;
  }

  // --------------------------------------------------------------------------

  handleSearch() {
    this.loaded = true;
    console.log(this.selectedProyect);
    if (this.selectedProyect === "") {
      this.showErrorToast();
      return;
    }
    this.camapanaList = getCampanaList({ oppId: this.selectedProyect })
      .then((resp) => {
        this.loaded = false;
        this.data = resp.strCampanaList;
        this.dataFiltrada = this.data;

        console.log("resp.strCampanaList");
        console.log(resp.strCampanaList);
        console.log("this.valueCampaign: ", this.valueCampaign);
        console.log("this.valueLever: ", this.valueLever);
        console.log("this.valueStartDate: ", this.valueStartDate);
        console.log("this.valueEndDate: ", this.valueEndDate);
        console.log("this.dataFiltrada: ");
        console.log(this.dataFiltrada);

        // aplica los filtros a dataFiltrada
        this.applyFilters();

        this.processRecords(this.dataFiltrada);
      })
      .catch((error) => {
        this.loaded = false;
        this.showInternalErrorToast();
        console.log(error.message);
      });
  }

  handleReset() {
    this.loaded = true;
    this.valueCurrency = "";
    this.valueSupport = "";
    this.valueCampaign = "";
    this.valueLever = "";
    this.valueStartDate = "";
    this.valueEndDate = "";
    this.camapanaList = getCampanaList({ oppId: this.selectedProyect }).then(
      (resp) => {
        this.loaded = false;
        this.data = resp.strCampanaList;
        this.processRecords(this.data);
      }
    );
  }

  applyFilters() {
    // filtrar por campaña
    if (this.valueCampaign !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.COD_CAMPANA === this.valueCampaign;
      });
    }

    // filtrar por palanca
    if (this.valueLever !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.PALANCA_PRINCIPAL === this.valueLever;
      });
    }

    // filtrar por fecha inicio
    if (this.valueStartDate !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.INICIO_VIGENCIA >= this.valueStartDate;
      });
    }

    // filtrar por fecha fin
    if (this.valueEndDate !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.FIN_VIGENCIA <= this.valueEndDate;
      });
    }

    // filtrar por Moneda
    if (this.valueCurrency !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.MONEDA === this.valueCurrency;
      });
    }
    // filtrar por Sustento
    if (this.valueSupport !== "") {
      this.dataFiltrada = this.dataFiltrada.filter((item) => {
        return item.SUSTENTO === this.valueSupport;
      });
    }
  }

  handleProjectSelection(event) {
    this.selectedProyect = event.target.value;
    console.log("proyecto: " + this.selectedProyect);
  }

  get optionsCurrency() {
    return [
      { label: "--Seleccionar--", value: "" },
      { label: "Dólares", value: "USD" },
      { label: "Soles", value: "PEN" }
    ];
  }

  handleCurrencySelection(event) {
    this.valueCurrency = event.target.value;
    this.isDataChanged = true;
  }

  get optionsSupport() {
    return [
      { label: "--Seleccionar--", value: "" },
      { label: "Si", value: "SI" },
      { label: "No", value: "NO" }
    ];
  }

  handleSupportSelection(event) {
    this.valueSupport = event.target.value;
    this.isDataChanged = true;
  }

  handleCampaignSelection(event) {
    this.valueCampaign = event.target.value;
    this.isDataChanged = true;
  }

  handleLeverSelection(event) {
    this.valueLever = event.target.value;
    this.isDataChanged = true;
  }

  handleStartDateSelection(event) {
    this.valueStartDate = event.target.value;
    this.isDataChanged = true;
  }

  handleEndDateSelection(event) {
    this.valueEndDate = event.target.value;
    this.isDataChanged = true;
  }

  showErrorToast() {
    const evt = new ShowToastEvent({
      title: "El campo Proyecto es obligatorio",
      message: "Por favor seleccione un Proyecto",
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(evt);
  }

  showInternalErrorToast() {
    const evt = new ShowToastEvent({
      title: "Error interno",
      message: "Parece que hay un error al consultar el proyecto",
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(evt);
  }
}