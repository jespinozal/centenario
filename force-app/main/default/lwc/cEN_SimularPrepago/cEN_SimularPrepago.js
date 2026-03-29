/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * @last modified by  : Felipe Bermudez - NTT DATA / campo nuevo interesxPagSinPrepago
 * @last modified by  : Felipe Bermudez - NTT DATA / limitar renderizar EJECUTAR PREPAGO para callcenter
**/

import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import downloadPdf                  from "@salesforce/apex/CEN_SimularPrepago.downloadPdf";
import getResumenFinanciamiento     from "@salesforce/apex/CEN_SimularPrepago.getResumenFinanciamiento";
import getResumenCuotas             from "@salesforce/apex/CEN_SimularPrepago.getResumenCuotas";
import generarDocumentosApi         from "@salesforce/apex/CEN_SimularPrepago.generarDocumentosApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IMPORTE_DE_FINANCIAMIENTO    from "@salesforce/schema/Case.CEN_ImporteDeFinanciamiento__c";
import TIPO_DE_PREPAGO              from "@salesforce/schema/Case.CEN_TipoDePrepago__c";
import relateCaseLog                from "@salesforce/apex/CEN_LotesFinanciamientoCasos.relateCaseLog";
import findAccounts                from "@salesforce/apex/CEN_SimularPrepago.findAccounts";

import { RefreshEvent }             from 'lightning/refresh';
import validateProfile             from "@salesforce/apex/CEN_SimularPrepago.isCallCenterUser";


/*import jsPDF from '@salesforce/resourceUrl/jsPDFLibrary';
import html2canvas from '@salesforce/resourceUrl/html2canvas';
import purify from '@salesforce/resourceUrl/purify';
import autotable from '@salesforce/resourceUrl/autotable';


import { loadScript } from 'lightning/platformResourceLoader';*/



const FIELDS = [IMPORTE_DE_FINANCIAMIENTO, TIPO_DE_PREPAGO];
export default class CEN_SimularPrepago extends LightningElement {
    //Valores iniciales del modal
    @track isModalOpen                  =   false;
    @track mostrarSpinner               =   false;
    @track tituloModalSimulacion        =   '';
    @track steps                        =   [];
    @track pasoSeleccionado             =   '';
    @track botonSiguiente               =   'Siguiente';
    @track desactivarAnterior           =   false;
    @track desactivarSiguiente          =   true;
    //Variables de Pantallas de Simulación de Prepago
    @track P1SimulacionResumenFinanciamiento    =   false;
    @track P2SimulacionTipoDeCuotas             =   false;
    @track P3SimulacionResumenDePagos           =   false;
    //Variables de Pantallas de Ejecución de Prepago
    @track P1EjecucionValidacionDatos           =   false;
    @track P2EjecucionResumen                   =   false;
    //Variables de Generar documentos
    @track P1GenerarDocumentos                  =   false;
    @track P2GenerarDocumentos                  =   false;

    //Variables de dataSimulacionResumenFinanciamiento
    @track dataSimulacionResumenFinanciamiento  =   [];
    columnsSimulacionResumenFinanciamiento      =   [
                                                    { label: 'Financiamiento',  fieldName: 'financiamiento' },
                                                    { label: 'Proyecto',        fieldName: 'proyecto'},
                                                    { label: 'Precio',          fieldName: 'precio'},

                                                    ];
    //Radio Inicial
    @track optionsRadioInicial=[];
    @track fechaPrepago;
    @track fechaPrepagoEjecucion;


    jsPdfInitialized=false;

    @track isCallCenter = false;

