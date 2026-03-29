import { LightningElement, track, api, wire } from 'lwc';
//Obtener Número de Documentos
import getLotesFinanciamientos from "@salesforce/apex/CEN_LotesFinanciamientoCasos.getLotesFinanciamientos";
import saveFinanciamientoLotes from "@salesforce/apex/CEN_LotesFinanciamientoCasos.saveFinanciamientoLotes";
import getFinanciamientoLotesInicial from "@salesforce/apex/CEN_LotesFinanciamientoCasos.getFinanciamientoLotesInicial";
import getTipoDeRegistroDeveloper from "@salesforce/apex/CEN_LotesFinanciamientoCasos.getTipoDeRegistroDeveloper";
import relateCaseLog from "@salesforce/apex/CEN_LotesFinanciamientoCasos.relateCaseLog";
import getCamposProyectosFin   from '@salesforce/apex/CEN_LotesFinanciamientoCasos.getCamposProyectoFin';
import { RefreshEvent } from 'lightning/refresh';

export default class CEN_LotesFinanciamientoCasos extends LightningElement {
    //Boolean para mostrar u ocultar el modal 
    @track isModalOpen      =   false;
    @track mostrarSpinner   =   false;
    @track botonSiguiente   =   'Siguiente';
    //Método para mostrar el modal principal
    openModal() {
        this.isModalOpen    =   true;
        this.busquedaFinanciamiento();
        this.mostrarSpinner =   false;
    }
    //Método para cerrar el modal principal
    closeModal() {
        this.isModalOpen                =   false;
        //BOTONES PREVIO Y SIGUIENTE
        this.desactivarAnterior         =   true;
        this.desactivarSiguiente        =   true;
        //MOSTRAR PANTALLAS
        /*this.financiamientoLoteOpenP1   =   true;
        this.financiamientoOpenP2       =   false;
        this.lotesOpenP3                =   false;
        this.confirmacionOpenP4         =   false;*/
        this.financiamientoOpenP2       =   false;
        this.lotesOpenP3                =   false;
        this.getRecordTypeDevelopername();
        this.mostrarSpinner             =   false;
        //this.pasoSeleccionado           =   'financiamientoLote';
        this.botonSiguiente             =   'Siguiente';
        this.dataFinanciamiento         =   [];
        this.dataLotes                  =   [];
        this.lotesSeleccionados         =   [];
        this.financiamientoSeleccionadoValue    =[];
        this.mostrarSpinner             =   false;
    }
    
    //Evento para la barra de progreso
    @track pasoSeleccionado         =   'financiamientoLote';
    @track financiamientoLoteOpenP1 =   false;
    @track financiamientoOpenP2     =   false;
    @track lotesOpenP3              =   false;
    @track confirmacionOpenP4       =   false;
    @track steps                    =   [{ label: 'Selección Financiamiento o Lote',    value: 'financiamientoLote' },
                                        { label: 'Financiamiento',                      value: 'financiamiento' },
                                        { label: 'Lotes',                               value: 'lotes' },];
    
