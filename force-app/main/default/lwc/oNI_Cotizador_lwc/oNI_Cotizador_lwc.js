import fetchAccountWrapper from '@salesforce/apex/CEN_cls_VisorLote_2.fetchAccountWrapper';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import CEN_CODIGOSAP__c from '@salesforce/schema/Proyecto__c.CEN_CODIGOSAP__c';
import QUOTE_OBJECT from '@salesforce/schema/Quote';
import OPPORTUNITY_FIELD from '@salesforce/schema/Quote.OpportunityId';
import NAME_FIELD from '@salesforce/schema/Quote.Name';
import save from '@salesforce/apex/ONI_Cotizador_cls.save';
import getOffice from '@salesforce/apex/ONI_Cotizador_cls.getOffice';
import getQuote from '@salesforce/apex/ONI_Cotizador_cls.getQuote';
import getIndustrial from '@salesforce/apex/ONI_Cotizador_cls.getIndustrial';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Opportunity.RecordType.Name';
import LEAD_RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Lead.RecordType.Name';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import TYPE_FIELD from '@salesforce/schema/Product2.ONI_fld_Product_TipoObjetoAlquiler__c';
import TotalAmount from '@salesforce/schema/Order.TotalAmount';
import getCustomSetting from '@salesforce/apex/ONI_Cotizador_cls.getCustomSetting';
import blanco from '@salesforce/resourceUrl/blanco';
import getConfiguration from '@salesforce/apex/ONI_Cotizador_cls.getConfiguration';
import getRecordTypeName from '@salesforce/apex/ONI_Cotizador_cls.getRecordTypeName';


const FIELDS = [CEN_CODIGOSAP__c];

export default class ONI_Cotizador_lwc extends LightningElement {
    @api recordId;
    @api isEmbedded = false;
    isModalOpen = false;
    selectedRecordId;
    codigoSAP;
    data = [];
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalRecords = 0;
    @track totalPages = 0;

    @track stage = 1;

    @track preSelectedRows = [];
    @track preSelectedRowsData = [];

    @track preSelectedCondRows = [];
    @track preSelectedCondRowsData = [];

    @track draftValues = [];
    @track draftValuesConditions = [];

    @track totalPayment = 0.0;
    @track directPayment = 0.0;
    @track chunkPayment = 0.0;
    @track installmentPayment = 0.0;
    @track milestonePayment = 0.0;

    @track installmentNumber = undefined;

    @track isOffice;
    @track isIndustrial;

    @track psie = false;
    @track pme = true;
    @track pcde = false;
    @track hie = false;
    @track input_psie = true;
    @track input_pme = false;
    @track input_pcde = true;
    @track input_hie = true;

    @track nextableT = false;

    @track activeSections = [];

    didRun = true;
    typeSale = 'CO'//Contado

    selectedIndustry = '';

    isFinanced = false;

    pathSelector = 0;
    path = [
        [1, 2, 3, 7, 8, 9],
        [1, 2, 7, 3, 8, 9],
    ];
    @track calculatorData = {};
    miAmount = 0.0

    directPaymentPer = 10.0;
    installmentPaymentPer = 0.0;
    chunkPaymentPer = 0.0;
    milestonePaymentPer = 0.0;

    // Reactive property to hold the combobox options
    industryOptions = [
        { label: 'Oficina', value: '1' },
        { label: 'Estacionamiento', value: '5' },
        { label: 'Local Comercial', value: '2' },
        { label: 'Depósito', value: '4' },
    ];

    csx;
    conf;

    ofiFilter = {
        criteria: [
           
            {
                fieldPath: 'CEN_Tipo_de_proyecto__c',
                operator: 'eq',
                value: 'Oficina'
            }
        ],
        //filterLogic: '1 AND 2' // Optional: default is AND
    };

    get pathol() {
        return this.path[this.pathSelector];
    }

    paymentChangeName;

    @track milestoneList = [];
    @track installmentList = [];


    get totalPaymentPer(){
        return this.isFinanced?((this.input_pme == false ? Number(this.directPaymentPer) : 0) + (this.input_pcde == false ? Number(this.chunkPaymentPer) : 0) + (this.input_psie == false ? Number(this.installmentPaymentPer) : 0) + (this.input_hie == false ? Number(this.milestonePaymentPer) : 0)).toFixed(2):100;
    }

    get currentInstallmentNumber() {
        return this.installmentList.length;
    }

    // Getter para controlar el progreso visual
    get currentStageName() {
        if (this.currentStage==1) return 'stage1';
        if (this.currentStage==2) return 'stage2';
        if (this.currentStage==3) return 'stage3';
        if (this.currentStage==4) return 'stage4';
        if (this.currentStage==5) return 'stage5';
        if (this.currentStage==6) return 'stage6';
        if (this.currentStage==7) return 'stage7';
        if (this.currentStage==8) return 'stage8';
        if (this.currentStage==9) return 'stage9';
        return 'stage1';
    }

    handleAddMilestone(event) {
        //  console.log(JSON.stringify(event));
        console.log(this.refs.miName.value);
        console.log(this.refs.miDate.value);
        console.log(this.refs.miAmount.value);

        let milestoneAcc = 0;
        let stopEx = false;
        if (this.refs.miName.value == '') {
            this.refs.miName.setCustomValidity('Tiene que ser un nombre válido.');
            stopEx = stopEx || true;
        } else {
            stopEx = stopEx || false;
            this.refs.miName.setCustomValidity('');
        }
        // if (this.refs.miDate.value == '') {
        //     this.refs.miDate.setCustomValidity('Tiene que ser una fecha valida.')
        //     stopEx = stopEx || true;
        // } 
        // else {
        //     this.refs.miDate.setCustomValidity('')
        //     stopEx = stopEx || false;
        // }
        if (this.refs.miAmount.value <= 0) {
            this.refs.miAmount.setCustomValidity('Tiene que ser mayor a 0.');
            stopEx = stopEx || true;
        } else {
            this.refs.miAmount.setCustomValidity('');
            stopEx = stopEx || false;
        }


        milestoneAcc = Number(this.milestoneList.reduce((sum, milestone) => Number(sum) + Number(milestone.amount), 0)) + Number(this.refs.miAmount.value);

        console.log("milestoneAcc", milestoneAcc);
        console.log("this.milestonePayment",this.milestonePayment);

        if (milestoneAcc > this.milestonePayment) {
            this.refs.miAmount.setCustomValidity('El monto no puede exceder el monto acumulado de hitos');
            stopEx = stopEx || true;
        }
        this.refs.miName.reportValidity();
        this.refs.miDate.reportValidity();
        this.refs.miAmount.reportValidity();
        if (stopEx) return;


        this.milestoneList.push({
            id: Date.now(),
            name: this.refs.miName.value,
            date: this.refs.miDate.value,
            amount: this.refs.miAmount.value,
        });
        this.milestoneList = this.milestoneList.slice(0);
        console.log("mile", JSON.stringify(this.milestoneList));
        this.refs.miName.value = ''
        this.refs.miDate.value = ''
        this.refs.miAmount.value = ''
    }


