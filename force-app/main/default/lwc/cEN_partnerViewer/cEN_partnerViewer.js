import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunityPartners from '@salesforce/apex/CEN_PartnerController.getOpportunityPartners';

export default class Cen_partnerViewer extends NavigationMixin(LightningElement) {

    @api recordId;
    @track processedPartners = [];
    opportunityId;
    error;
    isLoading = true;

    @wire(getOpportunityPartners, { caseId: '$recordId' })
    wiredResult({ error, data }) {
        if (data) {
            this.opportunityId = data.opportunityId; // Guardamos el ID de la Oportunidad
            
            // Generamos la URL para cada partner
            Promise.all(
                data.partners.map(partner => this.generatePartnerUrl(partner))
            ).then(results => {
                this.processedPartners = results;
                this.error = undefined;
            }).catch(err => {
                this.error = err;
            }).finally(() => {
                this.isLoading = false;
            });
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    // NAVEGACIÓN: Manejador para el enlace "Ver Todos"
    handleViewAllClick(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'Opportunity',
                relationshipApiName: 'OpportunityPartners', // Relación estándar de Partners
                actionName: 'view'
            }
        });
    }
    
    // NAVEGACIÓN: Manejador para el clic en el nombre del partner
    handleNavigate(event) {
        event.preventDefault();
        const url = event.currentTarget.href;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: url }
        });
    }

    // TÍTULO: Crea el título dinámico con el contador
    get cardTitle() {
        const count = this.processedPartners.length;
        return `Partners (${count})`;
    }

    // UTILIDAD: Devuelve true si hay partners
    get hasPartners() {
        return !this.isLoading && this.processedPartners && this.processedPartners.length > 0;
    }
    
    // UTILIDAD: Genera la URL para cada Partner
    generatePartnerUrl(partner) {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: partner.accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        };
        return this[NavigationMixin.GenerateUrl](pageRef).then(url => {
            return { ...partner, accountUrl: url };
        });
    }
}