    pasoSiguiente(){
        console.log('paso actual'   + this.pasoSeleccionado);
        console.log('radio'         + this.valorRadio);
        this.mostrarSpinner             =   true;
        
        if(this.valorRadio ==  'lotes'){
            this.steps = [
                //{ label: 'Selección Financiamiento o Lote', value: 'financiamientoLote' },
                { label: 'Financiamiento',                  value: 'financiamiento' },
                { label: 'Lotes',                           value: 'lotes' },
                
            ];
            if(this.pasoSeleccionado        ==  'financiamientoLote' ){
                //MOSTRAR SPINNER
                //BOTONES PREVIO Y SIGUIENTE
                this.desactivarAnterior         =   false;
                this.desactivarSiguiente        =   true;
                //MOSTRAR PANTALLAS
                this.financiamientoLoteOpenP1   =   false;
                this.financiamientoOpenP2       =   true;
                this.lotesOpenP3                =   false;
                this.confirmacionOpenP4         =   false;
                //SIGUIENTE PANTALLA
                this.pasoSeleccionado           =   'financiamiento';
                this.steps.value                =   'financiamiento';
                this.busquedaFinanciamiento();
            }
            else if(this.pasoSeleccionado   ==  'financiamiento'){
                //MOSTRAR SPINNER
                this.mostrarSpinner             =   true;
                //BOTONES PREVIO Y SIGUIENTE
                this.desactivarAnterior         =   false;
                this.desactivarSiguiente        =   true;
                //MOSTRAR PANTALLAS
                this.financiamientoLoteOpenP1   =   false;
                this.financiamientoOpenP2       =   false;
                this.lotesOpenP3                =   true;
                this.confirmacionOpenP4         =   false;
                //SIGUIENTE PANTALLA
                this.pasoSeleccionado           =   'lotes';
                //OCULTAR SPINNER
                this.mostrarSpinner             =   false;
                //BOTON SIGUIENTE A GUARDAR
                this.botonSiguiente             =   'Guardar';

            }
            else if(this.pasoSeleccionado   ==  'lotes' ){
                //MOSTRAR SPINNER
                this.mostrarSpinner             =   true;
                //BOTONES PREVIO Y SIGUIENTE
                this.desactivarAnterior         =   true;
                this.desactivarSiguiente        =   true;
                //MOSTRAR PANTALLAS
                this.financiamientoLoteOpenP1   =   false;
                this.financiamientoOpenP2       =   false;
                this.lotesOpenP3                =   true;
                //SIGUIENTE PANTALLA
                //this.pasoSeleccionado           =   'confirmacion';
                //OCULTAR SPINNER
                this.mostrarSpinner             =   false;
                this.guardarFinanciamientosLotes(this.lotesSeleccionados);
                console.log('guardar');
            }
        }
        else if(this.valorRadio ==  'financiamiento'){
            this.steps = [
                //{ label: 'Selección Financiamiento o Lote', value: 'financiamientoLote' },
                { label: 'Financiamiento',                  value: 'financiamiento' },
                
            ];
            if(this.pasoSeleccionado        ==  'financiamientoLote' ){
                //MOSTRAR SPINNER
                this.mostrarSpinner             =   true;
                //BOTONES PREVIO Y SIGUIENTE
                this.desactivarAnterior         =   false;
                this.financiamientoLoteOpenP1   =   false;
                this.financiamientoOpenP2       =   true;
                this.pasoSeleccionado           =   'financiamiento';
                this.busquedaFinanciamiento();
                //MOSTRAR SPINNER
                this.mostrarSpinner             =   true;
                //BOTON SIGUIENTE A GUARDAR
                this.botonSiguiente             =   'Guardar';
            }else if(this.pasoSeleccionado   ==  'financiamiento'){
                this.financiamientoLoteOpenP1   =   false;
                this.financiamientoOpenP2       =   true;
                this.desactivarAnterior         =   true;
                this.desactivarSiguiente        =   true;
                this.guardarFinanciamientosLotes(this.dataLotes);
                console.log('guardar');
            }
        }
    }
    
    pasoAnterior(){
        if(this.pasoSeleccionado    ==  'lotes'){
            //BOTONES PREVIO Y SIGUIENTE
            this.desactivarAnterior         =   false;
            this.desactivarSiguiente        =   true;
            //MOSTRAR PANTALLAS
            this.financiamientoLoteOpenP1   =   false;
            this.financiamientoOpenP2       =   true;
            this.lotesOpenP3                =   false;
            this.confirmacionOpenP4         =   false;
            this.pasoSeleccionado           =   'financiamiento';
            this.botonSiguiente             =   'Siguiente';
        }
        else if(this.pasoSeleccionado   ==  'financiamiento'){
            //BOTONES PREVIO Y SIGUIENTE
            this.desactivarAnterior         =   true;
            this.desactivarSiguiente        =   true;
            //MOSTRAR PANTALLAS
            this.financiamientoLoteOpenP1   =   true;
            this.financiamientoOpenP2       =   false;
            this.lotesOpenP3                =   false;
            this.confirmacionOpenP4         =   false;
            this.pasoSeleccionado           =   'financiamientoLote';
            this.botonSiguiente             =   'Siguiente';            
        }
    }

    //Radio Buton
    @track valorRadio   =   '';
    @track desactivarAnterior  =   true;
    @track desactivarSiguiente =   true;
    /*get options() {
        return [
            { label: 'Lotes',           value: 'lotes' },
            { label: 'Financiamiento',  value: 'financiamiento' },
        ];
    }*/
    @track options=[
            { label: 'Lotes',           value: 'lotes' },
            { label: 'Financiamiento',  value: 'financiamiento' },
    ];

    seleccionRadio(event){
        this.valorRadio             =   event.target.value;
        this.desactivarSiguiente    =   false;
        
    }

