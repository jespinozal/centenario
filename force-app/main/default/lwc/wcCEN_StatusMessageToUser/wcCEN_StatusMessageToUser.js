import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOppData from '@salesforce/apex/CEN_StatusMessageToUser_ctr.getStatusFromOpp';
import getPaymentDataError from '@salesforce/apex/CEN_StatusMessageToUser_ctr.getErrorPaymentByOppId';
import callApiSAP from '@salesforce/apex/CEN_StatusMessageToUser_ctr.sendOperationToSap';
import callApiPaymentSAP from '@salesforce/apex/CEN_StatusMessageToUser_ctr.sendPaymentsToSap';


export default class WcCEN_StatusMessageToUser extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track oppData;
    @track error;
    @track hasRendered = true;
    @track progressRingVisible = true;
    @track progressBarVisible = false;
    @track isModalOppMessageOpen = false;
    @track isModalPaymentMessageOpen = false;
    @track btnErrorOpp = false;
    @track btnErrorPayment = false;
    @track btnProcessingPayment = false;
    @track paymentsError = {};

    currencyType = '';
    initAmount = 0.00;
    currentAmount = 0.00;
    dateExperation;
    dayBetween = 0;
    difAmount=0.00;
    percentDay;
    percentAmount;
    maxDays;
    proforma;
    daysRingType;
    amountRingType;
    messageErrorOpp;
    messageErrorPayment;
    selectedValue = 'option1';
    options =  [ { label: 'Circular', value: 'option1' },{ label: 'Barras', value: 'option2' }];

    searchOpp(){
        getOppData({ oppId: this.recordId })
            .then((result) => {
                console.log('result::: '+result);
                if(result.CEN_AmountPaidDate__c){
                    this.currentAmount = result.CEN_AmountPaidDate__c;
                    this.currentAmount = (Math.round(this.currentAmount * 100) / 100).toFixed(2); 
                }else{
                    this.currentAmount = 0;
                }
                if(result.CEN_Monto_cuota_de_inicial_de_precio__c){
                    this.initAmount = result.CEN_Monto_cuota_de_inicial_de_precio__c;
                    this.currencyType = result.CEN_Moneda__c == 'PEN' ? 'S/' : '$';
                    //this.initAmount = (Math.round(this.initAmount * 100) / 100).toFixed(2);
                    this.initAmount = Number(Math.round(this.initAmount + "e2") + "e-2");
                    this.initAmount = this.initAmount.toFixed(2);
                }else{
                    this.initAmount = 0;
                }
                
                if(result.CEN_Proyecto__r.CEN_MaximumTermForSigningTheContract__c){
                    this.maxDays = result.CEN_Proyecto__r.CEN_MaximumTermForSigningTheContract__c;
                }else{
                    this.maxDays = 0 ;
                }

                this.difAmount = this.initAmount - this.currentAmount;
                this.difAmount = this.difAmount.toFixed(2);
                if(result.CEN_Proforma__c){
                    this.proforma = result.CEN_Proforma__c;
                }else{
                    this.proforma = 'S/P';
                }
                if(result.CEN_MaximumDateSigningContract__c){
                    this.dateExperation= result.CEN_MaximumDateSigningContract__c;
                    var currenDate = Date.now();
                    var myDate = this.dateExperation;
                    var strDate = myDate.toString(myDate);
                    var d = new Date(strDate);
                    var n = d.valueOf();
                    var dif = parseInt ((n-currenDate) / (1000*60*60*24));
                    this.dayBetween = dif;
                }else{
                    this.dayBetween = 0;
                }
                
                
                var myPercentDay = (dif / this.maxDays)*100;
                this.percentDay = this.progressBarVisible?'width:'+(myPercentDay)+'%':''+(myPercentDay);
                this.daysRingType = myPercentDay>50?'base':myPercentDay>0?'warning':'expired';

                var myPercentAmount = (this.currentAmount / this.initAmount)*100;                
                this.percentAmount =  this.progressBarVisible?'width:'+(myPercentAmount)+'%':''+(myPercentAmount);
                this.amountRingType = myPercentAmount==0?'warning':myPercentAmount>99?'base-autocomplete':'base';
                
                if(result.CEN_MessageError__c != undefined && result.CEN_MessageError__c != null){
                    var myMessageErrorOpp = result.CEN_MessageError__c;
                    this.messageErrorOpp = myMessageErrorOpp;
                    this.btnErrorOpp =  myMessageErrorOpp!=undefined || myMessageErrorOpp.trim()>0?true:false;
                }else{
                    this.btnErrorOpp = false;
                }
                
                if(result.CEN_MessageError__c != undefined && result.CEN_MessageError__c != null){
                    var myMessageErrorPayment = result.CEN_MessageError__c;
                    this.messageErrorPayment = myMessageErrorPayment;
                    this.btnErrorOpp =  myMessageErrorPayment!=undefined || myMessageErrorPayment.trim()>0?true:false;
                }else{
                    this.btnErrorOpp = false;
                }

                this.error = undefined;

            })
            .catch((error) => {
                this.error = error;
                
            });
            this.getPaymentError();
            this.hasRendered = false;
    }

    renderedCallback() {
        if (this.hasRendered) {
            this.loaded = !this.loaded;
            this.searchOpp();
        }
        console.log('FIN Cargando');
        console.log('cargando ' + this.loaded);
    }
    

    getPaymentError() {
        getPaymentDataError({ oppId: this.recordId })
                .then((result) => {
                    // Logica de error de pagos
                    if(result.length>0){

                        // result.forEach(element => {
                        //     console.log(element);
                        //     if(element.CEN_MessageError__c == '' && elemnt.CEN_PaymentStatus__c == 'PendienteSAP'){
                        //         this.btnProcessingPayment = true;
                        //     }
                        // });
                        
                        // if(!this.btnProcessingPayment){
                            console.log('getPaymentError-pagosConError: '+result);
                            console.table(result);
                            this.paymentsError = result;
                            this.btnErrorPayment = true;
                        // }
                    }else{
                        console.log('getPaymentError-pagosSinError');
                    }
                    

                })
                .catch((error) => {
                    this.error = error;
                    
                });
    }

    viewModalOppMessage(e){
        this.isModalOppMessageOpen = true;
    }
    closeModalOppMessage(e){
        console.log('closeModalOppMessage');
        this.isModalOppMessageOpen = false;
    }
    sendOperationToSap(e){
        this.loaded = !this.loaded;
        callApiSAP({ oppId: this.recordId })
        .then((result) => {
            // mensaje api
            console.table(result);
            
            if(result.success){
                var susMessage = result.success;
                this.showMessageToast('Exito',susMessage,'success');
                this.isModalOppMessageOpen = false;
            }else{
                var errMessage = result.error;
                this.showMessageToast('Error',errMessage,'error');
            }

            this.loaded = !this.loaded;
            //setInterval(window.location.reload(),15000);
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
            console.table(this.error);
            //setInterval(window.location.reload(),15000);
        });  
    }

    sendPaymentsToSap(e){
        this.loaded = !this.loaded;
        callApiPaymentSAP({ oppId: this.recordId })
        .then((result) => {
            // mensaje api
            console.table(result);

            if(result.success){
                var susMessage = result.success;
                this.showMessageToast('Exito',susMessage,'success');
                this.isModalPaymentMessageOpen = false;
            }else{
                var errMessage = result.error;
                this.showMessageToast('Error',errMessage,'error');
            }

            this.loaded = !this.loaded;
            //setInterval(window.location.reload(),15000);
            
        })
        .catch((error) => {
            this.loaded = !this.loaded;
            this.error = error;
            this.showMessageToast('Error','Error tecnico, contactar al administrador de sistemas','error');
            console.table(this.error);
            this.isModalPaymentMessageOpen = false;
            //setInterval(window.location.reload(),15000);
        });
    }

    
    viewModalPaymentMessage(e){
        this.isModalPaymentMessageOpen = true;
    }
    closeModalPaymentMessage(e){
        this.isModalPaymentMessageOpen = false;
        console.log('Cerrar');
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
        this.selectedValue = event.detail.value;
        this.hasRendered = true;
        if(this.selectedValue == 'option1'){
            this.progressRingVisible = true;
            this.progressBarVisible = false;
        }else{
            this.progressRingVisible = false;
            this.progressBarVisible = true;
        }
    }

   

}