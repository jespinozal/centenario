import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'; // Importa el cargador de estilos
import datatableStyles from '@salesforce/resourceUrl/datatableStyles'; // Importa tu recurso estático
import { NavigationMixin } from 'lightning/navigation'; 

const COLS = [
    // Tu definición de columnas no cambia
    { label: 'Nombre', fieldName: 'Name', wrapText: true, initialWidth: 225, sortable: true },
    { label: 'Relacionado A', type: 'url', fieldName: 'relatedToUrl', wrapText: true, initialWidth: 201, typeAttributes: { label: { fieldName: 'CEN_Nombre_Relacionado_A__c' }, target: '_blank' }, sortable: false },
    { label: 'Origen', fieldName: 'CEN_Origen_del_Archivo__c', wrapText: true, initialWidth: 90, sortable: true },
    { label: 'Fecha', fieldName: 'CEN_Fecha_de_Creacion__c', type: 'date', typeAttributes:{ year: "numeric", month: "2-digit", day: "2-digit" }, initialWidth: 95, sortable: true },
    { label: 'Tipo', fieldName: 'CEN_Tipo_de_Archivo__c', initialWidth: 84 },
    { label: 'Tamaño', fieldName: 'CEN_Tamano_Formateado__c', initialWidth: 90},
    {
        type: 'button-icon', // MODIFICADO: Esto convierte la celda en un botón.
        initialWidth: 50,
        typeAttributes: {
            name: 'preview',
            title: 'Haga clic para previsualizar el archivo',
            variant: 'border-filled', // Un estilo de botón sutil
            iconName: 'utility:preview',
            alternativeText: 'Previsualizar'
        }
    }
];

export default class EnhancedFlowDataTable extends NavigationMixin(LightningElement) {
    @api inputData = [];
    @api selectedRows = [];
    @api preselectedRows = [];
    // Propiedad para aplicar la clase CSS al contenedor de la tabla
    @api tableClass = 'force-height';

    columns = COLS;
    tableData = [];
    masterData = [];
    
    _selectedRowIds = new Set();
    hasStylesLoaded = false;
    

    sortBy;
    sortDirection;

    connectedCallback() {

        if (this.inputData && this.inputData.length > 0) {
            this.masterData = this.inputData.map(record => {
                let recordCopy = {...record};

                recordCopy.previewLabel = 'Ver';
                if (recordCopy.CEN_ID_Relacionado_A__c) {
                    recordCopy.relatedToUrl = '/' + recordCopy.CEN_ID_Relacionado_A__c;
                }
                return recordCopy;
            });

            this.tableData = [...this.masterData];

             // --- INICIO DE LA NUEVA LÓGICA ---
            // Revisa si el flujo nos pasó una selección previa
            if (this.selectedRows && this.selectedRows.length > 0) {
                // Si es así, inicializamos nuestro Set de IDs con esos valores
                // Esto "recuerda" las selecciones de la vez anterior.
                this._selectedRowIds = new Set(this.selectedRows.map(row => row.CEN_ID_Original__c));
            }
            // --- FIN DE LA NUEVA LÓGICA ---

            // Establecer un orden inicial por defecto (opcional)
            this.sortBy = 'CEN_Fecha_de_Creacion__c';
            this.sortDirection = 'desc';
            this.sortData(this.sortBy, this.sortDirection);
        }
    }

    // Carga los estilos una vez que el componente se ha renderizado
    renderedCallback() {
        

        if (this.hasStylesLoaded) {
            return;
        }
        this.hasStylesLoaded = true;

        loadStyle(this, datatableStyles).catch(error => {
            console.error('Error al cargar los estilos personalizados.', error);
        });
    }

    /// --- NUEVA FUNCIÓN PARA MANEJAR EL EVENTO DE ORDENAMIENTO ---
    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }

    // --- NUEVA FUNCIÓN CON LA LÓGICA PARA ORDENAR LOS DATOS ---
    sortData(fieldname, direction) {
        let parseData = [...this.tableData];
        let keyValue = (a) => a[fieldname];
        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.tableData = parseData;
    }

    get selectedRowIds() {
        // Este getter se llama cada vez que el componente se redibuja.
        console.log('GETTER: Pasando a la datatable los IDs seleccionados:', [...this._selectedRowIds]);
        return [...this._selectedRowIds];
    }

    handleSearchChange(event) {
        const searchTerm = event.target.value.toLowerCase();
        console.log(`--- FILTRANDO POR: "${searchTerm}" ---`);
        if (searchTerm) {
            this.tableData = this.masterData.filter(record => {
                // La condición ahora revisa si el término de búsqueda existe en CUALQUIERA de estos campos.
                const nameMatch = record.Name && record.Name.toLowerCase().includes(searchTerm);
                const typeMatch = record.CEN_Tipo_de_Archivo__c && record.CEN_Tipo_de_Archivo__c.toLowerCase().includes(searchTerm);
                const originMatch = record.CEN_Origen_del_Archivo__c && record.CEN_Origen_del_Archivo__c.toLowerCase().includes(searchTerm);
                const relatedToMatch = record.CEN_Nombre_Relacionado_A__c && record.CEN_Nombre_Relacionado_A__c.toLowerCase().includes(searchTerm);

                return nameMatch || typeMatch || originMatch || relatedToMatch;
            });
        } else {
            // Cuando el buscador se vacía, restauramos la lista completa
            this.tableData = [...this.masterData];
            // Y VOLVEMOS A APLICAR EL ORDENAMIENTO ACTUAL
            this.sortData(this.sortBy, this.sortDirection);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'preview') {
            // Verificamos si es un Attachment o un File moderno.
            if (row.CEN_Tipo_Documento__c.includes('Adjunto')) {
                // Es un Attachment antiguo. La única opción segura es descargar.
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: `/${row.CEN_ID_Original__c}`
                    }
                });
            } else {
                // Es un File moderno (ContentDocument). Usamos el previsualizador estándar.
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        // Pasamos el ID del ContentDocument para que sepa qué archivo mostrar.
                        recordIds: row.CEN_ID_Original__c
                    }
                });
            }
        }
    }

     handleRowSelection(event) {
    const visibleIds = this.tableData.map(row => row.CEN_ID_Original__c);
    const selectedInEvent = new Set(event.detail.selectedRows.map(row => row.CEN_ID_Original__c));

    for (const id of visibleIds) {
        if (selectedInEvent.has(id)) {
            this._selectedRowIds.add(id);
        } else {
            this._selectedRowIds.delete(id);
        }
    }

    this.selectedRows = this.masterData.filter(row => this._selectedRowIds.has(row.CEN_ID_Original__c));
    } 
   
   
}