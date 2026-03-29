import { LightningElement, track, api } from 'lwc';

export default class lwcSimuladorFinanciamiento extends LightningElement {
    // Inputs
    @track producto = '';
    @track porcentajeInicial = 0;
    @track area = 0;
    @track precioM2 = 0;
    @track montoFinanciar = 0;
    @track tea = 11; // TEA en %
    @track numCuotas = 0;
    @track fechaVencimiento = ''; // fecha del primer vencimiento (YYYY-MM-DD desde lightning-input type=date)

    // Resultados y tabla
    @track resultados = [];
    @track tablaAmortizacion = [];

    @api
    get setProducto() {
        return this.producto;
    } 
    set setProducto(value){
        this.producto = value;
    }

    
    @api
    get setArea() {
        return this.area;
    } 
    set setArea(value){
        this.area = value;
    }
    @api
    get setPrecioM2() {
        return this.precioM2;
    } 
    set setPrecioM2(value){
        this.precioM2 = value;
    }

    @api
    get setMontoFinanciar() {
        return this.montoFinanciar;
    }
    set setMontoFinanciar(value){
        this.montoFinanciar = value;
    }


    handleChange(event) {
        const field = event.target.dataset.field;
        // Guardar valores numéricos donde apliquen
        if (['porcentajeInicial','area','precioM2','montoFinanciar','tea','numCuotas'].includes(field)) {
            // si viene vacío, poner 0
            const val = event.target.value;
            this[field] = (val === '' || val === null) ? 0 : Number(val);
        } else {
            this[field] = event.target.value;
        }
    }

    // Función PMT: devuelve el pago periódico (positivo)
    // rate: tasa periódica (ejemplo TEM como decimal), nper: número de períodos, pv: monto a financiar (positivo)
    pmt(rate, nper, pv) {
        if (!nper || nper <= 0) return 0;
        if (!rate || rate === 0) {
            // sin interés
            return pv / nper;
        }
        const r = rate;
        const payment = (pv * r) / (1 - Math.pow(1 + r, -nper));
        return payment;
    }

