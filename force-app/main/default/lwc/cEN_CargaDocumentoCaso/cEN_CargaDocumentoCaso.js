import { LightningElement, track, api } from 'lwc';
import getDatosDocumentos   from "@salesforce/apex/CEN_CargaDocumentoCaso.getDatosDocumentos";
import uploadDocumento      from "@salesforce/apex/CEN_CargaDocumentoCaso.uploadDocumento";
import relateCaseLog        from "@salesforce/apex/CEN_CargaDocumentoCaso.relateCaseLog";
import { RefreshEvent }     from 'lightning/refresh';
import getToken from '@salesforce/apex/CEN_CargaDocumentoOnbase.getToken';
import getCaseForDocument from '@salesforce/apex/CEN_CargaDocumentoCaso.getCaseForDocument';
import getProducto from '@salesforce/apex/CEN_CargaDocumentoOnbase.getProducto';
import getFetchParams from '@salesforce/apex/CEN_CargaDocumentoCaso.getFetchParams';
import uploadCont from '@salesforce/apex/CEN_CargaDocumentoCaso.uploadCont';

import getEndPointCargarDocumentoPrepago from '@salesforce/apex/CEN_CargaDocumentoOnbase.getEndPointCargarDocumentoPrepago';

export default class CEN_CargaDocumentoCaso extends LightningElement {
 
    @track resumenTipoDeSolicitud           =   '';
    @track resumenNumeroDocumento           =   '';
    @track resumenFinanciamiento            =   '';
    @track resumenEstado                    =   '';
    @track resumenUrl                       =   '';
    @track resumenUsuario                   =   '';
    @track resumenFechaDeCarga              =   '';
    @api recordId;
    formatos                                =   ['.pdf'];
    @track showSpinner                      =   false;
    @track idLog                            =   '';
    connectedCallback(){
        this.obtenerDetalleDocumentos();
    }
    showModal = false;
    uploading = true;
    uploadSuccess = false;
    progressValue = 0;
    fileName="";
    fileSize=0;
    epoch;
    never=false;
    error=false;
    
    
    /*cargaDocumento(event){
        const documentoCargado = event.detail.files;
        console.log('documento: '+  documentoCargado);
        this.resumenEstado          =   'Cargado';

    }*/
    obtenerDetalleDocumentos(){
        getDatosDocumentos({
            idCaso  :   this.recordId
        }).then((result)=>{
            console.log('resultadoget: '+JSON.stringify(result));
            this.resumenTipoDeSolicitud     =   result.tipoDeSolicitud;
            this.resumenNumeroDocumento     =   result.numeroDocumento;
            this.resumenFinanciamiento      =   result.financiamiento;
            this.resumenEstado              =   result.estado;
            this.resumenUrl                 =   result.url;
            this.resumenUsuario             =   result.usuario;
            this.resumenFechaDeCarga        =   result.fechaDeCarga;
            this.showSpinner                =   false;
        }).catch((error) => {
            console.log('Error getDatosDocumentos: '+JSON.stringify(error));
        }
        );
    }

    closeModal(){
        this.showModal=false;
        this.uploading=true;
        this.uploadSuccess=false;
        this.progressValue=0;
        this.fileName="";
        this.fileSize=0;
        this.epoch=Date.now();
        this.showSpinner=false;
        
        
    }

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
          const fileReader = new FileReader();
          const fileName = fileSource.name;

