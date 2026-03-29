import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

import CEN_SUB_ETAPA_ARRAS_FIELD from "@salesforce/schema/Opportunity.CEN_Sub_etapa_ARRAS__c";
import CEN_SUB_ESTADO_FIELD from "@salesforce/schema/Opportunity.CEN_Sub_estado__c";
import CEN_STATUS_LOT_FIELD from "@salesforce/schema/Opportunity.CEN_StatusLot__c";

const myFields = [
  CEN_SUB_ETAPA_ARRAS_FIELD,
  CEN_SUB_ESTADO_FIELD,
  CEN_STATUS_LOT_FIELD
];

export default class LwcMostrarEstadoOnBase extends LightningElement {
  @api recordId;
  data;
  error;

  subEtapaArras = "";
  subEstado = "";
  statusLot = "";

  @wire(getRecord, { recordId: "$recordId", fields: myFields })
  wiredRecord({ error, data }) {
    if (error) {
      console.log("paso un error");
    } else if (data) {
      this.data = data;
      
      this.subEtapaArras = (!this.data.fields.CEN_Sub_etapa_ARRAS__c.value)? false: true;
      this.subEstado = this.data.fields.CEN_Sub_estado__c.value;
      this.statusLot = this.data.fields.CEN_StatusLot__c.value;
    }
  }
}