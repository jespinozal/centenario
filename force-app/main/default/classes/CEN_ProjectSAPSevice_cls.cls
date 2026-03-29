/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-08-2021   @everis.com   Initial Version
**/
@RestResource(urlMapping='/sap/project/*')
global class CEN_ProjectSAPSevice_cls{
    private static List<Proyecto__c> projectToProcess;
    private static Set<String> idExtenalProjectToProcess;
    @HttpPost
    global static String doPost(){
        List<CEN_ProjectObjectResponse> myRespList = new List<CEN_ProjectObjectResponse>();
        try {
            String jsonString = RestContext.request.requestBody.toString();
            //String jsonString ='[{"zonaRegistrada":null,"zona":"Lima Sur 2","tipoVivienda":null,"tipoProyecto":"Urbano","statusProyecto":null,"statusLots":"ARRAS","sociedad":"0018","registro":null,"owner":null,"numeroLicencia":null,"name":"SaritaColonia TEST","montoMinimoReserva":100.00,"montoMinimoDeposito":200.00,"maximumTermForSigningTheContract":1,"maximumPaymentDuePeriod":1,"idSap":"120U3","fechaVigenciaPrecio":null,"fechaInicio":"2021-06-01","fechaEntrega":"2021-06-30","etapa":"3","ejecutivoPostVentaAsignado":null,"departamento":"00001","provincia":"00001","distrito":"00001","direccion":"Olimpo","descripcionProyecto":"Primero Proyecto","codInternoSAP":null,"changeInLotsStatus":false,"centro":"Olimpo","area":"50"}]';
            List<CEN_ProjectObjectRequest> myObjReq = (List<CEN_ProjectObjectRequest> )JSON.deserialize(jsonString,List<CEN_ProjectObjectRequest>.class);
            if(myObjReq.size()<=200){
                List<CEN_ProjectObjectResponse> myRespValidate = validateData(myObjReq,false);
                if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
            
                List<CEN_ProjectObjectResponse> myRespProcess = projectProcess (false); 
                if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
            }else{
                CEN_ProjectObjectResponse lotMax = new CEN_ProjectObjectResponse();
                lotMax.idProject = 'All';
                lotMax.status = 'error';
                lotMax.message = 'Procesar maximo de 200 proyectos';
                
                myRespList.add(lotMax); 
            }
           
        } catch (Exception ex) {
            CEN_ProjectObjectResponse lotEx = new CEN_ProjectObjectResponse();
            lotEx.idProject = 'All';
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
        List<CEN_ProjectObjectResponse> myRespList = new List<CEN_ProjectObjectResponse>();
        try {
            String jsonString = RestContext.request.requestBody.toString();
            //String jsonString ='[{"zonificacion":null,"usoInmueble":null,"urbanizacion":null,"tipoProyect":null,"tipoLote":null,"tipologia":null,"tipoInmueble":null,"tieneReserva":null,"sector":null,"productSKU":null,"productCode":null,"precioVenta":null,"numeroKardex":null,"numeroFichaRegistral":null,"name":null,"medidaIzquierda":null,"medidaFrente":null,"medidaFondo":null,"medidaDerecha":null,"manzana":null,"linderoIzquierda":null,"linderoFrente":null,"linderoFondo":null,"linderoDerecha":null,"isActive":null,"idProyectoSap":null,"idLotSap":null,"fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":null,"description":null,"descripcionLote":null,"descripcionCorta":null,"costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":null,"codLoteSap":"codLoteSapS1","codEstadoLote":null,"codEstadoEntrega":null,"codCompania":null,"codCliente":null,"areaLote":"a111"},{"zonificacion":null,"usoInmueble":null,"urbanizacion":null,"tipoProyect":null,"tipoLote":null,"tipologia":null,"tipoInmueble":null,"tieneReserva":null,"sector":null,"productSKU":null,"productCode":null,"precioVenta":null,"numeroKardex":null,"numeroFichaRegistral":null,"name":null,"medidaIzquierda":null,"medidaFrente":null,"medidaFondo":null,"medidaDerecha":null,"manzana":null,"linderoIzquierda":null,"linderoFrente":null,"linderoFondo":null,"linderoDerecha":null,"isActive":null,"idProyectoSap":null,"idLotSap":null,"fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":null,"description":null,"descripcionLote":null,"descripcionCorta":null,"costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":null,"codLoteSap":"codLoteSapS2","codEstadoLote":null,"codEstadoEntrega":null,"codCompania":null,"codCliente":null,"areaLote":"a222"}]';
            List<CEN_ProjectObjectRequest> myObjReq = (List<CEN_ProjectObjectRequest> )JSON.deserialize(jsonString,List<CEN_ProjectObjectRequest>.class);
        if(myObjReq.size() <= 200){
            List<CEN_ProjectObjectResponse> myRespValidate = validateData(myObjReq,true);
            if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
        
            List<CEN_ProjectObjectResponse> myRespProcess = projectProcess (true); 
            if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
        }else{
            CEN_ProjectObjectResponse lotMax = new CEN_ProjectObjectResponse();
            lotMax.idProject = 'All';
            lotMax.status = 'error';
            lotMax.message = 'Procesar maximo de 200 proyectos';
            
            myRespList.add(lotMax); 
        }
           
       
        } catch (Exception ex) {
            CEN_ProjectObjectResponse lotEx = new CEN_ProjectObjectResponse();
            lotEx.idProject = 'All';
            lotEx.status = 'error';
            lotEx.message = ex.getMessage();
            
            myRespList.add(lotEx);
        }
        String myResp = JSON.serialize(myRespList);
        system.debug('myRespToSap: '+myResp);

        return myResp; 
    
    }

    private static List<CEN_ProjectObjectResponse> projectProcess (Boolean isLotsUpdate){
        List<CEN_ProjectObjectResponse> processResp = new List<CEN_ProjectObjectResponse> ();
        if(projectToProcess.size()>0){
            Database.SaveResult[] srList;
            if(isLotsUpdate){
                List<Proyecto__c> getProjUpdate = [SELECT Id, CEN_CODIGOSAP__c FROM Proyecto__c WHERE CEN_CODIGOSAP__c IN :idExtenalProjectToProcess ];
                for(Proyecto__c getP: getProjUpdate ){
                    for(Proyecto__c pUpdate: projectToProcess){
                        if(pUpdate.CEN_CODIGOSAP__c == getP.CEN_CODIGOSAP__c){
                            pUpdate.Id = getP.Id;
                        }
                    }

                }
                srList = Database.update(projectToProcess, false);
            }
            else{srList = Database.insert(projectToProcess, false);}
            
            Integer pos = 0 ;
            for (Database.SaveResult sr : srList) {
                Proyecto__c getProject = projectToProcess.get(pos);
                if (sr.isSuccess()) {
                    CEN_ProjectObjectResponse lotSucces = new CEN_ProjectObjectResponse();
                    lotSucces.idProject = getProject.CEN_CODIGOSAP__c;
                    lotSucces.status = 'succes';
                    lotSucces.message = 'Proyecto procesado con exito';
                    processResp.add(lotSucces);
                }else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        CEN_ProjectObjectResponse projError = new CEN_ProjectObjectResponse();
                        projError.idProject = getProject.CEN_CODIGOSAP__c;
                        projError.status = 'error';
                        projError.message = isLotsUpdate && getProject.Id==null?'Proyecto no encontrado':err.getStatusCode() + ': ' + err.getMessage();
                        processResp.add(projError);
                    }
                }
                ++pos;
            }
           }
           return processResp;
    }

    private static List<CEN_ProjectObjectResponse> validateData(List<CEN_ProjectObjectRequest> myProjectReq, Boolean isProjectUpdate){
        List<CEN_ProjectObjectResponse> myProjectResp = new List<CEN_ProjectObjectResponse>();
        projectToProcess =  new List<Proyecto__c> ();
        Map<String, String> mapDistri = getDistri ();
        idExtenalProjectToProcess = new Set<String>();
        for(CEN_ProjectObjectRequest proj: myProjectReq){
            Proyecto__c myProj = new Proyecto__c();
            try{
                if( proj.area!=null && String.isNotEmpty(proj.area)){myProj.CEN_Area__c=proj.area;}

                if(proj.changeInLotsStatus!=null){myProj.CEN_ChangeInLotsStatus__c=proj.changeInLotsStatus;}

                if(proj.centro!=null && String.isNotEmpty(proj.centro)){myProj.CEN_Centro__c=proj.centro;}

                if(proj.codInternoSAP!=null && String.isNotEmpty(proj.codInternoSAP)){myProj.CEN_Cod_Interno_SAP__c=proj.codInternoSAP;}

                if(proj.idSap!=null && String.isNotEmpty(proj.idSap)){
                    myProj.CEN_CODIGOSAP__c=proj.idSap;
                    idExtenalProjectToProcess.add(proj.idSap);
                }else{throw new ProjectSAPSeviceException('Debe indicar el campo idSap');}

                if(isProjectUpdate && proj.descripcionProyecto!=null && String.isNotEmpty(proj.descripcionProyecto)){myProj.CEN_Descripci_n_proyecto__c=proj.descripcionProyecto;}
                else if(!isProjectUpdate && (proj.descripcionProyecto==null || String.isEmpty(proj.descripcionProyecto))){throw new ProjectSAPSeviceException('Debe indicar el campo descripcionProyecto');}
                else{myProj.CEN_Descripci_n_proyecto__c=proj.descripcionProyecto;}

                if(isProjectUpdate && proj.direccion!=null && String.isNotEmpty(proj.direccion)){myProj.CEN_Direccion__c=proj.direccion;}
                else if(!isProjectUpdate && (proj.direccion==null || String.isEmpty(proj.direccion))){throw new ProjectSAPSeviceException('Debe indicar el campo direccion');}
                else{myProj.CEN_Direccion__c=proj.direccion;}
                
                String myKeyDistrito;
                if(isProjectUpdate && proj.departamento!=null && String.isNotEmpty(proj.departamento)){myKeyDistrito=proj.departamento;}
                else if(!isProjectUpdate && (proj.departamento==null || String.isEmpty(proj.departamento))){throw new ProjectSAPSeviceException('Debe indicar el campo departamento');}
                else{myKeyDistrito=proj.departamento;}
                
                if(isProjectUpdate && proj.provincia!=null && String.isNotEmpty(proj.provincia)){myKeyDistrito+=proj.provincia;}
                else if(!isProjectUpdate && (proj.provincia==null || String.isEmpty(proj.provincia))){throw new ProjectSAPSeviceException('Debe indicar el campo provincia');}
                else{myKeyDistrito=myKeyDistrito+proj.provincia;}

                if(isProjectUpdate && proj.distrito!=null){myKeyDistrito+=proj.distrito;}
                else if(!isProjectUpdate && proj.distrito==null){throw new ProjectSAPSeviceException('Debe indicar el campo distrito');}
                else{myKeyDistrito=myKeyDistrito+proj.distrito;}
                system.debug('*** myKeyDistrito: '+myKeyDistrito);
                if(myKeyDistrito!=null && mapDistri.get(myKeyDistrito)!=null){myProj.CEN_Distrito__c = mapDistri.get(myKeyDistrito);}
                else if(myKeyDistrito!=null && mapDistri.get(myKeyDistrito)==null){throw new ProjectSAPSeviceException('No se puede verificar la ubicacion del departamento, provincia y distrito');}
                else {myProj.CEN_Distrito__c = mapDistri.get(myKeyDistrito);}

                //**** Se debe mapear el UserNameAD del USER ?? ****
                if(proj.ejecutivoPostVentaAsignado!=null && String.isNotEmpty(proj.ejecutivoPostVentaAsignado)){myProj.CEN_Ejecutivo_Post_Venta_Asignado__c=proj.ejecutivoPostVentaAsignado;}
              
                if(proj.statusLots!=null && String.isNotEmpty(proj.statusLots)){myProj.CEN_StatusLots__c=proj.statusLots;}
              
                if(isProjectUpdate && proj.etapa!=null && String.isNotEmpty(proj.etapa) ){myProj.CEN_Etapa__c=proj.etapa;}
                else if(!isProjectUpdate && (proj.etapa==null || String.isEmpty(proj.etapa))){throw new ProjectSAPSeviceException('Debe indicar el campo etapa');}
                else{myProj.CEN_Etapa__c=proj.etapa;}

                String strFechaEntrega = proj.fechaEntrega;
                if(strFechaEntrega!=null && String.isNotEmpty(strFechaEntrega)){
                    strFechaEntrega = strFechaEntrega.replace('T', ' ');
                    Date fe = Date.valueOf(strFechaEntrega);
                    myProj.CEN_Fecha_entrega__c=fe;
                }

               String strFechaInicio = proj.fechaInicio;
               if(strFechaEntrega!=null && String.isNotEmpty(strFechaEntrega)){
                    strFechaEntrega = strFechaEntrega.replace('T', ' ');
                    Date fi = Date.valueOf(strFechaEntrega);
                    myProj.CEN_FchInicio__c=fi;
                }
              
                String strFechaVigencia = proj.fechaVigenciaPrecio;
                if(strFechaVigencia!=null && String.isNotEmpty(strFechaVigencia)){
                    strFechaVigencia = strFechaVigencia.replace('T', ' ');
                    Date fv = Date.valueOf(strFechaVigencia);
                    myProj.CEN_Fecha_Vigencia_Precio__c=fv;
                }
                Decimal myMontoMinimoDeposito = proj.montoMinimoDeposito!=null && String.isNotEmpty(proj.montoMinimoDeposito)? Decimal.ValueOf((proj.montoMinimoDeposito).trim()):0;
                if(isProjectUpdate && myMontoMinimoDeposito > 0 ){myProj.CEN_monto_minimo_deposito__c=myMontoMinimoDeposito;}
                else if(!isProjectUpdate && myMontoMinimoDeposito ==0 ){throw new ProjectSAPSeviceException('Debe indicar el campo montoMinimoDeposito');}
                else{myProj.CEN_monto_minimo_deposito__c=myMontoMinimoDeposito;}


                Decimal myMontoMinimoReserva = proj.montoMinimoReserva!=null && String.isNotEmpty(proj.montoMinimoReserva)?Decimal.ValueOf((proj.montoMinimoReserva).trim()):0;
                if(isProjectUpdate && myMontoMinimoReserva > 0){myProj.CEN_monto_minimo_reserva__c=myMontoMinimoReserva;}
                else if(!isProjectUpdate && myMontoMinimoReserva==0 ){throw new ProjectSAPSeviceException('Debe indicar el campo montoMinimoReserva');}
                else{myProj.CEN_monto_minimo_reserva__c=myMontoMinimoReserva;}

                if(isProjectUpdate && proj.name!=null && String.isNotEmpty(proj.name)){myProj.Name=proj.name;}
                else if(!isProjectUpdate && (proj.name==null || String.isEmpty(proj.name))){throw new ProjectSAPSeviceException('Debe indicar el campo name');}
                else{myProj.Name=proj.name;}

                if(proj.numeroLicencia!=null && String.isNotEmpty(proj.numeroLicencia) ){myProj.CEN_Numerodelicencia__c=proj.name;}
              
                if(proj.maximumTermForSigningTheContract!=null  && String.isNotEmpty(proj.maximumTermForSigningTheContract)){myProj.CEN_MaximumTermForSigningTheContract__c= Integer.valueOf(proj.maximumTermForSigningTheContract);}
              
                if(proj.maximumPaymentDuePeriod!=null && String.isNotEmpty(proj.maximumPaymentDuePeriod)){myProj.CEN_MaximumPaymentDuePeriod__c= Integer.valueOf(proj.maximumPaymentDuePeriod);}
              
                if(proj.registro!=null && String.isNotEmpty(proj.registro)){myProj.CEN_Registro__c=proj.registro;}

                if(isProjectUpdate && proj.sociedad!=null && String.isNotEmpty(proj.sociedad)){myProj.CEN_Sociedad__c=proj.sociedad;}
                else if(!isProjectUpdate && (proj.sociedad==null || String.isEmpty(proj.sociedad) )){throw new ProjectSAPSeviceException('Debe indicar el campo sociedad');}
                else{myProj.CEN_Sociedad__c=proj.sociedad;}

                if(proj.statusProyecto!=null && String.isNotEmpty(proj.statusProyecto)){myProj.CEN_Status_del_proyecto__c=proj.statusProyecto;}

                if(isProjectUpdate && proj.tipoProyecto!=null && String.isNotEmpty(proj.tipoProyecto)){myProj.CEN_Tipo_de_proyecto__c=proj.tipoProyecto;}
                else if(!isProjectUpdate && (proj.tipoProyecto==null || String.isEmpty(proj.tipoProyecto))){throw new ProjectSAPSeviceException('Debe indicar el campo tipoProyecto');}
                else{myProj.CEN_Tipo_de_proyecto__c=proj.tipoProyecto;}

                if(proj.tipoVivienda!=null && String.isNotEmpty(proj.tipoVivienda)){myProj.CEN_Tipo_vivienda__c=proj.tipoVivienda;}

                if(isProjectUpdate && proj.zona!=null && String.isNotEmpty(proj.zona)){myProj.Zona__c=proj.zona;}
                else if(!isProjectUpdate && (proj.zona==null || String.isEmpty(proj.zona))){throw new ProjectSAPSeviceException('Debe indicar el campo zona');}
                else{myProj.Zona__c=proj.zona;}

                if(proj.zonaRegistrada!=null && String.isNotEmpty(proj.zonaRegistrada)){myProj.CEN_Zona_Registrada__c=proj.zonaRegistrada;}

                projectToProcess.add(myProj);
            } catch (Exception ex) {
                CEN_ProjectObjectResponse projEx = new CEN_ProjectObjectResponse();
                projEx.idProject = myProj.CEN_CODIGOSAP__c;
                projEx.status = 'error';
                projEx.message = 'errorValidate: ' +ex.getMessage();
                
                myProjectResp.add(projEx);
            }
        }
        return myProjectResp;   
    
    }

    private static Map<String, String> getDistri (){
        Map<String, String> mapRes = new Map<String, String>();
       List<Tabla_maestra__c> distris = [SELECT Id, CEN_Codigo_departamento__c, CEN_Codigo_distrito__c, CEN_Codigo_provincia__c FROM Tabla_maestra__c];
       for(Tabla_maestra__c d: distris){
        String myKey = d.CEN_Codigo_departamento__c + d.CEN_Codigo_provincia__c + d.CEN_Codigo_distrito__c;
        mapRes.put(myKey, d.Id);
       }
       return mapRes;
    }

    public class ProjectSAPSeviceException extends Exception {}

}