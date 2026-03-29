import ONI_cls_Product2_GetProducts from '@salesforce/apex/ONI_cls_Product2_GetProducts.ONI_cls_Product2_GetProducts';
import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import linkImageToProduct from '@salesforce/apex/ONI_cls_ContentVersion_SaveImgToProduct2.linkImageToProduct';

const actions = [
    { label: 'Seleccionar', name: 'select' }
];
const columns = [
    { label: 'Nombre del Producto', fieldName: 'Name' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

export default class LwcONI_ShowProducts extends LightningElement {
    @api myRecordId;

    @track data = [];
    @track columns = columns;
    @track selectedProduct = null;
    @track selectedProductId = null;
    @track uploadedFileId = null;
    @track imageUrl = null;
    @track error;  // AGREGADO: Para mostrar errores
    @track uploaderKey = 0;

    connectedCallback() {
        this.loadProducts();
    }

    loadProducts() {
        ONI_cls_Product2_GetProducts()
            .then(result => {
                this.data = result || [];  // AGREGADO: Fallback si null
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error cargando productos:', error);
                this.error = reduceErrors(error) || 'Error desconocido al cargar productos.';
                this.showToast('Error', this.error, 'error');
            });
    }

    // CAMBIO: Envuelve en try-catch y agrega logs/validaciones
    handleRowAction(event) {
        try {
            //console.log('Evento rowaction completo:', event.detail);  // AGREGADO: Log completo
            const action = event.detail.action;
            const row = event.detail.row;

            if (!action || !row) {
                throw new Error('Acción o fila no válida');
            }

            //console.log('Acción:', action.name, 'Fila:', row);  // AGREGADO: Log específico

            if (action.name === 'select') {
                if (!row.Id || !row.Name) {
                    throw new Error('El producto no tiene Id o Name válido');
                }
                this.selectedProduct = row;
                this.selectedProductId = row.Id;
                this.resetImageState();
                this.showToast('Éxito', `Producto seleccionado: ${row.Name}`, 'success');
            }
        } catch (error) {
            console.error('Error en handleRowAction:', error);  // AGREGADO: Catch y log
            this.error = error.message || 'Error al seleccionar producto.';
            this.showToast('Error', this.error, 'error');
        }
    }

    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }

    get allowMultiple() {
        return false;
    }

    get hideCheckbox() {
        return true;
    }

    get isUploadDisabled() {
        return !this.selectedProductId;
    }

    get saveDisabled() {
        return !this.uploadedFileId || !this.selectedProductId;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles && uploadedFiles.length > 0) {
            const file = uploadedFiles[0];

            // ID del ContentVersion (no del Document)
            const contentVersionId = file.contentVersionId;
            this.uploadedFileId = file.documentId; // para vincular

            // URL CORRECTA para previsualización en <img>
            this.imageUrl = `/sfc/servlet.shepherd/version/download/${contentVersionId}`;

            this.showToast('Imagen subida', 'Previsualización disponible.', 'success');
        }
    }

    async handleSave() {
        if (!this.selectedProductId || !this.uploadedFileId) return;

        try {
            console.log("LINKER: ", this.uploadedFileId, this.selectedProduct)
            await linkImageToProduct({
                contentDocumentId: this.uploadedFileId,
                productId: this.selectedProductId
            });
            this.showToast('Éxito', 'Imagen asignada al producto correctamente.', 'success');
            this.resetImageState();
        } catch (error) {
            console.error('Error guardando:', error);
            this.showToast('Error', reduceErrors(error) || error.body?.message || 'Error al guardar.', 'error');
        }
    }

    resetImageState() {
        this.uploadedFileId = null;
        this.imageUrl = null;
        this.uploaderKey = Date.now();
    }

    showToast(title, message, variant) {
        try {
            const toast = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toast);
        } catch (e) {
            console.error('Error mostrando toast:', e);  // AGREGADO: Fallback si toast falla
        }
    }
}