    handleAddInstallment(event) {
        //  console.log(JSON.stringify(event));
        console.log(this.refs.insName.value);
        console.log(this.refs.insDate.value);
        console.log(this.refs.insAmount.value);

        let installmentAcc = 0;
        let stopEx = false;
        if (this.refs.insName.value == '') {
            this.refs.insName.setCustomValidity('Tiene que ser un nombre válido.');
            stopEx = stopEx || true;
        } else {
            stopEx = stopEx || false;
            this.refs.insName.setCustomValidity('');
        }
        if (this.refs.insDate.value == '') {
            this.refs.insDate.setCustomValidity('Tiene que ser una fecha valida.')
            stopEx = stopEx || true;
        } else {
            this.refs.insDate.setCustomValidity('')
            stopEx = stopEx || false;
        }
        if (this.refs.insAmount.value <= 0) {
            this.refs.insAmount.setCustomValidity('Tiene que ser mayor a 0.');
            stopEx = stopEx || true;
        } else {
            this.refs.insAmount.setCustomValidity('');
            stopEx = stopEx || false;
        }


        installmentAcc = Number(this.installmentList.reduce((sum, installment) => Number(sum) + Number(installment.amount), 0)) + Number(this.refs.insAmount.value);

        console.log("installmentAcc", installmentAcc);

        if (installmentAcc > this.installmentPayment) {
            this.refs.insAmount.setCustomValidity('El monto no puede exceder el monto acumulado de hitos');
            stopEx = stopEx || true;
        }
        this.refs.insName.reportValidity();
        this.refs.insDate.reportValidity();
        this.refs.insAmount.reportValidity();
        if (stopEx) return;


        this.installmentList.push({
            id: Date.now(),
            name: this.refs.insName.value,
            date: this.refs.insDate.value,
            amount: this.refs.insAmount.value,
        });
        this.installmentList = this.installmentList.slice(0);
        console.log("ins", JSON.stringify(this.installmentList));
        this.refs.insName.value = ''
        this.refs.insDate.value = ''
        this.refs.insAmount.value = ''
    }

    toPath(item, addOrRem) {

        if (addOrRem) {

            const edx = this.path[this.pathSelector].indexOf(item);
            console.log('edx', edx, item);
            if (edx > -1) { return; }

            const index = this.path[this.pathSelector].findIndex(num => num >= item);


            if (index !== -1) {
                this.path[this.pathSelector].splice(index, 0, item);
            } else {

                this.path[this.pathSelector].push(item);
            }

        } else {
            const index = this.path[this.pathSelector].indexOf(item);

            if (index > -1) {
                this.path[this.pathSelector].splice(index, 1);
            }

        }

    }

    // Get the default record type ID
    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productInfo;

    // Get the picklist values for the Industry field
    // @wire(getPicklistValues, {
    //     recordTypeId: '$productInfo.data.defaultRecordTypeId',
    //     fieldApiName: TYPE_FIELD,
    // })
    // wiredPicklistValues({ data, error }) {
    //     if (data) {
    //     // Set the combobox options property from the picklist values
    //     this.industryOptions = data.values;
    //     } else if (error) {
    //     console.error('Error fetching picklist values:', error);
    //     }
    // }

    handleIndustryChange() {
        this.selectedIndustry = this.refs.industry.value;
    }

    async connectedCallback() {
        // Si no usas @wire para salas, llama a generateCalendar aquí después de definir selectedRoomId
        //    this.generateCalendar();
        this.csx = await getCustomSetting();
        this.conf = await getConfiguration();
        console.log("conf",this.conf);
        console.log('csx', JSON.stringify(this.csx));

         this.recordTypeName = await getRecordTypeName({opportunityId:this.recordId});
            this.isOffice = this.recordTypeName.includes('Oficina');
            this.isIndustrial = this.recordTypeName.includes('Industrial');
            this.pathSelector = this.isIndustrial ? 0 : 1;

            this.didRun = false;

            console.log('pps',this.isOffice,this.isIndustrial,this.pathSelector);


    }