    //Data Table de Financiamiento
    @track columnsFinanciamiento = [
        { label: 'Id de Financiamiento',    fieldName: 'proforma' },
        { label: 'Versión',                 fieldName: 'version'},
        { label: 'Sociedad',                fieldName: 'bukrs'},
        { label: 'Proyecto',                fieldName: 'processo'},
        { label: 'Estado de Financiamiento',fieldName: 'estadoFinanciamientoFormateado'},
        { label: 'Urbanización',            fieldName: 'urbanizacion'},
    ];
    dataFinanciamiento  =   [];
    //Obtener data de financiamiento
    @api recordId;
    @api idCaso;
    @api idLog;
    busquedaFinanciamiento() {
        this.mostrarSpinner =   true;
        getLotesFinanciamientos({
            idCaso  : this.recordId
        })
        .then((result)  =>  {
            console.log('result: '+ result);
            console.log('result: '+ JSON.stringify(result));
            this.dataFinanciamiento         =   result.financiamientos;
            this.idLog                      =   result.financiamientos[0].idLog;
            this.mostrarSpinner             =   false;
            this.relateCaseLogSave();
        }
        ).catch((error) =>  {
            console.log('error: '+error);
        }
        );
    }

    //Método futuro
    async relateCaseLogSave(){
        relateCaseLog({
            idCaso  :   this.recordId,
            idLog   :   this.idLog
        }).then((result)    =>  {
            console.log('result relateCaseLog: '+result);
            this.dispatchEvent(new RefreshEvent());
        }).catch((error) =>  {
            console.log('error: '+error);
            this.dispatchEvent(new RefreshEvent());
        }
        );
    }

    //Data de Lotes
    dataLotes       =[];
    columnsLotes    = [
        //{ label: 'Id de Lote SAP',          fieldName: 'idLoteSap' },
        { label: 'Lote',                    fieldName: 'nombreLote',    wrapText: true},
        //{ label: 'Material',                fieldName: 'codLote'},
        { label: 'Importe Precio Venta',    fieldName: 'valorFormateado'},
        //{ label: 'Estado de Lote',          fieldName: 'estadoLote'},
        //{ label: 'Sub Estado de Lote',      fieldName: 'subestadoLote'},
        { label: 'Manzana',                 fieldName: 'manzana'},
        { label: 'Lote',                    fieldName: 'lote'},
    ];
    financiamientoSeleccionadoValue  =   '';
    lotesSeleccionados               =   [];
    proforma = '';
    financiamientoSeleccionado(event) {
        const selectedRow                       =   event.detail.selectedRows;
        this.desactivarSiguiente                =   false;
        this.dataLotes                          =   selectedRow[0].lotes;
        this.financiamientoSeleccionadoValue    =   selectedRow[0];
        this.proforma                           =   selectedRow[0].proforma;
        //console.log('financiamiento seleccionado: ',JSON.stringify(this.financiamientoSeleccionadoValue));
        console.log('proforma:',JSON.stringify(selectedRow[0].proforma));
        //console.log('lotes del financiamiento: ', JSON.stringify(selectedRow[0].lotes));
    }
    loteSeleccionado(event) {
        const selectedRow           =   event.detail.selectedRows;
        this.desactivarSiguiente    =   false;
        this.lotesSeleccionados     =   selectedRow;
        console.log('Lotes Seleccionados:', JSON.stringify(selectedRow));
    }

    //Guardar Financiamientos y Lotes
    @api financiamiento='';
    @api lLotes ='';
    guardarFinanciamientosLotes(lotesGuardar){
        this.mostrarSpinner             =   true;
        console.log('financiamientoSeleccionadoValue guardar: '+JSON.stringify(this.financiamientoSeleccionadoValue));
        console.log('lotesSeleccionados guardar: '+JSON.stringify(this.lotesSeleccionados));

        saveFinanciamientoLotes({
            financiamiento  :   JSON.stringify(this.financiamientoSeleccionadoValue),
            lLotes          :   JSON.stringify(lotesGuardar),
            idCaso          :   this.recordId
        })
        .then((result)  =>  {
            console.log('result: '+ result);
            console.log('result: '+ JSON.stringify(result));
            this.closeModal();
            this.getFinanciamientoLotesResumen();
            this.listarCamposProyecto();
            window.location.reload();
        }
        ).catch((error) =>  {
            console.log('error: '+error);
        }
        );
    }
    listarCamposProyecto(){
        getCamposProyectosFin({
            numProforma : this.proforma,
            idCaso  : this.recordId
        })
        .then((result)  =>  {
            console.log('result: '+ result);
            console.log('result: '+ JSON.stringify(result));
        }
        ).catch((error) =>  {
            console.log('error: '+error);
        }
        );
    }