    connectedCallback(){
        // this.getDatosEjecucion();
        const currentDate = new Date();
        this.fechaPrepago = currentDate.toISOString().split('T')[0];
        
        //Valida si el usaurio que interactua con la INTERACCION es tipo CALLCENTER (true y false)
        validateProfile()
            .then(result => {
                console.log('Profile' + result);
                this.isCallCenter = result;
                this.getDatosEjecucion();
                 // true o false
            })
            .catch(error => {
                console.error(error);
                this.isCallCenter = null; // o manejar error como prefieras
                this.getDatosEjecucion();
            });

    }
    handleFechaChange(event) {
        // Obtener el valor de la fecha
        this.fechaPrepago = event.target.value;
        console.log('Fecha de prepago:', this.fechaPrepago);
    }
    handleFechaEjecucionChange(event) {
        // Obtener el valor de la fecha
        this.fechaPrepagoEjecucion = event.target.value;
        console.log('Fecha de prepago:', this.fechaPrepagoEjecucion);
    }
    @track valorRadioInicial            =   '';
    seleccionRadioInicial(event){
        this.valorRadioInicial          =   event.target.value;
        this.desactivarBotonSiguienteInicial   =   false;

        console.log('valor de radio: '+this.valorRadioInicial);
        if(this.valorRadioInicial       === 'simularPrepagoRadio'){
            this.tituloModalSimulacion  =   'Simular Prepago';
            this.steps                  =   [
                                                { label: 'Tipo de Cuotas',      value: 'pasoTipoDeCuotas' },
                                                { label: 'Resumen de Pagos',    value: 'pasoResumenDePagos' },
                                            ];
            this.pasoSeleccionado       =   'pasoTipoDeCuotas';

        }else if(this.valorRadioInicial     === 'ejecutarPrepagoRadio'){
            
            this.tituloModalSimulacion  =   'Ejecutar Prepago';
            this.steps                  =   [
                                        { label: 'Ejecución de Prepago',    value: 'ejecucionDePrepago' },
                                        { label: 'Resumen de Ejecución',    value: 'resumenDeEjecucion' },
            ];
            this.pasoSeleccionado       =   'ejecucionDePrepago';

        }else if(this.valorRadioInicial     === 'generarDocumentosRadio'){
            this.tituloModalSimulacion  =   'Generar Documentos';
            this.steps                  =   [
                                        { label: 'Confirmación',        value: 'confirmacionDocumentos' },
                                        { label: 'Vista de Documentos', value: 'vistaDeDocumentos' },
                                        ];
            this.pasoSeleccionado       =   'confirmacionDocumentos';
        }
    }
    //Botón Siguiente
    @track desactivarBotonSiguienteInicial     =   true;
    
    closeModal() {
        this.isModalOpen                =   false;
        this.botonSiguiente                     =   'Siguiente';
        //this.P1SimulacionResumenFinanciamiento  =   true;
        this.pasoSeleccionado                       =   '';
        if(this.valorRadioInicial   === 'simularPrepagoRadio'){
            this.P2SimulacionTipoDeCuotas           =   true;
            this.P3SimulacionResumenDePagos         =   false;
            this.P1EjecucionValidacionDatos         =   false;
            this.P2EjecucionResumen                 =   false;
        }else if(this.valorRadioInicial   === 'ejecutarPrepagoRadio'){
            this.P2SimulacionTipoDeCuotas           =   false;
            this.P3SimulacionResumenDePagos         =   false;
            this.P1EjecucionValidacionDatos         =   true;
            this.P2EjecucionResumen                 =   false;
        }
        
    }
    openModal(){
        this.isModalOpen    =   true;
        if(this.valorRadioInicial       === 'simularPrepagoRadio'){
            this.pasoSeleccionado   =   'pasoTipoDeCuotas';
            this.simulacionDePrepago();

        }else if(this.valorRadioInicial     === 'ejecutarPrepagoRadio'){
            this.pasoSeleccionado   =   'ejecucionDePrepago';
            this.ejecucionDePrepago();
            

        }else if(this.valorRadioInicial     === 'generarDocumentosRadio'){
            this.generacionDeDocumentos();

        }
    }
    generacionDeDocumentos(){
        if(this.pasoSeleccionado    === 'confirmacionDocumentos'){
            this.P1SimulacionResumenFinanciamiento  =   false;
            this.P2SimulacionTipoDeCuotas           =   false;
            this.P3SimulacionResumenDePagos         =   false;
            this.P1EjecucionValidacionDatos         =   false;
            this.P2EjecucionResumen                 =   false;
            this.P1GenerarDocumentos                =   true;
            this.botonSiguiente                     =   'Siguiente';
        }
        

    }

