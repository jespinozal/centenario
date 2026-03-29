import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSimulacionPrepago from "@salesforce/apex/CEN_SimulacionPrepago.getSimulacionPrepago";
// import getSimulacionPDF from "@salesforce/apex/CEN_SimulacionPrepago.getSimulacionPDF";
import getCuotasRestantes from "@salesforce/apex/CEN_SimulacionPrepago.getCuotasRestantes";
import CEN_lbl_idOportunidadGenerica from "@salesforce/label/c.CEN_lbl_idOportunidadGenerica";

// eslint-disable-next-line @lwc/lwc/no-leading-uppercase-api-name
export default class LwcSimuladorPrepago extends LightningElement {
  isModalOpen = false;
  @api recordId;
  @api IdOportunidad;
  @api numCuotas;
  @api fecCuotaSaldoFin;
  @api fecCuotaSaldoIni;
  @api monotocuotafinan;

  connectedCallback() {
    this.totalDeCuotasSaldo = this.numCuotas;
    // console.log('fechaUltimaCuotaSaldo1', this.fechaUltimaCuotaSaldo, '- -', this.fecCuotaSaldoFin);
    // this.fechaUltimaCuotaSaldo = this.fecCuotaSaldoFin;
    // console.log('fechaUltimaCuotaSaldo2', this.fechaUltimaCuotaSaldo, '- -', this.fecCuotaSaldoFin);
    // this.fechaPrimeraCuotaSaldo = this.fecCuotaSaldoIni;
  }

  oppMapper(data) {
    if (data) {
      if (!this.numCuotas) {
        this.totalDeCuotasSaldo =
          data.fields.CEN_N_Cuotas_del_Saldo_del_precio__c.value;
      } else {
        this.totalDeCuotasSaldo = this.numCuotas;
        this.fechaPrimeraCuotaSaldo = this.fecCuotaSaldoIni;
      }

      // console.log(
      //   "fecha del sObject mes",
      //   // data.fields.CEN_MaximumFlowDate__c.value.getMonth()
      // );
    }
  }

  validaNuevaOportunidad() {
    console.log("IdOportunidad antes de validarla -->", this.IdOportunidad);
    if (this.recordId) {
      if (this.recordId !== CEN_lbl_idOportunidadGenerica) {
        this.isModalOpen = true;
        this.IdOportunidad = this.recordId;
      }
    }
  }

  @api
  openModal() {
    this.isModalOpen = true;
  }
  @api
  closeModal() {
    this.isModalOpen = false;
  }

  // Toast para mostrar campos obligatorios
  _title = "Complete los campos requeridos";
  message = "Completar los campos marcados con un asterisco (*)";
  variant = "error";
  variantOptions = [
    { label: "error", value: "error" },
    { label: "warning", value: "warning" },
    { label: "success", value: "success" },
    { label: "info", value: "info" }
  ];

  // #region Definiciones

  _data;
  _resp;
  negrita;
  mostrarDiferenciaDeCuotas = false;
  cuotaMantenida = false;
  cuotaFacilote = "0";
  cuotasInicialRestantes = "0";
  cuotaSaldoAnteriorAPrepago = this.monotocuotafinan;
  cuotaSaldoPosteriorAPrepago = "0";
  saldoNroCuotasPrepago = "";
  ultimaCuotaSaldo = "0";
  ahorro = "";
  hacerObligatorio = true;
  cuotaInicNoCuotas = "1-8";
  cuotasRestantes = `Cuotas Inicial ${this.cuotaInicNoCuotas}`;
  totalDeCuotasSaldo;
  fechaUltimaCuotaSaldo;
  fechaPrimeraCuotaSaldo;
  divisa = "";
  errorMessage = "";
  showSpinner = false;
  nroProforma = "";
  tipoDeInput = "number";
  nroCuotasFinanciamientoInicial = 0;
  nroCuotasNuevoFinanciamiento = 0;
  reduccionDeCuotas = 0;
  rebajaDeIntereses = 0;
  montoReducidoDeLaCuota = 0;

  montoPrepago = "";
  fechaPrepago = "";
  // IdOportunidad = this.recordId;
  camposRequestPrepago = {};
  // console.log('recorddId -->', IdOportunidad);

