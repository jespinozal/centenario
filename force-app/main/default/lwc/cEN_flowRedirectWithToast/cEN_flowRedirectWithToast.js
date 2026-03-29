import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CEN_flowRedirectWithToast extends NavigationMixin(LightningElement) {

    @api recordId;
    @api toastTitle;
    @api toastMessage;
    @api toastVariant;

    connectedCallback() {
        this.showToast();
        this.navigateToRecord();
    }

    showToast() {
        // YA NO NECESITAMOS REEMPLAZAR EL TEXTO.
        // El flujo nos dará el mensaje final y completo.
        const event = new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage, // Se usa directamente
            variant: this.toastVariant || 'success',
        });
        this.dispatchEvent(event);
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
}