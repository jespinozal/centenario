import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class WcCEN_DateTimeCustom extends LightningElement {

    @track dateTrack;
    @track timeTrack;

    @track _propDateTime = '';
    @api
    get propDateTime(){
        return this._propDateTime;
    }
    set propDateTime(val){
        this._propDateTime = val;
    }

    @track _propDateTimeServer = '';
    @api
    get propDateTimeServer(){
        return this._propDateTimeServer;
    }
    set propDateTimeServer(val){
        this._propDateTimeServer = val;
    }

    @track _propTimeCheck = '';
    @api
    get propTimeCheck(){
        return this._propTimeCheck;
    }
    set propTimeCheck(val){
        this._propTimeCheck = val;
    }

    @track checked = true;
    @track disabledInput = false;

    changeToggle(event){
        var inp=this.template.querySelectorAll("lightning-input");       
        this.checked = !this.checked;
        this.disabledInput = !this.disabledInput;
 
        // inp.forEach(function(element){
        //     if(element.name=="inDate"){
        //         this.dateTrack = element.value;
        //     } else if(element.name=="inTime"){
        //         this.timeTrack = element.value;
        //     }
        // },this);

        if(!this.checked){
            this.timeTrack = '00:00:00';
        }else{
            inp.forEach(function(element){
                if(element.name=="inDate"){
                    this.dateTrack = element.value;
                } else if(element.name=="inTime"){
                    this.timeTrack = element.value;
                }
            },this);
        }

        this._propDateTime = this.dateTrack + ' ' + this.timeTrack;
        this._propTimeCheck = this.checked;
        //console.log(this.timeTrack);
        //console.log(this.checked);
    }

    // sampleValidate.js
    @api
    validate() {

        //console.log('this.timeTrack ' + this.timeTrack); 
        var cadena = this.timeTrack;
        var resultTime = true;
        
        if(this.timeTrack != ''){
            resultTime = /^([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])$/.test(cadena);
        }
        var msg = '';

        var today = new Date();
        today.setHours(0,0,0,0);
        //console.log('resultTime ' + resultTime); 
        var fecha = new Date(this._propDateTime);
        fecha.setHours(0,0,0,0);

        // console.log('fecha ' + fecha); 
        // console.log('today ' + today);

        if(this.dateTrack === '') { 
            msg = 'Completar este campo.'; 
        }else if(this.dateTrack  == null){
            msg = 'Ingresar Fecha';
        }else if(!resultTime){
            msg = 'Formato de 24 horas no válido hh:mm:ss.'; 
        }else if(fecha > today){
            msg = 'Fecha de pago es mayor a la fecha actual.'; 
        }else if(this.checked){
            if(this.timeTrack === ''){
                msg = 'Ingrese hora de la transferencia.'; 
            }
        } 

        if(msg){
            return { 
                isValid: false, 
                errorMessage: msg 
            };
        }else{
            return { isValid: true }; 
        }
    }

    handleDateTimeInputMask(event) {
        // var dateTrack;
        // var timeTrack;
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="inDate"){
                this.dateTrack = element.value;
            } else if(element.name=="inTime"){
                this.timeTrack = element.value;
            }
        },this);

        // if(this.checked){
        //     this.timeTrack = this.timeTrack === '' ? '00:00:00' : this.timeTrack; 
        // }else{
        //     this.timeTrack = '00:00:00';
        // }
        this._propDateTime = this.dateTrack + ' ' + this.timeTrack;

        var Strfecha = this.dateTrack + ' ' + this.timeTrack + 'Z';
        var fecha = new Date(Strfecha);
        var horaCalculada = fecha.getUTCHours() + 5;
        var horaServidor = 0;

        //console.log('horaCalculada ' + horaCalculada);
        if(horaCalculada >= 24){
            horaServidor = horaCalculada - 24;
            fecha.setDate(fecha.getDate() + 1);
        }
        else if(horaCalculada >= 5 && horaCalculada < 10){
            horaServidor = horaCalculada;
            fecha.setDate(fecha.getDate() + 1);
        }
        else{
            horaServidor = horaCalculada;
        }

        //console.log('horaServidor ' + horaServidor);

        let day = fecha.getDate()
        let month = fecha.getMonth() + 1
        let year = fecha.getFullYear()

        this._propDateTimeServer = year + '-' + month + '-' + day + ' ' + horaServidor + ':' + fecha.getMinutes() + ':' + fecha.getSeconds();
        this._propTimeCheck = this.checked;
        
        //console.log('this.timeTrack ' + this.timeTrack);
        //console.log('this._propDateTimeServer ' + this._propDateTimeServer) ;
        // console.log('hora ' +this.timeTrack );
        // console.log('fecha ' + this.dateTrack );
    }
}