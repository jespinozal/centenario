({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        var IdProyecto = component.get("v.idProyecto");
        console.log('IdProyecto: '+IdProyecto);
        var action = component.get("c.fetchAccountWrapper");
        action.setParams({
            "Idproyecto": IdProyecto ,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
               
                        if(oRes.estado=='ok'){
                             console.log('Todo ok');
                        console.log(oRes.getlotes.length);
                        //	Setear mínimos y máximos
                        component.set("v.sliderTamaniomin",oRes.tamanioMin);                
                        component.set("v.sliderTamaniomax",oRes.tamanioMax);
                        component.set("v.sliderTamanio1Value",oRes.tamanioMin);
                        component.set("v.sliderTamanio2Value",oRes.tamanioMax);
                        
                        component.set("v.sliderPreciomin",oRes.precioMin);
                        component.set("v.sliderPreciomax",oRes.precioMax);
                        component.set("v.sliderPrecio1Value",oRes.precioMin);
                        component.set("v.sliderPrecio2Value",oRes.precioMax);
                        
                        if(oRes.getlotes.length > 0){
                            component.set('v.listOfAllAccounts', oRes.getlotes);
                            var pageSize = component.get("v.pageSize");
                            var totalRecordsList = oRes.getlotes;
                            var totalLength = totalRecordsList.length ;
                            component.set("v.totalRecordsCount", totalLength);
                            component.set("v.startPage",0);
                            component.set("v.endPage",pageSize-1);
                            
                            var PaginationLst = [];
                            for(var i=0; i < pageSize; i++){
                                if(component.get("v.listOfAllAccounts").length > i){
                                    PaginationLst.push(oRes.getlotes[i]);    
                                } 
                            }
                            component.set('v.PaginationList', PaginationLst);
                            component.set("v.selectedCount" , 0);
                            //use Math.ceil() to Round a number upward to its nearest integer
                            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize)); 
                            var spinner = component.find("mySpinner");
                            this.filterData(component);
                            $A.util.toggleClass(spinner, "slds-hide");
                        }else{
                            // if there is no records then display message
                            component.set("v.bNoRecordsFound" , true);
                            console.log(oRes.mensaje);
                        component.set("v.serviceMensaje", oRes.mensaje);
                        } 
                    }else{
                    component.set("v.bNoRecordsFound" , true);
                        console.log(oRes.mensaje);
                        component.set("v.serviceMensaje", oRes.mensaje);
                }
            }
            else{
                alert('Error...');
            }
        });
                
        $A.enqueueAction(action);  
    },
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                
                    Paginationlist.push(sObjectList[i]);  
                
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        
    },
   // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                
                    Paginationlist.push(sObjectList[i]); 
                
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        
    },
    filterData:function(component) { 
        
                
        var minValT, maxValT, minValP, maxValP, lote, manzana, i, data, dataF, estado;
        
        //	Filter all datatable
        estado = component.get("v.selectedValueEstado");
        minValT = component.get("v.sliderTamanio1Value");
        console.log('minValT: ' + minValT);
        maxValT = component.get("v.sliderTamanio2Value");
        console.log('maxValT: ' + maxValT);
        minValP = component.get("v.sliderPrecio1Value");
        maxValP = component.get("v.sliderPrecio2Value");
        lote = component.find("lote").get("v.value");
        lote = lote.toUpperCase();
        manzana = component.find("manzana").get("v.value");
        manzana = manzana.toUpperCase();
        data = component.get("v.listOfAllAccounts");
        dataF=[];
        
        if(!estado){estado="";}else{estado=estado.toUpperCase();}
        if(!manzana){manzana="";}
        if(!lote){lote="";}
        console.log('estado: ' + estado);
        console.log('manzana: ' + manzana);
        console.log('lote: ' + lote);
        for (i = 0; i < data.length; i++) {
            if(data[i].isChecked&&data[i].isChecked==true){
                console.log(" data["+i+"].isChecked");
                data[i].isChecked=false;                
                console.log(" data["+i+"].isChecked="+data[i].isChecked);
            }
                if (data[i].Area >=minValT && data[i].Area<=maxValT && data[i].Precioventafun>=minValP &&
                    data[i].Precioventafun<=maxValP && data[i].Descripcionlote.toUpperCase().indexOf(lote)>-1 &&
                    data[i].Manzana.toUpperCase().indexOf(manzana)>-1 && data[i].Codestadolote.toUpperCase().indexOf(estado)>-1) {
                        dataF.push(data[i]);
          
            }
        }
        console.log('DataF: '+dataF.length);
        component.set("v.dataVisible", dataF);
        			var pageSize = component.get("v.pageSize");
                    var totalRecordsList = dataF;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(dataF.length > i){
                            PaginationLst.push(dataF[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        component.set("v.currentPage",1);
        
        
    },
})