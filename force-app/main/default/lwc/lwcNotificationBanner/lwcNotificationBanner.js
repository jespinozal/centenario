import { LightningElement , api, wire} from 'lwc';
import getBannerDetail from '@salesforce/apex/CEN_DebidaDiligencia_ctr.getBannerDetail';

export default class LwcNotificationBanner extends LightningElement {
    @api recordId;
    @wire(getBannerDetail,{idOpportunity:'$recordId'}) banner;

    get message() {
        return 'Advertencia con las siguientes cuentas: ' + this.banner.data;
    }

    get IsDisplay() {
        return this?.banner && this.banner?.data;
    }

}