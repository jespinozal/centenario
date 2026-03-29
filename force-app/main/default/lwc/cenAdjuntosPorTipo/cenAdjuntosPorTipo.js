import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import ADJUNTOS_CHANNEL from '@salesforce/messageChannel/cenadjuntos__c';
import { refreshApex } from '@salesforce/apex';
import obtenerAdjuntosPorCasoYSeccion from '@salesforce/apex/CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCasoYSeccion';

/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class Cen_AdjuntosPorTipo_lwc extends LightningElement {
    @api recordId;
    @api nombreSeccion;
    @api esArchivado = false;

    grupos = [];
    subscription = null;
    wiredSeccion;
    @wire(MessageContext) messageContext;

    @wire(obtenerAdjuntosPorCasoYSeccion, { caseId: '$recordId', seccion: '$nombreSeccion', esArchivado: '$esArchivado' })
    procesar(result) {
        this.wiredSeccion = result;
        const { data, error } = result;
        if (data) {
            this.construirGrupos(data);
        } else if (error) {
            console.error(error);
            this.grupos = [];
        }
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            ADJUNTOS_CHANNEL,
            (message) => this.manejarMensaje(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    get tituloHeader() {
        return this.nombreSeccion || 'Adjuntos';
    }
    get hayGrupos() {
        return Array.isArray(this.grupos) && this.grupos.length > 0;
    }

    construirGrupos(lista) {
        const mapa = lista.reduce((acc, adj) => {
            const tipo = adj.CEN_TipoDocumentoCaso__c || 'Sin Tipo';
            (acc[tipo] = acc[tipo] || []).push(adj);
            return acc;
        }, {});
        this.grupos = Object.keys(mapa).map(tipo => ({
            nombreGrupo: tipo,
            adjuntos: mapa[tipo]
        }));
    }

    async manejarMensaje(message) {
        try {
            if (!message || message.recordId !== this.recordId) return;
            if (this.wiredSeccion) await refreshApex(this.wiredSeccion);
        } catch (e) {
            console.error('Error al manejar mensaje LMS:', e);
        }
    }
}