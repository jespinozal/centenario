import { api, LightningElement, track, wire } from 'lwc';
import getQuote from '@salesforce/apex/ONI_Cotizador_cls.getQuote';

export default class LwcONI_Products_From_QuoteLineItem extends LightningElement {
    // @api quoteId;
    @api idprueba;
    @track _quoteId = '';

    @api
    get quoteId() {
        return this._quoteId;
    }
    set quoteId(id) {
        this._quoteId = id;
    }

    data = [];
    columns = [
        { label: 'Terrenos seleccionados', fieldName: 'productName', initialWidth:300 },
        { label: 'Costo Unit.', fieldName: 'productCostoUnit', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumFractionDigits: 2 } },
        { label: 'Area', fieldName: 'productArea', cellAttributes: { alignment: 'right' } },
        { label: 'Total', fieldName: 'precioVenta', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumFractionDigits: 2 }  },
    ];

    connectedCallback() {
        getQuote({ opportunityId: this.idprueba })
            .then(result => {
                this.data = result.map(item => {
                    const productName = item.Product2 ? item.Product2.Name : '';
                    const productArea = item.Product2?.AREA__c;
                    const productCostoUnit = item.Product2?.ONI_fld_Producto_PrecioM2__c;
                    const precioVenta = item.Product2?.CEN_PRECIOVENTAFUN__c;
                    return {
                        Id: item.quoteId,
                        productName,
                        productArea,
                        productCostoUnit,
                        precioVenta
                    }
                });
            })
            .catch(error => {
                console.log("ERROR: ", error)
            })
    }
}