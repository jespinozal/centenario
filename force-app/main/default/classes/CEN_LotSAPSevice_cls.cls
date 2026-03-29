/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-01-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-07-2021   @everis.com   Initial Version
**/
@RestResource(urlMapping='/sap/lot/*')
global class CEN_LotSAPSevice_cls {
    private static List<Product2> lotToProcess;
    private static Set<String> idProjLotsProcess;
    private static Set<String> lotsIdsUpdate;
    private static Map<String,String> mapProjError;

    @HttpPost
    global static String doPost(){
        system.debug('doPost');
        List<CEN_LotObjectResponse> myRespList = new List<CEN_LotObjectResponse>();
        try {
             String jsonString = RestContext.request.requestBody.toString();
            //String jsonString ='[{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":null,"fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]}]';
            List<CEN_LotObjectRequest> myObjReq = (List<CEN_LotObjectRequest> )JSON.deserialize(jsonString,List<CEN_LotObjectRequest>.class);
            if(myObjReq.size()>200){
                CEN_LotObjectResponse lotMax = new CEN_LotObjectResponse();
                lotMax.idLot = 'All';
                lotMax.status = 'error';
                lotMax.message = 'procesar maximo 200 registros';
                myRespList.add(lotMax);
            }else{
                Integer max = 0;
                idProjLotsProcess = new set<String>();
                for(CEN_LotObjectRequest req: myObjReq){
                    max+=req.lots.size();
                    idProjLotsProcess.add(req.idProyectoSap);
                }
                if(max>200){
                    CEN_LotObjectResponse lotMax = new CEN_LotObjectResponse();
                    lotMax.idLot = 'All';
                    lotMax.status = 'error';
                    lotMax.message = 'procesar maximo 200 registros';
                    myRespList.add(lotMax);
                }else{
                    List<CEN_LotObjectResponse> myRespValiProje = validateProject(idProjLotsProcess);
                    if(myRespValiProje.size()>0){myRespList.addAll(myRespValiProje);}
                    List<CEN_LotObjectResponse> myRespValidate = validateData(myObjReq,false);
                    if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
                
                    //List<CEN_LotObjectResponse> myRespProcess = lotProcess (false); //REVISAR EN SAP PORQUE SE DUPLICA LOTE
                    //if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
                }
            }
        } catch (Exception ex) {
            CEN_LotObjectResponse lotEx = new CEN_LotObjectResponse();
            lotEx.idLot = 'All';
            lotEx.status = 'error';
            lotEx.message = ex.getMessage();
            
            myRespList.add(lotEx);
        }
        String myResp = JSON.serialize(myRespList);
        system.debug('myRespToSap: '+myResp);

        return myResp; 
    }

    @HttpPut
    global static String doPut(){
        system.debug('doPut');
        List<CEN_LotObjectResponse> myRespList = new List<CEN_LotObjectResponse>();
        try {
             String jsonString = RestContext.request.requestBody.toString();
            //String jsonString ='[{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":null,"fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]}]';
            List<CEN_LotObjectRequest> myObjReq = (List<CEN_LotObjectRequest> )JSON.deserialize(jsonString,List<CEN_LotObjectRequest>.class);
            if(myObjReq.size()>200){
                CEN_LotObjectResponse lotMax = new CEN_LotObjectResponse();
                lotMax.idLot = 'All';
                lotMax.status = 'error';
                lotMax.message = 'procesar maximo 200 registros';
                myRespList.add(lotMax);
            }else{
                Integer max = 0;
                idProjLotsProcess = new set<String>();
                for(CEN_LotObjectRequest req: myObjReq){
                    max+=req.lots.size();
                    idProjLotsProcess.add(req.idProyectoSap);
                }
                if(max>200){
                    CEN_LotObjectResponse lotMax = new CEN_LotObjectResponse();
                    lotMax.idProject='all';
                    lotMax.idLot = 'all';
                    lotMax.status = 'error';
                    lotMax.message = 'procesar maximo 200 registros';
                    myRespList.add(lotMax);
                }else{
                    List<CEN_LotObjectResponse> myRespValiProje = validateProject(idProjLotsProcess);
                    if(myRespValiProje.size()>0){myRespList.addAll(myRespValiProje);}
                    List<CEN_LotObjectResponse> myRespValidate = validateData(myObjReq,true);
                    if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
                
                    List<CEN_LotObjectResponse> myRespProcess = lotProcess (true); 
                    if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
                }
            }
        } catch (Exception ex) {
            CEN_LotObjectResponse lotEx = new CEN_LotObjectResponse();
            lotEx.idProject='all';
            lotEx.idLot = 'all';
            lotEx.status = 'error';
            lotEx.message = ex.getMessage();
            
            myRespList.add(lotEx);
        }
        String myResp = JSON.serialize(myRespList);
        system.debug('myRespToSap: '+myResp);

        return myResp; 

    }

    private static List<CEN_LotObjectResponse> lotProcess (Boolean isLotsUpdate){
        system.debug('lotProcess');
        List<CEN_LotObjectResponse> processResp = new List<CEN_LotObjectResponse> ();
        if(lotToProcess.size()>0){
            Database.SaveResult[] srList;
            if(isLotsUpdate){
                //List<Product2> myLotsSF = [SELECT Id, CEN_IdLotSAP__c FROM Product2 WHERE CEN_IdLotSAP__c IN :lotsIdsUpdate];
                List<Product2> myLotsSF = [ SELECT Id, CEN_IdLotSAP__c, CEN_Proyecto__r.CEN_CODIGOSAP__c 
                                            FROM Product2 
                                            WHERE CEN_IdLotSAP__c IN :lotsIdsUpdate 
                                            AND CEN_Proyecto__r.CEN_CODIGOSAP__c = :idProjLotsProcess];
                
                for(Product2 myid:myLotsSF){
                    for(Product2 myLot:lotToProcess){
                        if(myLot.CEN_IdLotSAP__c == myid.CEN_IdLotSAP__c){
                            myLot.Id = myid.Id;
                        } 
                    }

                }
                srList = Database.update(lotToProcess, false);}
            else{srList = Database.insert(lotToProcess, false);}
            String myMsg = 'Lote '+(isLotsUpdate?'actualizado':'registrado')+' con exito';
            Integer pos = 0 ;
            for (Database.SaveResult sr : srList) {
                Product2 getLot = lotToProcess.get(pos);
                if (sr.isSuccess()) {
                    CEN_LotObjectResponse lotSucces = new CEN_LotObjectResponse();
                    lotSucces.idProject = getLot.IDPROYECTO__c;
                    lotSucces.idLot = getLot.CEN_IdLotSAP__c;
                    lotSucces.status = 'succes';
                    lotSucces.message = myMsg;
                    processResp.add(lotSucces);
                }else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        CEN_LotObjectResponse lotError = new CEN_LotObjectResponse();
                        lotError.idProject = getLot.IDPROYECTO__c;
                        lotError.idLot = getLot.CEN_IdLotSAP__c;
                        lotError.status = 'error';
                        lotError.message = isLotsUpdate && getLot.Id == null?'No existe lote':err.getStatusCode()+ ': ' + err.getMessage();
                        processResp.add(lotError);
                    }
                }
                ++pos;
            }
           }
           
           system.debug('lotProcess-processResp: '+processResp);

           return processResp;
    }

    private static List<CEN_LotObjectResponse> validateData(List<CEN_LotObjectRequest> myLotsReq, Boolean isLotsUpdate){
        system.debug('validateData');
        system.debug('myLotsReq: ' + myLotsReq);
        List<CEN_LotObjectResponse> mylotsResp = new List<CEN_LotObjectResponse>();
        lotToProcess =  new List<Product2> ();
        for(CEN_LotObjectRequest lotReq: myLotsReq){
            if(mapProjError==null || (mapProjError!=null && mapProjError.get(lotReq.idProyectoSap)==null) ){
                 
                for(CEN_LotObjectRequest.lot lot: lotReq.lots ){
                    Product2 mylot = new Product2();
                    try{
                        if(isLotsUpdate && lot.isActive!=null){mylot.IsActive=lot.isActive;}
                        else if(!isLotsUpdate && lot.isActive==null ){mylot.IsActive=true;}
                        else{mylot.IsActive=lot.isActive;}
        
                        if(isLotsUpdate && lot.codCliente!=null){mylot.CEN_CODCLIENTESAP__c=lot.codCliente;}
                        //else if(!isLotsUpdate && lot.codCliente==null){throw new LotSAPSeviceException('Debe indicar el campo codCliente');}
                        else{mylot.CEN_CODCLIENTESAP__c=lot.codCliente;}
        
                        if(isLotsUpdate && lot.costoAbitacionUrba!=null){mylot.CEN_COSTOABITACIONURBA__c=lot.costoAbitacionUrba;}
                        //else if(!isLotsUpdate && lot.costoAbitacionUrba==null){throw new LotSAPSeviceException('Debe indicar el campo costoAbitacionUrba');}
                        else{mylot.CEN_COSTOABITACIONURBA__c=lot.costoAbitacionUrba;}
        
                        if(isLotsUpdate && lot.costoMayorValor!=null){mylot.CEN_COSTOMAYORVALOR__c=lot.costoMayorValor;}
                        //else if(!isLotsUpdate && lot.costoMayorValor==null){throw new LotSAPSeviceException('Debe indicar el campo costoMayorValor');}
                        else{mylot.CEN_COSTOMAYORVALOR__c=lot.costoMayorValor;}
        
                        if(isLotsUpdate && lot.costoTerreno!=null){mylot.CEN_COSTOTERRENO__c=lot.costoTerreno;}
                        //else if(!isLotsUpdate && lot.costoTerreno==null){throw new LotSAPSeviceException('Debe indicar el campo costoTerreno');}
                        else{mylot.CEN_COSTOTERRENO__c=lot.costoTerreno;}
        
                        if(lot.costoVenta!=null){mylot.CEN_COSTOVENTA__c=lot.costoVenta;}
        
                        if(isLotsUpdate && lot.codCompania!=null){mylot.CODCOMPANIA__c=lot.codCompania;}
                        else if(!isLotsUpdate && lot.codCompania==null){throw new LotSAPSeviceException('Debe indicar el campo codCompania');}
                        else{mylot.CODCOMPANIA__c=lot.codCompania;}
        
                        if(lot.codEstadoEntrega!=null){mylot.CODESTADOENTREGA__c=lot.codEstadoEntrega;}
        
                        if(isLotsUpdate && lot.codEstadoLote!=null){mylot.CODESTADOLOTE__c =lot.codEstadoLote;}
                        else if(!isLotsUpdate && lot.codEstadoLote==null){throw new LotSAPSeviceException('Debe indicar el campo codEstadoLote');}
                        else{mylot.CODESTADOLOTE__c =lot.codEstadoLote;}
        
                        if(isLotsUpdate && lot.codMonedaFuncional!=null){mylot.CODMONEDAFUNCIONAL__c=lot.codMonedaFuncional;}
                        //else if(!isLotsUpdate && lot.codMonedaFuncional==null){throw new LotSAPSeviceException('Debe indicar el campo codMonedaFuncional');}
                        else{mylot.CODMONEDAFUNCIONAL__c=lot.codMonedaFuncional;}
        
                        if(isLotsUpdate && lot.codLoteSap!=null){mylot.CODLOTE__c=lot.codLoteSap.replaceFirst('^0+','');}
                        else if(!isLotsUpdate && lot.codLoteSap==null){throw new LotSAPSeviceException('Debe indicar el campo codLoteSap');}
                        else{mylot.CODLOTE__c=lot.codLoteSap.replaceFirst('^0+','');}
        
                        if(lot.codSituacionLote!=null){mylot.CODSITUACIONLOTE__c=lot.codSituacionLote;}
        
                        if(isLotsUpdate && lot.descripcionCorta!=null){mylot.DESCRIPCIONCORTA__c=lot.descripcionCorta;}
                        //else if(!isLotsUpdate && lot.descripcionCorta==null){throw new LotSAPSeviceException('Debe indicar el campo descripcionCorta');}
                        else{mylot.DESCRIPCIONCORTA__c=lot.descripcionCorta;}
        
                        if(isLotsUpdate && lot.descripcionLote!=null){mylot.DESCRIPCIONLOTE__c=lot.descripcionLote;}
                        //else if(!isLotsUpdate && lot.descripcionLote==null){throw new LotSAPSeviceException('Debe indicar el campo descripcionLote');}
                        else{mylot.DESCRIPCIONLOTE__c=lot.descripcionLote;}
        
                        if(lot.etapaLote!=null){mylot.CEN_Etapa__c=lot.etapaLote;}

                        String strFechaIngreso = lot.fechaIngreso;
                        if(strFechaIngreso!=null && String.isNotEmpty(strFechaIngreso)){
                            strFechaIngreso = strFechaIngreso.replace('T', ' ');
                            Date fi = Date.valueOf(strFechaIngreso);
                           
                            mylot.FECINGRESO__c= fi;
                       }

                        String strFechaNotaria = lot.fechaIngresoNotaria;
                        if(strFechaNotaria !=null && String.isNotEmpty(strFechaNotaria)){
                            strFechaNotaria = strFechaNotaria.replace('T', ' ');
                            Date fn = Date.valueOf(strFechaNotaria);

                            mylot.FECINGRESONOTARIA__c=fn;
                        }

                        String strFechaVenta = lot.fechaVenta;
                        if(strFechaVenta !=null && String.isNotEmpty(strFechaVenta)){
                            strFechaVenta = strFechaVenta.replace('T', ' ');
                            Date fv = Date.valueOf(strFechaVenta);

                            mylot.FECVENTA__c=fv;
                        }
                        
                        if(lot.idLotSap!=null){
                            mylot.CEN_IdLotSAP__c=lot.idLotSap;
                            if(lotsIdsUpdate==null){lotsIdsUpdate=new set<String>();}
                            lotsIdsUpdate.add(lot.idLotSap);
                        }
                        else{throw new LotSAPSeviceException('Debe indicar el campo idLotSap');}
                       
                        
                        if(isLotsUpdate && lotReq.idProyectoSap!=null){mylot.IDPROYECTO__c=lotReq.idProyectoSap;}
                        else if(!isLotsUpdate && lotReq.idProyectoSap==null){throw new LotSAPSeviceException('Debe indicar el campo idProyectoSap');}
                        else{mylot.IDPROYECTO__c=lotReq.idProyectoSap;}
                        
                        if(mylot.IDPROYECTO__c!=null){
                            Proyecto__c myProj = [SELECT Id, CEN_CODIGOSAP__c FROM Proyecto__c WHERE CEN_CODIGOSAP__c =:lotReq.idProyectoSap];
                            mylot.CEN_Proyecto__c = myProj.Id;
                        }
                        
                        if(isLotsUpdate && lot.linderoDerecha!=null){mylot.LINDERODERECHA__c=lot.linderoDerecha;}
                        else if(!isLotsUpdate && lot.linderoDerecha==null){throw new LotSAPSeviceException('Debe indicar el campo linderoDerecha');}
                        else{mylot.LINDERODERECHA__c=lot.linderoDerecha;}
                        
                        if(isLotsUpdate && lot.linderoFondo!=null){mylot.CEN_LINDEROFONDO__c=lot.linderoFondo;}
                        else if(!isLotsUpdate && lot.linderoFondo==null){throw new LotSAPSeviceException('Debe indicar el campo linderoFondo');}
                        else{mylot.CEN_LINDEROFONDO__c=lot.linderoFondo;}
                        
                        if(isLotsUpdate && lot.linderoFrente!=null){mylot.CEN_LINDEROFRENTE__c=lot.linderoFrente;}
                        else if(!isLotsUpdate && lot.linderoFrente==null){throw new LotSAPSeviceException('Debe indicar el campo linderoFrente');}
                        else{mylot.CEN_LINDEROFRENTE__c=lot.linderoFrente;}
                        
                        if(isLotsUpdate && lot.linderoIzquierda!=null){mylot.CEN_LINDEROIZQUIERDA__c=lot.linderoIzquierda;}
                        else if(!isLotsUpdate && lot.linderoIzquierda==null){throw new LotSAPSeviceException('Debe indicar el campo linderoIzquierda');}
                        else{mylot.CEN_LINDEROIZQUIERDA__c=lot.linderoIzquierda;}
                        
                        if(isLotsUpdate && lot.manzana!=null){mylot.MANZANA__c=lot.manzana;}
                        else if(!isLotsUpdate && lot.manzana==null){throw new LotSAPSeviceException('Debe indicar el campo manzana');}
                        else{mylot.MANZANA__c=lot.manzana;}
                        
                        if(isLotsUpdate && lot.medidaDerecha!=null){mylot.CEN_MEDIDADERECHA__c=lot.medidaDerecha;}
                        else if(!isLotsUpdate && lot.medidaDerecha==null){throw new LotSAPSeviceException('Debe indicar el campo medidaDerecha');}
                        else{mylot.CEN_MEDIDADERECHA__c=lot.medidaDerecha;}
                        
                        if(isLotsUpdate && lot.medidaFondo!=null){mylot.CEN_MEDIDAFONDO__c=lot.medidaFondo;}
                        else if(!isLotsUpdate && lot.medidaFondo==null){throw new LotSAPSeviceException('Debe indicar el campo medidaFondo');}
                        else{mylot.CEN_MEDIDAFONDO__c=lot.medidaFondo;}
                        
                        if(isLotsUpdate && lot.medidaFrente!=null){mylot.CEN_MEDIDAFRENTE__c=lot.medidaFrente;}
                        else if(!isLotsUpdate && lot.medidaFrente==null){throw new LotSAPSeviceException('Debe indicar el campo medidaFrente');}
                        else{mylot.CEN_MEDIDAFRENTE__c=lot.medidaFrente;}
                        
                        if(isLotsUpdate && lot.medidaIzquierda!=null){mylot.CEN_MEDIDAIZQUIERDA__c=lot.medidaIzquierda;}
                        else if(!isLotsUpdate && lot.medidaIzquierda==null){throw new LotSAPSeviceException('Debe indicar el campo medidaIzquierda');}
                        else{mylot.CEN_MEDIDAIZQUIERDA__c=lot.medidaIzquierda;}
                        
                        if(isLotsUpdate && lot.numeroFichaRegistral!=null){mylot.CEN_NUMEROFICHAREGISTRAL__c=lot.numeroFichaRegistral;}
                        //else if(!isLotsUpdate && lot.numeroFichaRegistral==null){throw new LotSAPSeviceException('Debe indicar el campo numeroFichaRegistral');}
                        else{mylot.CEN_NUMEROFICHAREGISTRAL__c=lot.numeroFichaRegistral;}
                        
                        if(isLotsUpdate && lot.numeroKardex!=null){mylot.CEN_NUMEROKARDEX__c=lot.numeroKardex;}
                        //else if(!isLotsUpdate && lot.numeroKardex==null){throw new LotSAPSeviceException('Debe indicar el campo numeroKardex');}
                        else{mylot.CEN_NUMEROKARDEX__c=lot.numeroKardex;}
                        
                        if(isLotsUpdate && lot.precioVenta!=null){mylot.CEN_PRECIOVENTAFUN__c=lot.precioVenta;}
                        else if(!isLotsUpdate && lot.precioVenta==null){throw new LotSAPSeviceException('Debe indicar el campo precioVenta');}
                        else{mylot.CEN_PRECIOVENTAFUN__c=lot.precioVenta;}
                        
                        if(isLotsUpdate && lot.productCode!=null){mylot.ProductCode=lot.productCode;}
                        else if(!isLotsUpdate && lot.productCode==null){throw new LotSAPSeviceException('Debe indicar el campo productCode');}
                        else{mylot.ProductCode=lot.productCode;}
                        
                        if(lot.description!=null){mylot.Description=lot.description;}
                        
                        if(isLotsUpdate && lot.name!=null){mylot.Name=lot.name;}
                        else if(!isLotsUpdate && lot.name==null){throw new LotSAPSeviceException('Debe indicar el campo name');}
                        else{mylot.Name=lot.name;}
                        
                        if(lot.productSKU!=null){mylot.StockKeepingUnit=lot.productSKU;}
                        
                        if(lot.sector!=null){mylot.CEN_SECTOR__c=lot.sector;}
                        
                        if(lot.tieneReserva!=null){mylot.CEN_Tiene_Reserva__c=lot.tieneReserva==true?'Si':'No';}
                        
                        if(lotReq.tipoProyect!=null){mylot.CEN_Tipo_de_proyecto__c=lotReq.tipoProyect;}
                        
                        if(isLotsUpdate && lot.tipoInmueble!=null){mylot.CEN_TIPOINMUEBLE__c=lot.tipoInmueble;}
                        else if(!isLotsUpdate && lot.tipoInmueble==null){throw new LotSAPSeviceException('Debe indicar el campo tipoInmueble');}
                        else{mylot.CEN_TIPOINMUEBLE__c=lot.tipoInmueble;}
                        
                        if(isLotsUpdate && lot.tipoLote!=null){mylot.CEN_TIPOLOTE__c=lot.tipoLote;}
                        else if(!isLotsUpdate && lot.tipoLote==null){throw new LotSAPSeviceException('Debe indicar el campo tipoLote');}
                        else{mylot.CEN_TIPOLOTE__c=lot.tipoLote;}
                        
                        if(lot.tipologia!=null){mylot.CEN_TIPOLOGIA__c=lot.tipologia;}
                        
                        if(lot.urbanizacion!=null){mylot.CEN_Urbanizaci_n__c=lot.urbanizacion;}
                        
                        if(isLotsUpdate && lot.usoInmueble!=null){mylot.CEN_USOINMUEBLE__c=lot.usoInmueble;}
                        else if(!isLotsUpdate && lot.usoInmueble==null){throw new LotSAPSeviceException('Debe indicar el campo usoInmueble');}
                        else{mylot.CEN_USOINMUEBLE__c=lot.usoInmueble;}
                        
                        if(lot.zonificacion!=null){mylot.CEN_ZONIFICACION__c=lot.zonificacion;}
                        
                        if(lot.eliminado!=null){mylot.CEN_eliminado__c=lot.eliminado;}
                        
                        if(isLotsUpdate && lot.areaLote!=null){mylot.AREA__c=lot.areaLote;}
                        else if(!isLotsUpdate && lot.areaLote==null){throw new LotSAPSeviceException('Debe indicar el campo areaLote');}
                        else{mylot.AREA__c=lot.areaLote;}
        
                        lotToProcess.add(mylot);
                        System.debug('lotToProcess: ' + lotToProcess);
                    } catch (Exception ex) {
                        CEN_LotObjectResponse lotEx = new CEN_LotObjectResponse();
                        lotEx.idProject = lotReq.idProyectoSap;
                        lotEx.idLot = lot.idLotSap;
                        lotEx.status = 'error';
                        lotEx.message = ex.getMessage();
                        
                        mylotsResp.add(lotEx);
                    }
                }
            } 
        }
        system.debug('validateData-mylotsResp: '+mylotsResp);
        return mylotsResp;   
    
    }

    private static List<CEN_LotObjectResponse> validateProject (Set<String> projectIds){
        system.debug('validateProject');
        List<CEN_LotObjectResponse>  validateProjResp = new List<CEN_LotObjectResponse> ();
        List<Proyecto__c> getProjUpdate = [SELECT CEN_CODIGOSAP__c FROM Proyecto__c WHERE CEN_CODIGOSAP__c IN :projectIds ];
        String projectExist = string.join(getProjUpdate,','); 
        for(String myId: projectIds){
            if(!projectExist.contains(myId)){
                if(mapProjError==null){mapProjError=new Map<String,String>();}
                CEN_LotObjectResponse projErr = new CEN_LotObjectResponse();
                projErr.idProject=myId;
                projErr.idLot= 'all';
                projErr.status='error';
                projErr.message='No existe el proyecto: '+myId;
                mapProjError.put(myId,'error');

                validateProjResp.add(projErr);
            }
        }
        system.debug('validateProject-validateProjResp: '+validateProjResp);
        return validateProjResp;
    }

    public class LotSAPSeviceException extends Exception {}
}