    calcular() {
        // Normalizar inputs
        const area = Number(this.area) || 0;
        const precioM2 = Number(this.precioM2) || 0;
        const montoFinanciarInput = Number(this.montoFinanciar) || 0;
        const porcentajeInicial = Number(this.porcentajeInicial) || 0;
        const teaPct = Number(this.tea) || 0; // TEA en %
        const n = Math.floor(Number(this.numCuotas) || 0);

        // Formateador local (es-PE)
        const nf = new Intl.NumberFormat('es-PE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

        // Cálculos
        const precioContado = area * precioM2;
        const montoFinanciar = (montoFinanciarInput > 0) ? montoFinanciarInput : Math.max(0, precioContado - inicialValor);
        const porcentajeAFinanciar = (precioContado > 0) ? (montoFinanciar / precioContado) * 100 : 0;
        const inicialValor = precioContado * ((100 - porcentajeAFinanciar) / 100);
        const tem = (Math.pow(1 + (teaPct / 100), 1 / 12) - 1);
        const valorCuota = this.pmt(tem, n || 1, montoFinanciar);
        const valorFinal = valorCuota * (n || 1);
        const totalIntereses = valorFinal - montoFinanciar;
        const saldoCapitalAFinanciar = montoFinanciar;

        let primerVcto;
        if (this.fechaVencimiento) {
            const [year, month, day] = this.fechaVencimiento.split('-').map(Number);
            primerVcto = new Date(year, month - 1, day); 
        } else {
            primerVcto = new Date();
        }

        // Armar resultados para mostrar (orden legible)
        this.resultados = [
            { label: 'Precio Contado', value: nf.format(precioContado) },
            { label: 'Inicial Valor', value: nf.format(inicialValor) },
            { label: 'Porcentaje a Financiar (%)', value: nf.format(porcentajeAFinanciar) },
            { label: 'TEM (%)', value: nf.format(tem * 100) },
            { label: 'Valor Cuota', value: nf.format(valorCuota) },
            { label: 'Monto a Financiar', value: nf.format(montoFinanciar) },
            { label: 'Total Intereses con Financiamiento', value: nf.format(totalIntereses) },
            { label: 'Valor Final', value: nf.format(valorFinal) },
            { label: 'Saldo Capital a Financiar', value: nf.format(saldoCapitalAFinanciar) },
            { label: 'Fecha primer vencimiento', value: this.formatDate(primerVcto) }
        ];
        
        // =========================
        // TABLA DE AMORTIZACIÓN
        // =========================
        this.tablaAmortizacion = [];

        if (n > 0 && montoFinanciar > 0) {
            let saldoAnterior = montoFinanciar;
            //let fechaVcto = new Date(primerVcto);
            const fechaBaseVcto = new Date(primerVcto);
            //console.log('fechaVcto linea 129 '+ fechaVcto);
            // Variables para los totales
            let totalInteresesSum = 0;
            let totalCapitalSum = 0;
            let totalCuotaSum = 0;
            let totalPagoSum = 0;

            for (let i = 1; i <= n; i++) {
                const interesFinanciamiento = saldoAnterior * tem;
                const capital = valorCuota - interesFinanciamiento;
                const nuevoSaldo = saldoAnterior - capital;
                const totalCuota = valorCuota;
                const totalPago = totalCuota;
                const fechaVcto = this.addMonthsSmart(fechaBaseVcto, i - 1);

                totalInteresesSum += interesFinanciamiento;
                totalCapitalSum += capital;
                totalCuotaSum += totalCuota;
                totalPagoSum += totalPago;

                this.tablaAmortizacion.push({
                    numero: i,
                    fechaVcto: this.formatDate(fechaVcto),
                    saldoCapital: nf.format(saldoAnterior),
                    intereses: nf.format(interesFinanciamiento),
                    capital: nf.format(capital),
                    totalCuota: nf.format(totalCuota),
                    totalPago: nf.format(totalPago),
                    rowClass: ''
                });

                saldoAnterior = nuevoSaldo;
            }
            this.tablaAmortizacion.push({
                numero: '',
                fechaVcto: '',
                saldoCapital: 'Totales',
                intereses: nf.format(totalInteresesSum),
                capital: nf.format(totalCapitalSum),
                totalCuota: nf.format(totalCuotaSum),
                totalPago: nf.format(totalPagoSum),
                rowClass: 'slds-theme_shade slds-text-title_bold'
            });
        }


        

        // Dispatch the event
        this.dispatchEvent(new CustomEvent('childata', {
            detail: {
                numCuotas:this.numCuotas,

                tea:this.tea,
                fechaVencimiento: this.fechaVencimiento,
                
            }
        }));
    }

    // Corrige fechas como 31/01 → 28/02 → 31/03, etc.
    /* addMonthSmart(date) {
        console.log('parametro de addMonthSmart => ' + date);
        const d = new Date(date);
        const day = d.getDate();
        const newDate = new Date(d);
        console.log('newDate => ' + newDate);
        // x
        newDate.setMonth(newDate.getMonth() + 1);
        console.log('newDate.setMonth() => ' + newDate);
        // Si el mes cambió más de lo esperado, retrocede al último día del mes
        console.log('newDate.getMonth()  => ' + newDate.getMonth());
        console.log('(d.getMonth() + 1) % 12  => ' + (d.getMonth() + 1) % 12);
        while (newDate.getMonth() !== (d.getMonth() + 1) % 12) {
            newDate.setDate(newDate.getDate() - 1);
        }

        // Si el nuevo mes no tiene ese día (ej. 30 o 31 en feb), ajusta al último día
        console.log('newDate.setDate() => ' + newDate);
        console.log('newDate.setDate() => ' + newDate.getDate());
        console.log('day => ' + day);
        if (newDate.getDate() !== day) {
            console.log('entro a IF de linea 206');
            const month = newDate.getMonth();
            console.log('entro a IF de linea 209 ' + month);
            newDate.setMonth(month);
            newDate.setDate(0); // último día del mes anterior
            
        }
        //console.log('entro a IF de lina 214 ' + month);
        return newDate;
    } */
    
    addMonthsSmart(date, monthsToAdd) {
        const d = new Date(date);
        const originalDay = d.getDate();
    
        const newDate = new Date(d);
        newDate.setDate(1);
        newDate.setMonth(newDate.getMonth() + monthsToAdd);
    
        const lastDayOfTargetMonth = new Date(
            newDate.getFullYear(),
            newDate.getMonth() + 1,
            0
        ).getDate();
    
        newDate.setDate(Math.min(originalDay, lastDayOfTargetMonth));
    
        return newDate;
    }

    formatDate(date) {
        if (!date) return '';
        const d = new Date(date);
        const dd = String(d.getDate()).padStart(2, '0');
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const yyyy = d.getFullYear();
        return `${dd}/${mm}/${yyyy}`;
    }
}