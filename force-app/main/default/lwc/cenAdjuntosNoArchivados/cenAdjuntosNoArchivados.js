import { LightningElement, api } from 'lwc';
/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class CenAdjuntosNoArchivados extends LightningElement {
    @api recordId;
    header = 'Documentos por sección';
    esArchivado = false;
}