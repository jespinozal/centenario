import { LightningElement,api } from 'lwc';
import getListProducts from '@salesforce/apex/ONI_EnviarBrochurePDF_cls.getListProducts';
import generateAndAttachPdfEx from '@salesforce/apex/ONI_EnviarBrochurePDF_cls.generateAndAttachPdfEx';
import sendEmailWithBrochure from '@salesforce/apex/ONI_EnviarBrochurePDF_cls.sendEmailWithBrochure';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ONI_EnviarListaPrecios_lwc extends LightningElement {
    @api recordId;
    PDFButton = true; //flag que desabilita el boton generar brochure
    sendButton = true; //flag que desabilita el boton enviar
    generatedPDF = false; //flag que indica si ya hay brochure generado
    url; //guarda el url del contentVersion (PDF) generado
    cvId; //guarda el id del contentVersion (PDF) generado
    data=[];
    allData=[];
    columns = [
        { label: 'Nombre', fieldName: 'Name' }        
    ];

    async connectedCallback(){
        const lp = await getListProducts({'recordType':'Oficina'});
        console.log(JSON.stringify(lp));
        this.data=lp.slice(0);
        this.allData=lp.slice(0);
    }

    renderedCallback(){

    }

    handlePDF(){
        //this.dispatchEvent(new CloseActionScreenEvent());
        console.log('this.selectedItems',this.selectedItems);

        const _selectedItems = this.selectedItems.map((o)=>o.Id);
        console.log('_selectedItems',_selectedItems);
        console.log('recordId',this.recordId);

        generateAndAttachPdfEx({'id':this.recordId,'idList':_selectedItems})
            .then(result => {
                this.cvId = result;
                this.url = `/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_PDF&versionId=${this.cvId}`;
                console.log('result',this.cvId);
                this.PDFButton = true;
                this.generatedPDF = true;
                this.sendButton = false;
            })
            .catch(error => {
                console.error('error',error);
            });
            
    }
    handleSend(){
        this.dispatchEvent(new CloseActionScreenEvent());
        console.log('this.cvId',this.cvId);
        sendEmailWithBrochure({'id': this.recordId, 'cvId':this.cvId})
            .then(result => {
                console.log('result',result);
            })
            .catch(error => {
                console.error('error',error);
            });
            
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedItems = selectedRows;
        console.log('pp',JSON.stringify(this.selectedItems));
        this.PDFButton = this.selectedItems.length === 0;
    }

    handleFilterChange(event) {
        
        const searchTerm = event.target.value.toLowerCase();
        if (!searchTerm) {
            this.filteredData = this.allData; // Show all data if search term is empty
            return;
        }

        this.data = this.allData.filter(row => {
            // Iterate over all fields in the row to check for a match
            return Object.values(row).some(value =>
                String(value).toLowerCase().includes(searchTerm)
            );
        });
        
    }

}