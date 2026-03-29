import { api, LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ONI_class_Opportunity_LeftDocuments_find from '@salesforce/apex/ONI_class_Opportunity_LeftDocuments.ONI_class_Opportunity_LeftDocuments_find';
import RECORDTYPE_FIELD from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import TIPO_PRODUCTO_FIELD from '@salesforce/schema/Opportunity.OFI_fld_Opportunity_TipoProducto__c';

export default class ONI_lwc_Opportunity_LeftDocuments extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [RECORDTYPE_FIELD, TIPO_PRODUCTO_FIELD] })
    opportunityRecord;

    get recordTypeName() {
        return this.opportunityRecord?.data?.fields?.RecordType?.value?.fields?.DeveloperName?.value;
    }

    get tipoProducto() {
        return this.opportunityRecord?.data?.fields?.OFI_fld_Opportunity_TipoProducto__c?.value;
    }

    get isOficina() {
        return this.recordTypeName === 'OFI_rt_Oportunidad_Oficina' && this.tipoProducto === 'Oficinas';
    }

    get isSala() {
        return this.recordTypeName === 'OFI_rt_Oportunidad_Oficina' && this.tipoProducto === 'Salas';
    }

    get isIndustrial() {
        return this.recordTypeName === 'IND_rt_Oportunidad_Industrial';
    }
    

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Carta Fianza' })
    cartaFianzaResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Acta Entrega' })
    actaEntregaResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Póliza de Seguro' })
    polizaSeguroResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Poliza de Seguro' })
    polizaSeguroResult2;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Contrato Firmado' })
    contratoFirmadoResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Constancia de Pago' })
    constanciaPagoResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Ficha de Reserva' })
    fichaReservaResult;

    @wire(ONI_class_Opportunity_LeftDocuments_find, { opportunityId: '$recordId', documentName: 'Confirmación' })
    confirmacionResult;

    get cartaFianza() {
        return (this.cartaFianzaResult?.data?.[0] || false);
    }

    get actaEntrega() {
        return (this.actaEntregaResult?.data?.[0] || false);
    }

    get polizaSeguro() {
        return (this.polizaSeguroResult?.data?.[0] || this.polizaSeguroResult2?.data?.[0] || false);
    }

    get contratoFirmado() {
        return (this.contratoFirmadoResult?.data?.[0] || false);
    }

    get constanciaPago() {
        return (this.constanciaPagoResult?.data?.[0] || false);
    }

    get fichaReserva() {
        return (this.fichaReservaResult?.data?.[0] || false);
    }

    get confirmacion() {
        return (this.confirmacionResult?.data?.[0] || false);
    }
}