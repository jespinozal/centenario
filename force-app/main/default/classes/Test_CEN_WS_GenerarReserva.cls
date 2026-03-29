@isTest
private class Test_CEN_WS_GenerarReserva {

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
            String ws_contacto = label.CEN_ws_contacto;
            String ws_reserva = label.CEN_ws_reserva;
            if(endpoint.equals(ws_reserva)){
                CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element response_x = new CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element();
                response_x.ExBelnr='8300000075';
                response_x.ExMessageRetorn='Doc.8300000075 se contabilizó en sociedad 0010';
                response.put('response_x', response_x);
            }else if(endpoint.equals(ws_contacto)){
                CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element response_x = new CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element();
                response_x.ExContacto='C12345678';
                response_x.ExKunnr='12345678';
                response_x.ExMessageRetorn='El contacto ha sido creado de manera exitosa:';
                response.put('response_x', response_x);
            }
        }
}

     private static Map<String, String> GetAuthorization(){
        String user = label.CEN_usersap;
        String pass = label.CEN_passSap;
        Blob sblob = Blob.valueOf(user + ':' + pass);
        String base64_auth = EncodingUtil.base64Encode(sblob);
        Map<String, String> header = new Map<String, String>();
        header.put('Authorization','Basic ' + base64_auth);
        return header;
    }

    @isTest static void a_ReservarLote_Juridica_Success(){
       Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima',
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Numero_de_documento_del__c ='10100010002', Name='Maximule SAC', Phone='6543245', CEN_Direcci_n__c='av siempre viva',
                                     CEN_Estado__c='Cuenta Potencial', RecordTypeId='0124T0000000qqbQAA', CEN_Distrito__c =distrito.Id);
        insert cuenta;
        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, StageName='Operación', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today());
        insert oportunidad;
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='123123123', CODCOMPANIA__c='0010',
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(),
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        String response = CEN_WS_GenerarReserva.CEN_ReservarLote(item.OpportunityId, precio2.Product2Id);
        System.debug('response: '+response);
        //System.assertEquals('Se creó la reserva exitosamente.', response);
    }
    @isTest static void b_ReservarLote_Natural_Success(){
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

        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, CEN_DiscountRate__c = 'Descuento táctico', StageName='Operación', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today());
        insert oportunidad;
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='123123123', CODCOMPANIA__c='0010',
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(),
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        String response = CEN_WS_GenerarReserva.CEN_ReservarLote(item.OpportunityId, precio2.Product2Id);
        System.debug('response: '+response);
        //System.assertEquals('Se creó la reserva exitosamente.', response);
    }
    @isTest static void c_Reserva_cmp_Controller(){
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

        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, StageName='Operación', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today(), CEN_DiscountRate__c = 'Descuento táctico');
        insert oportunidad;
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='123123123', CODCOMPANIA__c='0010',
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(),
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id,Product2Id=lote.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        CEN_Reservas.NivelPagerWrapper response = CEN_Reservas.getReserva(item.Id);
        CEN_Reservas.NivelPagerWrapper expected = new CEN_Reservas.NivelPagerWrapper();
        expected.status='success';
        expected.mensaje='Se creó la reserva exitosamente.';
        expected.id=item.Id;
        System.debug('response: '+response);
        //System.assertEquals(expected.status, response.status);
        //System.assertEquals(expected.mensaje.trim(), response.mensaje.trim());
        System.assertEquals(expected.id, response.id);
    }
    @isTest static void d_invoke_WS_Reserva(){
        CEN_WS_Reserva.ZWS_CREAR_RESERVA_BIND service = new CEN_WS_Reserva.ZWS_CREAR_RESERVA_BIND();
        service.inputHttpHeaders_x = GetAuthorization();
        service.timeout_x = 120000;
        CEN_WS_Reserva.ZsfrfcCrReserva obj = new CEN_WS_Reserva.ZsfrfcCrReserva();
        obj.bukrs = '0010';
        obj.Codzonas='';
        obj.IdMaterial='000000000840001460';
        obj.Rsnum='';
        obj.Pspnr='10U1.011E';
        obj.Posid='';
        obj.Pydes='';
        obj.Waers='PEN';
        obj.Diasb=null;
        obj.Lifnr='';
        obj.Lftxt='';
        obj.Tipox='A';
        obj.Numpe='';
        obj.Conta='C100047667';
        obj.Clien='';
        obj.Elpep='';
        obj.Impor='20';
        obj.Medio='';
        obj.Dmedi='';
        obj.Fecve='';
        obj.MotivoCompra='';
        obj.Arras='';
        obj.Tpago='';
        obj.Noper='';
        obj.Foper='2020-02-17';
        obj.ImpCi='';
        obj.Cuotas=null;
        obj.Imprimir='X';
        Test.setMock(WebServiceMock.class, new WSCalloutMock());
        CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element actual = service.ZsfRfcCrearReserva(obj);
        CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element expected = new CEN_WS_Reserva.ZsfRfcCrearReservaResponse_element();
        expected.ExBelnr='8300000075';
        expected.ExMessageRetorn='Doc.8300000075 se contabilizó en sociedad 0010';
        System.debug('Actual: '+actual);
        System.debug('Expected: '+expected);
        System.assertEquals(expected.ExBelnr, actual.ExBelnr);
        System.assertEquals(expected.ExMessageRetorn, actual.ExMessageRetorn);
    }
    @isTest static void e_invoke_WS_Contacto(){
        CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN service = new CEN_WS_Contacto.ZWS_CREAR_CONTACTO_BIN();
        service.timeout_x = 120000;
        service.inputHttpHeaders_x = GetAuthorization();
        CEN_WS_Contacto.ZsfrfcCrContac obj = new CEN_WS_Contacto.ZsfrfcCrContac();
        Test.setMock(WebServiceMock.class, new WSCalloutMock());
        CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element actual = service.ZsfRfcCrearContacto(obj);
        CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element expected = new CEN_WS_Contacto.ZsfRfcCrearContactoResponse_element();
        expected.ExContacto='C12345678';
        expected.ExKunnr='12345678';
        expected.ExMessageRetorn='El contacto ha sido creado de manera exitosa:';
        System.debug('Actual: '+actual);
        System.debug('Expected: '+expected);
        System.assertEquals(expected.ExContacto, actual.ExContacto);
        System.assertEquals(expected.ExKunnr, actual.ExKunnr);
        System.assertEquals(expected.ExMessageRetorn, actual.ExMessageRetorn);
    }
    @isTest static void f_convertir_prospecto_natural(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima',
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Lead prospecto = new Lead(CEN_Tipo_de_documento__c='DNI', LastName='Maximule', CEN_N_mero_de_documento__c='100010010',
                                  FirstName='max', CEN_Direcci_n_Prospecto__c='av. siempre viva',CEN_Distrito__c=distrito.Id,
                                  CEN_Divisi_n_de_inter_s__c='Lotes de vivienda',CEN_Medio__c='Activaciones / volantes',LeadSource='Presencial');
        insert prospecto;
        prospecto.Status='Convertido';
        update prospecto;
        Test.startTest();
        Database.SaveResult result = Database.update(prospecto, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
    @isTest static void g_convertir_prospecto_juridico(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima',
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Lead prospecto = new Lead(CEN_Tipo_de_documento__c='DNI', LastName='Maximule', CEN_N_mero_de_documento__c='100010010',
                                  FirstName='max', CEN_Direcci_n_Prospecto__c='av. siempre viva',CEN_Distrito__c=distrito.Id,
                                  CEN_RUC__c='10100010012', Company='MAX SAC', CEN_Distrito_Empresa__c=distrito.Id,
                                  CEN_Direcci_n_de_centro_de_trabajo__c='Av. camino real', CEN_Divisi_n_de_inter_s__c='Lotes de vivienda',
                                  CEN_Medio__c='Activaciones / volantes', LeadSource = 'Presencial');
        insert prospecto;
        prospecto.Status='Convertido';
        update prospecto;
        Test.startTest();
        Database.SaveResult result = Database.update(prospecto, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
    @isTest static void h_convertir_prospecto_natural_errors(){
        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima',
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501',
                                                         CEN_Codigo_distrito__c='150105');
        insert distrito;
        Lead prospecto = new Lead(LastName='Maximos', CEN_Divisi_n_de_inter_s__c='LOTES DE VIVIENDA', CEN_RUC__c='10202030309', LeadSource = 'Presencial', CEN_Medio__c='Activaciones / volantes');
        insert prospecto;

        Test.startTest();
        prospecto.Status='Convertido';
        Database.SaveResult result = Database.update(prospecto, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Número de documento, Nombre, Distrito, Nombre de la Compañia Interesada y Distrito de la Compañia Interesada son obligatorios.',
                             result.getErrors()[0].getMessage());

    }
    @isTest static void i_consultar_datos_dni(){
        CEN_WS_Consultar_Datos.DatosPersona expected = new CEN_WS_Consultar_Datos.DatosPersona();
        expected.Nombres = 'Ana Lucia';
        expected.Apellidos = 'Chinguel Rodriguez';
        CEN_WS_Consultar_Datos.DatosPersona actual = CEN_WS_Consultar_Datos.ReniecDNI('44842244');
        System.assertEquals(expected.Nombres, actual.Nombres);
        System.assertEquals(expected.Apellidos, actual.Apellidos);
    }
    @isTest public static void j_CEN_ProspectosDuplicados(){

        Lead prospecto1 = new Lead(FirstName='Max ', LastName='Maximos', CEN_Divisi_n_de_inter_s__c='LOTES DE VIVIENDA',
                                  CEN_N_mero_de_documento__c='78789898', CEN_Tipo_de_documento__c='DNI', LeadSource='Presencial',CEN_Medio__c='Activaciones / volantes');
        insert prospecto1;
        Lead prospecto2 = new Lead(FirstName='Min ', LastName='Minimus',CEN_N_mero_de_documento__c='78789898',
                                   CEN_Tipo_de_documento__c='DNI', LeadSource='Presencial', CEN_Medio__c = '0116');

        Lead prospecto4 = new Lead(FirstName='Medium1', LastName='Mediano2',CEN_N_mero_de_documento__c='78789898',
                                   CEN_Tipo_de_documento__c='DNI', CEN_Elige_donde_vivir__c='Lima Sur - Condominio Finca Bonita', CEN_Divisi_n_de_inter_s__c='Lotes de vivienda',
                                   CEN_Donde_comprar__c='LIMA_Lima_Sur_LU', CEN_Oficina_de_Venta2__c='ZV022', CEN_Tema_de_inter_s__c='Quiero comprar un lote',LeadSource='Presencial', CEN_Medio__c = '0116' );
        insert prospecto4;
        Test.startTest();
        Database.SaveResult result = Database.insert(prospecto2, false);
        Test.stopTest();
        System.debug(result);
        //System.assert(result.isSuccess());
    }
}