    connectedCallback() {
        this.getFinanciamientoLotesResumen();
        this.getRecordTypeDevelopername();
    }
    //Data inicial
    @track financiamientoResumen    =   [];
    @track lotesResumen             =   [];
    @track numeroFinanciamiento     =   '';
    @track estadoFinanciamiento     =   '';
    @track showFinanciamiento       =   false;
    getFinanciamientoLotesResumen() {
        getFinanciamientoLotesInicial({
            idCaso  : this.recordId
        })
        .then((result)  =>  {
            console.log('result xx: '+ result);
            console.log('result xx: '+ JSON.stringify(result));
            console.log('result xx: '+ JSON.stringify(result.financiamientos[0].proforma));

            this.financiamientoResumen      =   result.financiamientos[0];
            if(result.financiamientos[0].proforma    != null){
                this.showFinanciamiento         =   true; 
                this.numeroFinanciamiento       =   result.financiamientos[0].proforma;
                this.estadoFinanciamiento       =   result.financiamientos[0].estadoFinanciamiento;
                console.log('this.numeroFinanciamiento: '+this.numeroFinanciamiento);
            }
            if(result.financiamientos[0].lotes.length >0){
                this.lotesResumen           =   result.financiamientos[0].lotes;
            }else{
                this.lotesResumen           =   [];
            }

            console.log('numeroFinanciamiento: '+ this.numeroFinanciamiento);
            this.mostrarSpinner             =   false;
        }
        ).catch((error) =>  {
            console.log('error getFinanciamientoLotesResumen: '+JSON.stringify(error));
        }
        );
    }
    @track developerName            =   '';
    @track financiamientoLoteTitulo ='';
    getRecordTypeDevelopername(){
        getTipoDeRegistroDeveloper({
            idCaso  : this.recordId
        })
        .then((result)  =>  {
            console.log('result xx: '+ result);
            this.developerName             =   result;
            console.log('developerName: '+this.developerName);

            //Financiamiento
            if(this.developerName   === 'CEN_InteraccionPrepago' ||  this.developerName   === 'CEN_InteraccionUrbanoResolucion'){
                this.options                    =    [{ label: 'Financiamiento',  value: 'financiamiento' }];
                this.financiamientoOpenP2       =   true;
                this.financiamientoLoteTitulo   =   'Financiamiento';
                this.valorRadio                 =   'financiamiento';
                this.pasoSeleccionado           =   'financiamiento';
                this.botonSiguiente             =   'Guardar';
                this.steps = [
                    //{ label: 'Selección Financiamiento o Lote', value: 'financiamientoLote' },
                    { label: 'Financiamiento',                  value: 'financiamiento' },
                    //{ label: 'Lotes',                           value: 'lotes' },
                    
                ];
                this.columnsFinanciamiento = [
                    { label: 'Id de Financiamiento',    fieldName: 'proforma' },
                    { label: 'Versión',                 fieldName: 'version'},
                    { label: 'Sociedad',                fieldName: 'bukrs'},
                    { label: 'Proyecto',                fieldName: 'processo'},
                    { label: 'Estado de Financiamiento',fieldName: 'estadoFinanciamientoFormateado'},
                    { label: 'Urbanización',            fieldName: 'urbanizacion'},
                    { label: 'Lotes',                   fieldName: 'lotesConcatenados'}
                ];
                console.log('Interaccion Urbano');
                //this.columnsFinanciamiento.push({label: 'Financiamiento',  fieldName: 'financiamiento'});
            }
            //Financiamiento y Lotes
            else{
                this.financiamientoOpenP2                =   true;
                this.financiamientoLoteTitulo   =   'Financiamiento y Lotes'
                this.valorRadio                 =   'lotes';
                this.pasoSeleccionado           =  'financiamiento';
                this.steps = [
                    //{ label: 'Selección Financiamiento o Lote', value: 'financiamientoLote' },
                    { label: 'Financiamiento',                  value: 'financiamiento' },
                    { label: 'Lotes',                           value: 'lotes' },
                    
                ];


            }
            if(this.developerName   === 'CEN_InteraccionUrbanoResolucion'){
                
            }
        }
        ).catch((error) =>  {
            console.log('error getRecordTypeDevelopername: '+JSON.stringify(error));
        }
        );
    }
    
}