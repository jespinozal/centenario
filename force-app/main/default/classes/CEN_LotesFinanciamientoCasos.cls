/**
 * @description       : Clase Apex que se utiliza en el componente lwc CEN_LotesFinanciamientoCasos
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-20-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
public with sharing class CEN_LotesFinanciamientoCasos {
    
    /**
    * @description Método que formatea datos de financiamientos y lotes con la respuesta de SAP.
    * @author Richard Villafana - NTT DATA | 09-10-2024 
    * @param idCaso 
    * @return CEN_LotesFinanciamientoCasosApi 
    **/
    @AuraEnabled
    public static CEN_LotesFinanciamientoCasosApi getLotesFinanciamientos(String idCaso){
        Case  registroDeCaso    =   [SELECT Id, Account.CEN_N_mero_de_documento__pc, Account.CEN_Numero_de_documento_del__c, Account.IsPersonAccount
                                    FROM Case 
                                    WHERE Id=:idCaso
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1 ];
        String numeroDeDocumento;
        if(registroDeCaso.Account.IsPersonAccount){
            numeroDeDocumento   =   registroDeCaso.Account.CEN_N_mero_de_documento__pc;
        }else{
            numeroDeDocumento   =   registroDeCaso.Account.CEN_Numero_de_documento_del__c;
        }
        //String jsonRespuesta    =   '{"financiamientos": [{"proforma": 59530,"version": 1,"bukrs": "0019","processo": "19U1.902E","estadoFinanciamiento": "A","urbanizacion": "INDRA ETAPA 1","lotes": [{"idLoteSap": 872,"codLote": "000000000840037564","valor": 185714.00,"estadoLote": "E","subestadoLote": "NI","manzana": "XY","lote": "24"},{"idLoteSap": 873,"codLote": "000000000840037565","valor": 285714.00,"estadoLote": "E","subestadoLote": "NI","manzana": "Z","lote": "4"}]}]}';
        CEN_LotesFinanciamientoCasosApi  objFinanciamientosLotes = new CEN_LotesFinanciamientoCasosApi();
        objFinanciamientosLotes =   callApiFinanciamientoLotes(numeroDeDocumento, idCaso);
        //Consulta de Proyectos
        List<String> lProyectos =   new List<String>();
        List<String> lProductos =   new List<String>();
        System.debug('objFinanciamientosLotes: '+objFinanciamientosLotes);
        if(objFinanciamientosLotes.financiamientos.size()   >   0){
            for(CEN_LotesFinanciamientoCasosApi.FinanciamientoLote financiamientos    :   objFinanciamientosLotes.financiamientos){
                if(financiamientos.estadoFinanciamiento         ==  'A'){
                    financiamientos.estadoFinanciamientoFormateado    =   'Activo';
                }else if(financiamientos.estadoFinanciamiento   ==  'I'){
                    financiamientos.estadoFinanciamientoFormateado    =   'Inactivo';
                }
                financiamientos.codprocesso     =   financiamientos.processo;
                lProyectos.add(financiamientos.processo);
                for(CEN_LotesFinanciamientoCasosApi.Lote lote   :   financiamientos.lotes){
                    lProductos.add(lote.codLote.replaceFirst('^0+', ''));
                    if(lote.valor!=null){
                        lote.valorFormateado    =   'S/. ' + (lote.valor.format().contains('.')?lote.valor.format():(lote.valor.format()+'.00'));

                    }
                }
            }
            Map<String, String> mapNameCodigoProyecto   =   new Map<String, String>();
            if(lProyectos.size()    >   0){
                mapNameCodigoProyecto                   =   getProyecto(lProyectos);
            }
            if(mapNameCodigoProyecto.size() >   0){
                for(CEN_LotesFinanciamientoCasosApi.FinanciamientoLote financiamientos    :   objFinanciamientosLotes.financiamientos){
                    if(mapNameCodigoProyecto.containsKey(financiamientos.processo)){
                        financiamientos.processo        =   mapNameCodigoProyecto.get(financiamientos.processo); 
                    }
                }
            }else{
                for(CEN_LotesFinanciamientoCasosApi.FinanciamientoLote financiamientos    :   objFinanciamientosLotes.financiamientos){
                    financiamientos.processo    =  financiamientos.urbanizacion; 
                }
            }
            Map<String, List<String>> mapNameCodigoProducto   =   new Map<String, List<String>>();
            if(lProductos.size()    >   0){
                mapNameCodigoProducto           =   getProducto(lProductos);
            }
            if(mapNameCodigoProducto.size() >   0){
                for(CEN_LotesFinanciamientoCasosApi.FinanciamientoLote financiamientos    :   objFinanciamientosLotes.financiamientos){
                    for(CEN_LotesFinanciamientoCasosApi.Lote lote   :   financiamientos.lotes){
                        if(financiamientos.lotesConcatenados    ==  null){
                            financiamientos.lotesConcatenados   =   'Mz.'  +   lote.manzana    +   ' Lt.' +lote.lote;
                        }else{
                            financiamientos.lotesConcatenados   =   financiamientos.lotesConcatenados   +   ' / Mz.'  +   lote.manzana    +   ' Lt.' +   lote.lote;
                        }
                        lote.nombreLote     =   financiamientos.urbanizacion;
                    }
                }
            }
        }
        //Obtener el id del request
        String idLog;
        idLog = Request.getCurrent().getRequestId();
        objFinanciamientosLotes.financiamientos[0].idLog    =   idLog;
        return objFinanciamientosLotes;
    }
    /**
    * @description Obtener mapa de proyectos con código de proyecto y nombre de proyecto
    * @author Richard Villafana - NTT DATA | 08-08-2024 
    * @param lProyectos 
    * @return Map<String, String> 
    **/
    public static Map<String, String> getProyecto(List<String> lProyectos){
        Map<String, String> mapNameCodigoProyecto   =   new Map<String, String>();
        List<Proyecto__c> lProyectosObj             =   new List<Proyecto__c>();
        lProyectosObj                               =   [SELECT Name, CEN_CODIGOSAP__c 
                                                        FROM Proyecto__c
                                                        WHERE CEN_CODIGOSAP__c IN : lProyectos 
                                                        WITH SECURITY_ENFORCED];
        if(lProyectosObj.size()    >   0){
            for(Proyecto__c proyecto    :   lProyectosObj){
                mapNameCodigoProyecto.put(proyecto.CEN_CODIGOSAP__c, proyecto.Name);
            }
        }
        return mapNameCodigoProyecto;
    }

    /**
    * @description Obtener mapa de productos con código de producto y nombre del producto.
    * @author Richard Villafana - NTT DATA | 08-08-2024 
    * @param lProductos 
    * @return Map<String, String> 
    **/
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
    * @description Método que realiza el llamado al servicio de financiamientos y lotes
    * @author Richard Villafana - NTT DATA | 08-08-2024 
    * @param numeroDocumento 
    **/
    public static CEN_LotesFinanciamientoCasosApi callApiFinanciamientoLotes(String numeroDocumento, String idCaso){
        Map<String, String> documentoMap    =   new Map<String, String>();
        String idLog;
        documentoMap.put('documento', numeroDocumento);
        // Convertir el mapa a JSON 
        String jsonRequest  =   JSON.serialize(documentoMap);
        String resp;
        CEN_LotesFinanciamientoCasosApi lotes;
        try {
            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_FinanciamientosLotes');
            callApi.setRequestBody(jsonRequest);
            callApi.setTimeout(120000);
            if(!Test.isRunningTest()){
                resp = (String) callApi.makeCallout().getParsedResponse();
            }else{
                resp = '{"financiamientos":[{"proforma":59530,"version":1,"bukrs":"0019","processo":"19U1.902E","estadoFinanciamiento":"A","urbanizacion":"INDRA ETAPA 1","lotes":[{"idLoteSap":872,"codLote":"000000000840037564","valor":185714.00,"estadoLote":"E","subestadoLote":"NI","manzana":"XY","lote":"24"}]}]}';
            }
            System.debug('resp: '+resp);
            if(resp !=  null){
                lotes   =   CEN_LotesFinanciamientoCasosApi.parse(resp);
            }
            
        } catch (Exception e) {
            System.debug('Error de petición: '+e);
        }
        
        return lotes;
    }
    @AuraEnabled
    @future
    public static void relateCaseLog(String idCaso, String idLog){
        CEN_ServicesLog__c log  =   [SELECT CEN_caseId__c, Id, CEN_RequestId__c
                                    FROM CEN_ServicesLog__c
                                    WHERE CEN_RequestId__c =: idLog];
        if(log!=null){
            try {
                log.CEN_caseId__c   =   idCaso;
                update log;
            } catch (Exception e) {
                System.debug('Error al actualizar log con caso: '+e);
            }
        }
    }
    /**
    * @description Guardar los financiamientos y lotes en el caso.
    * @author Richard Villafana - NTT DATA | 09-10-2024 
    * @param financiamiento 
    * @param lLotes 
    * @param idCaso 
    **/
    @AuraEnabled
    public static void saveFinanciamientoLotes(String financiamiento, String lLotes, String idCaso){
        //Convertir el String de datos a objetos manejables en Apex.
        CEN_LotesFinanciamientoCasosApi.FinanciamientoLote  financiamientoSave  =   new CEN_LotesFinanciamientoCasosApi.FinanciamientoLote();
        List<CEN_LotesFinanciamientoCasosApi.Lote>          lotesSave           =   new List<CEN_LotesFinanciamientoCasosApi.Lote>();
        financiamientoSave      =   (CEN_LotesFinanciamientoCasosApi.FinanciamientoLote) System.JSON.deserialize(financiamiento, CEN_LotesFinanciamientoCasosApi.FinanciamientoLote.class);
        lotesSave               =   (List<CEN_LotesFinanciamientoCasosApi.Lote>) System.JSON.deserialize(lLotes, List<CEN_LotesFinanciamientoCasosApi.Lote>.class);
        //Obtener el Caso
        Case    actualizarCaso  =   [SELECT Id, CaseNumber, CEN_CodFinanciamiento__c, CEN_VersionFinanciamiento__c, CEN_SociedadFinanciamiento__c, 
                                    CEN_ProyectoRelacionado__c, CEN_EstadoFinanciamiento__c, CEN_Etapa__c, CEN_Lotes_asignados__c, CEN_CodigoDeLotes__c
                                    FROM Case
                                    WHERE Id =: idCaso
                                    WITH SECURITY_ENFORCED];
        if(financiamientoSave   !=  null){
            actualizarCaso.CEN_CodFinanciamiento__c         =   String.valueOf(financiamientoSave.proforma);
            actualizarCaso.CEN_VersionFinanciamiento__c     =   String.valueOf(financiamientoSave.version);
            actualizarCaso.CEN_SociedadFinanciamiento__c    =   financiamientoSave.bukrs;
            actualizarCaso.CEN_ProyectoRelacionado__c       =   financiamientoSave.processo;
            actualizarCaso.CEN_EstadoFinanciamiento__c      =   financiamientoSave.estadoFinanciamiento;
            actualizarCaso.CEN_Etapa__c                     =   financiamientoSave.urbanizacion;
            actualizarCaso.CEN_CodProyecto__c               =   financiamientoSave.codprocesso;
        }
        if(lotesSave.size()     >   0){
            List<String> lotes      =   new List<String>();
            List<String> desLotes   =   new List<String>();
            for(CEN_LotesFinanciamientoCasosApi.Lote lote   :   lotesSave){
                lotes.add(lote.codLote.replaceFirst('^0+', ''));  
                desLotes.add(financiamientoSave.urbanizacion + ' Mz.' + lote.manzana + ' Lt.'+lote.lote);
            }
            //actualizarCaso.CEN_Lotes_asignados__c   =   String.join(lotes, ',');
            actualizarCaso.CEN_CodigoDeLotes__c     =   String.join(lotes, ',');
            actualizarCaso.CEN_Lotes_asignados__c   =   String.join(desLotes, '/');
        }else{
            //actualizarCaso.CEN_Lotes_asignados__c   =   '';
            actualizarCaso.CEN_Lotes_asignados__c   =   '';
            actualizarCaso.CEN_CodigoDeLotes__c     =   '';
        }
        try {
            update actualizarCaso;
        } catch (Exception e) {
            System.debug('error: '+e);
        }
    }
    /**
    * @description Obtener los registros de financiamiento y lotes de SAP.
    * @author Richard Villafana - NTT DATA | 09-10-2024 
    * @param idCaso 
    * @return CEN_LotesFinanciamientoCasosApi 
    **/
    @AuraEnabled
    public static CEN_LotesFinanciamientoCasosApi getFinanciamientoLotesInicial(String idCaso){
        Case    casoData    =   [SELECT Id, CaseNumber, CEN_CodFinanciamiento__c, CEN_VersionFinanciamiento__c, CEN_SociedadFinanciamiento__c, 
                                CEN_ProyectoRelacionado__c, toLabel(CEN_EstadoFinanciamiento__c), CEN_Etapa__c, CEN_Lotes_asignados__c, CEN_CodigoDeLotes__c
                                FROM Case
                                WHERE Id =: idCaso
                                WITH SECURITY_ENFORCED];
        CEN_LotesFinanciamientoCasosApi  objFinanciamientosLotes = new CEN_LotesFinanciamientoCasosApi();
        List<CEN_LotesFinanciamientoCasosApi.FinanciamientoLote>    financiamientoDataLista     =   new List<CEN_LotesFinanciamientoCasosApi.FinanciamientoLote>();
        List<CEN_LotesFinanciamientoCasosApi.Lote>                  lotesData                   =   new List<CEN_LotesFinanciamientoCasosApi.Lote>();
        CEN_LotesFinanciamientoCasosApi.FinanciamientoLote          financiamientoData          =   new CEN_LotesFinanciamientoCasosApi.FinanciamientoLote();

        List<String> lProductos     =   new List<String>();
        if(casoData.CEN_CodigoDeLotes__c !=null && casoData.CEN_CodigoDeLotes__c.contains(',')){
            lProductos  =   casoData.CEN_CodigoDeLotes__c.split(',');
        }else{
            lProductos.add(casoData.CEN_CodigoDeLotes__c);
        }
        Map<String, List<String>> mapNameCodigoProducto   =   new Map<String, List<String>>();
        if(lProductos.size()    >   0){
            mapNameCodigoProducto                   =   getProducto(lProductos);
        }
        if(mapNameCodigoProducto.size() >   0){
            for(String codigoLote   :   lProductos){
                if(mapNameCodigoProducto.containsKey(codigoLote)){
                    CEN_LotesFinanciamientoCasosApi.Lote    lote    =   new CEN_LotesFinanciamientoCasosApi.Lote();
                    lote.nombreLote     =   mapNameCodigoProducto.get(codigoLote)[0];
                    lote.idLote         =   '/'+mapNameCodigoProducto.get(codigoLote)[1];
                    lotesData.add(lote);
                }
            }
        }
        financiamientoData.lotes        =   lotesData;
        if(casoData.CEN_CodFinanciamiento__c!=null){
            financiamientoData.proforma             =   Integer.valueOf(casoData.CEN_CodFinanciamiento__c);
            financiamientoData.estadoFinanciamiento =   casoData.CEN_EstadoFinanciamiento__c;
        }else{
            financiamientoData.proforma     =   null;
        }
        financiamientoDataLista.add(financiamientoData);
        objFinanciamientosLotes.financiamientos=financiamientoDataLista;
        return objFinanciamientosLotes;
    }
    /**
    * @description Obtener el tipo de registro del caso.
    * @author Richard Villafana - NTT DATA | 09-10-2024 
    * @param idCaso 
    * @return String 
    **/
    @AuraEnabled
    public static String getTipoDeRegistroDeveloper(String idCaso){
        System.debug('idCaso: '+idCaso);
        String developerName;
        Case    caso    =   [SELECT Id, RecordType.developerName
                            FROM Case
                            WHERE id =: idCaso
                            WITH SECURITY_ENFORCED];
        developerName   =   caso.RecordType.developerName;
        return developerName;
    }
    /**
    * @description Obtener Campos del proyecto en relación al financiamiento.
    * @author Ayleen Salcedo - NTT DATA | 26-12-2026 
    * @param numProforma 
    * @return String 
    **/
    @AuraEnabled
    public static String getCamposProyectoFin(String numProforma, String idCaso){
        System.debug('numProforma: '+numProforma);
        String financiamientoUltimo='00000'+numProforma;
        System.debug(financiamientoUltimo);
        String response;
        Opportunity    oppCampos =   [SELECT CEN_Proyecto__r.CEN_Estado_proyecto__c,
                                CEN_Proyecto__r.CEN_Estado_Servicio_Agua_Alcantarillado__c,
                                CEN_Proyecto__r.CEN_Proveedor_servicio_agua__c,
                                CEN_Proyecto__r.CEN_Estado_Servicio_Energia_Electrica__c,
                                CEN_Proyecto__r.CEN_Proveedor_servicio_energa_electrica__c
                            FROM Opportunity
                            WHERE CEN_Proforma__c =: financiamientoUltimo
                            WITH SECURITY_ENFORCED];
        response   =   oppCampos.CEN_Proyecto__r.CEN_Estado_proyecto__c;

        String estado = oppCampos.CEN_Proyecto__r.CEN_Estado_proyecto__c;
        String estadoServAgua = oppCampos.CEN_Proyecto__r.CEN_Estado_Servicio_Agua_Alcantarillado__c;
        String proveedorServAgua = oppCampos.CEN_Proyecto__r.CEN_Proveedor_servicio_agua__c;
        String estadoServEnergia = oppCampos.CEN_Proyecto__r.CEN_Estado_Servicio_Energia_Electrica__c;
        String proveedorServAEnergia = oppCampos.CEN_Proyecto__r.CEN_Proveedor_servicio_energa_electrica__c;

        // Actualización directa
        update new Case(
            Id = idCaso,
            CEN_Estado_del_proyecto__c = estado,
            CEN_Estado_servicio_agua__c = estadoServAgua,
            CEN_Proveedor_servicio_agua__c = proveedorServAgua,
            CEN_Estado_servicio_energia__c = estadoServEnergia,
            CEN_Proveedor_servicio_energia__c = proveedorServAEnergia
        );
        return response;
    }
}