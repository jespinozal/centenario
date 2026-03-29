import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBatchList from '@salesforce/apex/CEN_FinanceBulkDeliveryDate_ctr.getBatchList';
import updateDeliveryDate from '@salesforce/apex/CEN_FinanceBulkDeliveryDate_ctr.updateDeliveryDate';
import getBatchPagination from '@salesforce/apex/CEN_FinanceBulkDeliveryDate_ctr.getBatchPagination';
import getProjectData from '@salesforce/apex/CEN_FinanceBulkDeliveryDate_ctr.getProjectData';
import { refreshApex } from '@salesforce/apex';

export default class WcCEN_FinanceBulkDeliveryDate extends LightningElement {

  data = [];
  pageNumber = 1;
  pageSize = 10;
  isLastPage = true;
  resultSize = 0;
  codSAP = '';
  selection = [];
  hasPageChanged;
  error;
  selectedProj;
  datos = [];
  sizeData = 0;
  totalRecord = 0;
  projectName;
  @track loaded = false;
  @track hasRendered = true;
  @track isModalChargeOpen = false;
  @track deliverDate = '';

  @api searchKey = '';
  resultSearch = [];

  columns = [
      // { label: 'Id', fieldName: 'Id', type: 'text' },
      { label: 'Descripción', fieldName: 'Descripcionlote', type: 'text' },
      { label: 'Estado', fieldName: 'Desestadolote', type: 'text' },
      // { label: 'Fecha Entrega', fieldName: 'Fecentrega', type: 'text' },
      { label: 'Manzana', fieldName: 'Manzana', type: 'text' },
      { label: 'Lote', fieldName: 'Numeroletra', type: 'text' },
      { label: 'Proforma', fieldName: 'Proforma', type: 'text' },
  ];

  renderedCallback() {
    if (this.hasRendered) {
      this.loaded = !this.loaded;
      this.hasRendered = false;
    }
  }

  // connectedCallback() {
  // }
  
  rowSelection(evt) {
    // List of selected items from the data table event.
    let updatedItemsSet = new Set();
    // List of selected items we maintain.
    let selectedItemsSet = new Set(this.selection);
    // List of items currently loaded for the current view.
    let loadedItemsSet = new Set();


    this.data.map((event) => {
        loadedItemsSet.add(event.Id);
    });


    if (evt.detail.selectedRows) {
        evt.detail.selectedRows.map((event) => {
            updatedItemsSet.add(event.Id);
        });


        // Add any new items to the selection list
        updatedItemsSet.forEach((id) => {
            if (!selectedItemsSet.has(id)) {
                selectedItemsSet.add(id);
            }
        });        
    }


    loadedItemsSet.forEach((id) => {
        if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
            // Remove any items that were unselected.
            selectedItemsSet.delete(id);
        }
    });


