import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPosPaymentCulqi from '@salesforce/apex/CEN_POSPayments_ctr.getPosPaymentCulqi';
import generatePaymentPOS from '@salesforce/apex/CEN_POSPayments_ctr.generatePaymentPOS';
import validateInitialAmountPayment from '@salesforce/apex/CEN_POSPayments_ctr.validateInitialAmountPayment';
import {FlowNavigationFinishEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

const COLUMNS = [
    { label: 'Id', fieldName: 'id', type: 'text', initialWidth: 80, sortable: "true" },
    { label: 'Monto', fieldName: 'amount', type: 'currency', initialWidth: 120, sortable: "true" },
    { label: 'Moneda', fieldName: 'currencyCode', type: 'text', initialWidth: 120, sortable: "true" },
    { label: 'Sociedad', fieldName: 'society', type: 'text', initialWidth: 150, sortable: "true" },
    { label: 'Comisión', fieldName: 'totalFee', type: 'currency', initialWidth: 120, sortable: "true" },
    { label: 'Cód. Autorización', fieldName: 'autorizacion', type: 'text', initialWidth: 120, sortable: "true" },
    { label: 'Cód. Pago', fieldName: 'paymentCode', type: 'text', initialWidth: 120, sortable: "true" },
    { label: 'Núm. Tarjeta', fieldName: 'cardNumber', type: 'text', initialWidth: 120, sortable: "true" },
    { label: 'Fecha', fieldName: 'creationDate', type: 'text', initialWidth: 120, sortable: "true" },
    { label: 'Tipo Pago', fieldName: 'paymentType', type: 'text', initialWidth: 120, sortable: "true" }
];
export default class wcCEN_POSPayments extends LightningElement {
    @track hasRendered = true;
    @track error;
    @track getPaymentData = [];
    @track loaded = false;
    
    columns = COLUMNS;

    @track items = []; 
    @track data = []; 
    @track totalRecountCount = 0;
    @track isPreviousVisible = false;
    @track isNextVisible = false;
    @track selectedRows = [];
    @track amountMax = 0.0;
    @track amountMin = 0.0;
    @track montoAcumuladoFinal = 0.0;
    @track codSociety = '';
    @track sortBy;
    @track sortDirection;

    @track checked = false;
    @track _oppId = '';
    @api
    get oppId(){
        return this._oppId;
    }
    set oppId(val){
        this._oppId = val;
    }

    @track _moneda = '';
    @api
    get moneda(){
        return this._moneda;
    }
    set moneda(val){
        this._moneda = val;
    }

    @track _propMessagePOS = '';
    @api
    get propMessagePOS(){
        return this._propMessagePOS;
    }
    set propMessagePOS(val){
        this._propMessagePOS = val;
    }

    changeToggle(event){
        this.checked = !this.checked;
        console.log('sociedad:');
        console.log(this.checked);
    }

    renderedCallback() {
        if (this.hasRendered) {
            this.loaded = !this.loaded;
            var creationDateFromTrack;
            var creationDateToTrack;
            var inp=this.template.querySelectorAll("lightning-input");

            inp.forEach(function(element){
            if(element.name=="vCreationDateFrom"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    element.value = newDate.toISOString()
                }
                creationDateFromTrack=element.value;
            } else if(element.name=="vCreationDateTo"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    element.value = newDate.toISOString()
                }
                creationDateToTrack=element.value;
            }
            },this);

            this.hasRendered = false;
        }
    }

    searchClick(event){
        
        this.loaded = !this.loaded;
        var amountTrack;
        var creationDateFromTrack;
        var creationDateToTrack;
        var autorizacionTrack;
        var codeTrack;
        var cardTrack;
        var inp=this.template.querySelectorAll("lightning-input");
        var myCodSoc = this.codSociety;

        inp.forEach(function(element){
            if(element.name=="vAmount"){
                amountTrack= element.value;
            } else if(element.name=="vAutorizacion"){
                autorizacionTrack = element.value;
            } else if(element.name=="vCode"){
                codeTrack = element.value;
            } else if(element.name=="vCard"){
                cardTrack = element.value;
            } else if(element.name=="vCreationDateFrom"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    element.value = newDate.toISOString()
                }
                creationDateFromTrack=element.value;
            } else if(element.name=="vCreationDateTo"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    element.value = newDate.toISOString()
                }
                creationDateToTrack=element.value;
            }
        },this);

        validateInitialAmountPayment({inOppId: this.oppId})
        .then((result)=>{
            this.amountMin = (Math.round(result.amountMinimun * 100) / 100).toFixed(2);
            this.amountMax = (Math.round(result.amountMaximun * 100) / 100).toFixed(2);
            this.codSociety = result.projectSociety;

        getPosPaymentCulqi({ inCreationDateFrom: creationDateFromTrack, inCreationDateTo: creationDateToTrack, inAutorizacion: autorizacionTrack, inCode: codeTrack, inCard: cardTrack, inAmount: amountTrack, sociedad:this.codSociety, moneda: this.moneda, traslado: this.checked })
        .then((result)=>{
            this.items = result;
            this.totalRecountCount = result.length; 
            this.data = result;
            this.error = undefined;
            
            this.loaded = !this.loaded;

            if(this.totalRecountCount > 1){
                this.getPaymentData = this.data;
            }else if(this.totalRecountCount == 0){
                    this.showMessageToast('Notificación','No existen data con los filtros ingresados','success');
                }else{
                var dataPayment = this.data[0];
                if(dataPayment.status === "pagado"){
                    this.showMessageToast('Notificación','La referencia ya existe en el pago ' + dataPayment.description + ' de la oportunidad ' + dataPayment.opportunity  ,'warning');
                }else{
                    this.getPaymentData = this.data;
                }
            } 
           
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
        });
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            
        });
        
    } 

    generateClick(event){
        this.loaded = !this.loaded;
        
        var oArray = this.template.querySelector('lightning-datatable').getSelectedRows();

        if(oArray.length > 0){
            if(this.montoAcumuladoFinal < this.amountMin && this.amountMin > 0){
                this.showMessageToast('Alerta','El pago seleccionado deberá ser entre ' + this.amountMin +  ' y ' + this.amountMax + '.','warning');
                this.loaded = !this.loaded;
            }else{    
                generatePaymentPOS({inArray: oArray, inOppId: this.oppId})
                .then((result)=>{
                    const attributeChangeEvent = new FlowAttributeChangeEvent('propMessagePOS', result);
                    this.dispatchEvent(attributeChangeEvent);
                    const nextNavigationEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(nextNavigationEvent);
                })
                .catch((error) => {
                    this.loaded = !this.loaded;
                    this.error = error;
                    this._propMessagePOS = error;
                    this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
                })
                .finally(() => {
                    this.loaded = !this.loaded;
                });
            }
        }
        else{
            this.showMessageToast('Notificación','Seleccione un cargo','warning');
            this.loaded = !this.loaded;
        }

 
    }

    getSelectedName(event) {
        
        this.template.querySelector('lightning-datatable').selectedRows=[];
        let selectedRows2 = event.detail.selectedRows;
        let montoAcumulado = 0.0;
        var currentAmount = 0.0;
        var selectedRowsAux = this.selectedRows;
        var isCurrentAmount = false;
        var commision = 0.0;

        if(selectedRows2 != null && selectedRows2.length > 0){

            this.selectedRows = [];
            for (let i = 0; i < selectedRows2.length; i++){
                var idExists = false;
                currentAmount = selectedRows2[i].amount;
                commision = selectedRows2[i].totalFee;
                montoAcumulado += currentAmount;
                if(commision <= 0){
                    this.showMessageToast('Alerta','Aún se esta procesando la comisión del pago inténtelo en unos minutos.','warning');
                }else if(this.amountMax >= currentAmount && currentAmount > 0){
                    var validateAmount = this.amountMax - montoAcumulado;
                    for(let j = 0; j < selectedRowsAux.length; j++){
                        if(selectedRowsAux[j] == selectedRows2[i].id && validateAmount >= 0){
                            idExists = true;
                        }
                    }
                    
                    if(idExists){
                        this.selectedRows.push(selectedRows2[i].id);
                        
                    }else if(!idExists && validateAmount >= 0){
                        this.selectedRows.push(selectedRows2[i].id);
                        
                    }else{
                        isCurrentAmount = true;
                        this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');
                    }
                }else{
                    this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');
                }
            }
            
            if(isCurrentAmount){
                
                this.selectedRows = [];
                for(let j = 0; j < selectedRowsAux.length; j++){
                    this.selectedRows.push(selectedRowsAux[j]);
                }
            }
        }else{
            this.selectedRows = [];
            
        }

        this.montoAcumuladoFinal = montoAcumulado;
    }

    backClick(event){
        const backNavigationEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(backNavigationEvent);
    }

    cancelClick(event){
        
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
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

    handleSortAccountData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
    }


    sortAccountData(fieldname, direction) {
        
        //let parseData = JSON.parse(JSON.stringify(this.data));
        let parseData = JSON.parse(JSON.stringify(this.getPaymentData));
       
        let keyValue = (a) => {
            return a[fieldname];
        };


       let isReverse = direction === 'asc' ? 1: -1;


           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        //this.data = parseData;
        this.getPaymentData = parseData;


    }
}