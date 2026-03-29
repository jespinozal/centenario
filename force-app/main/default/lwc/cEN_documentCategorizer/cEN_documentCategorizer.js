import { LightningElement, api, wire } from 'lwc';
// Añade esta línea al principio de tu archivo
import { NavigationMixin } from 'lightning/navigation';
// Importamos las herramientas para obtener información y valores de picklist
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ADJUNTO_RELACIONADO_OBJECT from '@salesforce/schema/CEN_AdjuntoRelacionado__c';
import TIPO_DOCUMENTO_FIELD from '@salesforce/schema/CEN_AdjuntoRelacionado__c.CEN_TipoDocumentoCaso__c';

export default class DocumentCategorizer extends NavigationMixin(LightningElement) {
    // ENTRADA: Recibe la lista de documentos seleccionados desde el Flow.
    // ENTRADA: Recibe la lista de documentos seleccionados desde el Flow.
    _documents = [];
    @api 
    get documents() {
        return this._documents;
    }
    set documents(data = []) {
        this._documents = data;
        // INICIALIZA la variable de salida con los datos de entrada.
        // Esto asegura que categorizedDocuments siempre tenga la lista completa,
        // incluso antes de que el usuario haga algún cambio.
        this.categorizedDocuments = this._documents;
    }
    
    // SALIDA: Devuelve al Flow la lista de documentos con la categoría ya asignada.
    // Usamos un getter/setter para notificar al flow cuando los datos están listos.
    _categorizedDocuments = [];
    @api 
    get categorizedDocuments() {
        return this._categorizedDocuments;
    }
    set categorizedDocuments(data) {
        this._categorizedDocuments = data;
    }

    picklistOptions = [];
    error;

    // 1. Obtiene información del objeto CEN_AdjuntoRelacionado__c
    @wire(getObjectInfo, { objectApiName: ADJUNTO_RELACIONADO_OBJECT })
    objectInfo;

    // 2. Usa la info anterior para obtener los valores del picklist CEN_TipoDocumentoCaso__c
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIPO_DOCUMENTO_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.picklistOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.picklistOptions = undefined;
        }
    }

    // Se ejecuta cuando el usuario cambia el valor de un picklist
    handleCategoryChange(event) {
        // Obtenemos el ID del documento que se está cambiando y el nuevo valor del picklist
        const documentId = event.target.dataset.id;
        const newCategory = event.detail.value;

        // Creamos una nueva versión del array de documentos con el valor actualizado
        let updatedDocuments = this.documents.map(doc => {
            if (doc.CEN_ID_Original__c === documentId) {
                // Si es el documento correcto, actualizamos su categoría
                return { ...doc, CEN_Categoria_Seleccionada__c: newCategory };
            }
            // Si no, lo dejamos como está
            return doc;
        });

        // Actualizamos la lista interna y la variable de salida para el Flow
        this.documents = updatedDocuments;
        this.categorizedDocuments = updatedDocuments;
    }

    // Se ejecuta cuando el usuario hace clic en el ícono del ojo
    handlePreviewClick(event) {
        // Obtenemos el ID del documento desde el atributo data-id del botón
        const documentId = event.currentTarget.dataset.id;
        
        // Buscamos el registro completo del documento en nuestro array
        const doc = this.documents.find(d => d.CEN_ID_Original__c === documentId);

        if (!doc) {
            // Si por alguna razón no se encuentra el documento, no hacemos nada.
            return;
        }

        // Esta lógica es idéntica a la que ya tienes en tu otra tabla
        if (doc.CEN_Tipo_Documento__c && doc.CEN_Tipo_Documento__c.includes('Adjunto')) {
            // Es un Attachment antiguo. Navegamos a su URL de descarga/vista.
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `/${doc.CEN_ID_Original__c}`
                }
            });
        } else {
            // Es un File moderno (ContentDocument). Usamos el previsualizador estándar.
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    // Pasamos el ID del ContentDocument
                    recordIds: doc.CEN_ID_Original__c
                }
            });
        }
    }
}