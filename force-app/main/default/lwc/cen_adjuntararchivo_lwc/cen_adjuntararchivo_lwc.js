/**
 * @description       Componente LWC para adjuntar archivos a un registro.
 * Utiliza el componente estándar 'lightning-file-upload' para soportar archivos grandes
 * y luego llama a Apex para crear un registro personalizado de relación.
 * @author            Jose Miguel Espinoza Mestanza
 * @email             josemiguel.espinozamestanza@emeal.nttdata.com
 * @version           2.0
 */

// --- IMPORTACIONES ---
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

// --> PASO 1: Importar lo necesario para Lightning Message Service (LMS)
import { publish, MessageContext } from 'lightning/messageService';
import ADJUNTOS_CHANNEL from '@salesforce/messageChannel/cenadjuntos__c';

// Importación del esquema para evitar errores de escritura y asegurar la referencia al objeto/campos.
import CEN_ADJUNTO_RELACIONADO_OBJECT from '@salesforce/schema/CEN_AdjuntoRelacionado__c';
import TIPO_DOCUMENTO_CASO_FIELD from '@salesforce/schema/CEN_AdjuntoRelacionado__c.CEN_TipoDocumentoCaso__c';

// Importación del nuevo y simplificado método de Apex.
import crearRegistroAdjunto from '@salesforce/apex/CEN_AdjuntarArchivoController.crearRegistroAdjunto';

export default class Cen_adjuntararchivo_lwc extends LightningElement {

    // --- PROPIEDADES PÚBLICAS Y PRIVADAS ---

    /**
     * @description El ID del registro actual (ej. un Caso) donde se encuentra el componente.
     * Se recibe automáticamente desde la página de registro.
     * @type {string}
     */
    @api recordId;

    /**
     * @description Almacena el valor seleccionado por el usuario en el combobox de "Tipo de documento".
     * @type {string}
     */
    @track selectedTipoDocumento = '';

    /**
     * @description Lista que contendrá los valores del picklist para mostrarlos en el combobox.
     * @type {Array}
     */
    @track picklistOptions = [];

    // --> PASO 2: "Conectar" el componente al contexto de mensajería de LWC.
    @wire(MessageContext)
    messageContext;

    // --- SERVICIOS WIRE PARA OBTENER DATOS DE SALESFORCE ---

    // Wire para obtener información del objeto, necesario para obtener el RecordTypeId por defecto.
    @wire(getObjectInfo, { objectApiName: CEN_ADJUNTO_RELACIONADO_OBJECT })
    objectInfo;

    // Wire que obtiene los valores del picklist 'CEN_TipoDocumentoCaso__c'.
    // Se ejecuta automáticamente cuando la información del objeto (objectInfo) está disponible.
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TIPO_DOCUMENTO_CASO_FIELD
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            // Mapea los datos recibidos al formato que necesita lightning-combobox ({label: 'Label', value: 'Value'}).
            this.picklistOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error al obtener valores del picklist:', error);
            this.showToast('Error', 'No se pudieron cargar los tipos de documento.', 'error');
        }
    }

    // --- MANEJADORES DE EVENTOS ---

    /**
     * @description Se ejecuta cada vez que el usuario cambia la selección en el combobox.
     * @param {Event} event - El evento 'change' del combobox.
     */
    handlePicklistChange(event) {
        this.selectedTipoDocumento = event.detail.value;
    }

    /**
     * @description ¡Función Clave! Se ejecuta cuando 'lightning-file-upload' ha terminado de subir el archivo.
     * @param {Event} event - El evento 'uploadfinished' que contiene los detalles del archivo subido.
     */
    async handleUploadFinished(event) {
        // Obtenemos la lista de archivos subidos (normalmente será solo uno).
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            const documentId = uploadedFiles[0].documentId;
            const fileName = uploadedFiles[0].name;

            try {
                // Llamamos al método de Apex, pasándole solo los metadatos.
                // Ya no enviamos el contenido del archivo.
                await crearRegistroAdjunto({
                    caseId: this.recordId,
                    contentDocumentId: documentId,
                    tipoDeDocumento: this.selectedTipoDocumento,
                    fileName: fileName
                });
                
                this.showToast('Éxito', `'${fileName}' adjuntado correctamente.`, 'success');

                // --> PASO 3: Crear y publicar el mensaje DESPUÉS de que todo haya salido bien.
                const payload = { 
                    recordId: this.recordId,
                    tipoDocumento: this.selectedTipoDocumento,
                    accion: 'archivoSubido' // Puedes usar esto para diferentes tipos de notificaciones.
                };

                // Publica el mensaje en el canal. Cualquier componente que esté suscrito reaccionará.
                publish(this.messageContext, ADJUNTOS_CHANNEL, payload);
                
                this.resetForm();

            } catch (error) {
                // Muestra un error detallado si la creación del registro personalizado falla.
                console.error('Error al crear registro de adjunto:', error);
                const msg = (error && error.body && error.body.message) ? error.body.message : 'Error desconocido';
                this.showToast('Error', 'Error al crear el registro adjunto: ' + msg, 'error');
            }
        }
    }
    
    // --- MÉTODOS DE AYUDA (HELPERS) ---

    /**
     * @description Limpia el valor del combobox para permitir una nueva carga.
     */
    resetForm() {
        this.selectedTipoDocumento = '';
    }

    /**
     * @description Muestra una notificación (toast) en la pantalla.
     * @param {string} title - El título de la notificación.
     * @param {string} message - El mensaje de la notificación.
     * @param {string} variant - El estilo ('success', 'error', 'warning', 'info').
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    // --- GETTERS (PROPIEDADES CALCULADAS) ---

    /**
     * @description Getter que deshabilita el componente de carga si el usuario no ha seleccionado
     * un tipo de documento. Esto asegura que todos los archivos estén clasificados.
     * @returns {boolean}
     */
    get isUploadDisabled() {
        return !this.selectedTipoDocumento;
    }
}