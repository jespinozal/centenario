@isTest
public class Test_Controller {
    
    public static String respType = '';
    @isTest static void a_CEN_cls_AccountController(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='10100010002', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direcci_n__c='av siempre viva', CEN_Estado__c='Cuenta Potencial', 
                                     RecordTypeId='0124T0000000qqgQAA', CEN_Distrito__c =distrito.Id);
        insert cuenta;
        PageReference pageref = Page.CEN_vf_Account2;        
        pageref.getParameters().put('id',cuenta.Id);
        Test.setCurrentPage(pageref);
        
        ApexPages.StandardController scontr = new ApexPages.StandardController(cuenta);
        CEN_cls_AccountController controller = new CEN_cls_AccountController(scontr);
        List<Account> expected = [SELECT id,Name, CEN_N_mero_de_documento__pc, CEN_Distrito__c, CEN_Tipo_de_documento__pc, PersonEmail,Phone 
                                  FROM Account WHERE Id =:cuenta.Id];        
        List<Account> actual=controller.getAccounts();
        String nextPage = pageref.getUrl();
        System.debug('nextPage: '+nextPage);
        System.assertEquals('/apex/cen_vf_account2?id='+cuenta.Id, nextPage);
        System.assertEquals(expected.size(), actual.size());
        if(expected.size()==actual.size()){
            for(Integer i=0;i<actual.size();i++){
                System.assertEquals(expected[i].Id, actual[i].Id);
            }
        }
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(cuenta);
        CEN_cls_ActAccountAttach account_attach = new CEN_cls_ActAccountAttach(stdCtr);
        account_attach.pr=cuenta;
        account_attach.attach();
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest static void b_CEN_cls_CotizacionController(){
        CEN_cls_VisorLotes.DatosPersonaWrapper objPersona = null;

        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';        
        insert distrito;

        Account cuenta = new Account();
        cuenta.CEN_Numero_de_documento_del__c ='10100010002';
        cuenta.Name='Maximule SAC';
        cuenta.Phone='6543245';
        cuenta.CEN_Direcci_n__c='av siempre viva';
        cuenta.CEN_Estado__c='Cuenta Potencial';
        cuenta.RecordTypeId='0124T0000000qqbQAA';
        cuenta.CEN_Distrito__c =distrito.Id;
        insert cuenta;

        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U1.011E';
        proyecto.CEN_Etapa__c='Etapa 1';
        insert proyecto;

        Opportunity oportunidad=new Opportunity();
        oportunidad.AccountId=cuenta.Id;
        oportunidad.StageName='Operación';
        oportunidad.CEN_Sub_Estado__c='Segura';
        oportunidad.Name='Opo 1';
        oportunidad.CloseDate=Date.today();
        oportunidad.CEN_Proyecto__c = proyecto.Id;
        oportunidad.StageName = 'Cotización';
        insert oportunidad;

        objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);

        Product2 lote = new Product2();
        lote.Name='Lote prueba1';
        lote.CEN_Proyecto__c=proyecto.Id;
        lote.CODLOTE__c='123123123';
        lote.CODCOMPANIA__c='0010';
        lote.CEN_Tiene_Reserva__c='No';
        lote.CODESTADOLOTE__c='L';
        lote.CEN_PRECIOVENTAFUN__c='10000';
        lote.IsActive=true;
        lote.MANZANA__c = 'Mz. A1';
        lote.AREA__c = '100';
        lote.CEN_TIPOLOGIA__c= 'ESQUINA';
        insert lote;

        PricebookEntry precio2= new PricebookEntry();
        precio2.UseStandardPrice=false;
        precio2.IsActive=true;
        precio2.Pricebook2Id=Test.getStandardPricebookId();
        precio2.Product2Id=lote.Id;
        precio2.UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        insert precio2;
        