  // HARDCODEO DE DATA ENVIADA DESDE EL AURA COMPONENT
  filaItem = {
    processo: "19U1.903E",
    monedaDescuento: "PEN",
    indEliminarProd: "",
    descuentoOPS: "0",
    codPropiedad: "00000053",
    bukrs: "0019"
  };
  crearProformaItem = {
    zonaVenta: "ZV001",
    viaFinanciamiento: "CD",
    supervVenta: "jespilud@nttdata.com",
    supervAsignado: "jespilud@nttdata.com",
    stcd1: "45558712",
    saldoNoCuotas: "60",
    promotor: "",
    processo: "19U1.903E",
    motivoCompra: "I",
    monedaProforma: "PEN",
    medio: "8",
    interesesCI: "SI",
    indImpCuotaLibre: "",
    indFinanCI: "X",
    importeOCD: "3750",
    importeCIChar: "40000",
    impCuotaLibreInicial: "",
    faciloteIndCI: "",
    diasPago: "1",
    cuotaInicNoCuotas: "13",
    conversionArras: "NO",
    bukrs: "0019",
    apoderadoCentenario2: "2",
    apoderadoCentenario1: "2",
    noCuotasTotSi: "0"
  };

  // resp = {
  //   cuotaFacilote: "No Aplica",
  //   cuotasInicialRestantes: "5345.39",
  //   cuotaSaldoAnteriorAPrepago: "2882.32",
  //   cuotaSaldoPosteriorAPrepago: "2882.32",
  //   ultimaCuotaSaldo: "1454.65",
  //   divisa: "PEN",
  //   ahorro: "27545.32",
  //   cuotaInicNoCuotas: "3-13",
  //   cuotasRestantes: "Cuotas Inicial 1-13",
  //   nroProforma: "Sin Proforma"
  // };
  // IdOportunidad = "006R000000axECZIA2";

  // #endregion

  value = "inProgress";

