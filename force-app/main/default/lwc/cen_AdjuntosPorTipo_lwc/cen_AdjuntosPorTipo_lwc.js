import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import ADJUNTOS_CHANNEL from '@salesforce/messageChannel/cenadjuntos__c';
import { refreshApex } from '@salesforce/apex';
import obtenerAdjuntosPorCaso from '@salesforce/apex/CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCaso';
import obtenerAdjuntosPorCasoYTipo from '@salesforce/apex/CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCasoYTipo';
/*
Developer: Jose Miguel Espinoza Mestanza
Email: josemiguel.espinozamestanza@emeal.nttdata.com
*/
export default class Cen_AdjuntosPorTipo_lwc extends LightningElement {
    @api recordId; 
    grupos = [];
    subscription = null;
    wiredResult;
    @wire(MessageContext) messageContext;
    @wire(obtenerAdjuntosPorCaso, { caseId: '$recordId' })
    procesar(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.construirGrupos(data);
        } else if (error) {
            console.error(error);
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
    construirGrupos(lista) {
        const mapa = lista.reduce((acc, adj) => {
            const tipo = adj.CEN_TipoDocumentoCaso__c || 'Sin Tipo';
            (acc[tipo] = acc[tipo] || []).push(adj);
            return acc;
        }, {});
        this.grupos = Object.keys(mapa).map((tipo) => ({
            nombreGrupo: `${tipo}`,
            adjuntos: mapa[tipo]
        }));
    }
    async manejarMensaje(message) {
        try {
            if (!message || message.recordId !== this.recordId) return;
            if (message.accion === 'archivoSubido' && message.tipoDocumento) {
                await this.refrescarSoloTipo(message.tipoDocumento);
                return;
            }
            await refreshApex(this.wiredResult);
        } catch (e) {
            console.error('Error al manejar mensaje LMS:', e);
            if (this.wiredResult) {
                await refreshApex(this.wiredResult);
            }
        }
    }
    async refrescarSoloTipo(tipo) {
        try {
            const nuevosAdjuntos = await obtenerAdjuntosPorCasoYTipo({
                caseId: this.recordId,
                tipoDocumento: tipo
            });
            const idx = this.grupos.findIndex(g => g.nombreGrupo === tipo);
            if (idx >= 0) {
                const copia = [...this.grupos];
                copia[idx] = { ...copia[idx], adjuntos: [...nuevosAdjuntos] };
                this.grupos = copia;
            } else {
                this.grupos = [...this.grupos, { nombreGrupo: tipo, adjuntos: [...nuevosAdjuntos] }];
            }
        } catch (e) {
            console.warn('No se pudo refrescar solo el tipo. Se hará refresh global.', e);
            if (this.wiredResult) {
                await refreshApex(this.wiredResult);
            }
        }
    }
}