    //EJECUCION DE PREPAGO
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    caso;
    @track valueRadioP1EjecucionValidacionDatos  =   '';
    @track valueimporteRefinanciacionCambioEjecucion;
    ejecucionDePrepago(){
        if(this.pasoSeleccionado        ===     'ejecucionDePrepago'){
            this.desactivarAnterior                 =   true;
            this.getDatosEjecucion();
            this.P1SimulacionResumenFinanciamiento  =   false;
            this.P2SimulacionTipoDeCuotas           =   false;
            this.P3SimulacionResumenDePagos         =   false;
            this.P1EjecucionValidacionDatos         =   true;

        }else if(this.pasoSeleccionado  ===     'resumenDeEjecucion'){

        }
    }
    //@track importeRefinanciacionEjecucion    =   this.valueimporteRefinanciacionCambioEjecucion;
    @track importeRefinanciacionEjecucion    =   0;
    
    importeRefinanciacionCambioEjecucion(event){
        this.desactivarBotonSiguienteInicial   =   false;
        console.debug(' importe:'   +   event.detail.value);
        this.importeRefinanciacionEjecucion  =   event.detail.value;
        if(this.importeRefinanciacionEjecucion == 0  || this.importeRefinanciacionEjecucion==''){
            this.desactivarSiguiente    =   true;
        }else{
            this.desactivarSiguiente    =   false;
        }
        
    }
    @track tipoDePrepagoResumen     =   '';
    @track financiamientoActivo     =   false;
    @track financiamientoInactivo   =   false;
    getDatosEjecucion(){
        getResumenFinanciamiento({
            idCaso  : this.recordId
        })
        .then((result)  =>  {
            console.log('result: '+ result);
            console.log('result: '+ JSON.stringify(result));
            this.tipoDePrepagoResumen       =   result.tipoDePrepago;
            if(result.tipoDePrepago    ==  'Mantener Cuota'){
                this.valueRadioP1EjecucionValidacionDatos   =   'mantenerCuotaRadio';
            }else if(result.tipoDePrepago    ==  'Disminuir Cuenta'){
                this.valueRadioP1EjecucionValidacionDatos   =   'disminuirCuentaRadio';
            }
            this.valueimporteRefinanciacionCambioEjecucion  =   result.importeFinanciamiento;
            this.fechaPrepagoEjecucion  =   result.fechaDePrepago;
            if(this.valueimporteRefinanciacionCambioEjecucion == 0  || this.valueimporteRefinanciacionCambioEjecucion==''){
                this.desactivarSiguiente    =   true;
            }else{
                this.desactivarSiguiente    =   false;
            }
            this.pasoSeleccionado       =   'ejecucionDePrepago';

            console.log('result.estadoSap: '+result.estadoSap);
            if(result.estadoSap         ===  'Completado'){
                this.optionsRadioInicial=[
                    { label: 'Generar Documentos',  value: 'generarDocumentosRadio' }
                ]
            }else{ 
                if (this.isCallCenter) {
                    // Solo permitir "Simular Prepago" para callcenter
                    this.optionsRadioInicial = [
                        { label: 'Simular Prepago', value: 'simularPrepagoRadio' }
                    ];
                } else {
                    this.optionsRadioInicial = [
                        { label: 'Simular Prepago', value: 'simularPrepagoRadio' },
                        { label: 'Ejecutar Prepago', value: 'ejecutarPrepagoRadio' }
                    ];
                }
            }
            console.log('estado financiamiento: '+ result.estadoFinanciamiento);
            if(result.estadoFinanciamiento  === 'Activo'){
                this.financiamientoActivo   =   true;
                this.financiamientoInactivo =   false;
            }else if(result.estadoFinanciamiento    === 'Inactivo'  ||  result.estadoFinanciamiento === ''){
                this.financiamientoActivo   =   false;
                this.financiamientoInactivo =   true;
            }
        }
        ).catch((error) =>  {
            console.log('error: '+error);
        }
        );
    }
    @track optionsRadioP1EjecucionValidacionDatos =[
        { label: 'Mantener Cuota',      value: 'mantenerCuotaRadio' },
        { label: 'Disminuir Cuenta',    value: 'disminuirCuentaRadio' }
        ];
    @track radioP1EjecucionValidacionDatos    =   '';
    @track radioP1EjecucionValidacionDatosFinal    =   '';
    seleccionRadioP1EjecucionValidacionDatos(event){
        this.radioP1EjecucionValidacionDatosFinal   =   event.target.value;
       /* this.radioP1EjecucionValidacionDatos  =   event.target.value;
        console.log('evento: '+event.detail.value);
        const radio=event.detail.value;
        this.valueradioP1EjecucionValidacionDatos  =   radio;
        console.log('radio3: '+this.radioP1EjecucionValidacionDatos);
        console.log('radio3.1: '+this.valueradioP1EjecucionValidacionDatos);
*/
    }
    //SIMULACION DE PREPAGO
    simulacionDePrepago(){
        if(this.pasoSeleccionado        ===     'pasoTipoDeCuotas'){
            this.desactivarAnterior                 =   true;
            this.P2SimulacionTipoDeCuotas           =   true;
            this.P3SimulacionResumenDePagos         =   false;
            this.P1EjecucionValidacionDatos         =   false;
            console.log('now');
        }
    }
    @api idCaso;
    @api recordId;
    //PRIMERA PANTALLA DE SIMULACION DE PREPAGO
    
    
    //SEGUNDA PANTALLA DE SIMULACION DE PREPAGO
    @track optionsRadioP2SimulacionTipoDeCuotas =[
        { label: 'Mantener Cuota',      value: 'mantenerCuotaRadio' },
        { label: 'Disminuir Cuenta',    value: 'disminuirCuentaRadio' }
        ];
    @track radioP2SimulacionTipoDeCuotas    =   '';
    @track mostrarimporteRefinanciacion     =   false;
    seleccionRadioP2SimulacionTipoDeCuotas(event){
        this.radioP2SimulacionTipoDeCuotas  =   event.target.value;
        this.mostrarimporteRefinanciacion   =   true;
    }
    @track importeRefinanciacion    =   0;
    importeRefinanciacionCambio(event){
        this.desactivarBotonSiguienteInicial   =   false;
        console.debug(' importe:'   +   event.detail.value);
        this.importeRefinanciacion  =   event.detail.value;
        if(this.importeRefinanciacion == 0  || this.importeRefinanciacion==''){
            this.desactivarSiguiente    =   true;
        }else{
            this.desactivarSiguiente    =   false;
        }
        
    }
    //TERCERA PANTALLA DE SIMULACION DE PREPAGO
    @api tipoModo               =   '';
    @api cuota                  =   '';
    @api montoFinanciamiento    =   0;  
    @track resumenImporteSimulado       =   '';
    @track resumeninteresxPagSinPrepago       =   '';//Felipe
    @track resumentipoSimulacion        =   '';
    @track resumenCuotaActual           =   '';
    @track resumenNuevaCuota            =   '';
    @track resumenNroFinanciamiento     =   '';
    @track resumenFechaDeTermino        =   '';
    @track resumenfechaVencimientoProximaCuota        =   ''; 
    @track resumenfechaVencimientoUltimaCuota         =   '';
    @track resumenTotalDeCuotas         =   '';
    @track resumenPrecioDeVentas        =   '';
    @track resumenCapitalAmortizado     =   '';
    @track resumencapitalAmortizadoDespues  =   '';
    @track resumenSaldoDeCapital        =   '';
    @track resumensaldoDeCapitalDespues =   '';
    @track resumeninteresesPorPagarAntes    =   '';
    @track resumeninteresesPorPagarDespues  =   '';
    @track resumenPrepago               =   '';
    @track resumenUltimaCuota           =   '';
    @track resumenMensajeServicio       =   '';
    @track resumenEstado                =   '';
    @track resumenCuotasPorPagar        =   '';
    @track idLog                        =   '';
    @track mostrarResumen               =   false;
    @track mostrarError                 =   false;

