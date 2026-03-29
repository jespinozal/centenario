import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPosPaymentCulqi from '@salesforce/apex/CEN_POSPayments_ctr.getPosPaymentCulqi';
import generatePaymentPOS from '@salesforce/apex/CEN_POSPayments_ctr.generatePaymentPOS';
import validateInitialAmountPayment from '@salesforce/apex/CEN_POSPayments_ctr.validateInitialAmountPayment';

import getCashPaymentCulqi from '@salesforce/apex/CEN_CashPayment_ctr.getCashPaymentCulqi';
import generatePaymentCashCulqi from '@salesforce/apex/CEN_CashPayment_ctr.generatePaymentCashCulqi';
import validateInitialAmountPaymentCash from '@salesforce/apex/CEN_CashPayment_ctr.validateInitialAmountPaymentCash';
import {FlowNavigationFinishEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

const COLUMNSCHARGE = [
    { label: 'Código Referencia', fieldName: 'reference', type: 'text' },
    { label: 'Monto', fieldName: 'amount', type: 'currency' },
    { label: 'Nombre Cliente', fieldName: 'clientFirstName', type: 'text' },
    { label: 'Apellido Cliente', fieldName: 'clientLastName', type: 'text' },    
    { label: 'Descripción', fieldName: 'description', type: 'text' },
    { label: 'Fecha', fieldName: 'creationDate', type: 'text' },
    { label: 'Tipo Pago', fieldName: 'paymentType', type: 'text' },
    { label: 'Id', fieldName: 'id', type: 'text' }
];

const COLUMNSCASH = [
    { label: 'Código Pago', fieldName: 'paymentCode', type: 'text' },
    { label: 'Monto', fieldName: 'amount', type: 'currency' },
    { label: 'Descripción', fieldName: 'description', type: 'text' },
    { label: 'Estado', fieldName: 'status', type: 'text' },
    { label: 'Fecha', fieldName: 'creationDate', type: 'text' },
    { label: 'Id', fieldName: 'id', type: 'text' }
];
export default class wcCEN_CulqiExpress extends LightningElement {
    
    @track hasRendered = true;
    @track error;
    @track getPaymentDataCharge = [];
    @track getPaymentDataCash = [];
    @track loaded = false;
    
    columnscharge = COLUMNSCHARGE;
    columnscash = COLUMNSCASH;
    @track progressChargeVisible = true;
    @track progressCashVisible = false;

    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track isPreviousVisible = false;
    @track isNextVisible = false;
    @track selectedRowsCharge = [];
    @track selectedRowsCash = [];
    @track amountMax = 0.0;
    @track amountMin = 0.0;
    @track sumatoriaMontos = 0.0;
    @track codSociety = '';

    @track _oppId = '';
    @api
    get oppId(){
        return this._oppId;
    }
    set oppId(val){
        this._oppId = val;
    }

    @track _propMessagePOS = '';
    @api
    get propMessagePOS(){
        return this._propMessagePOS;
    }
    set propMessagePOS(val){
        this._propMessagePOS = val;
    }

    //Ordenes
    /*@track _propMessageCash = '';
    @api
    get propMessageCash(){
        return this._propMessageCash;
    }
    set propMessageCash(val){
        this._propMessageCash = val;
    }*/
    //Ordenes
    @track selectedValue = 'option1';
    options =  [ { label: 'Cargos', value: 'option1' },{ label: 'Ordenes', value: 'option2' }];
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

    searchClickCharge(event){
        this.loaded = !this.loaded;
        var amountTrack;
        var creationDateFromTrack;
        var creationDateToTrack;
        var firstNameTrack;
        var lastNameTrack;
        var referenceTrack;
        var inp=this.template.querySelectorAll("lightning-input");
        var myCodSoc = this.codSociety;

        inp.forEach(function(element){
            if(element.name=="vAmount"){
                amountTrack= element.value;
            } else if(element.name=="vFirstName"){
                firstNameTrack=element.value;
            } else if(element.name=="vLastName"){
                lastNameTrack=element.value;
            } else if(element.name=="vReference"){
                referenceTrack = element.value;
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
            this.amountMax = result.amountMaximun;
            this.codSociety = result.projectSociety;
            console.log(result);

        getPosPaymentCulqi({ inCreationDateFrom: creationDateFromTrack, inCreationDateTo: creationDateToTrack, inReference: referenceTrack, inAmount: amountTrack, inFirstName: firstNameTrack, inLastName: lastNameTrack, productCulqi: 'express', sociedad:myCodSoc })
        .then((result)=>{
            console.log('result');
            console.table(result);
            this.items = result;
            this.totalRecountCount = result.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            //this.data = this.items.slice(0,this.pageSize); 
            this.data = result;
            this.endingRecord = this.pageSize;
            this.error = undefined;

            this.loaded = !this.loaded;

            if(this.totalRecountCount > 1){
                this.getPaymentDataCharge = this.data;
                //this.getPaymentDataCharge = result;
            }else if(this.totalRecountCount == 0){
                    this.showMessageToast('Notificación','No existen data con los filtros ingresados','success');
                }else{
                var dataPayment = this.data[0];
                if(dataPayment.status === "pagado"){
                    this.showMessageToast('Notificación','La referencia de pago existe en el pago ' + dataPayment.description ,'warning');
                }else{
                    this.getPaymentDataCharge = this.data;
                    //this.getPaymentDataCharge = result;
                }
            }
            
            if(this.totalPage > 1){
                this.isNextVisible = true;
            }
           
            //console.table('getPosPaymentCulqi-sucess: '+ this.getPaymentData);
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            //console.log('error:' + this.error);
        });
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            console.error(error);
        });
        
    } 
    
    searchClickCash(event){
        this.loaded = !this.loaded;
        var amountTrack;
        var creationDateFromTrack;
        var creationDateToTrack;
        var paymentCodeTrack;
        var inp=this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element){
            if(element.name=="vAmount"){
                amountTrack= element.value;
            } else if(element.name=="vPaymentCode"){
                paymentCodeTrack = element.value;
            } else if(element.name=="vCreationDateFrom"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    element.value = newDate.toISOString();
                }
                creationDateFromTrack=element.value;
            } else if(element.name=="vCreationDateTo"){
                if(element.value === ""){
                    var newDate = new Date(); 
                    //element.value = newDate.toISOString()
                    element.value = creationDateFromTrack;
                }
                creationDateToTrack=element.value;
            }
        },this);

        //MIO
        getCashPaymentCulqi({ inCreationDateFrom: creationDateFromTrack, inCreationDateTo: creationDateToTrack, inPaymentCode: paymentCodeTrack, inAmount: amountTrack, productCulqi: 'express', sociedad:myCodSoc })
        .then((result)=>{

            this.items = result;
            this.totalRecountCount = result.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            //this.data = this.items.slice(0,this.pageSize); 
            this.data = result;
            this.endingRecord = this.pageSize;
            this.error = undefined;

            this.loaded = !this.loaded;

            if(this.totalRecountCount > 1){
                this.getPaymentDataCash = this.data;
                //this.getPaymentData = result;
            }else if(this.totalRecountCount == 0){
                    this.showMessageToast('Notificación','No existen data con los filtros ingresados','success');
                }else{
                var dataPayment = this.data[0];
                if(dataPayment.status === "pagado"){
                    this.showMessageToast('Notificación','La orden de pago existe en el pago ' + dataPayment.description ,'warning');
                }else{
                    this.getPaymentDataCash = this.data;
                    //this.getPaymentData = result;
                }
            }
            
            if(this.totalPage > 1){
                this.isNextVisible = true;
            }

            validateInitialAmountPaymentCash({inOppId: this.oppId})
            .then((result)=>{
                this.amountMax = result.amountMaximun;
                this.amountMin = result.amountMinimun;
                console.table(result);
                console.log ('imprimiendo Montos: ');
            })
            .catch((error) => {
                this.loaded = !this.loaded;
                this.error = error;
                console.error(error);
            });
            //console.table('getPosPaymentCulqi-sucess: '+ this.getPaymentData);
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            //console.log('error:' + this.error);
        });
        //Mio Termina
    }

    generateClickCharge(event){
        var oArray = this.template.querySelector('lightning-datatable').getSelectedRows();

        if(oArray.length > 0){
            generatePaymentPOS({inArray: oArray, inOppId: this.oppId})
            .then((result)=>{
                const attributeChangeEvent = new FlowAttributeChangeEvent('propMessagePOS', result);
                this.dispatchEvent(attributeChangeEvent);
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
                console.log('ERROR AL GENERara');
            })
            .catch((error) => {
                this.loaded = !this.loaded;
                this.error = error;
                this._propMessagePOS = error;
                this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
            });
        }
        else{
            this.showMessageToast('Notificación','Seleccione un cargo','warning');
        }

 
    }

    generateClickCash(event){
        var oArray = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('GEnerando: ' + oArray);
        if(this.sumatoriaMontos > this.amountMin){
            if(oArray.length > 0){
                generatePaymentCashCulqi({inArray: oArray, inOppId: this.oppId})
                .then((result)=>{
                    const attributeChangeEvent = new FlowAttributeChangeEvent('propMessagePOS', result);
                    this.dispatchEvent(attributeChangeEvent);
                    const nextNavigationEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(nextNavigationEvent);
                    console.log('GEnerando al if: ');
                })
                .catch((error) => {
                    this.loaded = !this.loaded;
                    this.error = error;
                    this._propMessagePOS = error;
                    this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
                });
            }
            else{
                this.showMessageToast('Notificación','Seleccione un cargo','warning');
            }
        }else{
            this.showMessageToast('Error','La suma de montos ingresados no supera el monto mínimo: S/.' + this.amountMin,'error');
        }
        

 
    }

    getSelectedNameCharge(event) {
        this.template.querySelector('lightning-datatable').selectedRows=[];
        let selectedRows2 = event.detail.selectedRows;
        let montoAcumulado = 0.0;
        var currentAmount = 0.0;
        var selectedRowsAux = this.selectedRowsCharge;
        var isCurrentAmount = false;

        if(selectedRows2 != null && selectedRows2.length > 0){

            this.selectedRowsCharge = [];
            for (let i = 0; i < selectedRows2.length; i++){
                var idExists = false;
                currentAmount = selectedRows2[i].amount;
                montoAcumulado += currentAmount;
                if(this.amountMax >= currentAmount && currentAmount > 0){
                    var validateAmount = this.amountMax - montoAcumulado;

                    for(let j = 0; j < selectedRowsAux.length; j++){
                        if(selectedRowsAux[j] == selectedRows2[i].id && validateAmount > 0){
                            idExists = true;
                        }
                    }
    
                    if(idExists){
                        this.selectedRowsCharge.push(selectedRows2[i].id);
                    }else if(!idExists && validateAmount >= 0){
                        this.selectedRowsCharge.push(selectedRows2[i].id);
                    }else{
                        isCurrentAmount = true;
                        this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');
                    }
                }else {this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');}
            }

            if(isCurrentAmount){
                this.selectedRowsCharge = [];
                for(let j = 0; j < selectedRowsAux.length; j++){
                    this.selectedRowsCharge.push(selectedRowsAux[j]);
                }
            }
        }else{
            this.selectedRowsCharge = [];
        }


    }

    getSelectedNameCash(event) {
        console.log('ERROR TABLA 2 : ');
        this.template.querySelector('lightning-datatable').selectedRows=[];
        let selectedRows2 = event.detail.selectedRows;
        let montoAcumulado = 0.0;
        var currentAmount = 0.0;
        var selectedRowsAux = this.selectedRowsCash;
        var isCurrentAmount = false;
        console.log('ERROR TABLA 3 : ');
        if(selectedRows2 != null && selectedRows2.length > 0){
            console.log('ERROR TABLA 4 : '+ selectedRows2);
            console.table(selectedRows2);
            this.selectedRowsCash = [];
            for (let i = 0; i < selectedRows2.length; i++){
                var idExists = false;
                currentAmount = selectedRows2[i].amount;
                montoAcumulado += currentAmount;
                this.sumatoriaMontos = montoAcumulado;
                console.log('validar this.amountMax: '+ this.amountMax);
                if(this.amountMax > currentAmount && currentAmount > 0){
                    var validateAmount = this.amountMax - montoAcumulado;

                    for(let j = 0; j < selectedRowsAux.length; j++){
                        console.log('validar Monto: '+ validateAmount);
                        if(selectedRowsAux[j] == selectedRows2[i].id && validateAmount > 0){
                            
                            idExists = true;
                        }
                    }
    
                    if(idExists){
                        this.selectedRowsCash.push(selectedRows2[i].id);
                    }else if(!idExists && validateAmount > 0){
                        this.selectedRowsCash.push(selectedRows2[i].id);
                    }else{
                        isCurrentAmount = true;
                        this.sumatoriaMontos = montoAcumulado - currentAmount;
                        this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');
                    }
                }else {this.showMessageToast('Alerta','El pago seleccionado supera el monto máximo.','warning');}
            }

            if(isCurrentAmount){
                this.selectedRowsCash = [];
                for(let j = 0; j < selectedRowsAux.length; j++){
                    this.selectedRowsCash.push(selectedRowsAux[j]);
                }
            }
        }else{
            this.selectedRowsCash = [];
        }


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
    
    handleChange(event) {
        console.log('ERROR AQUI BOTON')
        this.selectedValue = event.detail.value;
        //this.hasRendered = true;
        if(this.selectedValue == 'option1'){
            this.progressChargeVisible = true;
            this.progressCashVisible = false;
            this.getPaymentDataCash = [];
            this.selectedRowsCash = [];
            
        }else{
            this.progressChargeVisible = false;
            this.progressCashVisible = true;
            this.getPaymentDataCharge = [];
            this.selectedRowsCharge = [];
            
        }
        
    }
}