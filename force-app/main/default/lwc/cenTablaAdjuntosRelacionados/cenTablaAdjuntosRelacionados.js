import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import ADJUNTOS_CHANNEL from '@salesforce/messageChannel/cenadjuntos__c';
import CEN_ADJ from '@salesforce/schema/CEN_AdjuntoRelacionado__c';
import TIPO_DOC from '@salesforce/schema/CEN_AdjuntoRelacionado__c.CEN_TipoDocumentoCaso__c';
import ESTADO_DOC from '@salesforce/schema/CEN_AdjuntoRelacionado__c.CEN_EstadoDocumento__c';
import ID_FIELD from '@salesforce/schema/CEN_AdjuntoRelacionado__c.Id';
/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class CenTablaAdjuntosRelacionados extends LightningElement {
    @api recordId;
    @wire(MessageContext) messageContext;
    @api nombreGrupo;
    get placeholderTipo() {
        return this.nombreGrupo || 'Seleccione tipo...';
    }
    _adjuntos = [];
    @api
    get adjuntos() {
        return this._adjuntos;
    }
    set adjuntos(value) {
        const arr = Array.isArray(value) ? value : [];
        this._adjuntos = arr.map(a => this.decorateRow(a));
        if (this.picklistLoaded) {
            this.originalAdjuntos = JSON.parse(JSON.stringify(this._adjuntos));
        }
    }

    picklistOptions = [];
    picklistOptionsEstado = [];
    picklistLoaded = false;
    loadedTipo = false;
    loadedEstado = false;
    originalAdjuntos = [];
    changedRecords = new Map();

    @wire(getObjectInfo, { objectApiName: CEN_ADJ }) info;

    @wire(getPicklistValues, {
        recordTypeId: '$info.data.defaultRecordTypeId',
        fieldApiName: TIPO_DOC
    })
    wireTipo({ data, error }) {
        if (data) { 
            this.picklistOptions = data.values;
            this.loadedTipo = true;
            this.checkLoaded();
        } else if (error) {
            console.error(error);
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$info.data.defaultRecordTypeId',
        fieldApiName: ESTADO_DOC
    })
    wireEstado({ data, error }) {
        if (data) {
            this.picklistOptionsEstado = data.values;
            this.loadedEstado = true;
            this.checkLoaded();
        } else if (error) {
            console.error(error);
        }
    }
    checkLoaded() {
        if (this.loadedTipo && this.loadedEstado) {
            this.picklistLoaded = true;
            this.originalAdjuntos = JSON.parse(JSON.stringify(this._adjuntos));
        }
    }
    decorateRow(a) {
        const disabled = !!(a.CEN_Migrado__c);
        const rowClass = disabled ? 'slds-hint-parent slds-text-color_weak' : (a.hasChanges || '');
        const urlRegistro = `/lightning/r/CEN_AdjuntoRelacionado__c/${a.Id}/view`;
        return { ...a, _disabled: disabled, rowClass, urlRegistro };
    }

    handleFieldChange(event) {
        const recordId = event.target.dataset.id;
        const fieldName = event.target.dataset.field;
        const fila = this._adjuntos.find(x => x.Id === recordId);
        if (fila?._disabled) {
            this.showToast('Bloqueado', 'No se puede editar un registro Archivado o Migrado.', 'warning');
            return;
        }
        let newValue;
        if (event.target.type === 'checkbox') {
            newValue = event.target.checked;
        } else {
            newValue = event.detail.value || event.target.value;
        }

        this._adjuntos = this._adjuntos.map(adj => {
            if (adj.Id !== recordId) return adj;

            const provisional = { ...adj, [fieldName]: newValue };
            const willBeDisabled =
                !!(provisional.CEN_Migrado__c);

            const updated = {
                ...provisional,
                hasChanges: 'slds-hint-parent has-changes',
                _disabled: willBeDisabled,
                rowClass: willBeDisabled ? 'slds-hint-parent slds-text-color_weak' : 'slds-hint-parent has-changes'
            };
            return updated;
        });
        this._adjuntos = [...this._adjuntos];

        if (!this.changedRecords.has(recordId)) {
            this.changedRecords.set(recordId, { Id: recordId });
        }
        this.changedRecords.get(recordId)[fieldName] = newValue;

        console.log('Registros con cambios:', [...this.changedRecords.values()]);
    }

    get hasChanges() {
        return this.changedRecords.size > 0;
    }

    async guardar() {
        if (this.changedRecords.size === 0) {
            this.showToast('Advertencia', 'No hay cambios para guardar', 'warning');
            return;
        }

        try {
            const updatePromises = [...this.changedRecords.values()].map(changes => {
                const fields = {};
                Object.keys(changes).forEach(key => {
                    if (key === 'Id') {
                        fields[ID_FIELD.fieldApiName] = changes[key];
                    } else {
                        fields[key] = changes[key];
                    }
                });
                return updateRecord({ fields });
            });

            await Promise.all(updatePromises);
            this.showToast('Éxito', `${this.changedRecords.size} registro(s) actualizado(s)`, 'success');

            this.changedRecords.clear();
            this._adjuntos = this._adjuntos.map(a => this.decorateRow({ ...a, hasChanges: '' }));
            this.originalAdjuntos = JSON.parse(JSON.stringify(this._adjuntos));
            publish(this.messageContext, ADJUNTOS_CHANNEL, {
                recordId: this.recordId,
                accion: 'tipoDocumentoActualizado'
            });
        } catch (error) {
            console.error('Error al actualizar:', error);
            this.showToast('Error', 'Error al actualizar: No tiene Permisos necesarios para realizar esta acción', 'error');
        }
    }

    cancelar() {
        this.adjuntos = JSON.parse(JSON.stringify(this.originalAdjuntos));
        this.changedRecords.clear();
        this.showToast('Info', 'Cambios cancelados', 'info');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}