/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * @last modified by  : Felipe Bermudez (Se realizo el ajuste para generar token y consumo de servicio CEN_SharePoint_Documentos_Token
**/
public with sharing class CEN_CargaDocumentoOnbase {
    
    /**
    * @description Obtención de token
    * @author Richard Villafana - NTT DATA | 09-06-2024 
    * @return CEN_CargaDocumentoOnbaseApi 
    **/
    @AuraEnabled
    public static CEN_CargaDocumentoOnbaseApi getToken(){
        Map<String, String> body    =   new Map<String, String>();
        body.put('usuario',     '{!HTMLENCODE($Credential.Username)}');
        body.put('contraseña',  '{!HTMLENCODE($Credential.Password)}');
        String jsonRequest  =   JSON.serialize(body);
        String respuesta;
        CEN_CargaDocumentoOnbaseApi resp;

        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_SharePoint_Documentos_Token');
            callApi.setRequestBody      (jsonRequest);
            callApi.setTimeout          (120000);
            if(!Test.isRunningTest()){
                respuesta       =   (String) callApi.makeCallout().getParsedResponse();
            }else{
                respuesta       =   '{"Token":"e16783d3-fc50-4015-b9fe-a4b4f9449f8a"}';
            }
            resp    =   CEN_CargaDocumentoOnbaseApi.parseToken(respuesta);
        } catch (Exception e) {
            System.debug('Error de petición: '+e);
        }
        System.debug('respuesta: '+resp);
        return resp;
    }

    
    /**
    * @description Envío de documentos a OnBase
    * @author Richard Villafana - NTT DATA | 09-06-2024 
    * @param idCaso 
    * @param tipoDeClausula     = PREPAGO, RESOLUCION
    * @param extensionArchivo   =   PDF
    * @param docBase64 
    * @return CEN_CargaDocumentoOnbaseApi.documentoResponse 
    **/
    public static CEN_CargaDocumentoOnbaseApi.documentoResponse  sendDocumentos(String idCaso, String tipoDeClausula, String extensionArchivo, String docBase64){
        CEN_CargaDocumentoOnbaseApi token = new CEN_CargaDocumentoOnbaseApi();
        CEN_CargaDocumentoOnbaseApi.documentoRequest request    =   new CEN_CargaDocumentoOnbaseApi.documentoRequest();
        Case caso   =   [SELECT CaseNumber, Account.RecordType.DeveloperName, CEN_Etapa__c, CEN_VersionFinanciamiento__c,
                        CEN_CodFinanciamiento__c, Account.Name, Account.CEN_Tipo_de_documento__c, toLabel(Account.CEN_Tipo_de_documento__pc),
                        Account.CEN_N_mero_de_documento__pc, Account.CEN_Numero_de_documento_del__c, CEN_Lotes_asignados__c, CEN_CodigoDeLotes__c, ParentId,
                        Parent.CEN_CodFinanciamiento__c, Parent.CaseNumber, CEN_SociedadFinanciamiento__c, RecordType.DeveloperName
                        FROM Case
                        WHERE Id =: idCaso
                        WITH SECURITY_ENFORCED];
        System.debug('caso: '+caso);
        System.debug('caso: '+caso.Account.RecordType.DeveloperName);
        if(caso.CEN_SociedadFinanciamiento__c   ==  '0010'){
            request.empresa_centenario          =   'INVERSIONES CENTENARIO S.A.A.';
        }else if(caso.CEN_SociedadFinanciamiento__c   ==  '0019'){
            request.empresa_centenario          =   'CENTENARIO DESARROLLO';
        }
        
        if(caso.Account.RecordType.DeveloperName    ==  'PersonAccount'){
            request.tipo_personeria         =   'PERSONA NATURAL';
            CEN_CargaDocumentoOnbaseApi.PersonaNaturalRequest   personaNatural  =   new CEN_CargaDocumentoOnbaseApi.PersonaNaturalRequest();
            personaNatural.nombre_apellido  =   caso.Account.Name;
            if(caso.Account.CEN_Tipo_de_documento__pc ==  'Carnet de Extranjería'){
                personaNatural.tipo_documento   =   'C.E';
            }else if(caso.Account.CEN_Tipo_de_documento__pc ==  'DNI' || caso.Account.CEN_Tipo_de_documento__pc ==  'RUC' || caso.Account.CEN_Tipo_de_documento__pc ==  'Pasaporte'){
                personaNatural.tipo_documento   =   caso.Account.CEN_Tipo_de_documento__pc.toUpperCase();
            }else{
                personaNatural.tipo_documento   =   'Sin especificar';
            }
            personaNatural.nro_documento        =   caso.Account.CEN_N_mero_de_documento__pc;
            request.persona_natural             =   new List<CEN_CargaDocumentoOnbaseApi.PersonaNaturalRequest>();
            request.persona_natural.add(personaNatural);
            request.persona_juridica            =   new List<CEN_CargaDocumentoOnbaseApi.PersonaJuridicaRequest>();
        }else if(caso.Account.RecordType.DeveloperName    ==  'Cuenta_Empresa'){
            request.tipo_personeria         =   'PERSONA JURIDICA';
            CEN_CargaDocumentoOnbaseApi.PersonaJuridicaRequest   personaJuridica  =   new CEN_CargaDocumentoOnbaseApi.PersonaJuridicaRequest();
            personaJuridica.razon_social    =   caso.Account.Name;
            personaJuridica.ruc             =   caso.Account.CEN_Numero_de_documento_del__c;
            request.persona_juridica        =   new List<CEN_CargaDocumentoOnbaseApi.PersonaJuridicaRequest>();
            request.persona_juridica.add(personaJuridica);
            request.persona_natural         =   new List<CEN_CargaDocumentoOnbaseApi.PersonaNaturalRequest>();

        }
        if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionUrbanoResolucion'){
            request.tipo_clausula       =   'RESOLUCION';
        }else if(caso.RecordType.DeveloperName    ==  'CEN_InteraccionPrepago'){
            request.tipo_clausula       =   'PREPAGO';
        }
        
        request.fecha_documento              =   Date.today().year() + '/' + Date.today().month() + '/' + Date.today().day();
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

        List<String> codigosLotes   =   new List<String>();
        if(caso.CEN_CodigoDeLotes__c !=null && caso.CEN_CodigoDeLotes__c.contains(',')){
            codigosLotes  =   caso.CEN_CodigoDeLotes__c.split(',');
        }else{
            codigosLotes.add(caso.CEN_CodigoDeLotes__c);
        }
        Map<String, List<String>>   mapaProductos   =   new Map<String, List<String>>();
        if(codigosLotes.size()    >   0){
            mapaProductos   =   getProducto(codigosLotes);
        }
        List<CEN_CargaDocumentoOnbaseApi.MzLoteRequest>    listaLotes   =   new List<CEN_CargaDocumentoOnbaseApi.MzLoteRequest>();
        if(mapaProductos.size() >   0){
            for(String codigoLote   :   codigosLotes){
                if(mapaProductos.containsKey(codigoLote)){
                    CEN_CargaDocumentoOnbaseApi.MzLoteRequest    lote    =   new CEN_CargaDocumentoOnbaseApi.MzLoteRequest();
                    List<String> mzLt = new List<String>();
                    mzLt            =  parseLoteInfo(mapaProductos.get(codigoLote)[0]);
                    lote.manzana    =   mzLt[0];
                    lote.lote       =   mzLt[1];
                    listaLotes.add(lote);
                }
            }
        }
        request.mz_lt               =   new List<CEN_CargaDocumentoOnbaseApi.MzLoteRequest>();
        request.mz_lt               =   listaLotes;
        request.extension_archivo   =   extensionArchivo;
        request.docbase_64          =   docBase64;

        String jsonRequest      =   JSON.serialize(request);
        System.debug('request: '+ jsonRequest);
        token   =   getToken();
        System.debug('token: '+ token);

        Map<String, String> mapaHeaderToken  =   new Map<String, String>();
        CEN_CargaDocumentoOnbaseApi.documentoResponse resp;
        if(token!=null){
            mapaHeaderToken.put('Token',  token.Token);
            //mapaHeaderToken.put('Token',  '7206576a-a06a-41ad-944c-dc4d475a80dc');
            
            String respuesta;
            try {
                CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_OnbaseDocumentos');
                callApi.setRequestBody      (jsonRequest);
                callApi.setTimeout          (120000);
                callApi.setHeaders          (mapaHeaderToken);
                if(!Test.isRunningTest()){
                    respuesta   =   (String) callApi.makeCallout().getParsedResponse();
                }else{
                    respuesta   =   '{"cod_respuesta":0,"mensaje_error":" Mensaje: Cargo Exitosamente. ID: 2328083"}';
                }
                resp                    =   CEN_CargaDocumentoOnbaseApi.parseDocumento(respuesta);
            } catch (Exception e) {
                System.debug('Error de petición: '+e);
            }
        }else{
            resp = new CEN_CargaDocumentoOnbaseApi.documentoResponse();
            resp.cod_respuesta  =   '500';
            resp.mensaje_error  =   'No se pudo obtener token';
        }
        

        return resp;
    }
    /**
    * @description Obtener mapa de productos con código de producto y nombre del producto.
    * @author Richard Villafana - NTT DATA | 08-08-2024 
    * @param lProductos 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String, List<String>> getProducto(List<String> lProductos){
        Map<String, List<String>> mapNameCodigoProducto     =   new Map<String, List<String>>();
        List<Product2> lProductosObj                        =   new List<Product2>();
        lProductosObj                                       =   [SELECT Id, Name, CODLOTE__c
                                                                FROM Product2
                                                                WHERE CODLOTE__c IN:lProductos
                                                                AND CODLOTE__c != null
                                                                WITH SECURITY_ENFORCED];
        if(lProductosObj.size()    >   0){
            for(Product2 producto   :   lProductosObj){
                mapNameCodigoProducto.put(producto.CODLOTE__c, new List<String>{producto.Name, producto.Id});
            }
        }
        return mapNameCodigoProducto;
    }
    /**
    * @description Obtener la Manzana y Lote del nombre de Product2
    * @author Richard Villafana - NTT DATA | 09-06-2024 
    * @param loteInfo 
    * @return List<String> 
    **/
    public static List<String> parseLoteInfo(String loteInfo) {
        List<String> mzLt = new List<String>();
        // Expresión regular para encontrar el valor después de Mz.
        Pattern mzPattern = Pattern.compile('Mz\\.\\s*([A-Za-z0-9]+)');
        Matcher mzMatcher = mzPattern.matcher(loteInfo);
        
        // Expresión regular para encontrar el valor después de Lt.
        Pattern ltPattern = Pattern.compile('Lt\\.\\s*([A-Za-z0-9]+)');
        Matcher ltMatcher = ltPattern.matcher(loteInfo);
        
        String mz = '';
        String lt = '';
        
        // Extraer el valor de Mz.
        if (mzMatcher.find()) {
            mz = mzMatcher.group(1); // Captura el valor de Mz.
        }
        // Extraer el valor de Lt.
        if (ltMatcher.find()) {
            lt = ltMatcher.group(1); // Captura el valor de Lt.
        }
        mzLt.add(mz);
        mzLt.add(lt);
        System.debug('Mz: ' + mz);
        System.debug('Lt: ' + lt);
        return mzLt;
    }
    
    /**
    * @description Namecredential para armar el endpoint en js
    * @author Felipe Bermudez - NTT DATA | 17-09-2025 
    **/
    @AuraEnabled
    public static String getEndPointCargarDocumentoPrepago(){
        NamedCredential nc = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName='CEN_SharePoint_Documentos_Service' LIMIT 1];
        return nc.Endpoint;
    }
}