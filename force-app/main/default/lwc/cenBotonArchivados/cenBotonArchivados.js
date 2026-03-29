import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const CAMPOS_USUARIO = ['User.Profile.Name'];
/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class CenBotonArchivados extends LightningElement {
    @api recordId;
    @track mostrarModal = false;
    profileName;
    @wire(getRecord, { recordId: USER_ID, fields: CAMPOS_USUARIO })
    wiredUsuario({ data, error }) {
        if (data) {
            this.profileName =
                data.fields?.Profile?.displayValue ||
                data.fields?.Profile?.value?.fields?.Name?.value ||
                null;
        } else if (error) {
            this.profileName = null;
        }
    }
    get puedeVerBoton() {
        return this.profileName === 'CEN_Administrador_de_ventas_urbano';
    }

    abrirModal() { this.mostrarModal = true; }
    cerrarModal() { this.mostrarModal = false; }

    get esArchivadoTrue() { return true; }
}