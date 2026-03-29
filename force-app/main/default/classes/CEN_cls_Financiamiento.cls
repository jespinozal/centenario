/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 24-06-2025
 * clase TEST         :
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   04-19-2021   @everis.com       Initial Version
 * 1.1   24-06-2025   Felipe Bermudez   Se agrego Nuevo campo FechaEntregaLoteContrato a la respuesta para mostrar en LWC linea 141
 **/
public class CEN_cls_Financiamiento {

    private static String customReq =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
    '<soapenv:Header/>' +
    '<soapenv:Body>myBody' +
    '</soapenv:Body>' +
    '</soapenv:Envelope>';

    public class CabeceraProforma{
        @AuraEnabled public List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotes{get;set;}
        //@AuraEnabled public CEN_WS_Estado_Cuenta_Uno.ZstProformaK proforma{get;set;}
        @AuraEnabled public CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K proforma{get;set;}
        @AuraEnabled public Integer CantidadLotes{get;set;}
        @AuraEnabled public String LotesConcatenado{get;set;}
    }
    public class Financiamiento{
        @AuraEnabled public List<CabeceraProforma> cabeceras{get;set;}
        @AuraEnabled public Account cuenta{get;set;}
        @AuraEnabled public String mensaje{get;set;}
    }
    @AuraEnabled
    public static Financiamiento getFinanciamiento(String recordId){
        System.debug('<!--getFinanciamiento('+recordId+')');
        Financiamiento finan = new Financiamiento();
        finan.cabeceras = new List<CabeceraProforma>();
        Account cuenta = null;
        try{
            cuenta = [SELECT Id, Name, CEN_Tipo_de_documento__pc, CEN_Tipo_de_documento__c, CEN_N_mero_de_documento__pc, CEN_Numero_de_documento_del__c, RecordType.Name FROM Account WHERE ID=:recordId LIMIT 1];
        }catch(Exception ex){
            System.debug('Ex search cuenta: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
        }
        if(cuenta!=null){
            finan.cuenta = cuenta;
            finan.mensaje='OK';
            String tipo_cuenta = cuenta.RecordType.Name;
            if(String.isNotBlank(tipo_cuenta)){
                tipo_cuenta = tipo_cuenta.toUpperCase();
                tipo_cuenta = tipo_cuenta.trim();
            }
            List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotes = new List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES>();
            if(tipo_cuenta=='CUENTA NATURAL'){
                finan.cabeceras = getFinanciamientoByNdoc(cuenta.CEN_N_mero_de_documento__pc);
                lotes  = CEN_Lotes_Cliente.LotesPorClientSAP(cuenta.CEN_Tipo_de_documento__pc, cuenta.CEN_N_mero_de_documento__pc);
            }else{
                finan.cabeceras = getFinanciamientoByNdoc(cuenta.CEN_Numero_de_documento_del__c);
                lotes = CEN_Lotes_Cliente.LotesPorClientSAP(cuenta.CEN_Tipo_de_documento__c, cuenta.CEN_Numero_de_documento_del__c);
            }
            for(Integer i=0;i<finan.cabeceras.size();i++){
                finan.cabeceras[i].lotes = new List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES>();
                finan.cabeceras[i].CantidadLotes=0;
                finan.cabeceras[i].LotesConcatenado='';
                for(Integer j=0;j<lotes.size();j++){
                    if(lotes[j]!=null&&finan.cabeceras[i]!=null&&finan.cabeceras[i].proforma!=null&&
                       lotes[j].PROFORMA==finan.cabeceras[i].proforma.Proforma){
                           finan.cabeceras[i].CantidadLotes+=1;
                           finan.cabeceras[i].LotesConcatenado+=getLtMz(lotes[j].DESCRIPCION_LARGA);
                           finan.cabeceras[i].lotes.add(lotes[j]);
                           lotes.remove(j);
                           j--;
                    }
                }
            }
        }
        System.debug('-->getFinanciamiento('+recordId+'): ' +finan);
        return finan;
    }

    private static String getLtMz(String descripcionlote){
        String mz = '';
        String lt = '';
        if(String.isNotBlank(descripcionlote)){
            descripcionlote = descripcionlote.toUpperCase();
            mz = descripcionlote.substringBetween('MZ.', ' LT.');
            lt = descripcionlote.substringAfter('LT.');
        }
        return ('Mz. '+mz+' Lt. '+lt+'/');
    }

    public static List<CabeceraProforma> getFinanciamientoByNdoc(String ndocumento){
        System.debug('<!-- Iniciando getFinanciamientoByNdoc.('+ndocumento+')');
        List<CabeceraProforma> cabeceras = new List<CabeceraProforma>();
        CEN_WS_Estado_Cuenta_Uno.ZWS_ESTADO_CTA_UNO service = new  CEN_WS_Estado_Cuenta_Uno.ZWS_ESTADO_CTA_UNO();
        service.timeout_x=120000;
        service.inputHttpHeaders_x = new Map<String,String>();
        service.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(label.CEN_usersap+':'+label.CEN_passSap)));
        CEN_WS_Estado_Cuenta_Uno.ZFS_RFC_ESTADO_CUENTAResponse_element element = null;
        try{
            element = service.ZFS_RFC_ESTADO_CUENTA(ndocumento, new CEN_WS_Estado_Cuenta_Uno.TABLE_OF_ZST_PROFORMA_K());            
        }catch(Exception ex){
            System.debug('Exception obteniendo proformas desde SAP: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Tipo: '+ex.getTypeName());          
        }
        if(element!=null){
            if(String.isBlank(element.FL_ERROR)){
                for(Integer i=0;i<element.T_SALIDA.item.size();i++){
                    CabeceraProforma cproforma = new CabeceraProforma();
                    cproforma.proforma = element.T_SALIDA.item[i];
                    cproforma.lotes = new List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES>();
                    cabeceras.add(cproforma);
                }
                System.debug(element.T_SALIDA.item);
            }else{
                System.debug(element.FL_ERROR);
            }
        }
        System.debug('!--> Terminando getFinanciamientoByNdoc.('+ndocumento+'): '+cabeceras.size());
        return cabeceras;
    }

    @AuraEnabled
    public static List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP> getDetalleFinanciamiento(String proforma, String version){
        System.debug('<!-- Iniciando getDetalleFinanciamiento: proforma '+proforma+' y version '+version);        
        List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP> table= null;
        if(String.isNotBlank(proforma)&&String.isNotBlank(version)){
            try{
                proforma=String.valueOf(Integer.valueOf(proforma));
                version=String.valueOf(Integer.valueOf(version));
            }catch(Exception ex){
                System.debug('Exception tratando proforma y version: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Tipo: '+ex.getTypeName());            
            }
        }
        // if(String.isNotBlank(proforma)&&String.isNotBlank(version)){
        //     CEN_WS_Estado_Cuenta_Dos.ZWSSF_ESTADO_CUENTA2_BD service = new CEN_WS_Estado_Cuenta_Dos.ZWSSF_ESTADO_CUENTA2_BD();
        //     service.timeout_x=120000;
        //     service.inputHttpHeaders_x = new Map<String,String>();
        //     service.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(label.CEN_usersap+':'+label.CEN_passSap)));
        //     CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element element = null;
        //     try{
        //         element = service.ZfsRfcEstadoCuenta2(proforma, version);
        //         if(element!=null&&element.ExTStProformaP!=null&&element.ExTStProformaP.item!=null){
        //             table= new List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP>();
        //             System.debug('Detalles: '+element.ExTStProformaP.item.size());
        //             for(Integer i=0;i<element.ExTStProformaP.item.size();i++){
        //                 table.add(element.ExTStProformaP.item[i]);
        //             }
        //         }
        //     }catch(Exception ex){
        //         System.debug('Exception obteniendo proformas desde SAP: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Tipo: '+ex.getTypeName());            
        //     }    
        // }
        // INICIO -> Campo nuevo que llega en cuentas 2 se agrego 
        if(String.isNotBlank(proforma)&&String.isNotBlank(version)){
            CEN_WS_Estado_Cuenta_Dos.ZWSSF_ESTADO_CUENTA2_BD service = new CEN_WS_Estado_Cuenta_Dos.ZWSSF_ESTADO_CUENTA2_BD();
            service.timeout_x=120000;
            service.inputHttpHeaders_x = new Map<String,String>();
            service.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(label.CEN_usersap+':'+label.CEN_passSap)));
            CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element element = null;
            try{
                element = service.ZfsRfcEstadoCuenta2(proforma, version);
                if(element!=null&&element.ExTStProformaP!=null&&element.ExTStProformaP.item!=null){
                    table= new List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP>();
                    System.debug('Detalles: '+element.ExTStProformaP.item.size());
                    for(Integer i=0;i<element.ExTStProformaP.item.size();i++){
                        table.add(element.ExTStProformaP.item[i]);
                    }
                }
                if(element!=null&&element.ExTStProformaK!=null&&element.ExTStProformaK.item!=null){
                    for(Integer i=0;i<element.ExTStProformaK.item.size() && i<table.size();i++){
                        table[i].FechaEntregaLoteContrato = element.ExTStProformaK.item[i].FechaEntregaLoteContrato;
                    }
                }
            }catch(Exception ex){
                System.debug('Exception obteniendo proformas desde SAP: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Tipo: '+ex.getTypeName());            
            }    
        }
        
        System.debug('!--> Terminando getDetalleFinanciamiento: proforma '+proforma+' y version '+version);
        return table;        
    }
   
    public static CEN_FinancingObjectResponse updateFinancing(
        CEN_FinancingObjectRequest reqProcess
    ) {
        System.debug('IN setUpdateFinancing');
        String customReqBody;
        CEN_FinancingObjectResponse resp = new CEN_FinancingObjectResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_OTC_MODIF_DATOS_FINANC_WS',
            'urn:ZRFC_OTC_MODIF_DATOS_FINANC_WS'
        );

        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_Financing');
            Dom.Document docReq = new Dom.Document();
            String setReq = customReq.replace('myBody', customReqBody);
            System.debug('setUpdateFinancing-setReq: ' + setReq);
            docReq.load(setReq);
            callApi.setRequestBody(docReq);
                if(!Test.isRunningTest()){
                    callApi.setTimeout(30000);
                }
            resp = (CEN_FinancingObjectResponse) callApi.makeCallout().getParsedResponse();
            System.debug('setUpdateFinancing-resp: ' + resp);
        } catch (Exception ex) {
            System.debug('setUpdateFinancing-Error: ' + ex.getMessage());
            CEN_FinancingObjectResponse.BAPIRET2_T respError = new CEN_FinancingObjectResponse.BAPIRET2_T();
            List<CEN_FinancingObjectResponse.BAPIRET2> respErrorList = new List<CEN_FinancingObjectResponse.BAPIRET2>();
            CEN_FinancingObjectResponse.BAPIRET2 respErrorDetails = new CEN_FinancingObjectResponse.BAPIRET2();
            respErrorDetails.MESSAGE = ex.getMessage()+', en la linea: '+ex.getLineNumber();
            respErrorDetails.TYPE_x ='apiErrorCatch';
            respErrorList.add(respErrorDetails);
            respError.item = respErrorList;
            resp.ET_RETURN = respError;
        }
        return resp;
    }

    public static CEN_FinancingObjectRequest.ZTT_PROFORMA setProforma(List<CEN_FinancingObjectRequest.ZPROFORMA_S> items) {
        System.debug('setProforma-items: ' + items);
        CEN_FinancingObjectRequest.ZTT_PROFORMA proformas = new CEN_FinancingObjectRequest.ZTT_PROFORMA();
        proformas.item = items;

        System.debug('setProforma-proformas: ' + proformas);
        return proformas;
    }

    @AuraEnabled
    public static Map<String,String> setUpdateFinancing(String proforma, 
        String notaria, 
        String localidad, 
        String kardex, 
        String partida, 
        String fecha,
        String notaria_x, 
        String localidad_x, 
        String kardex_x, 
        String partida_x, 
        String fecha_x
    ){
        System.debug('<!--setUpdateFinancing(Proforma: ' +proforma+ ' Notaria:'+notaria+' Localidad:'+localidad+' Kardex:'+kardex+' Partida:'+partida+' Fecha:'+fecha+')');
        System.debug('<!--setUpdateFinancingX(Notaria:'+notaria_x+' Localidad:'+localidad_x+' Kardex:'+kardex_x+' Partida:'+partida_x+' Fecha:'+fecha_x+')');
        System.debug('***IN CEN_cls_Financiamiento.setUpdateFinancing***');
        CEN_FinancingObjectResponse resp;
        CEN_FinancingObjectRequest req = new CEN_FinancingObjectRequest();
        Map<String,String> mapResp = new Map<String,String>();
        try {
            CEN_FinancingObjectRequest.ZRFC_OTC_MODIF_DATOS_FINANC_WS_element reqElement = new CEN_FinancingObjectRequest.ZRFC_OTC_MODIF_DATOS_FINANC_WS_element();
            List<CEN_FinancingObjectRequest.ZPROFORMA_S> items = new List<CEN_FinancingObjectRequest.ZPROFORMA_S>();
            CEN_FinancingObjectRequest.ZPROFORMA_S item = new CEN_FinancingObjectRequest.ZPROFORMA_S();

            CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEN reqData = new CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEN();
            CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEX reqDatax = new CEN_FinancingObjectRequest.ZACCO_MODIF_DATOS_FINANCIAMIEX();
            item.PROFORMA = proforma;
            items.add(item);
            

            reqElement.IT_PROFORMA = setProforma(items);

            reqData.NOMBRE_NOTARIO = notaria_x == 'X' ? notaria : '';
            reqData.LOCAL_REGISTRO = localidad_x == 'X' ? localidad : '';
            reqData.NUMERO_KARDEX = kardex_x == 'X' ? kardex : '';
            reqData.NO_PARTIDA = partida_x == 'X' ? partida : '';
            reqData.FECHA_ENTREGA_FISICA = fecha_x == 'X' ? fecha : '';
        
            reqDatax.NOMBRE_NOTARIO = notaria_x;
            reqDatax.LOCAL_REGISTRO = localidad_x;
            reqDatax.NUMERO_KARDEX = kardex_x;
            reqDatax.NO_PARTIDA = partida_x;
            reqDatax.FECHA_ENTREGA_FISICA = fecha_x;

            reqElement.IS_MODIF_DATOS_FINANCIAMIENTO = reqData;
            reqElement.IS_MODIF_DATOS_FINANCIAMIENTOX = reqDatax;

            req.ZRFC_OTC_MODIF_DATOS_FINANC_WS = reqElement;

        } catch (Exception ex) {
            resp = new CEN_FinancingObjectResponse();
            CEN_FinancingObjectResponse.BAPIRET2_T respError = new CEN_FinancingObjectResponse.BAPIRET2_T();
            List<CEN_FinancingObjectResponse.BAPIRET2> respErrorList = new List<CEN_FinancingObjectResponse.BAPIRET2>();
            CEN_FinancingObjectResponse.BAPIRET2 respErrorDetails = new CEN_FinancingObjectResponse.BAPIRET2();
            respErrorDetails.TYPE_x ='dataErrorCatch';
            respErrorDetails.MESSAGE = ex.getMessage()+', en la linea: '+ex.getLineNumber();
            respErrorList.add(respErrorDetails);
            respError.item = respErrorList;
            resp.ET_RETURN = respError;
        }

        if(resp == null ){
            resp = new CEN_FinancingObjectResponse();
            resp = updateFinancing(req);
        }

        System.debug('***OUT CEN_cls_Financiamiento.setUpdateFinancing***');
        mapResp.put('mensaje',resp.ET_RETURN.item[0].MESSAGE);
        mapResp.put('estado',resp.ET_RETURN.item[0].TYPE_x);

        return mapResp;
    }

}