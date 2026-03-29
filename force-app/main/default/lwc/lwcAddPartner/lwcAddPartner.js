import {LightningElement,track,api,wire} from 'lwc';
import OPPORTUNITYID_FIELD from '@salesforce/schema/Partner.OpportunityId';
import ACCOUNTTOID_FIELD from '@salesforce/schema/Partner.AccountToId';
import ROLE_FIELD from '@salesforce/schema/Partner.Role';
import ISPRIMARY_FIELD from '@salesforce/schema/Partner.IsPrimary';
import savePartners from '@salesforce/apex/CEN_PartnerHelper_ctr.savePartners';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Objects_Type from "@salesforce/apex/CEN_PartnerHelper_ctr.getPartnerRole";
export default class LwcAddPartner extends LightningElement {
    isModalOpen = false;
    @track partnerList = [];
    @track index = 5;
    //@api recordId;
    @api item;
    @track opportunityId = OPPORTUNITYID_FIELD;
    //@track opportunityId = this.recordId;
    //@track opportunityId = '006Em0000065PjtIAE';
    @track accountToId = ACCOUNTTOID_FIELD;
    @track role = ROLE_FIELD;
    @track isPrimary = ISPRIMARY_FIELD;
    isLoaded = false;

    partner = {
        OpportunityId : this.opportunityId,
        AccountToId : this.accountToId,
        Role : '',
        key : 0,
        toggle : 'toggle0',
        active: false,
        IsPrimary: this.isPrimary
    }

    // connectedCallback() {
    //     console.log('item: ' + this.item);
    //     for (let i = 1; i < 6; i++) {
    //         this.partner.OpportunityId = this.item;
    //         this.partner.key = i;
    //         this.partner.toggle = 'toggle' + i;
    //         this.partnerList.push(JSON.parse(JSON.stringify(this.partner)));
    //     }
    // }

    addRow(){
        console.log(this.partnerList);
        this.index++;
        let i = this.index;
        this.partner.OpportunityId = this.item;
        this.partner.key = i;
        this.partner.toggle = 'toggle'+i;
        this.partnerList.push(JSON.parse(JSON.stringify(this.partner)));
    }

    @api async saveRecord(){
        this.partnerList = this.partnerList.filter((item) => {
            return item.active;
        });

        console.log('this.partnerList');
        console.log(this.partnerList);
        if(this.partnerList.length > 0){
        let resultado = await savePartners({partnerList : this.partnerList})
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                    this.partner.OpportunityId = '';
                    this.partner.AccountToId = '';
                    this.partner.Role = '';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Socio agregado',
                            variant: 'success',
                        }),
                    );
                }

                console.log(JSON.stringify(result));
                console.log("result", this.message);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                console.log("error", JSON.stringify(this.error));
            });
        }
        this.isModalOpen = false;
        // const evt = new CustomEvent('sendmessage', {detail: "Hey, This message is sent from child Component II"});
        // this.dispatchEvent(evt);
        window.location.reload();
        //this.handleShowPartner();
        //eval("$A.get('e.force:refreshView').fire();");
    }

    selectall(event) {
        const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = false;
        }
        const checkbox = this.template.querySelector('lightning-input[data-id="'+event.target.dataset.id+'"]');
        checkbox.checked=true;

        for(const element of this.partnerList){
            element.IsPrimary = false;
        }

        let key = event.target.dataset.key;
        if(key != "-1"){this.partnerList[key].IsPrimary = true;}
    }

    handleAccountSelection(event){
        let selectedRow = event.currentTarget;
        let key = selectedRow.dataset.id;
        this.partnerList[key].AccountToId = event.target.value;
        this.partnerList[key].active = true;
    }

    @track l_All_Types;
    @track TypeOptions;

    @wire(Objects_Type, {})
    WiredObjects_Type({ error, data }) {
        if (data) {
            try {
                this.l_All_Types = data;
                let options = [];
                for (var key in data) {
                    options.push({ label: data[key].MasterLabel, value: data[key].Id  });
                }
                this.TypeOptions = options;
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }
    handleRoleChange(event){
        let selectedRow = event.currentTarget;
        let key = selectedRow.dataset.id;
        this.partnerList[key].Role = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    @api
    closeModal() {
        this.isModalOpen = false;
    }

    @api
    show() {
        this.partnerList = [];
        this.index = 5;
        for (let i = 1; i < 6; i++) {
            this.partner.OpportunityId = this.item;
            this.partner.key = i;
            this.partner.toggle = 'toggle' + i;
            this.partnerList.push(JSON.parse(JSON.stringify(this.partner)));
        }
        this.isModalOpen = true;
    }

    // handleShowPartner() {
    //     this.template.querySelector("c-lwc-related-partner-lista").updateData();
    // }
}