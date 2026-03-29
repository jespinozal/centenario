import { LightningElement, track, wire,api } from 'lwc';
import getAvailableRooms from '@salesforce/apex/OFI_Salas_cls.getAvailableRooms';
import getRoomAvailability from '@salesforce/apex/OFI_Salas_cls.getRoomAvailability';
import createBooking from '@salesforce/apex/OFI_Salas_cls.createBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBookingsForMonth from '@salesforce/apex/OFI_Salas_cls.getBookingsForMonth';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import getRooms from '@salesforce/apex/OFI_Salas_cls.getRooms';

export default class OFI_Salas_lwc extends LightningElement {
    @track roomOptions = [];
    @track selectedRoomId;
    @track selectedDate;
    @track availableSlots = [];
    @track isLoading = false;
    @track message = '';

    @api isEmbedded;
    @api recordId;

    @track selectedRoomId = 'a01...'; // Reemplace con un ID de sala válido por defecto
    @track roomOptions = []; // Llenar con el resultado de getRoomsList()
    @track currentMonthYear;
    @track calendarDays = [];
    weekDays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    currentDate = new Date();

    get currentStage(){
        return this.path[this.pathSelector][this.stage-1];
    }

    pathSelector=0;
    path=[
        [1,2,3,4,5,6,7,8],
      
       
        
    ];


    roomAvailability=[];
    roomBooking=[];

    stage=1;
    officeSetupOpts=[
        {label:'Auditorio',value:'Auditorio'},
        {label:'Escuela',value:'Escuela'},
        {label:'Salón Libre',value:'Salón Libre'},
        {label:'Banquete',value:'Banquete'},
        {label:'Herradura',value:'Herradura'},
        
        
    ];
    startTimeOpts=[
        {label:'01:00',value:'1'},
        {label:'02:00',value:'2'},
        {label:'03:00',value:'3'},
        {label:'04:00',value:'4'},
        {label:'05:00',value:'5'},
        {label:'06:00',value:'6'},
        {label:'07:00',value:'7'},
        {label:'08:00',value:'8'},
        {label:'09:00',value:'9'},
        {label:'10:00',value:'10'},
        {label:'11:00',value:'11'},
        {label:'12:00',value:'12'},
        {label:'13:00',value:'13'},
        {label:'14:00',value:'14'},
        {label:'15:00',value:'15'},
        {label:'16:00',value:'16'},
        {label:'17:00',value:'17'},
        {label:'18:00',value:'18'},
        {label:'19:00',value:'19'},
        {label:'20:00',value:'20'},
        {label:'21:00',value:'21'},
        {label:'22:00',value:'22'},
        {label:'23:00',value:'23'},
        
    ]
    endTimeOpts=[];
    @track startTime='';
   @track endTime='';

