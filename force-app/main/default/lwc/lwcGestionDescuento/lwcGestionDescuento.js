import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcGestionDescuento extends LightningElement {
  isModalOpen = false;
  @api recordId;
  @api listDiscount;
  @api listPalanca;
  @api listMessage;
  @api IdOportunidad;
  @api hasPermission;
  @api hasPermissionAdditional;
  @track jsonPalanca;
  @track jsonDiscount;
  @track jsonMessage;
  @track hasRendered = true;
  overMouse = false;
  @track value;
  @track id;
  @track loaded = false;
  @track groupPalanca;
  @track jsonMerge;
  @track fileRequired = false;
  @track messageRequired = '';
  @track approver;
  @track res = [];
  @track jsonPalancas;

  //Variables para carga de archivos
  @track fileNames = '';
  @track filesUploaded = [];
  @track data;
  @track messageFiles = '';

  showPalancas() {

      let objDiscount = this.listDiscount;
      let objPalanca = this.listPalanca;
      let objMessage = this.listMessage;
      this.jsonPalanca = JSON.parse(objPalanca);
      this.jsonMessage = JSON.parse(objMessage);
      this.jsonDiscount = JSON.parse(objDiscount);

      let mapDiscountAd = this.jsonDiscount.map(el => {
        return {
          COD_PALANCA: el.COD_PALANCA,
          DESC_PALANCA: el.DESC_PALANCA,
          COD_PROMOCION: el.COD_PROMOCION,
          DESC_DESCUENTO: el.DESC_DESCUENTO,
          PORCEN_DESCUENTO: el.PORCEN_MAX_DESCUENTO,
          IMPORTE_DESCUENTO: el.IMPORTE_MAX_DESCUENTO,
          MONEDA: el.MONEDA,
          OBLIGATORIO: null,
          SUSTENTO: null,
          PRIORIDAD: null,
          APLICA: null,
          MOTIVO: null,
          LLAVE: null,
          MARCADO: null,
          QUANTITY: null,
          NIVEL_LIBERACION: el.NIVEL_LIBERACION,
          APROBADOR: el.APROBADOR
        }
      })

      let mapPalanca = this.jsonPalanca.map(el => {
        return {
          COD_PALANCA: el.COD_PALANCA,
          DESC_PALANCA: el.DESC_PALANCA,
          COD_PROMOCION: el.COD_PROMOCION,
          DESC_DESCUENTO: el.DESC_DESCUENTO,
          PORCEN_DESCUENTO: el.PORCEN_DESCUENTO,
          IMPORTE_DESCUENTO: el.IMPORTE_DESCUENTO,
          MONEDA: el.MONEDA,
          OBLIGATORIO: el.OBLIGATORIO,
          SUSTENTO: el.SUSTENTO,
          PRIORIDAD: el.PRIORIDAD,
          APLICA: el.APLICA,
          MOTIVO: el.MOTIVO,
          LLAVE: null,
          MARCADO: null,
          QUANTITY: null,
          NIVEL_LIBERACION: null,
          APROBADOR: null
        }
      })

      mapPalanca = mapDiscountAd.length > 0 ? mapPalanca.concat(mapDiscountAd) : mapPalanca;

      this.jsonMerge = mapPalanca.map((palanca, index, array) => {
        const opciones = array.reduce((acumulador, p, i) => {
          if (p.COD_PALANCA === palanca.COD_PALANCA) {
            acumulador.push({label: p.PORCEN_DESCUENTO + ' % - ' + p.DESC_DESCUENTO, value: i.toString()});
          }
          return acumulador;
        }, []);

        const palancas = array.reduce((acumulador, p, i) => {
          if (p.COD_PALANCA === palanca.COD_PALANCA) {
            acumulador.push({
            id: i.toString(),
            codigo: p.COD_PALANCA,
            importe: p.IMPORTE_DESCUENTO,
            porcentaje: p.PORCEN_DESCUENTO,
            prioridad: p.PRIORIDAD,
            aplica: p.APLICA,
            promocion: p.COD_PROMOCION,
            moneda: p.MONEDA,
            obligatorio: p.OBLIGATORIO,
            sustento: p.SUSTENTO,
            motivo: p.MOTIVO,
            aprobador: p.APROBADOR
          });
          }
          return acumulador;
        }, []);

        return {
          codigo: palanca.COD_PALANCA,
          description: palanca.DESC_PALANCA,
          options: opciones,
          palancas: palancas,
          promocion: '',
          porcentaje: '',
          moneda: palanca.MONEDA,
          importe: '0.0',
          ischecked: false,
          selectedValue: '',
          active: true, //Checkbox disabled
          activeDiscount: false, //Combobox disabled
          motivo: '',
          motivoArray: [],
          show: false,
          required: false,
          aprobador: ''
        };

      })
      .reduce((acc, palanca) => {
          if (!acc.some(p => p.codigo === palanca.codigo)) {
            acc.push(palanca);
          }
          return acc;
      }, []);

      console.log('this.hasPermission: ' + this.hasPermission);
      console.log('this.hasPermissionAdditional: ' + this.hasPermissionAdditional);
      this.jsonMerge = !this.hasPermissionAdditional ? this.jsonMerge.filter(palanca => palanca.description.toUpperCase() !== 'ADICIONAL') : this.jsonMerge;

      this.groupPalanca = this.jsonMerge;
      this.priorityPalanca();

  }

  //--------------------------------------------------------------

  //PopUp Informativa
  handleMouse(e) {
    let id = e.currentTarget.dataset.id;
    for(const element of this.groupPalanca) {
      for(let j=0; j< element.options.length; j++) {
        if(element.palancas[j].id === id && !element.active && element.motivoArray.length > 0){
          element.show = element.show ? false : true;
        }
      }
    }
  }

  //Seleccion de descuento
  handleChange(event) {
    this.value = event.detail.value;
    for(const element of this.groupPalanca) {
      for(let j=0; j< element.options.length; j++) {
        if(element.palancas[j].id === this.value){
          element.selectedValue = element.palancas[j].id.toString();
          element.importe = element.palancas[j].importe;
          element.promocion = element.palancas[j].promocion;
          element.moneda = element.palancas[j].moneda;
          element.porcentaje = element.palancas[j].porcentaje;
          element.show = element.motivoArray.length === 0 ? false : true;
          element.active = false;
          element.required = element.palancas[j].sustento === 'SI' ? true : false;
          element.motivo = element.palancas[j].motivo;
          this.approver = element.palancas[j].aprobador;
        }
      }
    }
    this.fileRequired = this.groupPalanca.filter((elemento) => elemento.required).length > 0 ? true : false;
    this.messageRequired = this.groupPalanca.filter((elemento) => elemento.required).length > 0 ? 'Porfavor adjuntar archivo' : '';
  }

  //Carga los descuentos por prioridad
  priorityPalanca(){
    for(const element of this.groupPalanca) {
      for(let j=0; j< element.options.length; j++) {
        if(element.palancas[j].prioridad === 'X'){
          element.selectedValue = element.palancas[j].id.toString();
          element.importe = element.palancas[j].importe;
          element.promocion = element.palancas[j].promocion;
          element.moneda = element.palancas[j].moneda;
          element.porcentaje = element.palancas[j].porcentaje;
          element.active = false;
          element.required = element.palancas[j].sustento === 'SI' ? true : false;
          this.approver = element.palancas[j].aprobador;
          element.activeDiscount = true;
        }
        if(element.palancas[j].motivo != null){
        element.motivoArray.push(element.palancas[j].motivo); //Muestra todos los motivos de la palanca
        }
      }
    }

    this.fileRequired = this.groupPalanca.filter((elemento) => elemento.required).length > 0 ? true : false;
    this.messageRequired = this.groupPalanca.filter((elemento) => elemento.required).length > 0 ? 'Porfavor adjuntar archivo' : '';
  }

  //Seleccionar palancas para el financiamiento
  handleChangeChecked(event) {
    let id = event.target.value;
    for(const element of this.groupPalanca) {
      for(let j=0; j< element.options.length; j++) {
        if(element.palancas[j].id === id){
          element.ischecked = element.ischecked ? false : true;
        }
      }
    }
  }

  //Aplicar Descuento y guardarlo en la opp
  applyDiscount(e){
    this.loaded = !this.loaded;
    let dsctosSeleccionados = this.groupPalanca.filter((elemento) => elemento.ischecked);
    let required = this.groupPalanca.filter((elemento) => elemento.ischecked && elemento.required).length > 0 ? true : false;
    let aprobador = this.groupPalanca.filter((elemento) => elemento.description.toUpperCase() === 'ADICIONAL' || elemento.description.toUpperCase() === 'ESPECIAL').length > 0 ? true : false;
    const especial = this.groupPalanca.find((item) => {
      return item.description === 'ESPECIAL' && item.ischecked;
    });

    const adicional = this.groupPalanca.find((item) => {
      return item.description.toUpperCase() === 'ADICIONAL' && item.ischecked;
    });

    const importeEspecial = especial != undefined ? especial.importe : 0.00;
    const porcentajeEspecial = especial != undefined ? especial.porcentaje : 0.00;;
    const importeAdicional = adicional != undefined ? adicional.importe : 0.00;;
    const porcentajeAdicional = adicional != undefined ? adicional.porcentaje : 0.00;;

    const levers = dsctosSeleccionados.map(el => {
      return {
        codigo: el.codigo,
        promocion: el.promocion,
        porcentaje: el.porcentaje,
        importe: el.importe,
        moneda: el.moneda,
        descripcionPalanca: el.description,
        aprobador: aprobador
      }
    });
    console.log(dsctosSeleccionados);
    console.log(this.jsonMessage);
    console.log(this.jsonMessage.length);
    if(dsctosSeleccionados.length !== 0){
      let limitPerDscto;
      let limitTotDscto;
      if(this.jsonMessage.length > 0){
        let dsctosMessage = this.jsonMessage.filter((elemento) => elemento.COD_MENSAJE === 'MAX01');
        limitPerDscto = parseFloat(dsctosMessage[0].PORCEN_DESCUENTO);
        limitTotDscto = parseFloat(dsctosMessage[0].IMPORTE_DESCUENTO);
      }else{
        this.showMessageToast('Notificación','No se ha configurado en SAP el límite máximo de descuento. Consultar con el administrador','error');
        this.loaded = !this.loaded;
      }
      let totalDiscount = levers.reduce((sum, value) => parseFloat(sum) + parseFloat(value.importe), 0);
      let totalPercentage = levers.reduce((sum, value) => parseFloat(sum) + parseFloat(value.porcentaje), 0);

      let validateTotalDiscount = levers.reduce((sum, value) => {
        if (value.descripcionPalanca.toUpperCase() !== 'ADICIONAL') {
          return parseFloat(sum) + parseFloat(value.importe);
        } else {
          return parseFloat(sum);
        }
      }, 0);

      let validateTotalPercent = levers.reduce((sum, value) => {
        if (value.descripcionPalanca.toUpperCase() !== 'ADICIONAL') {
          return parseFloat(sum) + parseFloat(value.porcentaje);
        } else {
          return parseFloat(sum);
        }
      }, 0);

      let motivoInformativa = especial != undefined ? especial.motivo : '';
      const criteria = {
        importeEspecial,
        importeAdicional,
        porcentajeEspecial,
        porcentajeAdicional,
        motivoInformativa
      };

      const newArray = [
        { levers: levers },
        { criteria: criteria }
      ];

      console.log('validateTotalDiscount:' + validateTotalDiscount);
      console.log('validateTotalPercent:' + validateTotalPercent);
      console.log('limitTotDscto:' + limitTotDscto);
      //if(this.jsonMessage.length > 0 && validateTotalDiscount > limitTotDscto){
      if(this.jsonMessage.length > 0 && validateTotalPercent > limitPerDscto){
        this.showMessageToast('Notificación','Total de descuentos superan el límite de ' + limitPerDscto + '%','error');
        this.loaded = !this.loaded;
      }else if(this.jsonMessage.length > 0 && required && !this.fileNames){
        this.showMessageToast('Notificación','Se requiere adjuntar un archivo','error');
        this.loaded = !this.loaded;
      }else if(this.jsonMessage.length > 0){
        //PASS VALUE FROM CHILD TO PARENT - INICIO
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { jsonPalancas: JSON.stringify(newArray), totalDiscount, totalPercentage, filesUploaded : this.filesUploaded}
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        //PASS VALUE FROM CHILD TO PARENT - FIN
        this.showMessageToast('Notificación','Se aplicaron los descuentos','success');

        this.isModalOpen = false;
        this.loaded = !this.loaded;
        //CARGA DE ARCHIVOS - FIN
      }
    }else{
      this.showMessageToast('Notificación','No ha seleccionado descuentos a aplicar','warning');
      this.loaded = !this.loaded;
    }
  }

  //Cargar archivos
  handleFileChanges(event) {
    let files = event.target.files;

    if (files.length > 0) {
        let filesName = '';

        for (const element of files) {
            let file = element;

            filesName = filesName + file.name + ',';

            let freader = new FileReader();
            freader.onload = f => {
                let base64 = 'base64,';
                let content = freader.result.indexOf(base64) + base64.length;
                let fileContents = freader.result.substring(content);
                this.filesUploaded.push({
                    Title: file.name,
                    VersionData: fileContents
                });
            };
            freader.readAsDataURL(file);
        }

        this.messageFiles = `archivos cargados con éxito!!`;
        this.fileNames = filesName.slice(0, -1);
        console.log(this.fileNames);
    }
  }

  get acceptedFormats() {
    return ['.pdf', '.png', '.zip'];
  }

  //Mensaje de notificación
  showMessageToast(strTitle,strMessage,strType) {
    const evt = new ShowToastEvent({
        title: strTitle,
        message: strMessage,
        variant: strType,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }

  //Abrir modal
  @api
  openModal() {
    this.isModalOpen = true;
    this.showPalancas();
  }

  //Cerrar modal
  @api
  closeModal() {
    this.isModalOpen = false;
  }

}