    this.selection = [...selectedItemsSet];
    
  }

  previousEve() {
    //Setting current page number
    let pageNumber = this.pageNumber;
    this.pageNumber = pageNumber - 1;
    //Setting pageChange variable to true
    this.hasPageChanged = true;
    
    if(this.resultSearch.length > 0){
      this.getBatchPag(this.resultSearch);
    }else{
      this.getBatchPag(this.datos);
    }
  }

  nextEve() {
    //get current page number
    let pageNumber = this.pageNumber;
    //Setting current page number
    this.pageNumber = pageNumber + 1;
    //Setting pageChange variable to true
    this.hasPageChanged = true;
    
    if(this.resultSearch.length > 0){
      this.getBatchPag(this.resultSearch);
    }else{
      this.getBatchPag(this.datos);
    }
  }

  get recordCount() {
    return (
      ((this.pageNumber - 1) * this.pageSize) + 1 +
      " - " +
      ((this.pageNumber - 1) * this.pageSize + this.resultSize)
    );
  }

  get disPre() {
    return this.pageNumber === 1 ? true : false;
  }

  handleProjectSelection(event){
    this.selectedProj = event.target.value;
    this.data = [];
    this.totalRecord = 0;
    this.resultSize = 0;
    this.codSAP = '';
    this.datos = [];
    this.searchKey = '';
    this.resultSearch = '';
    this.getProjectData();
    this.getBatch();
  }

  getProjectData(){
    getProjectData({
      Idproyecto: this.selectedProj
    })
    .then(resp => {
      this.projectName = resp;
    })
    .catch((error) => {
      //this.loaded = !this.loaded;
      this.error = error;
    });
  }

  async getBatch(){

    this.loaded = false;

    await getBatchList({
      Idproyecto: this.selectedProj
    }).then(result => {
      this.loaded = true;
      this.datos = result;
      this.sizeData = result.length;
      if(result.length > 0){
        getBatchPagination({
          mapResp: this.datos,
          pageSize: this.pageSize,
          pageNumber: this.pageNumber
        })
        .then(resp => {
            this.loaded = true;
            let accountData = JSON.parse(JSON.stringify(resp.batchList));
            this.data = accountData;
            this.resultSize = accountData.length;
            this.totalRecord = resp.totalRegistros;
            this.template.querySelector(
                '[data-id="datarow"]'
              ).selectedRows = this.selection;

            let cant = ((this.pageNumber - 1) * this.pageSize + this.resultSize);
            if (cant < this.totalRecord) {
              this.isLastPage = false;
            } else {
              this.isLastPage = true;
            }  
        })
        .catch((error) => {
          this.loaded = !this.loaded;
          this.error = error;
        });

      } else {
        this.loaded = true;
        this.showMessageToast('Mensaje', 'No existen lotes con estado Entregado para el proyecto: ' + this.projectName,'warning');
      }

    })
    .catch((error) => {
      this.loaded = !this.loaded;
      this.error = error;
    });  

  }

  async getBatchPag(lotes){
    this.loaded = !this.loaded;
    await getBatchPagination({
      mapResp: lotes,
      pageSize: this.pageSize,
      pageNumber: this.pageNumber
    })
    .then(resp => {
        this.loaded = !this.loaded;
        let accountData = JSON.parse(JSON.stringify(resp.batchList));
        this.data = accountData;
        this.resultSize = accountData.length;
        this.totalRecord = resp.totalRegistros;
        this.codSAP = resp.CodigoSAP;
        this.template.querySelector(
            '[data-id="datarow"]'
          ).selectedRows = this.selection;
        
        let cant = ((this.pageNumber - 1) * this.pageSize + this.resultSize);
        if (cant < this.totalRecord) {
          this.isLastPage = false;
        } else {
          this.isLastPage = true;
        }
    })
    .catch((error) => {
      this.loaded = !this.loaded;
      this.error = error;
    });  
  }

  viewModalCharge(e){
    this.isModalChargeOpen = true;
    var newDate = new Date();
    this.deliverDate = newDate.toISOString().substring(0, 10);

    console.log(this.selection);
  }

  closeModalCharge(e){
    this.isModalChargeOpen = false;
  }

  sendChargeToSap(){
    this.loaded = false;
    var lotes = [];
    var dateTrack;
    var inp=this.template.querySelectorAll("lightning-input");
    inp.forEach(function(element){
        if(element.name=="vDate"){
          dateTrack = element.value;
        } 
    },this);

    //this.loaded = !this.loaded; //al enviar a SAP
    //var dateTimeZone = this.setDateTimeZone(dateTrack); //save SF
    if(this.selection.length > 0){
      for(let element of this.selection){
        lotes.push(this.datos.find(resp => resp.Id == element));
      }

      // const filteredArr = lotes.reduce((acc, current) => {
      //   const x = acc.find(item => item.Proforma === current.Proforma);
      //   if (!x) {
      //     return acc.concat([current]);
      //   } else {
      //     return acc;
      //   }
      // }, []);

      const uniqueObjects = [...new Map(lotes.map(item => [item.Proforma, item])).values()]

      //console.table(uniqueObjects);

      updateDeliveryDate({inArrayLotes : uniqueObjects, inDeliverDate : dateTrack})
      .then((result)=>{
        this.loaded = true;
        this.showMessageToast('Mensaje', result + ' con fecha de entrega: ' + dateTrack,'success');
        setTimeout(function(){
          window.location.reload(1);
       }, 4000);
      })
      .catch((error) => {
        this.loaded = true;
        this.error = error;
        this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
      });
    }else{
      this.loaded = true;
      this.showMessageToast('Mensaje', 'No ha seleccionado ningún lote','warning');
    }

  }

  searchProduct(event){
    
    if(this.datos.length > 0){
      this.searchKey = event.target.value;
      this.resultSearch = this.datos.filter((el) => el.Descripcionlote.toLowerCase().indexOf(this.searchKey.toLowerCase()) > -1); 

      if(this.resultSearch.length > 0){
        this.template.querySelector(
          '[data-id="datarow"]'
        ).selectedRows = this.selection;

        this.pageNumber = 1;
        this.getBatchPag(this.resultSearch);
      }else{
        this.showMessageToast('Mensaje', 'No se encuentran coincidencias','warning');
      }
    }else{
      this.showMessageToast('Mensaje', 'No ha seleccionado proyecto','warning');
    }

  }

  showMessageToast(strTitle,strMessage,strType) {
    const evt = new ShowToastEvent({
        title: strTitle,
        message: strMessage,
        variant: strType,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }  
  
  setDateTimeZone(currentDate){

    var strDate = currentDate + ' 00:00:00Z';
    var dDate = new Date(currentDate);
    var timeTimeZone = dDate.getUTCHours() + 5;
    var timeServer = 0;

    console.log('timeTimeZone ' + timeTimeZone);
    if(timeTimeZone >= 24){
      timeServer = timeTimeZone - 24;
      dDate.setDate(dDate.getDate() + 1);
    }
    else if(timeTimeZone >= 5 && timeTimeZone < 10){
      timeServer = timeTimeZone;
      dDate.setDate(dDate.getDate() + 1);
    }
    else{
      timeServer = timeTimeZone;
    }

    let day = dDate.getDate();
    let month = dDate.getMonth() + 1;
    let year = dDate.getFullYear();

    var dateTimeZone = year + '-' + month + '-' + day + ' ' + timeServer + ':' + dDate.getMinutes() + ':' + dDate.getSeconds();

    return dateTimeZone;
  }

}