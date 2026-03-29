import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import actualizarPremioReferido from '@salesforce/apex/CEN_ClienteAptoPremioReferido_ctr.ActualizarDatosReferidoCasoLWC';

import PRECIOVTAENTE_FIELD from "@salesforce/schema/Case.CEN_PrecioVentaReferente__c";
import FECHACVTAENTE_FIELD from "@salesforce/schema/Case.CEN_FechaCierreVentaReferente__c";
import FECHACARRASENTE_FIELD from "@salesforce/schema/Case.CEN_FechaCierreArrasReferente__c";
import SUBZONAENTE_FIELD from "@salesforce/schema/Case.CEN_SubzonaReferente__c";
import NROFINANENTE_FIELD from "@salesforce/schema/Case.CEN_NumFinanciamientoReferente__c";
import DEUDAENTE_FIELD from "@salesforce/schema/Case.CEN_DeudaReferente__c";
import OBSENTE_FIELD from "@salesforce/schema/Case.CEN_ObservacionReferente__c";
import APTO_FIELD from "@salesforce/schema/Case.CEN_AptoPremiacion__c";
import PRECIOVTAIDO_FIELD from "@salesforce/schema/Case.CEN_PrecioVentaReferido__c";
import FECHACVTAIDO_FIELD from "@salesforce/schema/Case.CEN_FechaCierreVentaReferido__c";
import FECHACARRASIDO_FIELD from "@salesforce/schema/Case.CEN_FechaCierreArrasReferido__c";
import SUBZONAIDO_FIELD from "@salesforce/schema/Case.CEN_SubzonaReferido__c";
import NROFINANIDO_FIELD from "@salesforce/schema/Case.CEN_NumFinanciamientoReferido__c";
import OBSIDO_FIELD from "@salesforce/schema/Case.CEN_ObservacionReferido__c";


const FIELDS = [PRECIOVTAENTE_FIELD,
    FECHACVTAENTE_FIELD,
    FECHACARRASENTE_FIELD,
    SUBZONAENTE_FIELD,
    NROFINANENTE_FIELD,
    DEUDAENTE_FIELD,
    OBSENTE_FIELD,
    APTO_FIELD,
    PRECIOVTAIDO_FIELD,
    FECHACVTAIDO_FIELD,
    FECHACARRASIDO_FIELD,
    SUBZONAIDO_FIELD,
    NROFINANIDO_FIELD,
    OBSIDO_FIELD];

export default class LwcGestionReferidos extends LightningElement {
    @api recordId;
    @track loaded = false;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    caso;

    get preciovtaente() {
      return getFieldValue(this.caso.data, PRECIOVTAENTE_FIELD);
    }

    get fechacvtaente() {
        return getFieldValue(this.caso.data, FECHACVTAENTE_FIELD);
    }

    get fechacarrasente() {
        return getFieldValue(this.caso.data, FECHACARRASENTE_FIELD);
    }

    get subzonaente() {
        return getFieldValue(this.caso.data, SUBZONAENTE_FIELD);
    }

    get nrofinanente() {
        return getFieldValue(this.caso.data, NROFINANENTE_FIELD);
    }

    get deudaente() {
        return getFieldValue(this.caso.data, DEUDAENTE_FIELD);
    }

    get obsente() {
        return getFieldValue(this.caso.data, OBSENTE_FIELD);
    }

    get apto() {
        return getFieldValue(this.caso.data, APTO_FIELD);
    }

    get preciovtaido() {
        return getFieldValue(this.caso.data, PRECIOVTAIDO_FIELD);
    }

    get fechacvtaido() {
        return getFieldValue(this.caso.data, FECHACVTAIDO_FIELD);
    }

    get fechacarrasido() {
        return getFieldValue(this.caso.data, FECHACARRASIDO_FIELD);
    }

    get subzonaido() {
        return getFieldValue(this.caso.data, SUBZONAIDO_FIELD);
    }

    get nrofinanido() {
        return getFieldValue(this.caso.data, NROFINANIDO_FIELD);
    }

    get obsido() {
        return getFieldValue(this.caso.data, OBSIDO_FIELD);
    }

    renderedCallback() {
        if (this.hasRendered) {
            this.loaded = !this.loaded;
        }
    }

    updateClick(event){
        //console.log('recordId: ' + recordId);
        console.log('recordId this: ' + this.recordId);
        this.loaded = !this.loaded;

        actualizarPremioReferido({recordId : this.recordId})
        .then((result)=>{
            console.log(result);
            console.log(result.data.length);
            if(result.data.length > 0){
                console.log(result.data);
                this.dataValidate();
                this.showMessageToast('Notificación',result.mensaje,'success');
                this.dispatchEvent(new RefreshEvent());
                //eval("$A.get('e.force:refreshView').fire();");
            }else{
                this.showMessageToast('Alerta',result.mensaje,'warning');
            }
        })
        .catch((error) => {
            this.showMessageToast('Error', error + ' - Error tecnico, contactar al administrador de sistemas','error');
        })
        .finally(() => {
            this.loaded = !this.loaded;
        });

    }

    dataValidate() {
        console.log('this.nrofinanente: ' + this.nrofinanente);
        console.log('this.apto: ' + this.apto);

    }

    get eligibleClass() {
        return `slds-badge ${this.apto ? 'slds-theme_success': 'slds-theme_error'}`
    }

    get eligibleText() {
        return this.apto ? 'Apto': 'No Apto';
    }

    // beginRefresh() {
    //     this.dispatchEvent(new RefreshEvent());
    // }

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