    get nextStageLabel() {
        if (this.isIndustrial) {
            if (this.currentStage == 1) {
                return 'Continuar';
            } else if (this.currentStage == 2) {
                return 'Continuar';
            } else if (this.currentStage == 3) {
                return 'Continuar';
            } else if (this.currentStage == 4) {
                return 'Continuar';
            } else if (this.currentStage == 5) {
                return 'Continuar';
            } else if (this.currentStage == 6) {
                return 'Continuar';
            } else if (this.currentStage == 7) {
                return 'Continuar'
            } else if (this.currentStage == 8) {
                return 'Guardar'
            }
        } else {
            if (this.currentStage == 1) {
                return 'Continuar';
            } else if (this.currentStage == 2) {
                return 'Continuar';
            } else if (this.currentStage == 7) {
                return 'Continuar';
            } else if (this.currentStage == 3) {
                return 'Continuar';
            } else if (this.currentStage == 8) {
                return 'Guardar';
            }
        }
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDisplayedData();
        }


    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDisplayedData();
        }
    }

    get disablePrevious() {
        return this.currentPage === 1;
    }

    get disableNext() {
        return this.currentPage === this.totalPages;
    }

    selectedPaymentType = 'CO';
    paymentTypeOptions = [
        { value: 'CO', label: 'Contado', description: 'Pago Contado' },
        {
            value: 'CD',
            label: 'Financiado',
            description: 'Pago Financiado',
        },

    ];
    selectedCurrency = 'PEN';
    currencyOptions = [
        { value: 'PEN', label: 'Soles' },
        { value: 'USD', label: 'Dolares' }
    ];


    milestoneColumns = [
        { label: 'Descripción', fieldName: 'name' },
        { label: 'Fecha', fieldName: 'date' },
        { label: 'Monto', fieldName: 'amount',type: 'currency', typeAttributes: { currencyCode: 'USD' , minimumFractionDigits: 2,
        maximumFractionDigits: 2} },
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Eliminar', name: 'delete' }] },
        },
    ];
    milestoneColumnsStageSix = [
        { label: 'Descripción', fieldName: 'name' },
        /* { label: 'Fecha', fieldName: 'date' }, */
        { label: 'Monto', fieldName: 'amount',type: 'currency', typeAttributes: { currencyCode: 'USD' , minimumFractionDigits: 2,
        maximumFractionDigits: 2} },
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Eliminar', name: 'delete' }] },
        },
    ];

    columns = [
        { label: 'Lote', fieldName: 'Descripcionlote', initialWidth: 250 },
        //   { label: 'Tipologia', fieldName: 'FillerStr02' },
        //    { label: 'Manzana', fieldName: 'Manzana' },
        { label: 'Estado', fieldName: 'Codestadolote', initialWidth: 90, cellAttributes: { alignment: 'center' } },
        { label: 'Área', fieldName: 'Area', type: 'number', initialWidth: 90, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
        { label: 'Precio m2', fieldName: 'Precioventam2fun', initialWidth: 120, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
        { label: 'Moneda', fieldName: 'MonedaOriginal', initialWidth: 100, cellAttributes: { alignment: 'center' } },
        { label: 'Precio Total', fieldName: 'Precioventafun', initialWidth: 150, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    ];


    columnsO = [
        { label: 'Producto', fieldName: 'Descripcionlote', initialWidth: 250 },
         { label: 'Sociedad', fieldName: 'soc', initialWidth: 250 },
        //   { label: 'Tipologia', fieldName: 'FillerStr02' },
        //    { label: 'Manzana', fieldName: 'Manzana' },
        { label: 'Estado', fieldName: 'Codestadolote', initialWidth: 90, cellAttributes: { alignment: 'center' } },
        { label: 'Área', fieldName: 'Area', type: 'number', initialWidth: 90, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
        { label: 'Precio m2', fieldName: 'Precioventam2fun', initialWidth: 120, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
     //   { label: 'Moneda', fieldName: 'MonedaOriginal', initialWidth: 100, cellAttributes: { alignment: 'center' } },
        { label: 'Precio Total', fieldName: 'Precioventafun', initialWidth: 150, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    ];


    @track columns2 = [
        { label: 'Lote', fieldName: 'Descripcionlote', initialWidth: 250 },
        //     { label: 'Tipologia', fieldName: 'FillerStr02' },
        //    { label: 'Manzana', fieldName: 'Manzana' },
        { label: 'Estado', fieldName: 'Codestadolote', initialWidth: 90, cellAttributes: { alignment: 'center' } },
        { label: 'Área', fieldName: 'Area', type: 'number', initialWidth: 90, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
        { label: 'Precio m2', fieldName: 'Precioventam2fun', initialWidth: 120, editable: true, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
        { label: 'Moneda', fieldName: 'MonedaOriginal', initialWidth: 100, cellAttributes: { alignment: 'center' } },
        { label: 'Precio Total', fieldName: 'Precioventafun', initialWidth: 150, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    ];

    @track colOffice = [
        { label: 'Producto', fieldName: 'Descripcionlote', initialWidth: 250 },
        { label: 'Sociedad', fieldName: 'soc', initialWidth: 250 },
        //     { label: 'Tipologia', fieldName: 'FillerStr02' },
        //    { label: 'Manzana', fieldName: 'Manzana' },
        { label: 'Estado', fieldName: 'Codestadolote', initialWidth: 90, cellAttributes: { alignment: 'center' } },
        { label: 'Área', fieldName: 'Area', type: 'number', initialWidth: 90, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
        { label: 'Precio m2', fieldName: 'Precioventam2fun', initialWidth: 120, editable: true, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    //    { label: 'Moneda', fieldName: 'MonedaOriginal', initialWidth: 100, cellAttributes: { alignment: 'center' } },
        { label: 'Precio Total', fieldName: 'Precioventafun', initialWidth: 150, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    ];

    conditions = [
        { 'id': 1, 'description': 'Etapa', 'value': '' },
        { 'id': 2, 'description': 'Energía Eléctrica', 'value': '' },
        { 'id': 3, 'description': 'Acometidas de Agua y Desagüe', 'value': '' },
        { 'id': 4, 'description': 'Máximo consumo de agua y de desagüe (caudal máximo)', 'value': '' },
        { 'id': 5, 'description': 'Alumbrado público', 'value': '' },
        { 'id': 6, 'description': 'Pistas de concreto, veredas y bermas', 'value': '' },
        { 'id': 7, 'description': 'Zonificación', 'value': '' },
        { 'id': 8, 'description': 'Lote Independizado', 'value': '' },
    ];

    conditions2 = [
        { 'id': 1, 'description': 'Plazo Forzoso', 'value': '' },
        { 'id': 2, 'description': 'Incrementos Anuales', 'value': '' },
        { 'id': 3, 'description': 'Garantías (Fianza)', 'value': '' },
        { 'id': 4, 'description': 'Gastos de Condominio', 'value': '' },
        { 'id': 5, 'description': 'Periodo de Gracia de Renta', 'value': '' },
        { 'id': 6, 'description': 'Plazo Voluntario', 'value': '' },
        { 'id': 7, 'description': 'Información Adicional', 'value': '' },
    ];

    conditionsCols = [
        { label: 'Condición', fieldName: 'description' },
        { label: 'Valor', fieldName: 'value', editatype: 'text', editable: true }
    ]

    deleteRowFromTable(recordId) {
        let currentData = [...this.milestoneList];
        // Use filter() to create a new array without the deleted record
        this.milestoneList = currentData.filter(item => item.id !== recordId);
        // Alternative using splice(): 
        // const index = currentData.findIndex(item => item.Id === recordId);
        // currentData.splice(index, 1);
        // this.data = [...currentData]; // Reassign with spread operator to ensure reactivity
    }

    deleteRowFromTableI(recordId) {
        let currentData = [...this.installmentList];
        // Use filter() to create a new array without the deleted record
        this.installmentList = currentData.filter(item => item.id !== recordId);
        // Alternative using splice(): 
        // const index = currentData.findIndex(item => item.Id === recordId);
        // currentData.splice(index, 1);
        // this.data = [...currentData]; // Reassign with spread operator to ensure reactivity
    }

    handleToggle(event) {
        const openSections = event.detail.openSections;
        if (this.activeSections.includes('A')) {
            this.activeSections = [].slice(0);
        } else {
            this.activeSections = ['A'].slice(0);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.deleteRowFromTable(row.id); // First, delete from the table

        }
    }

    handleRowActionInstallment(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log(JSON.stringify(event));
        console.log(JSON.stringify(event.detail));
        console.log(JSON.stringify(event.detail.row));
        if (actionName === 'delete') {
            this.deleteRowFromTableI(row.id); // First, delete from the table

        }
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
    }

    handleChangePaymentType(event) {
        // Get the string of the "value" attribute on the selected option
        this.typeSale = event.detail.value;

        if (this.typeSale == 'CO') {
            this.isFinanced = false;

        }
        if (this.typeSale == 'CD') {
            this.isFinanced = true;

        }
    }

    handleSaveConditions(event) {
        const updatedFields = event.detail.draftValues;
        console.log(JSON.stringify(updatedFields));
        this.conditions = this.conditions.map((c) => {
            updatedFields.map((u) => {
                if (u.id == c.id) {
                    c.value = u.value;
                }
                return u;
            });
            return c;
        });
        this.draftValuesConditions = [];
        return true;
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log(JSON.stringify(updatedFields));

        // updatedFields.map((o)=>{
        //     this.preSelectedRowsData.map((d)=>{
        //         if(d.Idlote==o.Idlote){
        //             d.Precioventam2fun=o.Precioventam2fun;
        //     }
        //     })
        // });
        let hasError = false;
        let errorMessages = [];
        this.errors = {};
        let errors = { rows: {}, table: {} };

        const _psrd = this.preSelectedRowsData.map((d) => {
            console.log(JSON.stringify(d));
            updatedFields.map((u) => {
                if (d.Idlote == u.Idlote) {
                    if (this.isIndustrial) {
                        if (u.Precioventam2fun < (d.Precioventam2fun - (d.Precioventam2fun * this.conf.ONI_fld_Configuracion_DescuentoMaximoIND__c / 100))) {
                            d.needApproval = true;
                        }
                        d.Precioventam2fun = u.Precioventam2fun != undefined ? u.Precioventam2fun : d.Precioventam2fun;
                        d.Precioventafun = (Number(d.Precioventam2fun) * Number(d.Area)).toFixed(2);
                    } else {
                        if (d.type == 5) {
                            // if(d.Precioventam2fun!=u.Precioventam2fun){
                            //     console.log(JSON.stringify(u));
                            //     console.log(u.Idlote);

                            //     // hasError = true;
                            //     // errorMessages.push('Name cannot be blank.');

                            //     // // Add specific inline error for the row
                            //     // errors.rows[u.Idlote] = {
                            //     //     title: 'Error',
                            //     //     messages: ['El precio de m2 del estacionamiento no puede ser modificado.'],
                            //     //     fieldNames: ['Precio m2']
                            //     // };


                            // }
                            d.Precioventam2fun = u.Precioventam2fun
                            d.Precioventafun = u.Precioventam2fun;// != undefined ? u.Precioventafun : d.Precioventafun;
                        } else if (d.type == 2) {

                            if (u.Precioventam2fun < (d.Precioventam2fun - (d.Precioventam2fun * this.conf.ONI_fld_Configuracion_DescuentoMaximoOFI__c / 100))) {
                                d.needApproval = true;
                            }

                            d.Precioventam2fun = u.Precioventam2fun != undefined ? u.Precioventam2fun : d.Precioventam2fun;
                            d.Precioventafun = d.Precioventam2fun * d.Area;
                            d.rv = u.rv;
                        }
                        else {

                            if (u.Precioventam2fun < (d.Precioventam2fun - (d.Precioventam2fun * this.conf.ONI_fld_Configuracion_DescuentoMaximoOFI__c / 100))) {
                                 d.needApproval = true;
                            }

                            d.Precioventam2fun = u.Precioventam2fun != undefined ? u.Precioventam2fun : d.Precioventam2fun;
                            d.Precioventafun = d.Precioventam2fun * d.Area;
                            //   d.rv = u.rv;
                        }

                    }
                }
            })
            return d;
        })

        if (hasError) {
            // Prevent save by setting the errors property
            this.errors = errors;
        } else {
            this.errors = {};
        }



        this.preSelectedRowsData = _psrd.slice(0);
        console.log("$$$", JSON.stringify(this.preSelectedRowsData));

        const recordInputs = updatedFields.map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        this.draftValues = [];
        console.log(recordInputs);
        console.log(JSON.stringify(recordInputs));
        this.updateTotalAmount();
        this.directPayment = 0.0;
        this.chunkPayment = 0.0;
        this.installmentPayment = 0.0;
        this.milestonePayment = 0.0;
        return true;
        /*
                const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        
                Promise.all(promises)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Records updated',
                                variant: 'success'
                            })
                        );
                        // Clear all draft values in the datatable
                        this.draftValues = [];
                        // Display fresh data in the datatable
                        return refreshApex(this.wiredRecords);
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating records',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
                    */
    }

    handleRecordSelected(event) {
        console.log("handleRecordSelected", event.detail.recordId);
        this.selectedRecordId = event.detail.recordId;
        if (this.isIndustrial) {

        } else {
            this.doFilterOFI(event.detail.recordId);
        }
    }

    @wire(getRecord, { recordId: '$selectedRecordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        console.log("1d")
        if (data) {
            console.log("2d")
            console.log("data", data);
            this.codigoSAP = data.fields.CEN_CODIGOSAP__c.value;
            console.log("3d")
            this.doFilter();
            console.log("4d")
        } else if (error) {
            console.log("5d")
            console.log("error", error);
        }
    }

    // @wire(getRecord, {
    //     recordId: '$recordId',
    //     fields: [RECORD_TYPE_NAME_FIELD]
    // })
    // wiredRecord({ error, data }) {
    //     if (data) {
    //         this.recordTypeName = data.fields.RecordType.value.fields.Name.value;
    //         this.isOffice = this.recordTypeName === 'Oficina';
    //         this.isIndustrial = this.recordTypeName === 'IND_Industrial';
    //         this.pathSelector = this.isIndustrial ? 0 : 1;

    //         this.didRun = false;
    //         console.log('Current Record Type Name:', this.recordTypeName);
    //     } else if (error) {
    //         console.error('Error fetching record type:', error);
    //     }
    // }

    // @wire(getRecord, {
    //     recordId: '$recordId',
    //     fields: [LEAD_RECORD_TYPE_NAME_FIELD]
    // })
    // wiredRecord2({ error, data }) {
    //     if (data) {

    //         this.recordTypeName = data.fields.RecordType.value.fields.Name.value;
    //         this.isOffice = this.recordTypeName === 'Oficina';
    //         this.isIndustrial = this.recordTypeName === 'IND_Industrial';
    //         this.pathSelector = this.isIndustrial ? 0 : 1;

    //         this.didRun = false;
    //         console.log('Current Record Type Name:', this.recordTypeName);
    //     } else if (error) {
    //         console.error('Error fetching record type:', error);
    //     }
    // }


    async rcInd() {
        if (this.didRun == false) {
            const _xdata = await getQuote({ opportunityId: this.recordId });
            if (_xdata == null) return;
            console.log("prevLotList", JSON.stringify(_xdata));
            const prevLotList = _xdata.map(o => o.Product2.CODLOTE__c);

            const _data = _xdata.map(o => o.Product2);
            const data = _data.map(o => {
                o.Precioventam2fun = o.ONI_fld_Producto_PrecioM2__c;
                o.Precioventafun = o.CEN_PRECIOVENTAFUN__c;
                o.Descripcionlote = o.Name;
                o.Idlote = o.CODLOTE__c;
                o.type = o.ONI_fld_Product_TipoObjetoAlquiler__c;
                o.Codlote = o.CODLOTE__c;
                o.Area = o.AREA__c;
                o.Codestadolote = o.OFI_fld_Product2_Estado__c;
                o.MonedaOriginal = o.CODMONEDAFUNCIONAL__c;
                o.needApproval = false
                return o;
            });



            this.doFilter();
            this.didRun = true;
            this.preSelectedRows = prevLotList.slice(0);
            this.preSelectedRowsData = data.slice(0);
        }
    }

    async rcOffice() {
        if (this.didRun == false) {
            this.columns2=this.colOffice.slice(0);
            this.columns=this.columnsO.slice(0);
            this.didRun = true;
            const _xdata = await getQuote({ opportunityId: this.recordId });
            if (_xdata == null) return;
            console.log("_xdata", JSON.stringify(_xdata));
            const prevLotList = _xdata.map(o => o.PricebookEntryId);
            console.log("prevLotList", JSON.stringify(prevLotList));
            //const _data = _xdata.map(o=>o.Product2);
            const _data = _xdata.map(o => {
                const p2 = o.Product2;
                p2.pbeId = o.PricebookEntryId;
                p2.UnitPrice = o.PricebookEntry.UnitPrice;
                return p2;
            });
            console.log("_data", JSON.stringify(_data));
            const data = _data.map(o => {
                o.Precioventam2fun = o.UnitPrice>0?o.UnitPrice:undefined;
                o.Precioventafun = o.UnitPrice>0?o.OFI_fld_Product2_BaseMedida__c*o.UnitPrice:undefined;
                o.Descripcionlote = o.Name;
                o.Idlote = o.pbeId;
                o.type = o.ONI_fld_Product_TipoObjetoAlquiler__c;
                o.Codlote = o.pbeId;
                o.Area = o.OFI_fld_Product2_BaseMedida__c;
                o.Codestadolote = o.OFI_fld_Product2_Estado__c;
                o.needApproval = false;
                o.soc=o.OFI_fld_Product2_DescSociedad__c;
                return o;
            });

            this.columns2.push(
                { label: 'Renta Variable', fieldName: 'rv', editatype: 'currency', editable: true, type: 'currency', typeAttributes: { currencyCode: 'USD' } },
            );
            this.conditions = this.conditions2.slice(0);
            console.log('conditions',JSON.stringify(this.conditions));
            this.doFilter();

            this.preSelectedRows = prevLotList.slice(0);
            this.preSelectedRowsData = data.slice(0);
        }
    }

    async renderedCallback() {

        if (this.isIndustrial) {
        //    this.rcInd();
        } else {
        //    this.rcOffice();
        }

        // if(this.didRun==false){
        //     const _xdata = await getQuote({opportunityId:this.recordId});
        //     if(_xdata==null)return;
        //     console.log("prevLotList",JSON.stringify(_xdata));
        //     const prevLotList = _xdata.map(o=>o.Product2.CODLOTE__c);

        //     const _data = _xdata.map(o=>o.Product2);
        //     const data = _data.map(o=>{
        //         o.Precioventam2fun = o.ONI_fld_Producto_PrecioM2__c;
        //         o.Precioventafun = o.CEN_PRECIOVENTAFUN__c;
        //         o.Descripcionlote=o.Name;
        //         o.Idlote=o.CODLOTE__c;
        //         o.type=o.ONI_fld_Product_TipoObjetoAlquiler__c;
        //         o.Codlote=o.CODLOTE__c;
        //         o.Area = o.AREA__c;
        //         o.Codestadolote=o.OFI_fld_Product2_Estado__c;
        //         return o;
        //     });

        //     this.doFilter();
        //     this.didRun=true;
        //     this.preSelectedRows = prevLotList.slice(0);
        //     this.preSelectedRowsData = data.slice(0);
        // }
    }

    async doFilterIND() {
        const pId = this.refs.recordPicker.value;

        console.log(this.codigoSAP);

        const block = this.refs.block.value;
        const mz = this.refs.mz.value;

        const regexEtapa = new RegExp(`ETAPA ${block}\\b`, 'i');
        const regexMz = new RegExp(`Mz\\.${mz}\\b`, 'i');

        // const lotList =await fetchAccountWrapper({Idproyecto:this.codigoSAP});
        // console.log(lotList);
        //  console.log(pId);
        // const _data= lotList.getlotes.slice(0);

        const _xdata = await getIndustrial({ "projectId": this.codigoSAP, "typeProduct": "", "opportunityId": this.recordId });
        console.log("_xdata", JSON.stringify(_xdata));
        const _data = _xdata.map(o => o.Product2);
        const data = _data.map(o => {
            o.Precioventam2fun = o.ONI_fld_Producto_PrecioM2__c;
            o.Precioventafun = o.CEN_PRECIOVENTAFUN__c;
            o.Descripcionlote = o.Name;
            o.Idlote = o.CODLOTE__c;
            o.type = o.ONI_fld_Product_TipoObjetoAlquiler__c;
            o.Codlote = o.CODLOTE__c;
            o.Area = o.AREA__c;
            o.Codestadolote = o.OFI_fld_Product2_Estado__c;
            o.MonedaOriginal = o.CODMONEDAFUNCIONAL__c;
            o.needApproval = false;
            return o;
        });


        if (block != '' || mz != '') {
            this.allData = data.filter(p =>
                regexEtapa.test(p.Descripcionlote) && regexMz.test(p.Descripcionlote)
            );
        } else {
            this.allData = data;
        }

        this.totalRecords = data.length;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        this.updateDisplayedData();
        this.updateTotalAmount();
    }

    async doFilterOFI(pId) {

        this.columns2 = this.colOffice.slice(0);
        this.columns=this.columnsO.slice(0);
        this.conditions = this.conditions2.slice(0);
        //pId = this.refs.recordPickerOFI.value;
        console.log("pId", pId);
        console.log("this.selectedIndustry", this.selectedIndustry);
        const _xdata = await getOffice({ "projectId": pId, "typeProduct": this.selectedIndustry });
        console.log("####", JSON.stringify(_xdata));
        const _data = _xdata[0].map(o => {
            const p2 = o.Product2;
            p2.pbeId = o.Id;
            p2.UnitPrice = o.UnitPrice;
            return p2;
        });

        console.log("####", JSON.stringify(_data));
        //console.log("####",JSON.stringify(_medMap));
        //console.log("####",JSON.stringify(_socMap));
        const data = _data.map(o => {

            const id = o.pbeId//o.OFI_fld_Product2_IdSociedad__c+o.OFI_fld_Producto_NombreEdificio__r?.ONI_fld_Proyecto_EdificioExternalId__c+o.OFI_fld_Product2_IdSAP__c
            o.Precioventam2fun = o.OFI_fld_Product2_Clase__c == 5 ? this.conf.ONI_fld_Configuracion_EstPrecio__c : o.UnitPrice;
            o.Precioventafun = o.OFI_fld_Product2_Clase__c == 5 ? this.conf.ONI_fld_Configuracion_EstPrecio__c : o.OFI_fld_Product2_BaseMedida__c*o.UnitPrice;
            o.Descripcionlote = o.Name;
            o.Idlote = id;
            o.type = o.OFI_fld_Product2_Clase__c;
            o.Codlote = id;
            o.Area = o.OFI_fld_Product2_BaseMedida__c;
            o.needApproval = false;
            o.soc = o.OFI_fld_Product2_DescSociedad__c;
            return o;
        });

        this.allData = data;
        this.totalRecords = data.length;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        this.updateDisplayedData();
        this.updateTotalAmount();
    }

    async doFilter() {
        console.log('doFilter');
        if (this.isIndustrial) {
            this.doFilterIND();
        } else {
            this.doFilterOFI(this.selectedRecordId);
        }
        //convert to decimal
    }


    updateDisplayedData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        this.data = this.allData.slice(start, end);

        this.preSelectedRows = this.preSelectedRows.slice(0);

    }

    get doModal() {
        let ret;
        if (this.isEmbedded) {
            ret = this.isModalOpen;
        } else {
            ret = true;
        }
        return ret;
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new RefreshEvent());
    }

    get isPageable() {
        return this.totalPages > 1 && this.stage == 1;
    }

    get isHIE() {

        console.log('hie', this.hie, this.paymentChangeName);
        if (this.paymentChangeName == 'hie') {

        }
        return this.hie;
    }

    get currentStage() {
        return this.path[this.pathSelector][this.stage - 1];
    }

    get stage1() {
        console.log('stage1', this.path[this.pathSelector][this.stage - 1], this.stage - 1, this.pathSelector);
        return this.path[this.pathSelector][this.stage - 1] == 1;
    }

    get stage2() {

        return this.path[this.pathSelector][this.stage - 1] == 2;
    }

    get stage3() {

        return this.path[this.pathSelector][this.stage - 1] == 3;
    }

    get stage4() {

        return this.path[this.pathSelector][this.stage - 1] == 4;
    }

    get stage5() {

        return this.path[this.pathSelector][this.stage - 1] == 5;
    }

    get stage6() {

        return this.path[this.pathSelector][this.stage - 1] == 6;
    }

    get stage7() {

        return this.path[this.pathSelector][this.stage - 1] == 7;
    }

    get stage8() {

        return this.path[this.pathSelector][this.stage - 1] == 8;
    }

    get stage9() {

        return this.path[this.pathSelector][this.stage - 1] == 9;
    }


    get stageN() {

        return this.stage > 1;
    }

    get stageF() {
        return this.path[this.pathSelector][this.stage - 1] < 9;
    }

    get directPaymentX() {
        return this.directPayment;
    }
    get installmentPaymentX() {
        return this.installmentPayment;
    }
    get chunkPaymentX() {
        return this.chunkPayment;
    }
    get milestonePaymentX() {

        return this.milestonePayment;
    }

    handleCondSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('preCond::', JSON.stringify(selectedRows), selectedRows.length);
        console.log('event:.', JSON.stringify(event.detail.config.value));

        let selectedItemsSet = new Set(this.preSelectedCondRows);


        if (event.detail.config.action == "rowSelect") {
            this.preSelectedCondRowsData.push(...this.conditions.filter(o => o.id == event.detail.config.value));

            selectedItemsSet.add(event.detail.config.value);
            this.preSelectedCondRows = [...selectedItemsSet];
        } else if (event.detail.config.action == "rowDeselect") {
            this.preSelectedCondRowsData = this.preSelectedCondRowsData.filter(o => o.id != event.detail.config.value);
            selectedItemsSet.delete(event.detail.config.value);
            this.preSelectedCondRows = [...selectedItemsSet];
        }
        this.preSelectedCondRowsData = this.preSelectedCondRowsData.slice(0);
        console.log("preCondData::", JSON.stringify(this.preSelectedCondRowsData));
        console.log("preCond::", JSON.stringify(this.preSelectedCondRows));
    }

    handleRowSelection(event) {
        console.log('handleRowSelection');
        console.log(event);
        console.log(JSON.stringify(event));
        const selectedRows = event.detail.selectedRows;
        console.log('pre:', JSON.stringify(selectedRows), selectedRows.length);

        let selectedItemsSet = new Set(this.preSelectedRows);


        if (event.detail.config.action == "rowSelect") {
            this.preSelectedRowsData.push(...this.data.filter(o => o.Idlote == event.detail.config.value));

            selectedItemsSet.add(event.detail.config.value);
            this.preSelectedRows = [...selectedItemsSet];
        } else if (event.detail.config.action == "rowDeselect") {
            this.preSelectedRowsData = this.preSelectedRowsData.filter(o => o.Idlote != event.detail.config.value);
            selectedItemsSet.delete(event.detail.config.value);
            this.preSelectedRows = [...selectedItemsSet];
        }
        this.preSelectedRowsData = this.preSelectedRowsData.slice(0);
        this.updateTotalAmount();
        console.log("preData::", JSON.stringify(this.preSelectedRowsData));
        console.log("pre::", JSON.stringify(this.preSelectedRows));
    }

    updateTotalAmount() {
        this.totalPayment = (this.preSelectedRowsData.reduce((a, b) => a + Number(b.Precioventafun), 0)).toFixed(2);
    }


    async handleSaveRecord() {
        // const fields = {};
        // fields[OPPORTUNITY_FIELD.fieldApiName] = this.recordId;
        // fields[NAME_FIELD.fieldApiName] = '-';

        // const recordInput = { apiName: QUOTE_OBJECT.objectApiName, fields };
        // createRecord(recordInput)
        // .then(o=>{
        //     console.log(JSON.stringify(o));
        //     // Record created successfully

        // })
        // .catch(error => {
        //     // Handle the error
        //     console.log(JSON.stringify(error));
        // });
        let totalArea = 0;
        const qliPrice = this.preSelectedRowsData.reduce((accumulator, currentItem) => {
            const codlote = this.isIndustrial ? currentItem.CODLOTE__c : currentItem.pbeId;
            const precioM2 = currentItem.Precioventam2fun;
            const precioFun = currentItem.Precioventafun;
            const Area = currentItem.Area;
            const Descripcionlote = currentItem.Descripcionlote;
            const needApproval = currentItem.needApproval;
            totalArea += Number(Area);
            if (codlote && precioM2 && precioFun) {
                accumulator[codlote] = [precioM2, precioFun, Area, Descripcionlote, needApproval];
            }

            return accumulator;
        }, {});


        const result = await save({
            opportunityId: this.recordId,
            lotList: this.preSelectedRowsData.map(o => o.Codlote),
            qData: {
                typeSale: this.typeSale,
                totalPayment: this.totalPayment,
                milestoneList: JSON.stringify(this.milestoneList),
                installments: JSON.stringify(this.installmentList),
                conditions: JSON.stringify(this.preSelectedCondRowsData),
                directPayment: this.directPayment,
                chunkPayment: this.chunkPayment,
                chunkNumber: this.calculatorData['numCuotas'],
                chunkTEA: this.calculatorData['tea'],
                chunkDate: this.calculatorData['fechaVencimiento'],
                installmentPayment: this.installmentPayment,
                installmentNumber: this.installmentNumber,
                milestonePayment: this.milestonePayment,
                isFinanced: this.isFinanced,
                pathSelector: this.pathSelector,
                currency: this.currency,
                isIndustrial: this.isIndustrial,
                totalArea: totalArea,


            },
            qliPrice: qliPrice,
            isIndustrial: this.isIndustrial
        });


        this.closeModal();

    }
    keyIndex = 0;
    handleAddRow() {
        this.keyIndex = Date.now();
        const newRow = {
            // A unique key is required for each row
            Idlote: 'row-' + this.keyIndex,
            CODLOTE__c: 'row-' + this.keyIndex,
            Codlote: 'row-' + this.keyIndex,
            Descripcionlote: this.refs.Descripcionlote.value,
            Area: this.refs.Area.value,
            Precioventam2fun: this.refs.Precioventam2fun.value,
            MonedaOriginal: this.refs.currency.value,
            Precioventafun: Number(this.refs.Area.value) * Number(this.refs.Precioventam2fun.value),
            needApproval: false
        };
        this.refs.Descripcionlote.value = '';
        this.refs.Area.value = '';
        this.refs.Precioventam2fun.value = '';
        this.refs.currency.value = 'PEN';
        // Create a new array to trigger reactivity (spread operator)
        this.data = [...this.data, newRow];
    }

    handleNextStage() {
        //console.log(this.stage4 , this.isIndustrial , this.typeSale=='CD' , this.isFinanced , this.input_pcde==true);

        // if(this.stage3 && this.isIndustrial && this.typeSale=='CO'){
        //     this.stage=5;
        // }else if(this.stage3 && this.isIndustrial && this.typeSale=='CD' && this.isFinanced && this.input_pcde==true){
        //     this.stage=5;
        // }
        // else if(this.stage5 && this.isIndustrial){
        //     this.handleSaveRecord();
        // }else if(this.stage3 && this.isOffice){
        //     this.handleSaveRecord();
        // }
        // else{

        // }
        this.stage++;

        console.log('stageZ', this.stage, this.currentStage);

        if (this.currentStage == 3 && this.directPayment == 0) {
            this.directPayment = (this.totalPayment * this.directPaymentPer / 100).toFixed(2);
        }

        if (this.currentStage == undefined || this.currentStage == 9)//Se llego al final .Guardar
        {
            this.handleSaveRecord();
        }
    }

    handlePrevStage() {
        if (this.stage > 1) {
            this.stage--;
        }
    }

    handleBackStage() {

    }

    get nextableClass() {
        return !this.nextable ? 'good' : 'not-good';
    }

    get nextable() {
        let ret = false;
        console.log("####", this.stage);
        if (this.isIndustrial) {
            if (this.currentStage == 1) {
                ret = (this.preSelectedRows.length > 0);
            } else if (this.currentStage == 3) {
                if (this.isFinanced) {
                    ret = (100 == ((this.input_pme == false ? Number(this.directPaymentPer) : 0) + (this.input_pcde == false ? Number(this.chunkPaymentPer) : 0) + (this.input_psie == false ? Number(this.installmentPaymentPer) : 0) + (this.input_hie == false ? Number(this.milestonePaymentPer) : 0)).toFixed(2));
                    //ret = (this.totalPayment == ( (this.input_pme==false?Number(this.directPayment):0) + (this.input_pcde==false?Number(this.chunkPayment):0) + (this.input_psie==false?Number(this.installmentPayment):0) + (this.input_hie==false?Number(this.milestonePayment):0) ).toFixed(2));
                    //ret = (this.totalPayment == ( (this.input_pme==false?Number(this.directPayment):0) + (this.input_pcde==false?Number(this.chunkPayment):0) + (this.input_psie==false?Number(this.installmentPayment):0)  ));
                    if (

                        this.input_pme == false && Number(this.directPaymentPer) <= 0 ||
                        this.input_pcde == false && Number(this.chunkPaymentPer) <= 0 ||
                        this.input_psie == false && Number(this.installmentPaymentPer) <= 0 ||
                        this.input_hie == false && Number(this.milestonePaymentPer) <= 0

                    ) {
                        ret = false;
                    }

                    if (this.input_psie == false) {
                        ret = ret && this.installmentNumber > 0;

                    }

                    console.log("tp", (this.input_pme == false ? Number(this.directPaymentPer) : 0), (this.input_pcde == false ? Number(this.chunkPaymentPer) : 0), (this.input_psie == false ? Number(this.installmentPaymentPer) : 0), (this.input_hie == false ? Number(this.milestonePaymentPer) : 0));
                    console.log("tp", (100 == ((this.input_pme == false ? Number(this.directPaymentPer) : 0) + (this.input_pcde == false ? Number(this.chunkPaymentPer) : 0) + (this.input_psie == false ? Number(this.installmentPaymentPer) : 0) + (this.input_hie == false ? Number(this.milestonePaymentPer) : 0)).toFixed(2)));
                    //console.log(this.totalPayment,Number(this.directPayment).toFixed(2) + Number(this.chunkPayment).toFixed(2));
                    console.log('totalPayment', this.input_pme, this.input_pcde, this.input_psie, this.input_hie);
                    console.log('totalPayment', ((this.input_pme == false ? Number(this.directPayment).toFixed(2) : 0) + (this.input_pcde == false ? Number(this.chunkPayment).toFixed(2) : 0) + (this.input_psie == false ? Number(this.installmentPayment) : 0) + (this.input_hie == false ? Number(this.milestonePayment) : 0)));
                } else {
                    ret = true;
                }
            } else if (this.currentStage == 4) {
                ret = this.installmentList.length == this.installmentNumber;
                let installmentAcc = Number(this.installmentList.reduce((sum, installment) => Number(sum) + Number(installment.amount), 0)).toFixed(2);
                ret = ret && installmentAcc == this.installmentPayment;
                console.log(44, ret);

            } else if (this.currentStage == 6) {
                ret = true;
                let  milestoneAcc = Number(this.milestoneList.reduce((sum, milestone) => Number(sum) + Number(milestone.amount), 0)).toFixed(2);
                ret = ret && milestoneAcc == this.milestonePayment;
                console.log(66, ret,milestoneAcc,this.milestonePayment);

            }     
            else {
                ret = true;
            }
        } else {
            if (this.currentStage == 1) {
                ret = (this.preSelectedRows.length > 0);
            } else if (this.currentStage == 2) {

                ret = this.preSelectedRowsData.every(registro => {
                    // Comprueba si la propiedad existe y si es mayor a 0 (después de convertir a número)
                    return registro.hasOwnProperty('Precioventam2fun') && Number(registro.Precioventam2fun) > 0;
                });

            } else if (this.currentStage == 3) {
                //ret = (this.totalPayment == (Number(this.directPayment) + Number(this.chunkPayment)));
                ret = true;
                console.log(this.totalPayment, Number(this.directPayment).toFixed(2) + Number(this.chunkPayment).toFixed(2));
            } else {
                ret = true;
            }
        }

        return (this.nextableT) ? !ret : !ret;
    }

    handleTogglePayment(event) {
        console.log(event);
        console.log(JSON.stringify(event));
        ///this.isChecked = event.target.checked;

    }

    handlePaymentChange(event) {
        this.paymentChangeName = event.target.name;
        if (['pme', 'psie', 'pcde', 'hie'].includes(event.target.name)) {
            // console.log("#",event.target.name);
            // const vs={'pme':this.pme,'psie':this.psie,'pcde':this.pcde};
            // vs[event.target.name]=!event.target.checked;
            // console.log(event.target.checked);
            // console.log(this.pme);
            // console.log(this.psie);
            // console.log(this.pcde);

            if (event.target.name == 'pme') {
                this.pme = event.target.checked;
                this.input_pme = !this.input_pme;
            }
            if (event.target.name == 'psie') {
                this.psie = event.target.checked;
                this.toPath(4, this.psie);
                this.input_psie = !this.input_psie;
            }
            if (event.target.name == 'pcde') {
                this.pcde = event.target.checked;
                this.toPath(5, this.pcde);
                this.input_pcde = !this.input_pcde;
            }
            if (event.target.name == 'hie') {
                this.hie = event.target.checked;
                this.toPath(6, this.hie);
                this.input_hie = !this.input_hie;
            }
            this.nextableT = !this.nextableT;
            return;
        }

        const fieldName = event.target.name;
        console.log("handlePayment", fieldName);
        const value = parseFloat(event.target.value) || 0; // Convertir a número, usar 0 si el valor no es válido

        if (fieldName === 'directPaymentPer') {
            this.directPaymentPer = value;
            this.directPayment = (this.directPaymentPer / 100 * this.totalPayment).toFixed(2);
            // if(this.directPayment <  (this.totalPayment*10/100)){
            //     this.refs.directPayment.setCustomValidity('El monto no puede ser menor a 10% del total.');

            // }else{
            //     this.refs.directPayment.setCustomValidity('');
            // }
            // this.refs.directPayment.reportValidity();
            //console.log(this.totalPayment,this.directPayment);
            //this.chunkPayment = (this.totalPayment - this.directPayment).toFixed(2);
        } else if (fieldName === 'installmentPaymentPer') {
            this.installmentPaymentPer = value;
            this.installmentPayment = (this.installmentPaymentPer / 100 * this.totalPayment).toFixed(2);
        } else if (fieldName === 'chunkPaymentPer') {
            this.chunkPaymentPer = value;
            this.chunkPayment = (this.chunkPaymentPer / 100 * this.totalPayment).toFixed(2);
            //this.directPayment = (this.totalPayment - this.chunkPayment).toFixed(2);
        } else if (fieldName === 'milestonePaymentPer') {
            this.milestonePaymentPer = value;
            this.milestonePayment = (this.milestonePaymentPer / 100 * this.totalPayment).toFixed(2);
        }
        else if (fieldName === 'installmentNumber') {
            this.installmentNumber = value;
        }
        console.log('payzi', this.directPayment);
        console.log('payzi', this.chunkPayment);
        console.log('payzi', this.installmentPayment);
        console.log('payzi', this.milestonePayment);

        console.log("payz", this.totalPayment, this.directPayment + this.chunkPayment + this.installmentPayment + this.milestonePayment);

    }

    handleDataFromChild(event) {
        console.log('handleDataFromChild', JSON.stringify(event.detail));
        this.calculatorData = { ...event.detail };

    }

    get totalPaymentStr() {
        return new Intl.NumberFormat('es-PE', {
            style: 'currency',
            currency: 'USD',
        }).format(Number(this.totalPayment).toFixed(2));
    }

    get producto() {
        return this.preSelectedRowsData[0].Descripcionlote;
    }

    get area() {
        return this.preSelectedRowsData[0].FillerStr02;
    }

    get precioM2() {
        return this.preSelectedRowsData[0].Precioventam2fun;
    }

    get montoFinanciar() {
        return this.chunkPayment;// this.preSelectedRowsData[0].Precioventafun;
    }

}