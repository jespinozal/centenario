import { LightningElement, api, wire,track } from 'lwc';
import getPartner from '@salesforce/apex/CEN_PartnerHelper_ctr.getPartner';
import { RefreshEvent } from "lightning/refresh";
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from "lightning/uiRecordApi";
import deletePartner from '@salesforce/apex/CEN_PartnerHelper_ctr.deletePartner';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LwcRelatedPartnerList extends LightningElement {

    @api recordId;   
    @track error;
    @track partner;
    @track showPartner = false;
    @track partnerLabel;
    @track  message;
    //viewAll = '/lightning/r/Opportunity/' + this.recordId + '/related/OpportunityPartnersFrom/view';


    get getViewAll() {
        return '/lightning/r/Opportunity/' + this.recordId + '/related/OpportunityPartnersFrom/view';
    }

    // get partnerLabel() {
    //     return this.partner.length;
    // }

    @wire(getPartner,{oppId:'$recordId'})
    wiredPartner({data, error}){
        console.log('llamada');
        if (data) {
            this.partner = data;
                        if(this.partner){
                            this.partner = data.map((partn) => {
                                console.log('Partn');
                                const partneraccount = {...partn};
                                partneraccount.PartnerUrl = '/lightning/r/Account/' + partn.Id +'/view';
                                return partneraccount;
                            });
                        }

            this.error=undefined;
            // console.log('Entra a Data');
            // console.log(JSON.stringify(data));
            // console.log('Entra a Partner');
            // console.log(this.partner);
            // console.log(this.partner.length);
            this.partnerLabel='Partners ' + '('+ this.partner.length +')';
            this.showPartner = this.partner.length > 0 ? true : false;
        }

        if (error) {
            console.error('Error occurred retrieving Partner records...');
        }
    }

    handleShow() {
        const modal=this.template.querySelector("c-lwc-add-partner");
        modal.show();
    }

    parentHandler(event) {
        this.message = event.detail;
        console.log("Entro refreshApex");
        refreshApex(this.partner);
        this.dispatchEvent(new RefreshEvent());
        console.log('Message:' + this.message);

    }

    async handleDelete(event) {
        console.log("Hola Mundo");
        let selectedrow=event.currentTarget;
        let id=selectedrow.dataset.id;
        console.log("Id: " + id);

        try {
            await deleteRecord(id);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Partner deleted',
                    variant: 'success'
                })
            );
            // await refreshApex(this.wiredAccountsResult);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    async handleDelete2(event) {
        let selectedrow=event.currentTarget;
        let id=selectedrow.dataset.id;
        console.log("Id: " + id);

        try {
            //await deleteRecord(id);
            let resultado = await deletePartner({accountId : id})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Partner deleted',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new RefreshEvent());
                window.location.reload();
            })
            .catch(error => {
                // this.message = undefined;
                // this.error = error;
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error creating record',
                //         message: error.body.message,
                //         variant: 'error',
                //     }),
                // );
                console.log("error", JSON.stringify(this.error));
            });
        //}

            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Success',
            //         message: 'Partner deleted',
            //         variant: 'success'
            //     })
            // );
            // await refreshApex(this.wiredAccountsResult);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }
}