    getCuotas(tipoDeCuota, monto, fechaPrepago){
        console.log('getCuotas');
        console.log('idApoderado1.id: '+this.idApoderado1);
        console.log('idApoderado2.id: '+this.idApoderado2);

        getResumenCuotas({
            tipoModo            :   this.valorRadioInicial,
            cuota               :   tipoDeCuota,
            idCaso              :   this.recordId,
            montoFinanciamiento :   monto,
            fecha               :   fechaPrepago,
            idApoderado1        :   this.idApoderado1,
            idApoderado2        :   this.idApoderado2

        })
        .then((result)  =>  {
            console.log('getResumenCuotas');
            console.log('result: '+ result);
            // console.log('Cabecera: '+ JSON.stringify(result.extras.interesxPagSinPrepago2));
            console.log('result: '+ result.importeSimulado);
            
            this.resumenImporteSimulado     =   result.importeSimulado;
            this.resumentipoSimulacion      =   result.tipoSimulacion;
            this.resumenCuotaActual         =   result.cuotaActual;
            this.resumenNuevaCuota          =   result.nuevaCuota;
            this.resumenCuotasPorPagar      =   result.cuotasPorPagar;
            this.resumenNroFinanciamiento   =   result.nroFinanciamiento;
            this.resumenUltimaCuota         =   result.ultimaCuota;
            this.resumenFechaDeTermino      =   result.fechaDeTermino;
            this.resumenfechaVencimientoProximaCuota    =   result.fechaVencimientoProximaCuota;
            this.resumenfechaVencimientoUltimaCuota     =   result.fechaVencimientoUltimaCuota;
            this.resumenTotalDeCuotas                   =   result.totalDeCuotas;
            this.resumenPrecioDeVentas                  =   result.precioDeVentas;
            this.resumenCapitalAmortizado               =   result.capitalAmortizado;
            this.resumencapitalAmortizadoDespues        =   result.capitalAmortizadoDespues;
            this.resumenSaldoDeCapital                  =   result.saldoDeCapital;
            this.resumensaldoDeCapitalDespues       =   result.saldoDeCapitalDespues;
            this.resumeninteresesPorPagarAntes      =   result.interesesPorPagarAntes;
            this.resumeninteresesPorPagarDespues    =   result.interesesPorPagarDespues;
            this.resumenPrepago             =   result.prepago;
            this.dataPreview                =   result.detalles;
            this.resumenMensajeServicio     =   result.mensajeServicio;
            this.resumenEstado              =   result.estado;
            this.idLog                      =   result.idLog;
            this.mostrarSpinner             =   false;
            this.resumeninteresxPagSinPrepago             =   result.interesxPagSinPrepago2;//Felipe

            if(this.resumenEstado   === 'COMPLETADO'    && this.valorRadioInicial === 'ejecutarPrepagoRadio'){
                this.optionsRadioInicial=[
                    { label: 'Generar Documentos',  value: 'generarDocumentosRadio' }
                ];
            }
            if(this.resumenEstado   === 'COMPLETADO'    && this.valorRadioInicial === 'simularPrepagoRadio'){
                this.mostrarResumen =   true;
                this.mostrarError   =   false;
            }else if(this.resumenEstado   === ''    && this.valorRadioInicial === 'simularPrepagoRadio'){
                this.mostrarResumen =   false;
                this.mostrarError   =   true;

            }
            this.relateCaseLogSave();
        }
        ).catch((error) =>  {
            console.log('error: '+JSON.stringify(error));
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

    
    pasoSiguiente(){
        console.log('valorRadioInicial: '   + this.valorRadioInicial);
        console.log('pasoSeleccionado: '    + this.pasoSeleccionado);
        if(this.valorRadioInicial       === 'simularPrepagoRadio'){
            if(this.pasoSeleccionado    === 'pasoResumenDeFinanciamiento'){
                this.desactivarAnterior                 =   false;
                this.desactivarSiguiente                =   true;
                this.P1SimulacionResumenFinanciamiento  =   false;
                this.P2SimulacionTipoDeCuotas           =   true;
                this.P3SimulacionResumenDePagos         =   false;
                this.pasoSeleccionado                   =   'pasoTipoDeCuotas';
            }else if(this.pasoSeleccionado    === 'pasoTipoDeCuotas'){
                this.mostrarSpinner                     =   true;
                this.desactivarAnterior                 =   false;
                this.desactivarSiguiente                =   false;
                this.P1SimulacionResumenFinanciamiento  =   false;
                this.P2SimulacionTipoDeCuotas           =   false;
                this.P3SimulacionResumenDePagos         =   true;
                this.getCuotas(this.radioP2SimulacionTipoDeCuotas,  this.importeRefinanciacion, this.fechaPrepago);
                this.botonSiguiente                     =   'Descargar';
                this.pasoSeleccionado                   =   'pasoResumenDePagos';
            }
            else if(this.pasoSeleccionado    === 'pasoResumenDePagos'){
                this.mostrarSpinner             =   false;

                this.generatePdf();
            }
        }else if(this.valorRadioInicial     === 'ejecutarPrepagoRadio'){

            this.tituloModalSimulacion  =   'Ejecutar Prepago';
            if(this.radioP1EjecucionValidacionDatos!=null && (this.valueimporteRefinanciacionCambioEjecucion == 0 || this.valueimporteRefinanciacionCambioEjecucion =='')){
                this.desactivarSiguiente                =   false;
            }
            if(this.pasoSeleccionado    === 'ejecucionDePrepago'){
                this.openConfirmacion                   =   true;

            }else if(this.pasoSeleccionado    === 'resumenDeEjecucion'){
                this.tituloModalSimulacion  =   'Generar documentos';
                this.botonSiguiente         =   'Generar documentos';
                this.P2EjecucionResumen     =   false;
                this.P1GenerarDocumentos    =   true;
                this.steps                  =   [
                    { label: 'Confirmación',        value: 'confirmacionDocumentos' },
                    { label: 'Vista de Documentos', value: 'vistaDeDocumentos' },
                ];
                this.pasoSeleccionado       =   'confirmacionDocumentos';
                this.valorRadioInicial      =   'generarDocumentosRadio';

            }

        }else if(this.valorRadioInicial     === 'generarDocumentosRadio'){
            if(this.pasoSeleccionado    === 'confirmacionDocumentos'){
                this.desactivarAnterior                 =   true;
                this.desactivarSiguiente                =   true;
                this.mostrarSpinner                     =   true;
                this.tituloModalSimulacion              =   'Generar Documentos';
                this.pasoSeleccionado                   =   'vistaDeDocumentos';
                this.P1SimulacionResumenFinanciamiento  =   false;
                this.P2SimulacionTipoDeCuotas           =   false;
                this.P3SimulacionResumenDePagos         =   false;
                this.P1EjecucionValidacionDatos         =   false;
                this.P2EjecucionResumen                 =   false;
                this.P1GenerarDocumentos                =   false;
                this.P2GenerarDocumentos                =   true;
                this.getDocumentos();
            }
            


        }
    }
    pasoAnterior(){
        console.log('valorRadioInicial anterior : '    +this.valorRadioInicial);
        console.log('pasoSeleccionado anterior: '     +this.pasoSeleccionado);
        if(this.valorRadioInicial       === 'simularPrepagoRadio'){
            if(this.pasoSeleccionado    === 'pasoResumenDeFinanciamiento'){
                
            }else if(this.pasoSeleccionado    === 'pasoTipoDeCuotas'){
                this.desactivarAnterior                 =   true;
                this.desactivarSiguiente                =   false;
                this.P1SimulacionResumenFinanciamiento  =   true;
                this.P2SimulacionTipoDeCuotas           =   false;
                this.P3SimulacionResumenDePagos         =   false;
                this.pasoSeleccionado                   =   'pasoResumenDeFinanciamiento';
            }
            else if(this.pasoSeleccionado    === 'pasoResumenDePagos'){
                this.desactivarSiguiente                =   true;
                this.desactivarAnterior                 =   true;
                this.botonSiguiente                     =   'Siguiente';
                this.mostrarimporteRefinanciacion       =   false;
                this.P1SimulacionResumenFinanciamiento  =   false;
                this.P2SimulacionTipoDeCuotas           =   true;
                this.P3SimulacionResumenDePagos         =   false;
                this.pasoSeleccionado                   =   'pasoTipoDeCuotas';
            }
        }else if(this.valorRadioInicial     === 'ejecutarPrepagoRadio'){
            if(this.pasoSeleccionado    =   '   resumenDeEjecucion'){
                this.desactivarAnterior                 =   true;
                this.P1SimulacionResumenFinanciamiento  =   false;
                this.P2SimulacionTipoDeCuotas           =   false;
                this.P3SimulacionResumenDePagos         =   false;
                this.P1EjecucionValidacionDatos         =   true;
                this.P2EjecucionResumen                 =   false;
                this.pasoSeleccionado                   =   'ejecucionDePrepago';
                if(this.valueimporteRefinanciacionCambioEjecucion == 0  || this.valueimporteRefinanciacionCambioEjecucion==''){
                    this.desactivarSiguiente    =   true;
                }else{
                    this.desactivarSiguiente    =   false;
                }
            }

        }else if(this.valorRadioInicial     === 'generarDocumentosRadio'){
            this.tituloModalSimulacion  =   'Generar Documentos';

        }
    }
    generatePdf(){

        

        let dataCronogramaPreview = JSON.stringify(this.dataPreview);
        downloadPdf({ 
            importeSimulado     :   this.resumenImporteSimulado,
            cuotaActual         :   this.resumenCuotaActual,
            nuevaCuota          :   this.resumenNuevaCuota,
            fechaDeTermino      :   this.resumenFechaDeTermino,
            totalDeCuotas       :   this.resumenTotalDeCuotas,
            precioDeVentas      :   this.resumenPrecioDeVentas,
            capitalAmortizado   :   this.resumenCapitalAmortizado,
            saldoDeCapital      :   this.resumenSaldoDeCapital,
            prepago             :   this.resumenPrepago,
            ultimaCuota         :   this.resumenUltimaCuota,
            cuotasPorPagar      :   this.resumenCuotasPorPagar,
            idCaso              :   this.recordId,
            tipoDeSimulacion    :   this.resumentipoSimulacion,
            nroFinanciamiento   :   this.resumenNroFinanciamiento,
            vencimientoProximaCuota     :   this.resumenfechaVencimientoProximaCuota,
            vencimientoUltimaCuota      :   this.resumenfechaVencimientoUltimaCuota,
            precioDeVentas              :   this.resumenPrecioDeVentas,
            capitalAmortizado           :   this.resumenCapitalAmortizado,
            capitalAmortizadoDespues    :   this.resumencapitalAmortizadoDespues,
            saldoDeCapital              :   this.resumenSaldoDeCapital,
            saldoDeCapitalDespues       :   this.resumensaldoDeCapitalDespues,
            interesesPorPagar           :   this.resumeninteresesPorPagarAntes,
            interesesPorPagarDespues    :   this.resumeninteresesPorPagarDespues,
            resumeninteresxPagSinPrepagoPDF2    :   this.resumeninteresxPagSinPrepago


        })
        .then((result) => {
            this.mostrarSpinner             =   false;
            const url = "data:application/pdf;base64," + result;
            console.log('url: '+url);
            const element = document.createElement("a");
            element.setAttribute("href", url);
            element.setAttribute("download", 'Documento de Prepago - '+this.resumenNroFinanciamiento);
            element.style.display = "none";
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
      })
      .catch((error) => {
        console.log("error downloadPdf:" + JSON.stringify(error));
      });
    }
    @track openConfirmacion     =   false;
    closeModalConfirmacion(){
        this.openConfirmacion   =   false;
        console.log('radio4.1: '+this.valueradioP1EjecucionValidacionDatos);
    }
    confirmacionEjecutarPrepago(){
        
        console.log('tipo 1x: '+ this.radioP1EjecucionValidacionDatosFinal);

        console.log('tipo 1: '+ this.valueRadioP1EjecucionValidacionDatos);
        if(this.valueRadioP1EjecucionValidacionDatos == ''){
            this.valueRadioP1EjecucionValidacionDatos   = this.radioP1EjecucionValidacionDatosFinal;
        }
        this.mostrarSpinner                     =   true;
        this.desactivarAnterior                 =   true;
        this.desactivarSiguiente                =   false;
        this.P1EjecucionValidacionDatos         =   false;
        this.P2EjecucionResumen                 =   true;
        this.pasoSeleccionado                   =   'resumenDeEjecucion';
        this.botonSiguiente                     =   'Generar documentos';
        this.openConfirmacion                   =   false;
        console.log('ejecutar disminuir: '+ this.valueimporteRefinanciacionCambioEjecucion);
        console.log('tipo 2: '+ this.valueRadioP1EjecucionValidacionDatos);
        console.log('this.importeRefinanciacionEjecucion: '+this.importeRefinanciacionEjecucion);
        if(this.importeRefinanciacionEjecucion == 0){
            this.getCuotas(this.valueRadioP1EjecucionValidacionDatos, this.valueimporteRefinanciacionCambioEjecucion, this.fechaPrepagoEjecucion);
        }else{
            this.getCuotas(this.valueRadioP1EjecucionValidacionDatos, this.importeRefinanciacionEjecucion, this.fechaPrepagoEjecucion);
        }
        

    }

    //Preview
    @ track columnsPreview  =[
        { label: 'TIPO DE CUOTA',   fieldName: 'tipoCuota' },
        { label: 'FECHA VENCIMIENTO',            fieldName: 'fechaVencimiento' },
        { label: 'SALDO INICIAL-CAPITAL A FINANCIAR',          fieldName: 'saldoInicialFormato' },
        { label: 'INTERES COMPENSATORIOS / GASTOS ADMINISTRATIVOS',       fieldName: 'interesesFormato' },
        { label: 'AMORTIZACIÓN A CAPITAL',          fieldName: 'amortizacionFormato' },
        { label: 'TOTAL CUOTA',        fieldName: 'impCuotaFormato' },
        { label: 'FECHA DE PAGO',           fieldName: 'fechaPago' },
        { label: 'SALDO CAPITAL',       fieldName: 'saldoFinalFormato' },
        // { label: 'N° Financiamiento',   fieldName: 'proforma' },
        // { label: 'N° cuota',            fieldName: 'cuota' },
        // { label: 'Tipo Cuota',          fieldName: 'tipoCuota' },
        // { label: 'Saldo Inicial',       fieldName: 'saldoInicialFormato' },
        // { label: 'Imp. Amort',          fieldName: 'amortizacionFormato' },
        // { label: 'Imp. Interes',        fieldName: 'interesesFormato' },
        // { label: 'IntGasAdm',           fieldName: 'interesGastosFormato' },
        // { label: 'Importe Cuota',       fieldName: 'impCuotaFormato' },
        // { label: 'Saldo Final',         fieldName: 'saldoFinalFormato' },
        // { label: 'Indicador Pagado',    fieldName: 'flagPagado' },
        // { label: 'Fecha Vencimiento',   fieldName: 'fechaVencimiento' },

    ];
    @track dataPreview = [];
    @track documentoUrl             =   '';
    @track documentoFechaCarga      =   '';
    @track documentoRespuesta       =   '';
    @track documentoMensaje         =   '';

    getDocumentos(){
        generarDocumentosApi({
            idCaso  :   this.recordId
        })
        .then((result) => {
            console.log('documentos: '+JSON.stringify(result));
            console.log('documentos: '+JSON.stringify(result.Response));

            this.documentoRespuesta         =   result.codigoRespuesta;
            this.documentoFechaCarga        =   result.fechaCarga + ' ' + result.horaCarga;
            this.documentoMensaje           =   result.mensajeRespuesta;
            this.documentoUrl               =   result.urlDocumento;
            this.mostrarSpinner             =   false;
            this.idLog                      =   result.idLog;
            this.relateCaseLogSave();
        })
        .catch((error) => {
          console.log("error " + error);
        });
    }

    //BUSQUEDA DE APODERADOS
    @track apoderado1selec;
    @track apoderado2selec;

    @track idApoderado1 ='';
    @track idApoderado2 ='';
    handleValueSelectedOnAccount(event) {
        this.apoderado1selec = event.detail;
        this.idApoderado1   =   event.detail.id;

        console.log('record id: '+this.apoderado1selec.id);
        console.log('record : '+JSON.stringify(this.apoderado1selec));
        //this.idApoderado1 = parentAccountSelectedRecord.id;
    }

    handleValueSelectedOnAccount2(event) {
        this.apoderado2selec = event.detail;
        this.idApoderado2   =   event.detail.id;
        console.log('record id: '+this.apoderado2selec.id);
        console.log('record : '+JSON.stringify(this.apoderado2selec));


        //this.idApoderado2 = parentAccountSelectedRecord2.id;
    }

}