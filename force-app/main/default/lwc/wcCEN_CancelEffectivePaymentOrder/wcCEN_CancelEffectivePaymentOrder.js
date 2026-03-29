import { LightningElement, wire, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelPaymentEFEC from '@salesforce/apex/CEN_CancelEffectivePaymentOrder_ctr.cancelPaymentEFEC';
//import getIdCulqi from '@salesforce/apex/CEN_CancelEffectivePaymentOrder_ctr.getIdCulqi';

export default class WcCEN_CancelEffectivePaymentOrder extends LightningElement {

    //@track hasRendered = true;
    @track error;
    @api recordId;
    @track recId; 
    //@track culqiId;

    // renderedCallback() {
    //     if (this.hasRendered) {
    //         getIdCulqi({ inPaymentId: this.recordId })
    //         .then((result)=>{
    //             //this.showMessageToast('Alerta',result,'success');
    //             this.culqiId = result;
    //         })
    //         .catch((error) => {
    //             this.loaded = !this.loaded;
    //             console.log('error: ' + error);
    //             this.showMessageToast('Alerta', error ,'error');
    //         });
    //     }
    // }

    handleClick(event){
        //console.log('entra: ' + this.culqiId);
        cancelPaymentEFEC({ inPaymentId: this.recordId })
        .then((result)=>{
            console.log('EFEC: ' + result);
            this.showMessageToast('Alerta',result,'success');
            //updateRecord({fields: this.recordId});
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch((error) => {
            console.log('error: ' + error);
            this.loaded = !this.loaded;
            this.showMessageToast('Alerta', error ,'error');
            this.error = error;
        });
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

}