  get options() {
    return [
      { label: "Reducir Tiempo de Financiamiento", value: "reducirTiempo" },
      { label: "Disminuir Valor de Cuota", value: "disminuirCuota" }
    ];
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: this._title,
      message: this.message,
      variant: this.variant
    });
    this.dispatchEvent(evt);
  }

  handleChange(event) {
    // this.cuotaInicNoCuotas = `1-${this._data.fields.CEN_N_Cuotas_de_inicial_de_precio__c.value}`;
    // this.cuotasRestantes = `Cuotas Inicial ${this.cuotaInicNoCuotas}`;
    // console.log("entre al click");
    this.value = event.detail.value;
    if (this.value === "reducirTiempo") {
      this.cuotaMantenida = true;
      this.saldoNroCuotasPrepago = "";
      this.hacerObligatorio = false;
      this.negrita = "";
      this.fechaPrepago = "";
      this.mostrarDiferenciaDeCuotas = false;
    } else {
      this.cuotaMantenida = false;
      this.hacerObligatorio = true;
      this.negrita = "font-weight: bold; -webkit-text-fill-color: black";
      this.fechaPrepago = "";
      this.mostrarDiferenciaDeCuotas = true;
    }
  }

  handleInputChange(event) {
    if (event.target.dataset.type === "Monto_Prepago") {
      this.montoPrepago = event.target.value;
    } else if (event.target.dataset.type === "Saldo_Nro_Cuotas") {
      this.saldoNroCuotasPrepago = event.target.value;
    } else if (event.target.dataset.type === "Fecha_Prepago") {
      this.fechaPrepago = event.target.value;
      if (this.cuotaMantenida === false) {
        getCuotasRestantes({ fechaPrepago: this.fechaPrepago, fechaUltimaCuotaSaldo: this.fecCuotaSaldoFin })
          .then((resp) => {
            this.saldoNroCuotasPrepago = resp;
        })
      }
    }
  }

  // abrirPDF() {
  //   getSimulacionPDF({
  //     valoresSimulacion: {
  //       ...this._resp,
  //       ...this.camposRequestPrepago,
  //       ...this.reduccionDeCuotas
  //     },
  //     oppId: this.IdOportunidad
  //   }).then(() => {
  //     //  open pdf visualforce
  //     window.open(
  //       // planillaPDFsimuladorEndpoint + '?=' + this.IdOportunidad
  //       "https://centenario--deveveris8--c.visualforce.com/apex/CEN_vf_pdfPlantillaSimulacion?id=" +
  //         this.IdOportunidad +
  //         "&ahorro=" +
  //         this.ahorro +
  //         "&cuotaFacilote=" +
  //         this.cuotaFacilote +
  //         "&cuotasInicialRestantes=" +
  //         this.cuotasInicialRestantes +
  //         "&cuotaSaldoAnteriorAPrepago=" +
  //         this.cuotaSaldoAnteriorAPrepago +
  //         "&cuotaSaldoPosteriorAPrepago=" +
  //         this.cuotaSaldoPosteriorAPrepago +
  //         "&ultimaCuotaSaldo=" +
  //         this.ultimaCuotaSaldo +
  //         "&divisa=" +
  //         this.divisa +
  //         "&cuotaInicNoCuotas=" +
  //         this.cuotaInicNoCuotas +
  //         "&nroProforma=" +
  //         this.nroProforma +
  //         "&disminuirCuota=" +
  //         this.camposRequestPrepago.disminuirCuota +
  //         "&fecha=" +
  //         this.camposRequestPrepago.fecha +
  //         "&monto=" +
  //         this.camposRequestPrepago.monto +
  //         "&saldoNroCuotas=" +
  //         this.camposRequestPrepago.saldoNroCuotas +
  //         "&reduccionDeCuotas=" +
  //         this.reduccionDeCuotas
  //     );

  //     console.log("IdOportunidad  ->", this.IdOportunidad);
  //   });
  // }

  consultaPrepago() {
    this.errorMessage = "";
    if (this.IdOportunidad == null) {
      this.IdOportunidad = this.recordId;
    }
    console.log("numCuotas-->", this.numCuotas);
    console.log("fecCuotaSaldoIni-->", this.fecCuotaSaldoIni);
    //presionar boton
    // Capturando la información del formulario y llenando los campos del objeto
    this.showSpinner = true;
    if (
      (this.montoPrepago !== "" &&
        this.fechaPrepago !== "" &&
        this.fechaPrepago !== null &&
        this.cuotaMantenida === true) ||
      (this.cuotaMantenida === false &&
        this.montoPrepago !== "" &&
        this.fechaPrepago !== "" &&
        this.fechaPrepago !== null &&
        this.saldoNroCuotasPrepago !== "")
    ) {
      console.log("pase las validaciones");
      if (this.cuotaMantenida === true) {
        this.camposRequestPrepago.reducirTiempo = "X";
        this.camposRequestPrepago.disminuirCuota = "";
        this.saldoNroCuotasPrepago = "";
      } else {
        this.camposRequestPrepago.disminuirCuota = "X";
        this.camposRequestPrepago.reducirTiempo = "";
      }

      this.camposRequestPrepago.monto = this.montoPrepago;
      this.camposRequestPrepago.saldoNroCuotas = this.saldoNroCuotasPrepago;
      this.camposRequestPrepago.fecha = this.fechaPrepago;
      console.log("Campos:");
      console.log(this.camposRequestPrepago); // revisar que se llenaron los campos con la info correcta
      console.log(this.resp);

      getSimulacionPrepago({
        prepagoCampos: this.camposRequestPrepago,
        oppId: this.IdOportunidad,
        isSimulation: true,
      })
        .then((resp) => {
          // llenando lo campos calculados en el simulador
          this._resp = resp;
          console.log('resp -->');
          console.log(resp);
          if (resp.errorMessage) {
            this.errorMessage = "Error SAP: " + resp.errorMessage;
          } else {
            if (resp.cuotaFacilote === "No aplica") this.tipoDeInput = "text";
            else this.tipoDeInput = "number";
            this.cuotaFacilote = resp.cuotaFacilote;
            this.cuotasInicialRestantes = resp.cuotasInicialRestantes;
            // this.cuotaSaldoAnteriorAPrepago = resp.cuotaSaldoAnteriorAPrepago;
            this.cuotaSaldoPosteriorAPrepago = resp.cuotaSaldoPosteriorAPrepago;
            this.montoReducidoDeLaCuota = this.monotocuotafinan - this.cuotaSaldoPosteriorAPrepago;
            this.divisa = resp.divisa;
            this.ahorro = resp.ahorro;
            this.ultimaCuotaSaldo = resp.ultimaCuotaSaldo;
            this.cuotaInicNoCuotas = resp.cuotaInicNoCuotas;
            this.cuotasRestantes = `Cuotas Inicial ${this.cuotaInicNoCuotas}`;
            if (resp.nroProforma === "0000000000")
              this.nroProforma = "Sin Proforma";
            else this.nroProforma = resp.nroProforma;
            this.fechaUltimaCuotaSaldo = resp.fechaUltimaCuotaSaldo;
            this.nroCuotasNuevoFinanciamiento =
              resp.nroCuotasNuevoFinanciamiento;
            this.nroCuotasFinanciamientoInicial =
              resp.nroCuotasFinanciamientoInicial;
            this.nroCuotasNuevoFinanciamiento =
              resp.nroCuotasNuevoFinanciamiento;
            this.reduccionDeCuotas =
              this.nroCuotasFinanciamientoInicial -
              this.nroCuotasNuevoFinanciamiento;
            this.rebajaDeIntereses = this.ahorro;
          }
        })
        .finally(() => {
          this.showSpinner = false;
        });
    } else {
      console.log("llena los campos saldo y fecha");
      this.showSpinner = false;
      this.showNotification();
    }
  }
}