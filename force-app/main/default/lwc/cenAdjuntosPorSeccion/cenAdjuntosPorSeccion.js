import { LightningElement, api } from 'lwc';

/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class CenAdjuntosPorSeccion extends LightningElement {
    @api recordId;
    @api header = 'Documentos por sección';
    @api esArchivado = false;
    secciones = ['Adjuntos','Contratos','Documentos Firmados'];

    activeSections = [];

    handleSectionToggle(event) {
        this.activeSections = event.detail.openSections;
    }
}