    columns = [
        { label: 'Sala', fieldName: 'roomName'},
        { label: 'Fecha', fieldName: 'startDate'},
        { label: 'Hora Inicio', fieldName: 'startTime'},
        { label: 'Hora Fin', fieldName: 'endTime'},
        { label: 'Montaje', fieldName: 'officeSetup'},
        { label: 'Precio Total', fieldName: 'totalAmount', type: 'currency', typeAttributes: { currencyCode: 'PEN' , minimumFractionDigits: 2,
        maximumFractionDigits: 2}},
       
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Eliminar', name: 'delete' }] },
        },
        
    

    ];

    columnsAv = [
        { label: 'Sala', fieldName: 'roomName'},
        { label: 'Fecha', fieldName: 'startDate'},
        { label: 'Hora Inicio', fieldName: 'startTime'},
        { label: 'Hora Fin', fieldName: 'endTime'},
        { label: 'Montaje', fieldName: 'officeSetup'},
        { label: 'Precio Total', fieldName: 'totalAmount', type:'currency'},
       
       

    ];

    equipment=[];
    equipmentCols=[
        { label: 'Equipos AV y Otros', fieldName: 'name'},
        { label: 'Fecha', fieldName: 'rDate'},
        { label: 'Cantidad', fieldName: 'qty', type:'number'},
        { label: 'Precio Unitario', fieldName: 'unitAmount', type: 'currency', typeAttributes: { currencyCode: 'PEN' , minimumFractionDigits: 2,
        maximumFractionDigits: 2}},
        { label: 'Precio Total', fieldName: 'totalAmount', type: 'currency', typeAttributes: { currencyCode: 'PEN' , minimumFractionDigits: 2,
        maximumFractionDigits: 2}},

         {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Eliminar', name: 'delete' }] },
        },
        
    ];

    get nextStageLabel() {
        
        if(this.currentStage==1){
            return 'Continuar';
        }else if(this.currentStage==2){
            return 'Continuar';
        }else if(this.currentStage==3){
            return 'Guardar'
        }
    
    } 

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
console.log("###","row",JSON.stringify(row));
        if (actionName === 'delete') {
            this.deleteRowFromTable(row.id); // First, delete from the table
     
        }
    }

    handleRowActionE(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
console.log("###","row",JSON.stringify(row));
        if (actionName === 'delete') {
            this.deleteRowFromTableE(row.id); // First, delete from the table
     
        }
    }

    deleteRowFromTable(recordId) {
        let currentData = [...this.roomBooking];
        console.log("currentData",JSON.stringify(currentData));
        this.roomBooking = currentData.filter(item => item.id !== recordId);
        // Alternative using splice(): 
        // const index = currentData.findIndex(item => item.Id === recordId);
        // currentData.splice(index, 1);
        // this.data = [...currentData]; // Reassign with spread operator to ensure reactivity
    }

    deleteRowFromTableE(recordId) {
        let currentData = [...this.equipment];
        console.log("currentData",JSON.stringify(currentData));
        this.equipment = currentData.filter(item => item.id !== recordId);
        // Alternative using splice(): 
        // const index = currentData.findIndex(item => item.Id === recordId);
        // currentData.splice(index, 1);
        // this.data = [...currentData]; // Reassign with spread operator to ensure reactivity
    }


    handleStartTime(event){
        //endTime can be less than start time, endtime has to be always more then 4 hours
        //endtimeopts can be less than start time, endtime has to be always more then 4 hours 
        
        this.startTime=event.detail.value;
        
        this.endTimeOpts=[];
        for(let i=parseInt(this.startTime)+4;i<=24;i++){
            this.endTimeOpts.push({label:i.toString().padStart(2, '0') + ':00',value:i.toString()});
        }
    }

    handleAddEquipment(){
        this.equipment.push({
            id:Date.now(),
            name:this.refs.equipment.value,
            rDate:this.refs.rDate.value,
            qty:this.refs.qty.value,
            unitAmount:this.refs.unitAmount.value,
            totalAmount:(Number(this.refs.qty.value)*Number(this.refs.unitAmount.value)).toFixed(2),// this.refs.totalAmount.value,
        });
        this.equipment = this.equipment.slice(0);
        this.refs.equipment.value='';
        this.refs.rDate.value='';
        this.refs.qty.value='';
        this.refs.unitAmount.value='';
    }

    handleAddTime(){
        const startTime =this.refs.startTime.value;
        const endTime =this.refs.endTime.value;
        const officeSetup = this.refs.officeSetup.value;
        const totalAmount = this.refs.totalAmount.value;
        console.log('this.refs.startTime.value',this.refs.startTime.value,this.refs.startTime.value=='');
        let stopEx = false;
        // if (this.refs.startTime.value == '') {
        //     this.refs.startTime.setCustomValidity('No puede estar en blanco');
        //     stopEx = stopEx || true;
        // } else {
        //     stopEx = stopEx || false;
        //     this.refs.startTime.setCustomValidity('');
        // }
        // if (this.refs.endTime.value == '') {
        //     this.refs.endTime.setCustomValidity('No puede estar en blanco')
        //     stopEx = stopEx || true;
        // } else {
        //     this.refs.endTime.setCustomValidity('')
        //     stopEx = stopEx || false;
        // }
        // if (this.refs.officeSetup.value == '') {
        //     this.refs.officeSetup.setCustomValidity('No puede estar en blanco')
        //     stopEx = stopEx || true;
        // } else {
        //     this.refs.officeSetup.setCustomValidity('')
        //     stopEx = stopEx || false;
        // }
        if (this.refs.totalAmount.value <= 0||this.refs.totalAmount.value <= 0.00) {
            this.refs.totalAmount.setCustomValidity('Tiene que ser mayor a 0.');
            stopEx = stopEx || true;
        } else {
            this.refs.totalAmount.setCustomValidity('');
            stopEx = stopEx || false;
        }

        if(!stopEx){

        this.roomBooking.push({
            id:Date.now(),
            roomId:this.selectedRoomId,
            roomName:this.selectedRoomName,
            startDate:this.selectedDate,
            startTime:startTime,
            endTime:endTime,
            officeSetup:officeSetup,
            totalAmount:totalAmount,
        });
        this.roomBooking = this.roomBooking.slice(0);
        this.refs.startTime.value='';
        this.refs.endTime.value='';
        this.refs.officeSetup.value='';
        this.refs.totalAmount.value='';

        }
    }
    

    @wire(getRooms)
    wiredRooms({ error, data }) {
        if (data) {
            this.roomOptions = data.map(room => {
                console.log("###3",room);
                return { label: room.Product2.Name, value: room.Product2.Id };
            });
        } else if (error) {
            console.error('Error loading rooms', error);
        }
    }

    get slotsAvailable() {
        return this.availableSlots.length > 0;
    }

    get isBookingDisabled() {
        return !this.selectedRoomId || !this.selectedDate || this.availableSlots.filter(slot => slot.checked).length === 0;
    }

    // handleRoomChange(event) {
    //     this.selectedRoomId = event.detail.value;
    //     this.fetchAvailability();
    // }


    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new RefreshEvent());
    }


    handleDateChange(event) {
        this.selectedDate = event.detail.value;
        console.log("this.selectedDate",this.selectedDate);
        this.fetchAvailability();
    }

    fetchAvailability() {
        if (this.selectedRoomId && this.selectedDate) {
            this.isLoading = true;
            this.message = '';
            getRoomAvailability({ roomId: this.selectedRoomId, selectedDateString: this.selectedDate })
                .then(result => {
                    console.log('results',JSON.stringify(result));
                    const ra=[];
                    const pad = (num) => num.toString().padStart(2, '0');
                    const that=this;
                    result.forEach((r)=>{
                        const dt = new Date(r.OFI_fld_SalaReserva_Inicio__c);
                        const year = dt.getFullYear();
                        const month = pad(dt.getMonth() + 1); // getMonth() returns 0-11
                        const day = pad(dt.getDate());
                        const et = new Date(r.OFI_fld_SalaReserva_Fin__c);
                        ra.push({
                            'roomId':r.OFI_fld_SalaReserva_Producto__c,
                            'roomName':that.selectedRoomName,
                            'startDate':`${year}-${month}-${day}`,
                            'startTime':dt.toLocaleTimeString(),
                            'endTime':et.toLocaleTimeString(),

                        });
                    });
                    this.roomAvailability = ra.slice(0);
                    // result format: { 'Morning': true, 'Afternoon': false } (true means available)
                    this.availableSlots = [
                        { label: 'Mañana (8am - 12pm)', value: 'Half AM', checked: false, disabled: result.Morning },
                        { label: 'Tarde (1pm - 5pm)', value: 'Half PM', checked: false, disabled: result.Afternoon },
                        { label: 'Día Completo', value: 'Full', checked: false, disabled: (result.Morning && result.Afternoon) }
                    ];
                    this.isLoading = false;
                    console.log(JSON.stringify(this.availableSlots));
                })
                .catch(error => {
                    this.message = 'Error fetching availability: ' + error;
                    this.isLoading = false;
                    this.availableSlots = [];
                    console.log(JSON.stringify(this.availableSlots));
                });
        }
    }

    handleSlotChange(event) {
        const value = event.currentTarget.dataset.value;
        const isChecked = event.detail.checked;
        console.log('value',value);
        console.log('detail',event.detail);
        console.log('detail',JSON.stringify(event.currentTarget.dataset));

        if (value === 'Full') {
            // If 'Full Day' is selected/deselected, manage other checkboxes
            this.availableSlots = this.availableSlots.map(slot => {
                if (slot.value !== 'Full') {
                   return {...slot, checked: isChecked};
                }
                return {...slot, checked: isChecked};
            });
        } else {
            // If 'Morning' or 'Afternoon' is selected/deselected
            const morningSlot = this.availableSlots.find(s => s.value === 'Half AM');
            const afternoonSlot = this.availableSlots.find(s => s.value === 'Half PM');
            const fullDaySlot = this.availableSlots.find(s => s.value === 'Full');
            
            if (morningSlot.checked && afternoonSlot.checked) {
                fullDaySlot.checked = true;
            } else {
                fullDaySlot.checked = false;
            }
            // Update the specific slot that was changed
            const changedSlot = this.availableSlots.find(s => s.value === value);
            if (changedSlot) changedSlot.checked = isChecked;
            console.log('changedSlot',JSON.stringify(changedSlot));
            //console.log('this.availableSlots',JSON.stringify(this.availableSlots))
        }
    }

    async handleNextStage(){
        //console.log(this.stage4 , this.isIndustrial , this.typeSale=='CD' , this.isFinanced , this.input_pcde==true);
       
        if(this.stage1){
            const ret = await this.fetchAvailability();
        }
        //else if(this.stage3 && this.isIndustrial && this.typeSale=='CD' && this.isFinanced && this.input_pcde==true){
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

        console.log('stageZ',this.stage,this.currentStage);

       

        if(this.currentStage==undefined || this.currentStage==4)//Se llego al final .Guardar
        {
            this.handleBooking();
        }
    }

    handleBooking() {
        console.log('roomBooking',JSON.stringify(this.roomBooking));
        this.isLoading = true;
        const selectedSlots = this.availableSlots.filter(slot => slot.checked && slot.value !== 'Full').map(slot => slot.value);
        console.log('this.availableSlots',JSON.stringify(this.availableSlots));
        console.log('selectedSlots',JSON.stringify(selectedSlots));
        // createBooking({ 
        //     roomId: this.selectedRoomId, 
        //     dateString: this.selectedDate, 
        //     bookingType: selectedSlots[0] 
        // })
        createBooking({
            lm:this.roomBooking,
            qData:{
                opportunityId:this.recordId,
                equipment:JSON.stringify(this.equipment)
            },
            
        })
        .then(() => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Sala reservada correctamente!',
                    variant: 'success',
                })
                
            );
            this.fetchAvailability(); // Refresh availability
            this.closeModal();
        })
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al reservar la sala',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        });
    }


    connectedCallback() {
        // Si no usas @wire para salas, llama a generateCalendar aquí después de definir selectedRoomId
    //    this.generateCalendar();
    }

    handleRoomChange(event) {
        this.selectedRoomId = event.detail.value;
        const selectedOption = this.roomOptions.find(
            option => option.value === this.selectedRoomId
        );
        this.selectedRoomName = selectedOption.label;
        this.generateCalendar(); // Regenerar calendario para la nueva sala
    }

    async generateCalendar() {
        if (!this.selectedRoomId) return;

        const year = this.currentDate.getFullYear();
        const month = this.currentDate.getMonth();
        const firstDayOfMonth = new Date(year, month, 1);
        const lastDayOfMonth = new Date(year, month + 1, 0);

        this.currentMonthYear = firstDayOfMonth.toLocaleString('es-ES', { month: 'long', year: 'numeric' });

        try {
            const bookings = await getBookingsForMonth({
                roomId: this.selectedRoomId,
                startOfMonthString: firstDayOfMonth.toISOString().split('T')[0],
                endOfMonthString: lastDayOfMonth.toISOString().split('T')[0]
            });
            console.log('bookings',bookings);
            this.calendarDays = this.buildCalendarData(firstDayOfMonth, lastDayOfMonth, bookings);

        } catch (error) {
            console.error('Error al cargar reservas:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se pudieron cargar las reservas del mes.',
                    variant: 'error',
                }),
            );
        }
    }

    buildCalendarData(firstDayOfMonth, lastDayOfMonth, bookings) {
        let days = [];
        const numDaysInMonth = lastDayOfMonth.getDate();
        const startDayOfWeek = firstDayOfMonth.getDay(); // 0 (Dom) a 6 (Sab)

        // Rellenar días vacíos al principio del mes
        for (let i = 0; i < startDayOfWeek; i++) {
            days.push({ dayOfMonth: '', classes: 'calendar-day empty' });
        }

        // Mapear reservas por fecha para acceso rápido
        const bookingsMap = new Map();
        bookings.forEach(booking => {
            console.log('booking',booking);
            // Usamos la fecha de inicio para mapear (ignorando la hora por ahora)
            
            const dateKey = new Date(booking.OFI_fld_SalaReserva_Inicio__c).toISOString().split('T')[0];
            console.log('dateKey:::'+dateKey);
            console.log('dateKey1:::'+!bookingsMap.has(dateKey));
            if (!bookingsMap.has(dateKey)) {
                bookingsMap.set(dateKey, { am: false, pm: false });
            }
            console.log('bookingsMap',JSON.stringify(bookingsMap));
            //console.log(booking.OFI_fld_SalaReserva_Tipo__c.includes('Full') || booking.OFI_fld_SalaReserva_Tipo__c.includes('Half AM'))
            // if (booking.OFI_fld_SalaReserva_Tipo__c.includes('Full') || booking.OFI_fld_SalaReserva_Tipo__c.includes('Half AM')) {
                bookingsMap.get(dateKey).am = true;
            // }
            //console.log(booking.OFI_fld_SalaReserva_Tipo__c.includes('Full') || booking.OFI_fld_SalaReserva_Tipo__c.includes('Half PM'))
            // if (booking.OFI_fld_SalaReserva_Tipo__c.includes('Full') || booking.OFI_fld_SalaReserva_Tipo__c.includes('Half PM')) {
                 bookingsMap.get(dateKey).pm = true;
            // }
        });
        console.log('bookingsMap',bookingsMap);
        // Llenar los días del mes con estado de reserva
        for (let i = 1; i <= numDaysInMonth; i++) {
            const date = new Date(firstDayOfMonth.getFullYear(), firstDayOfMonth.getMonth(), i);
            const dateString = date.toISOString().split('T')[0];
            console.log('>>'+dateString);
            const status = bookingsMap.get(dateString) || { am: false, pm: false };
            console.log('status',status);
            let dayClasses = 'calendar-day';
            if (dateString === new Date().toISOString().split('T')[0]) {
                dayClasses += ' selected';
                this.selectedDate=dateString;
            }

            days.push({
                dayOfMonth: i,
                dateString: dateString,
                classes: dayClasses,
                isHalfDayAMBooked: status.am,
                isHalfDayPMBooked: status.pm,
                isFullDayBooked: status.am && status.pm
            });
        }

        return days;
    }

    handleDayClick(event) {
        const selectedDate = event.currentTarget.dataset.datestring;
        console.log('dataset',JSON.stringify(event.currentTarget.dataset));
        console.log('Día clickeado:', selectedDate);
        this.selectedDate = selectedDate;

        const allItems = this.template.querySelectorAll('.calendar-day');

        // 2. Iterate through all items and remove the 'active' class
        allItems.forEach(item => {
            item.classList.remove('selected');
        });

        // 3. Add the 'active' class to the specific element that was clicked
        // event.currentTarget refers to the element the event handler is attached to
        event.currentTarget.classList.add('selected');

        if (selectedDate) {
            // Aquí puedes implementar la lógica para abrir un modal de reserva 
            // para el día seleccionado (usando el método createBooking de Apex).
            console.log('Día clickeado:', selectedDate);
            // alert(`Click en ${selectedDate}. Implementar lógica de reserva aquí.`);
        }
    }

    get stage1(){
        console.log('stage1',this.path[this.pathSelector][this.stage-1],this.stage-1,this.pathSelector);
        return this.path[this.pathSelector][this.stage-1]==1;
    }

    get stage2(){
        
        return this.path[this.pathSelector][this.stage-1]==2;
    }

    get stage3(){
        
        return this.path[this.pathSelector][this.stage-1]==3;
    }

    get stage4(){
        
        return this.path[this.pathSelector][this.stage-1]==4;
    }

    get stage5(){
        
        return this.path[this.pathSelector][this.stage-1]==5;
    }

    get stage6(){
        
        return this.path[this.pathSelector][this.stage-1]==6;
    }

    get stage7(){
        
        return this.path[this.pathSelector][this.stage-1]==7;
    }

    get stage8(){
        
        return this.path[this.pathSelector][this.stage-1]==8;
    }

    get stageN(){
        
        return this.stage > 1;
    }

    get stageV(){
     
        return this.path[this.pathSelector][this.stage-1]==1 || this.path[this.pathSelector][this.stage-1]==4;
    }


    // async handleNextStage(){
    //     console.log(this.stage);

    //     if(this.stage1){
    //         const ret = await this.fetchAvailability();
    //         this.stage=2;
    //     }
    //     else{
    //         this.stage++;
    //     }
        
       
    // }

    handlePrevStage(){
        if(this.stage>1){
            this.stage--;
        }
    }
}