import { LightningElement, api, track,wire } from 'lwc';
import updateOpByProyectoId from '@salesforce/apex/CEN_UpdateFechaEntregaProyectoLotes.updateOpByProyectoId';
import validarEstadoProyecto from '@salesforce/apex/CEN_UpdateFechaEntregaProyectoLotes.validarEstadoProyecto';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CEN_ESTADO_PROYECTO_FIELD from '@salesforce/schema/Proyecto__c.CEN_Estado_proyecto__c'; 

export default class CEN_UpdateFechaEntregaProyectoLotes extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track isButtonDisabled = true;

    // Escuchar cambios en el campo CEN_Estado_proyecto__c
    @wire(getRecord, { recordId: '$recordId', fields: [CEN_ESTADO_PROYECTO_FIELD] })
    proyecto({ error, data }) {
        if (data) {
            // Cuando el registro cambia, volver a verificar el estado con Apex
            this.checkBtnUpdateOppVisibility();
        } else if (error) {
            console.error('Error al obtener el registro: ', error);
            this.isButtonDisabled = true; // Deshabilitar por defecto si hay error
        }
    }

    @wire(CurrentPageReference)
    setRecordId({ attributes }) {
        if (attributes?.recordId) {
            this.recordId = this.recordId || attributes.recordId;
        }
    }

    connectedCallback() {
        // Verificar el estado inicial del botón
        this.checkBtnUpdateOppVisibility();
    }

    checkBtnUpdateOppVisibility() {
        if (this.recordId) {
            validarEstadoProyecto({ idProyecto: this.recordId })
                .then((result) => {
                    this.isButtonDisabled = !result; // Habilitar o deshabilitar según la respuesta de Apex
                    console.log('Estado del botón: ' + (this.isButtonDisabled ? 'Deshabilitado' : 'Habilitado'));
                })
                .catch((error) => {
                    console.error('Error al validar el estado: ', error);
                    this.isButtonDisabled = true; // Deshabilitar por defecto si hay error
                });
        }
    }

    handleClick() {
        if (!this.recordId) {
            this.showToast('Error', 'No se proporcionó un ID de proyecto válido.', 'error');
            return;
        }

        this.isLoading = true;
        this.isButtonDisabled = true;

        updateOpByProyectoId({ idProyecto: this.recordId })
            .then((result) => {
                const variant = result.includes('Se actualizaron las oportunidades') ? 'success' : 'warning';
                this.showToast(variant.charAt(0).toUpperCase() + variant.slice(1), result, variant);
                if (variant === 'success') {
                    this.dispatchEvent(new RefreshEvent());
                }
            })
            .catch((error) => {
                const errorMessage = error.body?.message || error.message;
                this.showToast('Error', `Error al procesar la solicitud: ${errorMessage}`, 'error');
            })
            .finally(() => {
                this.isLoading = false;
                // Volver a verificar el estado del botón después de la acción
                this.checkBtnUpdateOppVisibility();
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}