/**
 * @name               : 
 * @author             : Diego Bravo
 * @creation date      : 
 * @modification date  : 15-10-2024
 * @last modified by   : Diego Bravo
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   13-08-2024   Diego Bravo   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/CEN_PreviewAndDownloadController.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation';

export default class CEN_PreviewAndDownloadResolucion extends NavigationMixin(LightningElement) {

    @api recordIdValue;
    @api documenType;
    @api resolucionEspecial;
    @api iteracion;
    filesList =[]
    
    @wire(getRelatedFilesByRecordId, {recordId: '$recordIdValue', tipoDocumento: '$documenType', resolucionEspecial: '$resolucionEspecial', iteracion: '$iteracion'})
    wiredResult({data, error}){
        console.log('RecordId',this.recordId);
        console.log('Tipo documento', this.documenType);
        if(data){
            console.log(data)
            this.filesList = Object.keys(data).map(item=>({
                "label":data[item],
                "value": item,
                "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if(error){
            console.log(error)
        }
    }

    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }

	
}