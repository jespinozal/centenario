({
    doInit: function(component, event, helper) {
        
        helper.doInitHelper(component, event);
    },
 
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        //var sObjectList = component.get("v.listOfAllAccounts");
        var sObjectList = component.get("v.dataVisible");
        console.log(sObjectList);
        var end = component.get("v.endPage");
        console.log(end);
        var start = component.get("v.startPage");
        console.log(start);
        var pageSize = component.get("v.pageSize");
        console.log(pageSize);
        var whichBtn = event.getSource().get("v.name");
        console.log(whichBtn);
        
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'Next') {
            console.log('entro');
            console.log(component.get("v.currentPage"));
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'Previous') {
            console.log(component.get("v.currentPage"));
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
        
    },
 
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedCount", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
 
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        console.log('Selct:' +selectedRec );
        var getSelectedNumber = component.get("v.selectedCount");
        console.log('SelctNumber:' +getSelectedNumber );
        console.log(event.getSource());
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        console.log('selectedCount:' +getSelectedNumber );
        if(getSelectedNumber>1){
            event.getSource().set("v.value",false);
            getSelectedNumber--;
            alert( 'Solo puedes seleccionar un Lote.' );
        }else if(getSelectedNumber<=0){            
            getSelectedNumber=0;
            component.set('v.idlote',null);
            component.set('v.area',null);
            component.set('v.preciom2',null);
        }else{
            var allRecords = component.get("v.listOfAllAccounts");
            //console.log('allrecords: '+ allRecords);
            var selectedRecords = [];
            for (var i = 0; i < allRecords.length; i++) {
                if (allRecords[i].isChecked) {
                    selectedRecords.push(allRecords[i]);
                }
            }
            if(selectedRecords.length>0){
                console.log(selectedRecords[0].Codlote);
                component.set('v.idlote',selectedRecords[0].Codlote );
                component.set('v.area', selectedRecords[0].Area);
                component.set('v.preciom2', selectedRecords[0].Precioventam2fun);
                component.set('v.lote', selectedRecords[0].Descripcionlote);
        		component.set('v.manzana', selectedRecords[0].Manzana);
                component.set('v.tipologia', selectedRecords[0].FillerStr02);
                component.set('v.estado', selectedRecords[0].Codestadolote);
                //alert(JSON.stringify(selectedRecords));
            }           
        }
        console.log('SelctNumber:' +getSelectedNumber );
        component.set("v.selectedCount", getSelectedNumber);               
    },
 
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllAccounts");
        console.log('allrecords: '+ allRecords);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        console.log(selectedRecords[0].Descripcionlote);
        component.set('v.idlote',selectedRecords[0].Codlote );
        component.set('v.area', selectedRecords[0].Area);
        component.set('v.preciom2', selectedRecords[0].Precioventam2fun);
        component.set('v.Lote', selectedRecords[0].Descripcionlote);
        component.set('v.Manzana', selectedRecords[0].Manzana);
        alert(JSON.stringify(selectedRecords));
    },
    
    filterDataTable:function(component, event, helper) { 
        
                helper.filterData(component);
        
    },
    
    cleanFilters:function(component, event, helper) { 
        var minValT, maxValT, minValP, maxValP, lote, manzana, i, data, dataF;
        //component.set("v.dataCharged", true);
        data = component.get("v.listOfAllAccounts");
        minValT = component.get("v.sliderTamaniomin");
        maxValT = component.get("v.sliderTamaniomax");
        minValP = component.get("v.sliderPreciomin");
        maxValP = component.get("v.sliderPreciomax");
        component.set("v.selectedValueEstado","");
        component.set("v.sliderTamanio1Value",minValT);
        component.set("v.sliderTamanio2Value",maxValT);
        component.set("v.sliderPrecio1Value",minValP);
        component.set("v.sliderPrecio2Value",maxValP);
        component.find("lote").set("v.value",null);
        component.find("manzana").set("v.value",null);
        component.set("v.dataVisible", data);
        //component.set("v.dataCharged", false);
       

					var pageSize = component.get("v.pageSize");
                    var totalRecordsList = data;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
        for(var i=0; i < data.length; i++){
            if(data[i].isChecked&&data[i].isChecked==true){                
                console.log(" data["+i+"].isChecked");
                data[i].isChecked=false;                
                console.log(" data["+i+"].isChecked="+data[i].isChecked);
            }
        }
                    for(var i=0; i < pageSize; i++){
                        if(data.length > i){
                            PaginationLst.push(data[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));   
        component.set("v.currentPage",1);
    },
    
    
    selectChange : function(component, event, helper) {
        // first get the div element. by using aura:id
      	var changeElement = component.find("DivID");
        // by using $A.util.toggleClass add-remove slds-hide class
     	$A.util.toggleClass(changeElement, "slds-hide");
        if(component.get("v.selectChangeTamanioEnabled")==true){
            component.set("v.selectChangeTamanioEnabled",false);
            component.set("v.sliderTamanio1Value", component.get("v.sliderTamaniomin"));
            component.set("v.sliderTamanio2Value", component.get("v.sliderTamaniomax"));
        }else{
            component.set("v.selectChangeTamanioEnabled",true);
        }
    },
    
    selectChange2 : function(component, event, helper) {
        // first get the div element. by using aura:id
      	var changeElement = component.find("DivID2");
        // by using $A.util.toggleClass add-remove slds-hide class
      	$A.util.toggleClass(changeElement, "slds-hide");
        if(component.get("v.selectChangePrecioEnabled")==true){
            component.set("v.selectChangePrecioEnabled",false);
            component.set("v.sliderPrecio1Value", component.get("v.sliderPreciomin"));
            component.set("v.sliderPrecio2Value", component.get("v.sliderPreciomax"));
        }else{
            component.set("v.selectChangePrecioEnabled",true);
        }
	},
    
})