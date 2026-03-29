import { LightningElement, api, track } from 'lwc';
import IMAGE_WARNING from '@salesforce/resourceUrl/CEN_ImageWarning';

export default class WcCEN_MessagePopUpWarning extends LightningElement {

    imageWarning = IMAGE_WARNING;
    @track isModalOpen = false;

    @api
    openModal() {
        this.isModalOpen = true;
    }

    @api
    closeModal() {
        this.isModalOpen = false;    
    }
}