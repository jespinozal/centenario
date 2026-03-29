import { LightningElement, api, track } from 'lwc';
import fetchLeads from '@salesforce/apex/CEN_LeadHistory_ctr.fetchLeads';

const COLUMNS_BASIC = [
    {title: 'Proyecto', label: 'Proyecto', estilo: 'width:300px;'},
    {title: 'Fecha', label: 'Fecha', estilo: 'width:80px;'},
    {title: 'Propietario', label: 'Propietario'},
    {title: 'Tipología', label: 'Tipología'},
    {title: 'Intentos', label: 'Intentos', estilo: 'width:100px;'},
    {title: 'Estado', label: 'Estado'},
    {title: 'Lead', label: 'Nombre Prospecto'}
];

const COLUMNS_DETAIL = [
    {title: 'Evento', label: 'Evento', icon: '/_slds/icons/standard-sprite/svg/symbols.svg#event'},
    {title: 'Fecha', label: 'Fecha', estilo: 'width:80px;'},
    {title: 'Estado', label: 'Estado'},
    {title: 'Contacto', label: 'Contacto'},
    {title: 'Valores Contacto', label: 'Valores Contacto'},
    {title: 'Asunto', label: 'Asunto'}
];

export default class LwcTreeGrid extends LightningElement {

    @api recordId;
    lstLeads;
    @track eventos;
    @track hasRendered = true;
    descripcion;

    lstCol = COLUMNS_BASIC;
    lstColDet = COLUMNS_DETAIL;

    connectedCallback(){
        fetchLeads({ recordId: this.recordId})
        .then((response) => {
            this.lstLeads = response;
            if(this.lstLeads){
                this.lstLeads = response.map((ld) => {
                    const lead = {...ld};
                    lead.LeadURL = '/lightning/r/Lead/' + ld.id +'/view';
                    switch(ld.estado){
                        case 'No contactado':
                            lead.StatusColor = "slds-truncate slds-text-color_error";
                            break;
                        case 'Contactado':
                            lead.StatusColor = "slds-truncate slds-text-color_default";
                            break;
                        default:
                            lead.StatusColor = "slds-truncate slds-text-color_success";
                    }
                    return lead;
                });
            }
        }).catch((error) => {
            console.table(error);
        });
    }

    handleLeadChange(e){
        let id = e.currentTarget.dataset.id;
        console.log(id);
        let list = this.lstLeads;
        const newList = list.map(item => {
            if(id === item.id){
                item.active = item.active ? false : true;
            }
            return item;
        })

        this.lstLeads = newList;
        console.log(newList);
    }

    handleMouse(e){
        let id = e.currentTarget.dataset.id;

        let list = this.lstLeads;
        const newList = list.map(item => {
            if(item.eventos != null){
                item.eventos.map(subItem => {
                    if(id === subItem.id){
                        this.descripcion = subItem.descripcion;
                    }
                    return subItem;
                })
            }
            return item;
        })

    }

    handleMouseOut(e){
        let id = e.currentTarget.dataset.id;
        this.descripcion = '';
    }

}