        Proyecto__c proyecto2 = CEN_cls_VisorLote_2.buscarProyectobyId(proyecto.Id);
        System.assertEquals(proyecto.id, proyecto2.Id);
        Id[]searchResultsIds=new Id[]{proyecto.Id};
        Test.setFixedSearchResults(searchResultsIds);
        Test.startTest();
        Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);

        List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);
        
        
        System.assertEquals(1, proyectos_encontrados.size());
        System.assertEquals(proyecto.id, proyectos_encontrados[0].Id);
        System.assertNotEquals(null, objPersona);
        
        CEN_cls_VisorLote_2.ListWrapper wraper = CEN_cls_VisorLote_2.fetchAccountWrapper(proyecto.CEN_CODIGOSAP__c);
        //System.assertEquals('ok', wraper.estado);
        // System.assertEquals(1, wraper.getlotes.size());
        // System.assertEquals('todo ok', wraper.mensaje);
        // System.assertEquals(108440.0, wraper.precioMax);
        // System.assertEquals(108430.0, wraper.precioMin);
        // System.assertEquals(150.0, wraper.tamanioMax);
        // System.assertEquals(140.0, wraper.tamanioMin);
        
        Quote cotizacion = new Quote();
        cotizacion.Name='Coti';
        cotizacion.OpportunityId=oportunidad.Id;
        cotizacion.Pricebook2Id = Test.getStandardPricebookId();        
        insert cotizacion;
                    
        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.Product2Id = lote.Id;
        objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
        objQuoteLineItem.PricebookEntryId = precio2.Id;
        objQuoteLineItem.Quantity = 1;
        objQuoteLineItem.UnitPrice = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.QuoteId = cotizacion.Id;
        objQuoteLineItem.CEN_area_del_lote__c = Double.valueOf(lote.AREA__c);
        objQuoteLineItem.CEN_lote__c = lote.DESCRIPCIONCORTA__c;
        objQuoteLineItem.CEN_manzana_del_lote__c = lote.MANZANA__c.capitalize();
        objQuoteLineItem.CEN_precio_m2_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c)/objQuoteLineItem.CEN_area_del_lote__c;
        objQuoteLineItem.CEN_precio_venta_cotizado_lote__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.CEN_fld_precioVentaDscto__c = Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        objQuoteLineItem.CEN_tipologia_del_lote__c = lote.CEN_TIPOLOGIA__c;        
        objQuoteLineItem.CEN_urbanizacion_proyecto__c = proyecto.Name;
        objQuoteLineItem.CEN_etapa__c = proyecto.CEN_Etapa__c;
        insert objQuoteLineItem;

        PageReference pageref = Page.CEN_vf_pdfPlantillaCotizador;
        pageref.getParameters().put('id',cotizacion.Id);

        Test.setCurrentPage(pageref);
        
        ApexPages.StandardController scontr = new ApexPages.StandardController(cotizacion);
        //  Controlador de visualforce
        CEN_cls_pdfPlantillaCotizador_ccvf controller = new CEN_cls_pdfPlantillaCotizador_ccvf(scontr);
        Attachment objAttachment = controller.getLogoProyecto();
        Proyecto__c objProyecto = controller.getProyecto();
        Quote objQuote = controller.getCotizacion();
        List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> listAnotaciones = controller.getAnotaciones();
        List<QuoteLineItem> listProductosPedido = controller.getLotesCotizados();
        List<CEN_cmt_precisionesYObeneficios__mdt> listCEN_cmt_precisionesYObeneficios = controller.getPrecisionesYObeneficios();
        List<CEN_cmt_terminosYcondiciones__mdt> listCEN_cmt_terminosYcondiciones = controller.getTerminosYcondiciones();
        List<CEN_cls_pdfPlantillaCotizador_ccvf.FormaPago> listFormaPago = controller.getFormasDePagoMasDetalles();
        Quote expected = [SELECT Id FROM Quote WHERE OpportunityId =:oportunidad.Id order by CreatedDate desc limit 1];                
        String urlPageVF = pageref.getUrl();

        CEN_cls_VisorLotes.generarPDF(cotizacion.Id, oportunidad.Id);
        Test.stopTest();
        System.assertEquals('/apex/cen_vf_pdfplantillacotizador?id='+cotizacion.Id, urlPageVF);
        System.assertEquals(expected.Id, objQuote.Id);
    }
    @isTest static void c_CEN_cls_LeadController(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Lead prospecto = new Lead(CEN_Tipo_de_documento__c='DNI', LastName='Maximule', CEN_N_mero_de_documento__c='100010010', Phone='8787877',
                                  Email='a@test.test', FirstName='max', CEN_Direcci_n_Prospecto__c='av. siempre viva',CEN_Distrito__c=distrito.Id,
                                  LeadSource = 'Presencial',CEN_Medio__c='0110',MobilePhone='+51985810707');
        insert prospecto;
        PageReference pageref = Page.CEN_vf_Lead2;
        pageref.getParameters().put('id',prospecto.Id);
        
        Test.setCurrentPage(pageref);
        ApexPages.StandardController scontr = new ApexPages.StandardController(prospecto);
        CEN_cls_LeadController controller = new CEN_cls_LeadController(scontr);
        List<Lead> actual=controller.getLeads();
        List<Lead> expected = [SELECT id,Name,CEN_N_mero_de_documento__c,Phone,Email,CEN_Direcci_n_Prospecto__c, CEN_Tipo_de_documento__c 
                               FROM Lead WHERE Id =:prospecto.Id];
        String nextPage = pageref.getUrl();
        System.debug('nextPage: '+nextPage);
        System.assertEquals('/apex/cen_vf_lead2?id='+prospecto.Id, nextPage);
        System.assertEquals(expected, actual);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest static void d_CEN_Lote_desde_Visor(){
        Test.startTest();
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='10100010002', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Potencial', 
                                     RecordTypeId='0124T0000000qqgQAA', CEN_Distrito__pc =distrito.Id);
        insert cuenta;
        try{
            Contact contacto = new Contact(LastName=cuenta.LastName, FirstName=cuenta.FirstName, AccountId=cuenta.Id, CEN_Tipo_de_documento__c=cuenta.CEN_Tipo_de_documento__pc);
        	insert contacto;
        }catch(Exception ex){
            System.debug('ex: '+ ex);
        }

        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, StageName='Cotización', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today(), CEN_Proyecto__c= proyecto.Id);
        insert oportunidad;
        
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='840001257', CODCOMPANIA__c='0010', 
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(), 
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        List<CEN_Lote_desde_Visor.Requests> request = new List<CEN_Lote_desde_Visor.Requests>();
        CEN_Lote_desde_Visor.Requests req = new CEN_Lote_desde_Visor.Requests();
        req.recorIdrequest = oportunidad.Id;
        request.add(req);
        List<CEN_Lote_desde_Visor.Result> result = CEN_Lote_desde_Visor.ObtenerIdLoteOportunidad(request);
        // CEN_Lote_desde_Visor.Result actual = result[0];
        CEN_Lote_desde_Visor.Result expected = new CEN_Lote_desde_Visor.Result();
        CEN_ResponseContentVisorLotes response = new CEN_ResponseContentVisorLotes();
        response.Codlote='840001257';
        response.Idproyecto='10U1.011E';
        response.Descripcionlote='LA PLANICIE ETAPA 2 Mz.A1 Lt.1';
        response.Manzana='A1';
        response.Codestadolote='E';
        response.Area=142.42;
        response.Precioventafun = 108438.59;
        response.FillerStr02='ESQUINA CALLE';
        response.Numeroletra='1';
        response.Proforma='00123';
        expected.loteContentResponse = new List<CEN_ResponseContentVisorLotes>();
        expected.loteContentResponse.add(response);
        Test.stopTest();
        // System.assertEquals(expected.loteContentResponse[0].Codlote, actual.loteContentResponse[0].Codlote);
        // System.assertEquals(expected.loteContentResponse[0].Idproyecto, actual.loteContentResponse[0].Idproyecto);
        // System.assertEquals(expected.loteContentResponse[0].Descripcionlote, actual.loteContentResponse[0].Descripcionlote);
        // System.assertEquals(expected.loteContentResponse[0].Manzana, actual.loteContentResponse[0].Manzana);
        // System.assertEquals(expected.loteContentResponse[0].Codestadolote, actual.loteContentResponse[0].Codestadolote);
        // System.assertEquals(expected.loteContentResponse[0].Area, actual.loteContentResponse[0].Area);
        // System.assertEquals(expected.loteContentResponse[0].Precioventafun, actual.loteContentResponse[0].Precioventafun);
        // System.assertEquals(expected.loteContentResponse[0].FillerStr02, actual.loteContentResponse[0].FillerStr02);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    
    @isTest static void e_CEN_cls_Activar_Cotizador(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='01020305', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Potencial', 
                                     RecordTypeId='0124T0000000qqgQAA', CEN_Distrito__pc =distrito.Id);
        insert cuenta;
        
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U1.219E');
        insert proyecto;
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='840001257', CODCOMPANIA__c='0010', 
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(), 
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        
        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, StageName='Cotización', Name='Opo 1', CloseDate=Date.today(),CEN_Proyecto__c=proyecto.Id);
        insert oportunidad;
        
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        CEN_Visor_Centenario.Response data = CEN_Visor_Centenario.getData(oportunidad.Id);
        System.assertEquals(oportunidad.Id, data.oportunidad.Id);
        System.assertEquals(proyecto.Id, data.proyecto.Id);
        //System.assertEquals(label.CEN_api_visor_lotes+'/salesforce?token=3e98fb17-70a2-4e56-8cd8-3e2a439f0d1c&'+'OpportunityId='+oportunidad.Id+'&IdProyecto='+proyecto.CEN_CODIGOSAP__c, data.endpoint);
        System.assertEquals('OK', data.status);
        System.assertEquals('Se conectó al visor. Asegurese de no tener las pestañas emergentes bloqueados en su navegador.', data.mensaje);
        // 1r error
        RestRequest request = new RestRequest();       
        request.requestUri =
            'https://centenario--qa01.my.salesforce.com/services/apexrest/OpportunityLineItem/';
        request.httpMethod = 'POST';
        request.headers.put('Content-Type','application/json;charset=UTF-8');
        request.requestBody = Blob.valueOf('{"OpportunityId":"","CodLote":""}');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        CEN_API_VisorCentenario.createOpportunityLineItem();
        RestResponse respuesta = RestContext.response;
        
        RestResponse res = new RestResponse();
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"id":"","mensaje":"OpportunityId y CodLote son obligatorios."}');
        
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        System.assertEquals(res.responseBody, respuesta.responseBody);
         
        // 2 error
        request.requestBody = Blob.valueOf('{"OpportunityId":"'+oportunidad.Id+'","CodLote":""}');
        CEN_API_VisorCentenario.createOpportunityLineItem();
        respuesta = RestContext.response;
        
        res = new RestResponse();
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"id":"","mensaje":"CodLote es obligatorio."}');
        
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        System.assertEquals(res.responseBody, respuesta.responseBody);
        
        // 3 error
        request.requestBody = Blob.valueOf('{"OpportunityId":"","CodLote":"'+lote.CODLOTE__c+'"}');
        CEN_API_VisorCentenario.createOpportunityLineItem();
        respuesta = RestContext.response;
        
        res = new RestResponse();
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"id":"","mensaje":"OpportunityId es obligatorio."}');
        
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        System.assertEquals(res.responseBody, respuesta.responseBody);
        
        // 4 error
        request.requestBody = Blob.valueOf('{"OpportunityId":"'+oportunidad.Id+'","CodLote":"00000000840001258"}');
        CEN_API_VisorCentenario.createOpportunityLineItem();
        respuesta = RestContext.response;
        
        res = new RestResponse();
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se encontró un Lote con el CodLote 00000000840001258.');
        
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        String texto =respuesta.responseBody.toString();
        System.assert(texto.contains(res.responseBody.toString()));
        
        // 1 sucess
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        res.statusCode = 201;
        res.responseBody = Blob.valueOf('{"id":"'+item.Id+'","mensaje":"El Lote '+lote.CODLOTE__c+
                                        ' fue relacionado con la Oportunidad '+oportunidad.Id+
                                        ' exitosamente. Creando el Lote de Oportunidad '+item.Id+'."}');
        request.requestBody = Blob.valueOf('{"OpportunityId":"'+oportunidad.Id+'","CodLote":"'+lote.CODLOTE__c+'"}');
        CEN_API_VisorCentenario.createOpportunityLineItem();
        respuesta = RestContext.response;
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        System.assertEquals(res.responseBody, respuesta.responseBody);        
        
        // 2 success
        delete item;
        delete precio2;        
        CEN_API_VisorCentenario.createOpportunityLineItem();
        respuesta = RestContext.response;
        item = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:oportunidad.Id LIMIT 1];
        res.responseBody = Blob.valueOf('{"id":"'+item.Id+'","mensaje":"El Lote '+lote.CODLOTE__c+
                                        ' fue relacionado con la Oportunidad '+oportunidad.Id+
                                        ' exitosamente. Creando el Lote de Oportunidad '+item.Id+'."}');
        System.assertEquals(res.headers, respuesta.headers);
        System.assertEquals(res.statusCode, respuesta.statusCode);
        System.assertEquals(res.responseBody, respuesta.responseBody);
        
        CEN_cls_Activar_Cotizador.Response objResponse = CEN_cls_Activar_Cotizador.validarOportunidad(oportunidad.Id);
        System.assert(objResponse.ok);
        System.assert(!objResponse.lotes.isEmpty());
        System.assertEquals(objResponse.lotes[0].Codlote, lote.CODLOTE__c);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest static void f_CEN_Interacciones_PostVenta(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Tabla_maestra__c distrito2 = new Tabla_maestra__c(Name='Comas', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150106');
        insert distrito2;
        String RecTypeIdCN= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='01020305', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Centenario', 
                                     RecordTypeId=RecTypeIdCN, CEN_Distrito__pc =distrito.Id);
        insert cuenta;
        
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Anfitriona'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             //Caseta_de_Venta__c = 'Sala San Andres',
             LocaleSidKey = 'en_US'
            
        );
        insert u;
        Boolean debeUsarOAC = false;
        List<CEN_busquedaDNI.PickListWrapper> listaSeleccionOAC = new List<CEN_busquedaDNI.PickListWrapper>();
        String oacElegido = null; 
        System.runAs(u){
            debeUsarOAC = CEN_busquedaDNI.getObligacionElegirOAC();
            listaSeleccionOAC = CEN_busquedaDNI.getOACs();
            if(!listaSeleccionOAC.isEmpty()){
                oacElegido = listaSeleccionOAC[0].value;
            }
            CEN_busquedaDNI.getselectEve(cuenta.id,'Cuenta','Postventa',cuenta.CEN_N_mero_de_documento__pc,'Min','Minimus','min.minimus@cliente.com','972715766','calle test',distrito2.Id,'Común',null, oacElegido, '0118');
        }
        
        Case caso = new Case();
        caso.Subject = 'Interacción - Entrega de documentos - Cláusula de prepago';
        caso.Description = 'El cliente quiere la entrega de sus documentos por correo.';
        caso.Status = 'En proceso';
        //caso.ContactId = cuentas[2].PersonContactId;
        caso.CEN_Actualizar_Datos__c = true;
        caso.Reason = 'Entrega de documentos';
        caso.CEN_Sub_Categoria__c ='Cláusula de prepago';
        caso.Origin ='Presencial';
        caso.Type ='Solicitud';
        caso.CEN_Area_Responsable__c = 'Post venta';
      	caso.CEN_Tipifica_Solucion__c = 'Procedente';
        caso.AccountId = cuenta.Id;
        caso.ParentId = null;
    	insert caso;
        
        Case caso1 = [SELECT Id, AccountId, ContactId,Priority,Status,Origin,Reason, Subject, CEN_Sub_Categoria__c,ParentId FROM Case WHERE AccountId=:cuenta.Id LIMIT 1];
                        
        Case caso2 = new Case(AccountId=caso1.AccountId, ContactId=caso1.ContactId, Priority=caso1.Priority,
                             Status='Pendiente',Origin=caso1.Origin,Reason=caso1.Reason,Subject=caso1.Subject,
                             CEN_Sub_Categoria__c=caso1.CEN_Sub_Categoria__c, ParentId=caso1.Id);
        insert caso2;
        
       
        Test.startTest();
        caso1.Status='Cerrado';
        Database.SaveResult result = Database.update(caso1, false); 
        Test.stopTest();
        System.debug(result);
        System.assert(!result.isSuccess()); 
        // Interacciones para App y Case Comment
        Case caso3 = new Case(AccountId=caso1.AccountId, ContactId=caso1.ContactId, Priority=caso1.Priority,
                             Status='Pendiente',Origin='App',Reason=caso1.Reason,Subject=caso1.Subject,
                             CEN_Sub_Categoria__c=caso1.CEN_Sub_Categoria__c, CEN_Tipo_de_Contacto__c='Reactivo',
                             Description='Quiero que revisen el agua en el terreno.');
        insert caso3;
        Case caso4 = new Case(AccountId=caso1.AccountId, ContactId=caso1.ContactId, Priority=caso1.Priority,
                             Status='Pendiente',Origin='App',Reason=caso1.Reason,Subject=caso1.Subject,
                             CEN_Sub_Categoria__c=caso1.CEN_Sub_Categoria__c, ParentId=caso3.Id,CEN_Tipo_de_Contacto__c='Reactivo',
                             Description='Revisión de agua');
        insert caso4;
        
        CaseComment coment= new CaseComment(ParentId=caso4.Id, CommentBody='Prueba 1');
        insert coment;
        
        List<CaseComment> coment2 = [SELECT Id, ParentId, CommentBody FROM CaseComment WHERE ParentId=:caso3.Id];
        System.assertEquals('Prueba 1',coment2[0].CommentBody);
        
        // Atender Interacciones postventa
        
        caso1.Status='Pendiente';
        caso1.Reason='Información';
        update caso1;
        
        Tabla_maestra__c distrito2_rec = CEN_cls_Interacciones.buscarDistritobyId(distrito2.Id);
        List<Tabla_maestra__c> distritos = CEN_cls_Interacciones.buscarDistrito('Comas');
        Case caso5 = CEN_cls_Interacciones.getCaseById(caso1.Id);
        String str = CEN_cls_Interacciones.postergarCase(caso5.Id,true);
        System.assertEquals('ok', str);
        //	NO Gestionar caso
        String texto_r1 = CEN_cls_Interacciones.noGestionar(caso1.Id,'no está permitido cambios');
        System.assertEquals('OK', texto_r1);
        
        delete caso2;
        delete caso5;
        String nuevo_nombre='Min2';
        String nuevo_apellido='Minimus';
        String nuevo_correo='min.minimus@cliente.com';
        String nuevo_celular='972457566';
        String nuevo_direccion='972457566';
        System.runAs(u){
            CEN_busquedaDNI.getselectEve(cuenta.id,'Cuenta','Postventa',cuenta.CEN_N_mero_de_documento__pc,
                                        nuevo_nombre,nuevo_apellido,nuevo_correo,nuevo_celular,nuevo_direccion,distrito2.Id,'Común', null, oacElegido,'0118');            
        }
        
        Case caso777 = new Case();
        caso777.Subject = 'Interacción - Entrega de documentos - Cláusula de prepago';
        caso777.Description = 'El cliente quiere la entrega de sus documentos por correo.';
        caso777.Status = 'En proceso';
        //caso777.ContactId = cuentas[2].PersonContactId;
        caso777.CEN_Actualizar_Datos__c = true;
        caso777.Reason = 'Entrega de documentos';
        caso777.CEN_Sub_Categoria__c ='Cláusula de prepago';
        caso777.Origin ='Presencial';
        caso777.Type ='Solicitud';
        caso777.CEN_Area_Responsable__c = 'Post venta';
      	caso777.CEN_Tipifica_Solucion__c = 'Procedente';
        caso777.AccountId = cuenta.Id;
        caso777.ParentId = null;
    	insert caso777;
        
        Case caso6 = [SELECT Id, CEN_nombre_actualizado__c, CEN_distrito_actualizado__c, CEN_direccion_actualizado__c, 
                      correo_actualizado__c, CEN_celular_actualizado__c, CEN_apellido_actualizado__c
                      FROM Case WHERE AccountId=:cuenta.Id AND ParentId=null AND Origin!='App' LIMIT 1];
        //System.assertEquals(nuevo_nombre, caso6.CEN_nombre_actualizado__c);
        //System.assertEquals(nuevo_apellido, caso6.CEN_apellido_actualizado__c);
        //System.assertEquals(nuevo_correo, caso6.correo_actualizado__c );
        //System.assertEquals(nuevo_celular, caso6.CEN_celular_actualizado__c);
        //System.assertEquals(nuevo_direccion, caso6.CEN_direccion_actualizado__c);
        
        CEN_cls_Interacciones.Response res_int = CEN_cls_Interacciones.actualizarDatosCliente(caso6.Id, distrito2.Id, nuevo_nombre, nuevo_apellido, nuevo_correo, nuevo_celular, nuevo_direccion);
        //Case caso7 = [SELECT Id FROM Case WHERE ParentId=:caso6.Id LIMIT 1];
        //System.assertEquals('OK', res_int.estado);
        //System.assertEquals('Se actualizó los datos de la Interacción.', res_int.mensaje);
        //System.assertEquals(caso7.Id, res_int.newcase.Id);
        
            
        String RecTypeIdCJ= [select Id from RecordType where (Name='Cuenta Jurídica') and (SobjectType='Account')].Id;
        Account cuentaj = new Account(CEN_Tipo_de_documento__c='RUC', CEN_Numero_de_documento_del__c='10202020207', Name='EMPRESA SAC',RecordTypeId=RecTypeIdCJ);
        insert cuentaj;
        Contact repre = new Contact(AccountId=cuentaj.Id, FirstName='Repre', LastName='Name repre');
        insert repre;
        System.runAs(u){
            CEN_busquedaDNI.getselectDoc(cuentaj.CEN_Tipo_de_documento__c, cuentaj.CEN_Numero_de_documento_del__c);
            CEN_busquedaDNI.registrarVisitaDeTercero('DNI', '70707070', 'Armando', 'Armandez', 'Direccion', distrito2.Id, 'corre@u.tes', '987684624', 'Preferencial', oacElegido);
            CEN_busquedaDNI.getselectEve(cuentaj.id,'Cuenta','Postventa',cuenta.CEN_N_mero_de_documento__pc,'Min','Minimus','min.minimus@cliente.com','972715766','calle test',distrito2.Id,'Común',repre.Id, oacElegido, '0118');
        }
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        
        Product2  prod2= new Product2 ();
        prod2.name='prueba';
        prod2.CODLOTE__c='840001258';
        prod2.IsActive =true;
        prod2.DESCRIPCIONLOTE__c='Las Palmeras Etapa 4 Mz.O Lt.11';
        prod2.CODCOMPANIA__c='0010';
        prod2.CEN_Tiene_Reserva__c='No';
        prod2.CODESTADOLOTE__c='L';
        prod2.CEN_PRECIOVENTAFUN__c='10000';
        prod2.CEN_Proyecto__c=proyecto.Id;
        insert prod2; 
        //h_agregar_lotes_Case(caso7.Id, prod2.Id);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest static void h_CEN_Interacciones_CallCenter(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Tabla_maestra__c distrito2 = new Tabla_maestra__c(Name='Comas', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150106');
        insert distrito2;
        String RecTypeIdCN= [select Id from RecordType where (Name='Cuenta Natural') and (SobjectType='Account')].Id;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='01020305', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Centenario', 
                                     RecordTypeId=RecTypeIdCN, CEN_Distrito__pc =distrito.Id);
        insert cuenta;        
        User u1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_Postventa'].Id,
             LastName = 'spvuser',
             Email = 'spvuser000@amamama.com',
             Username = 'spvuser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'spvtitle',
             Alias = 'spv',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
            //Caseta_de_Venta__c = 'Sala San Andres',
             LocaleSidKey = 'en_US'
            
        );
        User u2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Callcenter'].Id,
             LastName = 'lcast',
             Email = 'cuser000@amamama.com',
             Username = 'cuser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'tcitle',
             Alias = 'aclias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
            //Caseta_de_Venta__c = 'Sala San Andres',
             LocaleSidKey = 'en_US'
            
        );
        insert u1;
        insert u2;
        String nuevo_nombre='Min2';
        String nuevo_apellido='Minimus';
        String nuevo_correo='min.minimus@cliente.com';
        String nuevo_celular='972457566';
        String nuevo_direccion='Av tester sf';
       
        Case caso = null;
        
        Boolean debeUsarOAC = false;
        List<CEN_busquedaDNI.PickListWrapper> listaSeleccionOAC = new List<CEN_busquedaDNI.PickListWrapper>();
        String oacElegido = null; 
        System.runAs(u2){
            debeUsarOAC = CEN_busquedaDNI.getObligacionElegirOAC();
            listaSeleccionOAC = CEN_busquedaDNI.getOACs();
            if(!listaSeleccionOAC.isEmpty()){
                oacElegido = listaSeleccionOAC[0].value;
            }
            CEN_busquedaDNI.registrarVisitaDeTercero('DNI', '70707070', 'Armando', 'Armandez', 'Direccion', distrito2.Id, 'corre@u.tes', '987684624', 'Común', 'ZV022');
            CEN_busquedaDNI.getselectEve(cuenta.id,'Cuenta','Postventa',cuenta.CEN_N_mero_de_documento__pc,'Min','Minimus','min.minimus@cliente.com','972715766','calle test',distrito2.Id,'Común',null, oacElegido, '0118');
            Tabla_maestra__c dt = CEN_busquedaDNI.buscarDistritobyId(distrito2.Id);
            caso = [SELECT Id, OwnerId, Status FROM Case ORDER BY CreatedDate DESC LIMIT 1];
            caso.OwnerId = u1.Id;
            List<Case> subcasos = new List<Case>();
            subcasos.add(caso.clone(false, false, false, false));            
            subcasos.add(caso.clone(false, false, false, false));
            subcasos[0].ParentId=caso.Id;
            subcasos[1].ParentId=caso.Id;
            insert subcasos;
            upsert caso;
        }
        System.runAs(u1){
            CEN_cls_Interacciones.Response res_int = CEN_cls_Interacciones.actualizarDatosCliente(caso.Id, distrito2.Id, nuevo_nombre, nuevo_apellido, nuevo_correo, nuevo_celular, nuevo_direccion);
            caso.Status = 'Atendido';
            caso.Reason = 'Terreno';
            caso.CEN_Actualizar_Datos__c = false;
            caso.CEN_Sub_Categoria__c = 'Entrega de terreno';
            update caso;            
            caso.Status = 'En proceso';
            update caso;
        }
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @isTest static void g_CEN_Financiamientos(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='01020305', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Centenario', 
                                     RecordTypeId='0124T0000000qqgQAA', CEN_Distrito__pc =distrito.Id,
                                     Comentario__c='Sociedad: INVERSIONES CENTENARIO S.A.A|Proyecto: SANTA MARIA ETAPA 1 Mz.F14 Lt.13|Financiamiento: 4553|Tipo Financiamiento: Crédito Directo|Minuta: SMF1413-14|Tipo Cliente: Propietario|Venta: 04/07/2006|||Sociedad: INVERSIONES CENTENARIO S.A.A|Proyecto: SANTA MARIA ETAPA 1 Mz.F14 Lt.14|Financiamiento: 4553|Tipo Financiamiento: Crédito Directo|Minuta: SMF1413-14|Tipo Cliente: Propietario|Venta: 04/07/2006');
        insert cuenta;
        Product2 lote = new Product2(Name='Lote test', DESCRIPCIONLOTE__c='La Planicie Etapa 2 Mz.A1 Lt.2', CODLOTE__c='111111');
        insert lote;
        g_ejecutar_Financimientos(cuenta.Id);
        g_get_lotes(cuenta.Id);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
     }
    
    @isTest static void g_update_Financing_Success(){
        
        Test.startTest();
        Test_Controller.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        Map<String,String> response = CEN_cls_Financiamiento.setUpdateFinancing('00123', 'Notaria X', 'Local X', '001', '9901','', 'X', 'X', 'X', 'X', '');    
        Test.stopTest();
    }

    @isTest static void g_update_Financing_TryCatch_updateFinancing(){
        Test.startTest();
        Test_Controller.respType = 'error';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        try {
            Map<String,String> response = CEN_cls_Financiamiento.setUpdateFinancing('00123', 'Notaria X', 'Local X', '001', '9901','', 'Z', 'X', 'X', 'X', '');    
        } catch (Exception e) {
            System.debug('error');
            //System.debug(response);
        }
        
        Test.stopTest();
    }

    @future(callout=true)
    public static void g_ejecutar_Financimientos(String cuentaId){
        
        Test.setMock(WebServiceMock.class, new WSCalloutMock());
        CEN_cls_Financiamiento.Financiamiento finan= CEN_cls_Financiamiento.getFinanciamiento(cuentaId);
        List<CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K> proformas = new List<CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K>();
            CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K proforma = new CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K();
            proforma.PROFORMA='000123';
            proforma.VERSION='01';
            proforma.PROFORMA_ANT='';
            proforma.PROCESSO='';
            proforma.COD_PROPIEDAD='';
            proforma.PROPIEDADES='';
            proforma.COD_MINUTA='';
            proforma.FECHA_FINANCIAMIENTO='';
            proforma.BUKRS='';
            proforma.WAERS='';
            proforma.PRECIO='';
            proforma.TIPO_CAMBIO='';
            proforma.DIAS_PAGO='';
            proforma.IMPORTE_RESERVA='';
            proforma.CUOTA_INIC_IMP_R='';
            proforma.IMPORTE_SALDO_PRECIO='';
            proforma.TASA_ANUAL_INTERES_FINAN='';
            proforma.TASA_ANUAL_GASTOS_ADMIN='';
            proforma.TASA_MENSUAL_INTERES_FINAN='';
            proforma.TASA_MENSUAL_GASTOS_ADMIN='';
            proforma.COSTO_TOTAL_MENSUAL='';
            proforma.COSTO_TOTAL_ANUAL='';
            proforma.IMPORTE_CUOTA='';
            proforma.AMORTIZADO='';
            proforma.KUNNR='';
            proforma.TIP_CLI_CONT='';
            proforma.ERSDA='';
            proforma.AEDAT='';
            proforma.AENAM='';
            proforma.CASH_BLDAT='';
            proforma.CASH='';
            proforma.BFH='';
            proforma.CUOTA_INIC_IMP='';
            proforma.CUOTA_INIC_POR='';
            proforma.CUOTA_INIC_NO_CUOTAS=1;
            proforma.CUOTA_INIC_INTERES='';
            proforma.CUOTA_INIC_INTGAS='';
            proforma.SALDO_NO_CUOTAS=12;
            proforma.PERIODO_DIAS=12;
            proforma.SALDO_INTERESES='';
            proforma.SALDO_INTGAS='';
            proforma.MANTENER_CUOTA='';
            proforma.DISMINUIR_CUOTA='';
            proforma.PROMOTOR='';
            proforma.FECHA_INICIO='';
            proforma.VIA_FINANCIAMIENTO='';
            proforma.REP_LEG1='';
            proforma.REP_LEG2='';
            proforma.AREA_VENDIBLE='';
            proforma.SUP_CONSTRUIDA='';
            proforma.AREA_LIBRE='';
            proforma.BLOQUE_PORTAL='';
            proforma.NUMEROLETRA='';
            proforma.CANTIDAD_LOTES='';
            proforma.TELEMARKETING='';
            proforma.FIRMA_MECANIZ='';
            proforma.TIPO_CONTRATO='';
            proforma.PERIMETRO_FRENTE='';
            proforma.PERIMETRO_FONDO='';
            proforma.PERIMETRO_IZQUI='';
            proforma.PERIMETRO_DEREC='';
            proforma.PERFIL_COBRAN='';
            proforma.ESTADO='';
            proforma.MOTIVO='';
            proforma.VBELN='';
            proforma.TIPO_PROFORMA='';
            proforma.FECHA_CVENTAS='';
            proforma.COD_MOTGRUP='';
            proforma.COD_MOTDET='';
            proforma.FECHA_INACTIVO='';
            proforma.TIPO_PREPAGO='';
            proforma.FECHA_PREPAGO='';
            proforma.FECHA_REVERSION_PREPAGO='';
            proforma.FECHA_CIERRE2='';
            proforma.FECHA_TC_ENTREGA='';
            proforma.FECHA_ENTREGA_TC='';
            proforma.FECHA_ENTREGA_NIFF='';
            proforma.FECHA_ENTREGA_FIS='';
            proforma.TIPO_ENTREGA='';
            proforma.FECHA_CAMB_CONT='';
            proforma.FECHA_DESEMBOLSO='';
            proforma.BANCO='';
            proforma.FECHA_ENT_PROY='';
            proforma.CUOTA_INICIAL_FINANCIA='';
            proforma.APODERADO_CENTENARIO1='';
            proforma.APODERADO_CENTENARIO2='';
            proforma.INTERLOCUTOR1='';
            proforma.INTERLOCUTOR2='';
            proforma.INTERLOCUTOR3='';
            proforma.INTERLOCUTOR4='';
            proforma.INTERLOCUTOR5='';
            proforma.INTERLOCUTOR6='';
            proforma.INTERLOCUTOR7='';
            proforma.INTERLOCUTOR8='';
            proforma.INTERLOCUTOR9='';
            proforma.INTERLOCUTOR10='';
            proforma.APODERADO1='';
            proforma.APODERADO2='';
            proforma.ZZZONAVENTA='';
            proforma.MEDIO='';
            proforma.IND_FINAN_CI='';
            proforma.INTERESES_CI='';
            proforma.FECHA_CARTA_NOTARIAL='';
            proforma.RESOLUCION='';
            proforma.PENDIENTE_RESOLVER='';
            proforma.RESOL_PEND_APRO='';
            proforma.FECHA_RESOLVER='';
            proforma.PORCEN_RESOL_PUNTUAL='';
            proforma.PORCEN_RESOL_CENTENARIO='';
            proforma.PORCEN_RESOL_MOROSO='';
            proforma.OPCION_SOL_COMPRADOR='';
            proforma.OPCION_SOL_VENDEDOR='';
            proforma.OPCION_CAPITAL='';
            proforma.OPCION_CAPITAL_INTERES_GASTOS='';
            proforma.PORCEN_RESOL_PUNTUAL_FINAL='';
            proforma.PORCEN_RESOL_CENTENARIO_FINAL='';
            proforma.PORCEN_COMISION_VENTAS='';
            proforma.OTROS_GASTOS='';
            proforma.OTROS_GASTOS_CLIENTE='';
            proforma.CARGOS_POR_CTA_CLIENTE='';
            proforma.TOTAL_DESCONTAR_PENALIDAD='';
            proforma.MONTO_NC_CAPITAL_PAGADO='';
            proforma.MONTO_NC_CAPITAL_NO_PAGADO='';
            proforma.MONTO_NC_INTERESES_PAGADO='';
            proforma.MONTO_NC_INTERESES_NO_PAGADO='';
            proforma.MONTO_NC_PENALIDAD='';
            proforma.SITUACION_FINANCIAMIENTO='';
            proforma.CREADO_POR='';
            proforma.FLAG_VARIACION_AREA='';
            proforma.METROS_VARIACION_AREA='';
            proforma.MONTO_VARIACION_AREA='';
            proforma.ZAC_DOC_SUNAT='';
            proforma.NCUOTAS_SALDO_ORIGINAL=123;
            proforma.MOTIVO_COMPRA='';
            proforma.ASIENTOAP1='';
            proforma.ASIENTOAP2='';
            proforma.USRCOMPPAGO='';
            proforma.ESIGN_ESTADO='';
            proforma.ESIGN_FECHA='';
            proforma.COMPROB_ORACLE='';
        proformas.add(proforma);
        System.assertEquals(cuentaId, finan.cuenta.Id);
        System.assertEquals('OK', finan.mensaje);
        System.assertEquals(proformas.size(), finan.cabeceras.size());
        if(proformas.size()==finan.cabeceras.size()){
            for(Integer i=0; i<finan.cabeceras.size();i++){
                System.assertEquals(proformas[i].PROFORMA, finan.cabeceras[i].proforma.Proforma);
                System.assertEquals(proformas[i].VERSION, finan.cabeceras[i].proforma.Version);
            }
        }
        
        List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP> detalles = CEN_cls_Financiamiento.getDetalleFinanciamiento(finan.cabeceras[0].proforma.Proforma, finan.cabeceras[0].proforma.Version);
        List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP> detalles_ex = new List<CEN_WS_Estado_Cuenta_Dos.ZstProformaP>();
        CEN_WS_Estado_Cuenta_Dos.ZstProformaP detalle = new CEN_WS_Estado_Cuenta_Dos.ZstProformaP();
                detalle.Proforma='000123';
                detalle.Version='01';
                detalle.Cuota=1;
                detalle.CuotaAux='';
                detalle.NoDias=30;
                detalle.NoDiasAcu=0;
                detalle.Pagada='';
                detalle.TipoCuota='';
                detalle.SaldoInicial='';
                detalle.Amortizacion='';
                detalle.Intereses='';
                detalle.Gastos='';
                detalle.InteresGastos='';
                detalle.Igv='';
                detalle.SujetoIntIgv='';
                detalle.Desempleo='';
                detalle.SeguroVida='';
                detalle.ImpCuota='';
                detalle.Waers='';
                detalle.SaldoFinal='';
                detalle.FechaVencimiento='';
                detalle.FechaAlterna='';
                detalle.Bukrs='';
                detalle.Belnr='';
                detalle.Gjahr='';
                detalle.FechaTcEntrega='';
                detalle.IndCiLetra='';
                detalle.CuotaPagada='';
                detalle.FechaPago='';
                detalle.FlagFacturado='';
                detalle.FlagCompensado='';
                detalle.FlagPagado='';
                detalle.ImporteCuotaSap='';
                detalle.DescuentoPagoAdelantado='';
                detalle.FechaOperacion='';
                detalle.FlagDevengado='';
                detalle.ImportCancelado='';
                detalle.ImportProtesto='';
                detalle.ImportIntMoratorio='';
                detalle.ImportComisiones='';
                detalle.ImportPagoAdelantado='';
                detalle.FlagEnvioBanco='';
                detalle.FechaEnvioBanco='';
                detalle.FlagLargoPlazo='';
                detalle.ImporteCuotaVencida='';
                detalle.Usrcomppago='';
        detalles_ex.add(detalle);
        System.assertEquals(detalles_ex.size(), detalles.size());
        if(detalles_ex.size()==detalles.size()){
            for(Integer i=0; i<detalles_ex.size();i++){
                System.assertEquals(detalles_ex[i].Proforma, detalles[i].Proforma);
                System.assertEquals(detalles_ex[i].Version, detalles[i].Version);
                System.assertEquals(detalles_ex[i].Cuota, detalles[i].Cuota);
            }
        }
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @future(callout=true)
    public static void g_get_lotes(String cuentaId){
        Test.setMock(WebServiceMock.class, new WSCalloutMock());
        CEN_cls_Agregar_Lote_Interaccion.getDataCliente(cuentaId);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    @future(callout=true)
    public static void h_agregar_lotes_Case(String caseId, String loteId){
        Test.setMock(WebServiceMock.class, new WSCalloutMock());        
        CEN_cls_Agregar_Lote_Interaccion.Response res2 = CEN_cls_Agregar_Lote_Interaccion.BuscarLotesPorCasoTipoCliente(caseId,'CN');
        CEN_cls_Agregar_Lote_Interaccion.Response res3 = CEN_cls_Agregar_Lote_Interaccion.BuscarLotesPorCasoTipoCliente(caseId,'CT');
        CEN_cls_Agregar_Lote_Interaccion.Response res4 = CEN_cls_Agregar_Lote_Interaccion.ActualizarLotes(caseId,null);
        List<CEN_cls_Agregar_Lote_Interaccion.Lote> lotes = new List<CEN_cls_Agregar_Lote_Interaccion.Lote>();
        CEN_cls_Agregar_Lote_Interaccion.Lote lt = new CEN_cls_Agregar_Lote_Interaccion.Lote();
        lt.Id=loteId;
        lt.Name='Lote1';
        lotes.add(lt);
        CEN_cls_Agregar_Lote_Interaccion.Response res5 = CEN_cls_Agregar_Lote_Interaccion.ActualizarLotes(caseId,lotes);
        CEN_cls_Agregar_Lote_Interaccion.Response res1 = CEN_cls_Agregar_Lote_Interaccion.GetDataCase(caseId);
        System.debug('SOQL LIMITS: '+String.valueOf(Limits.getLimitQueries()-Limits.getQueries()));
    }
    public class WSCalloutMock implements WebServiceMock {
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,        
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            String CEN_ws_estado_cuenta_2 = label.CEN_ws_estado_cuenta_2;
            String CEN_ws_estado_cuenta_1 = label.CEN_ws_estado_cuenta_1;
            String CEN_ws_lotes_por_cliente = label.CEN_ws_lotes_por_cliente;
            if(endpoint.equals(CEN_ws_estado_cuenta_1)){
                CEN_WS_Estado_Cuenta_Uno.ZFS_RFC_ESTADO_CUENTAResponse_element response_x = new CEN_WS_Estado_Cuenta_Uno.ZFS_RFC_ESTADO_CUENTAResponse_element();    
               
                CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K proforma = new CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K();
                proforma.PROFORMA='000123';
                proforma.VERSION='01';
                proforma.PROFORMA_ANT='';
                proforma.PROCESSO='';
                proforma.COD_PROPIEDAD='';
                proforma.PROPIEDADES='';
                proforma.COD_MINUTA='';
                proforma.FECHA_FINANCIAMIENTO='';
                proforma.BUKRS='';
                proforma.WAERS='';
                proforma.PRECIO='';
                proforma.TIPO_CAMBIO='';
                proforma.DIAS_PAGO='';
                proforma.IMPORTE_RESERVA='';
                proforma.CUOTA_INIC_IMP_R='';
                proforma.IMPORTE_SALDO_PRECIO='';
                proforma.TASA_ANUAL_INTERES_FINAN='';
                proforma.TASA_ANUAL_GASTOS_ADMIN='';
                proforma.TASA_MENSUAL_INTERES_FINAN='';
                proforma.TASA_MENSUAL_GASTOS_ADMIN='';
                proforma.COSTO_TOTAL_MENSUAL='';
                proforma.COSTO_TOTAL_ANUAL='';
                proforma.IMPORTE_CUOTA='';
                proforma.AMORTIZADO='';
                proforma.KUNNR='';
                proforma.TIP_CLI_CONT='';
                proforma.ERSDA='';
                proforma.AEDAT='';
                proforma.AENAM='';
                proforma.CASH_BLDAT='';
                proforma.CASH='';
                proforma.BFH='';
                proforma.CUOTA_INIC_IMP='';
                proforma.CUOTA_INIC_POR='';
                proforma.CUOTA_INIC_NO_CUOTAS=1;
                proforma.CUOTA_INIC_INTERES='';
                proforma.CUOTA_INIC_INTGAS='';
                proforma.SALDO_NO_CUOTAS=12;
                proforma.PERIODO_DIAS=12;
                proforma.SALDO_INTERESES='';
                proforma.SALDO_INTGAS='';
                proforma.MANTENER_CUOTA='';
                proforma.DISMINUIR_CUOTA='';
                proforma.PROMOTOR='';
                proforma.FECHA_INICIO='';
                proforma.VIA_FINANCIAMIENTO='';
                proforma.REP_LEG1='';
                proforma.REP_LEG2='';
                proforma.AREA_VENDIBLE='';
                proforma.SUP_CONSTRUIDA='';
                proforma.AREA_LIBRE='';
                proforma.BLOQUE_PORTAL='';
                proforma.NUMEROLETRA='';
                proforma.CANTIDAD_LOTES='';
                proforma.TELEMARKETING='';
                proforma.FIRMA_MECANIZ='';
                proforma.TIPO_CONTRATO='';
                proforma.PERIMETRO_FRENTE='';
                proforma.PERIMETRO_FONDO='';
                proforma.PERIMETRO_IZQUI='';
                proforma.PERIMETRO_DEREC='';
                proforma.PERFIL_COBRAN='';
                proforma.ESTADO='';
                proforma.MOTIVO='';
                proforma.VBELN='';
                proforma.TIPO_PROFORMA='';
                proforma.FECHA_CVENTAS='';
                proforma.COD_MOTGRUP='';
                proforma.COD_MOTDET='';
                proforma.FECHA_INACTIVO='';
                proforma.TIPO_PREPAGO='';
                proforma.FECHA_PREPAGO='';
                proforma.FECHA_REVERSION_PREPAGO='';
                proforma.FECHA_CIERRE2='';
                proforma.FECHA_TC_ENTREGA='';
                proforma.FECHA_ENTREGA_TC='';
                proforma.FECHA_ENTREGA_NIFF='';
                proforma.FECHA_ENTREGA_FIS='';
                proforma.TIPO_ENTREGA='';
                proforma.FECHA_CAMB_CONT='';
                proforma.FECHA_DESEMBOLSO='';
                proforma.BANCO='';
                proforma.FECHA_ENT_PROY='';
                proforma.CUOTA_INICIAL_FINANCIA='';
                proforma.APODERADO_CENTENARIO1='';
                proforma.APODERADO_CENTENARIO2='';
                proforma.INTERLOCUTOR1='';
                proforma.INTERLOCUTOR2='';
                proforma.INTERLOCUTOR3='';
                proforma.INTERLOCUTOR4='';
                proforma.INTERLOCUTOR5='';
                proforma.INTERLOCUTOR6='';
                proforma.INTERLOCUTOR7='';
                proforma.INTERLOCUTOR8='';
                proforma.INTERLOCUTOR9='';
                proforma.INTERLOCUTOR10='';
                proforma.APODERADO1='';
                proforma.APODERADO2='';
                proforma.ZZZONAVENTA='';
                proforma.MEDIO='';
                proforma.IND_FINAN_CI='';
                proforma.INTERESES_CI='';
                proforma.FECHA_CARTA_NOTARIAL='';
                proforma.RESOLUCION='';
                proforma.PENDIENTE_RESOLVER='';
                proforma.RESOL_PEND_APRO='';
                proforma.FECHA_RESOLVER='';
                proforma.PORCEN_RESOL_PUNTUAL='';
                proforma.PORCEN_RESOL_CENTENARIO='';
                proforma.PORCEN_RESOL_MOROSO='';
                proforma.OPCION_SOL_COMPRADOR='';
                proforma.OPCION_SOL_VENDEDOR='';
                proforma.OPCION_CAPITAL='';
                proforma.OPCION_CAPITAL_INTERES_GASTOS='';
                proforma.PORCEN_RESOL_PUNTUAL_FINAL='';
                proforma.PORCEN_RESOL_CENTENARIO_FINAL='';
                proforma.PORCEN_COMISION_VENTAS='';
                proforma.OTROS_GASTOS='';
                proforma.OTROS_GASTOS_CLIENTE='';
                proforma.CARGOS_POR_CTA_CLIENTE='';
                proforma.TOTAL_DESCONTAR_PENALIDAD='';
                proforma.MONTO_NC_CAPITAL_PAGADO='';
                proforma.MONTO_NC_CAPITAL_NO_PAGADO='';
                proforma.MONTO_NC_INTERESES_PAGADO='';
                proforma.MONTO_NC_INTERESES_NO_PAGADO='';
                proforma.MONTO_NC_PENALIDAD='';
                proforma.SITUACION_FINANCIAMIENTO='';
                proforma.CREADO_POR='';
                proforma.FLAG_VARIACION_AREA='';
                proforma.METROS_VARIACION_AREA='';
                proforma.MONTO_VARIACION_AREA='';
                proforma.ZAC_DOC_SUNAT='';
                proforma.NCUOTAS_SALDO_ORIGINAL=123;
                proforma.MOTIVO_COMPRA='';
                proforma.ASIENTOAP1='';
                proforma.ASIENTOAP2='';
                proforma.USRCOMPPAGO='';
                proforma.ESIGN_ESTADO='';
                proforma.ESIGN_FECHA='';
                proforma.COMPROB_ORACLE='';
                
                response_x.T_SALIDA= new CEN_WS_Estado_Cuenta_Uno.TABLE_OF_ZST_PROFORMA_K();
                response_x.T_SALIDA.item = new CEN_WS_Estado_Cuenta_Uno.ZST_PROFORMA_K[]{proforma};
                response.put('response_x', response_x); 
            }
            else if(endpoint.equals(CEN_ws_estado_cuenta_2)){
                CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element response_x = new CEN_WS_Estado_Cuenta_Dos.ZfsRfcEstadoCuenta2Response_element();
                CEN_WS_Estado_Cuenta_Dos.ZstProformaK proforma = new CEN_WS_Estado_Cuenta_Dos.ZstProformaK();
                proforma.Proforma='000123';
                proforma.Version='01';
                proforma.ProformaAnt='';
                proforma.Processo='';
                proforma.CodPropiedad='';
                proforma.Propiedades='';
                proforma.CodMinuta='';
                proforma.FechaFinanciamiento='';
                proforma.Bukrs='';
                proforma.Waers='';
                proforma.Precio='';
                proforma.TipoCambio='';
                proforma.DiasPago='';
                proforma.ImporteReserva='';
                proforma.CuotaInicImpR='';
                proforma.ImporteSaldoPrecio='';
                proforma.TasaAnualInteresFinan='';
                proforma.TasaAnualGastosAdmin='';
                proforma.TasaMensualInteresFinan='';
                proforma.TasaMensualGastosAdmin='';
                proforma.CostoTotalMensual='';
                proforma.CostoTotalAnual='';
                proforma.ImporteCuota='';
                proforma.Amortizado='';
                proforma.Kunnr='';
                proforma.TipCliCont='';
                proforma.Ersda='';
                proforma.Aedat='';
                proforma.Aenam='';
                proforma.CashBldat='';
                proforma.Cash='';
                proforma.Bfh='';
                proforma.CuotaInicImp='';
                proforma.CuotaInicPor='';
                proforma.CuotaInicNoCuotas=1;
                proforma.CuotaInicInteres='';
                proforma.CuotaInicIntgas='';
                proforma.SaldoNoCuotas=12;
                proforma.PeriodoDias=12;
                proforma.SaldoIntereses='';
                proforma.SaldoIntgas='';
                proforma.MantenerCuota='';
                proforma.DisminuirCuota='';
                proforma.Promotor='';
                proforma.FechaInicio='';
                proforma.ViaFinanciamiento='';
                proforma.RepLeg1='';
                proforma.RepLeg2='';
                proforma.AreaVendible='';
                proforma.SupConstruida='';
                proforma.AreaLibre='';
                proforma.BloquePortal='';
                proforma.Numeroletra='';
                proforma.CantidadLotes='';
                proforma.Telemarketing='';
                proforma.FirmaMecaniz='';
                proforma.TipoContrato='';
                proforma.PerimetroFrente='';
                proforma.PerimetroFondo='';
                proforma.PerimetroIzqui='';
                proforma.PerimetroDerec='';
                proforma.PerfilCobran='';
                proforma.Estado='';
                proforma.Motivo='';
                proforma.Vbeln='';
                proforma.TipoProforma='';
                proforma.FechaCventas='';
                proforma.CodMotgrup='';
                proforma.CodMotdet='';
                proforma.FechaInactivo='';
                proforma.TipoPrepago='';
                proforma.FechaPrepago='';
                proforma.FechaReversionPrepago='';
                proforma.FechaCierre2='';
                proforma.FechaTcEntrega='';
                proforma.FechaEntregaTc='';
                proforma.FechaEntregaNiff='';
                proforma.FechaEntregaFis='';
                proforma.TipoEntrega='';
                proforma.FechaCambCont='';
                proforma.FechaDesembolso='';
                proforma.Banco='';
                proforma.FechaEntProy='';
                proforma.CuotaInicialFinancia='';
                proforma.ApoderadoCentenario1='';
                proforma.ApoderadoCentenario2='';
                proforma.Interlocutor1='';
                proforma.Interlocutor2='';
                proforma.Interlocutor3='';
                proforma.Interlocutor4='';
                proforma.Interlocutor5='';
                proforma.Interlocutor6='';
                proforma.Interlocutor7='';
                proforma.Interlocutor8='';
                proforma.Interlocutor9='';
                proforma.Interlocutor10='';
                proforma.Apoderado1='';
                proforma.Apoderado2='';
                proforma.Zzzonaventa='';
                proforma.Medio='';
                proforma.IndFinanCi='';
                proforma.InteresesCi='';
                proforma.FechaCartaNotarial='';
                proforma.Resolucion='';
                proforma.PendienteResolver='';
                proforma.ResolPendApro='';
                proforma.FechaResolver='';
                proforma.PorcenResolPuntual='';
                proforma.PorcenResolCentenario='';
                proforma.PorcenResolMoroso='';
                proforma.OpcionSolComprador='';
                proforma.OpcionSolVendedor='';
                proforma.OpcionCapital='';
                proforma.OpcionCapitalInteresGastos='';
                proforma.PorcenResolPuntualFinal='';
                proforma.PorcenResolCentenarioFinal='';
                proforma.PorcenComisionVentas='';
                proforma.OtrosGastos='';
                proforma.OtrosGastosCliente='';
                proforma.CargosPorCtaCliente='';
                proforma.TotalDescontarPenalidad='';
                proforma.MontoNcCapitalPagado='';
                proforma.MontoNcCapitalNoPagado='';
                proforma.MontoNcInteresesPagado='';
                proforma.MontoNcInteresesNoPagado='';
                proforma.MontoNcPenalidad='';
                proforma.SituacionFinanciamiento='';
                proforma.CreadoPor='';
                proforma.FlagVariacionArea='';
                proforma.MetrosVariacionArea='';
                proforma.MontoVariacionArea='';
                proforma.ZacDocSunat='';
                proforma.NcuotasSaldoOriginal=123;
                proforma.MotivoCompra='';
                proforma.Asientoap1='';
                proforma.Asientoap2='';
                proforma.Usrcomppago='';
                proforma.EsignEstado='';
                proforma.EsignFecha='';
                proforma.ComprobOracle='';
                response_x.ExTStProformaK = new CEN_WS_Estado_Cuenta_Dos.ZttStProformaK();
                response_x.ExTStProformaK.item = new CEN_WS_Estado_Cuenta_Dos.ZstProformaK[]{proforma};
                CEN_WS_Estado_Cuenta_Dos.ZstProformaP detalle = new CEN_WS_Estado_Cuenta_Dos.ZstProformaP();
                detalle.Proforma='000123';
                detalle.Version='01';
                detalle.Cuota=1;
                detalle.CuotaAux='';
                detalle.NoDias=30;
                detalle.NoDiasAcu=0;
                detalle.Pagada='';
                detalle.TipoCuota='';
                detalle.SaldoInicial='';
                detalle.Amortizacion='';
                detalle.Intereses='';
                detalle.Gastos='';
                detalle.InteresGastos='';
                detalle.Igv='';
                detalle.SujetoIntIgv='';
                detalle.Desempleo='';
                detalle.SeguroVida='';
                detalle.ImpCuota='';
                detalle.Waers='';
                detalle.SaldoFinal='';
                detalle.FechaVencimiento='';
                detalle.FechaAlterna='';
                detalle.Bukrs='';
                detalle.Belnr='';
                detalle.Gjahr='';
                detalle.FechaTcEntrega='';
                detalle.IndCiLetra='';
                detalle.CuotaPagada='';
                detalle.FechaPago='';
                detalle.FlagFacturado='';
                detalle.FlagCompensado='';
                detalle.FlagPagado='';
                detalle.ImporteCuotaSap='';
                detalle.DescuentoPagoAdelantado='';
                detalle.FechaOperacion='';
                detalle.FlagDevengado='';
                detalle.ImportCancelado='';
                detalle.ImportProtesto='';
                detalle.ImportIntMoratorio='';
                detalle.ImportComisiones='';
                detalle.ImportPagoAdelantado='';
                detalle.FlagEnvioBanco='';
                detalle.FechaEnvioBanco='';
                detalle.FlagLargoPlazo='';
                detalle.ImporteCuotaVencida='';
                detalle.Usrcomppago='';
                response_x.ExTStProformaP = new CEN_WS_Estado_Cuenta_Dos.ZttStProformaP();
                response_x.ExTStProformaP.item = new CEN_WS_Estado_Cuenta_Dos.ZstProformaP[]{detalle};
                response.put('response_x', response_x); 
            }
            else if(endpoint.equals(CEN_ws_lotes_por_cliente)){
                CEN_WS_Lotes_por_Cliente.ZSF_RFC_LOTES_X_CLIENTEResponse_element response_x = new CEN_WS_Lotes_por_Cliente.ZSF_RFC_LOTES_X_CLIENTEResponse_element();               
                CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES lote = new CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES();
                lote.PROCESSO = '';
                lote.COD_PROPIEDAD = '';
                lote.ID_MATERIAL = '111111';
                lote.PROFORMA = '000123';
                lote.FECHA_COMPRA = '';
                lote.STATUS_PROY = '';
                lote.STATUS_PROY_DESC = '';
                lote.FECHA_MINUTA = '';
                lote.AREA_NUEVA = '';
                lote.VARIACION = '';
                lote.AREA_VENDIBLE = '';
                lote.PERIMETRO_FRENTE = '';
                lote.PERIMETRO_FONDO = '';
                lote.PERIMETRO_IZQUI = '';
                lote.PERIMETRO_DEREC = '';
                lote.LINDERO_DERECHA = '';
                lote.LINDERO_IZQUIERDA = '';
                lote.LINDERO_FRENTE = '';
                lote.LINDERO_FONDO = '';
                lote.DESCRIPCION_LARGA = '';
                response_x.ET_LOTES= new CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES_T();
                response_x.ET_LOTES.item = new CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES[]{lote};
                response.put('response_x', response_x); 
            }
        }
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (Test_Controller.respType.equals('ok')) {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>S</TYPE>';
                result += '<ID>ZAC_OTC</ID>';
                result += '<NUMBER>084</NUMBER>';
                result += '<MESSAGE>Se realizó correctamente la modificación de datos. Proforma: 0000026584.</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>0000026584</MESSAGE_V1>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM>Q01CLNT100</SYSTEM>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK>X</E_OK>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (Test_Controller.respType.equals('error'))  {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>E</TYPE>';
                result += '<ID>ZAC_OTC</ID>';
                result += '<NUMBER>087</NUMBER>';
                result += '<MESSAGE>El estado del financiamiento: 0000026584  no es el correcto.</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>0000026584</MESSAGE_V1>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM>Q01CLNT100</SYSTEM>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK/>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    } 
    
}