          fileReader.onerror = () => reject(fileReader.error);
          fileReader.onload = () => resolve({ fileName, 
            base64: fileReader.result.split(',')[1] 
            ,fileSize: fileSource.size,
            fileCon:fileSource,
            fileContents:fileReader.result,
            dataStart:fileReader.result.indexOf(fileReader.result.split(',')[1]) + fileReader.result.split(',')[1].length
        });
          fileReader.readAsDataURL(fileSource);
        });
      }

    async openFile(event){
        this.uploading=true;
        this.showModal=true;
        this.progressValue=10;
        this.uploadSuccess=false;
        this.fileName="";
        this.fileSize=0;
        this.epoch=Date.now();
        this.showSpinner=true;
        this.error=false;

        const vInterval  = setInterval(()=>{
            if(this.progressValue<90){
                this.progressValue+=1;
            }else{
                clearInterval(vInterval);
            }
            
        },100);
        this.Files = await Promise.all(
            [...event.target.files].map(file => this.readFile(file))
          ); 

          //console.log("files",this.Files);

          this.fileName = this.Files[0].fileName;
          this.fileSize = (this.Files[0].fileSize/1024/1024).toFixed(2);

          this.sendFile();
    }

    cargaDocumento(event){
        //console.log(JSON.stringify(event));
        const uploadedFiles = event.detail.files;
        
        var archivo = uploadedFiles[0].documentId;
        console.log('archivo: '+uploadedFiles);
        console.log('archivo: '+archivo);
        //console.log('contentVersionId: '+uploadedFiles[0].contentVersionId);
        this.showSpinner                =   true;
        this.cargaDeArchivo(archivo);
    }

    async sendFile(){
        const getTokenResponse = await getToken();
       console.log('Token recibido:', getTokenResponse.Token);
        console.log('Access token:', getTokenResponse.Token);


        const caso = await getCaseForDocument({'idCaso':this.recordId});
        //console.log(JSON.stringify(caso));
        const request = {};
        if(caso.CEN_SociedadFinanciamiento__c   ==  '0010'){
            request.empresa_centenario          =   'INVERSIONES CENTENARIO S.A.A.';
        }else if(caso.CEN_SociedadFinanciamiento__c   ==  '0019'){
            request.empresa_centenario          =   'CENTENARIO DESARROLLO';
        }else if(caso.CEN_SociedadFinanciamiento__c   ==  '0013'){
            request.empresa_centenario          =   'PROMOCION INMOBILIARIA DEL SUR - PRINSUR';
        }

        if(caso.Account.RecordType.DeveloperName    ==  'PersonAccount'){
            request.tipo_personeria         =   'PERSONA NATURAL';
            const   personaNatural  =   {};
            personaNatural.nombre_apellido  =   caso.Account.Name;
            if(caso.Account.CEN_Tipo_de_documento__pc ==  'Carnet de Extranjería'){
                personaNatural.tipo_documento   =   'C.E';
            }else if(caso.Account.CEN_Tipo_de_documento__pc ==  'DNI' || caso.Account.CEN_Tipo_de_documento__pc ==  'RUC' || caso.Account.CEN_Tipo_de_documento__pc ==  'Pasaporte'){
                personaNatural.tipo_documento   =   caso.Account.CEN_Tipo_de_documento__pc.toUpperCase();
            }else{
                personaNatural.tipo_documento   =   'Sin especificar';
            }
            personaNatural.nro_documento        =   caso.Account.CEN_N_mero_de_documento__pc;
            request.persona_natural             =   [];
            request.persona_natural.push(personaNatural);
            request.persona_juridica            =   [];
        }else if(caso.Account.RecordType.DeveloperName    ==  'Cuenta_Empresa'){
            request.tipo_personeria         =   'PERSONA JURIDICA';
            const   personaJuridica  =   {};
            personaJuridica.razon_social    =   caso.Account.Name;
            personaJuridica.ruc             =   caso.Account.CEN_Numero_de_documento_del__c;
            request.persona_juridica        =   [];
            request.persona_juridica.push(personaJuridica);
            request.persona_natural         =   [];

        }


        if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionUrbanoResolucion'){
            request.tipo_clausula       =   'RESOLUCION';
        }else if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionPrepago'){
            request.tipo_clausula       =   'PREPAGO';
        }

        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        const formattedDate = `${year}/${month}/${day}`;
        
        request.fecha_documento              =   formattedDate;
        request.urbanizacion                =   caso.CEN_Etapa__c;
        request.etapa                       =   caso.CEN_Etapa__c;
        if(caso.ParentId  == null){
            request.nro_finacimiento            =   '00000'+caso.CEN_CodFinanciamiento__c;
            request.clave_unica                 =   caso.CaseNumber + '_00000' + caso.CEN_CodFinanciamiento__c;
        }else{
            request.nro_finacimiento            =   '00000'+caso.Parent.CEN_CodFinanciamiento__c;
            request.clave_unica                 =   caso.Parent.CaseNumber + '_00000' + caso.Parent.CEN_CodFinanciamiento__c;
        }
        
        request.tipo_documental             =   'LEG - Cláusulas adicionales / Adendas';

        let codigosLotes   =   [];
        if(caso.CEN_CodigoDeLotes__c !=null && caso.CEN_CodigoDeLotes__c.includes(',')){
            codigosLotes  =   caso.CEN_CodigoDeLotes__c.split(',');
        }else{
            codigosLotes.push(caso.CEN_CodigoDeLotes__c);
        }
        let   mapaProductos   =   {};
        if(codigosLotes.length    >   0){
            mapaProductos   =  await getProducto({'lProductos':codigosLotes});
        }
        const    listaLotes   =   [];
        if(Object.keys(mapaProductos).length  >   0){
            codigosLotes.forEach((codigoLote)=>{
                if(codigoLote in mapaProductos){
                    const    lote    =   {};
                    let mzLt = [];
                    mzLt            =  this.parseLoteInfo(mapaProductos[codigoLote][0]);
                    lote.manzana    =   mzLt[0];
                    lote.lote       =   mzLt[1];
                    listaLotes.push(lote);
                }
            });
            
        }
        request.mz_lt               =   [];
        request.mz_lt               =   listaLotes;
        request.extension_archivo   =   'PDF';
        request.docbase_64          =   this.Files[0].base64;
        
        const jsonData= JSON.stringify(request);
        console.log("Felipe"+jsonData);

        const fetchParams = await getFetchParams();

        let prevEpoch = this.epoch;

        //Se toco el metodo fetch para adecuar al nuevo servicio sharepoint
        const EndPoint = await getEndPointCargarDocumentoPrepago();//Felipe

        fetch(EndPoint+fetchParams['CEN_Endpoint__c'], {
            method: fetchParams['CEN_Method__c'],
            body: jsonData ,
            headers: {         'Content-Type': 'application/json; charset=utf-8','Token': getTokenResponse["Token"]},
          })
          .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            //console.log('Actual request status:', response.status); 
            return response.json(); 
        })
        .then(data => {
            console.log('Data retrieved:', data); 
            this.apiData = data;
            this.uploadSuccess = true; 
            this.uploading = false;
            this.progressValue=100;
            this.showSpinner=false;

            console.log(prevEpoch,this.epoch);
            if(prevEpoch == this.epoch){
                console.log('cont execution');
                console.log('data: '+JSON.stringify(data));
                if(data.success=true){
                    uploadCont({"idCaso":this.recordId,"jsonRespuesta":JSON.stringify(data)}).then((result) => {
                        console.log('resultado1: '+JSON.stringify(result));
                        this.idLog      =   result.idLog;
                        this.obtenerDetalleDocumentos();
                        this.relateCaseLogSave();
                      })
                      .catch((error) => {
                        console.log('resultado2: '+JSON.stringify(error));
                        this.error=true;
                        this.closeModal();
                        
                      });
                }else{
                    this.error=true;
                    this.closeModal();
                }
                
                  
            }else{
                console.log('lone execution');
            }
        })
          .catch(error => {
            console.error('Error uploading file:', error);
            this.error=true;
          });
    }

    cargaDeArchivo(archivo) {
        

        uploadDocumento({
            idCaso              :   this.recordId,
            tipoDeClausula      :   'PREPAGO',
            extensionArchivo    :   'PDF',
            idDocument          :   archivo
        })
          .then((result) => {
            console.log('resultado: '+JSON.stringify(result));
            this.idLog      =   result.idLog;
            this.obtenerDetalleDocumentos();
            this.relateCaseLogSave();
          })
          .catch((error) => {
            console.log('resultado: '+JSON.stringify(error));
            
          });
      }

      parseLoteInfo(loteInfo) {
        const ucLoteInfo = loteInfo.toUpperCase();
        const mzLt = [];
        
        // Regular expression to find the value after Mz.
        const mzPattern = /MZ\.\s*([A-Za-z0-9]+)/;
        // Regular expression to find the value after Lt.
        const ltPattern = /LT\.\s*([A-Za-z0-9]+)/;
        
        let mz = '';
        let lt = '';
        
        // Extract the value of Mz.
        const mzMatch = mzPattern.exec(ucLoteInfo);
        if (mzMatch) {
            mz = mzMatch[1]; // Capture the value of Mz.
        }
        
        // Extract the value of Lt.
        const ltMatch = ltPattern.exec(ucLoteInfo);
        if (ltMatch) {
            lt = ltMatch[1]; // Capture the value of Lt.
        }
        
        mzLt.push(mz);
        mzLt.push(lt);
        
        console.log('Mz: ' + mz);
        console.log('Lt: ' + lt);
        
        return mzLt;
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


}