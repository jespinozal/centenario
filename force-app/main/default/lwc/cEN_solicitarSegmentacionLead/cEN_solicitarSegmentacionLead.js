/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 15-01-2025
 * @last modified by   : Jesus Poco
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   13-01-2025   Luis Maldonado   Initial Version
 * 1.0   13-03-2025   Jesus Poco       Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import segmentacionLeadApi from '@salesforce/apex/CEN_SendLeadSegmentation.SegmentacionLeadApi';
import validarDni from '@salesforce/apex/CEN_SendLeadSegmentation.validarDni';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CEN_solicitarSegmentacionLead extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track responseMessage;
    @track isButtonDisabled = true; // Botón deshabilitado por defecto hasta validar estado
    
    connectedCallback() {
        // Verificar si el botón debe habilitarse al cargar el componente
        this.checkDniVisibility();
    }

    handleClick() {
        this.isLoading = true;
        this.isButtonDisabled = true; // Deshabilitar inmediatamente al hacer clic
        this.responseMessage = '';  
        console.log('Solicitando segmentación para Lead: ' + this.recordId);

        segmentacionLeadApi({ leadId: this.recordId })
            .then((result) => {
                console.log('Respuesta del servicio:', result);
                this.responseMessage = `Código de operación: ${result.codigoOperacion} - Glosa: ${result.glosaOperacion}`;
                if (result.codigoOperacion === '00') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Éxito',
                            message: 'Segmentación enviada correctamente',
                            variant: 'success',
                        })
                    );
                    // Recargar la página tras éxito para reflejar cambios
                    this.dispatchEvent(new CustomEvent('refreshview'));
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'No se pudo enviar la segmentación. Reintente.',
                            variant: 'error',
                        })
                    );
                    this.checkDniVisibility(); // Re-verificar estado tras fallo
                }
            })
            .catch((error) => {
                console.error('Error al llamar al servicio:', error);
                this.responseMessage = 'Ocurrió un error al solicitar la segmentación';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al procesar la solicitud',
                        variant: 'error',
                    })
                );
                this.checkDniVisibility(); // Re-verificar estado tras error
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    checkDniVisibility() {
        validarDni({ idLead: this.recordId })
            .then((result) => {
                this.isButtonDisabled = !result; // Habilitar si validarDni retorna true (fallo en envío o error en segmentación)
                console.log('Estado del botón: ' + (this.isButtonDisabled ? 'Deshabilitado' : 'Habilitado'));
            })
            .catch((error) => {
                console.error('Error al validar el estado: ', error);
                this.isButtonDisabled = true; // Deshabilitar por defecto si hay error
            });
    }
}